"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CitiesModule = void 0;
const common_1 = require("@nestjs/common");
const ibge_city_normalizer_service_1 = require("../../integrations/ibge/ibge-city-normalizer.service");
const ibge_http_client_1 = require("../../integrations/ibge/ibge-http.client");
const ibge_localities_service_1 = require("../../integrations/ibge/ibge-localities.service");
const cities_catalog_service_1 = require("./application/services/cities-catalog.service");
const city_merge_service_1 = require("./application/services/city-merge.service");
const city_ranking_service_1 = require("./application/services/city-ranking.service");
const local_city_metrics_repository_1 = require("./data/repositories/local-city-metrics.repository");
const city_metrics_repository_1 = require("./domain/repositories/city-metrics.repository");
const cities_controller_1 = require("./presentation/cities.controller");
let CitiesModule = class CitiesModule {
};
exports.CitiesModule = CitiesModule;
exports.CitiesModule = CitiesModule = __decorate([
    (0, common_1.Module)({
        controllers: [cities_controller_1.CitiesController],
        providers: [
            ibge_http_client_1.IbgeHttpClient,
            ibge_city_normalizer_service_1.IbgeCityNormalizerService,
            ibge_localities_service_1.IbgeLocalitiesService,
            city_ranking_service_1.CityRankingService,
            city_merge_service_1.CityMergeService,
            cities_catalog_service_1.CitiesCatalogService,
            local_city_metrics_repository_1.LocalCityMetricsRepository,
            {
                provide: city_metrics_repository_1.CityMetricsRepository,
                useExisting: local_city_metrics_repository_1.LocalCityMetricsRepository,
            },
        ],
    })
], CitiesModule);
//# sourceMappingURL=cities.module.js.map