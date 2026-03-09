"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CityCardEntity = void 0;
class CityCardEntity {
    id;
    name;
    stateCode;
    stateName;
    countryCode;
    ibgeCode;
    latitude;
    longitude;
    population;
    idhmScore;
    idhmReferenceYear;
    costOfLivingScore;
    rentScore;
    safetyScore;
    argentinaPopularityScore;
    spanishSupportScore;
    jobMarketScore;
    unemploymentRate;
    economicActivityScore;
    topIndustries;
    movaroScores;
    recommendationReasons;
    sources;
    updatedAt;
    regionName;
    constructor(id, name, stateCode, stateName, countryCode, ibgeCode, latitude, longitude, population, idhmScore, idhmReferenceYear, costOfLivingScore, rentScore, safetyScore, argentinaPopularityScore, spanishSupportScore, jobMarketScore, unemploymentRate, economicActivityScore, topIndustries, movaroScores, recommendationReasons, sources, updatedAt, regionName) {
        this.id = id;
        this.name = name;
        this.stateCode = stateCode;
        this.stateName = stateName;
        this.countryCode = countryCode;
        this.ibgeCode = ibgeCode;
        this.latitude = latitude;
        this.longitude = longitude;
        this.population = population;
        this.idhmScore = idhmScore;
        this.idhmReferenceYear = idhmReferenceYear;
        this.costOfLivingScore = costOfLivingScore;
        this.rentScore = rentScore;
        this.safetyScore = safetyScore;
        this.argentinaPopularityScore = argentinaPopularityScore;
        this.spanishSupportScore = spanishSupportScore;
        this.jobMarketScore = jobMarketScore;
        this.unemploymentRate = unemploymentRate;
        this.economicActivityScore = economicActivityScore;
        this.topIndustries = topIndustries;
        this.movaroScores = movaroScores;
        this.recommendationReasons = recommendationReasons;
        this.sources = sources;
        this.updatedAt = updatedAt;
        this.regionName = regionName;
    }
}
exports.CityCardEntity = CityCardEntity;
//# sourceMappingURL=city-card.entity.js.map