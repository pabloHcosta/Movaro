import { AppConfigService } from '../config/app-config.service';
type RequestLike = {
    method?: string;
    url?: string;
    query?: unknown;
    params?: unknown;
    body?: unknown;
    traceId?: string;
    ip?: string;
    headers?: Record<string, string | string[] | undefined>;
};
export declare class HttpDebugLoggerService {
    private readonly appConfig;
    private readonly logger;
    constructor(appConfig: AppConfigService);
    get isEnabled(): boolean;
    logRequest(request: RequestLike): void;
    logResponse(request: RequestLike, statusCode: number, durationMs: number, payload: unknown): void;
    logError(request: RequestLike, statusCode: number, durationMs: number, error: unknown): void;
    private normalizeError;
    private stringify;
    private resolveSource;
    private resolveHealthCheck;
}
export {};
