import { CityDataSourceType } from './city-data-source-type';

export type TravelRoutePriceLevel = 'low' | 'mid' | 'high';

export class TravelRouteInsightEntity {
  constructor(
    public readonly originIata: string,
    public readonly destIata: string,
    public readonly months: TravelRoutePriceLevel[],
    public readonly lowUsdMin: number,
    public readonly lowUsdMax: number,
    public readonly seasonalWarningKey: string | null,
    public readonly sourceLabel: string,
    public readonly sourceUrl: string | null,
    public readonly sourceType: CityDataSourceType,
  ) {}
}
