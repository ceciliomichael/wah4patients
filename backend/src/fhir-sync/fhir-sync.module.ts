import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { GatewayWebhookController } from './fhir-sync.controller';
import { GatewayAuthGuard } from './gateway-auth.guard';
import { FhirSyncRepository } from './fhir-sync.repository';
import { FhirSyncService } from './fhir-sync.service';
import { SupabaseModule } from '../supabase/supabase.module';
import { AppointmentHistoryModule } from '../appointment-history/appointment-history.module';

@Module({
  imports: [ConfigModule, SupabaseModule, AppointmentHistoryModule],
  controllers: [GatewayWebhookController],
  providers: [GatewayAuthGuard, FhirSyncRepository, FhirSyncService],
  exports: [FhirSyncRepository, FhirSyncService],
})
export class FhirSyncModule {}
