import { AppConfigService } from '../../common/config/app-config.service';
export declare class HealthService {
    private readonly appConfigService;
    constructor(appConfigService: AppConfigService);
    check(): {
        status: string;
        service: string;
        environment: import("../../common/config/environment.enum").AppEnvironment.Development;
        timestamp: string;
    } | {
        status: string;
        timestamp: string;
        service?: undefined;
        environment?: undefined;
    };
}
