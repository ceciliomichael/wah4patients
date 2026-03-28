import { IsEmail, IsString, MaxLength } from "class-validator";

export class RequestPasswordResetOtpDto {
  @IsString()
  @IsEmail()
  @MaxLength(254)
  email!: string;
}
