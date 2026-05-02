import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { PersonalRecordsController } from './personal-records.controller';
import { PersonalRecordsRepository } from './personal-records.repository';
import { PersonalRecordsService } from './personal-records.service';

@Module({
  imports: [AuthModule, SupabaseModule],
  controllers: [PersonalRecordsController],
  providers: [PersonalRecordsRepository, PersonalRecordsService],
})
export class PersonalRecordsModule {}
