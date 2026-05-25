import {
  BadRequestException,
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AppointmentHistoryRepository } from '../appointment-history/appointment-history.repository';
import {
  buildOperationOutcome,
  buildSuccessProcessQueryData,
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
import { parseInboundResource, isParsedPatientResource } from './parsers/fhir-parser.registry';
import { ParsedClinicalResource } from './parsers/fhir-parser.types';

@Injectable()
export class FhirSyncService {
  private readonly logger = new Logger(FhirSyncService.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly repository: FhirSyncRepository,
    private readonly appointmentHistoryRepository: AppointmentHistoryRepository,
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
    const profileId = await this.repository.findProfileIdByTransactionId(
      request.transactionId,
    );

    return this.persistReceiveResultsBundle(bundle, profileId ?? undefined);
  }

  async receiveResultsForProfile(
    profileId: string,
    payload: unknown,
  ): Promise<FhirSyncAcknowledgement> {
    const request = this.parseReceiveResultsRequest(payload);

    if (request.status !== 'SUCCESS') {
      return { message: 'Data received successfully' };
    }

    const bundle = this.extractBundle(request.data);
    return this.persistReceiveResultsBundle(bundle, profileId);
  }

  private async persistReceiveResultsBundle(
    bundle: FhirBundleResource,
    profileId?: string,
  ): Promise<FhirSyncAcknowledgement> {
    const parsedResources = extractBundleResources(bundle).map((resource) =>
      parseInboundResource(resource),
    );
    const patientResource = parsedResources.find(isParsedPatientResource);
    const patientIdentifiers =
      patientResource === undefined
        ? parsedResources.flatMap((resource) =>
            extractIdentifiersFromUnknownResource(resource.resource),
          )
        : extractIdentifiersFromPatient(patientResource.resource);
    const resolvedProfileId =
      profileId ?? (await this.repository.findProfileIdByIdentifiers(patientIdentifiers));

    if (resolvedProfileId === null || resolvedProfileId === undefined) {
      throw new BadRequestException('Unable to match the received result to a patient profile.');
    }

    if (patientResource !== undefined) {
      await this.repository.updateProfile(
        resolvedProfileId,
        mapPatientResourceToRecordPatch(patientResource.resource),
      );
      await this.repository.upsertPatientIdentifiers(
        resolvedProfileId,
        extractIdentifiersFromPatient(patientResource.resource),
      );
    }

    for (const parsedResource of parsedResources) {
      if (isParsedPatientResource(parsedResource)) {
        continue;
      }

      await this.persistParsedInboundResource(resolvedProfileId, parsedResource);
    }

    return { message: 'Data received successfully' };
  }

  async receivePush(payload: unknown): Promise<FhirSyncAcknowledgement> {
    const request = this.parseReceivePushRequest(payload);
    this.logger.log(
      `Received receive-push request: resourceType=${request.resourceType} transactionId=${request.transactionId} correlationId=${request.correlationId ?? 'n/a'} senderId=${request.senderId}`,
    );

    if (request.resourceType === 'Appointment') {
      if (request.correlationId === undefined) {
        this.logger.warn(
          `Appointment receive-push is missing correlationId: transactionId=${request.transactionId} senderId=${request.senderId}`,
        );
        throw new BadRequestException(
          'Unable to match the appointment push without a correlationId.',
        );
      }

      const approvedByCorrelationId =
        await this.appointmentHistoryRepository.markAppointmentHistoryApprovedByCorrelationId(
          request.correlationId,
        );

      if (approvedByCorrelationId) {
        this.logger.log(
          `Appointment receive-push matched by correlationId=${request.correlationId}`,
        );
        return { message: 'Data received successfully' };
      }

      this.logger.warn(
        `Appointment receive-push did not match a pending history record by correlationId=${request.correlationId} transactionId=${request.transactionId}`,
      );
      throw new BadRequestException(
        'Unable to match the appointment push to a pending history record.',
      );
    }

    const parsedResource = parseInboundResource(request.resource);

    const identifiers = extractIdentifiersFromUnknownResource(parsedResource.resource);
    const profileId = await this.repository.findProfileIdByIdentifiers(identifiers);
    if (profileId === null) {
      throw new BadRequestException('Unable to match the pushed resource to a patient profile.');
    }

    if (isParsedPatientResource(parsedResource)) {
      await this.repository.updateProfile(
        profileId,
        mapPatientResourceToRecordPatch(parsedResource.resource),
      );
      await this.repository.upsertPatientIdentifiers(
        profileId,
        extractIdentifiersFromPatient(parsedResource.resource),
      );
      return { message: 'Data received successfully' };
    }

    await this.persistParsedInboundResource(profileId, parsedResource);
    return { message: 'Data received successfully' };
  }

  private async persistParsedInboundResource(
    profileId: string,
    parsedResource: ParsedClinicalResource,
  ): Promise<void> {
    if ('medicationName' in parsedResource.insert) {
      await this.repository.insertMedicationResupplyRecord(profileId, parsedResource.insert);
      return;
    }

    await this.repository.insertClinicalRecord(
      parsedResource.resourceType,
      profileId,
      parsedResource.insert,
    );
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
    if (!this.isRecord(payload['resource'])) {
      throw new BadRequestException('Expected an object payload.');
    }

    const resource = payload['resource'];
    const correlationId = this.readReceivePushCorrelationId(payload, resource);

    return {
      transactionId,
      correlationId,
      senderId,
      resourceType,
      resource,
      reason: this.readOptionalString(payload['reason']) ?? undefined,
      notes: this.readOptionalString(payload['notes']) ?? undefined,
    };
  }

  private readReceivePushCorrelationId(
    payload: Record<string, unknown>,
    resource: Record<string, unknown>,
  ): string | undefined {
    return (
      this.readOptionalString(payload['correlationId']) ??
      this.readAppointmentIdentifierValue(resource) ??
      this.readAppointmentIdentifierValue(payload['data']) ??
      undefined
    );
  }

  private readAppointmentIdentifierValue(value: unknown): string | null {
    if (!this.isRecord(value) || !Array.isArray(value['identifier'])) {
      return null;
    }

    const schedulingRequestIdentifier = value['identifier'].find((identifier) => {
      if (!this.isRecord(identifier)) {
        return false;
      }

      const system = this.readOptionalString(identifier['system']);
      return (
        system === 'https://wah.ph/fhir/Identifier/scheduling-request-id' ||
        system === 'https://wah.ph/fhir/Identifier/appointment-id'
      );
    });

    if (this.isRecord(schedulingRequestIdentifier)) {
      return this.readOptionalString(schedulingRequestIdentifier['value']);
    }

    return null;
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
      'Appointment',
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
