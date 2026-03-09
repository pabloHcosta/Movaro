"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.LocalCityMetricsRepository = void 0;
const node_fs_1 = require("node:fs");
const node_path_1 = require("node:path");
const common_1 = require("@nestjs/common");
let LocalCityMetricsRepository = class LocalCityMetricsRepository {
    cache = null;
    getAll() {
        if (this.cache != null) {
            return this.cache;
        }
        const filePath = (0, node_path_1.resolve)(process.cwd(), '../../packages/contracts/seed/movaro_city_metrics.json');
        const fileContent = (0, node_fs_1.readFileSync)(filePath, 'utf-8');
        this.cache = JSON.parse(fileContent);
        return this.cache;
    }
};
exports.LocalCityMetricsRepository = LocalCityMetricsRepository;
exports.LocalCityMetricsRepository = LocalCityMetricsRepository = __decorate([
    (0, common_1.Injectable)()
], LocalCityMetricsRepository);
//# sourceMappingURL=local-city-metrics.repository.js.map