import { Module } from '@nestjs/common';

import { SupabaseAdminService } from '../../common/supabase/supabase-admin.service';
import { CitiesModule } from '../cities/cities.module';
import { CityDetailService } from './application/services/city-detail.service';
import { CityInsightsService } from './application/services/city-insights.service';
import { CityNeighborhoodSeedService } from './application/services/city-neighborhood-seed.service';
import { CityDetailController } from './presentation/city-detail.controller';
import { CityInsightsController } from './presentation/city-insights.controller';

@Module({
  imports: [CitiesModule],
  controllers: [CityInsightsController, CityDetailController],
  providers: [
    SupabaseAdminService,
    CityInsightsService,
    CityNeighborhoodSeedService,
    CityDetailService,
  ],
})
export class CityInsightsModule {}
