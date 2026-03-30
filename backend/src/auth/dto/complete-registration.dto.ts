import { IsEmail, IsString, MaxLength, MinLength } from 'class-validator';
import { ProfileNameDto } from './profile-name.dto';

export class CompleteRegistrationDto extends ProfileNameDto {
  @IsString()
  @IsEmail()
  @MaxLength(254)
  email!: string;

  @IsString()
  @MinLength(20)
  registrationToken!: string;

  @IsString()
  @MinLength(8)
  @MaxLength(20)
  password!: string;
}
