import {
  parseDelimitedList,
  resolveCorsOrigins,
  resolveIntegerEnv,
} from './runtime-env';

describe('runtime-env', () => {
  it('parses comma-separated values and removes empties', () => {
    expect(
      parseDelimitedList(' http://localhost:3001,https://app.example.com, , '),
    ).toEqual(['http://localhost:3001', 'https://app.example.com']);
  });

  it('prefers CORS_ALLOWED_ORIGINS and falls back to FRONTEND_ORIGIN', () => {
    expect(
      resolveCorsOrigins({
        CORS_ALLOWED_ORIGINS:
          'https://app.example.com, https://admin.example.com',
        FRONTEND_ORIGIN: 'http://localhost:3001',
      }),
    ).toEqual(['https://app.example.com', 'https://admin.example.com']);

    expect(
      resolveCorsOrigins({
        FRONTEND_ORIGIN: 'http://localhost:3001, http://localhost:8080',
      }),
    ).toEqual(['http://localhost:3001', 'http://localhost:8080']);
  });

  it('resolves integer env values with fallback defaults', () => {
    expect(resolveIntegerEnv({ LIMIT: '250' }, 'LIMIT', 100)).toBe(250);
    expect(resolveIntegerEnv({ LIMIT: 'abc' }, 'LIMIT', 100)).toBe(100);
    expect(resolveIntegerEnv({}, 'LIMIT', 100, 0)).toBe(100);
  });


});
