import { BadRequestException, Controller, Get, Query } from '@nestjs/common';

import { CityInsightsService } from '../application/services/city-insights.service';
import { GetCityInsightExploreQueryDto } from './dto/get-city-insight-explore-query.dto';
import { GetCityInsightsQueryDto } from './dto/get-city-insights-query.dto';

@Controller({
  path: 'city-insights',
  version: '1',
})
export class CityInsightsController {
  constructor(private readonly cityInsightsService: CityInsightsService) {}

  @Get()
  getCityInsights(@Query() query: GetCityInsightsQueryDto) {
    const cityId = query.cityId?.trim() ?? '';
    if (cityId.length == 0 || cityId.length > 120) {
      throw new BadRequestException('cityId is required.');
    }

    const normalizedLimit = query.limit ? Number(query.limit) : 5;
    if (!Number.isFinite(normalizedLimit) || normalizedLimit < 1) {
      throw new BadRequestException('limit must be a positive number.');
    }

    return this.cityInsightsService.getInsights({
      cityId,
      goal: query.goal?.trim() || undefined,
      timeline: query.timeline?.trim() || undefined,
      locale: query.locale?.trim() || undefined,
      limit: Math.min(Math.trunc(normalizedLimit), 8),
    });
  }

  @Get('explore')
  getExplorePlaces(@Query() query: GetCityInsightExploreQueryDto) {
    const cityId = query.cityId?.trim() ?? '';
    if (cityId.length == 0 || cityId.length > 120) {
      throw new BadRequestException('cityId is required.');
    }

    const theme = query.theme?.trim() ?? '';
    if (theme.length == 0) {
      throw new BadRequestException('theme is required.');
    }

    const normalizedLimit = query.limit ? Number(query.limit) : 6;
    if (!Number.isFinite(normalizedLimit) || normalizedLimit < 1) {
      throw new BadRequestException('limit must be a positive number.');
    }

    return this.cityInsightsService.getExplorePlaces({
      cityId,
      theme,
      locale: query.locale?.trim() || undefined,
      seedPlace: query.seedPlace?.trim() || undefined,
      limit: Math.min(Math.trunc(normalizedLimit), 8),
    });
  }
}
