import { SupabaseService } from '../supabase/supabase.service';
import { ProfileRepository, type ProfileRow } from './profile.repository';

describe('ProfileRepository', () => {
  const createRepository = (): ProfileRepository =>
    new ProfileRepository({} as SupabaseService);

  const buildRow = (
    patientProfile: Record<string, string>,
  ): ProfileRow =>
    ({
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
    }) as ProfileRow;

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
});
