import { Injectable } from '@nestjs/common';
import { CompletePasswordResetDto } from './dto/complete-password-reset.dto';
import { CompleteRegistrationDto } from './dto/complete-registration.dto';
import { DisableTotpDto } from './dto/disable-totp.dto';
import { GetSecuritySettingsStatusDto } from './dto/get-security-settings-status.dto';
import { LoginDto } from './dto/login.dto';
import { RegisterMpinDeviceDto } from './dto/register-mpin-device.dto';
import { RequestPasswordResetOtpDto } from './dto/request-password-reset-otp.dto';
import { RequestRegistrationOtpDto } from './dto/request-registration-otp.dto';
import { SetMpinDto } from './dto/set-mpin.dto';
import { RequestSecurityEmailOtpDto } from './dto/request-security-email-otp.dto';
import { VerifySecurityEmailOtpDto } from './dto/verify-security-email-otp.dto';
import { VerifyTotpForSecurityActionDto } from './dto/verify-totp-for-security-action.dto';
import { VerifyMfaBackupCodeDto } from './dto/verify-mfa-backup-code.dto';
import { VerifyMfaChallengeDto } from './dto/verify-mfa-challenge.dto';
import { VerifyMpinChallengeDto } from './dto/verify-mpin-challenge.dto';
import { VerifyMpinDto } from './dto/verify-mpin.dto';
import { VerifyPasswordResetOtpDto } from './dto/verify-password-reset-otp.dto';
import { VerifyRegistrationOtpDto } from './dto/verify-registration-otp.dto';
import { VerifyTotpCodeDto } from './dto/verify-totp-code.dto';
import {
  CompletePasswordResetResponse,
  CompleteRegistrationResponse,
  LoginResponse,
  LoginResultResponse,
  RequestOtpResponse,
  RequestPasswordResetOtpResponse,
  RegisterMpinDeviceResponse,
  SetMpinResponse,
  SecuritySettingsStatusResponse,
  TotpSetupStartResponse,
  TotpSetupVerifyResponse,
  VerifySecurityActionResponse,
  UnregisterMpinDeviceResponse,
  VerifyMpinResponse,
  VerifyOtpResponse,
  VerifyPasswordResetOtpResponse,
} from './auth.types';
import { LoginAuthService } from './login-auth.service';
import { MpinAuthService } from './mpin-auth.service';
import { PasswordResetAuthService } from './password-reset-auth.service';
import { RegistrationAuthService } from './registration-auth.service';

@Injectable()
export class AuthService {
  constructor(
    private readonly registrationAuthService: RegistrationAuthService,
    private readonly passwordResetAuthService: PasswordResetAuthService,
    private readonly loginAuthService: LoginAuthService,
    private readonly mpinAuthService: MpinAuthService,
  ) {}

  requestRegistrationOtp(
    dto: RequestRegistrationOtpDto,
  ): Promise<RequestOtpResponse> {
    return this.registrationAuthService.requestRegistrationOtp(dto);
  }

  verifyRegistrationOtp(
    dto: VerifyRegistrationOtpDto,
  ): Promise<VerifyOtpResponse> {
    return this.registrationAuthService.verifyRegistrationOtp(dto);
  }

  completeRegistration(
    dto: CompleteRegistrationDto,
  ): Promise<CompleteRegistrationResponse> {
    return this.registrationAuthService.completeRegistration(dto);
  }

  requestPasswordResetOtp(
    dto: RequestPasswordResetOtpDto,
  ): Promise<RequestPasswordResetOtpResponse> {
    return this.passwordResetAuthService.requestPasswordResetOtp(dto);
  }

  verifyPasswordResetOtp(
    dto: VerifyPasswordResetOtpDto,
  ): Promise<VerifyPasswordResetOtpResponse> {
    return this.passwordResetAuthService.verifyPasswordResetOtp(dto);
  }

  completePasswordReset(
    dto: CompletePasswordResetDto,
  ): Promise<CompletePasswordResetResponse> {
    return this.passwordResetAuthService.completePasswordReset(dto);
  }

  login(dto: LoginDto): Promise<LoginResultResponse> {
    return this.loginAuthService.login(dto);
  }

  startTotpSetup(
    authorizationHeader: string | undefined,
  ): Promise<TotpSetupStartResponse> {
    return this.loginAuthService.startTotpSetup(authorizationHeader);
  }

  verifyTotpSetup(
    authorizationHeader: string | undefined,
    dto: VerifyTotpCodeDto,
  ): Promise<TotpSetupVerifyResponse> {
    return this.loginAuthService.verifyTotpSetup(authorizationHeader, dto);
  }

  verifyMfaChallenge(dto: VerifyMfaChallengeDto): Promise<LoginResponse> {
    return this.loginAuthService.verifyMfaChallenge(dto);
  }

  verifyMfaBackupCode(dto: VerifyMfaBackupCodeDto): Promise<LoginResponse> {
    return this.loginAuthService.verifyMfaBackupCode(dto);
  }

  getSecuritySettingsStatus(
    authorizationHeader: string | undefined,
    dto: GetSecuritySettingsStatusDto,
  ): Promise<SecuritySettingsStatusResponse> {
    return this.loginAuthService.getSecuritySettingsStatus(
      authorizationHeader,
      dto,
    );
  }

  verifyTotpForSecurityAction(
    dto: VerifyTotpForSecurityActionDto,
  ): Promise<VerifySecurityActionResponse> {
    return this.loginAuthService.verifyTotpForSecurityAction(dto);
  }

  requestSecurityEmailOtp(
    dto: RequestSecurityEmailOtpDto,
  ): Promise<RequestPasswordResetOtpResponse> {
    return this.loginAuthService.requestSecurityEmailOtp(dto);
  }

  verifySecurityEmailOtp(
    dto: VerifySecurityEmailOtpDto,
  ): Promise<VerifySecurityActionResponse> {
    return this.loginAuthService.verifySecurityEmailOtp(dto);
  }

  verifyMpinChallenge(dto: VerifyMpinChallengeDto): Promise<LoginResponse> {
    return this.loginAuthService.verifyMpinChallenge(dto);
  }

  disableTotp(
    authorizationHeader: string | undefined,
    dto: DisableTotpDto,
  ): Promise<{ message: string }> {
    return this.loginAuthService.disableTotp(authorizationHeader, dto);
  }

  setMpin(
    authorizationHeader: string | undefined,
    dto: SetMpinDto,
  ): Promise<SetMpinResponse> {
    return this.mpinAuthService.setMpin(authorizationHeader, dto);
  }

  verifyMpin(
    authorizationHeader: string | undefined,
    dto: VerifyMpinDto,
  ): Promise<VerifyMpinResponse> {
    return this.mpinAuthService.verifyMpin(authorizationHeader, dto);
  }

  registerMpinDevice(
    authorizationHeader: string | undefined,
    dto: RegisterMpinDeviceDto,
  ): Promise<RegisterMpinDeviceResponse> {
    return this.mpinAuthService.registerMpinDevice(authorizationHeader, dto);
  }

  unregisterMpinDevice(
    authorizationHeader: string | undefined,
    dto: DisableTotpDto,
  ): Promise<UnregisterMpinDeviceResponse> {
    return this.mpinAuthService.unregisterDevice(authorizationHeader, dto);
  }
}
