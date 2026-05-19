import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { IntegrationController } from './integration.controller';
import { IntegrationService } from './integration.service';
import { AppointmentPushService } from './appointment-push.service';
import { GatewayClientService } from './gateway-client.service';
import { SyncSimulationService } from './sync-simulation.service';
import { FhirSyncModule } from '../fhir-sync/fhir-sync.module';

@Module({
  imports: [AuthModule, FhirSyncModule],
  controllers: [IntegrationController],
  providers: [
    GatewayClientService,
    IntegrationService,
    AppointmentPushService,
    SyncSimulationService,
  ],
})
export class IntegrationModule {}
