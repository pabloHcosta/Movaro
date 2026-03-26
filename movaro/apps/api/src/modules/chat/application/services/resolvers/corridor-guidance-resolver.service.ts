import { Injectable } from '@nestjs/common';

import { CitiesCatalogService } from '../../../../cities/application/services/cities-catalog.service';
import { AssistantKnowledgeService } from '../assistant-knowledge.service';
import { AskChatDto } from '../../../presentation/dto/ask-chat.dto';
import {
  corridorGuidanceProfiles,
  CorridorGuidanceProfile,
  GuidanceLocale,
  GuidanceTopic,
} from './corridor-guidance-profiles';

export interface CorridorGuidanceResult {
  found: boolean;
  confidence: number;
  answer: string;
  topic?: GuidanceTopic;
}

const TOPIC_KEYWORDS: Record<GuidanceTopic, string[]> = {
  documents: [
    'documentos',
    'documents',
    'documentación',
    'papelada',
    'papeles',
  ],
  cpf: ['cpf', 'cadastro de pessoa fisica', 'cadastro de pessoa física'],
  visa: ['visto', 'visa', 'visado', 'residencia', 'residência', 'mercosul'],
  costs: [
    'custo',
    'custos',
    'cost',
    'costs',
    'costo',
    'costos',
    'orçamento',
    'presupuesto',
    'budget',
  ],
  housing: [
    'moradia',
    'housing',
    'vivienda',
    'onde ficar',
    'where to stay',
    'donde quedarse',
    'dónde quedarse',
    'aluguel',
    'rent',
    'alquiler',
  ],
  activities: [
    'o que fazer',
    'what to do',
    'que hacer',
    'qué hacer',
    'vida na cidade',
    'life in the city',
    'vida en la ciudad',
  ],
  best_time: [
    'melhor época',
    'melhor epoca',
    'best time',
    'best season',
    'mejor época',
    'mejor epoca',
    'melhor momento',
  ],
};

@Injectable()
export class CorridorGuidanceResolverService {
  constructor(
    private readonly citiesCatalogService: CitiesCatalogService,
    private readonly assistantKnowledgeService: AssistantKnowledgeService,
  ) {}

  async resolve(dto: AskChatDto): Promise<CorridorGuidanceResult> {
    const topic = this.detectTopic(dto.message);
    if (!topic) {
      return { found: false, confidence: 0, answer: '' };
    }

    const corridorKey = this.normalizeCorridor(
      dto.originCountry,
      dto.destinationCountry,
    );
    const profile = corridorGuidanceProfiles.find(
      (item) => item.key === corridorKey,
    );
    const locale = this.normalizeLocale(dto.locale);

    if (!profile) {
      return {
        found: true,
        confidence: 0.9,
        topic,
        answer: this.unsupportedCorridorAnswer(
          locale,
          dto.originCountry,
          dto.destinationCountry,
        ),
      };
    }

    const normalizedCompletedItemIds = this.normalizeCompletedItemIds(
      dto.completedItemIds ?? [],
      profile,
    );

    const cityName = dto.recommendedCityId
      ? this.citiesCatalogService.getCityDisplayNameById(dto.recommendedCityId)
      : null;

    return {
      found: true,
      confidence: 0.93,
      topic,
        answer: profile.buildAnswer(topic, locale, {
        cityName,
        currentPhase: dto.currentPhase,
        completedItemIds: normalizedCompletedItemIds,
      }, {
        phaseHint: (currentLocale, currentPhase, completedItemIds) =>
          this.phaseHint(profile, currentLocale, currentPhase, completedItemIds),
        nextPendingItem: (currentPhase, completedItemIds, preferredPhases) =>
          this.nextPendingItem(
            profile,
            currentPhase,
            completedItemIds,
            preferredPhases,
          ),
      }),
    };
  }

  async getQuickPromptLabel(
    originCountry: string,
    destinationCountry: string,
    locale: string,
  ): Promise<string> {
    const corridorKey = this.normalizeCorridor(originCountry, destinationCountry);
    const normalizedLocale = this.normalizeLocale(locale);
    const template = await this.assistantKnowledgeService.getQuickPromptTemplate(
      'first_local_document',
      normalizedLocale,
      corridorKey,
    );
    if (template) {
      return template.label;
    }

    const profile = this.resolveProfile(originCountry, destinationCountry);
    if (!profile) {
      return this.genericQuickPromptLabel(normalizedLocale);
    }
    return profile.quickPromptLabel(normalizedLocale);
  }

  async getQuickPromptMessage(
    originCountry: string,
    destinationCountry: string,
    locale: string,
  ): Promise<string> {
    const corridorKey = this.normalizeCorridor(originCountry, destinationCountry);
    const normalizedLocale = this.normalizeLocale(locale);
    const template = await this.assistantKnowledgeService.getQuickPromptTemplate(
      'first_local_document',
      normalizedLocale,
      corridorKey,
    );
    if (template) {
      return template.message;
    }

    const profile = this.resolveProfile(originCountry, destinationCountry);
    if (!profile) {
      return this.genericQuickPromptMessage(normalizedLocale);
    }
    return profile.quickPromptMessage(normalizedLocale);
  }

  private detectTopic(message: string): GuidanceTopic | null {
    const lower = message.toLowerCase();

    let bestTopic: GuidanceTopic | null = null;
    let bestScore = 0;

    for (const [topic, keywords] of Object.entries(TOPIC_KEYWORDS)) {
      const score = keywords.reduce(
        (sum, keyword) => sum + (lower.includes(keyword) ? keyword.length : 0),
        0,
      );
      if (score > bestScore) {
        bestTopic = topic as GuidanceTopic;
        bestScore = score;
      }
    }

    return bestScore > 0 ? bestTopic : null;
  }

  private resolveProfile(
    originCountry: string,
    destinationCountry: string,
  ): CorridorGuidanceProfile | null {
    const corridorKey = this.normalizeCorridor(originCountry, destinationCountry);
    return (
      corridorGuidanceProfiles.find((item) => item.key === corridorKey) ?? null
    );
  }

  private normalizeCorridor(originCountry: string, destinationCountry: string) {
    return `${originCountry.toLowerCase().trim()}->${destinationCountry
      .toLowerCase()
      .trim()}`;
  }

  private normalizeLocale(locale?: string): GuidanceLocale {
    if (locale === 'es' || locale === 'en') {
      return locale;
    }
    return 'pt';
  }

  private normalizeCompletedItemIds(
    completedItemIds: string[],
    profile: CorridorGuidanceProfile,
  ): string[] {
    if (!profile.completedItemAliases) {
      return completedItemIds;
    }

    return completedItemIds.map(
      (itemId) => profile.completedItemAliases?.[itemId] ?? itemId,
    );
  }

  private phaseHint(
    profile: CorridorGuidanceProfile,
    locale: GuidanceLocale,
    currentPhase: string | undefined,
    completedItemIds: string[],
  ): string {
    const nextItem = this.nextPendingItem(
      profile,
      currentPhase,
      completedItemIds,
    );

    if (!nextItem) {
      if (locale === 'es') {
        return 'Tu progreso actual no muestra un cuello de botella claro en esta etapa.';
      }
      if (locale === 'en') {
        return 'Your current progress does not show a clear blocker in this stage.';
      }
      return 'Seu progresso atual não mostra um bloqueio claro nessa etapa.';
    }

    if (locale === 'es') {
      return `Por tu progreso actual, el próximo punto práctico a mover es: ${nextItem}.`;
    }
    if (locale === 'en') {
      return `From your current progress, the next practical item to move is: ${nextItem}.`;
    }
    return `Pelo seu progresso atual, o próximo ponto prático para mover é: ${nextItem}.`;
  }

  private nextPendingItem(
    profile: CorridorGuidanceProfile,
    currentPhase: string | undefined,
    completedItemIds: string[],
    preferredPhases?: string[],
  ): string | null {
    const phases =
      preferredPhases ?? this.orderedPhasesFrom(profile, currentPhase);
    const completed = new Set(completedItemIds);

    for (const phase of phases) {
      const pending = profile.guideItems.find(
        (item) => item.phase === phase && !completed.has(item.id),
      );
      if (pending) {
        return pending.title;
      }
    }

    return profile.guideItems.find(
      (item) => !completed.has(item.id),
    )?.title ?? null;
  }

  private orderedPhasesFrom(
    profile: CorridorGuidanceProfile,
    currentPhase?: string,
  ): string[] {
    if (!currentPhase || !profile.phaseOrder.includes(currentPhase)) {
      return [...profile.phaseOrder];
    }

    const currentIndex = profile.phaseOrder.indexOf(currentPhase);
    return [
      ...profile.phaseOrder.slice(currentIndex),
      ...profile.phaseOrder.slice(0, currentIndex),
    ];
  }

  private unsupportedCorridorAnswer(
    locale: GuidanceLocale,
    originCountry: string,
    destinationCountry: string,
  ): string {
    const corridor = `${originCountry} -> ${destinationCountry}`;
    if (locale === 'es') {
      return `Todavía no hay respuestas guiadas sin IA para el corredor ${corridor}. Cuando este corredor tenga cobertura estructurada, estas preguntas rápidas también van a responderse de forma determinística.`;
    }
    if (locale === 'en') {
      return `There is no structured non-AI guidance yet for the ${corridor} corridor. Once this corridor has product coverage, these quick prompts will also resolve deterministically.`;
    }
    return `Ainda não existem respostas guiadas sem IA para o corredor ${corridor}. Quando esse corredor tiver cobertura estruturada no produto, essas perguntas rápidas também passarão a responder de forma determinística.`;
  }

  private genericQuickPromptLabel(locale: GuidanceLocale): string {
    if (locale === 'es') return 'Primer documento local';
    if (locale === 'en') return 'First local document';
    return 'Primeiro documento local';
  }

  private genericQuickPromptMessage(locale: GuidanceLocale): string {
    if (locale === 'es') {
      return '¿Cuál es el primer documento local que debería resolver al llegar?';
    }
    if (locale === 'en') {
      return 'What is the first local document I should sort out after arrival?';
    }
    return 'Qual é o primeiro documento local que eu deveria resolver ao chegar?';
  }
}
