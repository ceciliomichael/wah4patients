import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ServiceUnavailableException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';
import { timingSafeEqual } from 'node:crypto';

@Injectable()
export class GatewayAuthGuard implements CanActivate {
  constructor(private readonly configService: ConfigService) {}

  canActivate(context: ExecutionContext): boolean {
    const expectedKey = this.configService.get<string>('WAH4PC_GATEWAY_AUTH_KEY');
    if (typeof expectedKey !== 'string' || expectedKey.trim().length === 0) {
      throw new ServiceUnavailableException(
        'Missing WAH4PC_GATEWAY_AUTH_KEY configuration.',
      );
    }

    const request = context.switchToHttp().getRequest<Request>();
    const providedKey = request.header('x-gateway-auth')?.trim() ?? '';
    if (providedKey.length === 0) {
      throw new UnauthorizedException('Missing gateway authentication header');
    }

    if (!this.keysMatch(expectedKey.trim(), providedKey)) {
      throw new UnauthorizedException('Invalid gateway authentication header');
    }

    return true;
  }

  private keysMatch(expected: string, provided: string): boolean {
    const expectedBuffer = Buffer.from(expected);
    const providedBuffer = Buffer.from(provided);

    if (expectedBuffer.length !== providedBuffer.length) {
      return false;
    }

    return timingSafeEqual(expectedBuffer, providedBuffer);
  }
}
