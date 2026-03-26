import { Injectable } from '@nestjs/common';

import { CorridorGuidanceResolverService } from './resolvers/corridor-guidance-resolver.service';
import { GuidanceLocale } from './resolvers/corridor-guidance-profiles';

interface PromptItem {
  key: string;
  label: string;
  message: string;
}

@Injectable()
export class ChatPromptsService {
  constructor(
    private readonly corridorGuidanceResolver: CorridorGuidanceResolverService,
  ) {}

  async buildPrompts(input: {
    originCountry: string;
    destinationCountry: string;
    locale?: string;
  }) {
    const locale = this.normalizeLocale(input.locale);
    const firstLocalDocument =
      await this.corridorGuidanceResolver.getQuickPromptMessage(
        input.originCountry,
        input.destinationCountry,
        locale,
      );
    const firstLocalDocumentLabel =
      await this.corridorGuidanceResolver.getQuickPromptLabel(
        input.originCountry,
        input.destinationCountry,
        locale,
      );

    const destinationLabel =
      input.destinationCountry.trim().length > 0
        ? input.destinationCountry.trim()
        : this.genericDestinationLabel(locale);

    return {
      categories: [
        {
          key: 'documents',
          label: this.categoryLabel('documents', locale),
          message: this.documentsPrompt(
            locale,
            destinationLabel,
            firstLocalDocument,
          ),
        },
        {
          key: 'costs',
          label: this.categoryLabel('costs', locale),
          message: this.costsPrompt(locale),
        },
        {
          key: 'activities',
          label: this.categoryLabel('activities', locale),
          message: this.activitiesPrompt(locale),
        },
        {
          key: 'stay',
          label: this.categoryLabel('stay', locale),
          message: this.housingPrompt(locale, destinationLabel),
        },
      ] satisfies PromptItem[],
      chips: [
        {
          key: 'visa',
          label: this.visaChip(locale),
          message: this.visaChip(locale),
        },
        {
          key: 'best_time',
          label: this.bestTimeChip(locale),
          message: this.bestTimeChip(locale),
        },
        {
          key: 'first_local_document',
          label: firstLocalDocumentLabel,
          message: firstLocalDocument,
        },
      ] satisfies PromptItem[],
    };
  }

  private normalizeLocale(locale?: string): GuidanceLocale {
    if (locale === 'es' || locale === 'en') {
      return locale;
    }
    return 'pt';
  }

  private categoryLabel(
    key: 'documents' | 'costs' | 'activities' | 'stay',
    locale: GuidanceLocale,
  ): string {
    const labels = {
      documents: { pt: 'Documentos', es: 'Documentos', en: 'Documents' },
      costs: { pt: 'Custos', es: 'Costos', en: 'Costs' },
      activities: { pt: 'O que fazer', es: 'Qué hacer', en: 'What to do' },
      stay: { pt: 'Onde ficar', es: 'Dónde quedarse', en: 'Where to stay' },
    };

    return labels[key][locale];
  }

  private documentsPrompt(
    locale: GuidanceLocale,
    destinationLabel: string,
    firstLocalDocumentPrompt: string,
  ): string {
    if (locale === 'es') {
      return `¿Qué documentos necesito para migrar a ${destinationLabel}? Explica visa y ${firstLocalDocumentPrompt}.`;
    }
    if (locale === 'en') {
      return `What documents do I need to move to ${destinationLabel}? Explain visas and ${firstLocalDocumentPrompt}.`;
    }
    return `Quais documentos preciso para migrar para ${destinationLabel}? Explique visto e ${firstLocalDocumentPrompt}.`;
  }

  private housingPrompt(
    locale: GuidanceLocale,
    destinationLabel: string,
  ): string {
    if (locale === 'es') {
      return `¿Cómo encontrar vivienda en ${destinationLabel}? Consejos para alquilar.`;
    }
    if (locale === 'en') {
      return `How do I find housing in ${destinationLabel}? Renting tips.`;
    }
    return `Como encontrar moradia em ${destinationLabel}? Dicas para alugar.`;
  }

  private costsPrompt(locale: GuidanceLocale): string {
    if (locale === 'es') {
      return '¿Cuánto cuesta mudarse? Dame una visión general de los costos.';
    }
    if (locale === 'en') {
      return 'How much does it cost to move? Give me a cost overview.';
    }
    return 'Quanto custa se mudar? Me dê uma visão geral dos custos.';
  }

  private activitiesPrompt(locale: GuidanceLocale): string {
    if (locale === 'es') {
      return '¿Qué debo saber sobre la vida en la ciudad destino?';
    }
    if (locale === 'en') {
      return 'What should I know about life in the destination city?';
    }
    return 'O que devo saber sobre a vida na cidade destino?';
  }

  private visaChip(locale: GuidanceLocale): string {
    if (locale === 'es') return '¿Necesito visa?';
    if (locale === 'en') return 'Do I need a visa?';
    return 'Preciso de visto?';
  }

  private bestTimeChip(locale: GuidanceLocale): string {
    if (locale === 'es') return '¿Mejor época para ir?';
    if (locale === 'en') return 'Best time to go?';
    return 'Melhor época pra ir?';
  }

  private genericDestinationLabel(locale: GuidanceLocale): string {
    if (locale === 'es') return 'tu destino';
    if (locale === 'en') return 'your destination';
    return 'seu destino';
  }
}
