import { SupabaseClient } from '@supabase/supabase-js';
import { AppConfigService } from '../config/app-config.service';
export declare class SupabaseAdminService {
    private readonly appConfig;
    private readonly logger;
    private readonly client;
    constructor(appConfig: AppConfigService);
    get isConfigured(): boolean;
    get admin(): SupabaseClient;
}
