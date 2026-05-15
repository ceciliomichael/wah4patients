import {
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
  ValidateIf,
} from 'class-validator';

const NAME_PATTERN = /^[A-Za-zÀ-ÿ][A-Za-zÀ-ÿ' .-]*$/;

export class ProfileNameDto {
  @IsString()
  @MinLength(1)
  @Matches(/\S/, { message: 'firstName cannot be blank' })
  @Matches(NAME_PATTERN, {
    message: 'firstName can only contain letters, spaces, and basic punctuation',
  })
  @MaxLength(100)
  firstName!: string;

  @IsOptional()
  @ValidateIf(
    (_, value) => typeof value === 'string' && value.trim().length > 0,
  )
  @IsString()
  @Matches(/\S/, { message: 'middleName cannot be blank' })
  @Matches(NAME_PATTERN, {
    message: 'middleName can only contain letters, spaces, and basic punctuation',
  })
  @MaxLength(100)
  middleName?: string;

  @IsString()
  @MinLength(1)
  @Matches(/\S/, { message: 'lastName cannot be blank' })
  @Matches(NAME_PATTERN, {
    message: 'lastName can only contain letters, spaces, and basic punctuation',
  })
  @MaxLength(100)
  lastName!: string;
}
