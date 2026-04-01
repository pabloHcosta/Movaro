import { Injectable } from '@nestjs/common';

import { OfficialCityMetricsModel } from '../../data/models/official-city-metrics.model';
import { OfficialCityMetricsRepository } from '../../domain/repositories/official-city-metrics.repository';

@Injectable()
export class CityOfficialMetricsService {
  constructor(
    private readonly repository: OfficialCityMetricsRepository,
  ) {}

  findByCity({
    cityId,
    ibgeCode,
  }: {
    cityId: string;
    ibgeCode: number;
  }): OfficialCityMetricsModel | null {
    const normalizedCityId = cityId.trim().toLowerCase();

    return (
      this.repository.getAll().find((item) => {
        if (item.cityId?.trim().toLowerCase() === normalizedCityId) {
          return true;
        }
        return item.ibgeCode === ibgeCode;
      }) ?? null
    );
  }
}
