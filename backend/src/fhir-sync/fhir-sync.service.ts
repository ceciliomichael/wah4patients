import {
  BadRequestException,
  Injectable,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  buildInternalRecordInsert,
  buildOperationOutcome,
  buildSuccessProcessQueryData,
  extractBundlePatient,
  extractBundleResources,
  extractIdentifiersFromPatient,
  extractIdentifiersFromUnknownResource,
  mapPatientResourceToRecordPatch,
  PreparedFhirCallbackPayload,
} from './fhir-sync.mapper';
import {
  FhirBundleResource,
  FhirPatientResource,
  GatewayProcessQueryRequest,
  GatewayReceivePushRequest,
  GatewayReceiveResultsRequest,
  GatewayResourceType,
  FhirSyncAcknowledgement,
  NormalizedIdentifier,
} from './fhir-sync.types';
import { FhirSyncRepository } from './fhir-sync.repository';

@Injectable()
export class FhirSyncService {
  constructor(
    private readonly configService: ConfigService,
    private readonly repository: FhirSyncRepository,
  ) {}

  async processQuery(payload: unknown): Promise<FhirSyncAcknowledgement> {
    const request = this.parseProcessQueryRequest(payload);
    const profileId = await this.repository.findProfileIdByIdentifiers(request.identifiers);

    if (profileId === null) {
      void this.sendGatewayCallback(request.gatewayReturnUrl, {
        transactionId: request.transactionId,
        status: 'ERROR',
        data: buildOperationOutcome('No matching patient profile was found.'),
      }).catch(() => undefined);
      return { message: 'Processing' };
    }

    const patientProfile = await this.repository.getProfile(profileId);
    if (patientProfile === null) {
      void this.sendGatewayCallback(request.gatewayReturnUrl, {
        transactionId: request.transactionId,
        status: 'ERROR',
        data: buildOperationOutcome('The patient profile is not available.'),
      }).catch(() => undefined);
      return { message: 'Processing' };
    }

    const patientResource = this.buildPatientResource(patientProfile, request.identifiers);
    const storedResources = await this.repository.listRecords(profileId, request.resourceType);
    const responseData = buildSuccessProcessQueryData(
      request.resourceType,
      patientResource,
      storedResources,
    );

    void this.sendGatewayCallback(request.gatewayReturnUrl, {
      transactionId: request.transactionId,
      status: 'SUCCESS',
      data: responseData,
    }).catch(() => undefined);

    return { message: 'Processing' };
  }

  async receiveResults(payload: unknown): Promise<FhirSyncAcknowledgement> {
    const request = this.parseReceiveResultsRequest(payload);

    if (request.status !== 'SUCCESS') {
      return { message: 'Data received successfully' };
    }

    const bundle = this.extractBundle(request.data);
    const patientResource = extractBundlePatient(bundle);
    const patientIdentifiers = patientResource === null ? [] : extractIdentifiersFromPatient(patientResource);
    const profileId = await this.repository.findProfileIdByIdentifiers(patientIdentifiers);

    if (profileId === null) {
      throw new BadRequestException('Unable to match the received result to a patient profile.');
    }

    if (patientResource !== null) {
      await this.repository.updateProfile(profileId, mapPatientResourceToRecordPatch(patientResource));
      await this.repository.upsertPatientIdentifiers(profileId, patientIdentifiers);
    }

    const resources = extractBundleResources(bundle);
    for (const resource of resources) {
      const resourceType = this.readResourceType(resource);
      if (resourceType === null) {
        continue;
      }

      if (resourceType === 'Patient') {
        continue;
      }

      await this.persistInboundResource(profileId, resourceType, resource);
    }

    return { message: 'Data received successfully' };
  }

  async receivePush(payload: unknown): Promise<FhirSyncAcknowledgement> {
    const request = this.parseReceivePushRequest(payload);
    const resourceType = request.resourceType;
    const resource = this.ensureRecord(request.resource);

    const identifiers = extractIdentifiersFromUnknownResource(resource);
    const profileId = await this.repository.findProfileIdByIdentifiers(identifiers);
    if (profileId === null) {
      throw new BadRequestException('Unable to match the pushed resource to a patient profile.');
    }

    if (resourceType === 'Patient' && this.isPatientResource(resource)) {
      await this.repository.updateProfile(profileId, mapPatientResourceToRecordPatch(resource));
      await this.repository.upsertPatientIdentifiers(profileId, extractIdentifiersFromPatient(resource));
      return { message: 'Data received successfully' };
    }

    const normalizedResourceType = this.readResourceType(resource) ?? resourceType;
    await this.persistInboundResource(profileId, normalizedResourceType, resource);
    return { message: 'Data received successfully' };
  }

  private async persistInboundResource(
    profileId: string,
    resourceType: GatewayResourceType,
    resource: Record<string, unknown>,
  ): Promise<void> {
    const record = buildInternalRecordInsert(resourceType, resource);
    if (record === null) {
      return;
    }

    if ('medicationName' in record) {
      await this.repository.insertMedicationResupplyRecord(profileId, record);
      return;
    }

    await this.repository.insertClinicalRecord(resourceType, profileId, record);
  }

  private async sendGatewayCallback(
    gatewayReturnUrl: string,
    payload: PreparedFhirCallbackPayload,
  ): Promise<void> {
    const apiKey = this.getRequiredConfig('WAH4PC_API_KEY');
    const providerId = this.getRequiredConfig('WAH4PC_PROVIDER_ID');

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 15_000);

    try {
      const response = await fetch(gatewayReturnUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-Provider-ID': providerId,
          'X-API-Key': apiKey,
          'Idempotency-Key': crypto.randomUUID(),
        },
        body: JSON.stringify(payload),
        signal: controller.signal,
      });

      if (!response.ok) {
        throw new ServiceUnavailableException(
          `Gateway callback failed with status ${response.status}`,
        );
      }
    } catch (error) {
      if (this.isAbortError(error)) {
        throw new ServiceUnavailableException('Gateway callback timed out.');
      }

      throw new ServiceUnavailableException('Unable to send data back to the gateway.');
    } finally {
      clearTimeout(timeoutId);
    }
  }

  private buildPatientResource(
    profile: { id: string; given_names: string[]; family_name: string; patient_profile: unknown },
    identifiers: NormalizedIdentifier[],
  ): FhirPatientResource {
    return {
      resourceType: 'Patient',
      id: profile.id,
      identifier: identifiers,
      name: [
        {
          given: profile.given_names,
          family: profile.family_name,
        },
      ],
      birthDate: this.readProfileField(profile.patient_profile, 'birthDate'),
      gender: this.readProfileField(profile.patient_profile, 'gender'),
      telecom: this.toTelecomList(profile.patient_profile),
      address: this.toAddressList(profile.patient_profile),
    };
  }

  private extractBundle(data: unknown): FhirBundleResource {
    if (!this.isRecord(data) || data['resourceType'] !== 'Bundle') {
      throw new BadRequestException('Expected a FHIR Bundle in the receive-results payload.');
    }

    return data as unknown as FhirBundleResource;
  }

  private parseProcessQueryRequest(payload: unknown): GatewayProcessQueryRequest {
    if (!this.isRecord(payload)) {
      throw new BadRequestException('Invalid process-query payload.');
    }

    const transactionId = this.readRequiredString(payload['transactionId'], 'transactionId');
    const requesterId = this.readRequiredString(payload['requesterId'], 'requesterId');
    const gatewayReturnUrl = this.readRequiredUrl(payload['gatewayReturnUrl'], 'gatewayReturnUrl');
    const resourceType = this.readResourceType(payload['resourceType']);
    const identifiers = this.readIdentifierList(payload['identifiers']);

    return {
      transactionId,
      requesterId,
      identifiers,
      resourceType,
      gatewayReturnUrl,
      reason: this.readOptionalString(payload['reason']) ?? undefined,
      notes: this.readOptionalString(payload['notes']) ?? undefined,
    };
  }

  private parseReceiveResultsRequest(payload: unknown): GatewayReceiveResultsRequest {
    if (!this.isRecord(payload)) {
      throw new BadRequestException('Invalid receive-results payload.');
    }

    const transactionId = this.readRequiredString(payload['transactionId'], 'transactionId');
    const status = this.readWebhookStatus(payload['status']);
    return {
      transactionId,
      status,
      data: payload['data'],
    };
  }

  private parseReceivePushRequest(payload: unknown): GatewayReceivePushRequest {
    if (!this.isRecord(payload)) {
      throw new BadRequestException('Invalid receive-push payload.');
    }

    const transactionId = this.readRequiredString(payload['transactionId'], 'transactionId');
    const senderId = this.readRequiredString(payload['senderId'], 'senderId');
    const resourceType = this.readResourceType(payload['resourceType']);
    const resource = this.ensureRecord(payload['resource']);

    return {
      transactionId,
      senderId,
      resourceType,
      resource,
      reason: this.readOptionalString(payload['reason']) ?? undefined,
      notes: this.readOptionalString(payload['notes']) ?? undefined,
    };
  }

  private readIdentifierList(value: unknown): NormalizedIdentifier[] {
    if (!Array.isArray(value)) {
      throw new BadRequestException('identifiers must be an array.');
    }

    return value
      .map((identifier) => {
        if (!this.isRecord(identifier)) {
          return null;
        }

        const system = this.readOptionalString(identifier['system']);
        const identifierValue = this.readOptionalString(identifier['value']);
        if (system === null || identifierValue === null) {
          return null;
        }

        return {
          system,
          value: identifierValue,
        };
      })
      .filter((identifier): identifier is NormalizedIdentifier => identifier !== null);
  }

  private readResourceType(value: unknown): GatewayResourceType {
    const resourceType = this.readRequiredString(value, 'resourceType') as GatewayResourceType;
    const supportedTypes: GatewayResourceType[] = [
      'Patient',
      'Condition',
      'Procedure',
      'Immunization',
      'Encounter',
      'Observation',
      'MedicationRequest',
    ];

    if (!supportedTypes.includes(resourceType)) {
      throw new BadRequestException(`Unsupported resource type: ${resourceType}`);
    }

    return resourceType;
  }

  private readWebhookStatus(value: unknown): GatewayReceiveResultsRequest['status'] {
    const status = this.readRequiredString(value, 'status').toUpperCase();
    if (status === 'SUCCESS' || status === 'REJECTED' || status === 'ERROR') {
      return status;
    }

    throw new BadRequestException(`Unsupported webhook status: ${status}`);
  }

  private readRequiredString(value: unknown, fieldName: string): string {
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw new BadRequestException(`Missing required field: ${fieldName}`);
    }

    return value.trim();
  }

  private readOptionalString(value: unknown): string | null {
    if (typeof value !== 'string') {
      return null;
    }

    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : null;
  }

  private readRequiredUrl(value: unknown, fieldName: string): string {
    const url = this.readRequiredString(value, fieldName);
    try {
      return new URL(url).toString();
    } catch {
      throw new BadRequestException(`Invalid URL for ${fieldName}`);
    }
  }

  private ensureRecord(value: unknown): Record<string, unknown> {
    if (!this.isRecord(value)) {
      throw new BadRequestException('Expected an object payload.');
    }

    return value;
  }

  private isPatientResource(value: unknown): value is FhirPatientResource {
    return this.isRecord(value) && value['resourceType'] === 'Patient';
  }

  private readProfileField(profileValue: unknown, fieldName: string): string | undefined {
    if (!this.isRecord(profileValue)) {
      return undefined;
    }

    const value = profileValue[fieldName];
    return typeof value === 'string' && value.trim().length > 0 ? value.trim() : undefined;
  }

  private toTelecomList(profileValue: unknown): Array<{ system?: string; value?: string; use?: string }> {
    if (!this.isRecord(profileValue) || !Array.isArray(profileValue['telecom'])) {
      return [];
    }

    return profileValue['telecom'].flatMap((entry) => {
      if (!this.isRecord(entry)) {
        return [];
      }

      const value = this.readOptionalString(entry['value']);
      if (value === null) {
        return [];
      }

      return [
        {
          system: this.readOptionalString(entry['system']) ?? undefined,
          value,
          use: this.readOptionalString(entry['use']) ?? undefined,
        },
      ];
    });
  }

  private toAddressList(profileValue: unknown): Array<{
    text?: string;
    line?: string[];
    city?: string;
    state?: string;
    postalCode?: string;
    country?: string;
  }> {
    if (!this.isRecord(profileValue) || !Array.isArray(profileValue['address'])) {
      return [];
    }

    return profileValue['address'].flatMap((entry) => {
      if (!this.isRecord(entry)) {
        return [];
      }

      const text = this.readOptionalString(entry['text']);
      const line = Array.isArray(entry['line'])
        ? entry['line'].filter((value): value is string => typeof value === 'string' && value.trim().length > 0)
        : [];

      return [
        {
          text: text ?? undefined,
          line,
          city: this.readOptionalString(entry['city']) ?? undefined,
          state: this.readOptionalString(entry['state']) ?? undefined,
          postalCode: this.readOptionalString(entry['postalCode']) ?? undefined,
          country: this.readOptionalString(entry['country']) ?? undefined,
        },
      ];
    });
  }

  private isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null && !Array.isArray(value);
  }

  private getRequiredConfig(key: string): string {
    const value = this.configService.get<string>(key);
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw new ServiceUnavailableException(`Missing required environment variable: ${key}`);
    }

    return value.trim();
  }

  private isAbortError(error: unknown): boolean {
    return error instanceof Error && error.name === 'AbortError';
  }
}
