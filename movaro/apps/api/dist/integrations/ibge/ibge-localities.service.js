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
exports.IbgeLocalitiesService = void 0;
const common_1 = require("@nestjs/common");
const ibge_http_client_1 = require("./ibge-http.client");
const ibge_city_normalizer_service_1 = require("./ibge-city-normalizer.service");
let IbgeLocalitiesService = class IbgeLocalitiesService {
    ibgeHttpClient;
    ibgeCityNormalizerService;
    constructor(ibgeHttpClient, ibgeCityNormalizerService) {
        this.ibgeHttpClient = ibgeHttpClient;
        this.ibgeCityNormalizerService = ibgeCityNormalizerService;
    }
    municipalityCache = new Map();
    getMunicipalityByIbgeCode(ibgeCode) {
        if (!this.municipalityCache.has(ibgeCode)) {
            this.municipalityCache.set(ibgeCode, this.ibgeHttpClient
                .get(`/localidades/municipios/${ibgeCode}`)
                .then((response) => this.ibgeCityNormalizerService.normalize(response)));
        }
        return this.municipalityCache.get(ibgeCode);
    }
};
exports.IbgeLocalitiesService = IbgeLocalitiesService;
exports.IbgeLocalitiesService = IbgeLocalitiesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [ibge_http_client_1.IbgeHttpClient,
        ibge_city_normalizer_service_1.IbgeCityNormalizerService])
], IbgeLocalitiesService);
//# sourceMappingURL=ibge-localities.service.js.map