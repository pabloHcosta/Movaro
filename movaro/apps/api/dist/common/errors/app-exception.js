"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppException = void 0;
const common_1 = require("@nestjs/common");
class AppException extends common_1.HttpException {
    payload;
    constructor(payload) {
        super({
            code: payload.code,
            message: payload.message,
            userMessage: payload.userMessage,
            status: payload.status,
        }, payload.status);
        this.payload = payload;
    }
    getPayload() {
        return this.payload;
    }
}
exports.AppException = AppException;
//# sourceMappingURL=app-exception.js.map