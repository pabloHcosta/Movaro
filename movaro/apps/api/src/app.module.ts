import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_FILTER, APP_INTERCEPTOR } from '@nestjs/core';

import { AppConfigModule } from './common/config/app-config.module';
import { getEnvFilePaths } from './common/config/env-file-paths';
import { validateEnvironment } from './common/config/env.validation';
import { GlobalExceptionFilter } from './common/filters/global-exception.filter';
import { ApiResponseInterceptor } from './common/interceptors/api-response.interceptor';
import { HttpDebugLoggingInterceptor } from './common/interceptors/http-debug-logging.interceptor';
import { HttpDebugLoggerService } from './common/logging/http-debug-logger.service';
import { TraceIdMiddleware } from './common/middleware/trace-id.middleware';
import { SupabaseAdminService } from './common/supabase/supabase-admin.service';
import { CitiesModule } from './modules/cities/cities.module';
import { HealthModule } from './modules/health/health.module';
import { MigrationModule } from './modules/migration/migration.module';
import { ReferenceModule } from './modules/reference/reference.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      cache: true,
      expandVariables: true,
      envFilePath: getEnvFilePaths(),
      validate: validateEnvironment,
    }),
    AppConfigModule,
    CitiesModule,
    HealthModule,
    MigrationModule,
    ReferenceModule,
  ],
  providers: [
    HttpDebugLoggerService,
    SupabaseAdminService,
    {
      provide: APP_FILTER,
      useClass: GlobalExceptionFilter,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: HttpDebugLoggingInterceptor,
    },
    {
      provide: APP_INTERCEPTOR,
      useClass: ApiResponseInterceptor,
    },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    consumer.apply(TraceIdMiddleware).forRoutes('*');
  }
}
