import {
  BadGatewayException,
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { authenticator } from 'otplib';
import { AuthSettingsService } from './auth-settings.service';
import { AuthSupportService } from './auth-support.service';
import {
  PatientProfileResponse,
  RequestPasswordResetOtpResponse,
  LoginMfaRequiredResponse,
  LoginResponse,
  LoginResultResponse,
  MfaChallengeTokenPayload,
  SecuritySettingsStatusResponse,
  SecurityVerificationTokenPayload,
  VerifySecurityActionResponse,
  TotpSetupStartResponse,
  TotpSetupVerifyResponse,
} from './auth.types';
import { DisableTotpDto } from './dto/disable-totp.dto';
import { LoginDto } from './dto/login.dto';
import { GetSecuritySettingsStatusDto } from './dto/get-security-settings-status.dto';
import { RequestSecurityEmailOtpDto } from './dto/request-security-email-otp.dto';
import { VerifySecurityEmailOtpDto } from './dto/verify-security-email-otp.dto';
import { VerifyTotpForSecurityActionDto } from './dto/verify-totp-for-security-action.dto';
import { VerifyMpinChallengeDto } from './dto/verify-mpin-challenge.dto';
import { VerifyMfaBackupCodeDto } from './dto/verify-mfa-backup-code.dto';
import { VerifyMfaChallengeDto } from './dto/verify-mfa-challenge.dto';
import { VerifyTotpCodeDto } from './dto/verify-totp-code.dto';
import { TotpFactorRepository } from './totp-factor.repository';
import { TotpRecoveryCodesRepository } from './totp-recovery-codes.repository';
import { ProfileService } from './profile.service';
import { PasswordResetOtpRepository } from './password-reset-otp.repository';
import { MailerService } from '../mailer/mailer.service';
import { compare } from 'bcryptjs';
import { UserMpinDeviceRepository } from './user-mpin-device.repository';
import { UserMpinRepository } from './user-mpin.repository';

@Injectable()
export class LoginAuthService {
  private readonly logger = new Logger(LoginAuthService.name);

  constructor(
    private readonly jwtService: JwtService,
    private readonly totpFactorRepository: TotpFactorRepository,
    private readonly totpRecoveryCodesRepository: TotpRecoveryCodesRepository,
    private readonly profileService: ProfileService,
    private readonly userMpinRepository: UserMpinRepository,
    private readonly userMpinDeviceRepository: UserMpinDeviceRepository,
    private readonly passwordResetOtpRepository: PasswordResetOtpRepository,
    private readonly mailerService: MailerService,
    private readonly settings: AuthSettingsService,
    private readonly support: AuthSupportService,
  ) {}

  async login(dto: LoginDto): Promise<LoginResultResponse> {
    const normalizedEmail = this.support.normalizeEmail(dto.email);
    const signInResult = await this.support.signInWithPasswordWithTrimFallback(
      normalizedEmail,
      dto.password,
    );
    const { data, error } = signInResult;

    if (error !== null || data.session === null || data.user === null) {
      this.logger.error('Failed to sign in Supabase auth user', {
        email: normalizedEmail,
        message: error?.message ?? 'Missing session or user in response',
      });

      throw new UnauthorizedException(
        error?.message?.trim().length
          ? `Login failed: ${error.message}`
          : 'Invalid email or password',
      );
    }

    const session = data.session;
    const profile = await this.resolveProfile(
      data.user.id,
      data.user.email ?? normalizedEmail,
    );
    const factor = await this.totpFactorRepository.findByUserId(data.user.id);

    if (factor?.isEnabled === true) {
      if (
        factor.totpSecretCiphertext === null ||
        factor.totpSecretCiphertext.trim().length === 0
      ) {
        this.logger.error('2FA is enabled but no active secret is available', {
          userId: data.user.id,
        });
        throw new BadGatewayException('Unable to complete login challenge');
      }

      const challengeToken = await this.jwtService.signAsync(
        {
          sub: data.user.id,
          purpose: 'mfa-challenge',
          email: data.user.email ?? normalizedEmail,
          accessToken: session.access_token,
          refreshToken: session.refresh_token,
          expiresIn: session.expires_in,
          tokenType: session.token_type,
        } satisfies Omit<MfaChallengeTokenPayload, 'iat' | 'exp'>,
        {
          secret: this.settings.mfaChallengeTokenSecret,
          expiresIn: `${this.settings.mfaChallengeTokenTtlSeconds}s`,
        },
      );

      return {
        mfaRequired: true,
        mfaChallengeToken: challengeToken,
        expiresInSeconds: this.settings.mfaChallengeTokenTtlSeconds,
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
        profile,
      },
    };
  }

  async startTotpSetup(
    authorizationHeader: string | undefined,
  ): Promise<TotpSetupStartResponse> {
    const authenticatedUser =
      await this.support.getAuthenticatedUserFromHeader(authorizationHeader);

    this.support.configureTotpAuthenticator();
    const secret = this.support.generateTotpSecret();

    const encryptedSecret = this.support.encryptTotpSecret(secret);
    await this.totpFactorRepository.upsertTempSecret(
      authenticatedUser.id,
      encryptedSecret,
    );

    const encodedAccount = encodeURIComponent(authenticatedUser.email);
    const encodedIssuer = encodeURIComponent(this.settings.totpIssuer);
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
    const authenticatedUser =
      await this.support.getAuthenticatedUserFromHeader(authorizationHeader);
    const factor = await this.totpFactorRepository.findByUserId(
      authenticatedUser.id,
    );

    const temporarySecretCiphertext = factor?.totpSecretTempCiphertext ?? '';
    if (temporarySecretCiphertext.trim().length === 0) {
      throw new BadRequestException('No pending 2FA setup was found');
    }

    const temporarySecret = this.support.decryptTotpSecret(
      temporarySecretCiphertext,
    );

    this.support.configureTotpAuthenticator();
    const isValidCode = authenticator.check(dto.code.trim(), temporarySecret);
    if (!isValidCode) {
      throw new UnauthorizedException('Invalid authentication code');
    }

    await this.totpFactorRepository.enableWithActiveSecret(
      authenticatedUser.id,
      temporarySecretCiphertext,
    );

    const recoveryCodes = this.support.generateRecoveryCodes(
      this.settings.totpRecoveryCodesCount,
    );
    const recoveryCodeHashes = recoveryCodes.map((code) =>
      this.support.hashRecoveryCode(authenticatedUser.id, code),
    );
    await this.totpRecoveryCodesRepository.replaceCodes(
      authenticatedUser.id,
      recoveryCodeHashes,
    );

    return {
      message: 'Two-factor authentication enabled',
      recoveryCodes,
    };
  }

  async verifyMfaChallenge(dto: VerifyMfaChallengeDto): Promise<LoginResponse> {
    const payload = await this.support.verifyMfaChallengeToken(
      dto.mfaChallengeToken,
    );
    const factor = await this.totpFactorRepository.findByUserId(payload.sub);

    if (
      factor === null ||
      factor.isEnabled !== true ||
      factor.totpSecretCiphertext === null
    ) {
      throw new UnauthorizedException(
        'Two-factor authentication is not enabled',
      );
    }

    this.support.configureTotpAuthenticator();
    const activeSecret = this.support.decryptTotpSecret(
      factor.totpSecretCiphertext,
    );
    const isValidCode = authenticator.check(dto.code.trim(), activeSecret);
    if (!isValidCode) {
      throw new UnauthorizedException('Invalid authentication code');
    }

    const profile = await this.resolveProfile(payload.sub, payload.email);

    return {
      accessToken: payload.accessToken,
      refreshToken: payload.refreshToken,
      expiresIn: payload.expiresIn,
      tokenType: payload.tokenType,
      user: {
        id: payload.sub,
        email: payload.email,
        profile,
      },
    };
  }

  async verifyMfaBackupCode(
    dto: VerifyMfaBackupCodeDto,
  ): Promise<LoginResponse> {
    const payload = await this.support.verifyMfaChallengeToken(
      dto.mfaChallengeToken,
    );
    const normalizedCode = dto.backupCode.trim().toUpperCase();
    if (normalizedCode.length === 0) {
      throw new UnauthorizedException('Invalid backup code');
    }

    const codeHash = this.support.hashRecoveryCode(payload.sub, normalizedCode);
    const consumed = await this.totpRecoveryCodesRepository.consumeCodeHash(
      payload.sub,
      codeHash,
    );

    if (!consumed) {
      throw new UnauthorizedException('Invalid backup code');
    }

    const profile = await this.resolveProfile(payload.sub, payload.email);

    return {
      accessToken: payload.accessToken,
      refreshToken: payload.refreshToken,
      expiresIn: payload.expiresIn,
      tokenType: payload.tokenType,
      user: {
        id: payload.sub,
        email: payload.email,
        profile,
      },
    };
  }

  async disableTotp(
    authorizationHeader: string | undefined,
    dto: DisableTotpDto,
  ): Promise<{ message: string }> {
    const authenticatedUser =
      await this.support.getAuthenticatedUserFromHeader(authorizationHeader);
    await this.verifySecurityTokenForUser(
      authenticatedUser.id,
      dto.securityVerificationToken,
    );

    const factor = await this.totpFactorRepository.findByUserId(
      authenticatedUser.id,
    );
    if (
      factor === null ||
      factor.isEnabled !== true ||
      factor.totpSecretCiphertext === null
    ) {
      throw new BadRequestException('Two-factor authentication is not enabled');
    }

    await this.totpFactorRepository.disable(authenticatedUser.id);
    await this.totpRecoveryCodesRepository.clearAll(authenticatedUser.id);

    return {
      message: 'Two-factor authentication disabled',
    };
  }

  async getSecuritySettingsStatus(
    authorizationHeader: string | undefined,
    dto: GetSecuritySettingsStatusDto,
  ): Promise<SecuritySettingsStatusResponse> {
    const authenticatedUser =
      await this.support.getAuthenticatedUserFromHeader(authorizationHeader);
    const deviceId = dto.deviceId.trim();
    const [factor, mpinRecord, deviceRecord] = await Promise.all([
      this.totpFactorRepository.findByUserId(authenticatedUser.id),
      this.userMpinRepository.findByUserId(authenticatedUser.id),
      this.userMpinDeviceRepository.findByUserId(authenticatedUser.id),
    ]);

    return {
      isTotpEnabled: factor?.isEnabled === true,
      isMpinConfigured: mpinRecord !== null,
      isMpinDeviceRegistered:
        deviceId.length > 0 &&
        deviceRecord !== null &&
        deviceRecord.deviceId === deviceId,
    };
  }

  async verifyMpinChallenge(
    dto: VerifyMpinChallengeDto,
  ): Promise<LoginResponse> {
    const payload = await this.support.verifyMfaChallengeToken(
      dto.mfaChallengeToken,
    );
    const deviceId = dto.deviceId.trim();
    const mpin = dto.mpin.trim();

    const [mpinRecord, deviceRecord] = await Promise.all([
      this.userMpinRepository.findByUserId(payload.sub),
      this.userMpinDeviceRepository.findByUserId(payload.sub),
    ]);

    if (mpinRecord === null) {
      throw new UnauthorizedException(
        'MPIN is not configured for this account',
      );
    }

    if (deviceRecord === null || deviceRecord.deviceId !== deviceId) {
      throw new UnauthorizedException(
        'MPIN login is only allowed on the registered device',
      );
    }

    const now = new Date();
    if (
      mpinRecord.lockedUntil !== null &&
      new Date(mpinRecord.lockedUntil) > now
    ) {
      throw new HttpException(
        {
          message: 'MPIN is temporarily locked',
          lockedUntil: mpinRecord.lockedUntil,
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    const isValid = await compare(
      this.support.buildMpinComparisonValue(payload.sub, mpin),
      mpinRecord.mpinHash,
    );

    if (!isValid) {
      const nextFailedAttempts = mpinRecord.failedAttempts + 1;
      const shouldLock =
        nextFailedAttempts >= this.settings.mpinMaxFailedAttempts;
      const lockedUntil = shouldLock
        ? this.support
            .addMinutes(now, this.settings.mpinLockDurationMinutes)
            .toISOString()
        : null;

      await this.userMpinRepository.updateFailureState(
        payload.sub,
        nextFailedAttempts,
        lockedUntil,
      );

      if (shouldLock) {
        throw new HttpException(
          {
            message: 'MPIN is temporarily locked',
            lockedUntil,
          },
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }

      throw new UnauthorizedException(
        `Invalid MPIN. ${this.settings.mpinMaxFailedAttempts - nextFailedAttempts} attempts remaining`,
      );
    }

    await this.userMpinRepository.markVerified(payload.sub);
    const profile = await this.resolveProfile(payload.sub, payload.email);

    return {
      accessToken: payload.accessToken,
      refreshToken: payload.refreshToken,
      expiresIn: payload.expiresIn,
      tokenType: payload.tokenType,
      user: {
        id: payload.sub,
        email: payload.email,
        profile,
      },
    };
  }

  async verifyTotpForSecurityAction(
    dto: VerifyTotpForSecurityActionDto,
  ): Promise<VerifySecurityActionResponse> {
    const payload = await this.verifyAndReadAccessToken(dto.accessToken);
    const factor = await this.totpFactorRepository.findByUserId(payload.sub);

    if (
      factor === null ||
      factor.isEnabled !== true ||
      factor.totpSecretCiphertext === null
    ) {
      throw new UnauthorizedException(
        'Two-factor authentication is not enabled',
      );
    }

    this.support.configureTotpAuthenticator();
    const activeSecret = this.support.decryptTotpSecret(
      factor.totpSecretCiphertext,
    );
    const isValidCode = authenticator.check(dto.code.trim(), activeSecret);
    if (!isValidCode) {
      throw new UnauthorizedException('Invalid authentication code');
    }

    const securityVerificationToken = await this.jwtService.signAsync(
      {
        sub: payload.sub,
        purpose: 'security-verification',
      } satisfies Omit<SecurityVerificationTokenPayload, 'iat' | 'exp'>,
      {
        secret: this.settings.securityVerificationTokenSecret,
        expiresIn: `${this.settings.securityVerificationTokenTtlSeconds}s`,
      },
    );

    return {
      message: 'Verification successful',
      securityVerificationToken,
      expiresInSeconds: this.settings.securityVerificationTokenTtlSeconds,
    };
  }

  async requestSecurityEmailOtp(
    dto: RequestSecurityEmailOtpDto,
  ): Promise<RequestPasswordResetOtpResponse> {
    const normalizedEmail = this.support.normalizeEmail(dto.email);
    const existingRecord =
      await this.passwordResetOtpRepository.findByEmail(normalizedEmail);
    const now = new Date();

    if (existingRecord !== null) {
      const nextAllowedAt = this.support.addSeconds(
        new Date(existingRecord.lastSentAt),
        this.settings.otpResendCooldownSeconds,
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

    const otpCode = this.support.generateOtpCode();
    const hashedOtp = this.support.hashOtp(normalizedEmail, otpCode);
    const expiresAt = this.support
      .addMinutes(now, this.settings.otpTtlMinutes)
      .toISOString();

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
        expiresInMinutes: this.settings.otpTtlMinutes,
      });
    } catch (error) {
      await this.passwordResetOtpRepository.deleteByEmail(normalizedEmail);
      throw error;
    }

    return {
      message: 'Verification code sent',
      cooldownSeconds: this.settings.otpResendCooldownSeconds,
    };
  }

  async verifySecurityEmailOtp(
    dto: VerifySecurityEmailOtpDto,
  ): Promise<VerifySecurityActionResponse> {
    const normalizedEmail = this.support.normalizeEmail(dto.email);
    const record =
      await this.passwordResetOtpRepository.findByEmail(normalizedEmail);
    if (record === null) {
      throw new BadRequestException(
        'Verification code request not found for this email',
      );
    }

    if (new Date(record.expiresAt) <= new Date()) {
      await this.passwordResetOtpRepository.deleteByEmail(normalizedEmail);
      throw new BadRequestException(
        'Verification code expired, please request a new code',
      );
    }

    if (record.failedAttempts >= this.settings.otpMaxAttempts) {
      await this.passwordResetOtpRepository.deleteByEmail(normalizedEmail);
      throw new UnauthorizedException(
        'Maximum verification attempts reached, request a new code',
      );
    }

    const expectedHash = this.support.hashOtp(
      normalizedEmail,
      dto.otpCode.trim(),
    );
    if (!this.support.hashesMatch(record.codeHash, expectedHash)) {
      const updatedAttempts = record.failedAttempts + 1;
      await this.passwordResetOtpRepository.incrementFailedAttempts(
        normalizedEmail,
        updatedAttempts,
      );

      if (updatedAttempts >= this.settings.otpMaxAttempts) {
        throw new UnauthorizedException(
          'Maximum verification attempts reached, request a new code',
        );
      }

      throw new UnauthorizedException('Invalid verification code');
    }

    const profileUserId =
      await this.support.findProfileIdByEmail(normalizedEmail);
    if (profileUserId === null) {
      throw new UnauthorizedException('Account was not found');
    }

    const securityVerificationToken = await this.jwtService.signAsync(
      {
        sub: profileUserId,
        purpose: 'security-verification',
      } satisfies Omit<SecurityVerificationTokenPayload, 'iat' | 'exp'>,
      {
        secret: this.settings.securityVerificationTokenSecret,
        expiresIn: `${this.settings.securityVerificationTokenTtlSeconds}s`,
      },
    );

    await this.passwordResetOtpRepository.deleteByEmail(normalizedEmail);
    return {
      message: 'Verification successful',
      securityVerificationToken,
      expiresInSeconds: this.settings.securityVerificationTokenTtlSeconds,
    };
  }

  private async verifyAndReadAccessToken(
    accessToken: string,
  ): Promise<{ sub: string }> {
    const authenticatedUser =
      await this.support.getAuthenticatedUserFromAccessToken(accessToken);
    return { sub: authenticatedUser.id };
  }

  private async verifySecurityTokenForUser(
    userId: string,
    token: string,
  ): Promise<void> {
    const payload = await this.support.verifySecurityVerificationToken(token);
    if (payload.sub !== userId) {
      throw new UnauthorizedException('Security verification token is invalid');
    }
  }

  private async resolveProfile(
    userId: string,
    email: string,
  ): Promise<PatientProfileResponse> {
    try {
      return await this.profileService.getProfileResponse(userId, email);
    } catch (error) {
      this.logger.warn('Falling back to an empty profile snapshot', {
        userId,
        email,
      });
      return {
        givenNames: [],
        familyName: '',
        displayName: '',
      };
    }
  }
}
