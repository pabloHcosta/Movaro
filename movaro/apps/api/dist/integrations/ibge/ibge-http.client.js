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
exports.IbgeHttpClient = void 0;
const common_1 = require("@nestjs/common");
const app_error_factory_1 = require("../../common/errors/app-error.factory");
const app_config_service_1 = require("../../common/config/app-config.service");
let IbgeHttpClient = class IbgeHttpClient {
    appConfigService;
    constructor(appConfigService) {
        this.appConfigService = appConfigService;
    }
    baseUrl = 'https://servicodados.ibge.gov.br/api/v1';
    async get(path) {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), this.appConfigService.outboundRequestTimeoutMs);
        try {
            const response = await fetch(`${this.baseUrl}${path}`, {
                headers: {
                    accept: 'application/json',
                },
                signal: controller.signal,
            });
            if (!response.ok) {
                throw app_error_factory_1.AppErrorFactory.networkError(`IBGE request failed with status ${response.status}.`);
            }
            return (await response.json());
        }
        catch (error) {
            if (error instanceof Error && 'getPayload' in error) {
                throw error;
            }
            if (error instanceof Error && error.name === 'AbortError') {
                throw app_error_factory_1.AppErrorFactory.networkError('IBGE request timed out.');
            }
            throw app_error_factory_1.AppErrorFactory.networkError(error instanceof Error
                ? error.message
                : 'Unable to reach IBGE data source.');
        }
        finally {
            clearTimeout(timeout);
        }
    }
};
exports.IbgeHttpClient = IbgeHttpClient;
exports.IbgeHttpClient = IbgeHttpClient = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [app_config_service_1.AppConfigService])
], IbgeHttpClient);
//# sourceMappingURL=ibge-http.client.js.map