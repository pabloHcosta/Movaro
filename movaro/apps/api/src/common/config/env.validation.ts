import { AppEnvironment } from './environment.enum';

type EnvRecord = Record<string, string | undefined>;

export function validateEnvironment(config: EnvRecord): EnvRecord {
  const nodeEnv = config.NODE_ENV ?? AppEnvironment.Development;
  const allowedEnvironments = Object.values(AppEnvironment);

  if (!allowedEnvironments.includes(nodeEnv as AppEnvironment)) {
    throw new Error(
      `Invalid NODE_ENV "${nodeEnv}". Expected one of: ${allowedEnvironments.join(', ')}`,
    );
  }

  if (config.PORT !== undefined) {
    const port = Number(config.PORT);

    if (!Number.isInteger(port) || port <= 0) {
      throw new Error('PORT must be a positive integer.');
    }
  }

  if (config.HOST !== undefined && config.HOST.trim().length === 0) {
    throw new Error('HOST cannot be empty.');
  }

  if (config.APP_NAME !== undefined && config.APP_NAME.trim().length === 0) {
    throw new Error('APP_NAME cannot be empty.');
  }

  if (config.ALLOWED_ORIGINS !== undefined) {
    const origins = config.ALLOWED_ORIGINS.split(',')
      .map((item) => item.trim())
      .filter((item) => item.length > 0);

    for (const origin of origins) {
      try {
        const parsed = new URL(origin);
        if (!['http:', 'https:'].includes(parsed.protocol)) {
          throw new Error();
        }
      } catch {
        throw new Error(
          `ALLOWED_ORIGINS contains an invalid origin: "${origin}".`,
        );
      }
    }
  }

  validatePositiveInteger(config.BODY_LIMIT_BYTES, 'BODY_LIMIT_BYTES');
  validatePositiveInteger(config.RATE_LIMIT_MAX, 'RATE_LIMIT_MAX');
  validatePositiveInteger(config.RATE_LIMIT_WINDOW_MS, 'RATE_LIMIT_WINDOW_MS');
  validatePositiveInteger(
    config.OUTBOUND_REQUEST_TIMEOUT_MS,
    'OUTBOUND_REQUEST_TIMEOUT_MS',
  );
  validateBoolean(config.TRUST_PROXY, 'TRUST_PROXY');
  validateSupabaseConfig(config);

  return {
    ...config,
    NODE_ENV: nodeEnv,
    PORT: config.PORT ?? '3000',
    HOST: config.HOST ?? '0.0.0.0',
    APP_NAME: config.APP_NAME ?? 'Movaro API',
    ALLOWED_ORIGINS: config.ALLOWED_ORIGINS ?? '',
    BODY_LIMIT_BYTES: config.BODY_LIMIT_BYTES ?? '1048576',
    RATE_LIMIT_MAX: config.RATE_LIMIT_MAX ?? '120',
    RATE_LIMIT_WINDOW_MS: config.RATE_LIMIT_WINDOW_MS ?? '60000',
    TRUST_PROXY: config.TRUST_PROXY ?? 'false',
    OUTBOUND_REQUEST_TIMEOUT_MS: config.OUTBOUND_REQUEST_TIMEOUT_MS ?? '5000',
  };
}

function validateSupabaseConfig(config: EnvRecord): void {
  const supabaseUrl = config.SUPABASE_URL?.trim();
  const supabaseSecretKey = config.SUPABASE_SECRET_KEY?.trim();
  const supabaseServiceRoleKey = config.SUPABASE_SERVICE_ROLE_KEY?.trim();
  const effectiveSecret = supabaseSecretKey || supabaseServiceRoleKey;

  if (Boolean(supabaseUrl) != Boolean(effectiveSecret)) {
    throw new Error(
      'SUPABASE_URL and SUPABASE_SECRET_KEY (or SUPABASE_SERVICE_ROLE_KEY) must be provided together.',
    );
  }

  if (!supabaseUrl) {
    return;
  }

  try {
    const parsed = new URL(supabaseUrl);
    if (!['http:', 'https:'].includes(parsed.protocol)) {
      throw new Error();
    }
  } catch {
    throw new Error('SUPABASE_URL must be a valid absolute URL.');
  }
}

function validatePositiveInteger(value: string | undefined, key: string): void {
  if (value === undefined) {
    return;
  }

  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed <= 0) {
    throw new Error(`${key} must be a positive integer.`);
  }
}

function validateBoolean(value: string | undefined, key: string): void {
  if (value === undefined) {
    return;
  }

  if (value !== 'true' && value !== 'false') {
    throw new Error(`${key} must be "true" or "false".`);
  }
}
