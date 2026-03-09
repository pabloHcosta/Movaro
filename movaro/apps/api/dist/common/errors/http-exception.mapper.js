"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.HttpExceptionMapper = void 0;
const common_1 = require("@nestjs/common");
const node_crypto_1 = require("node:crypto");
const app_exception_1 = require("./app-exception");
const app_error_factory_1 = require("./app-error.factory");
const error_code_enum_1 = require("./error-code.enum");
class HttpExceptionMapper {
    static toApiError(exception, host) {
        const traceId = this.getTraceId(host);
        if (exception instanceof app_exception_1.AppException) {
            const payload = exception.getPayload();
            return {
                code: payload.code,
                message: payload.message,
                userMessage: payload.userMessage,
                status: payload.status,
                traceId,
            };
        }
        if (exception instanceof common_1.BadRequestException) {
            return {
                code: error_code_enum_1.ErrorCode.ValidationError,
                message: this.extractMessage(exception),
                userMessage: 'Revise os dados enviados e tente novamente.',
                status: exception.getStatus(),
                traceId,
            };
        }
        if (exception instanceof common_1.UnauthorizedException) {
            return {
                code: error_code_enum_1.ErrorCode.Unauthorized,
                message: this.extractMessage(exception),
                userMessage: 'Voce precisa entrar para continuar essa acao.',
                status: exception.getStatus(),
                traceId,
            };
        }
        if (exception instanceof common_1.NotFoundException) {
            return {
                code: error_code_enum_1.ErrorCode.ResourceNotFound,
                message: this.extractMessage(exception),
                userMessage: 'Nao encontramos o recurso solicitado.',
                status: exception.getStatus(),
                traceId,
            };
        }
        if (exception instanceof common_1.HttpException) {
            return {
                code: error_code_enum_1.ErrorCode.InternalError,
                message: this.extractMessage(exception),
                userMessage: 'Nao foi possivel concluir a solicitacao agora.',
                status: exception.getStatus(),
                traceId,
            };
        }
        const fallback = app_error_factory_1.AppErrorFactory.internal(this.internalMessage(exception)).getPayload();
        return {
            code: fallback.code,
            message: fallback.message,
            userMessage: fallback.userMessage,
            status: fallback.status,
            traceId,
        };
    }
    static extractMessage(exception) {
        const response = exception.getResponse();
        if (typeof response === 'string') {
            return response;
        }
        if (response &&
            typeof response === 'object' &&
            'message' in response &&
            typeof response.message === 'string') {
            return response.message;
        }
        if (response &&
            typeof response === 'object' &&
            'message' in response &&
            Array.isArray(response.message)) {
            return response.message.join(', ');
        }
        return exception.message ?? common_1.HttpStatus[exception.getStatus()];
    }
    static getTraceId(host) {
        const request = host.switchToHttp().getRequest();
        return (request.traceId ??
            request.raw?.traceId ??
            request.id ??
            request.raw?.id ??
            (0, node_crypto_1.randomUUID)());
    }
    static internalMessage(exception) {
        const isDevelopment = process.env.NODE_ENV === 'development';
        if (!isDevelopment) {
            return 'Unexpected internal error.';
        }
        return exception instanceof Error
            ? exception.message
            : 'Unexpected internal error.';
    }
}
exports.HttpExceptionMapper = HttpExceptionMapper;
//# sourceMappingURL=http-exception.mapper.js.map