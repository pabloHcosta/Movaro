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
var SupabaseAdminService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.SupabaseAdminService = void 0;
const common_1 = require("@nestjs/common");
const supabase_js_1 = require("@supabase/supabase-js");
const app_config_service_1 = require("../config/app-config.service");
let SupabaseAdminService = SupabaseAdminService_1 = class SupabaseAdminService {
    appConfig;
    logger = new common_1.Logger(SupabaseAdminService_1.name);
    client;
    constructor(appConfig) {
        this.appConfig = appConfig;
        if (!appConfig.isSupabaseConfigured) {
            this.logger.warn('Supabase server config is missing. API will keep running without Supabase.');
            this.client = null;
            return;
        }
        this.client = (0, supabase_js_1.createClient)(appConfig.supabaseUrl, appConfig.supabaseSecretKey, {
            auth: {
                autoRefreshToken: false,
                persistSession: false,
            },
        });
    }
    get isConfigured() {
        return this.client != null;
    }
    get admin() {
        if (!this.client) {
            throw new Error('Supabase server client is not configured.');
        }
        return this.client;
    }
};
exports.SupabaseAdminService = SupabaseAdminService;
exports.SupabaseAdminService = SupabaseAdminService = SupabaseAdminService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [app_config_service_1.AppConfigService])
], SupabaseAdminService);
//# sourceMappingURL=supabase-admin.service.js.map