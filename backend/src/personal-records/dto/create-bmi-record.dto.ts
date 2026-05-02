import { IsIn, IsNumber, IsOptional, IsString, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateBmiRecordDto {
  @Type(() => Number)
  @IsNumber({ allowNaN: false, allowInfinity: false })
  @Min(0.1)
  weightValue!: number;

  @Type(() => Number)
  @IsNumber({ allowNaN: false, allowInfinity: false })
  @Min(0.1)
  heightValue!: number;

  @IsString()
  @IsIn(['metric', 'imperial'])
  measurementSystem!: 'metric' | 'imperial';

  @IsOptional()
  @Type(() => Number)
  @IsNumber({ allowNaN: false, allowInfinity: false })
  @Min(0.1)
  manualBmiValue?: number;

  @IsOptional()
  @IsString()
  notes?: string;
}
