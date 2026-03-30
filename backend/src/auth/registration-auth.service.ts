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
import { JwtService } from "@nestjs/jwt";
import { MailerService } from "../mailer/mailer.service";
import { SupabaseService } from "../supabase/supabase.service";
import { AuthSettingsService } from "./auth-settings.service";
import { AuthSupportService } from "./auth-support.service";
import {
  CompleteRegistrationResponse,
  RegistrationTokenPayload,
  RequestOtpResponse,
  VerifyOtpResponse,
} from "./auth.types";
import { CompleteRegistrationDto } from "./dto/complete-registration.dto";
import { RequestRegistrationOtpDto } from "./dto/request-registration-otp.dto";
import { VerifyRegistrationOtpDto } from "./dto/verify-registration-otp.dto";
import { RegistrationOtpRepository } from "./registration-otp.repository";

@Injectable()
export class RegistrationAuthService {
  private readonly logger = new Logger(RegistrationAuthService.name);

  constructor(
    private readonly jwtService: JwtService,
    private readonly mailerService: MailerService,
    private readonly supabaseService: SupabaseService,
    private readonly registrationOtpRepository: RegistrationOtpRepository,
    private readonly settings: AuthSettingsService,
    private readonly support: AuthSupportService,
  ) {}

  async requestRegistrationOtp(
    dto: RequestRegistrationOtpDto,
  ): Promise<RequestOtpResponse> {
    const normalizedEmail = this.support.normalizeEmail(dto.email);
    const existingRecord =
      await this.registrationOtpRepository.findByEmail(normalizedEmail);
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
        expiresInMinutes: this.settings.otpTtlMinutes,
      });
    } catch (error) {
      await this.registrationOtpRepository.deleteByEmail(normalizedEmail);
      throw error;
    }

    return {
      message: "Verification code sent",
      cooldownSeconds: this.settings.otpResendCooldownSeconds,
    };
  }

  async verifyRegistrationOtp(
    dto: VerifyRegistrationOtpDto,
  ): Promise<VerifyOtpResponse> {
    const normalizedEmail = this.support.normalizeEmail(dto.email);
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

    if (record.failedAttempts >= this.settings.otpMaxAttempts) {
      await this.registrationOtpRepository.deleteByEmail(normalizedEmail);
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
      await this.registrationOtpRepository.incrementFailedAttempts(
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
        secret: this.settings.registrationTokenSecret,
        expiresIn: `${this.settings.registrationTokenTtlSeconds}s`,
      },
    );

    return {
      message: "Email verified successfully",
      registrationToken,
      expiresInSeconds: this.settings.registrationTokenTtlSeconds,
    };
  }

  async completeRegistration(
    dto: CompleteRegistrationDto,
  ): Promise<CompleteRegistrationResponse> {
    const normalizedEmail = this.support.normalizeEmail(dto.email);
    const password = dto.password;

    if (!this.support.isPasswordStrong(password)) {
      throw new BadRequestException(
        "Password must include uppercase, lowercase, and at least one number",
      );
    }

    const tokenPayload = await this.support.verifyRegistrationToken(
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

      if (this.support.isSupabaseDuplicateUserError(error.message)) {
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
}
