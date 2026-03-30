import {
  BadGatewayException,
  BadRequestException,
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
  LoginMfaRequiredResponse,
  LoginResponse,
  LoginResultResponse,
  MfaChallengeTokenPayload,
  TotpSetupStartResponse,
  TotpSetupVerifyResponse,
} from './auth.types';
import { DisableTotpDto } from './dto/disable-totp.dto';
import { LoginDto } from './dto/login.dto';
import { VerifyMfaBackupCodeDto } from './dto/verify-mfa-backup-code.dto';
import { VerifyMfaChallengeDto } from './dto/verify-mfa-challenge.dto';
import { VerifyTotpCodeDto } from './dto/verify-totp-code.dto';
import { TotpFactorRepository } from './totp-factor.repository';
import { TotpRecoveryCodesRepository } from './totp-recovery-codes.repository';
import { ProfileService } from './profile.service';

@Injectable()
export class LoginAuthService {
  private readonly logger = new Logger(LoginAuthService.name);

  constructor(
    private readonly jwtService: JwtService,
    private readonly totpFactorRepository: TotpFactorRepository,
    private readonly totpRecoveryCodesRepository: TotpRecoveryCodesRepository,
    private readonly profileService: ProfileService,
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

    const signInResult = await this.support.signInWithPasswordWithTrimFallback(
      authenticatedUser.email,
      dto.password,
    );

    if (signInResult.error !== null) {
      throw new UnauthorizedException('Password verification failed');
    }

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

    this.support.configureTotpAuthenticator();
    const activeSecret = this.support.decryptTotpSecret(
      factor.totpSecretCiphertext,
    );
    const isValidCode = authenticator.check(dto.code.trim(), activeSecret);
    if (!isValidCode) {
      throw new UnauthorizedException('Invalid authentication code');
    }

    await this.totpFactorRepository.disable(authenticatedUser.id);
    await this.totpRecoveryCodesRepository.clearAll(authenticatedUser.id);

    return {
      message: 'Two-factor authentication disabled',
    };
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
