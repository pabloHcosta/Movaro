import { Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';

import { SupabaseAdminService } from '../../../common/supabase/supabase-admin.service';
import { RegisterLaunchInterestDto } from '../presentation/dto/register-launch-interest.dto';

@Injectable()
export class LaunchInterestsService {
  private readonly logger = new Logger(LaunchInterestsService.name);

  constructor(private readonly supabase: SupabaseAdminService) {}

  async register(body: RegisterLaunchInterestDto): Promise<{ accepted: true }> {
    if (!this.supabase.isConfigured) {
      throw new ServiceUnavailableException('Launch interest storage is unavailable.');
    }

    const email = body.email.trim().toLowerCase();
    const now = new Date().toISOString();
    const { error } = await this.supabase.admin.from('launch_interests').upsert(
      {
        email,
        locale: body.locale,
        source: 'landing_page',
        status: 'interested',
        analytics_session_id: body.analyticsSessionId ?? null,
        last_submitted_at: now,
        updated_at: now,
      },
      { onConflict: 'email' },
    );

    if (error) {
      this.logger.warn(`Launch interest was not stored: ${error.message}`);
      throw new ServiceUnavailableException('Launch interest storage is unavailable.');
    }

    return { accepted: true };
  }
}
