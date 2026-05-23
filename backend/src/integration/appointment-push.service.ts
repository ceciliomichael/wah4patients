import { BadRequestException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { randomUUID } from 'node:crypto';
import { IntegrationService } from './integration.service';
import { GatewayClientService } from './gateway-client.service';
import {
  AppointmentPushGatewayRequest,
  AppointmentPushRequestPayload,
  AppointmentPushResponse,
  FhirAppointmentResource,
} from './appointment-push.types';

@Injectable()
export class AppointmentPushService {
  constructor(
    private readonly configService: ConfigService,
    private readonly integrationService: IntegrationService,
    private readonly gatewayClient: GatewayClientService,
  ) {}

  async sendAppointmentRequest(
    payload: AppointmentPushRequestPayload,
  ): Promise<AppointmentPushResponse> {
    const targetProvider = await this.resolveTargetProvider(
      payload.targetProviderId.trim(),
    );
    const senderId = this.getRequiredConfig('WAH4PC_PROVIDER_ID');
    const gatewayUrl = this.getRequiredConfig('WAH4PC_GATEWAY_URL');
    const appointment = this.buildAppointmentResource(payload, targetProvider.name);
    const gatewayRequest: AppointmentPushGatewayRequest = {
      senderId,
      targetId: targetProvider.id,
      resource: appointment,
      data: appointment, // Adding this because hospital backend might require it due to buggy implementation
      reason: this.readOptionalText(payload.reason),
      notes: this.readOptionalText(payload.notes),
    };

    const response = await this.gatewayClient.postJson(
      '/fhir/push/Appointment',
      gatewayRequest as unknown as Record<string, unknown>,
      {
        'X-Provider-ID': senderId,
        'Idempotency-Key': randomUUID(),
      },
    );

    const transactionId = this.extractTransactionId(response);

    return {
      message: 'Appointment request sent to the gateway successfully.',
      transactionId,
      requesterId: senderId,
      targetProvider,
      appointment,
      gatewayUrl,
    };
  }

  private async resolveTargetProvider(providerId: string) {
    if (providerId.length === 0) {
      throw new BadRequestException('Select a provider before sending the request.');
    }

    const providersResponse = await this.integrationService.getProviders();
    const selectedProvider = providersResponse.providers.find(
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

    return selectedProvider;
  }

  private buildAppointmentResource(
    payload: AppointmentPushRequestPayload,
    providerName: string,
  ): FhirAppointmentResource {
    const scheduledAt = new Date(payload.scheduledAt);
    if (Number.isNaN(scheduledAt.getTime())) {
      throw new BadRequestException('Scheduled time is invalid.');
    }

    const durationMinutes = Number.isFinite(payload.durationMinutes)
      ? Math.floor(payload.durationMinutes)
      : 30;
    const normalizedDurationMinutes = durationMinutes >= 15 ? durationMinutes : 15;
    const endAt = new Date(
      scheduledAt.getTime() + normalizedDurationMinutes * 60_000,
    );
    const reason = this.readOptionalText(payload.reason) ?? payload.appointmentType;
    const notes = this.readOptionalText(payload.notes);
    const locationOrPlatform = payload.locationOrPlatform.trim();
    const appointmentType = payload.appointmentType.trim();
    const modeLabel = payload.appointmentMode === 'onsite'
      ? 'Onsite consultation'
      : 'Teleconsultation';

    return {
      resourceType: 'Appointment',
      meta: {
        profile: [
          'https://fhir-ph-core.wah.ph/phcore/StructureDefinition/ph-core-appointment'
        ]
      },
      identifier: [
        {
          use: 'secondary',
          system: 'https://wah.ph/fhir/Identifier/scheduling-request-id',
          value: randomUUID()
        }
      ],
      status: 'proposed',
      serviceCategory: [
        {
          coding: [
            {
              system: 'https://wah.ph/fhir/CodeSystem/service-category',
              code: payload.appointmentMode === 'onsite' ? 'outpatient' : 'teleconsultation',
              display: payload.appointmentMode === 'onsite' ? 'Outpatient Services' : 'Teleconsultation Services'
            }
          ]
        }
      ],
      description: `${appointmentType} request (${modeLabel})`,
      start: scheduledAt.toISOString(),
      end: endAt.toISOString(),
      participant: [
        {
          actor: {
            type: 'Patient',
            identifier: {
              system: payload.identifierSystem.trim(),
              value: payload.identifierValue.trim(),
            },
          },
          required: 'required',
          status: 'accepted',
        },
        {
          actor: {
            type: 'Practitioner',
            identifier: {
              system: 'https://wah.ph/fhir/Identifier/provider-id',
              value: payload.targetProviderId.trim()
            }
          },
          required: 'required',
          status: 'needs-action'
        }
      ],
      reasonCode: [{ text: reason }],
      note: [
        {
          text:
            notes ??
            `${appointmentType} via ${locationOrPlatform} for ${providerName}.`,
        },
      ],
    };
  }

  private extractTransactionId(response: unknown): string {
    if (!this.isRecord(response)) {
      throw new BadRequestException(
        'WAH4PC Gateway did not return a transaction response.',
      );
    }

    const directId = response['id'];
    if (typeof directId === 'string' && directId.trim().length > 0) {
      return directId.trim();
    }

    const nestedId = response['transactionId'];
    if (typeof nestedId === 'string' && nestedId.trim().length > 0) {
      return nestedId.trim();
    }

    throw new BadRequestException(
      'WAH4PC Gateway did not return a transaction id.',
    );
  }

  private readOptionalText(value: string | undefined): string | undefined {
    const trimmed = value?.trim() ?? '';
    return trimmed.length > 0 ? trimmed : undefined;
  }

  private getRequiredConfig(key: string): string {
    const value = this.configService.get<string>(key);
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw new BadRequestException(
        `Missing required environment variable: ${key}`,
      );
    }

    return value.trim();
  }

  private isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null;
  }
}
