import { CitySourceEntity } from './city-source.entity';
export declare class CitySourcesEntity {
    readonly territorialIdentity: CitySourceEntity;
    readonly population: CitySourceEntity;
    readonly humanDevelopment: CitySourceEntity;
    readonly curatedMetrics: CitySourceEntity;
    readonly ranking: CitySourceEntity;
    constructor(territorialIdentity: CitySourceEntity, population: CitySourceEntity, humanDevelopment: CitySourceEntity, curatedMetrics: CitySourceEntity, ranking: CitySourceEntity);
}
