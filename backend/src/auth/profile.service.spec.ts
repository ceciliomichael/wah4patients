import { BadRequestException } from '@nestjs/common';
import { ProfileRepository, type ProfileRow } from './profile.repository';
import { ProfileService } from './profile.service';

type ProfileRepositoryMock = {
  findByUserId: jest.Mock<Promise<ProfileRow | null>, [string]>;
  upsert: jest.Mock<Promise<ProfileRow>, [Parameters<ProfileRepository['upsert']>[0]]>;
  upsertPatientIdentifiers: jest.Mock<
    Promise<void>,
    [string, Parameters<ProfileRepository['upsertPatientIdentifiers']>[1]]
  >;
  toResponse: jest.Mock<ReturnType<ProfileRepository['toResponse']>, [ProfileRow]>;
};

describe('ProfileService', () => {
  const createRepositoryMock = (): ProfileRepositoryMock => ({
    findByUserId: jest.fn<Promise<ProfileRow | null>, [string]>(),
    upsert: jest.fn<Promise<ProfileRow>, [Parameters<ProfileRepository['upsert']>[0]]>(),
    upsertPatientIdentifiers: jest.fn<
      Promise<void>,
      [string, Parameters<ProfileRepository['upsertPatientIdentifiers']>[1]]
    >(),
    toResponse: jest.fn<ReturnType<ProfileRepository['toResponse']>, [ProfileRow]>(),
  });

  const buildRow = (
    overrides: Partial<ProfileRow> = {},
    patientProfile: Record<string, unknown> = {},
  ): ProfileRow => ({
    id: '550e8400-e29b-41d4-a716-446655440000',
    email: 'juan@example.com',
    given_names: ['Juan'],
    family_name: 'Dela Cruz',
    patient_profile: {
      birthDate: '1990-05-15',
      gender: 'male',
      phoneNumber: '09171234567',
      communicationLanguage: 'Filipino',
      philHealthId: '12-345678901-2',
      philSysId: '',
      addressLine1: '123 Main Street',
      addressLine2: '',
      city: 'Quezon City',
      province: 'Metro Manila',
      postalCode: '1100',
      country: 'Philippines',
      maritalStatus: '',
      nationality: '',
      religion: '',
      occupation: '',
      genderIdentity: '',
      emergencyContactName: '',
      emergencyContactPhone: '',
      ...patientProfile,
    },
    created_at: '2025-01-01T00:00:00.000Z',
    updated_at: '2025-01-01T00:00:00.000Z',
    ...overrides,
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('merges partial profile updates without requiring missing fields', async () => {
    const profileRepository = createRepositoryMock();
    const service = new ProfileService(profileRepository as unknown as ProfileRepository);
    const existingRow = buildRow({}, {
      birthDate: '1990-05-15',
      gender: 'male',
      phoneNumber: '09171234567',
      communicationLanguage: 'Filipino',
      philHealthId: '',
      philSysId: '',
      addressLine1: '123 Main Street',
      addressLine2: '',
      city: 'Quezon City',
      province: 'Metro Manila',
      postalCode: '1100',
      country: 'Philippines',
      maritalStatus: 'Single',
      nationality: 'Filipino',
      religion: 'Catholic',
      occupation: 'Teacher',
      genderIdentity: 'Male',
      emergencyContactName: 'Maria Dela Cruz',
      emergencyContactPhone: '09179876543',
    });

    profileRepository.findByUserId.mockResolvedValue(existingRow);
    profileRepository.upsert.mockResolvedValue(existingRow);
    profileRepository.upsertPatientIdentifiers.mockResolvedValue(undefined);
    profileRepository.toResponse.mockReturnValue({
      givenNames: ['Maria'],
      familyName: 'Dela Cruz',
      displayName: 'Maria Dela Cruz',
      birthDate: '1990-05-15',
      gender: 'male',
      phoneNumber: '09171234567',
      communicationLanguage: 'Filipino',
      philHealthId: '12-345678901-2',
      philSysId: '',
      addressLine1: '123 Main Street',
      addressLine2: '',
      city: 'Quezon City',
      province: 'Metro Manila',
      postalCode: '1100',
      country: 'Philippines',
      maritalStatus: 'Single',
      nationality: 'Filipino',
      religion: 'Catholic',
      occupation: 'Teacher',
      genderIdentity: 'Male',
      emergencyContactName: 'Maria Dela Cruz',
      emergencyContactPhone: '09179876543',
      isSyncLocked: false,
      isComplete: true,
      missingFields: [],
    });

    await service.saveProfileFromDto('user-1', 'juan@example.com', {
      firstName: 'Maria',
      philHealthId: '12-345678901-2',
    });

    expect(profileRepository.upsert).toHaveBeenCalledWith({
      id: 'user-1',
      email: 'juan@example.com',
      givenNames: ['Maria'],
      familyName: 'Dela Cruz',
      patientProfile: expect.objectContaining({
        birthDate: '1990-05-15',
        gender: 'male',
        philHealthId: '12-345678901-2',
        philSysId: '',
        addressLine1: '123 Main Street',
        city: 'Quezon City',
        province: 'Metro Manila',
        postalCode: '1100',
        country: 'Philippines',
      }),
    });
    expect(profileRepository.upsertPatientIdentifiers).toHaveBeenCalledWith(
      'user-1',
      expect.objectContaining({
        philHealthId: '12-345678901-2',
      }),
    );
  });

  it('stores the first and middle given names from profile updates', async () => {
    const profileRepository = createRepositoryMock();
    const service = new ProfileService(profileRepository as unknown as ProfileRepository);
    const existingRow = buildRow();
    const savedRow = buildRow(
      {
        given_names: ['Michael Christian', 'Aparicio'],
        family_name: 'Cecilio',
      },
      {
        birthDate: '1990-05-15',
        gender: 'male',
        phoneNumber: '09171234567',
        communicationLanguage: 'Filipino',
        philHealthId: '12-345678901-2',
        philSysId: '',
        addressLine1: '123 Main Street',
        addressLine2: '',
        city: 'Quezon City',
        province: 'Metro Manila',
        postalCode: '1100',
        country: 'Philippines',
        maritalStatus: '',
        nationality: '',
        religion: '',
        occupation: '',
        genderIdentity: '',
        emergencyContactName: '',
        emergencyContactPhone: '',
      },
    );

    profileRepository.findByUserId.mockResolvedValue(existingRow);
    profileRepository.upsert.mockResolvedValue(savedRow);
    profileRepository.upsertPatientIdentifiers.mockResolvedValue(undefined);
    profileRepository.toResponse.mockReturnValue({
      givenNames: ['Michael Christian', 'Aparicio'],
      familyName: 'Cecilio',
      displayName: 'Michael Christian Aparicio Cecilio',
      birthDate: '1990-05-15',
      gender: 'male',
      phoneNumber: '09171234567',
      communicationLanguage: 'Filipino',
      philHealthId: '12-345678901-2',
      philSysId: '',
      addressLine1: '123 Main Street',
      addressLine2: '',
      city: 'Quezon City',
      province: 'Metro Manila',
      postalCode: '1100',
      country: 'Philippines',
      maritalStatus: '',
      nationality: '',
      religion: '',
      occupation: '',
      genderIdentity: '',
      emergencyContactName: '',
      emergencyContactPhone: '',
      isSyncLocked: false,
      isComplete: true,
      missingFields: [],
    });

    await service.saveProfileFromDto('user-1', 'juan@example.com', {
      firstName: 'Michael Christian',
      middleName: 'Aparicio',
      lastName: 'Cecilio',
    });

    expect(profileRepository.upsert).toHaveBeenCalledWith({
      id: 'user-1',
      email: 'juan@example.com',
      givenNames: ['Michael Christian', 'Aparicio'],
      familyName: 'Cecilio',
      patientProfile: expect.any(Object),
    });
  });

  it('blocks manual updates when the profile is sync locked', async () => {
    const profileRepository = createRepositoryMock();
    const service = new ProfileService(profileRepository as unknown as ProfileRepository);
    const lockedRow = buildRow({}, { syncLocked: true });

    profileRepository.findByUserId.mockResolvedValue(lockedRow);

    await expect(
      service.saveProfileFromDto('user-1', 'juan@example.com', {
        firstName: 'Maria',
      }),
    ).rejects.toBeInstanceOf(BadRequestException);

    expect(profileRepository.upsert).not.toHaveBeenCalled();
    expect(profileRepository.upsertPatientIdentifiers).not.toHaveBeenCalled();
  });
});
