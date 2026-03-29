import {
  Body,
  Controller,
  Headers,
  HttpCode,
  HttpStatus,
  Post,
} from "@nestjs/common";
import { Throttle } from "@nestjs/throttler";
import { AuthService } from "./auth.service";
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
  LoginResponse,
  LoginResultResponse,
  RequestOtpResponse,
  RequestPasswordResetOtpResponse,
  SetMpinResponse,
  TotpSetupStartResponse,
  TotpSetupVerifyResponse,
  VerifyMpinResponse,
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
  login(@Body() dto: LoginDto): Promise<LoginResultResponse> {
    return this.authService.login(dto);
  }

  @Post("2fa/setup/start")
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 5 } })
  startTotpSetup(
    @Headers("authorization") authorizationHeader: string | undefined,
  ): Promise<TotpSetupStartResponse> {
    return this.authService.startTotpSetup(authorizationHeader);
  }

  @Post("2fa/setup/verify")
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 8 } })
  verifyTotpSetup(
    @Headers("authorization") authorizationHeader: string | undefined,
    @Body() dto: VerifyTotpCodeDto,
  ): Promise<TotpSetupVerifyResponse> {
    return this.authService.verifyTotpSetup(authorizationHeader, dto);
  }

  @Post("2fa/challenge/verify")
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 10 } })
  verifyMfaChallenge(
    @Body() dto: VerifyMfaChallengeDto,
  ): Promise<LoginResponse> {
    return this.authService.verifyMfaChallenge(dto);
  }

  @Post("2fa/challenge/verify-backup-code")
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 8 } })
  verifyMfaBackupCode(
    @Body() dto: VerifyMfaBackupCodeDto,
  ): Promise<LoginResponse> {
    return this.authService.verifyMfaBackupCode(dto);
  }

  @Post("2fa/disable")
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 5 } })
  disableTotp(
    @Headers("authorization") authorizationHeader: string | undefined,
    @Body() dto: DisableTotpDto,
  ): Promise<{ message: string }> {
    return this.authService.disableTotp(authorizationHeader, dto);
  }

  @Post("mpin/set")
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 5 } })
  setMpin(
    @Headers("authorization") authorizationHeader: string | undefined,
    @Body() dto: SetMpinDto,
  ): Promise<SetMpinResponse> {
    return this.authService.setMpin(authorizationHeader, dto);
  }

  @Post("mpin/verify")
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 12 } })
  verifyMpin(
    @Headers("authorization") authorizationHeader: string | undefined,
    @Body() dto: VerifyMpinDto,
  ): Promise<VerifyMpinResponse> {
    return this.authService.verifyMpin(authorizationHeader, dto);
  }
}
