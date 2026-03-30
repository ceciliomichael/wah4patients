import { IsString, Length, Matches, MaxLength, MinLength } from "class-validator";

export class VerifyMpinDto {
  @IsString()
  @Length(4, 4)
  @Matches(/^\d{4}$/)
  mpin!: string;

  @IsString()
  @MinLength(16)
  @MaxLength(128)
  deviceId!: string;
}
