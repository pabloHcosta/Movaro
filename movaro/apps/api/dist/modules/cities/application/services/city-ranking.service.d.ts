import { CityMetricsModel } from '../../data/models/city-metrics.model';
import { MovaroScoresEntity } from '../../domain/entities/movaro-scores.entity';
export declare class CityRankingService {
    calculateScores(city: CityMetricsModel): MovaroScoresEntity;
    buildRecommendationReasons(city: CityMetricsModel, scores: MovaroScoresEntity): string[];
    getMethodology(): {
        principles: string[];
        formulas: {
            economical: string;
            popularForArgentinians: string;
            languageAdaptation: string;
            workOpportunity: string;
            overall: string;
        };
        note: string;
    };
    private normalizeUnemployment;
    private round;
}
