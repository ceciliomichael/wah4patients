import {
  IsBoolean,
  IsDateString,
  IsIn,
  IsOptional,
  IsString,
  MaxLength,
  Matches,
  ValidateIf,
} from 'class-validator';

const GENDER_VALUES = ['male', 'female', 'other', 'unknown'] as const;
const PHONE_NUMBER_PATTERN = /^\+?[0-9][0-9\s()-]{6,29}$/;
const POSTAL_CODE_PATTERN = /^\d{4}$/;
const PHILHEALTH_ID_PATTERN = /^\d{2}-?\d{9}-?\d$/;
const PHILSYS_ID_PATTERN = /^\d{4}-?\d{7}-?\d$/;

export class UpdateProfileDto {
  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(100)
  firstName?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(100)
  middleName?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(100)
  lastName?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsDateString()
  birthDate?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @IsIn(GENDER_VALUES)
  gender?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(30)
  @Matches(PHONE_NUMBER_PATTERN, {
    message: 'phoneNumber must be a valid phone number',
  })
  phoneNumber?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(80)
  communicationLanguage?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(80)
  @Matches(PHILHEALTH_ID_PATTERN, {
    message: 'philHealthId must match the expected PhilHealth ID format',
  })
  philHealthId?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(80)
  @Matches(PHILSYS_ID_PATTERN, {
    message: 'philSysId must match the expected PhilSys ID format',
  })
  philSysId?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(160)
  addressLine1?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(160)
  addressLine2?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  city?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  province?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  region?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  barangay?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(20)
  @Matches(POSTAL_CODE_PATTERN, {
    message: 'postalCode must be a 4-digit code',
  })
  postalCode?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  country?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(80)
  maritalStatus?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(80)
  nationality?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(80)
  religion?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(80)
  occupation?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(80)
  genderIdentity?: string;

  @IsOptional()
  @IsBoolean()
  indigenousPeople?: boolean;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  indigenousGroup?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  race?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  educationalAttainment?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  sexAtBirth?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  pwdIdNumber?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  pwdDisabilityType?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsDateString()
  pwdIdExpirationDate?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  pwdIssuingLgu?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(120)
  emergencyContactName?: string;

  @IsOptional()
  @ValidateIf((_, value) => typeof value === 'string' && value.trim().length > 0)
  @IsString()
  @MaxLength(30)
  @Matches(PHONE_NUMBER_PATTERN, {
    message: 'emergencyContactPhone must be a valid phone number',
  })
  emergencyContactPhone?: string;
}
