import { Global, Module } from '@nestjs/common';

import { AppConfigService } from './app-config.service';
import configuration from './configuration';

@Global()
@Module({
  providers: [
    {
      provide: 'APP_CONFIGURATION',
      useFactory: configuration,
    },
    AppConfigService,
  ],
  exports: [AppConfigService, 'APP_CONFIGURATION'],
})
export class AppConfigModule {}
