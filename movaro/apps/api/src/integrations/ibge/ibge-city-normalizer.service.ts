import { Injectable } from '@nestjs/common';

type IbgeMunicipalityResponse = {
  id: number;
  nome: string;
  microrregiao?: {
    mesorregiao?: {
      UF?: {
        sigla: string;
        nome: string;
        regiao?: {
          nome: string;
        };
      };
    };
  };
  'regiao-imediata'?: {
    'regiao-intermediaria'?: {
      UF?: {
        sigla: string;
        nome: string;
        regiao?: {
          nome: string;
        };
      };
    };
  };
};

export type IbgeCityNormalized = {
  ibgeCode: number;
  officialName: string;
  stateCode: string;
  stateName: string;
  regionName: string | null;
};

@Injectable()
export class IbgeCityNormalizerService {
  normalize(input: IbgeMunicipalityResponse): IbgeCityNormalized {
    const uf =
      input['regiao-imediata']?.['regiao-intermediaria']?.UF ??
      input.microrregiao?.mesorregiao?.UF;

    return {
      ibgeCode: input.id,
      officialName: input.nome,
      stateCode: uf?.sigla ?? '',
      stateName: uf?.nome ?? '',
      regionName: uf?.regiao?.nome ?? null,
    };
  }
}
