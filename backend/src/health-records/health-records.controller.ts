import { Controller, Get, Headers } from '@nestjs/common';
import { HealthRecordsService } from './health-records.service';
import { HealthRecordsResponse } from './health-records.types';

@Controller('health-records')
export class HealthRecordsController {
  constructor(private readonly healthRecordsService: HealthRecordsService) {}

  @Get('medical-history')
  getMedicalHistoryRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<HealthRecordsResponse> {
    return this.healthRecordsService.getRecords(
      authorizationHeader,
      'medical-history',
    );
  }

  @Get('immunizations')
  getImmunizationRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<HealthRecordsResponse> {
    return this.healthRecordsService.getRecords(
      authorizationHeader,
      'immunizations',
    );
  }

  @Get('consultations')
  getMedicalConsultationRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<HealthRecordsResponse> {
    return this.healthRecordsService.getRecords(
      authorizationHeader,
      'consultations',
    );
  }

  @Get('laboratory-results')
  getLaboratoryResultRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<HealthRecordsResponse> {
    return this.healthRecordsService.getRecords(
      authorizationHeader,
      'laboratory-results',
    );
  }
}
