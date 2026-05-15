import { Json } from '../supabase/database.types';
import { SupabaseService } from '../supabase/supabase.service';
import { ProfileRepository, type ProfileRow } from './profile.repository';

describe('ProfileRepository', () => {
  const createRepository = (): ProfileRepository =>
    new ProfileRepository({} as SupabaseService);

  const buildRow = (
    patientProfile: Record<string, string>,
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
      ...patientProfile,
    },
    created_at: '2025-01-01T00:00:00.000Z',
    updated_at: '2025-01-01T00:00:00.000Z',
  });

  it('marks the profile complete when PhilHealth ID is present', () => {
    const repository = createRepository();
    const result = repository.toResponse(
      buildRow({ philHealthId: '12-345678901-2' }),
    );

    expect(result.isComplete).toBe(true);
    expect(result.missingFields).toHaveLength(0);
  });

  it('marks the profile complete when PhilSys ID is present', () => {
    const repository = createRepository();
    const result = repository.toResponse(
      buildRow({ philSysId: '1234-1234567-1' }),
    );

    expect(result.isComplete).toBe(true);
    expect(result.missingFields).toHaveLength(0);
  });

  it('requires one identifier when both are missing', () => {
    const repository = createRepository();
    const result = repository.toResponse(buildRow({}));

    expect(result.isComplete).toBe(false);
    expect(result.missingFields).toContain('PhilHealth ID or PhilSys ID');
  });

  it('upserts patient identifiers from the saved patient profile', async () => {
    const upsertMock: jest.Mock<unknown, [unknown, unknown?]> = jest
      .fn()
      .mockReturnValue({ error: null });
    const fromMock: jest.Mock<unknown, [string]> = jest
      .fn()
      .mockReturnValue({ upsert: upsertMock });
    const repository = new ProfileRepository({
      adminClient: {
        from: fromMock,
      },
    } as unknown as SupabaseService);

    await repository.upsertPatientIdentifiers('profile-123', {
      philHealthId: '12-345678901-2',
      philSysId: '1234-1234567-1',
    } as Json);

    expect(fromMock).toHaveBeenCalledWith('patient_identifiers');
    expect(upsertMock).toHaveBeenCalledWith(
      [
        {
          profile_id: 'profile-123',
          identifier_system: 'http://philhealth.gov.ph/fhir/Identifier/philhealth-id',
          identifier_value: '12-345678901-2',
          verified_at: expect.any(String),
        },
        {
          profile_id: 'profile-123',
          identifier_system: 'http://philsys.gov.ph/fhir/Identifier/philsys-id',
          identifier_value: '1234-1234567-1',
          verified_at: expect.any(String),
        },
      ],
      {
        onConflict: 'profile_id,identifier_system,identifier_value',
      },
    );
  });
});
