import { Controller, Get, Headers } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { MedicationResupplyService } from './medication-resupply.service';
import { MedicationResupplyHistoryResponse } from './medication-resupply.types';

@Controller('medication-resupply')
export class MedicationResupplyController {
  constructor(
    private readonly medicationResupplyService: MedicationResupplyService,
  ) {}

  @Get('history')
  @Throttle({ default: { ttl: 60_000, limit: 30 } })
  getHistoryRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<MedicationResupplyHistoryResponse> {
    return this.medicationResupplyService.getHistoryRecords(
      authorizationHeader,
    );
  }
}
