import { CityMetricsModel } from '../models/city-metrics.model';
import { CityMetricsRepository } from '../../domain/repositories/city-metrics.repository';
export declare class LocalCityMetricsRepository implements CityMetricsRepository {
    private cache;
    getAll(): CityMetricsModel[];
}
