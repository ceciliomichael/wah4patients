import {
  IsIn,
  IsISO8601,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

export class AppointmentPushRequestDto {
  @IsString()
  @IsUUID()
  targetProviderId!: string;

  @IsString()
  @IsIn(['onsite', 'teleconsultation'])
  appointmentMode!: 'onsite' | 'teleconsultation';

  @IsString()
  @MaxLength(120)
  appointmentType!: string;

  @IsString()
  @IsISO8601()
  scheduledAt!: string;

  @Type(() => Number)
  @IsInt()
  @Min(15)
  durationMinutes!: number;

  @IsString()
  @MaxLength(120)
  locationOrPlatform!: string;

  @IsString()
  @MaxLength(255)
  identifierSystem!: string;

  @IsString()
  @MaxLength(255)
  identifierValue!: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  reason?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;
}
