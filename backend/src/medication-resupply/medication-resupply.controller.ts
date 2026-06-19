import { Controller, Get, Headers } from '@nestjs/common';
import { MedicationResupplyService } from './medication-resupply.service';
import { MedicationResupplyHistoryResponse } from './medication-resupply.types';

@Controller('medication-resupply')
export class MedicationResupplyController {
  constructor(
    private readonly medicationResupplyService: MedicationResupplyService,
  ) {}

  @Get('history')
  getHistoryRecords(
    @Headers('authorization') authorizationHeader: string | undefined,
  ): Promise<MedicationResupplyHistoryResponse> {
    return this.medicationResupplyService.getHistoryRecords(
      authorizationHeader,
    );
  }
}
