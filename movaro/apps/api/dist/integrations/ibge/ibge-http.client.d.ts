import { AppConfigService } from '../../common/config/app-config.service';
export declare class IbgeHttpClient {
    private readonly appConfigService;
    constructor(appConfigService: AppConfigService);
    private readonly baseUrl;
    get<T>(path: string): Promise<T>;
}
