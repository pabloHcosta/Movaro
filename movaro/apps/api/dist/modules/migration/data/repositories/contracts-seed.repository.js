"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ContractsSeedRepository = void 0;
const node_fs_1 = require("node:fs");
const node_path_1 = require("node:path");
const common_1 = require("@nestjs/common");
let ContractsSeedRepository = class ContractsSeedRepository {
    getCountryNames() {
        const filePath = (0, node_path_1.resolve)(process.cwd(), '../../packages/contracts/seed/countries.json');
        const fileContent = (0, node_fs_1.readFileSync)(filePath, 'utf-8');
        const countries = JSON.parse(fileContent);
        return countries.map((country) => country.name);
    }
};
exports.ContractsSeedRepository = ContractsSeedRepository;
exports.ContractsSeedRepository = ContractsSeedRepository = __decorate([
    (0, common_1.Injectable)()
], ContractsSeedRepository);
//# sourceMappingURL=contracts-seed.repository.js.map