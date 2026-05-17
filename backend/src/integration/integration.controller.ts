import {
  Body,
  Controller,
  BadRequestException,
  Get,
  HttpCode,
  HttpStatus,
  Headers,
  Post,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import { PrepareSyncRequestDto } from './dto/prepare-sync-request.dto';
import { SimulateSyncRequestDto } from './dto/simulate-sync-request.dto';
import { IntegrationService } from './integration.service';
import {
  InteroperabilityProvidersResponse,
  PreparedSyncRequestResponse,
  SimulatedSyncRequestResponse,
} from './integration.types';
import { SyncSimulationService } from './sync-simulation.service';

@Controller('interoperability')
export class IntegrationController {
  constructor(
    private readonly integrationService: IntegrationService,
    private readonly syncSimulationService: SyncSimulationService,
  ) {}

  @Get('providers')
  @Throttle({ default: { ttl: 60_000, limit: 20 } })
  getProviders(): Promise<InteroperabilityProvidersResponse> {
    return this.integrationService.getProviders();
  }

  @Post('sync/prepare')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 20 } })
  prepareSyncRequest(
    @Headers('x-user-id') userId: string | undefined,
    @Body() dto: PrepareSyncRequestDto,
  ): Promise<PreparedSyncRequestResponse> {
    if (typeof userId !== 'string' || userId.trim().length === 0) {
      throw new BadRequestException('Missing authenticated account context.');
    }

    return this.integrationService.prepareSyncRequest(dto, userId);
  }

  @Post('sync/simulate')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { ttl: 60_000, limit: 20 } })
  simulateSyncRequest(
    @Headers('authorization') authorizationHeader: string | undefined,
    @Headers('x-user-id') userId: string | undefined,
    @Body() dto: SimulateSyncRequestDto,
  ): Promise<SimulatedSyncRequestResponse> {
    return this.syncSimulationService.simulateSyncRequest(
      authorizationHeader,
      userId,
      dto,
    );
  }
}
