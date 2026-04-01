import { MovaroScoresEntity } from './movaro-scores.entity';
import { CitySourcesEntity } from './city-sources.entity';
import { CityPublicOpinionEntity } from './city-public-opinion.entity';
import { CityBudgetSnapshotEntity } from './city-budget-snapshot.entity';
import { CitySeasonalitySnapshotEntity } from './city-seasonality-snapshot.entity';

export class CityCardEntity {
  constructor(
    public readonly id: string,
    public readonly name: string,
    public readonly stateCode: string,
    public readonly stateName: string,
    public readonly countryCode: string,
    public readonly ibgeCode: number,
    public readonly latitude: number,
    public readonly longitude: number,
    public readonly population: number,
    public readonly idhmScore: number,
    public readonly idhmReferenceYear: number,
    public readonly costOfLivingScore: number,
    public readonly rentScore: number,
    public readonly safetyScore: number,
    public readonly argentinaPopularityScore: number,
    public readonly spanishSupportScore: number,
    public readonly jobMarketScore: number,
    public readonly unemploymentRate: number,
    public readonly economicActivityScore: number,
    public readonly topIndustries: string[],
    public readonly movaroScores: MovaroScoresEntity,
    public readonly recommendationReasons: string[],
    public readonly sources: CitySourcesEntity,
    public readonly updatedAt: string,
    public readonly regionName: string | null,
    public readonly publicOpinion: CityPublicOpinionEntity | null,
    public readonly budgetSnapshot: CityBudgetSnapshotEntity | null,
    public readonly seasonalitySnapshot: CitySeasonalitySnapshotEntity | null,
  ) {}
}
