import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { mkdir, appendFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { randomUUID } from 'node:crypto';
import type { NextFunction, Request, Response } from 'express';

interface RequestLogEntry {
  timestamp: string;
  requestId: string;
  method: string;
  path: string;
  statusCode: number;
  durationMs: number;
  remoteAddress: string;
  userAgent: string;
  providerId: string | null;
  userId: string | null;
  resourceType: string | null;
  transactionId: string | null;
  correlationId: string | null;
}

@Injectable()
export class RequestLoggingService {
  private readonly enabled: boolean;
  private readonly logFilePath = resolve(process.cwd(), 'logs', 'requests.log');
  private ensureDirectoryPromise: Promise<void> | null = null;

  constructor(private readonly configService: ConfigService) {
    this.enabled = this.readEnabledFlag();
  }

  isEnabled(): boolean {
    return this.enabled;
  }

  createMiddleware() {
    return (req: Request, res: Response, next: NextFunction): void => {
      if (!this.enabled) {
        next();
        return;
      }

      const startedAt = process.hrtime.bigint();
      const requestId = randomUUID();

      res.on('finish', () => {
        void this.writeEntry(req, res, requestId, startedAt).catch(() => undefined);
      });

      next();
    };
  }

  private async writeEntry(
    req: Request,
    res: Response,
    requestId: string,
    startedAt: bigint,
  ): Promise<void> {
    await this.ensureDirectory();

    const durationMs = Number(process.hrtime.bigint() - startedAt) / 1_000_000;
    const entry: RequestLogEntry = {
      timestamp: new Date().toISOString(),
      requestId,
      method: req.method,
      path: this.getRequestPath(req),
      statusCode: res.statusCode,
      durationMs: Number(durationMs.toFixed(3)),
      remoteAddress: this.getRemoteAddress(req),
      userAgent: this.readHeader(req.headers['user-agent']) ?? '',
      providerId: this.readHeader(req.headers['x-provider-id']),
      userId: this.readHeader(req.headers['x-user-id']),
      resourceType: this.extractResourceType(req.body),
      transactionId: this.extractTransactionId(req.body),
      correlationId: this.extractCorrelationId(req.body),
    };

    await appendFile(this.logFilePath, `${JSON.stringify(entry)}\n`, 'utf8');
  }

  private async ensureDirectory(): Promise<void> {
    if (this.ensureDirectoryPromise === null) {
      this.ensureDirectoryPromise = mkdir(dirname(this.logFilePath), {
        recursive: true,
      }).then(() => undefined);
    }

    await this.ensureDirectoryPromise;
  }

  private readEnabledFlag(): boolean {
    const rawValue = this.configService.get<string | boolean | undefined>(
      'BACKEND_REQUEST_LOGGING_ENABLED',
    );

    if (typeof rawValue === 'boolean') {
      return rawValue;
    }

    const normalizedValue = rawValue?.trim().toLowerCase();
    return normalizedValue === 'true' || normalizedValue === '1' || normalizedValue === 'yes';
  }

  private getRequestPath(req: Request): string {
    return req.originalUrl?.trim() || req.url.trim() || req.path.trim();
  }

  private getRemoteAddress(req: Request): string {
    const forwardedFor = this.readHeader(req.headers['x-forwarded-for']);
    if (forwardedFor !== null) {
      return forwardedFor;
    }

    return req.ip || req.socket.remoteAddress || '';
  }

  private readHeader(value: string | string[] | undefined): string | null {
    if (Array.isArray(value)) {
      const joined = value.join(', ').trim();
      return joined.length > 0 ? joined : null;
    }

    const trimmed = value?.trim() ?? '';
    return trimmed.length > 0 ? trimmed : null;
  }

  private extractResourceType(body: unknown): string | null {
    if (!this.isRecord(body)) {
      return null;
    }

    const resourceType = this.readString(body['resourceType']);
    if (resourceType !== null) {
      return resourceType;
    }

    if (this.isRecord(body['data'])) {
      return this.readString(body['data']['resourceType']);
    }

    return null;
  }

  private extractTransactionId(body: unknown): string | null {
    if (!this.isRecord(body)) {
      return null;
    }

    const directTransactionId = this.readString(body['transactionId']);
    if (directTransactionId !== null) {
      return directTransactionId;
    }

    if (this.isRecord(body['data'])) {
      const nestedTransactionId = this.readString(body['data']['transactionId']);
      if (nestedTransactionId !== null) {
        return nestedTransactionId;
      }

      const nestedId = this.readString(body['data']['id']);
      if (nestedId !== null) {
        return nestedId;
      }
    }

    return null;
  }

  private extractCorrelationId(body: unknown): string | null {
    if (!this.isRecord(body)) {
      return null;
    }

    const directCorrelationId = this.readString(body['correlationId']);
    if (directCorrelationId !== null) {
      return directCorrelationId;
    }

    if (this.isRecord(body['data'])) {
      const nestedCorrelationId = this.readString(body['data']['correlationId']);
      if (nestedCorrelationId !== null) {
        return nestedCorrelationId;
      }
    }

    return null;
  }

  private readString(value: unknown): string | null {
    if (typeof value !== 'string') {
      return null;
    }

    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : null;
  }

  private isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null && !Array.isArray(value);
  }
}
