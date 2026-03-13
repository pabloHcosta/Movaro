import { Module } from '@nestjs/common';

import { GooglePlacesCityOpinionService } from '../../integrations/google/google-places-city-opinion.service';
import { IbgeCityNormalizerService } from '../../integrations/ibge/ibge-city-normalizer.service';
import { IbgeHttpClient } from '../../integrations/ibge/ibge-http.client';
import { IbgeLocalitiesService } from '../../integrations/ibge/ibge-localities.service';
import { OpenMeteoWeatherService } from '../../integrations/weather/open-meteo-weather.service';
import { CitiesCatalogService } from './application/services/cities-catalog.service';
import { CityMergeService } from './application/services/city-merge.service';
import { CityRankingService } from './application/services/city-ranking.service';
import { LocalCityMetricsRepository } from './data/repositories/local-city-metrics.repository';
import { CityMetricsRepository } from './domain/repositories/city-metrics.repository';
import { CitiesController } from './presentation/cities.controller';

@Module({
  controllers: [CitiesController],
  providers: [
    IbgeHttpClient,
    IbgeCityNormalizerService,
    IbgeLocalitiesService,
    GooglePlacesCityOpinionService,
    OpenMeteoWeatherService,
    CityRankingService,
    CityMergeService,
    CitiesCatalogService,
    LocalCityMetricsRepository,
    {
      provide: CityMetricsRepository,
      useExisting: LocalCityMetricsRepository,
    },
  ],
})
export class CitiesModule {}
