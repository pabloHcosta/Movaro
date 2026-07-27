import { Module } from '@nestjs/common';

import { SupabaseAdminService } from '../../common/supabase/supabase-admin.service';
import { ProductAnalyticsService } from './application/product-analytics.service';
import { ProductAnalyticsController } from './presentation/product-analytics.controller';

@Module({
  controllers: [ProductAnalyticsController],
  providers: [ProductAnalyticsService, SupabaseAdminService],
})
export class ProductAnalyticsModule {}
