import { Module } from "@nestjs/common";
import { JwtModule } from "@nestjs/jwt";
import { MailerModule } from "../mailer/mailer.module";
import { SupabaseModule } from "../supabase/supabase.module";
import { AuthController } from "./auth.controller";
import { AuthService } from "./auth.service";
import { PasswordResetOtpRepository } from "./password-reset-otp.repository";
import { RegistrationOtpRepository } from "./registration-otp.repository";
import { TotpFactorRepository } from "./totp-factor.repository";
import { TotpRecoveryCodesRepository } from "./totp-recovery-codes.repository";

@Module({
  imports: [JwtModule.register({}), SupabaseModule, MailerModule],
  controllers: [AuthController],
  providers: [
    AuthService,
    RegistrationOtpRepository,
    PasswordResetOtpRepository,
    TotpFactorRepository,
    TotpRecoveryCodesRepository,
  ],
})
export class AuthModule {}
