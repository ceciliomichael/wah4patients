import { BadGatewayException, Logger, ServiceUnavailableException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GatewayClientService } from './gateway-client.service';

describe('GatewayClientService', () => {
  const createConfigService = (): ConfigService => {
    return {
      get: (key: string) => {
        if (key === 'WAH4PC_GATEWAY_URL') {
          return 'https://wah4pc.example.com';
        }

        if (key === 'WAH4PC_API_KEY') {
          return 'gateway-api-key-test';
        }

        return '';
      },
    } as ConfigService;
  };

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('logs the raw gateway body when the gateway returns an HTML error page', async () => {
    const errorSpy = jest.spyOn(Logger.prototype, 'error').mockImplementation();
    jest.spyOn(globalThis, 'fetch').mockResolvedValue(
      new Response('<!doctype html><html><body>503 - Service unavailable</body></html>', {
        status: 503,
        statusText: 'Service Unavailable',
        headers: { 'content-type': 'text/html' },
      }) as Response,
    );

    const service = new GatewayClientService(createConfigService());

    await expect(service.getJson('/providers')).rejects.toBeInstanceOf(
      BadGatewayException,
    );
    expect(errorSpy).toHaveBeenCalledWith(
      expect.stringContaining('status=503'),
    );
    expect(errorSpy).toHaveBeenCalledWith(
      expect.stringContaining('body=<!doctype html><html><body>503 - Service unavailable</body></html>'),
    );
  });

  it('surfaces gateway connectivity issues as service unavailability', async () => {
    jest.spyOn(globalThis, 'fetch').mockRejectedValue(new Error('network down'));

    const service = new GatewayClientService(createConfigService());

    await expect(service.getJson('/providers')).rejects.toBeInstanceOf(
      ServiceUnavailableException,
    );
  });
});
