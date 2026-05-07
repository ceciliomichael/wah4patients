import { Injectable } from '@nestjs/common';
import { CompleteRegistrationDto } from './dto/complete-registration.dto';
import { ProfileNameDto } from './dto/profile-name.dto';
import { UpdateProfileDto } from './dto/update-profile.dto';
import {
  PatientProfileResponse,
  CompleteRegistrationResponse,
} from './auth.types';
import { ProfileRepository, type ProfileRow } from './profile.repository';

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
    dto: UpdateProfileDto | ProfileNameDto,
  ): Promise<PatientProfileResponse> {
    const row = await this.profileRepository.upsert({
      id: userId,
      email,
      givenNames: this.toGivenNames(dto),
      familyName: this.normalizeNamePart(dto.lastName),
      patientProfile: this.toPatientProfile(dto),
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

  private toGivenNames(dto: ProfileNameDto): string[] {
    const names = [
      this.normalizeNamePart(dto.firstName),
      this.normalizeNamePart(dto.secondName ?? ''),
      this.normalizeNamePart(dto.middleName ?? ''),
    ];

    return names.filter((name) => name.length > 0);
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

  private normalizeNamePart(value: string): string {
    return value.trim().replace(/\s+/g, ' ');
  }

  private normalizeOptional(value: string | undefined): string {
    return (value ?? '').trim().replace(/\s+/g, ' ');
  }
}
