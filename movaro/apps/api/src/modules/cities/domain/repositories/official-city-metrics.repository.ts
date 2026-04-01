import { OfficialCityMetricsModel } from '../../data/models/official-city-metrics.model';

export abstract class OfficialCityMetricsRepository {
  abstract getAll(): OfficialCityMetricsModel[];
}
