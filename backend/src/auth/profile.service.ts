import { BadRequestException, Injectable } from '@nestjs/common';
import { CompleteRegistrationDto } from './dto/complete-registration.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import {
  PatientProfileResponse,
  CompleteRegistrationResponse,
} from './auth.types';
import {
  ProfileRepository,
  isPatientProfileSyncLocked,
  type ProfileRow,
} from './profile.repository';

interface ProfileDraftInput {
  firstName?: string;
  secondName?: string;
  middleName?: string;
  lastName?: string;
  birthDate?: string;
  gender?: string;
  phoneNumber?: string;
  communicationLanguage?: string;
  philHealthId?: string;
  philSysId?: string;
  addressLine1?: string;
  addressLine2?: string;
  city?: string;
  province?: string;
  postalCode?: string;
  country?: string;
  maritalStatus?: string;
  nationality?: string;
  religion?: string;
  occupation?: string;
  genderIdentity?: string;
  emergencyContactName?: string;
  emergencyContactPhone?: string;
}

@Injectable()
export class ProfileService {
  constructor(private readonly profileRepository: ProfileRepository) {}

  async getProfileResponse(
    userId: string,
    email: string,
  ): Promise<PatientProfileResponse> {
    const row = await this.ensureProfileRow(userId, email);
    return this.profileRepository.toResponse(row);
  }

  async saveProfileFromDto(
    userId: string,
    email: string,
    dto: ProfileDraftInput,
  ): Promise<PatientProfileResponse> {
    const existingRow = await this.profileRepository.findByUserId(userId);
    if (
      existingRow !== null &&
      isPatientProfileSyncLocked(existingRow.patient_profile)
    ) {
      throw new BadRequestException(
        'Your profile is synced and can no longer be edited manually.',
      );
    }

    const mergedProfile = this.mergeProfile(existingRow, dto);
    const row = await this.profileRepository.upsert({
      id: userId,
      email,
      givenNames: mergedProfile.givenNames,
      familyName: mergedProfile.familyName,
      patientProfile: mergedProfile.patientProfile,
    });

    return this.profileRepository.toResponse(row);
  }

  async saveRegistrationProfile(
    userId: string,
    email: string,
    dto: CompleteRegistrationDto,
  ): Promise<CompleteRegistrationResponse['profile']> {
    return this.saveProfileFromDto(userId, email, dto);
  }

  private async ensureProfileRow(
    userId: string,
    email: string,
  ): Promise<ProfileRow> {
    const existingRow = await this.profileRepository.findByUserId(userId);
    if (existingRow !== null) {
      return existingRow;
    }

    return this.profileRepository.upsert({
      id: userId,
      email,
      givenNames: [],
      familyName: '',
      patientProfile: this.emptyPatientProfile(),
    });
  }

  private mergeProfile(
    existingRow: ProfileRow | null,
    dto: ProfileDraftInput,
  ): {
    givenNames: string[];
    familyName: string;
    patientProfile: {
      birthDate: string;
      gender: string;
      phoneNumber: string;
      communicationLanguage: string;
      philHealthId: string;
      philSysId: string;
      addressLine1: string;
      addressLine2: string;
      city: string;
      province: string;
      postalCode: string;
      country: string;
      maritalStatus: string;
      nationality: string;
      religion: string;
      occupation: string;
      genderIdentity: string;
      emergencyContactName: string;
      emergencyContactPhone: string;
    };
  } {
    const existingGivenNames = existingRow?.given_names ?? [];
    const existingFamilyName = existingRow?.family_name ?? '';
    const existingPatientProfile = this.normalizeExistingPatientProfile(
      existingRow?.patient_profile,
    );

    const givenNames = this.mergeGivenNames(dto, existingGivenNames);
    const familyName = this.mergeNamePart(dto.lastName, existingFamilyName);

    return {
      givenNames,
      familyName,
      patientProfile: {
        birthDate: this.mergeField(dto.birthDate, existingPatientProfile.birthDate),
        gender: this.mergeField(dto.gender, existingPatientProfile.gender),
        phoneNumber: this.mergeField(
          dto.phoneNumber,
          existingPatientProfile.phoneNumber,
        ),
        communicationLanguage: this.mergeField(
          dto.communicationLanguage,
          existingPatientProfile.communicationLanguage,
        ),
        philHealthId: this.mergeField(
          dto.philHealthId,
          existingPatientProfile.philHealthId,
        ),
        philSysId: this.mergeField(dto.philSysId, existingPatientProfile.philSysId),
        addressLine1: this.mergeField(
          dto.addressLine1,
          existingPatientProfile.addressLine1,
        ),
        addressLine2: this.mergeField(
          dto.addressLine2,
          existingPatientProfile.addressLine2,
        ),
        city: this.mergeField(dto.city, existingPatientProfile.city),
        province: this.mergeField(dto.province, existingPatientProfile.province),
        postalCode: this.mergeField(
          dto.postalCode,
          existingPatientProfile.postalCode,
        ),
        country: this.mergeField(dto.country, existingPatientProfile.country),
        maritalStatus: this.mergeField(
          dto.maritalStatus,
          existingPatientProfile.maritalStatus,
        ),
        nationality: this.mergeField(
          dto.nationality,
          existingPatientProfile.nationality,
        ),
        religion: this.mergeField(dto.religion, existingPatientProfile.religion),
        occupation: this.mergeField(dto.occupation, existingPatientProfile.occupation),
        genderIdentity: this.mergeField(
          dto.genderIdentity,
          existingPatientProfile.genderIdentity,
        ),
        emergencyContactName: this.mergeField(
          dto.emergencyContactName,
          existingPatientProfile.emergencyContactName,
        ),
        emergencyContactPhone: this.mergeField(
          dto.emergencyContactPhone,
          existingPatientProfile.emergencyContactPhone,
        ),
      },
    };
  }

  private mergeGivenNames(
    dto: ProfileDraftInput,
    existingGivenNames: string[],
  ): string[] {
    const nextNames = [
      this.normalizeNamePart(dto.firstName),
      this.normalizeNamePart(dto.secondName ?? ''),
      this.normalizeNamePart(dto.middleName ?? ''),
    ].filter((name) => name.length > 0);

    if (nextNames.length > 0) {
      return nextNames;
    }

    return existingGivenNames.map((name) => this.normalizeNamePart(name));
  }

  private mergeNamePart(nextValue: string | undefined, existingValue: string): string {
    const normalizedNext = this.normalizeOptional(nextValue);
    if (normalizedNext.length > 0) {
      return normalizedNext;
    }

    return this.normalizeOptional(existingValue);
  }

  private mergeField(nextValue: string | undefined, existingValue: string): string {
    return this.mergeNamePart(nextValue, existingValue);
  }

  private normalizeExistingPatientProfile(
    value: ProfileRow['patient_profile'] | undefined,
  ): {
    birthDate: string;
    gender: string;
    phoneNumber: string;
    communicationLanguage: string;
    philHealthId: string;
    philSysId: string;
    addressLine1: string;
    addressLine2: string;
    city: string;
    province: string;
    postalCode: string;
    country: string;
    maritalStatus: string;
    nationality: string;
    religion: string;
    occupation: string;
    genderIdentity: string;
    emergencyContactName: string;
    emergencyContactPhone: string;
  } {
    const record =
      value !== null && typeof value === 'object' && !Array.isArray(value)
        ? (value as Record<string, unknown>)
        : {};

    return {
      birthDate: this.normalizeOptional(record.birthDate as string | undefined),
      gender: this.normalizeOptional(record.gender as string | undefined),
      phoneNumber: this.normalizeOptional(record.phoneNumber as string | undefined),
      communicationLanguage: this.normalizeOptional(
        record.communicationLanguage as string | undefined,
      ),
      philHealthId: this.normalizeOptional(record.philHealthId as string | undefined),
      philSysId: this.normalizeOptional(record.philSysId as string | undefined),
      addressLine1: this.normalizeOptional(record.addressLine1 as string | undefined),
      addressLine2: this.normalizeOptional(record.addressLine2 as string | undefined),
      city: this.normalizeOptional(record.city as string | undefined),
      province: this.normalizeOptional(record.province as string | undefined),
      postalCode: this.normalizeOptional(record.postalCode as string | undefined),
      country: this.normalizeOptional(record.country as string | undefined),
      maritalStatus: this.normalizeOptional(record.maritalStatus as string | undefined),
      nationality: this.normalizeOptional(record.nationality as string | undefined),
      religion: this.normalizeOptional(record.religion as string | undefined),
      occupation: this.normalizeOptional(record.occupation as string | undefined),
      genderIdentity: this.normalizeOptional(record.genderIdentity as string | undefined),
      emergencyContactName: this.normalizeOptional(
        record.emergencyContactName as string | undefined,
      ),
      emergencyContactPhone: this.normalizeOptional(
        record.emergencyContactPhone as string | undefined,
      ),
    };
  }

  private toPatientProfile(dto: Partial<UpdateProfileDto>): {
    birthDate: string;
    gender: string;
    phoneNumber: string;
    communicationLanguage: string;
    philHealthId: string;
    philSysId: string;
    addressLine1: string;
    addressLine2: string;
    city: string;
    province: string;
    postalCode: string;
    country: string;
    maritalStatus: string;
    nationality: string;
    religion: string;
    occupation: string;
    genderIdentity: string;
    emergencyContactName: string;
    emergencyContactPhone: string;
  } {
    return {
      birthDate: this.normalizeOptional(dto.birthDate),
      gender: this.normalizeOptional(dto.gender),
      phoneNumber: this.normalizeOptional(dto.phoneNumber),
      communicationLanguage: this.normalizeOptional(dto.communicationLanguage),
      philHealthId: this.normalizeOptional(dto.philHealthId),
      philSysId: this.normalizeOptional(dto.philSysId),
      addressLine1: this.normalizeOptional(dto.addressLine1),
      addressLine2: this.normalizeOptional(dto.addressLine2),
      city: this.normalizeOptional(dto.city),
      province: this.normalizeOptional(dto.province),
      postalCode: this.normalizeOptional(dto.postalCode),
      country: this.normalizeOptional(dto.country),
      maritalStatus: this.normalizeOptional(dto.maritalStatus),
      nationality: this.normalizeOptional(dto.nationality),
      religion: this.normalizeOptional(dto.religion),
      occupation: this.normalizeOptional(dto.occupation),
      genderIdentity: this.normalizeOptional(dto.genderIdentity),
      emergencyContactName: this.normalizeOptional(dto.emergencyContactName),
      emergencyContactPhone: this.normalizeOptional(dto.emergencyContactPhone),
    };
  }

  private emptyPatientProfile() {
    return this.toPatientProfile({});
  }

  private normalizeNamePart(value: string | undefined): string {
    return this.normalizeOptional(value);
  }

  private normalizeOptional(value: string | undefined): string {
    return (value ?? '').trim().replace(/\s+/g, ' ');
  }
}
