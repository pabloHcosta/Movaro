import { existsSync, readFileSync } from 'node:fs';
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

    const distFilePath = resolve(__dirname, '../seeds/movaro_city_metrics.json');
    const sourceFilePath = resolve(
      process.cwd(),
      'src/modules/cities/data/seeds/movaro_city_metrics.json',
    );
    const filePath = existsSync(distFilePath) ? distFilePath : sourceFilePath;
    const fileContent = readFileSync(filePath, 'utf-8');
    this.cache = JSON.parse(fileContent) as CityMetricsModel[];
    return this.cache;
  }
}
