export declare class CitySourceEntity {
    readonly id: string;
    readonly title: string;
    readonly provider: string;
    readonly description: string;
    readonly isOfficial: boolean;
    readonly url: string | null;
    constructor(id: string, title: string, provider: string, description: string, isOfficial: boolean, url: string | null);
}
