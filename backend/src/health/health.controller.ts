import { Controller, Get } from '@nestjs/common';
import { Public } from '../common/decorators/public.decorator';

interface HealthResponse {
  status: 'ok';
  timestamp: string;
}

@Controller('health')
export class HealthController {
  @Public()
  @Get()
  getHealth(): HealthResponse {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
    };
  }
}
