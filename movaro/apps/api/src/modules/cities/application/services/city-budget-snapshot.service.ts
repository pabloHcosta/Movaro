import { Injectable } from '@nestjs/common';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { CityBudgetSnapshotEntity } from '../../domain/entities/city-budget-snapshot.entity';

@Injectable()
export class CityBudgetSnapshotService {
  private cache: Record<string, CityBudgetSnapshotEntity> | null = null;

  findByCityId(cityId: string): CityBudgetSnapshotEntity | null {
    const snapshots = this.loadSnapshots();
    return snapshots[normalize(cityId)] ?? null;
  }

  private loadSnapshots(): Record<string, CityBudgetSnapshotEntity> {
    if (this.cache != null) {
      return this.cache;
    }

    const distFilePath = resolve(
      __dirname,
      '../data/seeds/city_budget_snapshots.json',
    );
    const sourceFilePath = resolve(
      process.cwd(),
      'src/modules/cities/data/seeds/city_budget_snapshots.json',
    );
    const filePath = existsSync(distFilePath) ? distFilePath : sourceFilePath;
    const fileContent = readFileSync(filePath, 'utf-8');
    const raw = JSON.parse(fileContent) as Array<{
      cityId: string;
      cityLabel: string;
      singlePersonExcludingRent: number;
      oneBedroomOutsideCentre: number;
      oneBedroomCityCentre: number;
      averageMonthlyNetSalary: number;
      monthlyTransportPass: number;
      utilities: number;
      updatedAt: string;
      sourceLabel: string;
      sourceUrl: string;
      sourceType: 'official' | 'community' | 'curated' | 'derived';
    }>;

    this.cache = Object.fromEntries(
      raw.map((item) => [
        normalize(item.cityId),
        new CityBudgetSnapshotEntity(
          item.cityLabel,
          item.singlePersonExcludingRent,
          item.oneBedroomOutsideCentre,
          item.oneBedroomCityCentre,
          item.averageMonthlyNetSalary,
          item.monthlyTransportPass,
          item.utilities,
          item.updatedAt,
          item.sourceLabel,
          item.sourceUrl,
          item.sourceType,
        ),
      ]),
    );

    return this.cache;
  }
}

function normalize(value: string): string {
  return value.trim().toLowerCase();
}
