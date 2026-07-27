import { Injectable } from '@nestjs/common';

import { GooglePlacesCityOpinionService } from '../../../../integrations/google/google-places-city-opinion.service';
import { IbgeLocalitiesService } from '../../../../integrations/ibge/ibge-localities.service';
import { IbgePopulationService } from '../../../../integrations/ibge/ibge-population.service';
import { CityMetricsModel } from '../../data/models/city-metrics.model';
import { CityBudgetSnapshotEntity } from '../../domain/entities/city-budget-snapshot.entity';
import { CityCardEntity } from '../../domain/entities/city-card.entity';
import { CitySeasonalitySnapshotEntity } from '../../domain/entities/city-seasonality-snapshot.entity';
import { CitySourceEntity } from '../../domain/entities/city-source.entity';
import { CitySourcesEntity } from '../../domain/entities/city-sources.entity';
import { CityBudgetSnapshotService } from './city-budget-snapshot.service';
import { CityOfficialMetricsService } from './city-official-metrics.service';
import { CityPublicOpinionSeedService } from './city-public-opinion-seed.service';
import { CityRankingService } from './city-ranking.service';
import { CitySeasonalitySnapshotService } from './city-seasonality-snapshot.service';

@Injectable()
export class CityMergeService {
  constructor(
    private readonly ibgeLocalitiesService: IbgeLocalitiesService,
    private readonly ibgePopulationService: IbgePopulationService,
    private readonly cityRankingService: CityRankingService,
    private readonly googlePlacesCityOpinionService: GooglePlacesCityOpinionService,
    private readonly cityPublicOpinionSeedService: CityPublicOpinionSeedService,
    private readonly cityBudgetSnapshotService: CityBudgetSnapshotService,
    private readonly citySeasonalitySnapshotService: CitySeasonalitySnapshotService,
    private readonly cityOfficialMetricsService: CityOfficialMetricsService,
  ) {}

  async merge(metrics: CityMetricsModel): Promise<CityCardEntity> {
    const officialMetrics = this.cityOfficialMetricsService.findByCity({
      cityId: metrics.id,
      ibgeCode: metrics.ibgeCode,
    });
    const resolvedMetrics = this.applyOfficialOverrides(
      metrics,
      officialMetrics,
    );
    const [ibgeData, populationEstimate] = await Promise.all([
      this.ibgeLocalitiesService.getMunicipalityByIbgeCode(metrics.ibgeCode),
      this.ibgePopulationService.getPopulationEstimateByIbgeCode(
        metrics.ibgeCode,
      ),
    ]);
    const scores = this.cityRankingService.calculateScores(resolvedMetrics);
    const recommendationReasons =
      this.cityRankingService.buildRecommendationReasons(
        resolvedMetrics,
        scores,
      );
    const officialName =
      ibgeData.officialName?.trim() || metrics.displayName || metrics.name;
    const stateCode =
      ibgeData.stateCode?.trim() || this.inferStateCode(metrics.id);
    const stateName =
      ibgeData.stateName?.trim() || this.stateNameFromCode(stateCode);
    const sources = this.buildSources({
      stateCode,
      officialName,
      officialMetrics,
    });
    const publicOpinion =
      (await this.googlePlacesCityOpinionService.getCityOpinion(
        resolvedMetrics,
        stateName,
      )) ?? this.cityPublicOpinionSeedService.findByCityId(resolvedMetrics.id);
    const budgetSnapshot = this.resolveBudgetSnapshot(resolvedMetrics);
    const seasonalitySnapshot =
      this.resolveSeasonalitySnapshot(resolvedMetrics);
    const sourcesWithOpinion = publicOpinion
      ? new CitySourcesEntity(
          sources.territorialIdentity,
          sources.population,
          sources.humanDevelopment,
          sources.employment,
          sources.safety,
          sources.curatedMetrics,
          sources.ranking,
          new CitySourceEntity(
            'public_reviews',
            'Percepcao publica',
            publicOpinion.provider,
            publicOpinion.provider === 'Google Maps'
              ? 'Leitura automatica de temas recorrentes em avaliacoes publicas da localidade. Nao representa a opiniao de toda a cidade.'
              : 'Leitura comunitaria agregada de qualidade de vida e custo publicada por fonte externa. Serve como sinal complementar, nao como consenso absoluto.',
            false,
            publicOpinion.placeUrl,
            publicOpinion.provider === 'Google Maps' ? 'curated' : 'community',
          ),
        )
      : sources;

    return new CityCardEntity(
      resolvedMetrics.id,
      resolvedMetrics.displayName ?? officialName,
      stateCode,
      stateName,
      resolvedMetrics.countryCode,
      resolvedMetrics.ibgeCode,
      resolvedMetrics.latitude,
      resolvedMetrics.longitude,
      populationEstimate.population,
      resolvedMetrics.idhmScore,
      resolvedMetrics.idhmReferenceYear,
      resolvedMetrics.costOfLivingScore,
      resolvedMetrics.rentScore,
      resolvedMetrics.safetyScore,
      resolvedMetrics.argentinaPopularityScore,
      resolvedMetrics.spanishSupportScore,
      resolvedMetrics.jobMarketScore,
      resolvedMetrics.unemploymentRate,
      resolvedMetrics.economicActivityScore,
      resolvedMetrics.topIndustries,
      scores,
      recommendationReasons,
      sourcesWithOpinion,
      resolvedMetrics.updatedAt,
      ibgeData.regionName,
      publicOpinion,
      budgetSnapshot,
      seasonalitySnapshot,
    );
  }

  private applyOfficialOverrides(
    metrics: CityMetricsModel,
    officialMetrics: ReturnType<CityOfficialMetricsService['findByCity']>,
  ): CityMetricsModel {
    if (officialMetrics == null) {
      return metrics;
    }

    return {
      ...metrics,
      idhmScore: officialMetrics.development?.idhmScore ?? metrics.idhmScore,
      idhmReferenceYear:
        officialMetrics.development?.idhmReferenceYear ??
        metrics.idhmReferenceYear,
      unemploymentRate:
        officialMetrics.employment?.unemploymentRate ??
        metrics.unemploymentRate,
      jobMarketScore:
        officialMetrics.employment?.jobMarketScore ?? metrics.jobMarketScore,
      economicActivityScore:
        officialMetrics.employment?.economicActivityScore ??
        metrics.economicActivityScore,
      topIndustries:
        officialMetrics.employment?.topIndustries ?? metrics.topIndustries,
      safetyScore: officialMetrics.safety?.safetyScore ?? metrics.safetyScore,
    };
  }

  private resolveBudgetSnapshot(
    metrics: CityMetricsModel,
  ): CityBudgetSnapshotEntity | null {
    const snapshot = metrics.budgetSnapshot;
    if (snapshot) {
      return new CityBudgetSnapshotEntity(
        snapshot.cityLabel,
        snapshot.singlePersonExcludingRent,
        snapshot.oneBedroomOutsideCentre,
        snapshot.oneBedroomCityCentre,
        snapshot.averageMonthlyNetSalary,
        snapshot.monthlyTransportPass,
        snapshot.utilities,
        snapshot.updatedAt,
        snapshot.sourceLabel,
        snapshot.sourceUrl,
        snapshot.sourceType ?? 'community',
      );
    }

    return this.cityBudgetSnapshotService.findByCityId(metrics.id);
  }

  private resolveSeasonalitySnapshot(
    metrics: CityMetricsModel,
  ): CitySeasonalitySnapshotEntity | null {
    const snapshot = metrics.seasonalitySnapshot;
    if (snapshot) {
      return new CitySeasonalitySnapshotEntity(
        snapshot.peakMonths,
        snapshot.lowMonths,
        snapshot.severity,
        snapshot.visitorsLabelPt,
        snapshot.visitorsLabelEs,
        snapshot.visitorsLabelEn,
        snapshot.rentNotesPt,
        snapshot.rentNotesEs,
        snapshot.rentNotesEn,
        snapshot.jobNotesPt,
        snapshot.jobNotesEs,
        snapshot.jobNotesEn,
        snapshot.populationMultiplierNote ?? null,
        snapshot.updatedAt,
        snapshot.sourceLabel,
        snapshot.sourceUrl ?? null,
        snapshot.sourceType ?? 'curated',
      );
    }

    return this.citySeasonalitySnapshotService.findByCityId(metrics.id);
  }

  private buildSources({
    stateCode,
    officialName,
    officialMetrics,
  }: {
    stateCode: string;
    officialName: string;
    officialMetrics: ReturnType<CityOfficialMetricsService['findByCity']>;
  }): CitySourcesEntity {
    const ibgeCityUrl = this.buildIbgeCityUrl({
      stateCode,
      officialName,
    });

    return new CitySourcesEntity(
      new CitySourceEntity(
        'territorial_identity',
        'Identidade territorial',
        'IBGE Localidades',
        'Nome oficial, UF, codigo IBGE e regiao municipal.',
        true,
        'https://servicodados.ibge.gov.br/api/docs/localidades',
      ),
      new CitySourceEntity(
        'population',
        'Populacao',
        'IBGE Cidades e Estados',
        'Panorama municipal utilizado como referencia oficial para populacao.',
        true,
        ibgeCityUrl,
      ),
      new CitySourceEntity(
        'human_development',
        'Desenvolvimento humano',
        officialMetrics?.development?.sourceLabel ??
          'Atlas do Desenvolvimento Humano no Brasil (PNUD, Ipea e FJP)',
        officialMetrics?.development != null
          ? 'Indicador oficial ingerido para desenvolvimento humano municipal.'
          : 'IDHM municipal oficial com referencia no Censo 2010.',
        true,
        officialMetrics?.development?.sourceUrl ??
          'https://www.undp.org/pt/brazil/idhm-municipios-2010',
        officialMetrics?.development?.sourceType ?? 'official',
      ),
      officialMetrics?.employment == null
        ? null
        : new CitySourceEntity(
            'employment',
            'Emprego formal',
            officialMetrics.employment.sourceLabel,
            'Indicadores oficiais ingeridos para desemprego, dinamica laboral e sinais de mercado.',
            officialMetrics.employment.sourceType === 'official',
            officialMetrics.employment.sourceUrl ?? null,
            officialMetrics.employment.sourceType ?? 'official',
          ),
      officialMetrics?.safety == null
        ? null
        : new CitySourceEntity(
            'safety',
            'Violencia letal registrada',
            officialMetrics.safety.sourceLabel,
            `Media anual de ${officialMetrics.safety.homicideRatePer100k.toFixed(1)} homicidios registrados por 100 mil habitantes entre ${officialMetrics.safety.referenceStartYear} e ${officialMetrics.safety.referenceEndYear}. O score de 0 a 100 e um sinal comparativo derivado, nao uma classificacao oficial e nao representa diferencas entre bairros nem crimes patrimoniais.`,
            false,
            officialMetrics.safety.sourceUrl ?? null,
            'derived',
            officialMetrics.safety.homicideRatePer100k,
            'homicides_per_100k',
            `${officialMetrics.safety.referenceStartYear}-${officialMetrics.safety.referenceEndYear}`,
            officialMetrics.safety.updatedAt,
          ),
      new CitySourceEntity(
        'curated_metrics',
        'Metricas interpretativas do produto',
        'Metodologia comparativa interna (nao oficial)',
        'Indicadores internos e heuristicas do produto. Servem para leitura comparativa, mas nao substituem fontes oficiais por metrica individual.',
        false,
        null,
        'curated',
      ),
      new CitySourceEntity(
        'ranking',
        'Metodologia de score',
        'Metodologia comparativa interna v1 (nao oficial)',
        'Scores derivados da metodologia do produto sobre dados publicos e sinais curados. Nao representam um indicador oficial unico.',
        false,
        null,
        'derived',
      ),
    );
  }

  private buildIbgeCityUrl({
    stateCode,
    officialName,
  }: {
    stateCode: string;
    officialName: string;
  }): string {
    if (!officialName || !stateCode) {
      return 'https://cidades.ibge.gov.br/';
    }

    const slug = officialName
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');

    return `https://cidades.ibge.gov.br/brasil/${stateCode.toLowerCase()}/${slug}/panorama`;
  }

  private inferStateCode(cityId: string): string {
    const match = cityId.match(/-([a-z]{2})$/i);
    return match?.[1]?.toUpperCase() ?? '';
  }

  private stateNameFromCode(stateCode: string): string {
    const states: Record<string, string> = {
      AC: 'Acre',
      AL: 'Alagoas',
      AP: 'Amapa',
      AM: 'Amazonas',
      BA: 'Bahia',
      CE: 'Ceara',
      DF: 'Distrito Federal',
      ES: 'Espirito Santo',
      GO: 'Goias',
      MA: 'Maranhao',
      MT: 'Mato Grosso',
      MS: 'Mato Grosso do Sul',
      MG: 'Minas Gerais',
      PA: 'Para',
      PB: 'Paraiba',
      PR: 'Parana',
      PE: 'Pernambuco',
      PI: 'Piaui',
      RJ: 'Rio de Janeiro',
      RN: 'Rio Grande do Norte',
      RS: 'Rio Grande do Sul',
      RO: 'Rondonia',
      RR: 'Roraima',
      SC: 'Santa Catarina',
      SP: 'Sao Paulo',
      SE: 'Sergipe',
      TO: 'Tocantins',
    };

    return states[stateCode] ?? stateCode;
  }
}
