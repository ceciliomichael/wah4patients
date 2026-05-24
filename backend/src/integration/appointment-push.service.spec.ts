import { BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { AppointmentHistoryRepository } from '../appointment-history/appointment-history.repository';
import { FhirSyncRepository } from '../fhir-sync/fhir-sync.repository';
import { GatewayClientService } from './gateway-client.service';
import { AppointmentPushService } from './appointment-push.service';
import { IntegrationService } from './integration.service';

describe('AppointmentPushService', () => {
  const baseConfig = {
    WAH4PC_GATEWAY_URL: 'https://wah4pc.echosphere.cfd',
    WAH4PC_API_KEY: 'gateway-test-api-key-1234567890',
    WAH4PC_PROVIDER_ID: '550e8400-e29b-41d4-a716-446655440000',
  };

  const createConfigService = (
    overrides: Partial<Record<keyof typeof baseConfig, string>> = {},
  ): ConfigService => {
    const values = { ...baseConfig, ...overrides };

    return {
      get: (key: string) => values[key as keyof typeof values] ?? '',
    } as ConfigService;
  };

  const createRepositoryMock = (): Pick<
    FhirSyncRepository,
    'upsertSyncTransaction'
  > => {
    return {
      upsertSyncTransaction: jest.fn().mockResolvedValue(undefined),
    };
  };

  const createAppointmentHistoryRepositoryMock = (): Pick<
    AppointmentHistoryRepository,
    'insertPendingAppointmentHistoryRecord'
  > => {
    return {
      insertPendingAppointmentHistoryRecord: jest.fn().mockResolvedValue(undefined),
    };
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('builds and sends an appointment push to the selected provider', async () => {
    const providerResponse = new Response(
      JSON.stringify({
        success: true,
        data: [
          {
            id: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
            name: 'WAH for Clinics',
            type: 'clinic',
            facility_code: 'WAH4C',
            location: 'Tarlac City',
            isActive: true,
          },
        ],
      }),
      {
        status: 200,
        headers: { 'content-type': 'application/json' },
      },
    );
    const pushResponse = new Response(
      JSON.stringify({
        id: 'txn_appointment_123',
        status: 'COMPLETED',
      }),
      {
        status: 200,
        headers: { 'content-type': 'application/json' },
      },
    );

    const fetchSpy = jest.spyOn(globalThis, 'fetch').mockImplementation(
      async (input: RequestInfo | URL, init?: RequestInit) => {
        const requestUrl = input.toString();
        if (requestUrl.endsWith('/providers')) {
          return providerResponse.clone();
        }

        if (requestUrl.endsWith('/fhir/push/Appointment')) {
          expect(init?.headers).toEqual(
            expect.objectContaining({
              'X-Provider-ID': baseConfig.WAH4PC_PROVIDER_ID,
              'Idempotency-Key': expect.any(String),
            }),
          );
          return pushResponse.clone();
        }

        throw new Error(`Unexpected request: ${requestUrl}`);
      },
    );

    const configService = createConfigService();
    const gatewayClient = new GatewayClientService(configService);
    const integrationService = new IntegrationService(
      configService,
      createRepositoryMock() as FhirSyncRepository,
      gatewayClient,
    );
    const service = new AppointmentPushService(
      configService,
      integrationService,
      gatewayClient,
      createAppointmentHistoryRepositoryMock() as AppointmentHistoryRepository,
    );

    const result = await service.sendAppointmentRequest({
      targetProviderId: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
      appointmentMode: 'onsite',
      appointmentType: 'General Checkup',
      scheduledAt: '2026-03-18T09:00:00+08:00',
      durationMinutes: 30,
      locationOrPlatform: 'WAH Main Clinic',
      identifierSystem: 'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
      identifierValue: '12-345678901-2',
      reason: 'Follow-up consultation after lab results',
      notes: 'Please confirm availability for the morning slot.',
    }, '11111111-1111-1111-1111-111111111111');

    expect(fetchSpy).toHaveBeenCalledTimes(2);
    expect(result.message).toContain('successfully');
    expect(result.transactionId).toBe('txn_appointment_123');
    expect(result.requesterId).toBe(baseConfig.WAH4PC_PROVIDER_ID);
    expect(result.targetProvider.id).toBe(
      '7fffb351-9a0f-4327-9c22-da6344fa74b5',
    );
    expect(result.appointment.resourceType).toBe('Appointment');
    expect(result.appointment.description).toContain('General Checkup');
    expect(result.appointment.start).toBe('2026-03-18T01:00:00.000Z');
  });

  it('rejects inactive providers before sending the gateway push', async () => {
    jest.spyOn(globalThis, 'fetch').mockResolvedValue(
      new Response(
        JSON.stringify({
          success: true,
          data: [
            {
              id: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
              name: 'WAH for Clinics',
              type: 'clinic',
              facility_code: 'WAH4C',
              location: 'Tarlac City',
              isActive: false,
            },
          ],
        }),
        {
          status: 200,
          headers: { 'content-type': 'application/json' },
        },
      ) as Response,
    );

    const configService = createConfigService();
    const gatewayClient = new GatewayClientService(configService);
    const integrationService = new IntegrationService(
      configService,
      createRepositoryMock() as FhirSyncRepository,
      gatewayClient,
    );
    const service = new AppointmentPushService(
      configService,
      integrationService,
      gatewayClient,
      createAppointmentHistoryRepositoryMock() as AppointmentHistoryRepository,
    );

    await expect(
      service.sendAppointmentRequest({
        targetProviderId: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
        appointmentMode: 'teleconsultation',
        appointmentType: 'Medication Review',
        scheduledAt: '2026-03-18T09:00:00+08:00',
        durationMinutes: 30,
        locationOrPlatform: 'Google Meet',
        identifierSystem: 'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
        identifierValue: '12-345678901-2',
      }, '11111111-1111-1111-1111-111111111111'),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
