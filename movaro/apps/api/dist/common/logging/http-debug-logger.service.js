"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.HttpDebugLoggerService = void 0;
const common_1 = require("@nestjs/common");
const app_config_service_1 = require("../config/app-config.service");
const environment_enum_1 = require("../config/environment.enum");
let HttpDebugLoggerService = class HttpDebugLoggerService {
    appConfig;
    logger = new common_1.Logger('HttpDebug');
    constructor(appConfig) {
        this.appConfig = appConfig;
    }
    get isEnabled() {
        return (this.appConfig.nodeEnv === environment_enum_1.AppEnvironment.Development ||
            this.appConfig.nodeEnv === environment_enum_1.AppEnvironment.Staging);
    }
    logRequest(request) {
        if (!this.isEnabled) {
            return;
        }
        const source = this.resolveSource(request);
        const healthCheck = this.resolveHealthCheck(request);
        this.logger.log([
            healthCheck != null ? `[APP_HEALTH:${healthCheck}]` : '[REQUEST]',
            `${request.method ?? 'UNKNOWN'} ${request.url ?? '-'}`,
            `source=${source}`,
            `traceId=${request.traceId ?? '-'}`,
            `ip=${request.ip ?? '-'}`,
            `query=${this.stringify(request.query)}`,
            `params=${this.stringify(request.params)}`,
            `body=${this.stringify(request.body)}`,
        ].join(' | '));
    }
    logResponse(request, statusCode, durationMs, payload) {
        if (!this.isEnabled) {
            return;
        }
        const source = this.resolveSource(request);
        const healthCheck = this.resolveHealthCheck(request);
        this.logger.log([
            healthCheck != null ? '[APP_CONNECTED]' : '[RESPONSE]',
            `${request.method ?? 'UNKNOWN'} ${request.url ?? '-'} -> ${statusCode}`,
            `source=${source}`,
            `traceId=${request.traceId ?? '-'}`,
            `duration=${durationMs}ms`,
            `response=${this.stringify(payload)}`,
        ].join(' | '));
    }
    logError(request, statusCode, durationMs, error) {
        if (!this.isEnabled) {
            return;
        }
        const source = this.resolveSource(request);
        const healthCheck = this.resolveHealthCheck(request);
        this.logger.error([
            healthCheck != null ? '[APP_HEALTH_ERROR]' : '[ERROR]',
            `${request.method ?? 'UNKNOWN'} ${request.url ?? '-'} -> ${statusCode}`,
            `source=${source}`,
            `traceId=${request.traceId ?? '-'}`,
            `duration=${durationMs}ms`,
            `error=${this.stringify(this.normalizeError(error))}`,
        ].join(' | '));
    }
    normalizeError(error) {
        if (error instanceof Error) {
            return {
                name: error.name,
                message: error.message,
                stack: error.stack?.split('\n').slice(0, 6).join(' | '),
            };
        }
        if (typeof error === 'object' && error !== null) {
            return error;
        }
        return { value: error };
    }
    stringify(value) {
        if (value === undefined) {
            return '-';
        }
        try {
            const seen = new WeakSet();
            const serialized = JSON.stringify(value, (_key, currentValue) => {
                if (typeof currentValue === 'string' &&
                    currentValue.length > 500) {
                    return `${currentValue.slice(0, 500)}…`;
                }
                if (typeof currentValue === 'object' &&
                    currentValue !== null) {
                    if (seen.has(currentValue)) {
                        return '[Circular]';
                    }
                    seen.add(currentValue);
                }
                return currentValue;
            });
            if (serialized == null) {
                return String(value);
            }
            return serialized.length > 2000
                ? `${serialized.slice(0, 2000)}…`
                : serialized;
        }
        catch {
            return '[Unserializable]';
        }
    }
    resolveSource(request) {
        const clientHeader = request.headers?.['x-movaro-client'];
        const source = Array.isArray(clientHeader) ? clientHeader[0] : clientHeader;
        if (typeof source === 'string' && source.trim().length > 0) {
            return source;
        }
        return 'unknown';
    }
    resolveHealthCheck(request) {
        const healthHeader = request.headers?.['x-movaro-health-check'];
        const value = Array.isArray(healthHeader) ? healthHeader[0] : healthHeader;
        if (typeof value === 'string' && value.trim().length > 0) {
            return value;
        }
        return undefined;
    }
};
exports.HttpDebugLoggerService = HttpDebugLoggerService;
exports.HttpDebugLoggerService = HttpDebugLoggerService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [app_config_service_1.AppConfigService])
], HttpDebugLoggerService);
//# sourceMappingURL=http-debug-logger.service.js.map