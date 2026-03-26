import { Injectable } from '@nestjs/common';

import { AssistantKnowledgeService } from './assistant-knowledge.service';
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
        ? `${input.originCountry.toLowerCase().trim()}->${input.destinationCountry
            .toLowerCase()
            .trim()}`
        : undefined;

    const items = await this.assistantKnowledgeService.getGuideAnswers(
      locale,
      input.destinationCountry,
      corridorKey,
    );

    return { items };
  }

  private normalizeLocale(locale?: string): GuidanceLocale {
    if (locale === 'es' || locale === 'en') {
      return locale;
    }
    return 'pt';
  }
}
