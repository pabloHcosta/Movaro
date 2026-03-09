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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.CitiesController = void 0;
const common_1 = require("@nestjs/common");
const app_error_factory_1 = require("../../../common/errors/app-error.factory");
const cities_catalog_service_1 = require("../application/services/cities-catalog.service");
const get_cities_query_dto_1 = require("./dto/get-cities-query.dto");
let CitiesController = class CitiesController {
    citiesCatalogService;
    constructor(citiesCatalogService) {
        this.citiesCatalogService = citiesCatalogService;
    }
    getHighlights() {
        return this.citiesCatalogService.getHighlights();
    }
    search(query) {
        if (!query || query.trim().length == 0) {
            throw app_error_factory_1.AppErrorFactory.validationError('q is required.', 'Informe um termo para buscar cidades.');
        }
        const normalizedQuery = query.trim().replace(/\s+/g, ' ');
        if (normalizedQuery.length > 80) {
            throw new common_1.BadRequestException('q must be at most 80 characters long.');
        }
        return this.citiesCatalogService.search(normalizedQuery);
    }
    getMethodology() {
        return this.citiesCatalogService.getMethodology();
    }
    getCities(query) {
        return this.citiesCatalogService.getCities(query);
    }
    getCityById(id) {
        const normalizedId = id.trim();
        if (normalizedId.length == 0 ||
            normalizedId.length > 120 ||
            !/^[a-z0-9-]+$/.test(normalizedId)) {
            throw new common_1.BadRequestException('Invalid city id.');
        }
        return this.citiesCatalogService.getCityById(normalizedId);
    }
};
exports.CitiesController = CitiesController;
__decorate([
    (0, common_1.Get)('highlights'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], CitiesController.prototype, "getHighlights", null);
__decorate([
    (0, common_1.Get)('search'),
    __param(0, (0, common_1.Query)('q')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", void 0)
], CitiesController.prototype, "search", null);
__decorate([
    (0, common_1.Get)('metadata/methodology'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], CitiesController.prototype, "getMethodology", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [get_cities_query_dto_1.GetCitiesQueryDto]),
    __metadata("design:returntype", void 0)
], CitiesController.prototype, "getCities", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], CitiesController.prototype, "getCityById", null);
exports.CitiesController = CitiesController = __decorate([
    (0, common_1.Controller)({
        path: 'cities',
        version: '1',
    }),
    __metadata("design:paramtypes", [cities_catalog_service_1.CitiesCatalogService])
], CitiesController);
//# sourceMappingURL=cities.controller.js.map