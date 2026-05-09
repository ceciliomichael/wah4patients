import {
  BadGatewayException,
  BadRequestException,
  Injectable,
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

const DEFAULT_RESOURCE_TYPE = 'Patient';
const PHILHEALTH_IDENTIFIER_SYSTEM = 'http://philhealth.gov.ph';
const PHILSYS_IDENTIFIER_SYSTEM =
  'http://philsys.gov.ph/fhir/Identifier/philsys-id';
const GATEWAY_PROVIDER_LIST_PATH = '/providers';

@Injectable()
export class IntegrationService {
  constructor(private readonly configService: ConfigService) {}

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

    return {
      canSubmit: true,
      requesterId: this.getRequiredConfig('WAH4PC_PROVIDER_ID'),
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
    const gatewayUrl = this.resolveGatewayApiBaseUrl();
    const requestUrl = new URL(
      path.replace(/^\//, ''),
      `${gatewayUrl}/`,
    ).toString();
    const apiKey = this.getRequiredConfig('WAH4PC_API_KEY');

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 15_000);

    let response: Response;
    try {
      response = await fetch(requestUrl, {
        method: 'GET',
        headers: {
          Accept: 'application/json',
          'x-api-key': apiKey,
        },
        signal: controller.signal,
      });
    } catch (error) {
      if ((error as Error & { name?: string }).name === 'AbortError') {
        throw new ServiceUnavailableException(
          'The WAH4PC Gateway request timed out. Please try again.',
        );
      }

      throw new ServiceUnavailableException(
        'Unable to reach the WAH4PC Gateway. Check the configured gateway URL.',
      );
    } finally {
      clearTimeout(timeoutId);
    }

    const decodedBody = await this.safeParseJson(response);
    if (!response.ok) {
      const message = this.extractErrorMessage(decodedBody);
      throw new BadGatewayException(
        message ??
          `WAH4PC Gateway request failed with status ${response.status}`,
      );
    }

    return decodedBody;
  }

  private async safeParseJson(response: Response): Promise<unknown> {
    const contentType = response.headers.get('content-type') ?? '';
    if (!contentType.includes('application/json')) {
      const textBody = await response.text();
      return textBody.trim().length > 0 ? textBody : null;
    }

    try {
      return await response.json();
    } catch {
      return null;
    }
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

  private extractErrorMessage(payload: unknown): string | undefined {
    if (!this.isRecord(payload)) {
      return undefined;
    }

    const directMessage = payload['message'];
    if (typeof directMessage === 'string' && directMessage.trim().length > 0) {
      return directMessage.trim();
    }

    const errorMessage = payload['error'];
    if (typeof errorMessage === 'string' && errorMessage.trim().length > 0) {
      return errorMessage.trim();
    }

    return undefined;
  }

  private resolveGatewayApiBaseUrl(): string {
    const gatewayUrl = this.getRequiredConfig('WAH4PC_GATEWAY_URL').trim();
    if (gatewayUrl.length === 0) {
      throw new ServiceUnavailableException(
        'Missing WAH4PC gateway URL configuration.',
      );
    }

    const normalized = gatewayUrl.replace(/\/+$/, '');
    return normalized.endsWith('/api/v1') ? normalized : `${normalized}/api/v1`;
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
    if (
      normalized === PHILHEALTH_IDENTIFIER_SYSTEM ||
      normalized === PHILSYS_IDENTIFIER_SYSTEM
    ) {
      return normalized;
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
