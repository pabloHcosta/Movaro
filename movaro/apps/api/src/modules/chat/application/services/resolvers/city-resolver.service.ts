import { Injectable, Logger } from '@nestjs/common';

import { CitiesCatalogService } from '../../../../cities/application/services/cities-catalog.service';
import { CityCardEntity } from '../../../../cities/domain/entities/city-card.entity';

export interface CityResolverResult {
  found: boolean;
  confidence: number;
  city?: CityCardEntity;
  summary?: string;
}

@Injectable()
export class CityResolverService {
  private readonly logger = new Logger(CityResolverService.name);

  constructor(private readonly citiesCatalogService: CitiesCatalogService) {}

  async resolve(
    cityId: string | undefined,
    locale: string = 'pt',
  ): Promise<CityResolverResult> {
    if (!cityId) {
      return { found: false, confidence: 0 };
    }

    const resolvedCityId =
      this.citiesCatalogService.resolveCityId(cityId) ?? cityId;

    try {
      const city = await this.citiesCatalogService.getCityById(resolvedCityId);
      return {
        found: true,
        confidence: 0.92,
        city,
        summary: this.buildSummary(city, locale),
      };
    } catch {
      // City not found — try a broader search
      try {
        const results = await this.citiesCatalogService.search(resolvedCityId);
        if (results.length > 0) {
          const city = results[0];
          return {
            found: true,
            confidence: 0.75,
            city,
            summary: this.buildSummary(city, locale),
          };
        }
      } catch {
        this.logger.warn(`City resolver: search failed for "${cityId}"`);
      }
      return { found: false, confidence: 0 };
    }
  }

  private buildSummary(city: CityCardEntity, locale: string): string {
    const scores = city.movaroScores;
    const costLabel = this.costLabel(city.costOfLivingScore, locale);
    const safetyLabel = this.safetyLabel(city.safetyScore, locale);

    if (locale === 'es') {
      return (
        `${city.name} (${city.stateName}) es una ciudad ${costLabel} con una población de ` +
        `${this.formatPop(city.population)} habitantes. ` +
        `Puntuación general Movaro: ${scores?.overall ?? 'N/D'}/10. ` +
        `Costo de vida: ${costLabel}. Seguridad: ${safetyLabel}. ` +
        `Popularidad entre argentinos: ${this.popularityLabel(city.argentinaPopularityScore, locale)}. ` +
        (city.topIndustries?.length
          ? `Principales industrias: ${city.topIndustries.slice(0, 3).join(', ')}.`
          : '') +
        (city.recommendationReasons?.length
          ? ` Destacados: ${city.recommendationReasons.slice(0, 2).join('; ')}.`
          : '')
      );
    }

    if (locale === 'en') {
      return (
        `${city.name} (${city.stateName}) is a ${costLabel} city with ` +
        `${this.formatPop(city.population)} inhabitants. ` +
        `Movaro overall score: ${scores?.overall ?? 'N/A'}/10. ` +
        `Cost of living: ${costLabel}. Safety: ${safetyLabel}. ` +
        `Popularity with Argentines: ${this.popularityLabel(city.argentinaPopularityScore, locale)}. ` +
        (city.topIndustries?.length
          ? `Top industries: ${city.topIndustries.slice(0, 3).join(', ')}.`
          : '') +
        (city.recommendationReasons?.length
          ? ` Highlights: ${city.recommendationReasons.slice(0, 2).join('; ')}.`
          : '')
      );
    }

    // pt (default)
    return (
      `${city.name} (${city.stateName}) é uma cidade ${costLabel} com ` +
      `${this.formatPop(city.population)} habitantes. ` +
      `Pontuação geral Movaro: ${scores?.overall ?? 'N/D'}/10. ` +
      `Custo de vida: ${costLabel}. Segurança: ${safetyLabel}. ` +
      `Popularidade entre argentinos: ${this.popularityLabel(city.argentinaPopularityScore, locale)}. ` +
      (city.topIndustries?.length
        ? `Principais indústrias: ${city.topIndustries.slice(0, 3).join(', ')}.`
        : '') +
      (city.recommendationReasons?.length
        ? ` Destaques: ${city.recommendationReasons.slice(0, 2).join('; ')}.`
        : '')
    );
  }

  private formatPop(pop: number | null | undefined): string {
    if (!pop) return '?';
    if (pop >= 1_000_000) return `${(pop / 1_000_000).toFixed(1)}M`;
    if (pop >= 1_000) return `${(pop / 1_000).toFixed(0)}K`;
    return String(pop);
  }

  private costLabel(score: number | null | undefined, locale: string): string {
    if (score == null) return locale === 'pt' ? 'desconhecido' : 'unknown';
    if (score >= 7) return locale === 'pt' ? 'acessível' : locale === 'es' ? 'asequible' : 'affordable';
    if (score >= 4) return locale === 'pt' ? 'moderado' : 'moderado';
    return locale === 'pt' ? 'caro' : locale === 'es' ? 'caro' : 'expensive';
  }

  private safetyLabel(score: number | null | undefined, locale: string): string {
    if (score == null) return locale === 'pt' ? 'desconhecida' : 'unknown';
    if (score >= 7) return locale === 'pt' ? 'boa' : locale === 'es' ? 'buena' : 'good';
    if (score >= 4) return locale === 'pt' ? 'moderada' : 'moderada';
    return locale === 'pt' ? 'baixa' : locale === 'es' ? 'baja' : 'low';
  }

  private popularityLabel(score: number | null | undefined, locale: string): string {
    if (score == null) return locale === 'pt' ? 'desconhecida' : 'unknown';
    if (score >= 7) return locale === 'pt' ? 'alta' : 'alta';
    if (score >= 4) return locale === 'pt' ? 'média' : locale === 'es' ? 'media' : 'medium';
    return locale === 'pt' ? 'baixa' : locale === 'es' ? 'baja' : 'low';
  }
}
