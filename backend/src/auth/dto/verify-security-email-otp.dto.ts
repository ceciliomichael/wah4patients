import { IsEmail, IsString, Matches } from "class-validator";

export class VerifySecurityEmailOtpDto {
  @IsEmail()
  email!: string;

  @IsString()
  @Matches(/^\d{6}$/)
  otpCode!: string;
}
