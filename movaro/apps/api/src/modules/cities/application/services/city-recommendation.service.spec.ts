import { CityCardEntity } from '../../domain/entities/city-card.entity';
import { CityRecommendationService } from './city-recommendation.service';
import { CitiesCatalogService } from './cities-catalog.service';

const source = {
  provider: 'IBGE',
  sourceType: 'official',
  updatedAt: '2026-07-10',
  url: 'https://www.ibge.gov.br/',
};

function city({
  id,
  stateCode,
  population,
  latitude,
  longitude,
  economical,
  work,
  safety,
  rent,
  living,
}: {
  id: string;
  stateCode: string;
  population: number;
  latitude: number;
  longitude: number;
  economical: number;
  work: number;
  safety: number;
  rent: number;
  living: number;
}): CityCardEntity {
  return {
    id,
    name: id,
    stateCode,
    stateName: stateCode,
    countryCode: 'BR',
    ibgeCode: 1,
    latitude,
    longitude,
    population,
    idhmScore: 0.8,
    idhmReferenceYear: 2021,
    costOfLivingScore: economical,
    rentScore: economical,
    safetyScore: safety,
    argentinaPopularityScore: 60,
    spanishSupportScore: 60,
    jobMarketScore: work,
    unemploymentRate: 7,
    economicActivityScore: work,
    topIndustries: [],
    movaroScores: {
      economical,
      popularForArgentinians: 60,
      languageAdaptation: 60,
      workOpportunity: work,
      overall: 70,
    },
    recommendationReasons: [],
    sources: {
      territorialIdentity: source,
      population: source,
      humanDevelopment: source,
      employment: source,
      safety: source,
      curatedMetrics: source,
      ranking: source,
      publicReviews: null,
    },
    updatedAt: '2026-07-10',
    regionName: null,
    publicOpinion: null,
    budgetSnapshot: {
      cityLabel: id,
      singlePersonExcludingRent: living,
      oneBedroomOutsideCentre: rent,
      oneBedroomCityCentre: rent * 1.2,
      averageMonthlyNetSalary: work * 70,
      monthlyTransportPass: 200,
      utilities: 300,
      updatedAt: '2026-07-10',
      sourceLabel: 'Official budget fixture',
      sourceUrl: 'https://example.gov/budget',
      sourceType: 'official',
    },
    seasonalitySnapshot: null,
  } as CityCardEntity;
}

const catalog = [
  city({
    id: 'curitiba-pr',
    stateCode: 'PR',
    population: 1_770_000,
    latitude: -25.43,
    longitude: -49.27,
    economical: 74,
    work: 78,
    safety: 76,
    rent: 1800,
    living: 2300,
  }),
  city({
    id: 'sao-paulo-sp',
    stateCode: 'SP',
    population: 11_400_000,
    latitude: -23.55,
    longitude: -46.63,
    economical: 35,
    work: 98,
    safety: 54,
    rent: 4200,
    living: 2500,
  }),
  city({
    id: 'santos-sp',
    stateCode: 'SP',
    population: 418_000,
    latitude: -23.96,
    longitude: -46.33,
    economical: 52,
    work: 70,
    safety: 69,
    rent: 3000,
    living: 2200,
  }),
  city({
    id: 'florianopolis-sc',
    stateCode: 'SC',
    population: 537_000,
    latitude: -27.59,
    longitude: -48.55,
    economical: 48,
    work: 76,
    safety: 82,
    rent: 3400,
    living: 2100,
  }),
  city({
    id: 'maragogi-al',
    stateCode: 'AL',
    population: 33_000,
    latitude: -9.01,
    longitude: -35.22,
    economical: 84,
    work: 30,
    safety: 61,
    rent: 1100,
    living: 2700,
  }),
];

function profile(overrides: Record<string, unknown> = {}) {
  return {
    destinationCountryCode: 'BR' as const,
    intent: 'explore_unsure' as const,
    priorities: ['balanced_unsure'],
    constraints: [],
    supportNeeds: [],
    ...overrides,
  };
}

describe('CityRecommendationService', () => {
  const catalogService = {
    getCities: jest.fn().mockResolvedValue(catalog),
  } as unknown as CitiesCatalogService;
  const service = new CityRecommendationService(catalogService);

  beforeEach(() => jest.clearAllMocks());

  it('returns a versioned, ordered result with evidence metadata', async () => {
    const result = await service.recommend(profile());

    expect(result.methodologyVersion).toBe('city-recommendation-v2.2.0');
    expect(result.recommendationId).toMatch(
      /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/,
    );
    expect(result.catalogSize).toBe(catalog.length);
    expect(result.recommendations).toHaveLength(3);
    expect(result.recommendations.map((item) => item.score)).toEqual(
      [...result.recommendations]
        .map((item) => item.score)
        .sort((left, right) => right - left),
    );
    expect(result.sourceSummary.length).toBeGreaterThan(0);
    expect(result.evaluation.scenariosEvaluated).toBeGreaterThan(0);
    expect(['robust', 'moderate', 'sensitive']).toContain(
      result.evaluation.stabilityBand,
    );
    expect(['strong', 'moderate', 'limited']).toContain(
      result.evaluation.reliabilityBand,
    );
    expect(result.recommendations.map((item) => item.rank)).toEqual([1, 2, 3]);
  });

  it('treats mandatory coast, scale, transit and cost constraints as filters', async () => {
    const coast = await service.recommend(
      profile({ constraints: ['want_coast'] }),
    );
    expect(
      coast.recommendations.every((item) =>
        ['santos-sp', 'florianopolis-sc', 'maragogi-al'].includes(item.city.id),
      ),
    ).toBe(true);

    const bigTransit = await service.recommend(
      profile({ constraints: ['need_big_city', 'need_transit'] }),
    );
    expect(bigTransit.appliedHardFilters).toEqual([
      'need_big_city',
      'need_transit',
    ]);
    expect(
      bigTransit.recommendations.every(
        (item) =>
          item.city.population >= 900_000 &&
          ['curitiba-pr', 'sao-paulo-sp'].includes(item.city.id),
      ),
    ).toBe(true);

    const affordable = await service.recommend(
      profile({ constraints: ['avoid_expensive'] }),
    );
    expect(
      affordable.recommendations.some(
        (item) => item.city.id === 'sao-paulo-sp',
      ),
    ).toBe(false);
  });

  it('requires verified higher education presence for a study route', async () => {
    const result = await service.recommend(
      profile({ intent: 'study', priorities: ['university'] }),
    );

    expect(result.appliedHardFilters).toContain('verified_higher_education');
    expect(
      result.recommendations.every((item) =>
        [
          'curitiba-pr',
          'sao-paulo-sp',
          'santos-sp',
          'florianopolis-sc',
        ].includes(item.city.id),
      ),
    ).toBe(true);
    expect(
      result.recommendations.some((item) => item.city.id === 'maragogi-al'),
    ).toBe(false);
  });

  it('uses exact origin coordinates instead of a regional proxy', async () => {
    const result = await service.recommend(
      profile({
        priorities: ['close_to_argentina'],
        originLatitude: -32.8895,
        originLongitude: -68.8458,
      }),
    );
    const curitiba = result.recommendations.find(
      (item) => item.city.id === 'curitiba-pr',
    );
    const sourceEvidence = curitiba?.evidence.find(
      (item) => item.dimension === 'proximity_argentina',
    );

    expect(sourceEvidence?.provider).toContain('Distância geodésica');
    expect(result.warnings).not.toContain(
      'recommendation_warning_origin_distance_unavailable',
    );
  });

  it('uses work arrangement and household composition as scoring inputs', async () => {
    const remote = await service.recommend(
      profile({
        intent: 'remote_income',
        priorities: ['low_cost'],
        workArrangement: 'remote',
      }),
    );
    const localJob = await service.recommend(
      profile({
        intent: 'find_job_br',
        priorities: ['job_opportunities'],
        workArrangement: 'local_job',
      }),
    );
    expect(remote.recommendations[0].city.id).not.toBe(
      localJob.recommendations[0].city.id,
    );

    const solo = await service.recommend(
      profile({ travelGroup: 'solo', priorities: ['low_cost'] }),
    );
    const family = await service.recommend(
      profile({
        travelGroup: 'family_kids',
        childrenCount: 2,
        priorities: ['low_cost'],
      }),
    );
    const soloAffordability = solo.recommendations.find(
      (item) => item.city.id === 'maragogi-al',
    )?.dimensions.affordability;
    const familyAffordability = family.recommendations.find(
      (item) => item.city.id === 'maragogi-al',
    )?.dimensions.affordability;
    expect(soloAffordability).not.toBe(familyAffordability);
  });

  it('scores coast without pretending to measure climate normals', async () => {
    const coastResult = await service.recommend(
      profile({ priorities: ['warm_climate_beach'] }),
    );
    expect(coastResult.unavailableDimensions).not.toContain('climate_warmth');
    expect(coastResult.warnings).not.toContain(
      'recommendation_warning_climate_normals_unavailable',
    );

    const legacyClimateResult = await service.recommend(
      profile({
        priorities: ['nature'],
        constraints: ['prefer_cooler'],
      }),
    );
    expect(legacyClimateResult.warnings).toContain(
      'recommendation_warning_climate_normals_unavailable',
    );
  });
});
