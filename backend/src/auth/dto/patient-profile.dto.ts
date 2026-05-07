import {
  IsDateString,
  IsIn,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
  ValidateIf,
} from 'class-validator';
import { ProfileNameDto } from './profile-name.dto';

const GENDER_VALUES = ['male', 'female', 'other', 'unknown'] as const;

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
  phoneNumber!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(80)
  communicationLanguage!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(80)
  philHealthId!: string;

  @IsString()
  @MinLength(1)
  @MaxLength(80)
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
  emergencyContactPhone?: string;
}
