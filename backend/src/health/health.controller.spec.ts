import { HealthController } from './health.controller';

describe('HealthController', () => {
  it('returns ok status', () => {
    const controller = new HealthController();
    const response = controller.getHealth();

    expect(response.status).toBe('ok');
    expect(typeof response.timestamp).toBe('string');
    expect(response.timestamp.length).toBeGreaterThan(10);
  });
});
