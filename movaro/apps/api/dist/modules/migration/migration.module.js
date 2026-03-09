"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MigrationModule = void 0;
const common_1 = require("@nestjs/common");
const migration_plan_service_1 = require("./application/services/migration-plan.service");
const contracts_seed_repository_1 = require("./data/repositories/contracts-seed.repository");
const seed_catalog_repository_1 = require("./domain/repositories/seed-catalog.repository");
const migration_controller_1 = require("./presentation/migration.controller");
let MigrationModule = class MigrationModule {
};
exports.MigrationModule = MigrationModule;
exports.MigrationModule = MigrationModule = __decorate([
    (0, common_1.Module)({
        controllers: [migration_controller_1.MigrationController],
        providers: [
            migration_plan_service_1.MigrationPlanService,
            contracts_seed_repository_1.ContractsSeedRepository,
            {
                provide: seed_catalog_repository_1.SeedCatalogRepository,
                useExisting: contracts_seed_repository_1.ContractsSeedRepository,
            },
        ],
    })
], MigrationModule);
//# sourceMappingURL=migration.module.js.map