import {
  IsIn,
  IsISO8601,
  IsNumber,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
  Min,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateMedicationIntakeRecordDto {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  prescriptionId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  medicationReference?: string;

  @IsString()
  @MinLength(1)
  @Matches(/\S/, { message: 'medicationNameSnapshot cannot be blank' })
  @MaxLength(200)
  medicationNameSnapshot!: string;

  @IsISO8601()
  scheduledAt!: string;

  @IsOptional()
  @IsISO8601()
  takenAt?: string;

  @IsString()
  @IsIn(['scheduled', 'taken', 'missed', 'delayed', 'skipped'])
  status!: 'scheduled' | 'taken' | 'missed' | 'delayed' | 'skipped';

  @IsOptional()
  @Type(() => Number)
  @IsNumber({ allowNaN: false, allowInfinity: false })
  @Min(0.01)
  quantityValue?: number;

  @IsOptional()
  @IsString()
  @MaxLength(64)
  quantityUnit?: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
