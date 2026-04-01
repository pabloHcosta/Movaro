import { CityDataSourceType } from '../../domain/entities/city-data-source-type';

export type OfficialSnapshotSourceModel = {
  sourceLabel: string;
  sourceUrl?: string | null;
  sourceType?: CityDataSourceType;
  updatedAt: string;
};

export type OfficialCityDevelopmentSnapshotModel =
  OfficialSnapshotSourceModel & {
    idhmScore: number;
    idhmReferenceYear: number;
  };

export type OfficialCityEmploymentSnapshotModel =
  OfficialSnapshotSourceModel & {
    unemploymentRate?: number;
    jobMarketScore?: number;
    economicActivityScore?: number;
    topIndustries?: string[];
  };

export type OfficialCitySafetySnapshotModel = OfficialSnapshotSourceModel & {
  safetyScore: number;
};

export type OfficialCityMetricsModel = {
  cityId?: string;
  ibgeCode: number;
  development?: OfficialCityDevelopmentSnapshotModel;
  employment?: OfficialCityEmploymentSnapshotModel;
  safety?: OfficialCitySafetySnapshotModel;
};
