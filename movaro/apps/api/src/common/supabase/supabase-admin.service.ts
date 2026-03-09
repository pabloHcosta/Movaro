import { Injectable, Logger } from '@nestjs/common';
import { SupabaseClient, createClient } from '@supabase/supabase-js';

import { AppConfigService } from '../config/app-config.service';

@Injectable()
export class SupabaseAdminService {
  private readonly logger = new Logger(SupabaseAdminService.name);
  private readonly client: SupabaseClient | null;

  constructor(private readonly appConfig: AppConfigService) {
    if (!appConfig.isSupabaseConfigured) {
      this.logger.warn(
        'Supabase server config is missing. API will keep running without Supabase.',
      );
      this.client = null;
      return;
    }

    this.client = createClient(
      appConfig.supabaseUrl!,
      appConfig.supabaseSecretKey!,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      },
    );
  }

  get isConfigured(): boolean {
    return this.client != null;
  }

  get admin(): SupabaseClient {
    if (!this.client) {
      throw new Error('Supabase server client is not configured.');
    }

    return this.client;
  }
}
