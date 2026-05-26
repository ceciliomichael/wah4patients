import { ConfigService } from '@nestjs/config';
import { AppointmentHistoryRepository } from '../appointment-history/appointment-history.repository';
import { FhirSyncRepository } from './fhir-sync.repository';
import { FhirSyncService } from './fhir-sync.service';
import { FhirPatientResource } from './fhir-sync.types';
import { readFileSync } from 'node:fs';
import { join } from 'node:path';

function readFixture(fileName: string): Record<string, unknown> {
  const filePath = join(__dirname, '../../../resources/examples/ph-core', fileName);
  return JSON.parse(readFileSync(filePath, 'utf8')) as Record<string, unknown>;
}

describe('FhirSyncService', () => {
  const configServiceMock = {
    get: jest.fn(),
  } as Pick<ConfigService, 'get'>;

  const repositoryMock = {
    findProfileIdByIdentifiers: jest.fn(),
    findProfileIdByTransactionId: jest.fn(),
    getProfile: jest.fn(),
    listRecords: jest.fn(),
    updateProfile: jest.fn(),
    upsertPatientIdentifiers: jest.fn(),
    insertClinicalRecord: jest.fn(),
    insertMedicationResupplyRecord: jest.fn(),
    markMedicationResupplyApprovedByCorrelationId: jest.fn(),
  } as Pick<
    FhirSyncRepository,
    | 'findProfileIdByIdentifiers'
    | 'findProfileIdByTransactionId'
    | 'getProfile'
    | 'listRecords'
    | 'updateProfile'
    | 'upsertPatientIdentifiers'
    | 'insertClinicalRecord'
    | 'insertMedicationResupplyRecord'
    | 'markMedicationResupplyApprovedByCorrelationId'
  >;
  const appointmentHistoryRepositoryMock = {
    markAppointmentHistoryApprovedByTransactionId: jest.fn(),
    markAppointmentHistoryApprovedByCorrelationId: jest.fn(),
  } as Pick<
    AppointmentHistoryRepository,
    | 'markAppointmentHistoryApprovedByTransactionId'
    | 'markAppointmentHistoryApprovedByCorrelationId'
  >;

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('parses a receive-results bundle and persists each normalized resource', async () => {
    const service = new FhirSyncService(
      configServiceMock as ConfigService,
      repositoryMock as FhirSyncRepository,
      appointmentHistoryRepositoryMock as AppointmentHistoryRepository,
    );

    const patient = readFixture('Patient-patient-single-example.json') as FhirPatientResource;
    patient.identifier = [
      ...(patient.identifier ?? []),
      {
        system: 'https://philsys.gov.ph/fhir/Identifier/philsys-id',
        value: '123456789012',
      },
    ];
    patient.extension = [
      ...(patient.extension ?? []),
      {
        url: 'https://fhir-ph-core.wah.ph/ph-core/fhir/StructureDefinition/pwd-disability-type',
        valueCodeableConcept: {
          coding: [
            {
              code: 'visual',
              display: 'Visual Disability',
            },
          ],
        },
      },
    ];
    const bundle = {
      resourceType: 'Bundle',
      entry: [
        { resource: patient },
        { resource: readFixture('Immunization-immunization-single-example.json') },
        { resource: readFixture('Encounter-encounter-single-example.json') },
        { resource: readFixture('Observation-observation-bp-example.json') },
        { resource: readFixture('Condition-condition-single-example.json') },
        { resource: readFixture('Procedure-procedure-single-example.json') },
        { resource: readFixture('MedicationRequest-medicationrequest-single-example.json') },
      ],
    };

    repositoryMock.findProfileIdByIdentifiers = jest.fn().mockResolvedValue('profile-123');
    repositoryMock.findProfileIdByTransactionId = jest.fn().mockResolvedValue(null);
    repositoryMock.updateProfile = jest.fn().mockResolvedValue(undefined);
    repositoryMock.upsertPatientIdentifiers = jest.fn().mockResolvedValue(undefined);
    repositoryMock.insertClinicalRecord = jest.fn().mockResolvedValue(undefined);
    repositoryMock.insertMedicationResupplyRecord = jest.fn().mockResolvedValue(undefined);
    repositoryMock.markMedicationResupplyApprovedByCorrelationId = jest
      .fn()
      .mockResolvedValue(true);

    await expect(
      service.receiveResults({
        transactionId: 'txn-results-001',
        status: 'SUCCESS',
        data: bundle,
      }),
    ).resolves.toEqual({ message: 'Data received successfully' });

    expect(repositoryMock.findProfileIdByIdentifiers).toHaveBeenCalledWith([
      {
        system: 'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
        value: '63-584789845-5',
      },
      {
        system: 'https://philsys.gov.ph/fhir/Identifier/philsys-id',
        value: '123456789012',
      },
    ]);
    expect(repositoryMock.updateProfile).toHaveBeenCalledWith(
      'profile-123',
      expect.objectContaining({
        givenNames: ['Juan Jane', 'Dela Fuente'],
        familyName: 'Dela Cruz',
        patientProfile: expect.objectContaining({
          philSysId: '123456789012',
          religion: 'Atheism',
          occupation: 'Hospital Administrator',
          race: 'Filipino',
          educationalAttainment: 'Elementary Graduate',
          pwdDisabilityType: 'Visual Disability',
        }),
      }),
    );
    expect(repositoryMock.upsertPatientIdentifiers).toHaveBeenCalledWith('profile-123', [
      {
        system: 'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
        value: '63-584789845-5',
      },
      {
        system: 'https://philsys.gov.ph/fhir/Identifier/philsys-id',
        value: '123456789012',
      },
    ]);
    expect(repositoryMock.insertClinicalRecord).toHaveBeenCalledWith(
      'Immunization',
      'profile-123',
      expect.objectContaining({
        title: 'Influenza H5N1-1203 Vaccine',
      }),
    );
    expect(repositoryMock.insertClinicalRecord).toHaveBeenCalledWith(
      'Encounter',
      'profile-123',
      expect.objectContaining({
        title: 'ambulatory',
      }),
    );
    expect(repositoryMock.insertClinicalRecord).toHaveBeenCalledWith(
      'Observation',
      'profile-123',
      expect.objectContaining({
        title: 'Blood pressure systolic & diastolic',
      }),
    );
    expect(repositoryMock.insertClinicalRecord).toHaveBeenCalledWith(
      'Condition',
      'profile-123',
      expect.objectContaining({
        title: 'Type 2 Diabetes Mellitus',
        detailsJson: expect.arrayContaining([
          expect.objectContaining({
            label: 'Current status',
            value: 'Active',
          }),
          expect.objectContaining({
            label: 'Verification status',
            value: 'Confirmed',
          }),
          expect.objectContaining({
            label: 'Diagnosed on',
            value: expect.stringContaining('March 15, 2020'),
          }),
          expect.objectContaining({
            label: 'Notes',
            value: expect.stringContaining('diet and exercise management'),
          }),
        ]),
      }),
    );
    expect(repositoryMock.insertClinicalRecord).toHaveBeenCalledWith(
      'Procedure',
      'profile-123',
      expect.objectContaining({
        title: 'Laparoscopic appendectomy',
        detailsJson: expect.arrayContaining([
          expect.objectContaining({
            label: 'Performed on',
            value: expect.stringContaining('January 15, 2024'),
          }),
          expect.objectContaining({
            label: 'Outcome',
            value: 'Successful',
          }),
          expect.objectContaining({
            label: 'Follow-up',
            value: expect.stringContaining('wound care'),
          }),
        ]),
      }),
    );
    expect(repositoryMock.insertMedicationResupplyRecord).toHaveBeenCalledWith(
      'profile-123',
      expect.objectContaining({
        medicationName: 'Twinact 40mg/5mg tablet',
      }),
    );
  });

  it('uses transactionId to resolve gateway receive-results bundles without a patient resource', async () => {
    const service = new FhirSyncService(
      configServiceMock as ConfigService,
      repositoryMock as FhirSyncRepository,
      appointmentHistoryRepositoryMock as AppointmentHistoryRepository,
    );

    const condition = readFixture('Condition-condition-single-example.json');
    condition.meta = {
      profile: ['http://hl7.org/fhir/StructureDefinition/Condition'],
    };

    repositoryMock.findProfileIdByTransactionId = jest
      .fn()
      .mockResolvedValue('profile-transaction-123');
    repositoryMock.findProfileIdByIdentifiers = jest.fn();
    repositoryMock.updateProfile = jest.fn().mockResolvedValue(undefined);
    repositoryMock.upsertPatientIdentifiers = jest.fn().mockResolvedValue(undefined);
    repositoryMock.insertClinicalRecord = jest.fn().mockResolvedValue(undefined);
    repositoryMock.insertMedicationResupplyRecord = jest.fn().mockResolvedValue(undefined);
    repositoryMock.markMedicationResupplyApprovedByCorrelationId = jest
      .fn()
      .mockResolvedValue(true);

    await expect(
      service.receiveResults({
        transactionId: 'txn-results-transaction-001',
        status: 'SUCCESS',
        data: {
          resourceType: 'Bundle',
          type: 'collection',
          entry: [{ resource: condition }],
        },
      }),
    ).resolves.toEqual({ message: 'Data received successfully' });

    expect(repositoryMock.findProfileIdByTransactionId).toHaveBeenCalledWith(
      'txn-results-transaction-001',
    );
    expect(repositoryMock.findProfileIdByIdentifiers).not.toHaveBeenCalled();
    expect(repositoryMock.updateProfile).not.toHaveBeenCalled();
    expect(repositoryMock.upsertPatientIdentifiers).not.toHaveBeenCalled();
    expect(repositoryMock.insertClinicalRecord).toHaveBeenCalledWith(
      'Condition',
      'profile-transaction-123',
      expect.objectContaining({
        title: 'Type 2 Diabetes Mellitus',
        recordedAt: '2020-03-15T10:30:00Z',
      }),
    );
  });

  it('parses a receive-push patient payload and updates the profile', async () => {
    const service = new FhirSyncService(
      configServiceMock as ConfigService,
      repositoryMock as FhirSyncRepository,
      appointmentHistoryRepositoryMock as AppointmentHistoryRepository,
    );
    const patient = readFixture('Patient-patient-single-example.json') as FhirPatientResource;

    repositoryMock.findProfileIdByIdentifiers = jest.fn().mockResolvedValue('profile-123');
    repositoryMock.findProfileIdByTransactionId = jest.fn().mockResolvedValue(null);
    repositoryMock.updateProfile = jest.fn().mockResolvedValue(undefined);
    repositoryMock.upsertPatientIdentifiers = jest.fn().mockResolvedValue(undefined);

    await expect(
      service.receivePush({
        transactionId: 'txn-push-001',
        senderId: 'sender-001',
        resourceType: 'Patient',
        resource: patient,
      }),
    ).resolves.toEqual({ message: 'Data received successfully' });

    expect(repositoryMock.updateProfile).toHaveBeenCalledWith(
      'profile-123',
      expect.objectContaining({
        givenNames: ['Juan Jane', 'Dela Fuente'],
        familyName: 'Dela Cruz',
      }),
    );
    expect(repositoryMock.upsertPatientIdentifiers).toHaveBeenCalledWith('profile-123', [
      {
        system: 'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
        value: '63-584789845-5',
      },
    ]);
  });

  it('extracts medication request correlationId from the FHIR identifier when the top-level field is absent', async () => {
    const service = new FhirSyncService(
      configServiceMock as ConfigService,
      repositoryMock as FhirSyncRepository,
      appointmentHistoryRepositoryMock as AppointmentHistoryRepository,
    );

    repositoryMock.markMedicationResupplyApprovedByCorrelationId = jest
      .fn()
      .mockResolvedValue(true);

    await expect(
      service.receivePush({
        transactionId: 'txn-medication-push-001',
        senderId: 'sender-001',
        resourceType: 'MedicationRequest',
        resource: {
          resourceType: 'MedicationRequest',
          identifier: [
            {
              system: 'https://wah.ph/fhir/Identifier/medication-request-id',
              use: 'official',
              value: '3a6ef0f7-7fd8-4571-88fb-2b5ac8c0b1b1',
            },
          ],
        },
      }),
    ).resolves.toEqual({ message: 'Data received successfully' });

    expect(
      repositoryMock.markMedicationResupplyApprovedByCorrelationId,
    ).toHaveBeenCalledWith('3a6ef0f7-7fd8-4571-88fb-2b5ac8c0b1b1');
    expect(repositoryMock.insertMedicationResupplyRecord).not.toHaveBeenCalled();
  });

  it('rejects medication request pushes when no matching history record exists', async () => {
    const service = new FhirSyncService(
      configServiceMock as ConfigService,
      repositoryMock as FhirSyncRepository,
      appointmentHistoryRepositoryMock as AppointmentHistoryRepository,
    );

    repositoryMock.markMedicationResupplyApprovedByCorrelationId = jest
      .fn()
      .mockResolvedValue(false);

    await expect(
      service.receivePush({
        transactionId: 'txn-medication-push-404',
        senderId: 'sender-001',
        resourceType: 'MedicationRequest',
        resource: {
          resourceType: 'MedicationRequest',
          identifier: [
            {
              system: 'https://wah.ph/fhir/Identifier/medication-request-id',
              value: 'c72d1f6e-5388-4a9b-b72c-e4f6ca7fd0c4',
            },
          ],
        },
      }),
    ).rejects.toThrow('Unable to match the medication request push to a pending history record.');

    expect(
      repositoryMock.markMedicationResupplyApprovedByCorrelationId,
    ).toHaveBeenCalledWith('c72d1f6e-5388-4a9b-b72c-e4f6ca7fd0c4');
  });

  it('rejects medication request pushes without a correlationId', async () => {
    const service = new FhirSyncService(
      configServiceMock as ConfigService,
      repositoryMock as FhirSyncRepository,
      appointmentHistoryRepositoryMock as AppointmentHistoryRepository,
    );

    await expect(
      service.receivePush({
        transactionId: 'txn-medication-push-no-correlation',
        senderId: 'sender-001',
        resourceType: 'MedicationRequest',
        resource: {
          resourceType: 'MedicationRequest',
        },
      }),
    ).rejects.toThrow('Unable to match the medication request push without a correlationId.');

    expect(
      repositoryMock.markMedicationResupplyApprovedByCorrelationId,
    ).not.toHaveBeenCalled();
    expect(repositoryMock.insertMedicationResupplyRecord).not.toHaveBeenCalled();
  });

  it('prioritizes correlationId when approving appointment pushes', async () => {
    const service = new FhirSyncService(
      configServiceMock as ConfigService,
      repositoryMock as FhirSyncRepository,
      appointmentHistoryRepositoryMock as AppointmentHistoryRepository,
    );

    appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByCorrelationId = jest
      .fn()
      .mockResolvedValue(true);
    appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByTransactionId = jest
      .fn()
      .mockResolvedValue(false);

    await expect(
      service.receivePush({
        transactionId: 'txn-push-002',
        correlationId: 'corr-push-002',
        senderId: 'sender-001',
        resourceType: 'Appointment',
        resource: {
          resourceType: 'Appointment',
        },
      }),
    ).resolves.toEqual({ message: 'Data received successfully' });

    expect(
      appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByCorrelationId,
    ).toHaveBeenCalledWith('corr-push-002');
    expect(
      appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByTransactionId,
    ).not.toHaveBeenCalled();
  });

  it('extracts appointment correlationId from the FHIR identifier when the top-level field is absent', async () => {
    const service = new FhirSyncService(
      configServiceMock as ConfigService,
      repositoryMock as FhirSyncRepository,
      appointmentHistoryRepositoryMock as AppointmentHistoryRepository,
    );

    appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByCorrelationId = jest
      .fn()
      .mockResolvedValue(true);
    appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByTransactionId = jest
      .fn()
      .mockResolvedValue(false);

    await expect(
      service.receivePush({
        transactionId: 'txn-forwarded-gateway-001',
        senderId: 'sender-001',
        resourceType: 'Appointment',
        resource: {
          resourceType: 'Appointment',
          status: 'booked',
          identifier: [
            {
              system: 'https://wah.ph/fhir/Identifier/appointment-id',
              use: 'official',
              value: '7017daa4-45eb-483b-921e-71136e56770d',
            },
          ],
        },
      }),
    ).resolves.toEqual({ message: 'Data received successfully' });

    expect(
      appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByCorrelationId,
    ).toHaveBeenCalledWith('7017daa4-45eb-483b-921e-71136e56770d');
    expect(
      appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByTransactionId,
    ).not.toHaveBeenCalled();
  });

  it('rejects appointment pushes when no matching history record exists', async () => {
    const service = new FhirSyncService(
      configServiceMock as ConfigService,
      repositoryMock as FhirSyncRepository,
      appointmentHistoryRepositoryMock as AppointmentHistoryRepository,
    );

    appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByCorrelationId = jest
      .fn()
      .mockResolvedValue(false);
    appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByTransactionId = jest
      .fn()
      .mockResolvedValue(false);

    await expect(
      service.receivePush({
        transactionId: 'txn-push-404',
        correlationId: 'corr-push-404',
        senderId: 'sender-001',
        resourceType: 'Appointment',
        resource: {
          resourceType: 'Appointment',
        },
      }),
    ).rejects.toThrow('Unable to match the appointment push to a pending history record.');

    expect(
      appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByCorrelationId,
    ).toHaveBeenCalledWith('corr-push-404');
    expect(
      appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByTransactionId,
    ).not.toHaveBeenCalled();
  });

  it('rejects appointment pushes without a correlationId', async () => {
    const service = new FhirSyncService(
      configServiceMock as ConfigService,
      repositoryMock as FhirSyncRepository,
      appointmentHistoryRepositoryMock as AppointmentHistoryRepository,
    );

    await expect(
      service.receivePush({
        transactionId: 'txn-push-no-correlation',
        senderId: 'sender-001',
        resourceType: 'Appointment',
        resource: {
          resourceType: 'Appointment',
        },
      }),
    ).rejects.toThrow('Unable to match the appointment push without a correlationId.');

    expect(
      appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByCorrelationId,
    ).not.toHaveBeenCalled();
    expect(
      appointmentHistoryRepositoryMock.markAppointmentHistoryApprovedByTransactionId,
    ).not.toHaveBeenCalled();
  });

  it('maps PH Core gateway payload fields from receive-results into patient profile patch', async () => {
    const service = new FhirSyncService(
      configServiceMock as ConfigService,
      repositoryMock as FhirSyncRepository,
      appointmentHistoryRepositoryMock as AppointmentHistoryRepository,
    );

    const bundle = {
      resourceType: 'Bundle',
      type: 'collection',
      entry: [
        {
          resource: {
            resourceType: 'Patient',
            meta: {
              profile: ['https://wah-fhir-ph-core.echosphere.cfd/phcore/StructureDefinition/ph-core-patient'],
            },
            identifier: [
              {
                system: 'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
                value: '123456789016',
              },
              {
                system: 'https://philsys.gov.ph/fhir/Identifier/philsys-id',
                value: '123456789012',
              },
            ],
            name: [
              {
                family: 'Dela Cruz',
                given: ['Christianity', 'Eugenio'],
              },
            ],
            gender: 'male',
            birthDate: '2000-06-20',
            maritalStatus: {
              coding: [
                {
                  code: 'S',
                  system: 'http://terminology.hl7.org/CodeSystem/v3-MaritalStatus',
                },
              ],
            },
            telecom: [
              {
                system: 'phone',
                use: 'mobile',
                value: '09171234567',
              },
            ],
            address: [
              {
                line: ['123 Sampaguita Street'],
                city: 'Bangued',
                postalCode: '1870',
                country: 'PH',
                extension: [
                  {
                    url: 'https://fhir-ph-core.wah.ph/ph-core/fhir/StructureDefinition/region',
                    valueCoding: { display: 'Cordillera Administrative Region (CAR)' },
                  },
                  {
                    url: 'https://fhir-ph-core.wah.ph/ph-core/fhir/StructureDefinition/province',
                    valueCoding: { display: 'Abra' },
                  },
                  {
                    url: 'https://fhir-ph-core.wah.ph/ph-core/fhir/StructureDefinition/city-municipality',
                    valueCoding: { display: 'Bangued' },
                  },
                  {
                    url: 'https://fhir-ph-core.wah.ph/ph-core/fhir/StructureDefinition/barangay',
                    valueCoding: { display: 'Agtangao' },
                  },
                ],
              },
            ],
            extension: [
              {
                url: 'https://fhir-ph-core.wah.ph/ph-core/fhir/StructureDefinition/religion',
                valueCodeableConcept: {
                  coding: [{ display: 'Roman Catholic' }],
                },
              },
              {
                url: 'https://fhir-ph-core.wah.ph/ph-core/fhir/StructureDefinition/race',
                valueCodeableConcept: {
                  coding: [{ display: 'Bisaya/Binisaya' }],
                },
              },
              {
                url: 'https://fhir-ph-core.wah.ph/ph-core/fhir/StructureDefinition/educational-attainment',
                valueCodeableConcept: {
                  coding: [{ display: 'Bachelor\'s Degree or Equivalent' }],
                },
              },
              {
                url: 'https://fhir-ph-core.wah.ph/ph-core/fhir/StructureDefinition/occupation',
                valueCodeableConcept: {
                  coding: [{ display: 'Congressman' }],
                },
              },
              {
                url: 'https://fhir-ph-core.wah.ph/ph-core/fhir/StructureDefinition/indigenous-people',
                valueBoolean: true,
              },
              {
                url: 'https://fhir-ph-core.wah.ph/ph-core/fhir/StructureDefinition/indigenous-group',
                valueCodeableConcept: {
                  coding: [{ display: 'Aetas' }],
                },
              },
              {
                url: 'https://fhir-ph-core.wah.ph/ph-core/fhir/StructureDefinition/pwd-disability-type',
                valueCodeableConcept: {
                  coding: [{ display: 'Visual Disability' }],
                },
              },
            ],
          },
        },
      ],
    };

    repositoryMock.findProfileIdByIdentifiers = jest.fn().mockResolvedValue('profile-abc');
    repositoryMock.findProfileIdByTransactionId = jest.fn().mockResolvedValue(null);
    repositoryMock.updateProfile = jest.fn().mockResolvedValue(undefined);
    repositoryMock.upsertPatientIdentifiers = jest.fn().mockResolvedValue(undefined);
    repositoryMock.insertClinicalRecord = jest.fn().mockResolvedValue(undefined);
    repositoryMock.insertMedicationResupplyRecord = jest.fn().mockResolvedValue(undefined);
    repositoryMock.markMedicationResupplyApprovedByCorrelationId = jest
      .fn()
      .mockResolvedValue(true);

    await expect(
      service.receiveResults({
        transactionId: 'txn-log-shape-001',
        status: 'SUCCESS',
        data: bundle,
      }),
    ).resolves.toEqual({ message: 'Data received successfully' });

    expect(repositoryMock.updateProfile).toHaveBeenCalledWith(
      'profile-abc',
      expect.objectContaining({
        patientProfile: expect.objectContaining({
          philHealthId: '123456789016',
          philSysId: '123456789012',
          province: 'Abra',
          region: 'Cordillera Administrative Region (CAR)',
          barangay: 'Agtangao',
          religion: 'Roman Catholic',
          occupation: 'Congressman',
          race: 'Bisaya/Binisaya',
          educationalAttainment: 'Bachelor\'s Degree or Equivalent',
          indigenousPeople: true,
          indigenousGroup: 'Aetas',
          maritalStatus: 'S',
          pwdDisabilityType: 'Visual Disability',
        }),
      }),
    );
  });
});
