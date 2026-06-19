import { Controller, Get, Headers } from '@nestjs/common';
import { AppointmentHistoryService } from './appointment-history.service';
import { AppointmentHistoryResponse } from './appointment-history.types';

@Controller('appointment-history')
export class AppointmentHistoryController {
  constructor(
    private readonly appointmentHistoryService: AppointmentHistoryService,
  ) {}

  @Get('history')
  getHistoryRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<AppointmentHistoryResponse> {
    return this.appointmentHistoryService.getHistoryRecords(
      authorizationHeader,
    );
  }
}
