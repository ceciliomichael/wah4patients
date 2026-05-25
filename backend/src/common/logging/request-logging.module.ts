import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { RequestLoggingService } from './request-logging.service';

@Module({
  imports: [ConfigModule],
  providers: [RequestLoggingService],
  exports: [RequestLoggingService],
})
export class RequestLoggingModule {}
