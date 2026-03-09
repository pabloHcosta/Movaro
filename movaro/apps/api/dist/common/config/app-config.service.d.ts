import { AppEnvironment } from './environment.enum';
import type { AppConfiguration } from './types/app-configuration.type';
export declare class AppConfigService {
    private readonly config;
    constructor(config: AppConfiguration);
    get appName(): string;
    get nodeEnv(): AppEnvironment;
    get host(): string;
    get port(): number;
    get globalPrefix(): string;
    get allowedOrigins(): string[];
    get bodyLimitBytes(): number;
    get rateLimitMax(): number;
    get rateLimitWindowMs(): number;
    get trustProxy(): boolean;
    get outboundRequestTimeoutMs(): number;
    get supabaseUrl(): string | null;
    get supabaseSecretKey(): string | null;
    get isSupabaseConfigured(): boolean;
}
