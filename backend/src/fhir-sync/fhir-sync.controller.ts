import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Post,
  UseGuards,
} from '@nestjs/common';

import { Public } from '../common/decorators/public.decorator';
import { GatewayAuthGuard } from './gateway-auth.guard';
import { FhirSyncService } from './fhir-sync.service';
import { FhirSyncAcknowledgement } from './fhir-sync.types';

@Controller('fhir')
@UseGuards(GatewayAuthGuard)
export class GatewayWebhookController {
  constructor(private readonly fhirSyncService: FhirSyncService) {}

  @Public()
  @Post('process-query')
  @HttpCode(HttpStatus.OK)
  processQuery(@Body() body: unknown): Promise<FhirSyncAcknowledgement> {
    return this.fhirSyncService.processQuery(body);
  }

  @Public()
  @Post('receive-results')
  @HttpCode(HttpStatus.OK)
  receiveResults(@Body() body: unknown): Promise<FhirSyncAcknowledgement> {
    return this.fhirSyncService.receiveResults(body);
  }

  @Public()
  @Post('receive-push')
  @HttpCode(HttpStatus.OK)
  receivePush(@Body() body: unknown): Promise<FhirSyncAcknowledgement> {
    return this.fhirSyncService.receivePush(body);
  }
}
