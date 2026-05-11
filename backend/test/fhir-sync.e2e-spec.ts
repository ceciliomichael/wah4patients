import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { FhirSyncService } from '../src/fhir-sync/fhir-sync.service';

describe('FhirSync routes (e2e)', () => {
  const gatewayAuthKey = 'gateway-auth-test-key-123456';
  const patientIdentifier = {
    system: 'http://philhealth.gov.ph',
    value: '12-345678901-2',
  };
  const fhirSyncServiceMock = {
    processQuery: jest.fn().mockResolvedValue({ message: 'Processing' }),
    receiveResults: jest.fn().mockResolvedValue({ message: 'Data received successfully' }),
    receivePush: jest.fn().mockResolvedValue({ message: 'Data received successfully' }),
  };

  let app: INestApplication<App>;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(FhirSyncService)
      .useValue(fhirSyncServiceMock)
      .compile();

    app = moduleFixture.createNestApplication();
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

  it('/fhir/process-query (POST)', async () => {
    await request(app.getHttpServer())
      .post('/api/fhir/process-query')
      .set('x-gateway-auth', gatewayAuthKey)
      .send({
        transactionId: 'txn-001',
        requesterId: 'requester-123',
        identifiers: [
          {
            system: 'http://philhealth.gov.ph',
            value: '12-345678901-2',
          },
        ],
        resourceType: 'Patient',
        gatewayReturnUrl: 'https://gateway.example.com/api/v1/fhir/receive/Patient',
        reason: 'Referral consultation',
        notes: 'Patient requested record sync',
      })
      .expect(200)
      .expect({ message: 'Processing' });

    expect(fhirSyncServiceMock.processQuery).toHaveBeenCalledWith({
      transactionId: 'txn-001',
      requesterId: 'requester-123',
      identifiers: [
        {
          system: 'http://philhealth.gov.ph',
          value: '12-345678901-2',
        },
      ],
      resourceType: 'Patient',
      gatewayReturnUrl: 'https://gateway.example.com/api/v1/fhir/receive/Patient',
      reason: 'Referral consultation',
      notes: 'Patient requested record sync',
    });
  });

  it('/fhir/receive-results (POST)', async () => {
    await request(app.getHttpServer())
      .post('/api/fhir/receive-results')
      .set('x-gateway-auth', gatewayAuthKey)
      .send({
        transactionId: 'txn-002',
        status: 'SUCCESS',
        data: {
          resourceType: 'Bundle',
          entry: [
            {
              resource: {
                resourceType: 'Patient',
                id: 'patient-123',
                identifier: [patientIdentifier],
                name: [
                  {
                    given: ['Jane'],
                    family: 'Doe',
                  },
                ],
                birthDate: '1990-01-01',
                gender: 'female',
              },
            },
            {
              resource: {
                resourceType: 'Immunization',
                id: 'imm-001',
                status: 'completed',
                occurrenceDateTime: '2026-05-11T09:00:00.000Z',
                vaccineCode: {
                  text: 'COVID-19 vaccine',
                },
                site: {
                  text: 'Left arm',
                },
                route: {
                  text: 'IM',
                },
                note: [
                  {
                    text: 'No adverse reaction',
                  },
                ],
              },
            },
          ],
        },
      })
      .expect(200)
      .expect({ message: 'Data received successfully' });

    expect(fhirSyncServiceMock.receiveResults).toHaveBeenCalledWith({
      transactionId: 'txn-002',
      status: 'SUCCESS',
      data: {
        resourceType: 'Bundle',
        entry: [
          {
            resource: {
              resourceType: 'Patient',
              id: 'patient-123',
              identifier: [
                {
                  system: 'http://philhealth.gov.ph',
                  value: '12-345678901-2',
                },
              ],
              name: [
                {
                  given: ['Jane'],
                  family: 'Doe',
                },
              ],
              birthDate: '1990-01-01',
              gender: 'female',
            },
          },
          {
            resource: {
              resourceType: 'Immunization',
              id: 'imm-001',
              status: 'completed',
              occurrenceDateTime: '2026-05-11T09:00:00.000Z',
              vaccineCode: {
                text: 'COVID-19 vaccine',
              },
              site: {
                text: 'Left arm',
              },
              route: {
                text: 'IM',
              },
              note: [
                {
                  text: 'No adverse reaction',
                },
              ],
            },
          },
        ],
      },
    });
  });

  it('/fhir/receive-push (POST)', async () => {
    await request(app.getHttpServer())
      .post('/api/fhir/receive-push')
      .set('x-gateway-auth', gatewayAuthKey)
      .send({
        transactionId: 'txn-003',
        senderId: 'sender-123',
        resourceType: 'Observation',
        resource: {
          resourceType: 'Observation',
          id: 'obs-001',
          subject: {
            identifier: patientIdentifier,
          },
          status: 'final',
          effectiveDateTime: '2026-05-11T09:00:00.000Z',
          code: {
            text: 'Blood pressure',
          },
          valueString: '120/80',
          performer: [
            {
              display: 'Clinic Nurse',
            },
          ],
        },
      })
      .expect(200)
      .expect({ message: 'Data received successfully' });

    expect(fhirSyncServiceMock.receivePush).toHaveBeenCalledWith({
      transactionId: 'txn-003',
      senderId: 'sender-123',
      resourceType: 'Observation',
      resource: {
        resourceType: 'Observation',
        id: 'obs-001',
        subject: {
          identifier: {
            system: 'http://philhealth.gov.ph',
            value: '12-345678901-2',
          },
        },
        status: 'final',
        effectiveDateTime: '2026-05-11T09:00:00.000Z',
        code: {
          text: 'Blood pressure',
        },
        valueString: '120/80',
        performer: [
          {
            display: 'Clinic Nurse',
          },
        ],
      },
    });
  });
});
