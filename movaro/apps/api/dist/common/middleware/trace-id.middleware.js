"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.TraceIdMiddleware = void 0;
const common_1 = require("@nestjs/common");
const node_crypto_1 = require("node:crypto");
let TraceIdMiddleware = class TraceIdMiddleware {
    use(req, res, next) {
        const requestTraceId = req.headers['x-trace-id'];
        const traceId = typeof requestTraceId === 'string' && isSafeTraceId(requestTraceId)
            ? requestTraceId.trim()
            : (0, node_crypto_1.randomUUID)();
        req.traceId = traceId;
        res.setHeader('x-trace-id', traceId);
        next();
    }
};
exports.TraceIdMiddleware = TraceIdMiddleware;
exports.TraceIdMiddleware = TraceIdMiddleware = __decorate([
    (0, common_1.Injectable)()
], TraceIdMiddleware);
function isSafeTraceId(value) {
    const trimmed = value.trim();
    return (trimmed.length > 0 &&
        trimmed.length <= 128 &&
        /^[a-zA-Z0-9-]+$/.test(trimmed));
}
//# sourceMappingURL=trace-id.middleware.js.map