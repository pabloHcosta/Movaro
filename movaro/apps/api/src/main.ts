import helmet from '@fastify/helmet';
import rateLimit from '@fastify/rate-limit';
import { Logger, ValidationPipe, VersioningType } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import {
  FastifyAdapter,
  NestFastifyApplication,
} from '@nestjs/platform-fastify';

import { AppModule } from './app.module';
import {
  APP_GLOBAL_PREFIX,
  API_VERSION,
} from './common/constants/app.constants';
import { AppConfigService } from './common/config/app-config.service';

const writeMethods = new Set(['POST', 'PUT', 'PATCH']);
const routeLimitBuckets = new Map<string, { count: number; resetAt: number }>();

type RouteLimitRule = {
  key: string;
  path: string;
  methods: string[];
  max: number;
  windowMs: number;
};

const routeLimitRules: RouteLimitRule[] = [
  {
    key: 'migration-plan',
    path: `/${APP_GLOBAL_PREFIX}/v${API_VERSION}/migration/plan`,
    methods: ['POST'],
    max: 20,
    windowMs: 10 * 60 * 1000,
  },
  {
    key: 'product-analytics',
    path: `/${APP_GLOBAL_PREFIX}/v${API_VERSION}/product-analytics/events`,
    methods: ['POST'],
    max: 30,
    windowMs: 10 * 60 * 1000,
  },
  {
    key: 'city-search',
    path: `/${APP_GLOBAL_PREFIX}/v${API_VERSION}/cities/search`,
    methods: ['GET'],
    max: 45,
    windowMs: 60 * 1000,
  },
  {
    key: 'health',
    path: `/${APP_GLOBAL_PREFIX}/v${API_VERSION}/health`,
    methods: ['GET'],
    max: 30,
    windowMs: 60 * 1000,
  },
];

function pruneExpiredRouteLimitBuckets(now: number): void {
  for (const [key, value] of routeLimitBuckets.entries()) {
    if (value.resetAt <= now) {
      routeLimitBuckets.delete(key);
    }
  }
}

async function bootstrap() {
  const bodyLimitBytes = Number(process.env.BODY_LIMIT_BYTES ?? 1024 * 1024);
  const trustProxy = process.env.TRUST_PROXY === 'true';
  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter({
      bodyLimit: bodyLimitBytes,
      requestTimeout: 10000,
      keepAliveTimeout: 5000,
      trustProxy,
    }),
    {
      bufferLogs: true,
    },
  );

  const logger = new Logger('Bootstrap');
  const appConfig = app.get(AppConfigService);
  const isProductionLike = appConfig.nodeEnv !== 'development';
  const fastify = app.getHttpAdapter().getInstance();

  fastify.addHook('onRequest', (request, reply, done) => {
    if (!writeMethods.has(request.method)) {
      done();
      return;
    }

    const contentTypeHeader = request.headers['content-type'];
    const contentType = Array.isArray(contentTypeHeader)
      ? contentTypeHeader[0]
      : contentTypeHeader;

    if (
      typeof contentType != 'string' ||
      contentType.trim().length === 0 ||
      contentType.includes(',') ||
      contentType.includes('\t')
    ) {
      void reply.code(415).send({
        success: false,
        error: {
          code: 'UNSUPPORTED_MEDIA_TYPE',
          message: 'Invalid content-type header.',
          userMessage: 'Envie os dados em JSON para concluir esta acao.',
          status: 415,
          traceId: request.id,
        },
      });
      return;
    }

    const normalizedContentType = contentType.split(';', 1)[0]?.trim();
    if (normalizedContentType != 'application/json') {
      void reply.code(415).send({
        success: false,
        error: {
          code: 'UNSUPPORTED_MEDIA_TYPE',
          message: 'Only application/json is accepted.',
          userMessage: 'Envie os dados em JSON para concluir esta acao.',
          status: 415,
          traceId: request.id,
        },
      });
      return;
    }

    done();
  });
  fastify.addHook('preHandler', (request, reply, done) => {
    const path = request.url.split('?', 1)[0];
    const rule = routeLimitRules.find(
      (item) => item.path === path && item.methods.includes(request.method),
    );

    if (!rule) {
      done();
      return;
    }

    const now = Date.now();
    if (routeLimitBuckets.size > 5000) {
      pruneExpiredRouteLimitBuckets(now);
    }

    const bucketKey = `${rule.key}:${request.ip}`;
    const current = routeLimitBuckets.get(bucketKey);

    if (!current || current.resetAt <= now) {
      routeLimitBuckets.set(bucketKey, {
        count: 1,
        resetAt: now + rule.windowMs,
      });
      done();
      return;
    }

    if (current.count >= rule.max) {
      void reply.code(429).send({
        success: false,
        error: {
          code: 'RATE_LIMITED',
          message: `Too many requests for ${rule.key}.`,
          userMessage:
            'Voce fez tentativas demais em pouco tempo. Aguarde um pouco e tente novamente.',
          status: 429,
          traceId: request.id,
        },
      });
      return;
    }

    current.count += 1;
    routeLimitBuckets.set(bucketKey, current);
    done();
  });

  await app.register(helmet as never, {
    global: true,
    contentSecurityPolicy: false,
    crossOriginEmbedderPolicy: false,
    hsts: isProductionLike,
    referrerPolicy: {
      policy: 'no-referrer',
    },
  });
  await app.register(rateLimit as never, {
    global: true,
    max: appConfig.rateLimitMax,
    timeWindow: appConfig.rateLimitWindowMs,
    allowList: (_request, key) => key === '127.0.0.1' || key === '::1',
  });

  app.enableCors({
    origin: (origin, callback) => {
      // Native mobile clients typically do not send an Origin header.
      if (!origin) {
        callback(null, true);
        return;
      }

      if (appConfig.allowedOrigins.length == 0 && !isProductionLike) {
        callback(null, true);
        return;
      }

      callback(null, appConfig.allowedOrigins.includes(origin));
    },
    methods: ['GET', 'POST', 'OPTIONS'],
    allowedHeaders: [
      'content-type',
      'x-trace-id',
      'x-movaro-client',
      'x-movaro-environment',
      'x-movaro-health-check',
    ],
    exposedHeaders: ['x-trace-id'],
    credentials: false,
    maxAge: 86400,
  });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: false,
      },
    }),
  );
  app.setGlobalPrefix(APP_GLOBAL_PREFIX);
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: API_VERSION,
  });
  await app.listen({
    host: appConfig.host,
    port: appConfig.port,
  });

  logger.log(
    `Movaro API running on http://${appConfig.host}:${appConfig.port}/${APP_GLOBAL_PREFIX}/v${API_VERSION}`,
  );
  logger.log(`Environment: ${appConfig.nodeEnv}`);
  logger.log(
    `Health check available at http://${appConfig.host}:${appConfig.port}/${APP_GLOBAL_PREFIX}/v${API_VERSION}/health`,
  );
  logger.log(
    `Supabase: ${appConfig.isSupabaseConfigured ? 'configured' : 'not configured'}`,
  );
}

void bootstrap();
