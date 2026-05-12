import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { AuthSupportService } from '../src/auth/auth-support.service';
import { AppModule } from '../src/app.module';
import { FhirSyncService } from '../src/fhir-sync/fhir-sync.service';

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;
  const fhirSyncServiceMock = {
    receiveResults: jest.fn().mockResolvedValue({ message: 'Data received successfully' }),
    receiveResultsForProfile: jest
      .fn()
      .mockResolvedValue({ message: 'Data received successfully' }),
  };
  const authSupportServiceMock = {
    getAuthenticatedUserFromHeader: jest.fn().mockResolvedValue({
      id: '550e8400-e29b-41d4-a716-446655440000',
      email: 'patient@example.com',
    }),
  };

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(AuthSupportService)
      .useValue(authSupportServiceMock)
      .overrideProvider(FhirSyncService)
      .useValue(fhirSyncServiceMock)
      .compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('api/v1');
    await app.init();
  });

  afterEach(() => {
    jest.restoreAllMocks();
    jest.clearAllMocks();
  });

  afterAll(async () => {
    if (app !== undefined) {
      await app.close();
    }
  });

  it('/api/v1/health (GET)', () => {
    return request(app.getHttpServer())
      .get('/api/v1/health')
      .expect(200)
      .expect((response) => {
        const body = response.body as { status?: string; timestamp?: string };
        expect(body.status).toBe('ok');
        expect(typeof body.timestamp).toBe('string');
      });
  });

  it('/api/v1/auth/login (POST) requires x-api-key', () => {
    return request(app.getHttpServer()).post('/api/v1/auth/login').expect(401);
  });

  it('/api/v1/interoperability/providers (GET)', async () => {
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

    await request(app.getHttpServer())
      .get('/api/v1/interoperability/providers')
      .set('x-api-key', 'test-api-key-12345678901234567890')
      .expect(200)
      .expect((response) => {
        expect(response.body).toEqual({
          source: 'wah4pc',
          providers: [
            {
              id: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
              name: 'WAH for Clinics',
              type: 'clinic',
              facilityCode: 'WAH4C',
              location: 'Tarlac City',
              isActive: true,
            },
          ],
        });
      });
  });

  it('/api/v1/interoperability/sync/prepare (POST)', async () => {
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

    await request(app.getHttpServer())
      .post('/api/v1/interoperability/sync/prepare')
      .set('x-api-key', 'test-api-key-12345678901234567890')
      .send({
        providerId: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
        identifierSystem:
          'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
        identifierValue: '12-345678901-2',
      })
      .expect(200)
      .expect((response) => {
        expect(response.body.requesterId).toBe(
          '550e8400-e29b-41d4-a716-446655440000',
        );
        expect(response.body.targetProvider.id).toBe(
          '7fffb351-9a0f-4327-9c22-da6344fa74b5',
        );
        expect(response.body.patientIdentifiers).toEqual([
          {
            system: 'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
            value: '12-345678901-2',
          },
        ]);
      });
  });

  it('/api/v1/interoperability/sync/simulate (POST)', async () => {
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

    await request(app.getHttpServer())
      .post('/api/v1/interoperability/sync/simulate')
      .set('x-api-key', 'test-api-key-12345678901234567890')
      .set('authorization', 'Bearer test-access-token')
      .send({
        providerId: '7fffb351-9a0f-4327-9c22-da6344fa74b5',
        identifierSystem:
          'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
        identifierValue: '12-345678901-2',
      })
      .expect(200)
      .expect((response) => {
        expect(response.body.message).toBe(
          'Simulated PH Core bundle stored successfully.',
        );
        expect(response.body.transactionId).toEqual(expect.any(String));
        expect(response.body.storedResourceTypes).toEqual([
          'Patient',
          'Immunization',
          'Encounter',
          'Observation',
          'Condition',
          'Procedure',
          'MedicationRequest',
        ]);
      });

    expect(authSupportServiceMock.getAuthenticatedUserFromHeader).toHaveBeenCalledWith(
      'Bearer test-access-token',
    );
    expect(fhirSyncServiceMock.receiveResultsForProfile).toHaveBeenCalledWith(
      '550e8400-e29b-41d4-a716-446655440000',
      expect.objectContaining({
        status: 'SUCCESS',
        data: expect.objectContaining({
          resourceType: 'Bundle',
          type: 'collection',
          entry: expect.arrayContaining([
            expect.objectContaining({
              resource: expect.objectContaining({
                resourceType: 'Patient',
                identifier: [
                  {
                    system:
                      'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
                    value: '12-345678901-2',
                  },
                ],
              }),
            }),
          ]),
        }),
      }),
    );
  });
});
