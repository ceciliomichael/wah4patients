import { Injectable } from '@nestjs/common';
import { AuthSupportService } from '../auth/auth-support.service';
import {
  HealthRecordsResponse,
  HealthRecordSection,
  HealthRecordTableName,
} from './health-records.types';
import { HealthRecordsRepository } from './health-records.repository';

const SECTION_TABLES: Record<HealthRecordSection, HealthRecordTableName> = {
  'medical-history': 'medical_history_records',
  immunizations: 'immunization_records',
  consultations: 'medical_consultation_records',
  'laboratory-results': 'laboratory_result_records',
};

@Injectable()
export class HealthRecordsService {
  constructor(
    private readonly authSupportService: AuthSupportService,
    private readonly healthRecordsRepository: HealthRecordsRepository,
  ) {}

  async getRecords(
    authorizationHeader: string | undefined,
    section: HealthRecordSection,
  ): Promise<HealthRecordsResponse> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    return this.healthRecordsRepository.listRecords(
      SECTION_TABLES[section],
      authenticatedUser.id,
    );
  }
}
