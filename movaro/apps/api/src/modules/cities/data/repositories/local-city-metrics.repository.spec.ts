import { LocalCityMetricsRepository } from './local-city-metrics.repository';

describe('LocalCityMetricsRepository', () => {
  it('loads the shipped city metrics seed', () => {
    const cities = new LocalCityMetricsRepository().getAll();

    expect(cities.length).toBeGreaterThan(0);
    expect(cities).toContainEqual(
      expect.objectContaining({ countryCode: 'BR', id: expect.any(String) }),
    );
  });
});
