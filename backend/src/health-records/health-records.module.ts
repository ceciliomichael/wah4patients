import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { HealthRecordsController } from './health-records.controller';
import { HealthRecordsRepository } from './health-records.repository';
import { HealthRecordsService } from './health-records.service';

@Module({
  imports: [AuthModule, SupabaseModule],
  controllers: [HealthRecordsController],
  providers: [HealthRecordsRepository, HealthRecordsService],
})
export class HealthRecordsModule {}
