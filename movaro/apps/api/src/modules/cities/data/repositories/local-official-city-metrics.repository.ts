import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { Injectable } from '@nestjs/common';

import { OfficialCityMetricsModel } from '../models/official-city-metrics.model';
import { OfficialCityMetricsRepository } from '../../domain/repositories/official-city-metrics.repository';

@Injectable()
export class LocalOfficialCityMetricsRepository
  implements OfficialCityMetricsRepository
{
  private cache: OfficialCityMetricsModel[] | null = null;

  getAll(): OfficialCityMetricsModel[] {
    if (this.cache != null) {
      return this.cache;
    }

    const distFilePath = resolve(
      __dirname,
      '../seeds/official_city_metrics.json',
    );
    const sourceFilePath = resolve(
      process.cwd(),
      'src/modules/cities/data/seeds/official_city_metrics.json',
    );
    const filePath = existsSync(distFilePath) ? distFilePath : sourceFilePath;
    const fileContent = readFileSync(filePath, 'utf-8');
    this.cache = JSON.parse(fileContent) as OfficialCityMetricsModel[];
    return this.cache;
  }
}
