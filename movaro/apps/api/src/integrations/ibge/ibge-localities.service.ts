import { Injectable } from '@nestjs/common';

import { LocalCityMetricsRepository } from '../../modules/cities/data/repositories/local-city-metrics.repository';
import { IbgeHttpClient } from './ibge-http.client';
import {
  IbgeCityNormalized,
  IbgeCityNormalizerService,
} from './ibge-city-normalizer.service';

@Injectable()
export class IbgeLocalitiesService {
  constructor(
    private readonly ibgeHttpClient: IbgeHttpClient,
    private readonly ibgeCityNormalizerService: IbgeCityNormalizerService,
    private readonly localCityMetricsRepository: LocalCityMetricsRepository,
  ) {}

  private readonly municipalityCache = new Map<
    number,
    Promise<IbgeCityNormalized>
  >();

  getMunicipalityByIbgeCode(ibgeCode: number): Promise<IbgeCityNormalized> {
    if (!this.municipalityCache.has(ibgeCode)) {
      this.municipalityCache.set(
        ibgeCode,
        this.ibgeHttpClient
          .get(`/localidades/municipios/${ibgeCode}`)
          .then((response) =>
            this.ibgeCityNormalizerService.normalize(
              response as Parameters<IbgeCityNormalizerService['normalize']>[0],
            ),
          )
          .catch((error) => {
            this.municipalityCache.delete(ibgeCode);
            const fallback = this.buildFallbackFromLocalMetrics(ibgeCode);
            if (fallback != null) {
              return fallback;
            }
            throw error;
          }),
      );
    }

    return this.municipalityCache.get(ibgeCode)!;
  }

  private buildFallbackFromLocalMetrics(
    ibgeCode: number,
  ): IbgeCityNormalized | null {
    const metrics = this.localCityMetricsRepository
      .getAll()
      .find((item) => item.ibgeCode === ibgeCode);

    if (metrics == null) {
      return null;
    }

    const stateCode = this.inferStateCode(metrics.id);

    return {
      ibgeCode,
      officialName: metrics.displayName?.trim() || metrics.name.trim(),
      stateCode,
      stateName: this.stateNameFromCode(stateCode),
      regionName: null,
    };
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
