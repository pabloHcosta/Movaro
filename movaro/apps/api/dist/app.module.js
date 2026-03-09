"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const core_1 = require("@nestjs/core");
const app_config_module_1 = require("./common/config/app-config.module");
const env_file_paths_1 = require("./common/config/env-file-paths");
const env_validation_1 = require("./common/config/env.validation");
const global_exception_filter_1 = require("./common/filters/global-exception.filter");
const api_response_interceptor_1 = require("./common/interceptors/api-response.interceptor");
const http_debug_logging_interceptor_1 = require("./common/interceptors/http-debug-logging.interceptor");
const http_debug_logger_service_1 = require("./common/logging/http-debug-logger.service");
const trace_id_middleware_1 = require("./common/middleware/trace-id.middleware");
const supabase_admin_service_1 = require("./common/supabase/supabase-admin.service");
const cities_module_1 = require("./modules/cities/cities.module");
const health_module_1 = require("./modules/health/health.module");
const migration_module_1 = require("./modules/migration/migration.module");
let AppModule = class AppModule {
    configure(consumer) {
        consumer.apply(trace_id_middleware_1.TraceIdMiddleware).forRoutes('*');
    }
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_1.ConfigModule.forRoot({
                isGlobal: true,
                cache: true,
                expandVariables: true,
                envFilePath: (0, env_file_paths_1.getEnvFilePaths)(),
                validate: env_validation_1.validateEnvironment,
            }),
            app_config_module_1.AppConfigModule,
            cities_module_1.CitiesModule,
            health_module_1.HealthModule,
            migration_module_1.MigrationModule,
        ],
        providers: [
            http_debug_logger_service_1.HttpDebugLoggerService,
            supabase_admin_service_1.SupabaseAdminService,
            {
                provide: core_1.APP_FILTER,
                useClass: global_exception_filter_1.GlobalExceptionFilter,
            },
            {
                provide: core_1.APP_INTERCEPTOR,
                useClass: http_debug_logging_interceptor_1.HttpDebugLoggingInterceptor,
            },
            {
                provide: core_1.APP_INTERCEPTOR,
                useClass: api_response_interceptor_1.ApiResponseInterceptor,
            },
        ],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map