export declare const cityCategories: readonly ["economical", "popular_argentina", "language", "work"];
export type CityCategory = (typeof cityCategories)[number];
export declare class GetCitiesQueryDto {
    category?: CityCategory;
    search?: string;
    countryCode?: string;
}
