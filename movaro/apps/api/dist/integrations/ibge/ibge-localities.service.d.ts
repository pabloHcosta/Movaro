import { IbgeHttpClient } from './ibge-http.client';
import { IbgeCityNormalized, IbgeCityNormalizerService } from './ibge-city-normalizer.service';
export declare class IbgeLocalitiesService {
    private readonly ibgeHttpClient;
    private readonly ibgeCityNormalizerService;
    constructor(ibgeHttpClient: IbgeHttpClient, ibgeCityNormalizerService: IbgeCityNormalizerService);
    private readonly municipalityCache;
    getMunicipalityByIbgeCode(ibgeCode: number): Promise<IbgeCityNormalized>;
}
