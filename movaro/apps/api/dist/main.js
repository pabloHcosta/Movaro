"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const helmet_1 = __importDefault(require("@fastify/helmet"));
const rate_limit_1 = __importDefault(require("@fastify/rate-limit"));
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const platform_fastify_1 = require("@nestjs/platform-fastify");
const app_module_1 = require("./app.module");
const app_constants_1 = require("./common/constants/app.constants");
const app_config_service_1 = require("./common/config/app-config.service");
const writeMethods = new Set(['POST', 'PUT', 'PATCH']);
const routeLimitBuckets = new Map();
const routeLimitRules = [
    {
        key: 'migration-plan',
        path: `/${app_constants_1.APP_GLOBAL_PREFIX}/v${app_constants_1.API_VERSION}/migration/plan`,
        methods: ['POST'],
        max: 20,
        windowMs: 10 * 60 * 1000,
    },
    {
        key: 'city-search',
        path: `/${app_constants_1.APP_GLOBAL_PREFIX}/v${app_constants_1.API_VERSION}/cities/search`,
        methods: ['GET'],
        max: 45,
        windowMs: 60 * 1000,
    },
    {
        key: 'health',
        path: `/${app_constants_1.APP_GLOBAL_PREFIX}/v${app_constants_1.API_VERSION}/health`,
        methods: ['GET'],
        max: 30,
        windowMs: 60 * 1000,
    },
];
function pruneExpiredRouteLimitBuckets(now) {
    for (const [key, value] of routeLimitBuckets.entries()) {
        if (value.resetAt <= now) {
            routeLimitBuckets.delete(key);
        }
    }
}
async function bootstrap() {
    const bodyLimitBytes = Number(process.env.BODY_LIMIT_BYTES ?? 1024 * 1024);
    const trustProxy = process.env.TRUST_PROXY === 'true';
    const app = await core_1.NestFactory.create(app_module_1.AppModule, new platform_fastify_1.FastifyAdapter({
        bodyLimit: bodyLimitBytes,
        requestTimeout: 10000,
        keepAliveTimeout: 5000,
        trustProxy,
    }), {
        bufferLogs: true,
    });
    const logger = new common_1.Logger('Bootstrap');
    const appConfig = app.get(app_config_service_1.AppConfigService);
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
        if (typeof contentType != 'string' ||
            contentType.trim().length === 0 ||
            contentType.includes(',') ||
            contentType.includes('\t')) {
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
        const rule = routeLimitRules.find((item) => item.path === path && item.methods.includes(request.method));
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
                    userMessage: 'Voce fez tentativas demais em pouco tempo. Aguarde um pouco e tente novamente.',
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
    await app.register(helmet_1.default, {
        global: true,
        contentSecurityPolicy: false,
        crossOriginEmbedderPolicy: false,
        hsts: isProductionLike,
        referrerPolicy: {
            policy: 'no-referrer',
        },
    });
    await app.register(rate_limit_1.default, {
        global: true,
        max: appConfig.rateLimitMax,
        timeWindow: appConfig.rateLimitWindowMs,
        allowList: (_request, key) => key === '127.0.0.1' || key === '::1',
    });
    app.enableCors({
        origin: (origin, callback) => {
            if (!origin && !isProductionLike) {
                callback(null, true);
                return;
            }
            if (!origin) {
                callback(new Error('Origin header is required.'), false);
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
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
        transformOptions: {
            enableImplicitConversion: false,
        },
    }));
    app.setGlobalPrefix(app_constants_1.APP_GLOBAL_PREFIX);
    app.enableVersioning({
        type: common_1.VersioningType.URI,
        defaultVersion: app_constants_1.API_VERSION,
    });
    await app.listen({
        host: appConfig.host,
        port: appConfig.port,
    });
    logger.log(`Movaro API running on http://${appConfig.host}:${appConfig.port}/${app_constants_1.APP_GLOBAL_PREFIX}/v${app_constants_1.API_VERSION}`);
    logger.log(`Environment: ${appConfig.nodeEnv}`);
    logger.log(`Health check available at http://${appConfig.host}:${appConfig.port}/${app_constants_1.APP_GLOBAL_PREFIX}/v${app_constants_1.API_VERSION}/health`);
    logger.log(`Supabase: ${appConfig.isSupabaseConfigured ? 'configured' : 'not configured'}`);
}
void bootstrap();
//# sourceMappingURL=main.js.map