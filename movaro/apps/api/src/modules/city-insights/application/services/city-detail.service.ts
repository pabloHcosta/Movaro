import { Injectable } from '@nestjs/common';

import { CitiesCatalogService } from '../../../cities/application/services/cities-catalog.service';
import { CityCardEntity } from '../../../cities/domain/entities/city-card.entity';
import { CityNeighborhoodSeedService } from './city-neighborhood-seed.service';
import { CityInsightsService } from './city-insights.service';

type DetailLocale = 'pt' | 'es' | 'en';

interface BaseDetailInput {
  cityId: string;
  locale?: string;
}

interface InsightAwareInput extends BaseDetailInput {
  goal?: string;
  timeline?: string;
}

interface ComparisonInput extends BaseDetailInput {
  compareTo: string[];
}

@Injectable()
export class CityDetailService {
  constructor(
    private readonly citiesCatalogService: CitiesCatalogService,
    private readonly cityInsightsService: CityInsightsService,
    private readonly cityNeighborhoodSeedService: CityNeighborhoodSeedService,
  ) {}

  async getSocialProof(input: InsightAwareInput) {
    const locale = this.resolveLocale(input.locale);
    const city = await this.citiesCatalogService.getCityById(input.cityId);
    const insights = await this.cityInsightsService.getInsights({
      cityId: city.id,
      goal: input.goal,
      timeline: input.timeline,
      locale,
      limit: 6,
    });
    const trustedInsights = insights.filter((item) => item.source !== 'template');

    const routineInsight =
      trustedInsights.find(
        (item) =>
          item.theme === 'local_routine' ||
          item.theme === 'food_and_cafes' ||
          item.theme === 'nightlife',
      ) ?? null;

    const neighborhoodInsight =
      trustedInsights.find((item) => item.theme === 'neighborhoods') ?? null;

    return {
      cityId: city.id,
      cityName: city.name,
      argentinaPopularityScore: city.argentinaPopularityScore,
      publicOpinion:
        city.publicOpinion == null
          ? null
          : {
              provider: city.publicOpinion.provider,
              placeName: city.publicOpinion.placeName,
              placeUrl: city.publicOpinion.placeUrl,
              rating: city.publicOpinion.rating,
              userRatingCount: city.publicOpinion.userRatingCount,
              summary: city.publicOpinion.summary,
              positivePoints: city.publicOpinion.positivePoints,
              criticalPoints: city.publicOpinion.criticalPoints,
              collectedAt: city.publicOpinion.collectedAt,
            },
      socialSignals: [
        {
          id: 'argentina_affinity',
          label: this.copy(locale, {
            pt: 'Afinidade entre argentinos',
            es: 'Afinidad entre argentinos',
            en: 'Affinity among Argentinians',
          }),
          value: city.argentinaPopularityScore,
          unit: 'score',
          source: city.sources.ranking.provider,
        },
        ...(city.publicOpinion?.rating != null
          ? [
              {
                id: 'public_rating',
                label: this.copy(locale, {
                  pt: 'Avaliação pública',
                  es: 'Valoración pública',
                  en: 'Public rating',
                }),
                value: city.publicOpinion.rating,
                unit: 'rating_5',
                source: city.publicOpinion.provider,
              },
            ]
          : []),
      ],
      routineInsight:
        routineInsight == null ? null : this.serializeInsight(routineInsight),
      neighborhoodInsight:
        neighborhoodInsight == null
          ? null
          : this.serializeInsight(neighborhoodInsight),
      sources: this.collectSources(city, trustedInsights),
    };
  }

  async getClimateSummary(input: BaseDetailInput) {
    const locale = this.resolveLocale(input.locale);
    const city = await this.citiesCatalogService.getCityById(input.cityId);
    const weather = await this.citiesCatalogService.getCityWeatherById(city.id);
    const seasonality = city.seasonalitySnapshot;

    return {
      cityId: city.id,
      cityName: city.name,
      currentWeather: {
        temperatureCelsius: weather.temperatureCelsius,
        weatherCode: weather.weatherCode,
        isDay: weather.isDay,
        windSpeedKmh: weather.windSpeedKmh,
        fetchedAt: weather.fetchedAt,
        conditionLabel: this.weatherConditionLabel(locale, weather.weatherCode),
      },
      seasonality:
        seasonality == null
          ? null
          : {
              peakMonths: seasonality.peakMonths,
              lowMonths: seasonality.lowMonths,
              severity: seasonality.severity,
              visitorsLabel: this.localizedSeasonalityField(
                locale,
                seasonality.visitorsLabelPt,
                seasonality.visitorsLabelEs,
                seasonality.visitorsLabelEn,
              ),
              rentNotes: this.localizedSeasonalityField(
                locale,
                seasonality.rentNotesPt,
                seasonality.rentNotesEs,
                seasonality.rentNotesEn,
              ),
              jobNotes: this.localizedSeasonalityField(
                locale,
                seasonality.jobNotesPt,
                seasonality.jobNotesEs,
                seasonality.jobNotesEn,
              ),
              populationMultiplierNote: seasonality.populationMultiplierNote,
              updatedAt: seasonality.updatedAt,
              sourceLabel: seasonality.sourceLabel,
              sourceUrl: seasonality.sourceUrl,
              sourceType: seasonality.sourceType,
            },
      sources: [
        {
          label: 'Open-Meteo',
          type: 'official',
        },
        ...(seasonality == null
          ? []
          : [
              {
                label: seasonality.sourceLabel,
                type: seasonality.sourceType,
                url: seasonality.sourceUrl,
              },
            ]),
      ],
    };
  }

  async getArrivalStory(input: InsightAwareInput) {
    const locale = this.resolveLocale(input.locale);
    const city = await this.citiesCatalogService.getCityById(input.cityId);
    const insights = await this.cityInsightsService.getInsights({
      cityId: city.id,
      goal: input.goal,
      timeline: input.timeline,
      locale,
      limit: 8,
    });
    const trustedInsights = insights.filter((item) => item.source !== 'template');
    const neighborhoods = await this.cityInsightsService.getExplorePlaces({
      cityId: city.id,
      theme: 'neighborhoods',
      locale,
      limit: 4,
    });
    const arrivalInsight =
      trustedInsights.find((item) => {
        const body =
          `${item.title} ${item.shortText} ${item.content}`.toLowerCase();
        return (
          body.includes('primeiros meses') ||
          body.includes('primeros meses') ||
          body.includes('first months') ||
          body.includes('chegada') ||
          body.includes('arrival') ||
          body.includes('adapt')
        );
      }) ??
      trustedInsights.find((item) => item.theme === 'local_routine') ??
      trustedInsights[0] ??
      null;
    const trustedNeighborhoods = this.uniqueNeighborhoods([
      ...neighborhoods.filter((item) => item.source !== 'template'),
      ...this.cityNeighborhoodSeedService.findByCityId(city.id),
      ...this.neighborhoodsFromHighlights(city, arrivalInsight),
    ]);

    const reserveMonths = this.resolveReserveMonths(city, input.timeline);
    const fairLivingTotal =
      city.budgetSnapshot == null
        ? null
        : this.fairLivingTotal(city.budgetSnapshot);
    const reserveAmountBrl =
      city.budgetSnapshot == null ? null : fairLivingTotal! * reserveMonths;

    return {
      cityId: city.id,
      cityName: city.name,
      story:
        arrivalInsight == null
          ? this.buildTimelineArrivalStory(city, locale, input.timeline)
          : this.serializeInsight(arrivalInsight),
      firstMonthBudget:
        city.budgetSnapshot == null
          ? null
          : {
              fairLivingTotalBrl: fairLivingTotal,
              averageMonthlyNetSalaryBrl:
                city.budgetSnapshot.averageMonthlyNetSalary,
              reserveMonths,
              reserveAmountBrl,
              sourceLabel: city.budgetSnapshot.sourceLabel,
              updatedAt: city.budgetSnapshot.updatedAt,
            },
      firstMonthFocus: this.firstMonthFocus(city, locale),
      neighborhoods: trustedNeighborhoods.map((item) => ({
        id: item.id,
        name: item.name,
        neighborhood: item.neighborhood,
        region: item.region,
        shortText: item.shortText,
        mapUrl: item.mapUrl,
        source: item.source,
      })),
      sources: this.collectSources(city, trustedInsights, trustedNeighborhoods),
    };
  }

  async getComparison(input: ComparisonInput) {
    const locale = this.resolveLocale(input.locale);
    const primary = await this.citiesCatalogService.getCityById(input.cityId);
    const comparisonCities = await Promise.all(
      input.compareTo
        .filter((item) => item.trim().length > 0)
        .slice(0, 4)
        .map((item) => this.citiesCatalogService.getCityById(item)),
    );

    const metrics = [
      this.metricRow(
        locale,
        'cost_of_living',
        this.copy(locale, {
          pt: 'Custo mensal base',
          es: 'Costo mensual base',
          en: 'Base monthly cost',
        }),
        primary.budgetSnapshot == null
          ? null
          : this.fairLivingTotal(primary.budgetSnapshot),
        comparisonCities.map((city) => ({
          cityId: city.id,
          cityName: city.name,
          value:
            city.budgetSnapshot == null
              ? null
              : this.fairLivingTotal(city.budgetSnapshot),
        })),
        'BRL',
        true,
      ),
      this.metricRow(
        locale,
        'safety',
        this.copy(locale, {
          pt: 'Segurança',
          es: 'Seguridad',
          en: 'Safety',
        }),
        primary.safetyScore,
        comparisonCities.map((city) => ({
          cityId: city.id,
          cityName: city.name,
          value: city.safetyScore,
        })),
        'score',
      ),
      this.metricRow(
        locale,
        'work',
        this.copy(locale, {
          pt: 'Trabalho',
          es: 'Trabajo',
          en: 'Work',
        }),
        primary.movaroScores.workOpportunity,
        comparisonCities.map((city) => ({
          cityId: city.id,
          cityName: city.name,
          value: city.movaroScores.workOpportunity,
        })),
        'score',
      ),
      this.metricRow(
        locale,
        'language',
        this.copy(locale, {
          pt: 'Adaptação de idioma',
          es: 'Adaptación de idioma',
          en: 'Language adaptation',
        }),
        primary.movaroScores.languageAdaptation,
        comparisonCities.map((city) => ({
          cityId: city.id,
          cityName: city.name,
          value: city.movaroScores.languageAdaptation,
        })),
        'score',
      ),
      this.metricRow(
        locale,
        'public_rating',
        this.copy(locale, {
          pt: 'Avaliação pública',
          es: 'Valoración pública',
          en: 'Public rating',
        }),
        primary.publicOpinion?.rating ?? null,
        comparisonCities.map((city) => ({
          cityId: city.id,
          cityName: city.name,
          value: city.publicOpinion?.rating ?? null,
        })),
        'rating_5',
      ),
    ];

    return {
      cityId: primary.id,
      cityName: primary.name,
      compareTo: comparisonCities.map((city) => ({
        cityId: city.id,
        cityName: city.name,
        stateCode: city.stateCode,
      })),
      metrics,
      sources: this.collectSources(primary, []),
    };
  }

  private metricRow(
    locale: DetailLocale,
    id: string,
    label: string,
    primaryValue: number | null,
    comparisons: Array<{
      cityId: string;
      cityName: string;
      value: number | null;
    }>,
    unit: string,
    lowerIsBetter = false,
  ) {
    const all = [primaryValue, ...comparisons.map((item) => item.value)].filter(
      (value): value is number => value != null,
    );
    const benchmark =
      all.length === 0
        ? null
        : lowerIsBetter
          ? Math.min(...all)
          : Math.max(...all);

    return {
      id,
      label,
      unit,
      primaryValue,
      benchmark,
      primaryIsBest:
        primaryValue != null && benchmark != null
          ? primaryValue === benchmark
          : false,
      benchmarkLabel:
        benchmark == null
          ? null
          : this.copy(locale, {
              pt: lowerIsBetter
                ? 'menor entre as cidades'
                : 'maior entre as cidades',
              es: lowerIsBetter
                ? 'menor entre ciudades'
                : 'mayor entre ciudades',
              en: lowerIsBetter
                ? 'lowest among compared cities'
                : 'highest among compared cities',
            }),
      comparisons,
    };
  }

  private firstMonthFocus(city: CityCardEntity, locale: DetailLocale) {
    const pairs = [
      {
        id: 'housing',
        score: city.rentScore,
        label: this.copy(locale, {
          pt: 'Moradia',
          es: 'Vivienda',
          en: 'Housing',
        }),
      },
      {
        id: 'language',
        score: city.movaroScores.languageAdaptation,
        label: this.copy(locale, {
          pt: 'Idioma',
          es: 'Idioma',
          en: 'Language',
        }),
      },
      {
        id: 'work',
        score: city.movaroScores.workOpportunity,
        label: this.copy(locale, {
          pt: 'Trabalho',
          es: 'Trabajo',
          en: 'Work',
        }),
      },
      {
        id: 'safety',
        score: city.safetyScore,
        label: this.copy(locale, {
          pt: 'Segurança',
          es: 'Seguridad',
          en: 'Safety',
        }),
      },
    ].sort((left, right) => left.score - right.score);

    return pairs.slice(0, 3);
  }

  private resolveReserveMonths(city: CityCardEntity, timeline?: string) {
    if (timeline === 'in_0_3m') {
      return city.rentScore >= 70 ? 2 : 3;
    }
    if (timeline === 'in_3_6m') {
      return city.rentScore >= 70 ? 2 : 4;
    }
    return city.rentScore >= 70 ? 3 : 4;
  }

  private buildTimelineArrivalStory(
    city: CityCardEntity,
    locale: DetailLocale,
    timeline?: string,
  ) {
    const focus = this.firstMonthFocus(city, locale)[0];
    const seasonality = city.seasonalitySnapshot;
    const budget = city.budgetSnapshot;
    const urgency = this.copy(locale, {
      pt:
        timeline === 'in_0_3m'
          ? 'A chegada está perto, então as decisões precisam reduzir risco agora.'
          : timeline === 'in_3_6m'
            ? 'Ainda há tempo para validar custo e bairro antes de transformar curiosidade em contrato.'
            : 'Com mais horizonte, vale organizar a chegada em camadas e evitar decisões caras cedo demais.',
      es:
        timeline === 'in_0_3m'
          ? 'La llegada está cerca, así que las decisiones deben reducir riesgo ahora.'
          : timeline === 'in_3_6m'
            ? 'Todavía hay tiempo para validar costo y barrio antes de convertir curiosidad en contrato.'
            : 'Con más horizonte, conviene organizar la llegada por capas y evitar decisiones caras demasiado pronto.',
      en:
        timeline === 'in_0_3m'
          ? 'Arrival is close, so decisions should reduce risk right now.'
          : timeline === 'in_3_6m'
            ? 'There is still time to validate cost and neighborhood before turning curiosity into a contract.'
            : 'With more runway, it is better to organize the move in layers and avoid expensive decisions too early.',
    });
    const focusText = this.copy(locale, {
      pt: `Hoje o foco mais sensível para ${city.name} é ${focus.label.toLowerCase()}.`,
      es: `Hoy el foco más sensible para ${city.name} es ${focus.label.toLowerCase()}.`,
      en: `Right now the most sensitive focus for ${city.name} is ${focus.label.toLowerCase()}.`,
    });
    const seasonalityText =
      seasonality == null
        ? this.copy(locale, {
            pt: 'A cidade não mostra um pico sazonal forte no dataset atual.',
            es: 'La ciudad no muestra un pico estacional fuerte en el dataset actual.',
            en: 'The city does not show a major seasonal spike in the current dataset.',
          })
        : this.copy(locale, {
            pt: `A sazonalidade pesa entre ${this.monthList(locale, seasonality.peakMonths)}, então moradia e preço mudam mais nesse período.`,
            es: `La estacionalidad pesa entre ${this.monthList(locale, seasonality.peakMonths)}, así que vivienda y precio cambian más en ese período.`,
            en: `Seasonality hits harder between ${this.monthList(locale, seasonality.peakMonths)}, so housing and pricing move more in that window.`,
          });
    const budgetText =
      budget == null
        ? this.copy(locale, {
            pt: 'Ainda não há um snapshot granular de orçamento disponível para esta cidade.',
            es: 'Todavía no hay un snapshot granular de presupuesto para esta ciudad.',
            en: 'There is no granular budget snapshot available for this city yet.',
          })
        : this.copy(locale, {
            pt: `O snapshot atual aponta custo base mensal perto de R$ ${this.fairLivingTotal(budget)?.toFixed(0)} e salário líquido médio de R$ ${budget.averageMonthlyNetSalary.toFixed(0)}.`,
            es: `El snapshot actual apunta a un costo base mensual cerca de R$ ${this.fairLivingTotal(budget)?.toFixed(0)} y salario neto medio de R$ ${budget.averageMonthlyNetSalary.toFixed(0)}.`,
            en: `The current snapshot points to a base monthly cost near R$ ${this.fairLivingTotal(budget)?.toFixed(0)} and an average net salary of R$ ${budget.averageMonthlyNetSalary.toFixed(0)}.`,
          });

    return {
      id: `${city.id}-arrival-derived`,
      type: 'practical_tip',
      theme: 'local_routine',
      title: this.copy(locale, {
        pt: 'Leitura prática para a chegada',
        es: 'Lectura práctica para la llegada',
        en: 'Practical arrival read',
      }),
      shortText: `${urgency} ${focusText}`,
      content: `${budgetText} ${seasonalityText}`,
      placeHighlights: [],
      ctaLabel: this.copy(locale, {
        pt: 'Planejar chegada',
        es: 'Planificar llegada',
        en: 'Plan arrival',
      }),
      source: 'derived',
      generatedAt: new Date().toISOString(),
      expiresAt: undefined,
    };
  }

  private serializeInsight(insight: {
    id: string;
    type: string;
    theme?: string;
    title: string;
    shortText: string;
    content: string;
    placeHighlights?: string[];
    ctaLabel?: string;
    source: string;
    generatedAt: string;
    expiresAt?: string;
  }) {
    return {
      id: insight.id,
      type: insight.type,
      theme: insight.theme,
      title: insight.title,
      shortText: insight.shortText,
      content: insight.content,
      placeHighlights: insight.placeHighlights ?? [],
      ctaLabel: insight.ctaLabel,
      source: insight.source,
      generatedAt: insight.generatedAt,
      expiresAt: insight.expiresAt,
    };
  }

  private collectSources(
    city: CityCardEntity,
    insights: Array<{ source: string }>,
    places: Array<{ source: string }> = [],
  ) {
    const labels = new Set<string>();
    const sources = [
      city.sources.ranking.provider,
      city.sources.curatedMetrics.provider,
      city.sources.employment?.provider,
      city.sources.safety?.provider,
      city.publicOpinion?.provider,
      city.budgetSnapshot?.sourceLabel,
      city.seasonalitySnapshot?.sourceLabel,
      ...insights.map((item) => item.source),
      ...places.map((item) => item.source),
    ].filter(
      (value): value is string =>
        value != null &&
        value.trim().length > 0 &&
        value.trim().toLowerCase() !== 'template',
    );

    return sources
      .filter((value) => {
        if (labels.has(value)) {
          return false;
        }
        labels.add(value);
        return true;
      })
      .map((value) => ({ label: value }));
  }

  private neighborhoodsFromHighlights(
    city: CityCardEntity,
    insight:
      | {
          id: string;
          title: string;
          shortText: string;
          placeHighlights?: string[];
        }
      | null,
  ) {
    const highlights = (insight?.placeHighlights ?? []).filter(
      (value) => value.trim().length > 0,
    );
    if (highlights.length === 0) {
      return [];
    }

    return highlights.slice(0, 4).map((name, index) => ({
      id: `${city.id}-highlight-neighborhood-${index + 1}`,
      cityId: city.id,
      cityName: city.name,
      theme: 'neighborhoods' as const,
      name,
      category: this.copy('pt', {
        pt: 'bairro',
        es: 'barrio',
        en: 'neighborhood',
      }),
      neighborhood: name,
      region: city.name,
      shortText:
        insight?.shortText ||
        `${name} aparece nos sinais curados desta cidade como ponto útil para começar a entender a rotina local.`,
      mapUrl: `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${name} ${city.name}`)}`,
      source: 'curated' as const,
    }));
  }

  private monthList(locale: DetailLocale, months: number[]) {
    const labels = {
      pt: ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'],
      es: ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'],
      en: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    }[locale];
    return months
      .filter((month) => month >= 1 && month <= 12)
      .map((month) => labels[month - 1])
      .join(', ');
  }

  private uniqueNeighborhoods<
    T extends { name: string; neighborhood?: string; region?: string; mapUrl: string },
  >(items: T[]) {
    const seen = new Set<string>();
    return items.filter((item) => {
      const key = [
        item.name.trim().toLowerCase(),
        item.neighborhood?.trim().toLowerCase() ?? '',
        item.region?.trim().toLowerCase() ?? '',
        item.mapUrl.trim().toLowerCase(),
      ].join('::');
      if (seen.has(key)) {
        return false;
      }
      seen.add(key);
      return true;
    });
  }

  private weatherConditionLabel(locale: DetailLocale, code: number | null) {
    if (code == null) {
      return this.copy(locale, {
        pt: 'Sem leitura',
        es: 'Sin lectura',
        en: 'No live read',
      });
    }
    if (code === 0 || code === 1) {
      return this.copy(locale, {
        pt: 'Céu aberto',
        es: 'Cielo abierto',
        en: 'Clear sky',
      });
    }
    if (code >= 2 && code <= 48) {
      return this.copy(locale, {
        pt: 'Nuvens',
        es: 'Nubes',
        en: 'Clouds',
      });
    }
    if (code >= 51 && code <= 67) {
      return this.copy(locale, {
        pt: 'Chuva leve a moderada',
        es: 'Lluvia leve a moderada',
        en: 'Light to moderate rain',
      });
    }
    if (code >= 71 && code <= 77) {
      return this.copy(locale, {
        pt: 'Frio intenso',
        es: 'Frío intenso',
        en: 'Colder conditions',
      });
    }
    return this.copy(locale, {
      pt: 'Tempo instável',
      es: 'Tiempo inestable',
      en: 'Unstable weather',
    });
  }

  private localizedSeasonalityField(
    locale: DetailLocale,
    pt: string,
    es: string,
    en: string,
  ) {
    return locale === 'pt' ? pt : locale === 'es' ? es : en;
  }

  private resolveLocale(locale?: string): DetailLocale {
    return locale === 'es' || locale === 'en' ? locale : 'pt';
  }

  private copy(
    locale: DetailLocale,
    values: { pt: string; es: string; en: string },
  ) {
    return locale === 'pt'
      ? values.pt
      : locale === 'es'
        ? values.es
        : values.en;
  }

  private fairLivingTotal(budget: CityCardEntity['budgetSnapshot']) {
    if (budget == null) {
      return null;
    }
    return (
      budget.singlePersonExcludingRent +
      Math.min(budget.oneBedroomOutsideCentre, budget.oneBedroomCityCentre)
    );
  }
}
