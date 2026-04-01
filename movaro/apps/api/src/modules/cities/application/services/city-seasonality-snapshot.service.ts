import { Injectable } from '@nestjs/common';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

import { CitySeasonalitySnapshotEntity } from '../../domain/entities/city-seasonality-snapshot.entity';

@Injectable()
export class CitySeasonalitySnapshotService {
  private cache: Record<string, CitySeasonalitySnapshotEntity> | null = null;

  findByCityId(_cityId: string): CitySeasonalitySnapshotEntity | null {
    const snapshots = this.loadSnapshots();
    return snapshots[_normalize(_cityId)] ?? null;
  }

  private loadSnapshots(): Record<string, CitySeasonalitySnapshotEntity> {
    if (this.cache != null) {
      return this.cache;
    }

    const distFilePath = resolve(
      __dirname,
      '../data/seeds/city_seasonality_snapshots.json',
    );
    const sourceFilePath = resolve(
      process.cwd(),
      'src/modules/cities/data/seeds/city_seasonality_snapshots.json',
    );
    const filePath = existsSync(distFilePath) ? distFilePath : sourceFilePath;
    const fileContent = readFileSync(filePath, 'utf-8');
    const raw = JSON.parse(fileContent) as Array<{
      cityId: string;
      peakMonths: number[];
      lowMonths: number[];
      severity: 'high' | 'medium';
      visitorsLabelPt: string;
      visitorsLabelEs: string;
      visitorsLabelEn: string;
      rentNotesPt: string;
      rentNotesEs: string;
      rentNotesEn: string;
      jobNotesPt: string;
      jobNotesEs: string;
      jobNotesEn: string;
      populationMultiplierNote?: string | null;
      updatedAt: string;
      sourceLabel: string;
      sourceUrl?: string | null;
      sourceType: 'official' | 'community' | 'curated' | 'derived';
    }>;

    this.cache = Object.fromEntries(
      raw.map((item) => [
        _normalize(item.cityId),
        new CitySeasonalitySnapshotEntity(
          item.peakMonths,
          item.lowMonths,
          item.severity,
          item.visitorsLabelPt,
          item.visitorsLabelEs,
          item.visitorsLabelEn,
          item.rentNotesPt,
          item.rentNotesEs,
          item.rentNotesEn,
          item.jobNotesPt,
          item.jobNotesEs,
          item.jobNotesEn,
          item.populationMultiplierNote ?? null,
          item.updatedAt,
          item.sourceLabel,
          item.sourceUrl ?? null,
          item.sourceType,
        ),
      ]),
    );

    return this.cache;
  }
}

function _normalize(value: string): string {
  return value.toLowerCase().trim();
}
