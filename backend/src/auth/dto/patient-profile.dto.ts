import {
  IsDateString,
  IsIn,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
  Matches,
  ValidateIf,
} from 'class-validator';
import { ProfileNameDto } from './profile-name.dto';

const GENDER_VALUES = ['male', 'female', 'other', 'unknown'] as const;
const PHONE_NUMBER_PATTERN = /^\+?[0-9][0-9\s()-]{6,29}$/;
const POSTAL_CODE_PATTERN = /^\d{4}$/;
const PHILHEALTH_ID_PATTERN = /^\d{2}-?\d{9}-?\d$/;
const PHILSYS_ID_PATTERN = /^\d{4}-?\d{7}-?\d$/;

export class PatientProfileDto extends ProfileNameDto {
  @IsString()
  @IsDateString()
  birthDate!: string;

  @IsString()
  @IsIn(GENDER_VALUES)
  gender!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(30)
  @Matches(PHONE_NUMBER_PATTERN, {
    message: 'phoneNumber must be a valid phone number',
  })
  phoneNumber!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(80)
  communicationLanguage!: string;

  @ValidateIf(
    (profile: PatientProfileDto) => (profile.philSysId ?? '').trim().length === 0,
  )
  @IsString()
  @MinLength(1)
  @MaxLength(80)
  @Matches(PHILHEALTH_ID_PATTERN, {
    message: 'philHealthId must match the expected PhilHealth ID format',
  })
  philHealthId!: string;

  @ValidateIf(
    (profile: PatientProfileDto) =>
      (profile.philHealthId ?? '').trim().length === 0,
  )
  @IsString()
  @MinLength(1)
  @MaxLength(80)
  @Matches(PHILSYS_ID_PATTERN, {
    message: 'philSysId must match the expected PhilSys ID format',
  })
  philSysId!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(160)
  addressLine1!: string;

  @IsOptional()
  @ValidateIf(
    (_, value) => typeof value === 'string' && value.trim().length > 0,
  )
  @IsString()
  @MaxLength(160)
  addressLine2?: string;

  @IsString()
  @MinLength(1)
  @MaxLength(120)
  city!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(120)
  province!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(20)
  @Matches(POSTAL_CODE_PATTERN, {
    message: 'postalCode must be a 4-digit code',
  })
  postalCode!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(120)
  country!: string;

  @IsOptional()
  @ValidateIf(
    (_, value) => typeof value === 'string' && value.trim().length > 0,
  )
  @IsString()
  @MaxLength(80)
  maritalStatus?: string;

  @IsOptional()
  @ValidateIf(
    (_, value) => typeof value === 'string' && value.trim().length > 0,
  )
  @IsString()
  @MaxLength(80)
  nationality?: string;

  @IsOptional()
  @ValidateIf(
    (_, value) => typeof value === 'string' && value.trim().length > 0,
  )
  @IsString()
  @MaxLength(80)
  religion?: string;

  @IsOptional()
  @ValidateIf(
    (_, value) => typeof value === 'string' && value.trim().length > 0,
  )
  @IsString()
  @MaxLength(80)
  occupation?: string;

  @IsOptional()
  @ValidateIf(
    (_, value) => typeof value === 'string' && value.trim().length > 0,
  )
  @IsString()
  @MaxLength(80)
  genderIdentity?: string;

  @IsOptional()
  @ValidateIf(
    (_, value) => typeof value === 'string' && value.trim().length > 0,
  )
  @IsString()
  @MaxLength(120)
  emergencyContactName?: string;

  @IsOptional()
  @ValidateIf(
    (_, value) => typeof value === 'string' && value.trim().length > 0,
  )
  @IsString()
  @MaxLength(30)
  @Matches(PHONE_NUMBER_PATTERN, {
    message: 'emergencyContactPhone must be a valid phone number',
  })
  emergencyContactPhone?: string;
}
