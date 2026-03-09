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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppConfigService = void 0;
const common_1 = require("@nestjs/common");
let AppConfigService = class AppConfigService {
    config;
    constructor(config) {
        this.config = config;
    }
    get appName() {
        return this.config.app.name;
    }
    get nodeEnv() {
        return this.config.app.nodeEnv;
    }
    get host() {
        return this.config.server.host;
    }
    get port() {
        return this.config.server.port;
    }
    get globalPrefix() {
        return this.config.server.globalPrefix;
    }
    get allowedOrigins() {
        return this.config.server.allowedOrigins;
    }
    get bodyLimitBytes() {
        return this.config.server.bodyLimitBytes;
    }
    get rateLimitMax() {
        return this.config.server.rateLimitMax;
    }
    get rateLimitWindowMs() {
        return this.config.server.rateLimitWindowMs;
    }
    get trustProxy() {
        return this.config.server.trustProxy;
    }
    get outboundRequestTimeoutMs() {
        return this.config.server.outboundRequestTimeoutMs;
    }
    get supabaseUrl() {
        return this.config.supabase.url;
    }
    get supabaseSecretKey() {
        return this.config.supabase.secretKey;
    }
    get isSupabaseConfigured() {
        return this.config.supabase.configured;
    }
};
exports.AppConfigService = AppConfigService;
exports.AppConfigService = AppConfigService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, common_1.Inject)('APP_CONFIGURATION')),
    __metadata("design:paramtypes", [Object])
], AppConfigService);
//# sourceMappingURL=app-config.service.js.map