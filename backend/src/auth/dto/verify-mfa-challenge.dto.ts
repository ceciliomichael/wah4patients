import { IsString, Matches, MaxLength } from "class-validator";

export class VerifyMfaChallengeDto {
  @IsString()
  @MaxLength(2048)
  mfaChallengeToken!: string;

  @IsString()
  @Matches(/^\d{6}$/)
  code!: string;
}
