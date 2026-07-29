import { Module } from '@nestjs/common';

import { GooglePlacesCityOpinionService } from '../../integrations/google/google-places-city-opinion.service';
import { IbgeCityNormalizerService } from '../../integrations/ibge/ibge-city-normalizer.service';
import { IbgeHttpClient } from '../../integrations/ibge/ibge-http.client';
import { IbgeLocalitiesService } from '../../integrations/ibge/ibge-localities.service';
import { IbgePopulationService } from '../../integrations/ibge/ibge-population.service';
import { SidraHttpClient } from '../../integrations/ibge/sidra-http.client';
import { OpenMeteoWeatherService } from '../../integrations/weather/open-meteo-weather.service';
import { CitiesCatalogService } from './application/services/cities-catalog.service';
import { CityBudgetSnapshotService } from './application/services/city-budget-snapshot.service';
import { CityMergeService } from './application/services/city-merge.service';
import { CityOfficialMetricsService } from './application/services/city-official-metrics.service';
import { CityPublicOpinionSeedService } from './application/services/city-public-opinion-seed.service';
import { CityRankingService } from './application/services/city-ranking.service';
import { CityRecommendationService } from './application/services/city-recommendation.service';
import { CitySeasonalitySnapshotService } from './application/services/city-seasonality-snapshot.service';
import { TravelRouteInsightService } from './application/services/travel-route-insight.service';
import { LocalCityMetricsRepository } from './data/repositories/local-city-metrics.repository';
import { LocalOfficialCityMetricsRepository } from './data/repositories/local-official-city-metrics.repository';
import { CityMetricsRepository } from './domain/repositories/city-metrics.repository';
import { OfficialCityMetricsRepository } from './domain/repositories/official-city-metrics.repository';
import { CitiesController } from './presentation/cities.controller';

@Module({
  controllers: [CitiesController],
  exports: [CitiesCatalogService],
  providers: [
    IbgeHttpClient,
    SidraHttpClient,
    IbgeCityNormalizerService,
    IbgeLocalitiesService,
    IbgePopulationService,
    GooglePlacesCityOpinionService,
    OpenMeteoWeatherService,
    CityBudgetSnapshotService,
    CityPublicOpinionSeedService,
    CitySeasonalitySnapshotService,
    CityRankingService,
    CityRecommendationService,
    TravelRouteInsightService,
    CityOfficialMetricsService,
    CityMergeService,
    CitiesCatalogService,
    LocalCityMetricsRepository,
    LocalOfficialCityMetricsRepository,
    {
      provide: CityMetricsRepository,
      useExisting: LocalCityMetricsRepository,
    },
    {
      provide: OfficialCityMetricsRepository,
      useExisting: LocalOfficialCityMetricsRepository,
    },
  ],
})
export class CitiesModule {}
