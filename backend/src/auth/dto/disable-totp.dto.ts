import { IsString, MaxLength } from "class-validator";

export class DisableTotpDto {
  @IsString()
  @MaxLength(2048)
  securityVerificationToken!: string;
}
