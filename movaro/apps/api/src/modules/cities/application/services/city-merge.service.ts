import { Injectable } from '@nestjs/common';

import { GooglePlacesCityOpinionService } from '../../../../integrations/google/google-places-city-opinion.service';
import { IbgeLocalitiesService } from '../../../../integrations/ibge/ibge-localities.service';
import { CityMetricsModel } from '../../data/models/city-metrics.model';
import { CityCardEntity } from '../../domain/entities/city-card.entity';
import { CitySourceEntity } from '../../domain/entities/city-source.entity';
import { CitySourcesEntity } from '../../domain/entities/city-sources.entity';
import { CityRankingService } from './city-ranking.service';

@Injectable()
export class CityMergeService {
  constructor(
    private readonly ibgeLocalitiesService: IbgeLocalitiesService,
    private readonly cityRankingService: CityRankingService,
    private readonly googlePlacesCityOpinionService: GooglePlacesCityOpinionService,
  ) {}

  async merge(metrics: CityMetricsModel): Promise<CityCardEntity> {
    const ibgeData = await this.ibgeLocalitiesService.getMunicipalityByIbgeCode(
      metrics.ibgeCode,
    );
    const scores = this.cityRankingService.calculateScores(metrics);
    const recommendationReasons =
      this.cityRankingService.buildRecommendationReasons(metrics, scores);
    const officialName =
      ibgeData.officialName?.trim() || metrics.displayName || metrics.name;
    const stateCode =
      ibgeData.stateCode?.trim() || this.inferStateCode(metrics.id);
    const stateName =
      ibgeData.stateName?.trim() || this.stateNameFromCode(stateCode);
    const sources = this.buildSources({
      stateCode,
      officialName,
    });
    const publicOpinion =
      await this.googlePlacesCityOpinionService.getCityOpinion(
        metrics,
        stateName,
      );
    const sourcesWithOpinion = publicOpinion
      ? new CitySourcesEntity(
          sources.territorialIdentity,
          sources.population,
          sources.humanDevelopment,
          sources.curatedMetrics,
          sources.ranking,
          new CitySourceEntity(
            'public_reviews',
            'Percepcao publica',
            'Google Maps',
            'Leitura automatica de temas recorrentes em avaliacoes publicas da localidade. Nao representa a opiniao de toda a cidade.',
            false,
            publicOpinion.placeUrl,
          ),
        )
      : sources;

    return new CityCardEntity(
      metrics.id,
      metrics.displayName ?? officialName,
      stateCode,
      stateName,
      metrics.countryCode,
      metrics.ibgeCode,
      metrics.latitude,
      metrics.longitude,
      metrics.population,
      metrics.idhmScore,
      metrics.idhmReferenceYear,
      metrics.costOfLivingScore,
      metrics.rentScore,
      metrics.safetyScore,
      metrics.argentinaPopularityScore,
      metrics.spanishSupportScore,
      metrics.jobMarketScore,
      metrics.unemploymentRate,
      metrics.economicActivityScore,
      metrics.topIndustries,
      scores,
      recommendationReasons,
      sourcesWithOpinion,
      metrics.updatedAt,
      ibgeData.regionName,
      publicOpinion,
    );
  }

  private buildSources({
    stateCode,
    officialName,
  }: {
    stateCode: string;
    officialName: string;
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
        'Atlas do Desenvolvimento Humano no Brasil (PNUD, Ipea e FJP)',
        'IDHM municipal oficial com referencia no Censo 2010.',
        true,
        'https://www.undp.org/pt/brazil/idhm-municipios-2010',
      ),
      new CitySourceEntity(
        'curated_metrics',
        'Metricas curadas do produto',
        'Movaro Dataset Curado v1',
        'Custo, aluguel, seguranca, popularidade entre argentinos, adaptacao com espanhol, mercado de trabalho, desemprego e setores fortes.',
        false,
        null,
      ),
      new CitySourceEntity(
        'ranking',
        'Metodologia de score',
        'Movaro Ranking Methodology v1',
        'Scores derivados da metodologia do produto sobre dados publicos e dataset curado.',
        false,
        null,
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
