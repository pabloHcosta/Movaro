import { Module } from '@nestjs/common';

import { SupabaseAdminService } from '../../common/supabase/supabase-admin.service';
import { CitiesModule } from '../cities/cities.module';
import { CityInsightsService } from './application/services/city-insights.service';
import { CityInsightsController } from './presentation/city-insights.controller';

@Module({
  imports: [CitiesModule],
  controllers: [CityInsightsController],
  providers: [SupabaseAdminService, CityInsightsService],
})
export class CityInsightsModule {}
