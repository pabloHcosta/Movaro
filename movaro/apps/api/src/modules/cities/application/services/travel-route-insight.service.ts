import { Injectable } from '@nestjs/common';

import { TravelRouteInsightEntity } from '../../domain/entities/travel-route-insight.entity';

@Injectable()
export class TravelRouteInsightService {
  resolveForCity({
    cityId: _cityId,
    originIata: _originIata,
    destIata: _destIata,
  }: {
    cityId?: string | null;
    originIata?: string | null;
    destIata?: string | null;
  }): TravelRouteInsightEntity | null {
    return null;
  }
}
