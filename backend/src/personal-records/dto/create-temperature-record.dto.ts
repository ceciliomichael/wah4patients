import { IsIn, IsNumber, IsOptional, IsString, Min } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateTemperatureRecordDto {
  @Type(() => Number)
  @IsNumber({ allowNaN: false, allowInfinity: false })
  @Min(0.1)
  temperatureValue!: number;

  @IsString()
  @IsIn(['celsius', 'fahrenheit'])
  temperatureUnit!: 'celsius' | 'fahrenheit';

  @IsOptional()
  @IsString()
  measurementMethod?: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
