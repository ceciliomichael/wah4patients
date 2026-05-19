import { BadGatewayException, Injectable, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class GatewayClientService {
  constructor(private readonly configService: ConfigService) {}

  async getJson(path: string): Promise<unknown> {
    return this.requestGatewayJson({
      method: 'GET',
      path,
    });
  }

  async postJson(
    path: string,
    body: Record<string, unknown>,
    headers: Record<string, string> = {},
  ): Promise<unknown> {
    return this.requestGatewayJson({
      method: 'POST',
      path,
      body,
      headers,
    });
  }

  private async requestGatewayJson(input: {
    method: 'GET' | 'POST';
    path: string;
    body?: Record<string, unknown>;
    headers?: Record<string, string>;
  }): Promise<unknown> {
    const requestUrl = new URL(
      input.path.replace(/^\//, ''),
      `${this.resolveGatewayApiBaseUrl()}/`,
    ).toString();
    const apiKey = this.getRequiredConfig('WAH4PC_API_KEY');

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 15_000);

    let response: Response;
    try {
      response = await fetch(requestUrl, {
        method: input.method,
        headers: {
          Accept: 'application/json',
          'x-api-key': apiKey,
          ...(input.method === 'POST' ? { 'Content-Type': 'application/json' } : {}),
          ...(input.headers ?? {}),
        },
        body: input.body == null ? undefined : JSON.stringify(input.body),
        signal: controller.signal,
      });
    } catch (error) {
      if ((error as Error & { name?: string }).name === 'AbortError') {
        throw new ServiceUnavailableException(
          'The WAH4PC Gateway request timed out. Please try again.',
        );
      }

      throw new ServiceUnavailableException(
        'Unable to reach the WAH4PC Gateway. Check the configured gateway URL.',
      );
    } finally {
      clearTimeout(timeoutId);
    }

    const decodedBody = await this.safeParseJson(response);
    if (!response.ok) {
      const message = this.extractErrorMessage(decodedBody);
      throw new BadGatewayException(
        message ?? `WAH4PC Gateway request failed with status ${response.status}`,
      );
    }

    return decodedBody;
  }

  private async safeParseJson(response: Response): Promise<unknown> {
    const contentType = response.headers.get('content-type') ?? '';
    if (!contentType.includes('application/json')) {
      const textBody = await response.text();
      return textBody.trim().length > 0 ? textBody : null;
    }

    try {
      return await response.json();
    } catch {
      return null;
    }
  }

  private extractErrorMessage(payload: unknown): string | undefined {
    if (!this.isRecord(payload)) {
      return undefined;
    }

    const directMessage = payload['message'];
    if (typeof directMessage === 'string' && directMessage.trim().length > 0) {
      return directMessage.trim();
    }

    const errorMessage = payload['error'];
    if (typeof errorMessage === 'string' && errorMessage.trim().length > 0) {
      return errorMessage.trim();
    }

    return undefined;
  }

  private resolveGatewayApiBaseUrl(): string {
    const gatewayUrl = this.getRequiredConfig('WAH4PC_GATEWAY_URL').trim();
    if (gatewayUrl.length === 0) {
      throw new ServiceUnavailableException(
        'Missing WAH4PC gateway URL configuration.',
      );
    }

    const normalized = gatewayUrl.replace(/\/+$/, '');
    return normalized.endsWith('/api/v1') ? normalized : `${normalized}/api/v1`;
  }

  private getRequiredConfig(key: string): string {
    const value = this.configService.get<string>(key);
    if (typeof value !== 'string' || value.trim().length === 0) {
      throw new ServiceUnavailableException(
        `Missing required environment variable: ${key}`,
      );
    }

    return value.trim();
  }

  private isRecord(value: unknown): value is Record<string, unknown> {
    return typeof value === 'object' && value !== null;
  }
}
