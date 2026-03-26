import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Reflector } from '@nestjs/core';
import { Request } from 'express';
import { timingSafeEqual } from 'node:crypto';
import { IS_PUBLIC_ROUTE } from '../decorators/public.decorator';

@Injectable()
export class ApiKeyGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly configService: ConfigService,
  ) {}

  canActivate(context: ExecutionContext): boolean {
    const isPublicRoute = this.reflector.getAllAndOverride<boolean>(
      IS_PUBLIC_ROUTE,
      [context.getHandler(), context.getClass()],
    );

    if (isPublicRoute) {
      return true;
    }

    const request = context.switchToHttp().getRequest<Request>();
    const incomingApiKey = request.header('x-api-key')?.trim() ?? '';
    const expectedApiKey =
      this.configService.getOrThrow<string>('BACKEND_API_KEY');

    if (incomingApiKey.length === 0) {
      throw new UnauthorizedException('Missing API key');
    }

    if (!this.keysMatch(expectedApiKey, incomingApiKey)) {
      throw new UnauthorizedException('Invalid API key');
    }

    return true;
  }

  private keysMatch(expectedApiKey: string, providedApiKey: string): boolean {
    const expectedBuffer = Buffer.from(expectedApiKey);
    const providedBuffer = Buffer.from(providedApiKey);

    if (expectedBuffer.length !== providedBuffer.length) {
      return false;
    }

    return timingSafeEqual(expectedBuffer, providedBuffer);
  }
}
