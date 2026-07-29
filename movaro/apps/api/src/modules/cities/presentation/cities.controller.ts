import {
  BadRequestException,
  Controller,
  Get,
  Param,
  Post,
  Body,
  Query,
} from '@nestjs/common';

import { AppErrorFactory } from '../../../common/errors/app-error.factory';
import { CitiesCatalogService } from '../application/services/cities-catalog.service';
import { CityRecommendationService } from '../application/services/city-recommendation.service';
import { GetCitiesQueryDto } from './dto/get-cities-query.dto';
import { RecommendCitiesDto } from './dto/recommend-cities.dto';

@Controller({
  path: 'cities',
  version: '1',
})
export class CitiesController {
  constructor(
    private readonly citiesCatalogService: CitiesCatalogService,
    private readonly cityRecommendationService: CityRecommendationService,
  ) {}

  @Post('recommendations')
  recommend(@Body() body: RecommendCitiesDto) {
    return this.cityRecommendationService.recommend(body);
  }

  @Get('highlights')
  getHighlights() {
    return this.citiesCatalogService.getHighlights();
  }

  @Get('search')
  search(@Query('q') query: string | undefined) {
    if (!query || query.trim().length == 0) {
      throw AppErrorFactory.validationError(
        'q is required.',
        'Informe um termo para buscar cidades.',
      );
    }

    const normalizedQuery = query.trim().replace(/\s+/g, ' ');
    if (normalizedQuery.length > 80) {
      throw new BadRequestException('q must be at most 80 characters long.');
    }

    return this.citiesCatalogService.search(normalizedQuery);
  }

  @Get('metadata/methodology')
  getMethodology() {
    return this.citiesCatalogService.getMethodology();
  }

  @Get()
  getCities(@Query() query: GetCitiesQueryDto) {
    return this.citiesCatalogService.getCities(query);
  }

  @Get(':id/weather')
  getCityWeather(@Param('id') id: string) {
    const normalizedId = id.trim();
    if (
      normalizedId.length == 0 ||
      normalizedId.length > 120 ||
      !/^[a-z0-9-]+$/.test(normalizedId)
    ) {
      throw new BadRequestException('Invalid city id.');
    }

    return this.citiesCatalogService.getCityWeatherById(normalizedId);
  }

  @Get(':id/travel-insight')
  getCityTravelInsight(
    @Param('id') id: string,
    @Query('originIata') originIata?: string,
    @Query('destIata') destIata?: string,
  ) {
    const normalizedId = id.trim();
    if (
      normalizedId.length == 0 ||
      normalizedId.length > 120 ||
      !/^[a-z0-9-]+$/.test(normalizedId)
    ) {
      throw new BadRequestException('Invalid city id.');
    }

    return this.citiesCatalogService.getCityTravelInsightById(normalizedId, {
      originIata: originIata?.trim().toUpperCase(),
      destIata: destIata?.trim().toUpperCase(),
    });
  }

  @Get(':id')
  getCityById(@Param('id') id: string) {
    const normalizedId = id.trim();
    if (
      normalizedId.length == 0 ||
      normalizedId.length > 120 ||
      !/^[a-z0-9-]+$/.test(normalizedId)
    ) {
      throw new BadRequestException('Invalid city id.');
    }

    return this.citiesCatalogService.getCityById(normalizedId);
  }
}
