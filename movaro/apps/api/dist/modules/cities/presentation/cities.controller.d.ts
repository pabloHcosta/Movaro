import { CitiesCatalogService } from '../application/services/cities-catalog.service';
import { GetCitiesQueryDto } from './dto/get-cities-query.dto';
export declare class CitiesController {
    private readonly citiesCatalogService;
    constructor(citiesCatalogService: CitiesCatalogService);
    getHighlights(): Promise<{
        mostChosenByArgentinians: import("../domain/entities/city-card.entity").CityCardEntity[];
        easiestForSpanishSpeakers: import("../domain/entities/city-card.entity").CityCardEntity[];
        mostEconomical: import("../domain/entities/city-card.entity").CityCardEntity[];
        bestForWork: import("../domain/entities/city-card.entity").CityCardEntity[];
    }>;
    search(query: string | undefined): Promise<import("../domain/entities/city-card.entity").CityCardEntity[]>;
    getMethodology(): {
        principles: string[];
        formulas: {
            economical: string;
            popularForArgentinians: string;
            languageAdaptation: string;
            workOpportunity: string;
            overall: string;
        };
        note: string;
    };
    getCities(query: GetCitiesQueryDto): Promise<import("../domain/entities/city-card.entity").CityCardEntity[]>;
    getCityById(id: string): Promise<import("../domain/entities/city-card.entity").CityCardEntity>;
}
