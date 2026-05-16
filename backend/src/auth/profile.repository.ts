import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { Database } from '../supabase/database.types';
import { Json } from '../supabase/database.types';
import { SupabaseService } from '../supabase/supabase.service';
import { PatientProfileResponse } from './auth.types';

export interface ProfileRow {
  id: string;
  email: string;
  given_names: string[];
  family_name: string;
  patient_profile: Json;
  created_at: string;
  updated_at: string;
}

type PatientProfileRecord = Record<string, string>;
type PatientIdentifierInsert =
  Database['public']['Tables']['patient_identifiers']['Insert'];
const SYNC_LOCKED_PROFILE_FLAG = 'syncLocked';
const PHILHEALTH_IDENTIFIER_SYSTEM =
  'http://philhealth.gov.ph/fhir/Identifier/philhealth-id';
const PHILSYS_IDENTIFIER_SYSTEM =
  'http://philsys.gov.ph/fhir/Identifier/philsys-id';

export interface ProfileUpsertInput {
  id: string;
  email: string;
  givenNames: string[];
  familyName: string;
  patientProfile: Json;
}

@Injectable()
export class ProfileRepository {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findByUserId(userId: string): Promise<ProfileRow | null> {
    const { data, error } = await this.supabaseService.adminClient
      .from('profiles')
      .select(
        'id, email, given_names, family_name, patient_profile, created_at, updated_at',
      )
      .eq('id', userId)
      .maybeSingle();

    if (error !== null) {
      throw new InternalServerErrorException('Unable to read profile record');
    }

    return (data as ProfileRow | null) ?? null;
  }

  async upsert(input: ProfileUpsertInput): Promise<ProfileRow> {
    const payload = {
      id: input.id,
      email: input.email,
      given_names: input.givenNames,
      family_name: input.familyName,
      patient_profile: input.patientProfile,
    };

    const { data, error } = await this.supabaseService.adminClient
      .from('profiles')
      .upsert(payload, { onConflict: 'id' })
      .select(
        'id, email, given_names, family_name, patient_profile, created_at, updated_at',
      )
      .single();

    if (error !== null || data === null) {
      throw new InternalServerErrorException('Unable to save profile record');
    }

    return data as unknown as ProfileRow;
  }

  async upsertPatientIdentifiers(profileId: string, patientProfile: Json): Promise<void> {
    const payload = this.buildPatientIdentifierPayload(profileId, patientProfile);
    if (payload.length === 0) {
      return;
    }

    const { error } = await this.supabaseService.adminClient
      .from('patient_identifiers')
      .upsert(payload, {
        onConflict: 'profile_id,identifier_system,identifier_value',
      });

    if (error !== null) {
      throw new InternalServerErrorException('Unable to save patient identifiers');
    }
  }

  toResponse(row: ProfileRow): PatientProfileResponse {
    const profile = normalizePatientProfile(row.patient_profile);
    const missingFields = getMissingProfileFields(
      row.given_names,
      row.family_name,
      profile,
    );

    return {
      givenNames: row.given_names,
      familyName: row.family_name,
      displayName: this.buildDisplayName(row.given_names, row.family_name),
      birthDate: profile.birthDate,
      gender: profile.gender,
      phoneNumber: profile.phoneNumber,
      communicationLanguage: profile.communicationLanguage,
      philHealthId: profile.philHealthId,
      philSysId: profile.philSysId,
      addressLine1: profile.addressLine1,
      addressLine2: profile.addressLine2,
      city: profile.city,
      province: profile.province,
      region: profile.region,
      barangay: profile.barangay,
      postalCode: profile.postalCode,
      country: profile.country,
      maritalStatus: profile.maritalStatus,
      nationality: profile.nationality,
      religion: profile.religion,
      occupation: profile.occupation,
      genderIdentity: profile.genderIdentity,
      indigenousPeople: profile.indigenousPeople === 'true',
      indigenousGroup: profile.indigenousGroup,
      race: profile.race,
      educationalAttainment: profile.educationalAttainment,
      sexAtBirth: profile.sexAtBirth,
      pwdIdNumber: profile.pwdIdNumber,
      pwdDisabilityType: profile.pwdDisabilityType,
      pwdIdExpirationDate: profile.pwdIdExpirationDate,
      pwdIssuingLgu: profile.pwdIssuingLgu,
      emergencyContactName: profile.emergencyContactName,
      emergencyContactPhone: profile.emergencyContactPhone,
      isSyncLocked: isPatientProfileSyncLocked(row.patient_profile),
      isComplete: missingFields.length === 0,
      missingFields,
    };
  }

  private buildDisplayName(givenNames: string[], familyName: string): string {
    const nameParts = givenNames
      .map((part) => part.trim())
      .filter((part) => part.length > 0);
    const trimmedFamilyName = familyName.trim();

    if (nameParts.length === 0 && trimmedFamilyName.length === 0) {
      return '';
    }

    const displayNameParts = [...nameParts];
    if (trimmedFamilyName.length > 0) {
      displayNameParts.push(trimmedFamilyName);
    }

    return displayNameParts.join(' ');
  }

  private buildPatientIdentifierPayload(
    profileId: string,
    patientProfile: Json,
  ): PatientIdentifierInsert[] {
    if (patientProfile === null || typeof patientProfile !== 'object' || Array.isArray(patientProfile)) {
      return [];
    }

    const record = patientProfile as Record<string, unknown>;
    const identifiers: PatientIdentifierInsert[] = [];

    const philHealthId = this.normalizeProfileIdentifier(record['philHealthId']);
    if (philHealthId !== null) {
      identifiers.push({
        profile_id: profileId,
        identifier_system: PHILHEALTH_IDENTIFIER_SYSTEM,
        identifier_value: philHealthId,
        verified_at: new Date().toISOString(),
      });
    }

    const philSysId = this.normalizeProfileIdentifier(record['philSysId']);
    if (philSysId !== null) {
      identifiers.push({
        profile_id: profileId,
        identifier_system: PHILSYS_IDENTIFIER_SYSTEM,
        identifier_value: philSysId,
        verified_at: new Date().toISOString(),
      });
    }

    return identifiers;
  }

  private normalizeProfileIdentifier(value: unknown): string | null {
    if (typeof value !== 'string') {
      return null;
    }

    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : null;
  }
}

export function isPatientProfileSyncLocked(value: unknown): boolean {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    return false;
  }

  const record = value as Record<string, unknown>;
  return record[SYNC_LOCKED_PROFILE_FLAG] == true;
}

const EMPTY_PROFILE: PatientProfileRecord = {
  birthDate: '',
  gender: '',
  phoneNumber: '',
  communicationLanguage: '',
  philHealthId: '',
  philSysId: '',
  addressLine1: '',
  addressLine2: '',
  city: '',
  province: '',
  region: '',
  barangay: '',
  postalCode: '',
  country: '',
  maritalStatus: '',
  nationality: '',
  religion: '',
  occupation: '',
  genderIdentity: '',
  indigenousPeople: '',
  indigenousGroup: '',
  race: '',
  educationalAttainment: '',
  sexAtBirth: '',
  pwdIdNumber: '',
  pwdDisabilityType: '',
  pwdIdExpirationDate: '',
  pwdIssuingLgu: '',
  emergencyContactName: '',
  emergencyContactPhone: '',
};

function normalizePatientProfile(value: unknown): PatientProfileRecord {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    return EMPTY_PROFILE;
  }

  const record = value as Record<string, unknown>;
  return {
    birthDate: normalizeString(record.birthDate),
    gender: normalizeString(record.gender),
    phoneNumber: normalizeString(record.phoneNumber),
    communicationLanguage: normalizeString(record.communicationLanguage),
    philHealthId: normalizeString(record.philHealthId),
    philSysId: normalizeString(record.philSysId),
    addressLine1: normalizeString(record.addressLine1),
    addressLine2: normalizeString(record.addressLine2),
    city: normalizeString(record.city),
    province: normalizeString(record.province),
    region: normalizeString(record.region),
    barangay: normalizeString(record.barangay),
    postalCode: normalizeString(record.postalCode),
    country: normalizeString(record.country),
    maritalStatus: normalizeString(record.maritalStatus),
    nationality: normalizeString(record.nationality),
    religion: normalizeString(record.religion),
    occupation: normalizeString(record.occupation),
    genderIdentity: normalizeString(record.genderIdentity),
    indigenousPeople: record.indigenousPeople === true ? 'true' : '',
    indigenousGroup: normalizeString(record.indigenousGroup),
    race: normalizeString(record.race),
    educationalAttainment: normalizeString(record.educationalAttainment),
    sexAtBirth: normalizeString(record.sexAtBirth),
    pwdIdNumber: normalizeString(record.pwdIdNumber),
    pwdDisabilityType: normalizeString(record.pwdDisabilityType),
    pwdIdExpirationDate: normalizeString(record.pwdIdExpirationDate),
    pwdIssuingLgu: normalizeString(record.pwdIssuingLgu),
    emergencyContactName: normalizeString(record.emergencyContactName),
    emergencyContactPhone: normalizeString(record.emergencyContactPhone),
  };
}

function getMissingProfileFields(
  givenNames: string[],
  familyName: string,
  profile: PatientProfileRecord,
): string[] {
  const missing: string[] = [];
  if (!givenNames.some((name) => name.trim().length > 0)) {
    missing.push('givenNames');
  }
  if (familyName.trim().length === 0) {
    missing.push('familyName');
  }
  if (profile.birthDate.trim().length === 0) missing.push('birthDate');
  if (profile.gender.trim().length === 0) missing.push('gender');
  if (profile.phoneNumber.trim().length === 0) missing.push('phoneNumber');
  if (profile.communicationLanguage.trim().length === 0) {
    missing.push('communicationLanguage');
  }
  const hasIdentifier =
    profile.philHealthId.trim().length > 0 || profile.philSysId.trim().length > 0;
  if (!hasIdentifier) missing.push('PhilHealth ID or PhilSys ID');
  if (profile.addressLine1.trim().length === 0) missing.push('addressLine1');
  if (profile.city.trim().length === 0) missing.push('city');
  if (profile.province.trim().length === 0) missing.push('province');
  if (profile.postalCode.trim().length === 0) missing.push('postalCode');
  if (profile.country.trim().length === 0) missing.push('country');

  return missing;
}

function normalizeString(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}
