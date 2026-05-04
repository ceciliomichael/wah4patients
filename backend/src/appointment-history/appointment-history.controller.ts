import { Controller, Get, Headers } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { AppointmentHistoryService } from './appointment-history.service';
import { AppointmentHistoryResponse } from './appointment-history.types';

@Controller('appointment-history')
export class AppointmentHistoryController {
  constructor(
    private readonly appointmentHistoryService: AppointmentHistoryService,
  ) {}

  @Get('history')
  @Throttle({ default: { ttl: 60_000, limit: 30 } })
  getHistoryRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<AppointmentHistoryResponse> {
    return this.appointmentHistoryService.getHistoryRecords(
      authorizationHeader,
    );
  }
}
