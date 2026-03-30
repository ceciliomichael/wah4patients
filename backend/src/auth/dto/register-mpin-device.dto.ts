import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class RegisterMpinDeviceDto {
  @IsString()
  @MinLength(16)
  @MaxLength(128)
  deviceId!: string;

  @IsOptional()
  @IsString()
  @MaxLength(2048)
  securityVerificationToken?: string;
}
