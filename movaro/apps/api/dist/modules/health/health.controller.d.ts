import { HealthService } from './health.service';
export declare class HealthController {
    private readonly healthService;
    constructor(healthService: HealthService);
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
