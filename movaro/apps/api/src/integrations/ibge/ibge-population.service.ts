import { Injectable } from '@nestjs/common';

import { SidraHttpClient } from './sidra-http.client';

type SidraValueRow = {
  V?: string;
  D3C?: string;
  D3N?: string;
};

export type IbgePopulationEstimate = {
  population: number;
  referenceYear: number | null;
};

@Injectable()
export class IbgePopulationService {
  constructor(private readonly sidraHttpClient: SidraHttpClient) {}

  private readonly populationCache = new Map<
    number,
    Promise<IbgePopulationEstimate>
  >();

  getPopulationEstimateByIbgeCode(
    ibgeCode: number,
  ): Promise<IbgePopulationEstimate> {
    if (!this.populationCache.has(ibgeCode)) {
      this.populationCache.set(
        ibgeCode,
        this.sidraHttpClient
          .get<SidraValueRow[]>(
            `/values/t/6579/v/9324/n6/${ibgeCode}/p/last?formato=json`,
          )
          .then((rows) => this.normalize(rows))
          .catch((error) => {
            this.populationCache.delete(ibgeCode);
            throw error;
          }),
      );
    }

    return this.populationCache.get(ibgeCode)!;
  }

  private normalize(rows: SidraValueRow[]): IbgePopulationEstimate {
    const dataRow = rows.find((row) => row.V != null && row.V !== 'Valor');
    const population = Number(dataRow?.V ?? '');
    const referenceYear = Number(dataRow?.D3C ?? dataRow?.D3N ?? '');

    if (!Number.isFinite(population)) {
      throw new Error('SIDRA population response did not contain a numeric value.');
    }

    return {
      population,
      referenceYear: Number.isFinite(referenceYear) ? referenceYear : null,
    };
  }
}
