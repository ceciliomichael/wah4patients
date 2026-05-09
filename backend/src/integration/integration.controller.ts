import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { PrepareSyncRequestDto } from './dto/prepare-sync-request.dto';
import { IntegrationService } from './integration.service';
import {
  InteroperabilityProvidersResponse,
  PreparedSyncRequestResponse,
} from './integration.types';

@Controller('interoperability')
export class IntegrationController {
  constructor(private readonly integrationService: IntegrationService) {}

  @Get('providers')
  @Throttle({ default: { ttl: 60_000, limit: 20 } })
  getProviders(): Promise<InteroperabilityProvidersResponse> {
    return this.integrationService.getProviders();
  }

  @Post('sync/prepare')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 20 } })
  prepareSyncRequest(
    @Body() dto: PrepareSyncRequestDto,
  ): Promise<PreparedSyncRequestResponse> {
    return this.integrationService.prepareSyncRequest(dto);
  }
}
