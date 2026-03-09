import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { Injectable } from '@nestjs/common';

import { CityMetricsModel } from '../models/city-metrics.model';
import { CityMetricsRepository } from '../../domain/repositories/city-metrics.repository';

@Injectable()
export class LocalCityMetricsRepository implements CityMetricsRepository {
  private cache: CityMetricsModel[] | null = null;

  getAll(): CityMetricsModel[] {
    if (this.cache != null) {
      return this.cache;
    }

    const filePath = resolve(
      process.cwd(),
      '../../packages/contracts/seed/movaro_city_metrics.json',
    );
    const fileContent = readFileSync(filePath, 'utf-8');
    this.cache = JSON.parse(fileContent) as CityMetricsModel[];
    return this.cache;
  }
}
