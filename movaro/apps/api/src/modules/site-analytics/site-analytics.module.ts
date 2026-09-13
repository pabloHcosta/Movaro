import { Module } from '@nestjs/common';

import { SupabaseAdminService } from '../../common/supabase/supabase-admin.service';
import { SiteAnalyticsService } from './application/site-analytics.service';
import { SiteAnalyticsController } from './presentation/site-analytics.controller';

@Module({
  controllers: [SiteAnalyticsController],
  providers: [SiteAnalyticsService, SupabaseAdminService],
})
export class SiteAnalyticsModule {}
