import { Injectable } from '@nestjs/common';

import { AppErrorFactory } from '../../../../common/errors/app-error.factory';
import { GetCitiesQueryDto } from '../../presentation/dto/get-cities-query.dto';
import { CityCardEntity } from '../../domain/entities/city-card.entity';
import { CurrentCityWeatherEntity } from '../../domain/entities/current-city-weather.entity';
import { CityMetricsRepository } from '../../domain/repositories/city-metrics.repository';
import { CityMergeService } from './city-merge.service';
import { CityRankingService } from './city-ranking.service';
import { OpenMeteoWeatherService } from '../../../../integrations/weather/open-meteo-weather.service';

@Injectable()
export class CitiesCatalogService {
  constructor(
    private readonly cityMetricsRepository: CityMetricsRepository,
    private readonly cityMergeService: CityMergeService,
    private readonly cityRankingService: CityRankingService,
    private readonly openMeteoWeatherService: OpenMeteoWeatherService,
  ) {}

  async getCities(query: GetCitiesQueryDto): Promise<CityCardEntity[]> {
    const merged = await this.buildCatalog();

    return merged
      .filter((city) =>
        query.countryCode ? city.countryCode == query.countryCode : true,
      )
      .filter((city) =>
        query.search
          ? city.name.toLowerCase().includes(query.search.toLowerCase())
          : true,
      )
      .sort(
        (left, right) =>
          this.getSortValue(right, query.category) -
          this.getSortValue(left, query.category),
      );
  }

  async getHighlights() {
    const catalog = await this.buildCatalog();

    return {
      mostChosenByArgentinians: this.sortBy(catalog, 'popular_argentina').slice(
        0,
        3,
      ),
      easiestForSpanishSpeakers: this.sortBy(catalog, 'language').slice(0, 3),
      mostEconomical: this.sortBy(catalog, 'economical').slice(0, 3),
      bestForWork: this.sortBy(catalog, 'work').slice(0, 3),
    };
  }

  async getCityById(id: string): Promise<CityCardEntity> {
    const catalog = await this.buildCatalog();
    const city = catalog.find((item) => item.id == id);

    if (!city) {
      throw AppErrorFactory.cityNotFound(id);
    }

    return city;
  }

  resolveCityId(rawId: string): string | null {
    const normalized = rawId.trim().toLowerCase();
    if (!normalized) {
      return null;
    }

    const metrics = this.cityMetricsRepository.getAll();
    const exact = metrics.find((item) => item.id === normalized);
    if (exact) {
      return exact.id;
    }

    const aliasMatch = metrics.find((item) => {
      const baseId = item.id.replace(/-[a-z]{2}$/i, '');
      const nameSlug = item.name
        .normalize('NFD')
        .replace(/[\u0300-\u036f]/g, '')
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, '-')
        .replace(/^-+|-+$/g, '');

      return baseId === normalized || nameSlug === normalized;
    });

    if (aliasMatch) {
      return aliasMatch.id;
    }

    const prefixMatch = metrics.find((item) => item.id.startsWith(`${normalized}-`));
    return prefixMatch?.id ?? null;
  }

  getCityDisplayNameById(rawId: string): string | null {
    const resolvedCityId = this.resolveCityId(rawId);
    if (!resolvedCityId) {
      return null;
    }

    const city = this.cityMetricsRepository
      .getAll()
      .find((item) => item.id === resolvedCityId);

    return city?.displayName ?? city?.name ?? null;
  }

  async getCityWeatherById(id: string): Promise<CurrentCityWeatherEntity> {
    const city = await this.getCityById(id);
    const currentWeather = await this.openMeteoWeatherService.getCurrentWeather(
      city.latitude,
      city.longitude,
    );

    return new CurrentCityWeatherEntity(
      currentWeather.temperatureCelsius,
      currentWeather.weatherCode,
      currentWeather.isDay,
      currentWeather.windSpeedKmh,
      currentWeather.fetchedAt,
    );
  }

  async search(query: string): Promise<CityCardEntity[]> {
    return this.getCities({
      search: query,
      countryCode: 'BR',
    });
  }

  getMethodology() {
    return this.cityRankingService.getMethodology();
  }

  private async buildCatalog(): Promise<CityCardEntity[]> {
    const metrics = this.cityMetricsRepository.getAll();
    return Promise.all(
      metrics.map((item) => this.cityMergeService.merge(item)),
    );
  }

  private sortBy(
    catalog: CityCardEntity[],
    category?: GetCitiesQueryDto['category'],
  ) {
    return [...catalog].sort(
      (left, right) =>
        this.getSortValue(right, category) - this.getSortValue(left, category),
    );
  }

  private getSortValue(
    city: CityCardEntity,
    category?: GetCitiesQueryDto['category'],
  ): number {
    switch (category) {
      case 'economical':
        return city.movaroScores.economical;
      case 'popular_argentina':
        return city.movaroScores.popularForArgentinians;
      case 'language':
        return city.movaroScores.languageAdaptation;
      case 'work':
        return city.movaroScores.workOpportunity;
      default:
        return city.movaroScores.overall;
    }
  }
}
