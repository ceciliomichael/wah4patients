import {
  BadRequestException,
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  GatewayProviderRecord,
  InteroperabilityProviderSummary,
  InteroperabilityProvidersResponse,
  PrepareSyncRequestPayload,
  PreparedSyncRequestResponse,
} from './integration.types';
import { GATEWAY_REQUEST_DELAY_MS } from '../common/config/runtime-env';
import { GatewayResourceType } from '../fhir-sync/fhir-sync.types';
import { FhirSyncRepository } from '../fhir-sync/fhir-sync.repository';
import { GatewayClientService } from './gateway-client.service';

const DEFAULT_RESOURCE_TYPE = 'Patient';
const PHILHEALTH_IDENTIFIER_SYSTEM =
  'http://philhealth.gov.ph/fhir/Identifier/philhealth-id';
const LEGACY_PHILHEALTH_IDENTIFIER_SYSTEM = 'http://philhealth.gov.ph';
const PHILSYS_IDENTIFIER_SYSTEM =
  'http://philsys.gov.ph/fhir/Identifier/philsys-id';
const PHILSYS_IDENTIFIER_SYSTEM_HTTPS =
  'https://philsys.gov.ph/fhir/Identifier/philsys-id';
const GATEWAY_PROVIDER_LIST_PATH = '/providers';
const GATEWAY_FHIR_REQUEST_PATH_PREFIX = '/fhir/request/';
const SYNC_RESOURCE_TYPES: readonly GatewayResourceType[] = [
  'Patient',
  'Condition',
  'Procedure',
  'Immunization',
  'Encounter',
  'Observation',
] as const;

@Injectable()
export class IntegrationService {
  private readonly logger = new Logger(IntegrationService.name);

  constructor(
    private readonly configService: ConfigService,
    private readonly fhirSyncRepository: FhirSyncRepository,
    private readonly gatewayClient: GatewayClientService,
  ) {}

  async getProviders(): Promise<InteroperabilityProvidersResponse> {
    const response = await this.fetchGatewayJson(GATEWAY_PROVIDER_LIST_PATH);
    const payload = this.extractProviderPayload(response);

    return {
      source: 'wah4pc',
      providers: payload.map((provider) => this.toProviderSummary(provider)),
    };
  }

  async prepareSyncRequest(
    payload: PrepareSyncRequestPayload,
    requesterProfileId?: string,
  ): Promise<PreparedSyncRequestResponse> {
    const providerId = payload.providerId.trim();
    if (!providerId) {
      throw new BadRequestException('Select a provider before preparing sync.');
    }

    const identifierSystem = payload.identifierSystem.trim();
    const identifierValue = payload.identifierValue.trim();
    if (!identifierSystem || !identifierValue) {
      throw new BadRequestException(
        'Select a valid identifier before preparing sync.',
      );
    }

    const providerResponse = await this.getProviders();
    const selectedProvider = providerResponse.providers.find(
      (provider) => provider.id === providerId,
    );

    if (selectedProvider == null) {
      throw new BadRequestException(
        'The selected provider is no longer available.',
      );
    }

    if (!selectedProvider.isActive) {
      throw new BadRequestException(
        'The selected provider is currently inactive.',
      );
    }

    const requesterId = this.getRequiredConfig('WAH4PC_PROVIDER_ID');
    const normalizedRequesterProfileId = requesterProfileId?.trim() ?? '';

    await this.requestSyncResourcesFromGateway({
      requesterId,
      targetId: selectedProvider.id,
      identifierSystem: this.normalizeIdentifierSystem(identifierSystem),
      identifierValue,
      reason: payload.reason?.trim(),
      notes: payload.notes?.trim(),
      requesterProfileId:
        normalizedRequesterProfileId.length > 0
          ? normalizedRequesterProfileId
          : undefined,
    });

    return {
      canSubmit: true,
      requesterId,
      targetProvider: selectedProvider,
      patientIdentifiers: [
        {
          system: this.normalizeIdentifierSystem(identifierSystem),
          value: identifierValue,
        },
      ],
      resourceType: payload.resourceType?.trim() || DEFAULT_RESOURCE_TYPE,
      gatewayUrl: this.getRequiredConfig('WAH4PC_GATEWAY_URL'),
      reason: payload.reason?.trim() || undefined,
      notes: payload.notes?.trim() || undefined,
    };
  }

  private async fetchGatewayJson(path: string): Promise<unknown> {
    return this.gatewayClient.getJson(path);
  }

  private async postGatewayJson(
    path: string,
    body: Record<string, unknown>,
    headers: Record<string, string> = {},
  ): Promise<unknown> {
    return this.gatewayClient.postJson(path, body, headers);
  }

  private async requestSyncResourcesFromGateway(input: {
    requesterId: string;
    requesterProfileId?: string;
    targetId: string;
    identifierSystem: string;
    identifierValue: string;
    reason?: string;
    notes?: string;
  }): Promise<void> {
    for (const resourceType of SYNC_RESOURCE_TYPES) {
      try {
        const transactionId = await this.requestResourceSyncFromGateway({
          resourceType,
          ...input,
        });

        if (input.requesterProfileId !== undefined) {
          await this.fhirSyncRepository.upsertSyncTransaction({
            transactionId,
            profileId: input.requesterProfileId,
            requesterId: input.requesterId,
            targetProviderId: input.targetId,
            resourceType,
          });
        }
      } catch (error) {
        this.logger.error(`Failed to request sync for ${resourceType}:`, error);
      }

      // Add a configurable delay between requests to avoid hitting gateway rate limits/throttling.
      await new Promise((resolve) =>
        setTimeout(resolve, GATEWAY_REQUEST_DELAY_MS),
      );
    }
  }

  private async requestResourceSyncFromGateway(input: {
    resourceType: GatewayResourceType;
    requesterId: string;
    targetId: string;
    identifierSystem: string;
    identifierValue: string;
    reason?: string;
    notes?: string;
  }): Promise<string> {
    const reason = input.reason?.trim();
    const notes = input.notes?.trim();
    const transactionId = crypto.randomUUID();

    const response = await this.postGatewayJson(
      `${GATEWAY_FHIR_REQUEST_PATH_PREFIX}${input.resourceType}`,
      {
        transactionId,
        requesterId: input.requesterId,
        targetId: input.targetId,
        patientIdentifiers: [
          {
            system: input.identifierSystem,
            value: input.identifierValue,
          },
        ],
        reason:
          reason && reason.length > 0
            ? reason
            : 'Patient requested sync records',
        notes: notes && notes.length > 0 ? notes : null,
      },
    );

    return this.extractGatewayTransactionId(
      response,
      input.resourceType,
      transactionId,
    );
  }

  private extractGatewayTransactionId(
    response: unknown,
    resourceType: GatewayResourceType,
    fallbackTransactionId: string,
  ): string {
    if (!this.isRecord(response)) {
      return fallbackTransactionId;
    }

    const data = response['data'];
    if (this.isRecord(data)) {
      const nestedId = data['id'];
      if (typeof nestedId === 'string' && nestedId.trim().length > 0) {
        return nestedId.trim();
      }

      const nestedTransactionId = data['transactionId'];
      if (
        typeof nestedTransactionId === 'string' &&
        nestedTransactionId.trim().length > 0
      ) {
        return nestedTransactionId.trim();
      }

      const nestedTransactionIdSnake = data['transaction_id'];
      if (
        typeof nestedTransactionIdSnake === 'string' &&
        nestedTransactionIdSnake.trim().length > 0
      ) {
        return nestedTransactionIdSnake.trim();
      }
    }

    const directId = response['transactionId'];
    if (typeof directId === 'string' && directId.trim().length > 0) {
      return directId.trim();
    }

    const snakeCaseId = response['transaction_id'];
    if (typeof snakeCaseId === 'string' && snakeCaseId.trim().length > 0) {
      return snakeCaseId.trim();
    }

    return fallbackTransactionId;
  }

  private extractProviderPayload(payload: unknown): GatewayProviderRecord[] {
    if (Array.isArray(payload)) {
      return payload.filter((provider) =>
        this.isGatewayProviderRecord(provider),
      );
    }

    if (this.isRecord(payload)) {
      const directProviders = payload['providers'];
      if (Array.isArray(directProviders)) {
        return directProviders.filter((provider) =>
          this.isGatewayProviderRecord(provider),
        );
      }

      const wrappedProviders = payload['data'];
      if (Array.isArray(wrappedProviders)) {
        return wrappedProviders.filter((provider) =>
          this.isGatewayProviderRecord(provider),
        );
      }

      if (
        this.isRecord(wrappedProviders) &&
        Array.isArray(wrappedProviders['providers'])
      ) {
        return wrappedProviders['providers'].filter((provider) =>
          this.isGatewayProviderRecord(provider),
        );
      }
    }

    return [];
  }

  private toProviderSummary(
    provider: GatewayProviderRecord,
  ): InteroperabilityProviderSummary {
    return {
      id: provider.id.trim(),
      name: provider.name.trim(),
      type: provider.type.trim(),
      facilityCode: provider.facility_code.trim(),
      location: provider.location.trim(),
      isActive: provider.isActive,
    };
  }

  private getRequiredConfig(key: string): string {
    const value = this.configService.get<string>(key);
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw new ServiceUnavailableException(
        `Missing required environment variable: ${key}`,
      );
    }

    return value.trim();
  }

  private normalizeIdentifierSystem(identifierSystem: string): string {
    const normalized = identifierSystem.trim();
    if (normalized === LEGACY_PHILHEALTH_IDENTIFIER_SYSTEM) {
      return PHILHEALTH_IDENTIFIER_SYSTEM;
    }

    if (normalized === PHILSYS_IDENTIFIER_SYSTEM_HTTPS) {
      return PHILSYS_IDENTIFIER_SYSTEM;
    }

    return normalized;
  }

  private isGatewayProviderRecord(
    value: unknown,
  ): value is GatewayProviderRecord {
    if (!this.isRecord(value)) {
      return false;
    }

    return (
      typeof value['id'] === 'string' &&
      typeof value['name'] === 'string' &&
      typeof value['type'] === 'string' &&
      typeof value['facility_code'] === 'string' &&
      typeof value['location'] === 'string' &&
      typeof value['isActive'] === 'boolean'
    );
  }

  private isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null;
  }
}
