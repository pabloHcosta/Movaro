import { GetCitiesQueryDto } from '../../presentation/dto/get-cities-query.dto';
import { CityCardEntity } from '../../domain/entities/city-card.entity';
import { CityMetricsRepository } from '../../domain/repositories/city-metrics.repository';
import { CityMergeService } from './city-merge.service';
import { CityRankingService } from './city-ranking.service';
export declare class CitiesCatalogService {
    private readonly cityMetricsRepository;
    private readonly cityMergeService;
    private readonly cityRankingService;
    constructor(cityMetricsRepository: CityMetricsRepository, cityMergeService: CityMergeService, cityRankingService: CityRankingService);
    getCities(query: GetCitiesQueryDto): Promise<CityCardEntity[]>;
    getHighlights(): Promise<{
        mostChosenByArgentinians: CityCardEntity[];
        easiestForSpanishSpeakers: CityCardEntity[];
        mostEconomical: CityCardEntity[];
        bestForWork: CityCardEntity[];
    }>;
    getCityById(id: string): Promise<CityCardEntity>;
    search(query: string): Promise<CityCardEntity[]>;
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
    private buildCatalog;
    private sortBy;
    private getSortValue;
}
