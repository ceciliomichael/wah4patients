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
import { createHash, randomInt, timingSafeEqual } from "node:crypto";
import { MailerService } from "../mailer/mailer.service";
import { SupabaseService } from "../supabase/supabase.service";
import { CompletePasswordResetDto } from "./dto/complete-password-reset.dto";
import { CompleteRegistrationDto } from "./dto/complete-registration.dto";
import { LoginDto } from "./dto/login.dto";
import { RequestPasswordResetOtpDto } from "./dto/request-password-reset-otp.dto";
import { RequestRegistrationOtpDto } from "./dto/request-registration-otp.dto";
import { VerifyPasswordResetOtpDto } from "./dto/verify-password-reset-otp.dto";
import { VerifyRegistrationOtpDto } from "./dto/verify-registration-otp.dto";
import {
  CompletePasswordResetResponse,
  CompleteRegistrationResponse,
  LoginResponse,
  PasswordResetTokenPayload,
  RegistrationTokenPayload,
  RequestOtpResponse,
  RequestPasswordResetOtpResponse,
  VerifyOtpResponse,
  VerifyPasswordResetOtpResponse,
} from "./auth.types";
import { PasswordResetOtpRepository } from "./password-reset-otp.repository";
import { RegistrationOtpRepository } from "./registration-otp.repository";

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

  constructor(
    private readonly configService: ConfigService,
    private readonly jwtService: JwtService,
    private readonly mailerService: MailerService,
    private readonly supabaseService: SupabaseService,
    private readonly registrationOtpRepository: RegistrationOtpRepository,
    private readonly passwordResetOtpRepository: PasswordResetOtpRepository,
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

  async login(dto: LoginDto): Promise<LoginResponse> {
    const normalizedEmail = this.normalizeEmail(dto.email);
    const password = dto.password;

    const { data, error } =
      await this.supabaseService.authClient.auth.signInWithPassword({
        email: normalizedEmail,
        password,
      });

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

  private normalizeEmail(email: string): string {
    return email.trim().toLowerCase();
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
