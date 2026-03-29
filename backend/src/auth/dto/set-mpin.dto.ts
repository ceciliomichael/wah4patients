import { IsString, Length, Matches, MaxLength, MinLength } from "class-validator";

export class SetMpinDto {
  @IsString()
  @Length(4, 4)
  @Matches(/^\d{4}$/)
  mpin!: string;

  @IsString()
  @Length(4, 4)
  @Matches(/^\d{4}$/)
  confirmMpin!: string;

  @IsString()
  @MinLength(16)
  @MaxLength(128)
  deviceId!: string;
}
