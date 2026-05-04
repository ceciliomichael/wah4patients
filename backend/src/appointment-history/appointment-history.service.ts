import { Injectable } from '@nestjs/common';
import { AuthSupportService } from '../auth/auth-support.service';
import { AppointmentHistoryRepository } from './appointment-history.repository';
import { AppointmentHistoryResponse } from './appointment-history.types';

@Injectable()
export class AppointmentHistoryService {
  constructor(
    private readonly authSupportService: AuthSupportService,
    private readonly appointmentHistoryRepository: AppointmentHistoryRepository,
  ) {}

  async getHistoryRecords(
    authorizationHeader: string | undefined,
  ): Promise<AppointmentHistoryResponse> {
    const authenticatedUser =
      await this.authSupportService.getAuthenticatedUserFromHeader(
        authorizationHeader,
      );

    return this.appointmentHistoryRepository.listHistoryRecords(
      authenticatedUser.id,
    );
  }
}
