import { CityDataSourceType } from './city-data-source-type';

export class CitySourceEntity {
  constructor(
    public readonly id: string,
    public readonly title: string,
    public readonly provider: string,
    public readonly description: string,
    public readonly isOfficial: boolean,
    public readonly url: string | null,
    public readonly sourceType: CityDataSourceType = isOfficial
      ? 'official'
      : 'curated',
    public readonly referenceValue: number | null = null,
    public readonly referenceUnit: string | null = null,
    public readonly referencePeriod: string | null = null,
    public readonly updatedAt: string | null = null,
  ) {}
}
