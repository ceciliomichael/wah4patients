import { IsEmail } from "class-validator";

export class RequestSecurityEmailOtpDto {
  @IsEmail()
  email!: string;
}
