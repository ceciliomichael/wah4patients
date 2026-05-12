import { BadRequestException } from '@nestjs/common';
import { ProfileRepository, type ProfileRow } from './profile.repository';
import { ProfileService } from './profile.service';

describe('ProfileService', () => {
  const createRepositoryMock = () => {
    return {
      findByUserId: jest.fn(),
      upsert: jest.fn(),
      toResponse: jest.fn(),
    } as unknown as jest.Mocked<ProfileRepository>;
  };

  const buildRow = (
    overrides: Partial<ProfileRow> = {},
    patientProfile: Record<string, unknown> = {},
  ): ProfileRow => {
    return {
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
    } as ProfileRow;
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('merges partial profile updates without requiring missing fields', async () => {
    const profileRepository = createRepositoryMock();
    const service = new ProfileService(profileRepository);
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
  });

  it('blocks manual updates when the profile is sync locked', async () => {
    const profileRepository = createRepositoryMock();
    const service = new ProfileService(profileRepository);
    const lockedRow = buildRow(
      {},
      {
        syncLocked: true,
      },
    );

    profileRepository.findByUserId.mockResolvedValue(lockedRow);

    await expect(
      service.saveProfileFromDto('user-1', 'juan@example.com', {
        firstName: 'Maria',
      }),
    ).rejects.toBeInstanceOf(BadRequestException);

    expect(profileRepository.upsert).not.toHaveBeenCalled();
  });
});
