"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.IbgeCityNormalizerService = void 0;
const common_1 = require("@nestjs/common");
let IbgeCityNormalizerService = class IbgeCityNormalizerService {
    normalize(input) {
        const uf = input['regiao-imediata']?.['regiao-intermediaria']?.UF ??
            input.microrregiao?.mesorregiao?.UF;
        return {
            ibgeCode: input.id,
            officialName: input.nome,
            stateCode: uf?.sigla ?? '',
            stateName: uf?.nome ?? '',
            regionName: uf?.regiao?.nome ?? null,
        };
    }
};
exports.IbgeCityNormalizerService = IbgeCityNormalizerService;
exports.IbgeCityNormalizerService = IbgeCityNormalizerService = __decorate([
    (0, common_1.Injectable)()
], IbgeCityNormalizerService);
//# sourceMappingURL=ibge-city-normalizer.service.js.map