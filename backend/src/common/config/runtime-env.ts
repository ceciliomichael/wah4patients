import './preload-env';



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



export const GATEWAY_REQUEST_DELAY_MS = resolveIntegerEnv(
  process.env,
  'GATEWAY_REQUEST_DELAY_MS',
  DEFAULT_GATEWAY_REQUEST_DELAY_MS,
  0,
);
