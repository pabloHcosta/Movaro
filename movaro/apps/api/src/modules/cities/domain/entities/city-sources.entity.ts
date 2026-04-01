import { CitySourceEntity } from './city-source.entity';

export class CitySourcesEntity {
  constructor(
    public readonly territorialIdentity: CitySourceEntity,
    public readonly population: CitySourceEntity,
    public readonly humanDevelopment: CitySourceEntity,
    public readonly employment: CitySourceEntity | null,
    public readonly safety: CitySourceEntity | null,
    public readonly curatedMetrics: CitySourceEntity,
    public readonly ranking: CitySourceEntity,
    public readonly publicReviews: CitySourceEntity | null = null,
  ) {}
}
