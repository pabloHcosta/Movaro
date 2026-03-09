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
exports.CityMergeService = void 0;
const common_1 = require("@nestjs/common");
const ibge_localities_service_1 = require("../../../../integrations/ibge/ibge-localities.service");
const city_card_entity_1 = require("../../domain/entities/city-card.entity");
const city_source_entity_1 = require("../../domain/entities/city-source.entity");
const city_sources_entity_1 = require("../../domain/entities/city-sources.entity");
const city_ranking_service_1 = require("./city-ranking.service");
let CityMergeService = class CityMergeService {
    ibgeLocalitiesService;
    cityRankingService;
    constructor(ibgeLocalitiesService, cityRankingService) {
        this.ibgeLocalitiesService = ibgeLocalitiesService;
        this.cityRankingService = cityRankingService;
    }
    async merge(metrics) {
        const ibgeData = await this.ibgeLocalitiesService.getMunicipalityByIbgeCode(metrics.ibgeCode);
        const scores = this.cityRankingService.calculateScores(metrics);
        const recommendationReasons = this.cityRankingService.buildRecommendationReasons(metrics, scores);
        const officialName = ibgeData.officialName?.trim() || metrics.displayName || metrics.name;
        const stateCode = ibgeData.stateCode?.trim() || this.inferStateCode(metrics.id);
        const stateName = ibgeData.stateName?.trim() || this.stateNameFromCode(stateCode);
        const sources = this.buildSources({
            stateCode,
            officialName,
        });
        return new city_card_entity_1.CityCardEntity(metrics.id, metrics.displayName ?? officialName, stateCode, stateName, metrics.countryCode, metrics.ibgeCode, metrics.latitude, metrics.longitude, metrics.population, metrics.idhmScore, metrics.idhmReferenceYear, metrics.costOfLivingScore, metrics.rentScore, metrics.safetyScore, metrics.argentinaPopularityScore, metrics.spanishSupportScore, metrics.jobMarketScore, metrics.unemploymentRate, metrics.economicActivityScore, metrics.topIndustries, scores, recommendationReasons, sources, metrics.updatedAt, ibgeData.regionName);
    }
    buildSources({ stateCode, officialName, }) {
        const ibgeCityUrl = this.buildIbgeCityUrl({
            stateCode,
            officialName,
        });
        return new city_sources_entity_1.CitySourcesEntity(new city_source_entity_1.CitySourceEntity('territorial_identity', 'Identidade territorial', 'IBGE Localidades', 'Nome oficial, UF, codigo IBGE e regiao municipal.', true, 'https://servicodados.ibge.gov.br/api/docs/localidades'), new city_source_entity_1.CitySourceEntity('population', 'Populacao', 'IBGE Cidades e Estados', 'Panorama municipal utilizado como referencia oficial para populacao.', true, ibgeCityUrl), new city_source_entity_1.CitySourceEntity('human_development', 'Desenvolvimento humano', 'Atlas do Desenvolvimento Humano no Brasil (PNUD, Ipea e FJP)', 'IDHM municipal oficial com referencia no Censo 2010.', true, 'https://www.undp.org/pt/brazil/idhm-municipios-2010'), new city_source_entity_1.CitySourceEntity('curated_metrics', 'Metricas curadas do produto', 'Movaro Dataset Curado v1', 'Custo, aluguel, seguranca, popularidade entre argentinos, adaptacao com espanhol, mercado de trabalho, desemprego e setores fortes.', false, null), new city_source_entity_1.CitySourceEntity('ranking', 'Metodologia de score', 'Movaro Ranking Methodology v1', 'Scores derivados da metodologia do produto sobre dados publicos e dataset curado.', false, null));
    }
    buildIbgeCityUrl({ stateCode, officialName, }) {
        if (!officialName || !stateCode) {
            return 'https://cidades.ibge.gov.br/';
        }
        const slug = officialName
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .toLowerCase()
            .replace(/[^a-z0-9]+/g, '-')
            .replace(/^-+|-+$/g, '');
        return `https://cidades.ibge.gov.br/brasil/${stateCode.toLowerCase()}/${slug}/panorama`;
    }
    inferStateCode(cityId) {
        const match = cityId.match(/-([a-z]{2})$/i);
        return match?.[1]?.toUpperCase() ?? '';
    }
    stateNameFromCode(stateCode) {
        const states = {
            AC: 'Acre',
            AL: 'Alagoas',
            AP: 'Amapa',
            AM: 'Amazonas',
            BA: 'Bahia',
            CE: 'Ceara',
            DF: 'Distrito Federal',
            ES: 'Espirito Santo',
            GO: 'Goias',
            MA: 'Maranhao',
            MT: 'Mato Grosso',
            MS: 'Mato Grosso do Sul',
            MG: 'Minas Gerais',
            PA: 'Para',
            PB: 'Paraiba',
            PR: 'Parana',
            PE: 'Pernambuco',
            PI: 'Piaui',
            RJ: 'Rio de Janeiro',
            RN: 'Rio Grande do Norte',
            RS: 'Rio Grande do Sul',
            RO: 'Rondonia',
            RR: 'Roraima',
            SC: 'Santa Catarina',
            SP: 'Sao Paulo',
            SE: 'Sergipe',
            TO: 'Tocantins',
        };
        return states[stateCode] ?? stateCode;
    }
};
exports.CityMergeService = CityMergeService;
exports.CityMergeService = CityMergeService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [ibge_localities_service_1.IbgeLocalitiesService,
        city_ranking_service_1.CityRankingService])
], CityMergeService);
//# sourceMappingURL=city-merge.service.js.map