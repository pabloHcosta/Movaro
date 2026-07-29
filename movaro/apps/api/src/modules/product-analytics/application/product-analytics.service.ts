import { Injectable, Logger } from '@nestjs/common';

import { SupabaseAdminService } from '../../../common/supabase/supabase-admin.service';
import { IngestProductEventsDto } from '../presentation/dto/ingest-product-events.dto';

@Injectable()
export class ProductAnalyticsService {
  private readonly logger = new Logger(ProductAnalyticsService.name);

  constructor(private readonly supabase: SupabaseAdminService) {}

  async ingest(body: IngestProductEventsDto): Promise<{
    accepted: boolean;
    eventIds: string[];
  }> {
    if (body.events.length === 0) {
      return { accepted: true, eventIds: [] };
    }

    if (!this.supabase.isConfigured) {
      return { accepted: false, eventIds: [] };
    }

    const rows = body.events.map((event) => ({
      event_id: event.eventId,
      installation_token: body.installationToken,
      app_environment: body.appEnvironment,
      event_name: event.eventName,
      occurred_at: event.occurredAt,
      step_index: event.stepIndex ?? null,
      methodology_version: event.methodologyVersion ?? null,
      stability_band: event.stabilityBand ?? null,
      coverage_band: event.coverageBand ?? null,
      rank_position: event.rankPosition ?? null,
    }));
    const { error } = await this.supabase.admin
      .from('product_flow_events')
      .upsert(rows, { onConflict: 'event_id', ignoreDuplicates: true });

    if (error) {
      this.logger.warn(
        `Product analytics batch was not stored: ${error.message}`,
      );
      return { accepted: false, eventIds: [] };
    }

    return {
      accepted: true,
      eventIds: body.events.map((event) => event.eventId),
    };
  }
}
