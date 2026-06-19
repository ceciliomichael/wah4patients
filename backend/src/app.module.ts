import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';

import { AuthModule } from './auth/auth.module';
import { envValidationSchema } from './common/config/env.validation';
import { ApiKeyGuard } from './common/guards/api-key.guard';
import { AppointmentHistoryModule } from './appointment-history/appointment-history.module';
import { HealthModule } from './health/health.module';
import { HealthRecordsModule } from './health-records/health-records.module';
import { IntegrationModule } from './integration/integration.module';
import { FhirSyncModule } from './fhir-sync/fhir-sync.module';
import { MedicationResupplyModule } from './medication-resupply/medication-resupply.module';
import { RequestLoggingModule } from './common/logging/request-logging.module';
import { PersonalRecordsModule } from './personal-records/personal-records.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      cache: true,
      validationSchema: envValidationSchema,
    }),

    HealthModule,
    AuthModule,
    AppointmentHistoryModule,
    PersonalRecordsModule,
    HealthRecordsModule,
    IntegrationModule,
    FhirSyncModule,
    MedicationResupplyModule,
    RequestLoggingModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ApiKeyGuard,
    },
  ],
})
export class AppModule {}
