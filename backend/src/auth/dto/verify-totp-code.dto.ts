import { IsString, Matches } from "class-validator";

export class VerifyTotpCodeDto {
  @IsString()
  @Matches(/^\d{6}$/)
  code!: string;
}
