import { Injectable } from '@nestjs/common';
import { randomUUID } from 'node:crypto';

import { CityCardEntity } from '../../domain/entities/city-card.entity';
import { RecommendCitiesDto } from '../../presentation/dto/recommend-cities.dto';
import { CitiesCatalogService } from './cities-catalog.service';

type Dimension =
  | 'affordability'
  | 'job_market'
  | 'safety'
  | 'climate_warmth'
  | 'transit_infra'
  | 'nature'
  | 'university'
  | 'community'
  | 'proximity_argentina'
  | 'family_fit';

type SourceType = 'official' | 'derived' | 'curated' | 'community';
type FreshnessStatus = 'fresh' | 'stale' | 'unknown';

export interface Evidence {
  dimension: Dimension;
  provider: string;
  sourceType: SourceType;
  updatedAt: string | null;
  freshnessStatus: FreshnessStatus;
  url: string | null;
}

interface CitySignals {
  values: Partial<Record<Dimension, number>>;
  evidence: Evidence[];
}

interface ScoredCity {
  city: CityCardEntity;
  score: number;
  dimensions: Partial<Record<Dimension, number>>;
  contributions: Partial<Record<Dimension, number>>;
  evidence: Evidence[];
  dataCoverage: number;
}

const METHODOLOGY_VERSION = 'city-recommendation-v2.3.0';

type StabilityBand = 'robust' | 'moderate' | 'sensitive' | 'insufficient_data';
type ReliabilityBand = 'strong' | 'moderate' | 'limited';
type SeparationBand = 'close' | 'clear' | 'strong' | 'single_result';
type RefinementQuestionId = 'work_arrangement' | 'available_capital';
type RefinementStatus = 'ask' | 'stable' | 'low_gain' | 'no_candidates';

export interface RefinementCandidate {
  questionId: RefinementQuestionId;
  discriminationGain: number;
  scenariosEvaluated: number;
  topCityVariants: number;
}

const COASTAL_CITY_IDS = new Set([
  'florianopolis-sc',
  'rio-de-janeiro-rj',
  'armacao-dos-buzios-rj',
  'arraial-do-cabo-rj',
  'cabo-frio-rj',
  'niteroi-rj',
  'balneario-camboriu-sc',
  'bombinhas-sc',
  'maceio-al',
  'maragogi-al',
  'joao-pessoa-pb',
  'recife-pe',
  'natal-rn',
  'aracaju-se',
  'salvador-ba',
  'porto-seguro-ba',
  'santos-sp',
  'ubatuba-sp',
  'paraty-rj',
  'tibau-do-sul-rn',
  'jijoca-de-jericoacoara-ce',
  'ilhabela-sp',
  'guaruja-sp',
  'garopaba-sc',
  'imbituba-sc',
  'itacare-ba',
  'sao-miguel-do-gostoso-rn',
  'cairu-ba',
  'itajai-sc',
]);

// Presence of a public university or a public higher-education campus in the
// municipality. This is intentionally categorical: the engine does not invent
// a quality score from population. Refresh against INEP/e-MEC before releases.
const PUBLIC_HIGHER_EDUCATION_CITY_IDS = new Set([
  'sao-paulo-sp',
  'rio-de-janeiro-rj',
  'brasilia-df',
  'belo-horizonte-mg',
  'campinas-sp',
  'curitiba-pr',
  'porto-alegre-rs',
  'florianopolis-sc',
  'recife-pe',
  'salvador-ba',
  'fortaleza-ce',
  'joao-pessoa-pb',
  'natal-rn',
  'maceio-al',
  'aracaju-se',
  'foz-do-iguacu-pr',
  'joinville-sc',
  'chapeco-sc',
  'niteroi-rj',
  'santos-sp',
]);

// Municipalities with a documented high-capacity or structurally integrated
// urban transport network. Missing cities are treated as unknown, never
// estimated from population or job-market scores.
const VERIFIED_TRANSIT_CITY_SCORES: Record<string, number> = {
  'sao-paulo-sp': 1,
  'rio-de-janeiro-rj': 0.95,
  'brasilia-df': 0.84,
  'belo-horizonte-mg': 0.84,
  'porto-alegre-rs': 0.82,
  'recife-pe': 0.82,
  'salvador-ba': 0.8,
  'fortaleza-ce': 0.78,
  'curitiba-pr': 0.86,
  'campinas-sp': 0.7,
  'florianopolis-sc': 0.64,
};

const BASE_WEIGHTS: Record<string, Partial<Record<Dimension, number>>> = {
  find_job_br: {
    job_market: 0.34,
    affordability: 0.2,
    transit_infra: 0.14,
    community: 0.12,
    safety: 0.12,
    proximity_argentina: 0.08,
  },
  remote_income: {
    affordability: 0.28,
    safety: 0.2,
    community: 0.15,
    nature: 0.15,
    transit_infra: 0.1,
    proximity_argentina: 0.12,
  },
  study: {
    university: 0.38,
    affordability: 0.2,
    transit_infra: 0.16,
    community: 0.1,
    job_market: 0.08,
    safety: 0.08,
  },
  family_partner: {
    family_fit: 0.3,
    safety: 0.24,
    affordability: 0.18,
    community: 0.1,
    proximity_argentina: 0.1,
    transit_infra: 0.08,
  },
  fresh_start: {
    safety: 0.24,
    affordability: 0.24,
    job_market: 0.18,
    community: 0.12,
    nature: 0.1,
    transit_infra: 0.12,
  },
  explore_unsure: {
    affordability: 0.2,
    safety: 0.2,
    job_market: 0.16,
    community: 0.12,
    proximity_argentina: 0.12,
    nature: 0.1,
    transit_infra: 0.1,
  },
};

const PRIORITY_DIMENSIONS: Record<
  string,
  Partial<Record<Dimension, number>>
> = {
  low_cost: { affordability: 1 },
  job_opportunities: { job_market: 1 },
  safety: { safety: 1 },
  // The current catalog can verify coast/nature, but it does not yet contain
  // comparable climate normals. Keep the legacy profile key for compatibility
  // while scoring only the signal the product can actually substantiate.
  warm_climate_beach: { nature: 1 },
  transit_infra: { transit_infra: 1 },
  nature: { nature: 1 },
  university: { university: 1 },
  community: { community: 1 },
  close_to_argentina: { proximity_argentina: 1 },
};

@Injectable()
export class CityRecommendationService {
  constructor(private readonly citiesCatalogService: CitiesCatalogService) {}

  async recommend(profile: RecommendCitiesDto) {
    const catalog = await this.citiesCatalogService.getCities({
      countryCode: profile.destinationCountryCode,
    });
    const budgetCosts = catalog
      .map((city) => this.monthlyLandingCost(city, profile))
      .filter((value): value is number => value != null)
      .sort((left, right) => left - right);
    const affordableCeiling = this.percentile(budgetCosts, 0.65);
    const hardFilters = this.hardFilters(profile, affordableCeiling);
    const eligible = catalog.filter((city) =>
      hardFilters.every((filter) => filter.accept(city)),
    );
    const weights = this.buildWeights(profile);
    const warnings = this.profileWarnings(profile, eligible.length);

    const ranked = this.rankCities(eligible, profile, weights, budgetCosts);
    const evaluation = this.evaluateRanking({
      eligible,
      profile,
      weights,
      budgetCosts,
      ranked,
    });
    const refinement = this.selectRefinement({
      profile,
      eligible,
      budgetCosts,
      ranked,
      evaluation,
    });

    const recommendations = ranked.slice(0, 3).map((item, index) => ({
      rank: index + 1,
      city: item.city,
      score: this.round(item.score),
      dimensions: this.roundRecord(item.dimensions),
      reasons: this.reasons(item),
      tradeoffs: this.tradeoffs(item, weights),
      dataCoverage: this.round(item.dataCoverage),
      dataUpdatedAt: this.latestEvidenceDate(item.evidence),
      freshnessStatus: this.overallFreshness(item.evidence),
      evidence: item.evidence,
    }));

    const unavailableDimensions = Object.keys(weights).filter(
      (dimension) =>
        !ranked.some((item) => item.dimensions[dimension as Dimension] != null),
    );
    if (unavailableDimensions.length > 0) {
      warnings.push('recommendation_warning_missing_dimensions');
    }

    return {
      recommendationId: randomUUID(),
      methodologyVersion: METHODOLOGY_VERSION,
      generatedAt: new Date().toISOString(),
      catalogSize: catalog.length,
      eligibleCityCount: eligible.length,
      profileCompleteness: this.profileCompleteness(profile),
      dataCoverage:
        recommendations.length === 0
          ? 0
          : this.round(
              recommendations.reduce(
                (sum, item) => sum + item.dataCoverage,
                0,
              ) / recommendations.length,
            ),
      appliedHardFilters: hardFilters.map((filter) => filter.id),
      unavailableDimensions,
      warnings: [...new Set(warnings)],
      evaluation: {
        ...evaluation,
        reliabilityBand: this.reliabilityBand(
          evaluation.stabilityBand,
          this.profileCompleteness(profile),
          recommendations.length === 0
            ? 0
            : recommendations.reduce(
                (sum, item) => sum + item.dataCoverage,
                0,
              ) / recommendations.length,
        ),
      },
      refinement,
      recommendations,
      sourceSummary: this.sourceSummary(recommendations),
    };
  }

  private selectRefinement({
    profile,
    eligible,
    budgetCosts,
    ranked,
    evaluation,
  }: {
    profile: RecommendCitiesDto;
    eligible: CityCardEntity[];
    budgetCosts: number[];
    ranked: ScoredCity[];
    evaluation: {
      stabilityBand: StabilityBand;
      scoreSeparationBand: SeparationBand;
    };
  }) {
    if (ranked.length === 0) {
      return this.refinementResponse('no_candidates', null, [], 0);
    }

    const candidates: Array<{
      questionId: RefinementQuestionId;
      values: string[];
      apply: (value: string) => RecommendCitiesDto;
    }> = [];

    if (!profile.workArrangement) {
      candidates.push({
        questionId: 'work_arrangement',
        values: ['remote', 'local_job', 'both_open'],
        apply: (value) => ({
          ...profile,
          workArrangement: value as RecommendCitiesDto['workArrangement'],
        }),
      });
    }
    if (!profile.availableCapital) {
      candidates.push({
        questionId: 'available_capital',
        values: ['low', 'medium', 'high', 'very_high', 'prefer_not_say'],
        apply: (value) => ({ ...profile, availableCapital: value }),
      });
    }

    if (candidates.length === 0) {
      return this.refinementResponse('no_candidates', null, [], 0);
    }

    const evaluated = candidates
      .map((candidate) => {
        const scenarioRankings = candidate.values.map((value) => {
          const scenarioProfile = candidate.apply(value);
          return this.rankCities(
            eligible,
            scenarioProfile,
            this.buildWeights(scenarioProfile),
            budgetCosts,
          );
        });
        const usableRankings = scenarioRankings.filter(
          (scenario) => scenario.length > 0,
        );
        const discriminationGain =
          usableRankings.length === 0
            ? 0
            : usableRankings.reduce(
                (sum, scenario) =>
                  sum + this.rankingDiscrimination(ranked, scenario),
                0,
              ) / usableRankings.length;
        return {
          questionId: candidate.questionId,
          discriminationGain: this.round(discriminationGain),
          scenariosEvaluated: usableRankings.length,
          topCityVariants: new Set(
            usableRankings.map((scenario) => scenario[0]?.city.id),
          ).size,
        } satisfies RefinementCandidate;
      })
      .sort(
        (left, right) =>
          right.discriminationGain - left.discriminationGain ||
          left.questionId.localeCompare(right.questionId),
      );

    const best = evaluated[0];
    const minimumGain = this.minimumRefinementGain(
      evaluation.scoreSeparationBand,
    );
    if (best.discriminationGain < minimumGain) {
      const status: RefinementStatus =
        evaluation.stabilityBand === 'robust' &&
        evaluation.scoreSeparationBand !== 'close'
          ? 'stable'
          : 'low_gain';
      return this.refinementResponse(status, null, evaluated, minimumGain);
    }

    return this.refinementResponse(
      'ask',
      best.questionId,
      evaluated,
      minimumGain,
    );
  }

  private rankingDiscrimination(
    baseline: ScoredCity[],
    scenario: ScoredCity[],
  ) {
    const baselineTop = baseline.slice(0, 3);
    const scenarioTop = scenario.slice(0, 3);
    if (baselineTop.length === 0 || scenarioTop.length === 0) return 0;

    const topChanged =
      baselineTop[0].city.id === scenarioTop[0].city.id ? 0 : 1;
    const scenarioPositions = new Map(
      scenarioTop.map((item, index) => [item.city.id, index]),
    );
    const rankDistance =
      baselineTop.reduce((sum, item, index) => {
        const scenarioIndex = scenarioPositions.get(item.city.id) ?? 3;
        return sum + Math.abs(index - scenarioIndex);
      }, 0) /
      (baselineTop.length * 3);

    return topChanged * 0.7 + rankDistance * 0.3;
  }

  private minimumRefinementGain(separation: SeparationBand) {
    return separation === 'close' ? 0.05 : separation === 'clear' ? 0.08 : 0.12;
  }

  private refinementResponse(
    status: RefinementStatus,
    questionId: RefinementQuestionId | null,
    candidates: RefinementCandidate[],
    minimumGain: number,
  ) {
    const gain = questionId
      ? (candidates.find((item) => item.questionId === questionId)
          ?.discriminationGain ?? 0)
      : (candidates[0]?.discriminationGain ?? 0);
    const gainBand =
      gain >= 0.3
        ? 'high'
        : gain >= 0.15
          ? 'moderate'
          : gain > 0
            ? 'low'
            : 'none';
    return {
      status,
      questionId,
      discriminationGain: this.round(gain),
      gainBand,
      minimumGain,
      scenariosEvaluated: candidates.reduce(
        (sum, item) => sum + item.scenariosEvaluated,
        0,
      ),
      candidates,
    };
  }

  private rankCities(
    cities: CityCardEntity[],
    profile: RecommendCitiesDto,
    weights: Partial<Record<Dimension, number>>,
    budgetCosts: number[],
  ) {
    return cities
      .map((city) => this.scoreCity(city, profile, weights, budgetCosts))
      .filter((item): item is ScoredCity => item != null)
      .sort(
        (left, right) =>
          right.score - left.score || left.city.id.localeCompare(right.city.id),
      );
  }

  private evaluateRanking({
    eligible,
    profile,
    weights,
    budgetCosts,
    ranked,
  }: {
    eligible: CityCardEntity[];
    profile: RecommendCitiesDto;
    weights: Partial<Record<Dimension, number>>;
    budgetCosts: number[];
    ranked: ScoredCity[];
  }): {
    stabilityBand: StabilityBand;
    scoreSeparationBand: SeparationBand;
    scenariosEvaluated: number;
    topCityStable: boolean;
  } {
    if (ranked.length === 0) {
      return {
        stabilityBand: 'insufficient_data',
        scoreSeparationBand: 'single_result',
        scenariosEvaluated: 0,
        topCityStable: false,
      };
    }

    const topCityId = ranked[0].city.id;
    const dimensions = Object.entries(weights).filter(
      ([, weight]) => (weight ?? 0) > 0,
    );
    let stableScenarios = 0;
    let scenariosEvaluated = 0;

    for (const [rawDimension] of dimensions) {
      const dimension = rawDimension as Dimension;
      for (const factor of [0.75, 1.25]) {
        const scenarioWeights = this.normalizeWeights({
          ...weights,
          [dimension]: (weights[dimension] ?? 0) * factor,
        });
        const scenario = this.rankCities(
          eligible,
          profile,
          scenarioWeights,
          budgetCosts,
        );
        if (scenario.length === 0) continue;
        scenariosEvaluated += 1;
        if (scenario[0].city.id === topCityId) stableScenarios += 1;
      }
    }

    const stableShare =
      scenariosEvaluated === 0 ? 0 : stableScenarios / scenariosEvaluated;
    const stabilityBand: StabilityBand =
      scenariosEvaluated === 0
        ? 'insufficient_data'
        : stableShare >= 0.85
          ? 'robust'
          : stableShare >= 0.6
            ? 'moderate'
            : 'sensitive';
    const margin =
      ranked.length < 2 ? null : Math.max(0, ranked[0].score - ranked[1].score);
    const scoreSeparationBand: SeparationBand =
      margin == null
        ? 'single_result'
        : margin < 0.04
          ? 'close'
          : margin < 0.1
            ? 'clear'
            : 'strong';

    return {
      stabilityBand,
      scoreSeparationBand,
      scenariosEvaluated,
      topCityStable: stableShare >= 0.85,
    };
  }

  private reliabilityBand(
    stability: StabilityBand,
    profileCompleteness: number,
    dataCoverage: number,
  ): ReliabilityBand {
    if (
      stability === 'insufficient_data' ||
      stability === 'sensitive' ||
      profileCompleteness < 0.55 ||
      dataCoverage < 0.55
    ) {
      return 'limited';
    }
    if (
      stability === 'robust' &&
      profileCompleteness >= 0.75 &&
      dataCoverage >= 0.75
    ) {
      return 'strong';
    }
    return 'moderate';
  }

  private normalizeWeights(
    weights: Partial<Record<Dimension, number>>,
  ): Partial<Record<Dimension, number>> {
    const total = Object.values(weights).reduce(
      (sum, value) => sum + (value ?? 0),
      0,
    );
    if (total <= 0) return weights;
    return Object.fromEntries(
      Object.entries(weights).map(([dimension, value]) => [
        dimension,
        (value ?? 0) / total,
      ]),
    ) as Partial<Record<Dimension, number>>;
  }

  private buildWeights(
    profile: RecommendCitiesDto,
  ): Partial<Record<Dimension, number>> {
    const weights = {
      ...(BASE_WEIGHTS[profile.intent] ?? BASE_WEIGHTS.explore_unsure),
    };
    for (const priority of profile.priorities) {
      this.mergeWeights(weights, PRIORITY_DIMENSIONS[priority] ?? {});
    }
    if (profile.workArrangement === 'remote') {
      this.mergeWeights(weights, { affordability: 0.4, nature: 0.2 });
    } else if (profile.workArrangement === 'local_job') {
      this.mergeWeights(weights, { job_market: 0.5, transit_infra: 0.2 });
    }
    if (
      profile.travelGroup === 'family_kids' ||
      profile.travelGroup === 'solo_parent' ||
      (profile.childrenCount ?? 0) > 0
    ) {
      this.mergeWeights(weights, { family_fit: 0.5, safety: 0.2 });
    }
    if (profile.availableCapital === 'low') {
      this.mergeWeights(weights, { affordability: 0.5 });
    } else if (profile.availableCapital === 'medium') {
      this.mergeWeights(weights, { affordability: 0.25 });
    }
    const total = Object.values(weights).reduce(
      (sum, value) => sum + (value ?? 0),
      0,
    );
    return Object.fromEntries(
      Object.entries(weights).map(([key, value]) => [
        key,
        (value ?? 0) / Math.max(total, 0.0001),
      ]),
    ) as Partial<Record<Dimension, number>>;
  }

  private scoreCity(
    city: CityCardEntity,
    profile: RecommendCitiesDto,
    weights: Partial<Record<Dimension, number>>,
    budgetCosts: number[],
  ): ScoredCity | null {
    const signals = this.signals(city, profile, budgetCosts);
    let weightedScore = 0;
    let availableWeight = 0;
    const contributions: Partial<Record<Dimension, number>> = {};

    for (const [rawDimension, weight] of Object.entries(weights)) {
      const dimension = rawDimension as Dimension;
      const value = signals.values[dimension];
      if (value == null || weight == null) continue;
      const contribution = value * weight;
      weightedScore += contribution;
      availableWeight += weight;
      contributions[dimension] = contribution;
    }
    if (availableWeight === 0) return null;

    let score = weightedScore / availableWeight;
    if (
      profile.constraints?.includes('prefer_south') &&
      !['RS', 'SC', 'PR'].includes(city.stateCode)
    ) {
      score *= 0.82;
    }
    if (
      profile.constraints?.includes('prefer_mid_city') &&
      (city.population < 250_000 || city.population >= 900_000)
    ) {
      score *= 0.86;
    }
    if (profile.constraints?.includes('prefer_cooler')) {
      // No climate-normal dataset is currently loaded. Do not recreate the
      // removed latitude proxy; expose the data gap instead.
      score *= 1;
    }

    return {
      city,
      score: Math.max(0, Math.min(1, score)),
      dimensions: signals.values,
      contributions,
      evidence: signals.evidence,
      dataCoverage: availableWeight,
    };
  }

  private signals(
    city: CityCardEntity,
    profile: RecommendCitiesDto,
    budgetCosts: number[],
  ): CitySignals {
    const values: Partial<Record<Dimension, number>> = {};
    const evidence: Evidence[] = [];
    const budgetCost = this.monthlyLandingCost(city, profile);
    if (budgetCost != null && budgetCosts.length > 1) {
      const min = budgetCosts[0];
      const max = budgetCosts[budgetCosts.length - 1];
      values.affordability = 1 - (budgetCost - min) / Math.max(max - min, 1);
      evidence.push(
        this.evidence(
          'affordability',
          city.budgetSnapshot!.sourceLabel,
          city.budgetSnapshot!.sourceType,
          city.budgetSnapshot!.updatedAt,
          city.budgetSnapshot!.sourceUrl,
        ),
      );
    } else {
      values.affordability = city.movaroScores.economical / 100;
      evidence.push(
        this.evidence(
          'affordability',
          city.sources.curatedMetrics.provider,
          'curated',
          city.updatedAt,
          city.sources.curatedMetrics.url,
        ),
      );
    }

    const salaryCoverage =
      city.budgetSnapshot == null || budgetCost == null
        ? null
        : city.budgetSnapshot.averageMonthlyNetSalary / Math.max(budgetCost, 1);
    values.job_market =
      salaryCoverage == null
        ? city.movaroScores.workOpportunity / 100
        : Math.max(
            0,
            Math.min(
              1,
              (city.movaroScores.workOpportunity / 100) * 0.55 +
                Math.min(salaryCoverage / 1.2, 1) * 0.45,
            ),
          );
    evidence.push(
      this.evidence(
        'job_market',
        city.sources.employment?.provider ??
          city.sources.curatedMetrics.provider,
        city.sources.employment?.sourceType ?? 'curated',
        city.sources.employment?.updatedAt ?? city.updatedAt,
        city.sources.employment?.url ?? city.sources.curatedMetrics.url,
      ),
    );

    values.safety = city.safetyScore / 100;
    evidence.push(
      this.evidence(
        'safety',
        city.sources.safety?.provider ?? city.sources.curatedMetrics.provider,
        city.sources.safety?.sourceType ?? 'curated',
        city.sources.safety?.updatedAt ?? city.updatedAt,
        city.sources.safety?.url ?? city.sources.curatedMetrics.url,
      ),
    );

    values.nature = COASTAL_CITY_IDS.has(city.id) ? 1 : 0.45;
    evidence.push(
      this.evidence(
        'nature',
        'IBGE Localidades e posição territorial',
        'derived',
        city.updatedAt,
        city.sources.territorialIdentity.url,
      ),
    );

    values.community =
      (city.argentinaPopularityScore * 0.7 + city.spanishSupportScore * 0.3) /
      100;
    evidence.push(
      this.evidence(
        'community',
        city.sources.curatedMetrics.provider,
        'curated',
        city.updatedAt,
        city.sources.curatedMetrics.url,
      ),
    );

    if (PUBLIC_HIGHER_EDUCATION_CITY_IDS.has(city.id)) {
      values.university = 1;
      evidence.push(
        this.evidence(
          'university',
          'Presença municipal derivada do Censo da Educação Superior / INEP',
          'derived',
          '2026-07-09',
          'https://www.gov.br/inep/pt-br/acesso-a-informacao/dados-abertos/microdados/censo-da-educacao-superior',
        ),
      );
    }

    const transit = VERIFIED_TRANSIT_CITY_SCORES[city.id];
    if (transit != null) {
      values.transit_infra = transit;
      evidence.push(
        this.evidence(
          'transit_infra',
          'Curadoria Movaro sobre o Projeto Acesso a Oportunidades / Ipea',
          'curated',
          '2026-07-29',
          'https://www.ipea.gov.br/acessooportunidades/',
        ),
      );
    }

    if (profile.originLatitude != null && profile.originLongitude != null) {
      const distance = this.haversineKm(
        profile.originLatitude,
        profile.originLongitude,
        city.latitude,
        city.longitude,
      );
      values.proximity_argentina = Math.max(
        0,
        1 - Math.min(distance, 4000) / 4000,
      );
      evidence.push(
        this.evidence(
          'proximity_argentina',
          'Distância geodésica entre origem confirmada e município IBGE',
          'derived',
          new Date().toISOString().slice(0, 10),
          city.sources.territorialIdentity.url,
        ),
      );
    }

    const hasChildren =
      profile.travelGroup === 'family_kids' ||
      profile.travelGroup === 'solo_parent' ||
      (profile.childrenCount ?? 0) > 0 ||
      profile.supportNeeds?.includes('children_school');
    if (hasChildren) {
      values.family_fit = values.safety! * 0.55 + values.affordability! * 0.45;
      evidence.push(
        this.evidence(
          'family_fit',
          'Composição de segurança municipal e orçamento familiar',
          'derived',
          city.budgetSnapshot?.updatedAt ?? city.updatedAt,
          city.budgetSnapshot?.sourceUrl ?? city.sources.safety?.url ?? null,
        ),
      );
    } else {
      values.family_fit = values.safety! * 0.5 + values.affordability! * 0.5;
      evidence.push(
        this.evidence(
          'family_fit',
          'Composição de segurança municipal e orçamento domiciliar',
          'derived',
          city.budgetSnapshot?.updatedAt ?? city.updatedAt,
          city.budgetSnapshot?.sourceUrl ?? city.sources.safety?.url ?? null,
        ),
      );
    }

    return { values, evidence };
  }

  private hardFilters(profile: RecommendCitiesDto, affordableCeiling: number) {
    const constraints = new Set(profile.constraints ?? []);
    const filters: Array<{
      id: string;
      accept: (city: CityCardEntity) => boolean;
    }> = [];
    if (constraints.has('want_coast')) {
      filters.push({
        id: 'want_coast',
        accept: (city) => COASTAL_CITY_IDS.has(city.id),
      });
    }
    if (constraints.has('need_big_city')) {
      filters.push({
        id: 'need_big_city',
        accept: (city) => city.population >= 900_000,
      });
    }
    if (constraints.has('need_transit')) {
      filters.push({
        id: 'need_transit',
        accept: (city) => VERIFIED_TRANSIT_CITY_SCORES[city.id] != null,
      });
    }
    if (constraints.has('avoid_expensive')) {
      filters.push({
        id: 'avoid_expensive',
        accept: (city) => {
          const cost = this.monthlyLandingCost(city, profile);
          return cost != null && cost <= affordableCeiling;
        },
      });
    }
    if (
      profile.intent === 'study' ||
      profile.priorities.includes('university')
    ) {
      filters.push({
        id: 'verified_higher_education',
        accept: (city) => PUBLIC_HIGHER_EDUCATION_CITY_IDS.has(city.id),
      });
    }
    return filters;
  }

  private monthlyLandingCost(
    city: CityCardEntity,
    profile: RecommendCitiesDto,
  ): number | null {
    const budget = city.budgetSnapshot;
    if (budget == null) return null;
    const adults =
      profile.travelGroup === 'partner' || profile.travelGroup === 'family_kids'
        ? 2
        : 1;
    const children = Math.max(profile.childrenCount ?? 0, 0);
    const householdFactor = 1 + (adults - 1) * 0.55 + children * 0.35;
    return (
      budget.oneBedroomOutsideCentre +
      budget.utilities +
      budget.singlePersonExcludingRent * householdFactor +
      budget.monthlyTransportPass * adults
    );
  }

  private profileWarnings(profile: RecommendCitiesDto, eligibleCount: number) {
    const warnings: string[] = [];
    if (profile.originLatitude == null || profile.originLongitude == null) {
      warnings.push('recommendation_warning_origin_distance_unavailable');
    }
    if (profile.constraints?.includes('prefer_cooler')) {
      warnings.push('recommendation_warning_climate_normals_unavailable');
    }
    if (eligibleCount < 3) {
      warnings.push('recommendation_warning_few_eligible_cities');
    }
    return warnings;
  }

  private profileCompleteness(profile: RecommendCitiesDto) {
    let score = 0.5;
    if (!profile.priorities.includes('balanced_unsure')) score += 0.18;
    if ((profile.constraints?.length ?? 0) > 0) score += 0.08;
    if (profile.funding && profile.funding !== 'dont_know') score += 0.08;
    if (profile.workArrangement) score += 0.06;
    if (profile.travelGroup) score += 0.04;
    if (profile.originLatitude != null && profile.originLongitude != null) {
      score += 0.06;
    }
    return this.round(Math.min(score, 1));
  }

  private reasons(item: ScoredCity) {
    const reasonByDimension: Record<Dimension, string> = {
      affordability: 'plan_reason_budget_fit',
      job_market: 'plan_reason_job_mobility',
      safety: 'plan_reason_safety',
      climate_warmth: 'plan_reason_climate_nature',
      transit_infra: 'plan_reason_transit',
      nature: 'plan_reason_climate_nature',
      university: 'plan_reason_university',
      community: 'plan_reason_community',
      proximity_argentina: 'plan_reason_proximity_argentina',
      family_fit: 'plan_reason_family_fit',
    };
    return Object.entries(item.contributions)
      .sort((left, right) => (right[1] ?? 0) - (left[1] ?? 0))
      .map(([dimension]) => reasonByDimension[dimension as Dimension])
      .filter((value, index, values) => values.indexOf(value) === index)
      .slice(0, 3);
  }

  private tradeoffs(
    item: ScoredCity,
    weights: Partial<Record<Dimension, number>>,
  ) {
    const unavailable = Object.keys(weights).filter(
      (dimension) => item.dimensions[dimension as Dimension] == null,
    );
    const tradeoffs = unavailable.length > 0 ? ['tradeoff_data_gap'] : [];
    if ((item.dimensions.affordability ?? 1) < 0.4) {
      tradeoffs.push('tradeoff_cost_pressure');
    }
    if ((item.dimensions.job_market ?? 1) < 0.45) {
      tradeoffs.push('tradeoff_job_market');
    }
    return tradeoffs.slice(0, 2);
  }

  private evidence(
    dimension: Dimension,
    provider: string,
    sourceType: SourceType,
    updatedAt: string | null,
    url: string | null,
  ): Evidence {
    return {
      dimension,
      provider,
      sourceType,
      updatedAt,
      freshnessStatus: this.freshness(sourceType, updatedAt),
      url,
    };
  }

  private freshness(
    sourceType: SourceType,
    updatedAt: string | null,
  ): FreshnessStatus {
    if (updatedAt == null) return 'unknown';
    const date = new Date(updatedAt);
    if (Number.isNaN(date.getTime())) return 'unknown';
    const ageDays = (Date.now() - date.getTime()) / 86_400_000;
    const maxDays =
      sourceType === 'official'
        ? 90
        : sourceType === 'derived'
          ? 30
          : sourceType === 'community'
            ? 14
            : 180;
    return ageDays <= maxDays ? 'fresh' : 'stale';
  }

  private overallFreshness(evidence: Evidence[]): FreshnessStatus {
    if (evidence.some((item) => item.freshnessStatus === 'stale')) {
      return 'stale';
    }
    if (evidence.some((item) => item.freshnessStatus === 'unknown')) {
      return 'unknown';
    }
    return 'fresh';
  }

  private latestEvidenceDate(evidence: Evidence[]) {
    const dates = evidence
      .map((item) => item.updatedAt)
      .filter((value): value is string => value != null)
      .sort();
    return dates.at(-1) ?? null;
  }

  private sourceSummary(
    recommendations: Array<{
      evidence: Evidence[];
    }>,
  ) {
    const unique = new Map<string, Evidence>();
    for (const recommendation of recommendations) {
      for (const evidence of recommendation.evidence) {
        const key = `${evidence.dimension}:${evidence.provider}`;
        if (!unique.has(key)) unique.set(key, evidence);
      }
    }
    return [...unique.values()];
  }

  private mergeWeights(
    target: Partial<Record<Dimension, number>>,
    extra: Partial<Record<Dimension, number>>,
  ) {
    for (const [dimension, value] of Object.entries(extra)) {
      const key = dimension as Dimension;
      target[key] = (target[key] ?? 0) + (value ?? 0);
    }
  }

  private percentile(values: number[], percentile: number) {
    if (values.length === 0) return Number.POSITIVE_INFINITY;
    const index = Math.min(
      values.length - 1,
      Math.floor((values.length - 1) * percentile),
    );
    return values[index];
  }

  private haversineKm(lat1: number, lon1: number, lat2: number, lon2: number) {
    const radians = (degrees: number) => (degrees * Math.PI) / 180;
    const dLat = radians(lat2 - lat1);
    const dLon = radians(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(radians(lat1)) *
        Math.cos(radians(lat2)) *
        Math.sin(dLon / 2) ** 2;
    return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  }

  private round(value: number) {
    return Math.round(value * 10_000) / 10_000;
  }

  private roundRecord(
    record: Partial<Record<Dimension, number>>,
  ): Partial<Record<Dimension, number>> {
    return Object.fromEntries(
      Object.entries(record).map(([key, value]) => [
        key,
        this.round(value ?? 0),
      ]),
    );
  }
}
