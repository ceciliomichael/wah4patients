import { IsString, MaxLength, MinLength } from "class-validator";

export class VerifyMfaBackupCodeDto {
  @IsString()
  @MaxLength(2048)
  mfaChallengeToken!: string;

  @IsString()
  @MinLength(6)
  @MaxLength(32)
  backupCode!: string;
}
