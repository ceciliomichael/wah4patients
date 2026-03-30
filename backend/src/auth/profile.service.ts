import { Injectable } from '@nestjs/common';
import { CompleteRegistrationDto } from './dto/complete-registration.dto';
import { ProfileNameDto } from './dto/profile-name.dto';
import {
  PatientProfileResponse,
  CompleteRegistrationResponse,
} from './auth.types';
import { ProfileRepository } from './profile.repository';

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
    dto: ProfileNameDto,
  ): Promise<PatientProfileResponse> {
    const row = await this.profileRepository.upsert({
      id: userId,
      email,
      givenNames: this.toGivenNames(dto),
      familyName: this.normalizeNamePart(dto.lastName),
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
  ): Promise<{
    id: string;
    email: string;
    given_names: string[];
    family_name: string;
    created_at: string;
    updated_at: string;
  }> {
    const existingRow = await this.profileRepository.findByUserId(userId);
    if (existingRow !== null) {
      return existingRow;
    }

    return this.profileRepository.upsert({
      id: userId,
      email,
      givenNames: [],
      familyName: '',
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

  private normalizeNamePart(value: string): string {
    return value.trim().replace(/\s+/g, ' ');
  }
}
