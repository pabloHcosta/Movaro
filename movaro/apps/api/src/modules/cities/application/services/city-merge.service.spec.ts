import { CityMetricsModel } from '../../data/models/city-metrics.model';
import { CityMergeService } from './city-merge.service';

describe('CityMergeService', () => {
  const metrics: CityMetricsModel = {
    id: 'curitiba-pr',
    name: 'Curitiba',
    displayName: 'Curitiba',
    countryCode: 'BR',
    ibgeCode: 4106902,
    latitude: -25.43,
    longitude: -49.27,
    population: 1_770_000,
    idhmScore: 0.823,
    idhmReferenceYear: 2010,
    costOfLivingScore: 70,
    rentScore: 68,
    safetyScore: 65,
    argentinaPopularityScore: 60,
    spanishSupportScore: 55,
    jobMarketScore: 75,
    unemploymentRate: 7,
    economicActivityScore: 78,
    topIndustries: ['Tecnologia'],
    updatedAt: '2026-08-20',
  };

  it('keeps a city available with clearly labelled local snapshots when IBGE providers fail', async () => {
    const service = new CityMergeService(
      {
        getMunicipalityByIbgeCode: jest
          .fn()
          .mockRejectedValue(new Error('IBGE unavailable')),
      } as never,
      {
        getPopulationEstimateByIbgeCode: jest
          .fn()
          .mockRejectedValue(new Error('SIDRA unavailable')),
      } as never,
      {
        calculateScores: jest.fn().mockReturnValue({
          economical: 70,
          popularForArgentinians: 60,
          languageAdaptation: 55,
          workOpportunity: 75,
          overall: 66,
        }),
        buildRecommendationReasons: jest.fn().mockReturnValue([]),
      } as never,
      { getCityOpinion: jest.fn().mockResolvedValue(null) } as never,
      { findByCityId: jest.fn().mockReturnValue(null) } as never,
      { findByCityId: jest.fn().mockReturnValue(null) } as never,
      { findByCityId: jest.fn().mockReturnValue(null) } as never,
      { findByCity: jest.fn().mockReturnValue(null) } as never,
    );

    const result = await service.merge(metrics);

    expect(result.name).toBe('Curitiba');
    expect(result.stateCode).toBe('PR');
    expect(result.stateName).toBe('Parana');
    expect(result.population).toBe(metrics.population);
    expect(result.sources.territorialIdentity).toEqual(
      expect.objectContaining({
        provider: 'Snapshot local versionado',
        isOfficial: false,
        sourceType: 'curated',
        updatedAt: metrics.updatedAt,
      }),
    );
    expect(result.sources.population).toEqual(
      expect.objectContaining({
        provider: 'Snapshot local versionado',
        isOfficial: false,
        sourceType: 'curated',
        updatedAt: metrics.updatedAt,
      }),
    );
  });
});
