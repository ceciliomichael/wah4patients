import { Body, Controller, HttpCode, HttpStatus, Post } from "@nestjs/common";
import { Throttle } from "@nestjs/throttler";
import { AuthService } from "./auth.service";
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
  RequestOtpResponse,
  RequestPasswordResetOtpResponse,
  VerifyOtpResponse,
  VerifyPasswordResetOtpResponse,
} from "./auth.types";

@Controller("auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post("register/request-otp")
  @Throttle({ default: { ttl: 60_000, limit: 5 } })
  requestRegistrationOtp(
    @Body() dto: RequestRegistrationOtpDto,
  ): Promise<RequestOtpResponse> {
    return this.authService.requestRegistrationOtp(dto);
  }

  @Post("register/resend-otp")
  @Throttle({ default: { ttl: 60_000, limit: 5 } })
  resendRegistrationOtp(
    @Body() dto: RequestRegistrationOtpDto,
  ): Promise<RequestOtpResponse> {
    return this.authService.requestRegistrationOtp(dto);
  }

  @Post("register/verify-otp")
  @Throttle({ default: { ttl: 60_000, limit: 6 } })
  verifyRegistrationOtp(
    @Body() dto: VerifyRegistrationOtpDto,
  ): Promise<VerifyOtpResponse> {
    return this.authService.verifyRegistrationOtp(dto);
  }

  @Post("register/complete")
  @Throttle({ default: { ttl: 60_000, limit: 5 } })
  completeRegistration(
    @Body() dto: CompleteRegistrationDto,
  ): Promise<CompleteRegistrationResponse> {
    return this.authService.completeRegistration(dto);
  }

  @Post("password-reset/request-otp")
  @Throttle({ default: { ttl: 60_000, limit: 5 } })
  requestPasswordResetOtp(
    @Body() dto: RequestPasswordResetOtpDto,
  ): Promise<RequestPasswordResetOtpResponse> {
    return this.authService.requestPasswordResetOtp(dto);
  }

  @Post("password-reset/resend-otp")
  @Throttle({ default: { ttl: 60_000, limit: 5 } })
  resendPasswordResetOtp(
    @Body() dto: RequestPasswordResetOtpDto,
  ): Promise<RequestPasswordResetOtpResponse> {
    return this.authService.requestPasswordResetOtp(dto);
  }

  @Post("password-reset/verify-otp")
  @Throttle({ default: { ttl: 60_000, limit: 6 } })
  verifyPasswordResetOtp(
    @Body() dto: VerifyPasswordResetOtpDto,
  ): Promise<VerifyPasswordResetOtpResponse> {
    return this.authService.verifyPasswordResetOtp(dto);
  }

  @Post("password-reset/complete")
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 5 } })
  completePasswordReset(
    @Body() dto: CompletePasswordResetDto,
  ): Promise<CompletePasswordResetResponse> {
    return this.authService.completePasswordReset(dto);
  }

  @Post("login")
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 10 } })
  login(@Body() dto: LoginDto): Promise<LoginResponse> {
    return this.authService.login(dto);
  }
}
