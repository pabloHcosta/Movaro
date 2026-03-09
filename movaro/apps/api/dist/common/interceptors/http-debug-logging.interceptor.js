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
exports.HttpDebugLoggingInterceptor = void 0;
const common_1 = require("@nestjs/common");
const rxjs_1 = require("rxjs");
const http_debug_logger_service_1 = require("../logging/http-debug-logger.service");
let HttpDebugLoggingInterceptor = class HttpDebugLoggingInterceptor {
    debugLogger;
    constructor(debugLogger) {
        this.debugLogger = debugLogger;
    }
    intercept(context, next) {
        if (context.getType() !== 'http' || !this.debugLogger.isEnabled) {
            return next.handle();
        }
        const http = context.switchToHttp();
        const request = http.getRequest();
        const response = http.getResponse();
        const startedAt = Date.now();
        this.debugLogger.logRequest(request);
        return next.handle().pipe((0, rxjs_1.tap)((payload) => {
            this.debugLogger.logResponse(request, response.statusCode ?? common_1.HttpStatus.OK, Date.now() - startedAt, payload);
        }), (0, rxjs_1.catchError)((error) => {
            const statusCode = error instanceof common_1.HttpException
                ? error.getStatus()
                : common_1.HttpStatus.INTERNAL_SERVER_ERROR;
            this.debugLogger.logError(request, statusCode, Date.now() - startedAt, error);
            return (0, rxjs_1.throwError)(() => error);
        }));
    }
};
exports.HttpDebugLoggingInterceptor = HttpDebugLoggingInterceptor;
exports.HttpDebugLoggingInterceptor = HttpDebugLoggingInterceptor = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [http_debug_logger_service_1.HttpDebugLoggerService])
], HttpDebugLoggingInterceptor);
//# sourceMappingURL=http-debug-logging.interceptor.js.map