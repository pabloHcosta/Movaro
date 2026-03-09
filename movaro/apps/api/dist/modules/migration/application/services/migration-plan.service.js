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
exports.MigrationPlanService = void 0;
const common_1 = require("@nestjs/common");
const app_error_factory_1 = require("../../../../common/errors/app-error.factory");
const migration_plan_entity_1 = require("../../domain/entities/migration-plan.entity");
const migration_step_entity_1 = require("../../domain/entities/migration-step.entity");
const seed_catalog_repository_1 = require("../../domain/repositories/seed-catalog.repository");
let MigrationPlanService = class MigrationPlanService {
    seedCatalogRepository;
    constructor(seedCatalogRepository) {
        this.seedCatalogRepository = seedCatalogRepository;
    }
    generatePlan(input) {
        this.validateInput(input);
        if (input.destinationCountry === 'Brasil') {
            return new migration_plan_entity_1.MigrationPlanEntity(input.originCountry, input.destinationCountry, input.goal, input.timeline, [
                new migration_step_entity_1.MigrationStepEntity('Verificar tipo de residencia ou visto', 'Mapear a base migratoria adequada para a motivacao principal da mudanca.', 'documentation', 7),
                new migration_step_entity_1.MigrationStepEntity('Obter CPF', 'Organizar o registro fiscal necessario para servicos e transacoes no Brasil.', 'documentation', 3),
                new migration_step_entity_1.MigrationStepEntity('Abrir conta bancaria', 'Preparar uma conta local para movimentacao financeira inicial.', 'financial', 5),
                new migration_step_entity_1.MigrationStepEntity('Buscar moradia', 'Pesquisar bairros, contratos e custos para uma instalacao segura.', 'housing', 14),
                new migration_step_entity_1.MigrationStepEntity('Regularizar documentacao local', 'Conferir registros adicionais, comprovantes e etapas administrativas locais.', 'settlement', 10),
            ]);
        }
        return new migration_plan_entity_1.MigrationPlanEntity(input.originCountry, input.destinationCountry, input.goal, input.timeline, [
            new migration_step_entity_1.MigrationStepEntity('Mapear destinos possiveis', 'Comparar opcoes de pais com base no objetivo e janela de mudanca.', 'research', 7),
            new migration_step_entity_1.MigrationStepEntity('Definir criterio de decisao', 'Organizar prioridades como custo, documentacao e qualidade de vida.', 'planning', 5),
        ]);
    }
    validateInput(input) {
        if (input.originCountry.trim().length == 0 ||
            input.destinationCountry.trim().length == 0 ||
            input.goal.trim().length == 0 ||
            input.timeline.trim().length == 0) {
            throw app_error_factory_1.AppErrorFactory.validationError('originCountry, destinationCountry, goal and timeline are required.', 'Preencha origem, destino, objetivo e momento da mudanca.');
        }
        const supportedCountries = this.seedCatalogRepository.getCountryNames();
        if (!supportedCountries.includes(input.originCountry)) {
            throw app_error_factory_1.AppErrorFactory.validationError('Unsupported originCountry.', 'O pais de origem ainda nao esta disponivel neste MVP.');
        }
        if (input.destinationCountry != 'Ainda nao sei' &&
            !supportedCountries.includes(input.destinationCountry)) {
            throw app_error_factory_1.AppErrorFactory.validationError('Unsupported destinationCountry.', 'O pais de destino ainda nao esta disponivel neste MVP.');
        }
    }
};
exports.MigrationPlanService = MigrationPlanService;
exports.MigrationPlanService = MigrationPlanService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [seed_catalog_repository_1.SeedCatalogRepository])
], MigrationPlanService);
//# sourceMappingURL=migration-plan.service.js.map