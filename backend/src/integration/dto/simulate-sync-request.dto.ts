import { IsOptional, IsString, MaxLength } from 'class-validator';

export class SimulateSyncRequestDto {
  @IsString()
  providerId!: string;

  @IsString()
  @MaxLength(255)
  identifierSystem!: string;

  @IsString()
  @MaxLength(255)
  identifierValue!: string;

  @IsOptional()
  @IsString()
  @MaxLength(64)
  resourceType?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  reason?: string;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  notes?: string;
}
