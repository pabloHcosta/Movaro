import { Injectable } from '@nestjs/common';

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
            throw error;
          }),
      );
    }

    return this.municipalityCache.get(ibgeCode)!;
  }
}
