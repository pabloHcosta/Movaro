import { CityDataSourceType } from './city-data-source-type';

export class CityBudgetSnapshotEntity {
  constructor(
    public readonly cityLabel: string,
    public readonly singlePersonExcludingRent: number,
    public readonly oneBedroomOutsideCentre: number,
    public readonly oneBedroomCityCentre: number,
    public readonly averageMonthlyNetSalary: number,
    public readonly monthlyTransportPass: number,
    public readonly utilities: number,
    public readonly updatedAt: string,
    public readonly sourceLabel: string,
    public readonly sourceUrl: string,
    public readonly sourceType: CityDataSourceType,
  ) {}
}
