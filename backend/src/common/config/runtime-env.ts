import './preload-env';

export type ThrottleSettings = {
  ttl: number;
  limit: number;
};

const DEFAULT_GLOBAL_THROTTLE: ThrottleSettings = {
  ttl: 60_000,
  limit: 120,
};

const DEFAULT_FHIR_WEBHOOK_THROTTLE: ThrottleSettings = {
  ttl: 60_000,
  limit: 120,
};

const DEFAULT_GATEWAY_REQUEST_DELAY_MS = 500;

export function parseDelimitedList(value: string | undefined): string[] {
  if (typeof value !== 'string') {
    return [];
  }

  return value
    .split(',')
    .map((item) => item.trim())
    .filter((item) => item.length > 0);
}

export function resolveCorsOrigins(
  env: NodeJS.ProcessEnv = process.env,
): string[] {
  const allowedOrigins = parseDelimitedList(env.CORS_ALLOWED_ORIGINS);
  if (allowedOrigins.length > 0) {
    return allowedOrigins;
  }

  return parseDelimitedList(env.FRONTEND_ORIGIN);
}

export function resolveIntegerEnv(
  env: NodeJS.ProcessEnv,
  key: string,
  fallback: number,
  minimumValue = 1,
): number {
  const rawValue = env[key];
  if (typeof rawValue !== 'string' || rawValue.trim().length === 0) {
    return fallback;
  }

  const parsedValue = Number(rawValue);
  if (!Number.isInteger(parsedValue) || parsedValue < minimumValue) {
    return fallback;
  }

  return parsedValue;
}

export function resolveThrottleSettings(
  env: NodeJS.ProcessEnv,
  prefix: string,
  fallback: ThrottleSettings,
): ThrottleSettings {
  return {
    ttl: resolveIntegerEnv(env, `${prefix}_TTL_MS`, fallback.ttl),
    limit: resolveIntegerEnv(env, `${prefix}_LIMIT`, fallback.limit),
  };
}

export const GLOBAL_THROTTLE_SETTINGS = resolveThrottleSettings(
  process.env,
  'THROTTLER',
  DEFAULT_GLOBAL_THROTTLE,
);

export const FHIR_WEBHOOK_THROTTLE_SETTINGS = resolveThrottleSettings(
  process.env,
  'FHIR_WEBHOOK_THROTTLER',
  DEFAULT_FHIR_WEBHOOK_THROTTLE,
);

export const GATEWAY_REQUEST_DELAY_MS = resolveIntegerEnv(
  process.env,
  'GATEWAY_REQUEST_DELAY_MS',
  DEFAULT_GATEWAY_REQUEST_DELAY_MS,
  0,
);
