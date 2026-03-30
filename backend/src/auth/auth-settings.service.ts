import { Injectable } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";

@Injectable()
export class AuthSettingsService {
  readonly otpTtlMinutes: number;
  readonly otpResendCooldownSeconds: number;
  readonly otpMaxAttempts: number;
  readonly otpHashSecret: string;
  readonly registrationTokenSecret: string;
  readonly registrationTokenTtlSeconds: number;
  readonly passwordResetTokenSecret: string;
  readonly passwordResetTokenTtlSeconds: number;
  readonly mfaChallengeTokenSecret: string;
  readonly mfaChallengeTokenTtlSeconds: number;
  readonly totpIssuer: string;
  readonly totpRecoveryCodesCount: number;
  readonly totpSecretEncryptionKey: string;
  readonly mpinMaxFailedAttempts: number;
  readonly mpinLockDurationMinutes: number;
  readonly mpinBcryptRounds: number;
  readonly securityVerificationTokenSecret: string;
  readonly securityVerificationTokenTtlSeconds: number;

  constructor(private readonly configService: ConfigService) {
    this.otpTtlMinutes = this.configService.get<number>("OTP_TTL_MINUTES", 10);
    this.otpResendCooldownSeconds = this.configService.get<number>(
      "OTP_RESEND_COOLDOWN_SECONDS",
      45,
    );
    this.otpMaxAttempts = this.configService.get<number>("OTP_MAX_ATTEMPTS", 5);
    this.otpHashSecret =
      this.configService.getOrThrow<string>("OTP_HASH_SECRET");
    this.registrationTokenSecret = this.configService.getOrThrow<string>(
      "REGISTRATION_TOKEN_SECRET",
    );
    this.registrationTokenTtlSeconds = this.configService.get<number>(
      "REGISTRATION_TOKEN_TTL_SECONDS",
      900,
    );
    this.passwordResetTokenSecret = this.configService.getOrThrow<string>(
      "PASSWORD_RESET_TOKEN_SECRET",
    );
    this.passwordResetTokenTtlSeconds = this.configService.get<number>(
      "PASSWORD_RESET_TOKEN_TTL_SECONDS",
      900,
    );
    this.mfaChallengeTokenSecret = this.configService.getOrThrow<string>(
      "MFA_CHALLENGE_TOKEN_SECRET",
    );
    this.mfaChallengeTokenTtlSeconds = this.configService.get<number>(
      "MFA_CHALLENGE_TOKEN_TTL_SECONDS",
      180,
    );
    this.totpIssuer = this.configService.get<string>("TOTP_ISSUER", "WAH4P");
    this.totpRecoveryCodesCount = this.configService.get<number>(
      "TOTP_RECOVERY_CODES_COUNT",
      8,
    );
    this.totpSecretEncryptionKey = this.configService.getOrThrow<string>(
      "TOTP_SECRET_ENCRYPTION_KEY",
    );
    this.mpinMaxFailedAttempts = this.configService.get<number>(
      "MPIN_MAX_FAILED_ATTEMPTS",
      5,
    );
    this.mpinLockDurationMinutes = this.configService.get<number>(
      "MPIN_LOCK_DURATION_MINUTES",
      15,
    );
    this.mpinBcryptRounds = this.configService.get<number>(
      "MPIN_BCRYPT_ROUNDS",
      12,
    );
    this.securityVerificationTokenSecret = this.configService.getOrThrow<string>(
      "SECURITY_VERIFICATION_TOKEN_SECRET",
    );
    this.securityVerificationTokenTtlSeconds = this.configService.get<number>(
      "SECURITY_VERIFICATION_TOKEN_TTL_SECONDS",
      300,
    );
  }
}
