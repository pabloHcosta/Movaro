import { Injectable } from '@nestjs/common';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { CityInsightExplorePlaceEntity } from '../../domain/entities/city-insight-explore-place.entity';
import { CityInsightTheme } from '../../domain/entities/city-insight.entity';

@Injectable()
export class CityNeighborhoodSeedService {
  private cache: Record<string, CityInsightExplorePlaceEntity[]> | null = null;

  findByCityId(cityId: string): CityInsightExplorePlaceEntity[] {
    const snapshots = this.loadSnapshots();
    return snapshots[normalize(cityId)] ?? [];
  }

  private loadSnapshots(): Record<string, CityInsightExplorePlaceEntity[]> {
    if (this.cache != null) {
      return this.cache;
    }

    const distFilePath = resolve(
      __dirname,
      '../data/seeds/city_neighborhoods.json',
    );
    const sourceFilePath = resolve(
      process.cwd(),
      'src/modules/city-insights/data/seeds/city_neighborhoods.json',
    );
    const filePath = existsSync(distFilePath) ? distFilePath : sourceFilePath;
    const fileContent = readFileSync(filePath, 'utf-8');
    const raw = JSON.parse(fileContent) as Array<{
      cityId: string;
      cityName: string;
      places: Array<{
        id: string;
        name: string;
        neighborhood?: string;
        region?: string;
        category: string;
        shortText: string;
        mapUrl: string;
        source?: 'openstreetmap' | 'template' | 'curated';
        latitude?: number;
        longitude?: number;
      }>;
    }>;

    this.cache = Object.fromEntries(
      raw.map((city) => [
        normalize(city.cityId),
        city.places.map(
          (place): CityInsightExplorePlaceEntity => ({
            id: place.id,
            cityId: city.cityId,
            cityName: city.cityName,
            theme: CityInsightTheme.Neighborhoods,
            name: place.name,
            category: place.category,
            neighborhood: place.neighborhood,
            region: place.region,
            shortText: place.shortText,
            mapUrl: place.mapUrl,
            latitude: place.latitude,
            longitude: place.longitude,
            source: place.source ?? 'curated',
          }),
        ),
      ]),
    );

    return this.cache;
  }
}

function normalize(value: string): string {
  return value.trim().toLowerCase();
}
