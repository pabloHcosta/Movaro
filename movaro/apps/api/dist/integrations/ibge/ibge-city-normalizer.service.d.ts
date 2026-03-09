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
export declare class IbgeCityNormalizerService {
    normalize(input: IbgeMunicipalityResponse): IbgeCityNormalized;
}
export {};
