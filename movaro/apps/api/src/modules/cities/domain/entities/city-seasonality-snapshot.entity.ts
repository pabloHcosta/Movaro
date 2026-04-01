import { CityDataSourceType } from './city-data-source-type';

export type CitySeasonalitySeverity = 'high' | 'medium';

export class CitySeasonalitySnapshotEntity {
  constructor(
    public readonly peakMonths: number[],
    public readonly lowMonths: number[],
    public readonly severity: CitySeasonalitySeverity,
    public readonly visitorsLabelPt: string,
    public readonly visitorsLabelEs: string,
    public readonly visitorsLabelEn: string,
    public readonly rentNotesPt: string,
    public readonly rentNotesEs: string,
    public readonly rentNotesEn: string,
    public readonly jobNotesPt: string,
    public readonly jobNotesEs: string,
    public readonly jobNotesEn: string,
    public readonly populationMultiplierNote: string | null,
    public readonly updatedAt: string,
    public readonly sourceLabel: string,
    public readonly sourceUrl: string | null,
    public readonly sourceType: CityDataSourceType,
  ) {}
}
