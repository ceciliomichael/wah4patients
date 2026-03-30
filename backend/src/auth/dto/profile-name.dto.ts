import {
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
  ValidateIf,
} from 'class-validator';

export class ProfileNameDto {
  @IsString()
  @MinLength(1)
  @Matches(/\S/, { message: 'firstName cannot be blank' })
  @MaxLength(100)
  firstName!: string;

  @IsOptional()
  @ValidateIf(
    (_, value) => typeof value === 'string' && value.trim().length > 0,
  )
  @IsString()
  @Matches(/\S/, { message: 'secondName cannot be blank' })
  @MaxLength(100)
  secondName?: string;

  @IsOptional()
  @ValidateIf(
    (_, value) => typeof value === 'string' && value.trim().length > 0,
  )
  @IsString()
  @Matches(/\S/, { message: 'middleName cannot be blank' })
  @MaxLength(100)
  middleName?: string;

  @IsString()
  @MinLength(1)
  @Matches(/\S/, { message: 'lastName cannot be blank' })
  @MaxLength(100)
  lastName!: string;
}
