import {
  IsOptional,
  IsString,
  Length,
  Matches,
  MaxLength,
} from 'class-validator';

export class SetMpinDto {
  @IsString()
  @Length(4, 4)
  @Matches(/^\d{4}$/)
  mpin!: string;

  @IsString()
  @Length(4, 4)
  @Matches(/^\d{4}$/)
  confirmMpin!: string;

  @IsOptional()
  @IsString()
  @MaxLength(2048)
  securityVerificationToken?: string;
}
