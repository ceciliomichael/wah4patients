import {
  BadGatewayException,
  BadRequestException,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  UnauthorizedException,
} from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { MailerService } from "../mailer/mailer.service";
import { SupabaseService } from "../supabase/supabase.service";
import { AuthSettingsService } from "./auth-settings.service";
import { AuthSupportService } from "./auth-support.service";
import {
  CompletePasswordResetResponse,
  PasswordResetTokenPayload,
  RequestPasswordResetOtpResponse,
  VerifyPasswordResetOtpResponse,
} from "./auth.types";
import { CompletePasswordResetDto } from "./dto/complete-password-reset.dto";
import { RequestPasswordResetOtpDto } from "./dto/request-password-reset-otp.dto";
import { VerifyPasswordResetOtpDto } from "./dto/verify-password-reset-otp.dto";
import { PasswordResetOtpRepository } from "./password-reset-otp.repository";

@Injectable()
export class PasswordResetAuthService {
  private readonly logger = new Logger(PasswordResetAuthService.name);

  constructor(
    private readonly jwtService: JwtService,
    private readonly mailerService: MailerService,
    private readonly supabaseService: SupabaseService,
    private readonly passwordResetOtpRepository: PasswordResetOtpRepository,
    private readonly settings: AuthSettingsService,
    private readonly support: AuthSupportService,
  ) {}

  async requestPasswordResetOtp(
    dto: RequestPasswordResetOtpDto,
  ): Promise<RequestPasswordResetOtpResponse> {
    const normalizedEmail = this.support.normalizeEmail(dto.email);
    const profileId = await this.support.findProfileIdByEmail(normalizedEmail);

    if (profileId === null) {
      const existingRecord =
        await this.passwordResetOtpRepository.findByEmail(normalizedEmail);
      if (existingRecord !== null) {
        await this.passwordResetOtpRepository.deleteByEmail(normalizedEmail);
      }

      return {
        message: "If an account exists, a password reset code has been sent",
        cooldownSeconds: this.settings.otpResendCooldownSeconds,
      };
    }

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
      message: "If an account exists, a password reset code has been sent",
      cooldownSeconds: this.settings.otpResendCooldownSeconds,
    };
  }

  async verifyPasswordResetOtp(
    dto: VerifyPasswordResetOtpDto,
  ): Promise<VerifyPasswordResetOtpResponse> {
    const normalizedEmail = this.support.normalizeEmail(dto.email);
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

    if (record.failedAttempts >= this.settings.otpMaxAttempts) {
      await this.passwordResetOtpRepository.deleteByEmail(normalizedEmail);
      throw new UnauthorizedException(
        "Maximum verification attempts reached, request a new code",
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
        secret: this.settings.passwordResetTokenSecret,
        expiresIn: `${this.settings.passwordResetTokenTtlSeconds}s`,
      },
    );

    return {
      message: "Email verified successfully",
      passwordResetToken,
      expiresInSeconds: this.settings.passwordResetTokenTtlSeconds,
    };
  }

  async completePasswordReset(
    dto: CompletePasswordResetDto,
  ): Promise<CompletePasswordResetResponse> {
    const normalizedEmail = this.support.normalizeEmail(dto.email);
    const password = dto.password;

    if (!this.support.isPasswordStrong(password)) {
      throw new BadRequestException(
        "Password must include uppercase, lowercase, and at least one number",
      );
    }

    const tokenPayload = await this.support.verifyPasswordResetToken(
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

    const userId = await this.support.findProfileIdByEmail(normalizedEmail);
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
}
