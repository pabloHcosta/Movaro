import { IbgeLocalitiesService } from '../../../../integrations/ibge/ibge-localities.service';
import { CityMetricsModel } from '../../data/models/city-metrics.model';
import { CityCardEntity } from '../../domain/entities/city-card.entity';
import { CityRankingService } from './city-ranking.service';
export declare class CityMergeService {
    private readonly ibgeLocalitiesService;
    private readonly cityRankingService;
    constructor(ibgeLocalitiesService: IbgeLocalitiesService, cityRankingService: CityRankingService);
    merge(metrics: CityMetricsModel): Promise<CityCardEntity>;
    private buildSources;
    private buildIbgeCityUrl;
    private inferStateCode;
    private stateNameFromCode;
}
