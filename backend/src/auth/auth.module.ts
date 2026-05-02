import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { MailerModule } from '../mailer/mailer.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { AuthSettingsService } from './auth-settings.service';
import { AuthSupportService } from './auth-support.service';
import { LoginAuthService } from './login-auth.service';
import { MpinAuthService } from './mpin-auth.service';
import { ProfileController } from './profile.controller';
import { ProfileRepository } from './profile.repository';
import { ProfileService } from './profile.service';
import { PasswordResetAuthService } from './password-reset-auth.service';
import { PasswordResetOtpRepository } from './password-reset-otp.repository';
import { RegistrationAuthService } from './registration-auth.service';
import { RegistrationOtpRepository } from './registration-otp.repository';
import { UserMpinDeviceRepository } from './user-mpin-device.repository';
import { TotpFactorRepository } from './totp-factor.repository';
import { TotpRecoveryCodesRepository } from './totp-recovery-codes.repository';
import { UserMpinRepository } from './user-mpin.repository';

@Module({
  imports: [JwtModule.register({}), SupabaseModule, MailerModule],
  controllers: [AuthController, ProfileController],
  providers: [
    AuthService,
    AuthSettingsService,
    AuthSupportService,
    RegistrationAuthService,
    PasswordResetAuthService,
    LoginAuthService,
    MpinAuthService,
    ProfileService,
    ProfileRepository,
    RegistrationOtpRepository,
    PasswordResetOtpRepository,
    TotpFactorRepository,
    TotpRecoveryCodesRepository,
    UserMpinRepository,
    UserMpinDeviceRepository,
  ],
  exports: [AuthSupportService],
})
export class AuthModule {}
