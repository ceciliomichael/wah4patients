import { Controller, Get, Headers } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { HealthRecordsService } from './health-records.service';
import { HealthRecordsResponse } from './health-records.types';

@Controller('health-records')
export class HealthRecordsController {
  constructor(private readonly healthRecordsService: HealthRecordsService) {}

  @Get('medical-history')
  @Throttle({ default: { ttl: 60_000, limit: 30 } })
  getMedicalHistoryRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<HealthRecordsResponse> {
    return this.healthRecordsService.getRecords(
      authorizationHeader,
      'medical-history',
    );
  }

  @Get('immunizations')
  @Throttle({ default: { ttl: 60_000, limit: 30 } })
  getImmunizationRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<HealthRecordsResponse> {
    return this.healthRecordsService.getRecords(
      authorizationHeader,
      'immunizations',
    );
  }

  @Get('consultations')
  @Throttle({ default: { ttl: 60_000, limit: 30 } })
  getMedicalConsultationRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<HealthRecordsResponse> {
    return this.healthRecordsService.getRecords(
      authorizationHeader,
      'consultations',
    );
  }

  @Get('laboratory-results')
  @Throttle({ default: { ttl: 60_000, limit: 30 } })
  getLaboratoryResultRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<HealthRecordsResponse> {
    return this.healthRecordsService.getRecords(
      authorizationHeader,
      'laboratory-results',
    );
  }
}
