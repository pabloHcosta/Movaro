import { Injectable } from '@nestjs/common';

import { AppConfigService } from '../../common/config/app-config.service';
import { CityMetricsModel } from '../../modules/cities/data/models/city-metrics.model';
import { CityPublicOpinionEntity } from '../../modules/cities/domain/entities/city-public-opinion.entity';

type GoogleTextSearchResponse = {
  places?: Array<{
    id?: string;
    displayName?: {
      text?: string;
    };
  }>;
};

type GooglePlaceDetailsResponse = {
  displayName?: {
    text?: string;
  };
  rating?: number;
  userRatingCount?: number;
  googleMapsUri?: string;
  reviewSummary?: {
    text?: {
      text?: string;
    };
  };
  reviews?: Array<{
    rating?: number;
    text?: {
      text?: string;
    };
    originalText?: {
      text?: string;
    };
  }>;
};

type OpinionTopic = {
  id: string;
  positiveLabel: string;
  criticalLabel: string;
  aliases: string[];
};

type ParsedReview = {
  rating: number;
  text: string;
};

@Injectable()
export class GooglePlacesCityOpinionService {
  constructor(private readonly appConfigService: AppConfigService) {}

  private readonly baseUrl = 'https://places.googleapis.com/v1';
  private readonly cache = new Map<string, CityPublicOpinionEntity | null>();

  private readonly topics: OpinionTopic[] = [
    {
      id: 'nature',
      positiveLabel: 'praias, natureza e paisagens',
      criticalLabel: 'preservacao dos espacos naturais e praias',
      aliases: [
        'praia',
        'praias',
        'mar',
        'natureza',
        'paisagem',
        'paisagens',
        'vista',
        'vistas',
        'lagoa',
        'lagoas',
        'parque',
        'parques',
        'verde',
        'green areas',
      ],
    },
    {
      id: 'safety',
      positiveLabel: 'sensacao de seguranca',
      criticalLabel: 'seguranca e tranquilidade nas ruas',
      aliases: [
        'seguranca',
        'seguro',
        'segura',
        'safe',
        'safety',
        'inseguro',
        'insegura',
      ],
    },
    {
      id: 'cleanliness',
      positiveLabel: 'limpeza e organizacao urbana',
      criticalLabel: 'limpeza e conservacao',
      aliases: [
        'limpa',
        'limpo',
        'limpeza',
        'organizada',
        'organizado',
        'organized',
        'clean',
        'cleanliness',
        'suja',
        'sujo',
      ],
    },
    {
      id: 'hospitality',
      positiveLabel: 'acolhimento e hospitalidade',
      criticalLabel: 'atendimento e receptividade',
      aliases: [
        'acolhedor',
        'acolhedora',
        'hospitalidade',
        'receptivo',
        'receptiva',
        'gentileza',
        'gentis',
        'friendly',
        'welcoming',
        'atendimento',
        'service',
      ],
    },
    {
      id: 'food',
      positiveLabel: 'gastronomia e vida social',
      criticalLabel: 'qualidade e variedade gastronomica',
      aliases: [
        'comida',
        'gastronomia',
        'restaurante',
        'restaurantes',
        'bar',
        'bares',
        'food',
        'restaurant',
        'restaurants',
      ],
    },
    {
      id: 'mobility',
      positiveLabel: 'mobilidade e acesso',
      criticalLabel: 'transito e deslocamento',
      aliases: [
        'transito',
        'trânsito',
        'trafego',
        'tráfego',
        'mobilidade',
        'transporte',
        'onibus',
        'ônibus',
        'metro',
        'metrô',
        'traffic',
        'transport',
        'parking',
        'estacionamento',
      ],
    },
    {
      id: 'cost',
      positiveLabel: 'custo-beneficio',
      criticalLabel: 'custo de vida e precos',
      aliases: [
        'caro',
        'cara',
        'caras',
        'preco',
        'precos',
        'preço',
        'preços',
        'aluguel',
        'custo',
        'barato',
        'barata',
        'expensive',
        'cheap',
        'affordable',
        'rent',
      ],
    },
    {
      id: 'infrastructure',
      positiveLabel: 'infraestrutura e servicos',
      criticalLabel: 'infraestrutura e manutencao urbana',
      aliases: [
        'infraestrutura',
        'estrutura',
        'servicos',
        'serviços',
        'comercio',
        'comércio',
        'infra',
        'infrastructure',
        'services',
      ],
    },
    {
      id: 'tourism',
      positiveLabel: 'lazer e atracoes',
      criticalLabel: 'lotacao em areas turisticas',
      aliases: [
        'turismo',
        'turistica',
        'turístico',
        'passeio',
        'passeios',
        'atracao',
        'atração',
        'atracoes',
        'atrações',
        'tourism',
        'tourist',
      ],
    },
    {
      id: 'climate',
      positiveLabel: 'clima e ambiente ao ar livre',
      criticalLabel: 'clima e conforto no dia a dia',
      aliases: [
        'clima',
        'calor',
        'quente',
        'frio',
        'vento',
        'weather',
        'climate',
        'hot',
        'cold',
      ],
    },
  ];

  async getCityOpinion(
    city: CityMetricsModel,
    stateName: string,
  ): Promise<CityPublicOpinionEntity | null> {
    if (!this.appConfigService.googlePlacesApiKey) {
      return null;
    }

    const cached = this.cache.get(city.id);
    if (cached !== undefined) {
      return cached;
    }

    const opinion = await this.loadCityOpinion(city, stateName).catch(
      () => null,
    );
    this.cache.set(city.id, opinion);
    return opinion;
  }

  private async loadCityOpinion(
    city: CityMetricsModel,
    stateName: string,
  ): Promise<CityPublicOpinionEntity | null> {
    const place = await this.searchCityPlace(city.name, stateName);
    if (!place.id) {
      return null;
    }

    const details = await this.getPlaceDetails(place.id);
    const reviews = this.parseReviews(details.reviews);
    const positivePoints = this.extractTopics(
      reviews.filter((review) => review.rating >= 4),
      'positive',
    );
    const criticalPoints = this.extractTopics(
      reviews.filter((review) => review.rating <= 3),
      'critical',
    );

    if (positivePoints.length === 0 && criticalPoints.length === 0) {
      return null;
    }

    return new CityPublicOpinionEntity(
      'Google',
      details.displayName?.text ?? place.displayName?.text ?? city.name,
      details.googleMapsUri ?? null,
      typeof details.rating === 'number' ? details.rating : null,
      typeof details.userRatingCount === 'number'
        ? details.userRatingCount
        : null,
      details.reviewSummary?.text?.text?.trim() || null,
      positivePoints,
      criticalPoints,
      new Date().toISOString(),
    );
  }

  private async searchCityPlace(cityName: string, stateName: string) {
    const response = await fetch(`${this.baseUrl}/places:searchText`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': this.appConfigService.googlePlacesApiKey ?? '',
        'X-Goog-FieldMask': 'places.id,places.displayName',
      },
      body: JSON.stringify({
        textQuery: `${cityName}, ${stateName}, Brasil`,
        languageCode: 'pt-BR',
        regionCode: 'BR',
        maxResultCount: 1,
      }),
      signal: AbortSignal.timeout(
        this.appConfigService.outboundRequestTimeoutMs,
      ),
    });

    if (!response.ok) {
      return {};
    }

    const payload = (await response.json()) as GoogleTextSearchResponse;
    return payload.places?.[0] ?? {};
  }

  private async getPlaceDetails(
    placeId: string,
  ): Promise<GooglePlaceDetailsResponse> {
    const url = new URL(`${this.baseUrl}/places/${placeId}`);
    url.searchParams.set('languageCode', 'pt-BR');
    url.searchParams.set('regionCode', 'BR');

    const response = await fetch(url, {
      headers: {
        'X-Goog-Api-Key': this.appConfigService.googlePlacesApiKey ?? '',
        'X-Goog-FieldMask':
          'displayName,rating,userRatingCount,googleMapsUri,reviewSummary,reviews',
      },
      signal: AbortSignal.timeout(
        this.appConfigService.outboundRequestTimeoutMs,
      ),
    });

    if (!response.ok) {
      return {};
    }

    return (await response.json()) as GooglePlaceDetailsResponse;
  }

  private parseReviews(
    reviews: GooglePlaceDetailsResponse['reviews'],
  ): ParsedReview[] {
    return (reviews ?? [])
      .map((review) => ({
        rating: typeof review.rating === 'number' ? review.rating : 0,
        text: (review.originalText?.text ?? review.text?.text ?? '').trim(),
      }))
      .filter((review) => review.text.length >= 12);
  }

  private extractTopics(
    reviews: ParsedReview[],
    sentiment: 'positive' | 'critical',
  ): string[] {
    if (reviews.length === 0) {
      return [];
    }

    const counts = new Map<string, number>();

    for (const review of reviews) {
      const normalized = this.normalize(review.text);
      const matched = new Set<string>();

      for (const topic of this.topics) {
        if (
          topic.aliases.some((alias) =>
            normalized.includes(this.normalize(alias)),
          )
        ) {
          matched.add(topic.id);
        }
      }

      for (const topicId of matched) {
        counts.set(topicId, (counts.get(topicId) ?? 0) + 1);
      }
    }

    return [...counts.entries()]
      .sort((left, right) => right[1] - left[1])
      .slice(0, 3)
      .map(([topicId]) => this.topics.find((topic) => topic.id === topicId))
      .filter((topic): topic is OpinionTopic => topic != null)
      .map((topic) =>
        sentiment === 'positive' ? topic.positiveLabel : topic.criticalLabel,
      );
  }

  private normalize(value: string): string {
    return value
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase();
  }
}
