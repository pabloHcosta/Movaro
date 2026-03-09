import { Injectable } from '@nestjs/common';

import { AppConfigService } from '../../common/config/app-config.service';

@Injectable()
export class HealthService {
  constructor(private readonly appConfigService: AppConfigService) {}

  check() {
    if (this.appConfigService.nodeEnv === 'development') {
      return {
        status: 'ok',
        service: this.appConfigService.appName,
        environment: this.appConfigService.nodeEnv,
        timestamp: new Date().toISOString(),
      };
    }

    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
    };
  }
}
