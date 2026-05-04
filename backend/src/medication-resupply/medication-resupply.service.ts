import { Injectable } from '@nestjs/common';
import { AuthSupportService } from '../auth/auth-support.service';
import { MedicationResupplyRepository } from './medication-resupply.repository';
import { MedicationResupplyHistoryResponse } from './medication-resupply.types';

@Injectable()
export class MedicationResupplyService {
  constructor(
    private readonly authSupportService: AuthSupportService,
    private readonly medicationResupplyRepository: MedicationResupplyRepository,
  ) {}

  async getHistoryRecords(
    authorizationHeader: string | undefined,
  ): Promise<MedicationResupplyHistoryResponse> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    return this.medicationResupplyRepository.listHistoryRecords(
      authenticatedUser.id,
    );
  }
}
