import { IsString, Matches, MaxLength } from "class-validator";

export class VerifyTotpForSecurityActionDto {
  @IsString()
  @MaxLength(2048)
  accessToken!: string;

  @IsString()
  @Matches(/^\d{6}$/)
  code!: string;
}
