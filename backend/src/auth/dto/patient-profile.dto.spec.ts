import { validateSync } from 'class-validator';

import { UpdateProfileDto } from './update-profile.dto';

function buildProfileDto(
  overrides: Partial<UpdateProfileDto> = {},
): UpdateProfileDto {
  return Object.assign(
    new UpdateProfileDto(),
    {
      firstName: 'Juan',
      lastName: 'Dela Cruz',
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
      maritalStatus: '',
      nationality: '',
      religion: '',
      occupation: '',
      genderIdentity: '',
      emergencyContactName: '',
      emergencyContactPhone: '',
    },
    overrides,
  );
}

describe('UpdateProfileDto', () => {
  it('accepts a profile with only PhilHealth ID', () => {
    const errors = validateSync(
      buildProfileDto({
        philHealthId: '12-345678901-2',
      }),
    );

    expect(errors).toHaveLength(0);
  });

  it('accepts a profile with only PhilSys ID', () => {
    const errors = validateSync(
      buildProfileDto({
        philSysId: '1234-1234567-1',
      }),
    );

    expect(errors).toHaveLength(0);
  });

  it('rejects a profile when both identifiers are missing', () => {
    const errors = validateSync(buildProfileDto());

    expect(errors.some((error) => error.property === 'philHealthId')).toBe(true);
    expect(errors.some((error) => error.property === 'philSysId')).toBe(true);
  });
});
