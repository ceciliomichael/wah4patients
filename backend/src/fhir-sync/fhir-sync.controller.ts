import { Body, Controller, HttpCode, HttpStatus, Post, UseGuards } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
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
  @Throttle({ default: { ttl: 60_000, limit: 20 } })
  processQuery(@Body() body: unknown): Promise<FhirSyncAcknowledgement> {
    return this.fhirSyncService.processQuery(body);
  }

  @Public()
  @Post('receive-results')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 20 } })
  receiveResults(@Body() body: unknown): Promise<FhirSyncAcknowledgement> {
    return this.fhirSyncService.receiveResults(body);
  }

  @Public()
  @Post('receive-push')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 20 } })
  receivePush(@Body() body: unknown): Promise<FhirSyncAcknowledgement> {
    return this.fhirSyncService.receivePush(body);
  }
}
