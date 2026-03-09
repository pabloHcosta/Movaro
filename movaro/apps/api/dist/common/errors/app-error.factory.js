"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppErrorFactory = void 0;
const common_1 = require("@nestjs/common");
const app_exception_1 = require("./app-exception");
const error_code_enum_1 = require("./error-code.enum");
class AppErrorFactory {
    static cityNotFound(cityId) {
        return new app_exception_1.AppException({
            code: error_code_enum_1.ErrorCode.CityNotFound,
            status: common_1.HttpStatus.NOT_FOUND,
            message: `City "${cityId}" was not found in the Movaro catalog.`,
            userMessage: 'Nao encontramos essa cidade no catalogo atual do Movaro.',
        });
    }
    static validationError(message, userMessage = 'Revise os dados enviados e tente novamente.') {
        return new app_exception_1.AppException({
            code: error_code_enum_1.ErrorCode.ValidationError,
            status: common_1.HttpStatus.BAD_REQUEST,
            message,
            userMessage,
        });
    }
    static unauthorized(message = 'Authentication is required.', userMessage = 'Voce precisa entrar para continuar essa acao.') {
        return new app_exception_1.AppException({
            code: error_code_enum_1.ErrorCode.Unauthorized,
            status: common_1.HttpStatus.UNAUTHORIZED,
            message,
            userMessage,
        });
    }
    static resourceNotFound(resource, userMessage = 'Nao encontramos o recurso solicitado.') {
        return new app_exception_1.AppException({
            code: error_code_enum_1.ErrorCode.ResourceNotFound,
            status: common_1.HttpStatus.NOT_FOUND,
            message: `${resource} was not found.`,
            userMessage,
        });
    }
    static networkError(message, userMessage = 'Nao foi possivel consultar uma fonte externa agora. Tente novamente.') {
        return new app_exception_1.AppException({
            code: error_code_enum_1.ErrorCode.NetworkError,
            status: common_1.HttpStatus.BAD_GATEWAY,
            message,
            userMessage,
        });
    }
    static internal(message = 'Unexpected internal error.', userMessage = 'Algo saiu do esperado no servidor. Tente novamente em instantes.') {
        return new app_exception_1.AppException({
            code: error_code_enum_1.ErrorCode.InternalError,
            status: common_1.HttpStatus.INTERNAL_SERVER_ERROR,
            message,
            userMessage,
        });
    }
}
exports.AppErrorFactory = AppErrorFactory;
//# sourceMappingURL=app-error.factory.js.map