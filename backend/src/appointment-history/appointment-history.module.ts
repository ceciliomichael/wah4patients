import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { AppointmentHistoryController } from './appointment-history.controller';
import { AppointmentHistoryRepository } from './appointment-history.repository';
import { AppointmentHistoryService } from './appointment-history.service';

@Module({
  imports: [AuthModule, SupabaseModule],
  controllers: [AppointmentHistoryController],
  providers: [AppointmentHistoryRepository, AppointmentHistoryService],
})
export class AppointmentHistoryModule {}
