import { CityMetricsModel } from '../../data/models/city-metrics.model';
export declare abstract class CityMetricsRepository {
    abstract getAll(): CityMetricsModel[];
}
