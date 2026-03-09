import { CityMetricsModel } from '../../data/models/city-metrics.model';

export abstract class CityMetricsRepository {
  abstract getAll(): CityMetricsModel[];
}
