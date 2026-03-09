import { APP_GLOBAL_PREFIX } from '../constants/app.constants';
import { AppEnvironment } from './environment.enum';
import { AppConfiguration } from './types/app-configuration.type';

export default (): AppConfiguration => ({
  app: {
    name: process.env.APP_NAME ?? 'Movaro API',
    nodeEnv:
      (process.env.NODE_ENV as AppEnvironment) ?? AppEnvironment.Development,
  },
  server: {
    host: process.env.HOST ?? '0.0.0.0',
    port: Number(process.env.PORT ?? 3000),
    globalPrefix: APP_GLOBAL_PREFIX,
    allowedOrigins: (process.env.ALLOWED_ORIGINS ?? '')
      .split(',')
      .map((item) => item.trim())
      .filter((item) => item.length > 0),
    bodyLimitBytes: Number(process.env.BODY_LIMIT_BYTES ?? 1048576),
    rateLimitMax: Number(process.env.RATE_LIMIT_MAX ?? 120),
    rateLimitWindowMs: Number(process.env.RATE_LIMIT_WINDOW_MS ?? 60000),
    trustProxy: (process.env.TRUST_PROXY ?? 'false') === 'true',
    outboundRequestTimeoutMs: Number(
      process.env.OUTBOUND_REQUEST_TIMEOUT_MS ?? 5000,
    ),
  },
  supabase: {
    url: process.env.SUPABASE_URL?.trim() || null,
    secretKey:
      process.env.SUPABASE_SECRET_KEY?.trim() ||
      process.env.SUPABASE_SERVICE_ROLE_KEY?.trim() ||
      null,
    configured: Boolean(
      process.env.SUPABASE_URL?.trim() &&
          (process.env.SUPABASE_SECRET_KEY?.trim() ||
              process.env.SUPABASE_SERVICE_ROLE_KEY?.trim()),
    ),
  },
});
