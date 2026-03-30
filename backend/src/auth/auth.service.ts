import {
  BadGatewayException,
  BadRequestException,
  ConflictException,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  UnauthorizedException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { authenticator } from "otplib";
import {
  createCipheriv,
  createDecipheriv,
  createHash,
  randomBytes,
  randomInt,
  timingSafeEqual,
} from "node:crypto";
import { compare, hash } from "bcryptjs";
import { MailerService } from "../mailer/mailer.service";
import { SupabaseService } from "../supabase/supabase.service";
import { CompletePasswordResetDto } from "./dto/complete-password-reset.dto";
import { CompleteRegistrationDto } from "./dto/complete-registration.dto";
import { DisableTotpDto } from "./dto/disable-totp.dto";
import { LoginDto } from "./dto/login.dto";
import { RequestPasswordResetOtpDto } from "./dto/request-password-reset-otp.dto";
import { RequestRegistrationOtpDto } from "./dto/request-registration-otp.dto";
import { SetMpinDto } from "./dto/set-mpin.dto";
import { VerifyMfaChallengeDto } from "./dto/verify-mfa-challenge.dto";
import { VerifyMfaBackupCodeDto } from "./dto/verify-mfa-backup-code.dto";
import { VerifyMpinDto } from "./dto/verify-mpin.dto";
import { VerifyPasswordResetOtpDto } from "./dto/verify-password-reset-otp.dto";
import { VerifyRegistrationOtpDto } from "./dto/verify-registration-otp.dto";
import { VerifyTotpCodeDto } from "./dto/verify-totp-code.dto";
import {
  CompletePasswordResetResponse,
  CompleteRegistrationResponse,
  LoginMfaRequiredResponse,
  LoginResponse,
  LoginResultResponse,
  MfaChallengeTokenPayload,
  PasswordResetTokenPayload,
  RegistrationTokenPayload,
  RequestOtpResponse,
  RequestPasswordResetOtpResponse,
  SetMpinResponse,
  TotpSetupStartResponse,
  TotpSetupVerifyResponse,
  VerifyMpinResponse,
  VerifyOtpResponse,
  VerifyPasswordResetOtpResponse,
} from "./auth.types";
import { PasswordResetOtpRepository } from "./password-reset-otp.repository";
import { RegistrationOtpRepository } from "./registration-otp.repository";
import { TotpFactorRepository } from "./totp-factor.repository";
import { TotpRecoveryCodesRepository } from "./totp-recovery-codes.repository";
import { UserMpinRepository } from "./user-mpin.repository";

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly otpTtlMinutes: number;
  private readonly otpResendCooldownSeconds: number;
  private readonly otpMaxAttempts: number;
  private readonly otpHashSecret: string;
  private readonly registrationTokenSecret: string;
  private readonly registrationTokenTtlSeconds: number;
  private readonly passwordResetTokenSecret: string;
  private readonly passwordResetTokenTtlSeconds: number;
  private readonly mfaChallengeTokenSecret: string;
  private readonly mfaChallengeTokenTtlSeconds: number;
  private readonly totpIssuer: string;
  private readonly totpRecoveryCodesCount: number;
  private readonly totpSecretEncryptionKey: string;
  private readonly mpinMaxFailedAttempts: number;
  private readonly mpinLockDurationMinutes: number;
  private readonly mpinBcryptRounds: number;

  constructor(
    private readonly configService: ConfigService,
    private readonly jwtService: JwtService,
    private readonly mailerService: MailerService,
    private readonly supabaseService: SupabaseService,
    private readonly registrationOtpRepository: RegistrationOtpRepository,
    private readonly passwordResetOtpRepository: PasswordResetOtpRepository,
    private readonly totpFactorRepository: TotpFactorRepository,
    private readonly totpRecoveryCodesRepository: TotpRecoveryCodesRepository,
    private readonly userMpinRepository: UserMpinRepository,
  ) {
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
  }

  async requestRegistrationOtp(
    dto: RequestRegistrationOtpDto,
  ): Promise<RequestOtpResponse> {
    const normalizedEmail = this.normalizeEmail(dto.email);
    const existingRecord =
      await this.registrationOtpRepository.findByEmail(normalizedEmail);
    const now = new Date();

    if (existingRecord !== null) {
      const nextAllowedAt = this.addSeconds(
        new Date(existingRecord.lastSentAt),
        this.otpResendCooldownSeconds,
      );
      if (nextAllowedAt > now) {
        const waitSeconds = Math.ceil(
          (nextAllowedAt.getTime() - now.getTime()) / 1000,
        );
        throw new HttpException(
          `Please wait ${waitSeconds} seconds before requesting a new verification code`,
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }
    }

    const otpCode = this.generateOtpCode();
    const hashedOtp = this.hashOtp(normalizedEmail, otpCode);
    const expiresAt = this.addMinutes(now, this.otpTtlMinutes).toISOString();

    await this.registrationOtpRepository.upsert({
      email: normalizedEmail,
      codeHash: hashedOtp,
      expiresAt,
      failedAttempts: 0,
      lastSentAt: now.toISOString(),
      verifiedAt: null,
    });

    try {
      await this.mailerService.sendRegistrationOtpEmail({
        email: normalizedEmail,
        otpCode,
        expiresInMinutes: this.otpTtlMinutes,
      });
    } catch (error) {
      await this.registrationOtpRepository.deleteByEmail(normalizedEmail);
      throw error;
    }

    return {
      message: "Verification code sent",
      cooldownSeconds: this.otpResendCooldownSeconds,
    };
  }

  async verifyRegistrationOtp(
    dto: VerifyRegistrationOtpDto,
  ): Promise<VerifyOtpResponse> {
    const normalizedEmail = this.normalizeEmail(dto.email);
    const record =
      await this.registrationOtpRepository.findByEmail(normalizedEmail);

    if (record === null) {
      throw new BadRequestException(
        "Verification code request not found for this email",
      );
    }

    if (new Date(record.expiresAt) <= new Date()) {
      await this.registrationOtpRepository.deleteByEmail(normalizedEmail);
      throw new BadRequestException(
        "Verification code expired, please request a new code",
      );
    }

    if (record.failedAttempts >= this.otpMaxAttempts) {
      await this.registrationOtpRepository.deleteByEmail(normalizedEmail);
      throw new UnauthorizedException(
        "Maximum verification attempts reached, request a new code",
      );
    }

    const expectedHash = this.hashOtp(normalizedEmail, dto.otpCode.trim());
    if (!this.hashesMatch(record.codeHash, expectedHash)) {
      const updatedAttempts = record.failedAttempts + 1;
      await this.registrationOtpRepository.incrementFailedAttempts(
        normalizedEmail,
        updatedAttempts,
      );

      if (updatedAttempts >= this.otpMaxAttempts) {
        throw new UnauthorizedException(
          "Maximum verification attempts reached, request a new code",
        );
      }

      throw new UnauthorizedException("Invalid verification code");
    }

    const verifiedAt = new Date().toISOString();
    await this.registrationOtpRepository.markVerified(
      normalizedEmail,
      verifiedAt,
    );

    const registrationToken = await this.jwtService.signAsync(
      {
        sub: normalizedEmail,
        purpose: "registration",
      } satisfies Omit<RegistrationTokenPayload, "iat" | "exp">,
      {
        secret: this.registrationTokenSecret,
        expiresIn: `${this.registrationTokenTtlSeconds}s`,
      },
    );

    return {
      message: "Email verified successfully",
      registrationToken,
      expiresInSeconds: this.registrationTokenTtlSeconds,
    };
  }

  async completeRegistration(
    dto: CompleteRegistrationDto,
  ): Promise<CompleteRegistrationResponse> {
    const normalizedEmail = this.normalizeEmail(dto.email);
    const password = dto.password;

    if (!this.isPasswordStrong(password)) {
      throw new BadRequestException(
        "Password must include uppercase, lowercase, and at least one number",
      );
    }

    const tokenPayload = await this.verifyRegistrationToken(
      dto.registrationToken,
    );

    if (tokenPayload.sub !== normalizedEmail) {
      throw new UnauthorizedException("Registration token email mismatch");
    }

    const otpRecord =
      await this.registrationOtpRepository.findByEmail(normalizedEmail);
    if (
      otpRecord === null ||
      otpRecord.verifiedAt === null ||
      new Date(otpRecord.expiresAt) <= new Date()
    ) {
      throw new BadRequestException(
        "Email verification is required before creating an account",
      );
    }

    const { data, error } =
      await this.supabaseService.adminClient.auth.admin.createUser({
        email: normalizedEmail,
        password,
        email_confirm: true,
      });

    if (error !== null) {
      this.logger.error("Failed to create Supabase auth user", {
        email: normalizedEmail,
        message: error.message,
      });

      if (this.isSupabaseDuplicateUserError(error.message)) {
        throw new ConflictException(
          "An account with this email already exists",
        );
      }

      throw new BadGatewayException(
        error.message.trim().length > 0
          ? `Failed to create account: ${error.message}`
          : "Failed to create account",
      );
    }

    const userId = data.user?.id;
    if (typeof userId !== "string" || userId.length === 0) {
      throw new BadGatewayException(
        "Account was created with invalid user data",
      );
    }

    await this.registrationOtpRepository.deleteByEmail(normalizedEmail);

    return {
      message: "Registration successful",
      userId,
      email: normalizedEmail,
    };
  }

  async requestPasswordResetOtp(
    dto: RequestPasswordResetOtpDto,
  ): Promise<RequestPasswordResetOtpResponse> {
    const normalizedEmail = this.normalizeEmail(dto.email);
    const profileId = await this.findProfileIdByEmail(normalizedEmail);

    if (profileId === null) {
      const existingRecord =
        await this.passwordResetOtpRepository.findByEmail(normalizedEmail);
      if (existingRecord !== null) {
        await this.passwordResetOtpRepository.deleteByEmail(normalizedEmail);
      }

      return {
        message: "If an account exists, a password reset code has been sent",
        cooldownSeconds: this.otpResendCooldownSeconds,
      };
    }

    const existingRecord =
      await this.passwordResetOtpRepository.findByEmail(normalizedEmail);
    const now = new Date();

    if (existingRecord !== null) {
      const nextAllowedAt = this.addSeconds(
        new Date(existingRecord.lastSentAt),
        this.otpResendCooldownSeconds,
      );
      if (nextAllowedAt > now) {
        const waitSeconds = Math.ceil(
          (nextAllowedAt.getTime() - now.getTime()) / 1000,
        );
        throw new HttpException(
          `Please wait ${waitSeconds} seconds before requesting a new verification code`,
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }
    }

    const otpCode = this.generateOtpCode();
    const hashedOtp = this.hashOtp(normalizedEmail, otpCode);
    const expiresAt = this.addMinutes(now, this.otpTtlMinutes).toISOString();

    await this.passwordResetOtpRepository.upsert({
      email: normalizedEmail,
      codeHash: hashedOtp,
      expiresAt,
      failedAttempts: 0,
      lastSentAt: now.toISOString(),
      verifiedAt: null,
    });

    try {
      await this.mailerService.sendPasswordResetOtpEmail({
        email: normalizedEmail,
        otpCode,
        expiresInMinutes: this.otpTtlMinutes,
      });
    } catch (error) {
      await this.passwordResetOtpRepository.deleteByEmail(normalizedEmail);
      throw error;
    }

    return {
      message: "If an account exists, a password reset code has been sent",
      cooldownSeconds: this.otpResendCooldownSeconds,
    };
  }

  async verifyPasswordResetOtp(
    dto: VerifyPasswordResetOtpDto,
  ): Promise<VerifyPasswordResetOtpResponse> {
    const normalizedEmail = this.normalizeEmail(dto.email);
    const record =
      await this.passwordResetOtpRepository.findByEmail(normalizedEmail);

    if (record === null) {
      throw new BadRequestException(
        "Verification code request not found for this email",
      );
    }

    if (new Date(record.expiresAt) <= new Date()) {
      await this.passwordResetOtpRepository.deleteByEmail(normalizedEmail);
      throw new BadRequestException(
        "Verification code expired, please request a new code",
      );
    }

    if (record.failedAttempts >= this.otpMaxAttempts) {
      await this.passwordResetOtpRepository.deleteByEmail(normalizedEmail);
      throw new UnauthorizedException(
        "Maximum verification attempts reached, request a new code",
      );
    }

    const expectedHash = this.hashOtp(normalizedEmail, dto.otpCode.trim());
    if (!this.hashesMatch(record.codeHash, expectedHash)) {
      const updatedAttempts = record.failedAttempts + 1;
      await this.passwordResetOtpRepository.incrementFailedAttempts(
        normalizedEmail,
        updatedAttempts,
      );

      if (updatedAttempts >= this.otpMaxAttempts) {
        throw new UnauthorizedException(
          "Maximum verification attempts reached, request a new code",
        );
      }

      throw new UnauthorizedException("Invalid verification code");
    }

    const verifiedAt = new Date().toISOString();
    await this.passwordResetOtpRepository.markVerified(
      normalizedEmail,
      verifiedAt,
    );

    const passwordResetToken = await this.jwtService.signAsync(
      {
        sub: normalizedEmail,
        purpose: "password-reset",
      } satisfies Omit<PasswordResetTokenPayload, "iat" | "exp">,
      {
        secret: this.passwordResetTokenSecret,
        expiresIn: `${this.passwordResetTokenTtlSeconds}s`,
      },
    );

    return {
      message: "Email verified successfully",
      passwordResetToken,
      expiresInSeconds: this.passwordResetTokenTtlSeconds,
    };
  }

  async completePasswordReset(
    dto: CompletePasswordResetDto,
  ): Promise<CompletePasswordResetResponse> {
    const normalizedEmail = this.normalizeEmail(dto.email);
    const password = dto.password;

    if (!this.isPasswordStrong(password)) {
      throw new BadRequestException(
        "Password must include uppercase, lowercase, and at least one number",
      );
    }

    const tokenPayload = await this.verifyPasswordResetToken(
      dto.passwordResetToken,
    );

    if (tokenPayload.sub !== normalizedEmail) {
      throw new UnauthorizedException("Password reset token email mismatch");
    }

    const otpRecord =
      await this.passwordResetOtpRepository.findByEmail(normalizedEmail);
    if (
      otpRecord === null ||
      otpRecord.verifiedAt === null ||
      new Date(otpRecord.expiresAt) <= new Date()
    ) {
      throw new BadRequestException(
        "Email verification is required before resetting a password",
      );
    }

    const userId = await this.findProfileIdByEmail(normalizedEmail);
    if (userId === null) {
      throw new BadGatewayException("Unable to reset password");
    }

    const { error } =
      await this.supabaseService.adminClient.auth.admin.updateUserById(userId, {
        password,
      });

    if (error !== null) {
      this.logger.error("Failed to reset Supabase auth user password", {
        email: normalizedEmail,
        message: error.message,
      });

      throw new BadGatewayException(
        error.message.trim().length > 0
          ? `Failed to reset password: ${error.message}`
          : "Failed to reset password",
      );
    }

    await this.passwordResetOtpRepository.deleteByEmail(normalizedEmail);

    return {
      message: "Password updated successfully",
    };
  }

  async login(dto: LoginDto): Promise<LoginResultResponse> {
    const normalizedEmail = this.normalizeEmail(dto.email);
    const signInResult = await this.signInWithPasswordWithTrimFallback(
      normalizedEmail,
      dto.password,
    );
    const { data, error } = signInResult;

    if (error !== null || data.session === null || data.user === null) {
      this.logger.error("Failed to sign in Supabase auth user", {
        email: normalizedEmail,
        message: error?.message ?? "Missing session or user in response",
      });

      throw new UnauthorizedException(
        error?.message?.trim().length
          ? `Login failed: ${error.message}`
          : "Invalid email or password",
      );
    }

    const session = data.session;
    const factor = await this.totpFactorRepository.findByUserId(data.user.id);

    if (factor?.isEnabled === true) {
      if (
        factor.totpSecretCiphertext === null ||
        factor.totpSecretCiphertext.trim().length === 0
      ) {
        this.logger.error("2FA is enabled but no active secret is available", {
          userId: data.user.id,
        });
        throw new BadGatewayException("Unable to complete login challenge");
      }

      const challengeToken = await this.jwtService.signAsync(
        {
          sub: data.user.id,
          purpose: "mfa-challenge",
          email: data.user.email ?? normalizedEmail,
          accessToken: session.access_token,
          refreshToken: session.refresh_token,
          expiresIn: session.expires_in,
          tokenType: session.token_type,
        } satisfies Omit<MfaChallengeTokenPayload, "iat" | "exp">,
        {
          secret: this.mfaChallengeTokenSecret,
          expiresIn: `${this.mfaChallengeTokenTtlSeconds}s`,
        },
      );

      return {
        mfaRequired: true,
        mfaChallengeToken: challengeToken,
        expiresInSeconds: this.mfaChallengeTokenTtlSeconds,
        user: {
          id: data.user.id,
          email: data.user.email ?? normalizedEmail,
        },
      } satisfies LoginMfaRequiredResponse;
    }

    return {
      accessToken: session.access_token,
      refreshToken: session.refresh_token,
      expiresIn: session.expires_in,
      tokenType: session.token_type,
      user: {
        id: data.user.id,
        email: data.user.email ?? normalizedEmail,
      },
    };
  }

  async startTotpSetup(
    authorizationHeader: string | undefined,
  ): Promise<TotpSetupStartResponse> {
    const authenticatedUser = await this.getAuthenticatedUserFromHeader(
      authorizationHeader,
    );

    this.configureTotpAuthenticator();
    const secret = this.generateTotpSecret();

    const encryptedSecret = this.encryptTotpSecret(secret);
    await this.totpFactorRepository.upsertTempSecret(
      authenticatedUser.id,
      encryptedSecret,
    );
    const encodedAccount = encodeURIComponent(authenticatedUser.email);
    const encodedIssuer = encodeURIComponent(this.totpIssuer);
    const otpauthUrl =
      `otpauth://totp/${encodedAccount}` +
      `?secret=${secret}` +
      `&issuer=${encodedIssuer}` +
      `&algorithm=SHA1&digits=6&period=30`;

    return {
      otpauthUrl,
      manualEntryKey: secret,
    };
  }

  async verifyTotpSetup(
    authorizationHeader: string | undefined,
    dto: VerifyTotpCodeDto,
  ): Promise<TotpSetupVerifyResponse> {
    const authenticatedUser = await this.getAuthenticatedUserFromHeader(
      authorizationHeader,
    );
    const factor = await this.totpFactorRepository.findByUserId(
      authenticatedUser.id,
    );

    const temporarySecretCiphertext = factor?.totpSecretTempCiphertext ?? "";
    if (temporarySecretCiphertext.trim().length === 0) {
      throw new BadRequestException("No pending 2FA setup was found");
    }

    const temporarySecret = this.decryptTotpSecret(temporarySecretCiphertext);

    this.configureTotpAuthenticator();
    const isValidCode = authenticator.check(dto.code.trim(), temporarySecret);
    if (!isValidCode) {
      throw new UnauthorizedException("Invalid authentication code");
    }

    await this.totpFactorRepository.enableWithActiveSecret(
      authenticatedUser.id,
      temporarySecretCiphertext,
    );

    const recoveryCodes = this.generateRecoveryCodes(this.totpRecoveryCodesCount);
    const recoveryCodeHashes = recoveryCodes.map((code) =>
      this.hashRecoveryCode(authenticatedUser.id, code),
    );
    await this.totpRecoveryCodesRepository.replaceCodes(
      authenticatedUser.id,
      recoveryCodeHashes,
    );

    return {
      message: "Two-factor authentication enabled",
      recoveryCodes,
    };
  }

  async verifyMfaChallenge(dto: VerifyMfaChallengeDto): Promise<LoginResponse> {
    const payload = await this.verifyMfaChallengeToken(dto.mfaChallengeToken);
    const factor = await this.totpFactorRepository.findByUserId(payload.sub);

    if (
      factor === null ||
      factor.isEnabled !== true ||
      factor.totpSecretCiphertext === null
    ) {
      throw new UnauthorizedException("Two-factor authentication is not enabled");
    }

    this.configureTotpAuthenticator();
    const activeSecret = this.decryptTotpSecret(factor.totpSecretCiphertext);
    const isValidCode = authenticator.check(
      dto.code.trim(),
      activeSecret,
    );
    if (!isValidCode) {
      throw new UnauthorizedException("Invalid authentication code");
    }

    return {
      accessToken: payload.accessToken,
      refreshToken: payload.refreshToken,
      expiresIn: payload.expiresIn,
      tokenType: payload.tokenType,
      user: {
        id: payload.sub,
        email: payload.email,
      },
    };
  }

  async verifyMfaBackupCode(
    dto: VerifyMfaBackupCodeDto,
  ): Promise<LoginResponse> {
    const payload = await this.verifyMfaChallengeToken(dto.mfaChallengeToken);
    const normalizedCode = dto.backupCode.trim().toUpperCase();
    if (normalizedCode.length === 0) {
      throw new UnauthorizedException("Invalid backup code");
    }

    const codeHash = this.hashRecoveryCode(payload.sub, normalizedCode);
    const consumed = await this.totpRecoveryCodesRepository.consumeCodeHash(
      payload.sub,
      codeHash,
    );

    if (!consumed) {
      throw new UnauthorizedException("Invalid backup code");
    }

    return {
      accessToken: payload.accessToken,
      refreshToken: payload.refreshToken,
      expiresIn: payload.expiresIn,
      tokenType: payload.tokenType,
      user: {
        id: payload.sub,
        email: payload.email,
      },
    };
  }

  async disableTotp(
    authorizationHeader: string | undefined,
    dto: DisableTotpDto,
  ): Promise<{ message: string }> {
    const authenticatedUser = await this.getAuthenticatedUserFromHeader(
      authorizationHeader,
    );

    const signInResult = await this.signInWithPasswordWithTrimFallback(
      authenticatedUser.email,
      dto.password,
    );

    if (signInResult.error !== null) {
      throw new UnauthorizedException("Password verification failed");
    }

    const factor = await this.totpFactorRepository.findByUserId(
      authenticatedUser.id,
    );
    if (
      factor === null ||
      factor.isEnabled !== true ||
      factor.totpSecretCiphertext === null
    ) {
      throw new BadRequestException("Two-factor authentication is not enabled");
    }

    this.configureTotpAuthenticator();
    const activeSecret = this.decryptTotpSecret(factor.totpSecretCiphertext);
    const isValidCode = authenticator.check(
      dto.code.trim(),
      activeSecret,
    );
    if (!isValidCode) {
      throw new UnauthorizedException("Invalid authentication code");
    }

    await this.totpFactorRepository.disable(authenticatedUser.id);
    await this.totpRecoveryCodesRepository.clearAll(authenticatedUser.id);

    return {
      message: "Two-factor authentication disabled",
    };
  }

  async setMpin(
    authorizationHeader: string | undefined,
    dto: SetMpinDto,
  ): Promise<SetMpinResponse> {
    const authenticatedUser = await this.getAuthenticatedUserFromHeader(
      authorizationHeader,
    );

    const mpin = dto.mpin.trim();
    const confirmMpin = dto.confirmMpin.trim();
    const deviceId = dto.deviceId.trim();

    if (mpin !== confirmMpin) {
      throw new BadRequestException("MPIN confirmation does not match");
    }

    const mpinHash = await hash(
      this.buildMpinComparisonValue(authenticatedUser.id, deviceId, mpin),
      this.mpinBcryptRounds,
    );

    await this.userMpinRepository.upsert({
      userId: authenticatedUser.id,
      deviceId,
      mpinHash,
      failedAttempts: 0,
      lockedUntil: null,
      lastVerifiedAt: null,
    });

    return {
      message: "MPIN configured successfully",
    };
  }

  async verifyMpin(
    authorizationHeader: string | undefined,
    dto: VerifyMpinDto,
  ): Promise<VerifyMpinResponse> {
    const authenticatedUser = await this.getAuthenticatedUserFromHeader(
      authorizationHeader,
    );

    const mpin = dto.mpin.trim();
    const deviceId = dto.deviceId.trim();
    const record = await this.userMpinRepository.findByUserId(authenticatedUser.id);

    if (record === null) {
      throw new UnauthorizedException("MPIN is not configured for this account");
    }

    if (record.deviceId !== deviceId) {
      throw new UnauthorizedException(
        "MPIN login is only allowed on the registered device",
      );
    }

    const now = new Date();
    if (record.lockedUntil !== null && new Date(record.lockedUntil) > now) {
      throw new HttpException(
        {
          message: "MPIN is temporarily locked",
          lockedUntil: record.lockedUntil,
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    const isValid = await compare(
      this.buildMpinComparisonValue(authenticatedUser.id, deviceId, mpin),
      record.mpinHash,
    );

    if (!isValid) {
      const nextFailedAttempts = record.failedAttempts + 1;
      const shouldLock = nextFailedAttempts >= this.mpinMaxFailedAttempts;
      const lockedUntil = shouldLock
        ? this.addMinutes(now, this.mpinLockDurationMinutes).toISOString()
        : null;

      await this.userMpinRepository.updateFailureState(
        authenticatedUser.id,
        nextFailedAttempts,
        lockedUntil,
      );

      if (shouldLock) {
        throw new HttpException(
          {
            message: "MPIN is temporarily locked",
            lockedUntil,
          },
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }

      throw new UnauthorizedException(
        `Invalid MPIN. ${this.mpinMaxFailedAttempts - nextFailedAttempts} attempts remaining`,
      );
    }

    await this.userMpinRepository.markVerified(authenticatedUser.id);

    return {
      message: "MPIN verified successfully",
      remainingAttempts: this.mpinMaxFailedAttempts,
      lockedUntil: null,
    };
  }

  private normalizeEmail(email: string): string {
    return email.trim().toLowerCase();
  }

  private buildMpinComparisonValue(
    userId: string,
    deviceId: string,
    mpin: string,
  ): string {
    return `${userId}:${deviceId}:${mpin}`;
  }

  private generateOtpCode(): string {
    return randomInt(0, 1_000_000).toString().padStart(6, "0");
  }

  private hashOtp(email: string, otpCode: string): string {
    return createHash("sha256")
      .update(`${email}:${otpCode}:${this.otpHashSecret}`)
      .digest("hex");
  }

  private hashesMatch(left: string, right: string): boolean {
    const leftBuffer = Buffer.from(left);
    const rightBuffer = Buffer.from(right);

    if (leftBuffer.length !== rightBuffer.length) {
      return false;
    }

    return timingSafeEqual(leftBuffer, rightBuffer);
  }

  private addMinutes(date: Date, minutes: number): Date {
    return new Date(date.getTime() + minutes * 60_000);
  }

  private addSeconds(date: Date, seconds: number): Date {
    return new Date(date.getTime() + seconds * 1_000);
  }

  private isPasswordStrong(password: string): boolean {
    if (password.length < 8 || password.length > 20) {
      return false;
    }

    const hasUppercase = /[A-Z]/.test(password);
    const hasLowercase = /[a-z]/.test(password);
    const hasNumber = /\d/.test(password);
    return hasUppercase && hasLowercase && hasNumber;
  }

  private async verifyRegistrationToken(
    registrationToken: string,
  ): Promise<RegistrationTokenPayload> {
    try {
      const payload =
        await this.jwtService.verifyAsync<RegistrationTokenPayload>(
          registrationToken,
          {
            secret: this.registrationTokenSecret,
          },
        );

      if (payload.purpose !== "registration") {
        throw new UnauthorizedException("Invalid registration token purpose");
      }

      return payload;
    } catch {
      throw new UnauthorizedException("Invalid or expired registration token");
    }
  }

  private async verifyPasswordResetToken(
    passwordResetToken: string,
  ): Promise<PasswordResetTokenPayload> {
    try {
      const payload =
        await this.jwtService.verifyAsync<PasswordResetTokenPayload>(
          passwordResetToken,
          {
            secret: this.passwordResetTokenSecret,
          },
        );

      if (payload.purpose !== "password-reset") {
        throw new UnauthorizedException("Invalid password reset token purpose");
      }

      return payload;
    } catch {
      throw new UnauthorizedException(
        "Invalid or expired password reset token",
      );
    }
  }

  private async verifyMfaChallengeToken(
    mfaChallengeToken: string,
  ): Promise<MfaChallengeTokenPayload> {
    try {
      const payload = await this.jwtService.verifyAsync<MfaChallengeTokenPayload>(
        mfaChallengeToken,
        {
          secret: this.mfaChallengeTokenSecret,
        },
      );

      if (payload.purpose !== "mfa-challenge") {
        throw new UnauthorizedException("Invalid challenge token purpose");
      }

      return payload;
    } catch {
      throw new UnauthorizedException("Invalid or expired MFA challenge token");
    }
  }

  private async getAuthenticatedUserFromHeader(
    authorizationHeader: string | undefined,
  ): Promise<{ id: string; email: string }> {
    const accessToken = this.extractBearerToken(authorizationHeader);
    const { data, error } = await this.supabaseService.authClient.auth.getUser(
      accessToken,
    );

    if (error !== null || data.user === null) {
      throw new UnauthorizedException("Invalid or expired access token");
    }

    const email = data.user.email?.trim().toLowerCase() ?? "";
    if (email.length === 0) {
      throw new UnauthorizedException("Authenticated user email is unavailable");
    }

    return {
      id: data.user.id,
      email,
    };
  }

  private extractBearerToken(authorizationHeader: string | undefined): string {
    const value = authorizationHeader?.trim() ?? "";
    const prefix = "Bearer ";
    if (!value.startsWith(prefix)) {
      throw new UnauthorizedException("Missing bearer token");
    }

    const token = value.slice(prefix.length).trim();
    if (token.length === 0) {
      throw new UnauthorizedException("Missing bearer token");
    }

    return token;
  }

  private async signInWithPasswordWithTrimFallback(
    email: string,
    password: string,
  ): Promise<{
    data: {
      session: {
        access_token: string;
        refresh_token: string;
        expires_in: number;
        token_type: string;
      } | null;
      user: {
        id: string;
        email?: string | null;
      } | null;
    };
    error: { message: string } | null;
  }> {
    const primaryResult =
      await this.supabaseService.authClient.auth.signInWithPassword({
        email,
        password,
      });

    const firstErrorMessage = primaryResult.error?.message?.toLowerCase() ?? "";
    const trimmedPassword = password.trim();
    const shouldRetryWithTrimmed =
      primaryResult.error !== null &&
      firstErrorMessage.includes("invalid login credentials") &&
      trimmedPassword.length > 0 &&
      trimmedPassword !== password;

    if (!shouldRetryWithTrimmed) {
      return primaryResult as {
        data: {
          session: {
            access_token: string;
            refresh_token: string;
            expires_in: number;
            token_type: string;
          } | null;
          user: {
            id: string;
            email?: string | null;
          } | null;
        };
        error: { message: string } | null;
      };
    }

    return (await this.supabaseService.authClient.auth.signInWithPassword({
      email,
      password: trimmedPassword,
    })) as {
      data: {
        session: {
          access_token: string;
          refresh_token: string;
          expires_in: number;
          token_type: string;
        } | null;
        user: {
          id: string;
          email?: string | null;
        } | null;
      };
      error: { message: string } | null;
    };
  }

  private configureTotpAuthenticator(): void {
    authenticator.options = {
      ...authenticator.options,
      digits: 6,
      step: 30,
      window: [1, 1],
    };
  }

  private generateTotpSecret(): string {
    const randomSeed = randomBytes(20);
    const base32Secret = this.toBase32Rfc4648NoPadding(randomSeed);

    if (!/^[A-Z2-7]{16,}$/.test(base32Secret)) {
      throw new BadGatewayException("Unable to generate a valid authenticator secret");
    }

    return base32Secret;
  }

  private toBase32Rfc4648NoPadding(value: Buffer): string {
    const alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
    let bits = 0;
    let bitBuffer = 0;
    let output = "";

    for (const byte of value) {
      bitBuffer = (bitBuffer << 8) | byte;
      bits += 8;

      while (bits >= 5) {
        const index = (bitBuffer >> (bits - 5)) & 31;
        output += alphabet[index];
        bits -= 5;
      }
    }

    if (bits > 0) {
      const index = (bitBuffer << (5 - bits)) & 31;
      output += alphabet[index];
    }

    return output;
  }

  private generateRecoveryCodes(count: number): string[] {
    return Array.from({ length: count }, () => {
      const left = randomBytes(3).toString("hex").toUpperCase();
      const right = randomBytes(3).toString("hex").toUpperCase();
      return `${left}-${right}`;
    });
  }

  private hashRecoveryCode(userId: string, code: string): string {
    return createHash("sha256")
      .update(`${userId}:${code}:${this.otpHashSecret}`)
      .digest("hex");
  }

  private encryptTotpSecret(secret: string): string {
    const key = createHash("sha256")
      .update(this.totpSecretEncryptionKey)
      .digest();
    const iv = randomBytes(12);
    const cipher = createCipheriv("aes-256-gcm", key, iv);
    const encrypted = Buffer.concat([
      cipher.update(secret, "utf8"),
      cipher.final(),
    ]);
    const tag = cipher.getAuthTag();

    return `${iv.toString("base64")}:${tag.toString("base64")}:${encrypted.toString("base64")}`;
  }

  private decryptTotpSecret(ciphertext: string): string {
    const parts = ciphertext.split(":");
    if (parts.length !== 3) {
      throw new UnauthorizedException("Invalid TOTP secret payload");
    }

    const [ivBase64, tagBase64, encryptedBase64] = parts;
    const key = createHash("sha256")
      .update(this.totpSecretEncryptionKey)
      .digest();
    const decipher = createDecipheriv(
      "aes-256-gcm",
      key,
      Buffer.from(ivBase64, "base64"),
    );
    decipher.setAuthTag(Buffer.from(tagBase64, "base64"));

    const decrypted = Buffer.concat([
      decipher.update(Buffer.from(encryptedBase64, "base64")),
      decipher.final(),
    ]);

    return decrypted.toString("utf8");
  }

  private async findProfileIdByEmail(email: string): Promise<string | null> {
    const { data, error } = await this.supabaseService.adminClient
      .from("profiles")
      .select("id")
      .eq("email", email)
      .maybeSingle();

    if (error !== null) {
      this.logger.error("Failed to look up profile for auth user", {
        email,
        message: error.message,
      });
      throw new BadGatewayException("Unable to locate account profile");
    }

    const profile = data as { id: string } | null;
    return profile?.id ?? null;
  }

  private isSupabaseDuplicateUserError(message: string): boolean {
    const normalized = message.toLowerCase();
    return (
      normalized.includes("already registered") ||
      normalized.includes("already exists") ||
      normalized.includes("duplicate key")
    );
  }
}
