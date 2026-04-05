import { Injectable } from '@nestjs/common';

import { AssistantKnowledgeService } from './assistant-knowledge.service';
import {
  normalizeChatCorridor,
  normalizeChatCountry,
} from './chat-country-normalizer';
import { GuidanceLocale } from './resolvers/corridor-guidance-profiles';

@Injectable()
export class GuideAnswersService {
  constructor(
    private readonly assistantKnowledgeService: AssistantKnowledgeService,
  ) {}

  async list(input: {
    destinationCountry: string;
    originCountry?: string;
    locale?: string;
  }) {
    const locale = this.normalizeLocale(input.locale);
    const corridorKey =
      input.originCountry && input.destinationCountry
        ? normalizeChatCorridor(input.originCountry, input.destinationCountry)
        : undefined;

    const items = await this.assistantKnowledgeService.getGuideAnswers(
      locale,
      normalizeChatCountry(input.destinationCountry),
      corridorKey,
    );

    return { items };
  }

  async resolve(input: {
    message: string;
    destinationCountry: string;
    originCountry?: string;
    locale?: string;
  }) {
    const locale = this.normalizeLocale(input.locale);
    const corridorKey =
      input.originCountry && input.destinationCountry
        ? normalizeChatCorridor(input.originCountry, input.destinationCountry)
        : undefined;

    return this.assistantKnowledgeService.resolveGuideAnswer(
      input.message,
      locale,
      normalizeChatCountry(input.destinationCountry),
      corridorKey,
    );
  }

  private normalizeLocale(locale?: string): GuidanceLocale {
    if (locale === 'es' || locale === 'en') {
      return locale;
    }
    return 'pt';
  }
}
