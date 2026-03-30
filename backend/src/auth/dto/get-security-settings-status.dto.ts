import { IsString, MaxLength, MinLength } from "class-validator";

export class GetSecuritySettingsStatusDto {
  @IsString()
  @MinLength(16)
  @MaxLength(128)
  deviceId!: string;
}
