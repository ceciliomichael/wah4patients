import { ConfigService } from '@nestjs/config';
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
    getProfile: jest.fn(),
    listRecords: jest.fn(),
    updateProfile: jest.fn(),
    upsertPatientIdentifiers: jest.fn(),
    insertClinicalRecord: jest.fn(),
    insertMedicationResupplyRecord: jest.fn(),
  } as Pick<
    FhirSyncRepository,
    | 'findProfileIdByIdentifiers'
    | 'getProfile'
    | 'listRecords'
    | 'updateProfile'
    | 'upsertPatientIdentifiers'
    | 'insertClinicalRecord'
    | 'insertMedicationResupplyRecord'
  >;

  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('parses a receive-results bundle and persists each normalized resource', async () => {
    const service = new FhirSyncService(configServiceMock as ConfigService, repositoryMock as FhirSyncRepository);

    const patient = readFixture('Patient-patient-single-example.json') as FhirPatientResource;
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
    repositoryMock.updateProfile = jest.fn().mockResolvedValue(undefined);
    repositoryMock.upsertPatientIdentifiers = jest.fn().mockResolvedValue(undefined);
    repositoryMock.insertClinicalRecord = jest.fn().mockResolvedValue(undefined);
    repositoryMock.insertMedicationResupplyRecord = jest.fn().mockResolvedValue(undefined);

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
    ]);
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
      }),
    );
    expect(repositoryMock.insertClinicalRecord).toHaveBeenCalledWith(
      'Procedure',
      'profile-123',
      expect.objectContaining({
        title: 'Laparoscopic appendectomy',
      }),
    );
    expect(repositoryMock.insertMedicationResupplyRecord).toHaveBeenCalledWith(
      'profile-123',
      expect.objectContaining({
        medicationName: 'Twinact 40mg/5mg tablet',
      }),
    );
  });

  it('parses a receive-push patient payload and updates the profile', async () => {
    const service = new FhirSyncService(configServiceMock as ConfigService, repositoryMock as FhirSyncRepository);
    const patient = readFixture('Patient-patient-single-example.json') as FhirPatientResource;

    repositoryMock.findProfileIdByIdentifiers = jest.fn().mockResolvedValue('profile-123');
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
});
