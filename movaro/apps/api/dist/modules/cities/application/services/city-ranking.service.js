"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CityRankingService = void 0;
const common_1 = require("@nestjs/common");
const movaro_scores_entity_1 = require("../../domain/entities/movaro-scores.entity");
let CityRankingService = class CityRankingService {
    calculateScores(city) {
        const economical = this.round((city.costOfLivingScore + city.rentScore) / 2);
        const popularForArgentinians = this.round(city.argentinaPopularityScore);
        const languageAdaptation = this.round(city.spanishSupportScore * 0.7 + city.argentinaPopularityScore * 0.3);
        const workOpportunity = this.round(city.jobMarketScore * 0.45 +
            city.economicActivityScore * 0.35 +
            this.normalizeUnemployment(city.unemploymentRate) * 0.2);
        const overall = this.round(economical * 0.25 +
            city.safetyScore * 0.2 +
            languageAdaptation * 0.2 +
            workOpportunity * 0.2 +
            popularForArgentinians * 0.15);
        return new movaro_scores_entity_1.MovaroScoresEntity(economical, popularForArgentinians, languageAdaptation, workOpportunity, overall);
    }
    buildRecommendationReasons(city, scores) {
        const reasons = [];
        if (scores.economical >= 72) {
            reasons.push('Boa opcao para quem prioriza custo');
        }
        if (scores.popularForArgentinians >= 75) {
            reasons.push('Popular entre argentinos');
        }
        if (scores.languageAdaptation >= 80) {
            reasons.push('Melhor adaptacao para quem ainda nao fala portugues');
        }
        if (scores.workOpportunity >= 75) {
            reasons.push('Mercado de trabalho mais forte');
        }
        if (city.costOfLivingScore < 50 && city.jobMarketScore > 80) {
            reasons.push('Custo mais alto, mas melhor infraestrutura');
        }
        if (reasons.length == 0) {
            reasons.push('Opcao equilibrada dentro do catalogo inicial do MVP');
        }
        return reasons;
    }
    getMethodology() {
        return {
            principles: [
                'Scores representam heuristicas do produto, nao verdades absolutas.',
                'Cada categoria responde a uma intencao diferente de migracao.',
                'Os dados combinam fonte oficial publica e dataset curado inicial do MVP.',
                'Adaptacao linguistica usa um proxy curado de presenca argentina, atendimento recorrente em espanhol e contexto turistico ou fronteirico.',
            ],
            formulas: {
                economical: 'media(costOfLivingScore, rentScore)',
                popularForArgentinians: 'argentinaPopularityScore',
                languageAdaptation: '0.70 * spanishSupportScore + 0.30 * argentinaPopularityScore',
                workOpportunity: '0.45 * jobMarketScore + 0.35 * economicActivityScore + 0.20 * scoreInvertidoDeDesemprego',
                overall: '0.25 * economical + 0.20 * safetyScore + 0.20 * languageAdaptation + 0.20 * workOpportunity + 0.15 * popularForArgentinians',
            },
            note: 'Os scores ajudam a ordenar exploracao por intencao. Adaptacao linguistica e um proxy inicial para conforto de quem ainda depende mais de espanhol.',
        };
    }
    normalizeUnemployment(unemploymentRate) {
        return this.round(Math.max(0, 100 - unemploymentRate * 10));
    }
    round(value) {
        return Math.round(value);
    }
};
exports.CityRankingService = CityRankingService;
exports.CityRankingService = CityRankingService = __decorate([
    (0, common_1.Injectable)()
], CityRankingService);
//# sourceMappingURL=city-ranking.service.js.map