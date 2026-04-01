import {
  BadGatewayException,
  Injectable,
  Logger,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { authenticator } from 'otplib';
import {
  createCipheriv,
  createDecipheriv,
  createHash,
  randomBytes,
  randomInt,
  timingSafeEqual,
} from 'node:crypto';
import { AuthSettingsService } from './auth-settings.service';
import {
  MfaChallengeTokenPayload,
  PasswordResetTokenPayload,
  RegistrationTokenPayload,
  SecurityVerificationTokenPayload,
} from './auth.types';
import { SupabaseService } from '../supabase/supabase.service';

export interface PasswordSignInResult {
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
}

export interface RefreshSessionResult {
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
}

@Injectable()
export class AuthSupportService {
  private readonly logger = new Logger(AuthSupportService.name);

  constructor(
    private readonly settings: AuthSettingsService,
    private readonly jwtService: JwtService,
    private readonly supabaseService: SupabaseService,
  ) {}

  normalizeEmail(email: string): string {
    return email.trim().toLowerCase();
  }

  buildMpinComparisonValue(userId: string, mpin: string): string {
    return `${userId}:${mpin}`;
  }

  generateOtpCode(): string {
    return randomInt(0, 1_000_000).toString().padStart(6, '0');
  }

  hashOtp(email: string, otpCode: string): string {
    return createHash('sha256')
      .update(`${email}:${otpCode}:${this.settings.otpHashSecret}`)
      .digest('hex');
  }

  hashesMatch(left: string, right: string): boolean {
    const leftBuffer = Buffer.from(left);
    const rightBuffer = Buffer.from(right);

    if (leftBuffer.length !== rightBuffer.length) {
      return false;
    }

    return timingSafeEqual(leftBuffer, rightBuffer);
  }

  addMinutes(date: Date, minutes: number): Date {
    return new Date(date.getTime() + minutes * 60_000);
  }

  addSeconds(date: Date, seconds: number): Date {
    return new Date(date.getTime() + seconds * 1_000);
  }

  isPasswordStrong(password: string): boolean {
    if (password.length < 8 || password.length > 20) {
      return false;
    }

    const hasUppercase = /[A-Z]/.test(password);
    const hasLowercase = /[a-z]/.test(password);
    const hasNumber = /\d/.test(password);
    return hasUppercase && hasLowercase && hasNumber;
  }

  async verifyRegistrationToken(
    registrationToken: string,
  ): Promise<RegistrationTokenPayload> {
    try {
      const payload =
        await this.jwtService.verifyAsync<RegistrationTokenPayload>(
          registrationToken,
          {
            secret: this.settings.registrationTokenSecret,
          },
        );

      if (payload.purpose !== 'registration') {
        throw new UnauthorizedException('Invalid registration token purpose');
      }

      return payload;
    } catch {
      throw new UnauthorizedException('Invalid or expired registration token');
    }
  }

  async verifyPasswordResetToken(
    passwordResetToken: string,
  ): Promise<PasswordResetTokenPayload> {
    try {
      const payload =
        await this.jwtService.verifyAsync<PasswordResetTokenPayload>(
          passwordResetToken,
          {
            secret: this.settings.passwordResetTokenSecret,
          },
        );

      if (payload.purpose !== 'password-reset') {
        throw new UnauthorizedException('Invalid password reset token purpose');
      }

      return payload;
    } catch {
      throw new UnauthorizedException(
        'Invalid or expired password reset token',
      );
    }
  }

  async verifyMfaChallengeToken(
    mfaChallengeToken: string,
  ): Promise<MfaChallengeTokenPayload> {
    try {
      const payload =
        await this.jwtService.verifyAsync<MfaChallengeTokenPayload>(
          mfaChallengeToken,
          {
            secret: this.settings.mfaChallengeTokenSecret,
          },
        );

      if (payload.purpose !== 'mfa-challenge') {
        throw new UnauthorizedException('Invalid challenge token purpose');
      }

      return payload;
    } catch {
      throw new UnauthorizedException('Invalid or expired MFA challenge token');
    }
  }

  async verifySecurityVerificationToken(
    token: string,
  ): Promise<SecurityVerificationTokenPayload> {
    try {
      const payload =
        await this.jwtService.verifyAsync<SecurityVerificationTokenPayload>(
          token,
          {
            secret: this.settings.securityVerificationTokenSecret,
          },
        );

      if (payload.purpose !== 'security-verification') {
        throw new UnauthorizedException('Invalid security token purpose');
      }

      return payload;
    } catch {
      throw new UnauthorizedException('Invalid or expired security token');
    }
  }

  async getAuthenticatedUserFromHeader(
    authorizationHeader: string | undefined,
  ): Promise<{ id: string; email: string }> {
    const accessToken = this.extractBearerToken(authorizationHeader);
    return this.getAuthenticatedUserFromAccessToken(accessToken);
  }

  async getAuthenticatedUserFromAccessToken(
    accessToken: string,
  ): Promise<{ id: string; email: string }> {
    const { data, error } =
      await this.supabaseService.authClient.auth.getUser(accessToken);

    if (error !== null || data.user === null) {
      throw new UnauthorizedException('Invalid or expired access token');
    }

    const email = data.user.email?.trim().toLowerCase() ?? '';
    if (email.length === 0) {
      throw new UnauthorizedException(
        'Authenticated user email is unavailable',
      );
    }

    return {
      id: data.user.id,
      email,
    };
  }

  extractBearerToken(authorizationHeader: string | undefined): string {
    const value = authorizationHeader?.trim() ?? '';
    const prefix = 'Bearer ';
    if (!value.startsWith(prefix)) {
      throw new UnauthorizedException('Missing bearer token');
    }

    const token = value.slice(prefix.length).trim();
    if (token.length === 0) {
      throw new UnauthorizedException('Missing bearer token');
    }

    return token;
  }

  async signInWithPasswordWithTrimFallback(
    email: string,
    password: string,
  ): Promise<PasswordSignInResult> {
    const primaryResult =
      await this.supabaseService.authClient.auth.signInWithPassword({
        email,
        password,
      });

    const firstErrorMessage = primaryResult.error?.message?.toLowerCase() ?? '';
    const trimmedPassword = password.trim();
    const shouldRetryWithTrimmed =
      primaryResult.error !== null &&
      firstErrorMessage.includes('invalid login credentials') &&
      trimmedPassword.length > 0 &&
      trimmedPassword !== password;

    if (!shouldRetryWithTrimmed) {
      return primaryResult as PasswordSignInResult;
    }

    return (await this.supabaseService.authClient.auth.signInWithPassword({
      email,
      password: trimmedPassword,
    })) as PasswordSignInResult;
  }

  async refreshSession(refreshToken: string): Promise<RefreshSessionResult> {
    return (await this.supabaseService.authClient.auth.refreshSession({
      refresh_token: refreshToken,
    })) as RefreshSessionResult;
  }

  configureTotpAuthenticator(): void {
    authenticator.options = {
      ...authenticator.options,
      digits: 6,
      step: 30,
      window: [1, 1],
    };
  }

  generateTotpSecret(): string {
    const randomSeed = randomBytes(20);
    const base32Secret = this.toBase32Rfc4648NoPadding(randomSeed);

    if (!/^[A-Z2-7]{16,}$/.test(base32Secret)) {
      throw new BadGatewayException(
        'Unable to generate a valid authenticator secret',
      );
    }

    return base32Secret;
  }

  private toBase32Rfc4648NoPadding(value: Buffer): string {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    let bits = 0;
    let bitBuffer = 0;
    let output = '';

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

  generateRecoveryCodes(count: number): string[] {
    return Array.from({ length: count }, () => {
      const left = randomBytes(3).toString('hex').toUpperCase();
      const right = randomBytes(3).toString('hex').toUpperCase();
      return `${left}-${right}`;
    });
  }

  hashRecoveryCode(userId: string, code: string): string {
    return createHash('sha256')
      .update(`${userId}:${code}:${this.settings.otpHashSecret}`)
      .digest('hex');
  }

  encryptTotpSecret(secret: string): string {
    const key = createHash('sha256')
      .update(this.settings.totpSecretEncryptionKey)
      .digest();
    const iv = randomBytes(12);
    const cipher = createCipheriv('aes-256-gcm', key, iv);
    const encrypted = Buffer.concat([
      cipher.update(secret, 'utf8'),
      cipher.final(),
    ]);
    const tag = cipher.getAuthTag();

    return `${iv.toString('base64')}:${tag.toString('base64')}:${encrypted.toString('base64')}`;
  }

  decryptTotpSecret(ciphertext: string): string {
    const parts = ciphertext.split(':');
    if (parts.length !== 3) {
      throw new UnauthorizedException('Invalid TOTP secret payload');
    }

    const [ivBase64, tagBase64, encryptedBase64] = parts;
    const key = createHash('sha256')
      .update(this.settings.totpSecretEncryptionKey)
      .digest();
    const decipher = createDecipheriv(
      'aes-256-gcm',
      key,
      Buffer.from(ivBase64, 'base64'),
    );
    decipher.setAuthTag(Buffer.from(tagBase64, 'base64'));

    const decrypted = Buffer.concat([
      decipher.update(Buffer.from(encryptedBase64, 'base64')),
      decipher.final(),
    ]);

    return decrypted.toString('utf8');
  }

  async findProfileIdByEmail(email: string): Promise<string | null> {
    const { data, error } = await this.supabaseService.adminClient
      .from('profiles')
      .select('id')
      .eq('email', email)
      .maybeSingle();

    if (error !== null) {
      this.logger.error('Failed to look up profile for auth user', {
        email,
        message: error.message,
      });
      throw new BadGatewayException('Unable to locate account profile');
    }

    const profile = data as { id: string } | null;
    return profile?.id ?? null;
  }

  isSupabaseDuplicateUserError(message: string): boolean {
    const normalized = message.toLowerCase();
    return (
      normalized.includes('already registered') ||
      normalized.includes('already exists') ||
      normalized.includes('duplicate key')
    );
  }
}
