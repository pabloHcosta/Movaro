import {
  BadRequestException,
  Controller,
  Get,
  Param,
  Query,
} from '@nestjs/common';

import { CityDetailService } from '../application/services/city-detail.service';

@Controller({
  path: 'city-detail',
  version: '1',
})
export class CityDetailController {
  constructor(private readonly cityDetailService: CityDetailService) {}

  @Get(':id/social-proof')
  getSocialProof(
    @Param('id') id: string,
    @Query('locale') locale?: string,
    @Query('goal') goal?: string,
    @Query('timeline') timeline?: string,
  ) {
    return this.cityDetailService.getSocialProof({
      cityId: this.normalizeCityId(id),
      locale,
      goal: goal?.trim() || undefined,
      timeline: timeline?.trim() || undefined,
    });
  }

  @Get(':id/climate-summary')
  getClimateSummary(@Param('id') id: string, @Query('locale') locale?: string) {
    return this.cityDetailService.getClimateSummary({
      cityId: this.normalizeCityId(id),
      locale,
    });
  }

  @Get(':id/arrival-story')
  getArrivalStory(
    @Param('id') id: string,
    @Query('locale') locale?: string,
    @Query('goal') goal?: string,
    @Query('timeline') timeline?: string,
  ) {
    return this.cityDetailService.getArrivalStory({
      cityId: this.normalizeCityId(id),
      locale,
      goal: goal?.trim() || undefined,
      timeline: timeline?.trim() || undefined,
    });
  }

  @Get(':id/comparison')
  getComparison(
    @Param('id') id: string,
    @Query('compareTo') compareTo?: string,
    @Query('locale') locale?: string,
  ) {
    const compareIds = (compareTo ?? '')
      .split(',')
      .map((item) => item.trim())
      .filter((item) => item.length > 0);
    if (compareIds.length === 0) {
      throw new BadRequestException('compareTo is required.');
    }

    return this.cityDetailService.getComparison({
      cityId: this.normalizeCityId(id),
      compareTo: compareIds,
      locale,
    });
  }

  private normalizeCityId(id: string) {
    const normalizedId = id.trim();
    if (
      normalizedId.length === 0 ||
      normalizedId.length > 120 ||
      !/^[a-z0-9-]+$/.test(normalizedId)
    ) {
      throw new BadRequestException('Invalid city id.');
    }
    return normalizedId;
  }
}
