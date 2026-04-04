import { Injectable } from '@nestjs/common';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { CityPublicOpinionEntity } from '../../domain/entities/city-public-opinion.entity';

@Injectable()
export class CityPublicOpinionSeedService {
  private cache: Record<string, CityPublicOpinionEntity> | null = null;

  findByCityId(cityId: string): CityPublicOpinionEntity | null {
    const snapshots = this.loadSnapshots();
    return snapshots[normalize(cityId)] ?? null;
  }

  private loadSnapshots(): Record<string, CityPublicOpinionEntity> {
    if (this.cache != null) {
      return this.cache;
    }

    const distFilePath = resolve(
      __dirname,
      '../data/seeds/city_public_opinions.json',
    );
    const sourceFilePath = resolve(
      process.cwd(),
      'src/modules/cities/data/seeds/city_public_opinions.json',
    );
    const filePath = existsSync(distFilePath) ? distFilePath : sourceFilePath;
    const fileContent = readFileSync(filePath, 'utf-8');
    const raw = JSON.parse(fileContent) as Array<{
      cityId: string;
      provider: string;
      placeName?: string | null;
      placeUrl?: string | null;
      rating?: number | null;
      userRatingCount?: number | null;
      summary?: string | null;
      positivePoints?: string[];
      criticalPoints?: string[];
      collectedAt: string;
    }>;

    this.cache = Object.fromEntries(
      raw.map((item) => [
        normalize(item.cityId),
        new CityPublicOpinionEntity(
          item.provider,
          item.placeName ?? null,
          item.placeUrl ?? null,
          item.rating ?? null,
          item.userRatingCount ?? null,
          item.summary ?? null,
          item.positivePoints ?? [],
          item.criticalPoints ?? [],
          item.collectedAt,
        ),
      ]),
    );

    return this.cache;
  }
}

function normalize(value: string): string {
  return value.trim().toLowerCase();
}
