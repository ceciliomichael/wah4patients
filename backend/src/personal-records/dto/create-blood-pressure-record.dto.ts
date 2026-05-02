import { IsIn, IsNumber, IsOptional, IsString, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateBloodPressureRecordDto {
  @Type(() => Number)
  @IsNumber({ allowNaN: false, allowInfinity: false })
  @Min(1)
  systolicMmHg!: number;

  @Type(() => Number)
  @IsNumber({ allowNaN: false, allowInfinity: false })
  @Min(1)
  diastolicMmHg!: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber({ allowNaN: false, allowInfinity: false })
  @Min(1)
  pulseRate?: number;

  @IsOptional()
  @IsString()
  @IsIn(['sitting', 'standing', 'lying', 'other'])
  measurementPosition?: 'sitting' | 'standing' | 'lying' | 'other';

  @IsOptional()
  @IsString()
  measurementMethod?: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
