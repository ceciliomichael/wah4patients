import { IsEmail, IsString, MaxLength, MinLength } from 'class-validator';

export class CompleteRegistrationDto {
  @IsString()
  @IsEmail()
  @MaxLength(254)
  email!: string;

  @IsString()
  @MinLength(8)
  @MaxLength(20)
  password!: string;

  @IsString()
  @MinLength(20)
  registrationToken!: string;
}
