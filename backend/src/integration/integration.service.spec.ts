import {
  BadRequestException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FhirSyncRepository } from '../fhir-sync/fhir-sync.repository';
import { IntegrationService } from './integration.service';

describe('IntegrationService', () => {
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

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('normalizes the provider payload from the gateway response', async () => {
    const fetchSpy = jest.spyOn(globalThis, 'fetch').mockResolvedValue(
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
              isActive: true,
            },
          ],
        }),
        {
          status: 200,
          headers: { 'content-type': 'application/json' },
        },
      ) as Response,
    );

    const service = new IntegrationService(
      createConfigService(),
      createRepositoryMock() as FhirSyncRepository,
    );
    const result = await service.getProviders();

    expect(fetchSpy).toHaveBeenCalledTimes(1);
    expect(result.source).toBe('wah4pc');
    expect(result.providers).toEqual([
      {
        id: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
        name: 'WAH for Clinics',
        type: 'clinic',
        facilityCode: 'WAH4C',
        location: 'Tarlac City',
        isActive: true,
      },
    ]);
  });

  it('prepares a sync request using the configured requester provider id', async () => {
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
    const fetchSpy = jest.spyOn(globalThis, 'fetch').mockImplementation(
      async (input: RequestInfo | URL) => {
        const requestUrl = input.toString();
        if (requestUrl.endsWith('/providers')) {
          return providerResponse.clone();
        }

        const resourceType = requestUrl.split('/').pop() ?? 'Patient';
        return new Response(
          JSON.stringify({
            success: true,
            data: {
              id: `txn_${resourceType.toLowerCase()}`,
              status: 'PENDING',
            },
          }),
          {
            status: 202,
            headers: { 'content-type': 'application/json' },
          },
        );
      },
    );

    const repositoryMock = createRepositoryMock();
    const service = new IntegrationService(
      createConfigService(),
      repositoryMock as FhirSyncRepository,
    );
    const result = await service.prepareSyncRequest(
      {
        providerId: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
        identifierSystem: 'https://philsys.gov.ph/fhir/Identifier/philsys-id',
        identifierValue: '1234-1234567-1',
        reason: 'Record sync',
        notes: 'Prepared from mobile app',
      },
      '550e8400-e29b-41d4-a716-446655440000',
    );

    expect(fetchSpy).toHaveBeenCalledTimes(8);
    expect(result.canSubmit).toBe(true);
    expect(result.requesterId).toBe(baseConfig.WAH4PC_PROVIDER_ID);
    expect(result.targetProvider.id).toBe(
      '7fffb351-9a0f-4327-9c22-da6344fa74b5',
    );
    expect(result.patientIdentifiers).toEqual([
      {
        system: 'http://philsys.gov.ph/fhir/Identifier/philsys-id',
        value: '1234-1234567-1',
      },
    ]);
    expect(fetchSpy.mock.calls.map((call) => call[0].toString())).toEqual([
      'https://wah4pc.echosphere.cfd/api/v1/providers',
      'https://wah4pc.echosphere.cfd/api/v1/fhir/request/Patient',
      'https://wah4pc.echosphere.cfd/api/v1/fhir/request/Condition',
      'https://wah4pc.echosphere.cfd/api/v1/fhir/request/Procedure',
      'https://wah4pc.echosphere.cfd/api/v1/fhir/request/Immunization',
      'https://wah4pc.echosphere.cfd/api/v1/fhir/request/Encounter',
      'https://wah4pc.echosphere.cfd/api/v1/fhir/request/Observation',
      'https://wah4pc.echosphere.cfd/api/v1/fhir/request/MedicationRequest',
    ]);
    const requestCall = fetchSpy.mock.calls[1];
    const requestInit = requestCall?.[1] as RequestInit | undefined;
    expect(requestInit?.body).toContain(
      '"system":"http://philsys.gov.ph/fhir/Identifier/philsys-id"',
    );
    expect(result.gatewayUrl).toBe(baseConfig.WAH4PC_GATEWAY_URL);
    expect(repositoryMock.upsertSyncTransaction).toHaveBeenCalledTimes(7);
    expect(repositoryMock.upsertSyncTransaction).toHaveBeenCalledWith(
      expect.objectContaining({
        transactionId: 'txn_patient',
        profileId: '550e8400-e29b-41d4-a716-446655440000',
        requesterId: baseConfig.WAH4PC_PROVIDER_ID,
        targetProviderId: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
      }),
    );
  });

  it('rejects sync preparation when the selected provider is inactive', async () => {
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

    const service = new IntegrationService(
      createConfigService(),
      createRepositoryMock() as FhirSyncRepository,
    );

    await expect(
      service.prepareSyncRequest(
        {
          providerId: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
          identifierSystem: 'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
          identifierValue: '12-345678901-2',
        },
        '550e8400-e29b-41d4-a716-446655440000',
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('surfaces gateway connectivity issues as service unavailability', async () => {
    jest
      .spyOn(globalThis, 'fetch')
      .mockRejectedValue(new Error('network down'));

    const service = new IntegrationService(
      createConfigService(),
      createRepositoryMock() as FhirSyncRepository,
    );

    await expect(service.getProviders()).rejects.toBeInstanceOf(
      ServiceUnavailableException,
    );
  });
});
