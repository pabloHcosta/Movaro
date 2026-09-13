import { Injectable, Logger } from '@nestjs/common';

import { SupabaseAdminService } from '../../../common/supabase/supabase-admin.service';
import { UpsertSiteAnalyticsDto } from '../presentation/dto/upsert-site-analytics.dto';

@Injectable()
export class SiteAnalyticsService {
  private readonly logger = new Logger(SiteAnalyticsService.name);

  constructor(private readonly supabase: SupabaseAdminService) {}

  async upsert(body: UpsertSiteAnalyticsDto): Promise<{ accepted: boolean }> {
    if (!this.supabase.isConfigured) {
      return { accepted: false };
    }

    const { error: sessionError } = await this.supabase.admin
      .from('landing_page_sessions')
      .upsert({
        session_id: body.sessionId,
        locale: body.locale,
        started_at: body.startedAt,
        last_seen_at: body.lastSeenAt,
        active_seconds: body.activeSeconds,
        max_scroll_percent: body.maxScrollPercent,
        referrer_host: body.referrerHost ?? null,
        utm_source: body.utmSource ?? null,
        utm_medium: body.utmMedium ?? null,
        utm_campaign: body.utmCampaign ?? null,
        converted: body.converted,
        converted_at: body.convertedAt ?? null,
      });

    if (sessionError) {
      this.logger.warn(`Landing session was not stored: ${sessionError.message}`);
      return { accepted: false };
    }

    if (body.sections.length === 0) {
      return { accepted: true };
    }

    const { error: sectionError } = await this.supabase.admin
      .from('landing_page_section_engagement')
      .upsert(
        body.sections.map((section) => ({
          session_id: body.sessionId,
          section_key: section.sectionKey,
          active_seconds: section.activeSeconds,
          view_count: section.viewCount,
          max_visibility_percent: section.maxVisibilityPercent,
        })),
        { onConflict: 'session_id,section_key' },
      );

    if (sectionError) {
      this.logger.warn(
        `Landing section engagement was not stored: ${sectionError.message}`,
      );
      return { accepted: false };
    }

    return { accepted: true };
  }
}
