"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CitySourceEntity = void 0;
class CitySourceEntity {
    id;
    title;
    provider;
    description;
    isOfficial;
    url;
    constructor(id, title, provider, description, isOfficial, url) {
        this.id = id;
        this.title = title;
        this.provider = provider;
        this.description = description;
        this.isOfficial = isOfficial;
        this.url = url;
    }
}
exports.CitySourceEntity = CitySourceEntity;
//# sourceMappingURL=city-source.entity.js.map