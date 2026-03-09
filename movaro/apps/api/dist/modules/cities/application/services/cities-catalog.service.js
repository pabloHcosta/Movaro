"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CitiesCatalogService = void 0;
const common_1 = require("@nestjs/common");
const app_error_factory_1 = require("../../../../common/errors/app-error.factory");
const city_metrics_repository_1 = require("../../domain/repositories/city-metrics.repository");
const city_merge_service_1 = require("./city-merge.service");
const city_ranking_service_1 = require("./city-ranking.service");
let CitiesCatalogService = class CitiesCatalogService {
    cityMetricsRepository;
    cityMergeService;
    cityRankingService;
    constructor(cityMetricsRepository, cityMergeService, cityRankingService) {
        this.cityMetricsRepository = cityMetricsRepository;
        this.cityMergeService = cityMergeService;
        this.cityRankingService = cityRankingService;
    }
    async getCities(query) {
        const merged = await this.buildCatalog();
        return merged
            .filter((city) => query.countryCode ? city.countryCode == query.countryCode : true)
            .filter((city) => query.search
            ? city.name.toLowerCase().includes(query.search.toLowerCase())
            : true)
            .sort((left, right) => this.getSortValue(right, query.category) -
            this.getSortValue(left, query.category));
    }
    async getHighlights() {
        const catalog = await this.buildCatalog();
        return {
            mostChosenByArgentinians: this.sortBy(catalog, 'popular_argentina').slice(0, 3),
            easiestForSpanishSpeakers: this.sortBy(catalog, 'language').slice(0, 3),
            mostEconomical: this.sortBy(catalog, 'economical').slice(0, 3),
            bestForWork: this.sortBy(catalog, 'work').slice(0, 3),
        };
    }
    async getCityById(id) {
        const catalog = await this.buildCatalog();
        const city = catalog.find((item) => item.id == id);
        if (!city) {
            throw app_error_factory_1.AppErrorFactory.cityNotFound(id);
        }
        return city;
    }
    async search(query) {
        return this.getCities({
            search: query,
            countryCode: 'BR',
        });
    }
    getMethodology() {
        return this.cityRankingService.getMethodology();
    }
    async buildCatalog() {
        const metrics = this.cityMetricsRepository.getAll();
        return Promise.all(metrics.map((item) => this.cityMergeService.merge(item)));
    }
    sortBy(catalog, category) {
        return [...catalog].sort((left, right) => this.getSortValue(right, category) - this.getSortValue(left, category));
    }
    getSortValue(city, category) {
        switch (category) {
            case 'economical':
                return city.movaroScores.economical;
            case 'popular_argentina':
                return city.movaroScores.popularForArgentinians;
            case 'language':
                return city.movaroScores.languageAdaptation;
            case 'work':
                return city.movaroScores.workOpportunity;
            default:
                return city.movaroScores.overall;
        }
    }
};
exports.CitiesCatalogService = CitiesCatalogService;
exports.CitiesCatalogService = CitiesCatalogService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [city_metrics_repository_1.CityMetricsRepository,
        city_merge_service_1.CityMergeService,
        city_ranking_service_1.CityRankingService])
], CitiesCatalogService);
//# sourceMappingURL=cities-catalog.service.js.map