import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { MailerModule } from '../mailer/mailer.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { RegistrationOtpRepository } from './registration-otp.repository';

@Module({
  imports: [JwtModule.register({}), SupabaseModule, MailerModule],
  controllers: [AuthController],
  providers: [AuthService, RegistrationOtpRepository],
})
export class AuthModule {}
