import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { MedicationResupplyController } from './medication-resupply.controller';
import { MedicationResupplyRepository } from './medication-resupply.repository';
import { MedicationResupplyService } from './medication-resupply.service';

@Module({
  imports: [AuthModule, SupabaseModule],
  controllers: [MedicationResupplyController],
  providers: [MedicationResupplyRepository, MedicationResupplyService],
})
export class MedicationResupplyModule {}
