import { CityResolverService } from './city-resolver.service';
import { CitiesCatalogService } from '../../../../cities/application/services/cities-catalog.service';

describe('CityResolverService', () => {
  it('normalizes a city slug without state suffix before resolving', async () => {
    const getCityById = jest.fn().mockResolvedValue({
      name: 'Florianopolis',
      stateName: 'Santa Catarina',
      costOfLivingScore: 8,
      safetyScore: 8,
      argentinaPopularityScore: 9,
      topIndustries: ['Tecnologia'],
      recommendationReasons: ['Popular entre argentinos'],
      population: 537000,
      movaroScores: {
        overall: 76,
      },
    });
    const service = new CityResolverService({
      resolveCityId: jest.fn().mockReturnValue('florianopolis-sc'),
      getCityById,
      search: jest.fn(),
    } as unknown as CitiesCatalogService);

    const result = await service.resolve('florianopolis', 'pt');

    expect(getCityById).toHaveBeenCalledWith('florianopolis-sc');
    expect(result.found).toBe(true);
    expect(result.confidence).toBe(0.92);
  });
});
