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
exports.CreateMigrationPlanDto = void 0;
const class_validator_1 = require("class-validator");
class CreateMigrationPlanDto {
    originCountry;
    destinationCountry;
    goal;
    timeline;
}
exports.CreateMigrationPlanDto = CreateMigrationPlanDto;
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(100),
    (0, class_validator_1.IsIn)(['Argentina']),
    __metadata("design:type", String)
], CreateMigrationPlanDto.prototype, "originCountry", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(100),
    (0, class_validator_1.IsIn)(['Brasil', 'Ainda nao sei']),
    __metadata("design:type", String)
], CreateMigrationPlanDto.prototype, "destinationCountry", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(100),
    (0, class_validator_1.IsIn)([
        'Trabalhar',
        'Trabalhar remoto',
        'Estudar',
        'Empreender',
        'Aposentar',
        'Qualidade de vida',
    ]),
    __metadata("design:type", String)
], CreateMigrationPlanDto.prototype, "goal", void 0);
__decorate([
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(100),
    (0, class_validator_1.IsIn)([
        'So estou pesquisando',
        'Nos proximos 12 meses',
        'Nos proximos 6 meses',
        'O mais rapido possivel',
    ]),
    __metadata("design:type", String)
], CreateMigrationPlanDto.prototype, "timeline", void 0);
//# sourceMappingURL=create-migration-plan.dto.js.map