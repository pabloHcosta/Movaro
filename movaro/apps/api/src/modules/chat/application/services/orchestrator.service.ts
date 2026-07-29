import { Injectable, Logger } from '@nestjs/common';

import { AssistantLanguageService } from './assistant-language.service';
import { ChatIntent, IntentDetectorService } from './intent-detector.service';
import { CityResolverService } from './resolvers/city-resolver.service';
import { CorridorGuidanceResolverService } from './resolvers/corridor-guidance-resolver.service';
import { CostResolverService } from './resolvers/cost-resolver.service';
import { DocResolverService } from './resolvers/doc-resolver.service';
import { FaqResolverService } from './resolvers/faq-resolver.service';
import { GuideAnswersService } from './guide-answers.service';
import { AskChatDto } from '../../presentation/dto/ask-chat.dto';

export type AnswerSource = 'app_data' | 'ai';

export interface OrchestratorAnswer {
  answer: string;
  source: AnswerSource;
  intent: ChatIntent;
  confidence: number;
  provider?: string;
}

/** Minimum confidence to return a structured resolver answer. */
const CONFIDENCE_THRESHOLD = 0.65;

interface CacheEntry {
  answer: OrchestratorAnswer;
  expiresAt: number;
}

const CACHE_TTL_MS = 30 * 60 * 1000; // 30 minutes
const MAX_CACHE_ENTRIES = 200;

@Injectable()
export class OrchestratorService {
  private readonly logger = new Logger(OrchestratorService.name);
  private readonly cache = new Map<string, CacheEntry>();

  constructor(
    private readonly assistantLanguageService: AssistantLanguageService,
    private readonly intentDetector: IntentDetectorService,
    private readonly cityResolver: CityResolverService,
    private readonly corridorGuidanceResolver: CorridorGuidanceResolverService,
    private readonly costResolver: CostResolverService,
    private readonly docResolver: DocResolverService,
    private readonly guideAnswersService: GuideAnswersService,
    private readonly faqResolver: FaqResolverService,
  ) {}

  async ask(dto: AskChatDto): Promise<OrchestratorAnswer> {
    const { message, originCountry, destinationCountry } = dto;
    const locale = await this.assistantLanguageService.detectResponseLocale(
      message,
      dto.locale,
    );

    // ── Cache lookup ───────────────────────────────────────────────────────────
    const cacheKey = this.makeCacheKey(
      message,
      locale,
      originCountry,
      destinationCountry,
      dto.highlightedCityId,
      dto.currentPhase,
      dto.migrationGoal,
      dto.planTimeline,
      dto.completedItemIds ?? [],
    );
    const cached = this.getCached(cacheKey);
    if (cached) {
      this.logger.debug('[Orchestrator] cache hit ✓');
      return cached;
    }

    this.logger.debug(
      `[Orchestrator] ask: "${message.substring(0, 60)}" | locale=${locale}`,
    );

    const initialCorridorGuidance = await this.corridorGuidanceResolver.resolve(
      {
        ...dto,
        locale,
      },
    );
    if (
      initialCorridorGuidance.found &&
      initialCorridorGuidance.topic &&
      (this.corridorGuidanceResolver.isExactQuickPrompt(message) ||
        initialCorridorGuidance.topic === 'next_step')
    ) {
      const result: OrchestratorAnswer = {
        answer: initialCorridorGuidance.answer,
        source: 'app_data',
        intent: 'general',
        confidence: initialCorridorGuidance.confidence,
      };
      this.putCache(cacheKey, result);
      return result;
    }

    // ── Intent detection ───────────────────────────────────────────────────────
    const intent = this.intentDetector.detect(message);
    this.logger.debug(
      `[Orchestrator] intent=${intent.intent} confidence=${intent.confidence.toFixed(2)}`,
    );

    // ── Structured resolvers (city, cost, documents) ───────────────────────────
    let answer: string | null = null;
    let resolverConfidence = 0;

    switch (intent.intent) {
      case 'city_info': {
        const cityId =
          intent.entities['cityId'] ?? dto.highlightedCityId ?? null;
        const result = await this.cityResolver.resolve(
          cityId ?? undefined,
          locale,
        );
        if (result.found && result.confidence >= CONFIDENCE_THRESHOLD) {
          answer = result.summary ?? null;
          resolverConfidence = result.confidence;
        }
        break;
      }

      case 'cost': {
        const result = await this.costResolver.resolve(locale);
        if (result.confidence >= CONFIDENCE_THRESHOLD) {
          answer = result.summary;
          resolverConfidence = result.confidence;
        }
        break;
      }

      case 'documents': {
        const result = await this.docResolver.resolve(
          message,
          locale,
          originCountry,
          destinationCountry,
        );
        if (result.confidence >= CONFIDENCE_THRESHOLD) {
          answer = result.summary;
          resolverConfidence = result.confidence;
        }
        break;
      }

      default:
        break;
    }

    // ── Deterministic corridor guidance for quick chat prompts ────────────────
    if (!answer || resolverConfidence < CONFIDENCE_THRESHOLD) {
      const corridorGuidance = await this.corridorGuidanceResolver.resolve(dto);
      if (
        corridorGuidance.found &&
        corridorGuidance.confidence >= CONFIDENCE_THRESHOLD
      ) {
        answer = corridorGuidance.answer;
        resolverConfidence = corridorGuidance.confidence;
        this.logger.debug(
          `[Orchestrator] corridor guidance answered (confidence=${corridorGuidance.confidence.toFixed(2)})`,
        );
      }
    }

    // ── Guide answers: same curated knowledge exposed in the guide UI ─────────
    if (!answer || resolverConfidence < CONFIDENCE_THRESHOLD) {
      const guideAnswer = await this.guideAnswersService.resolve({
        message,
        destinationCountry,
        originCountry,
        locale,
      });
      if (guideAnswer.found && guideAnswer.confidence >= CONFIDENCE_THRESHOLD) {
        answer = guideAnswer.answer;
        resolverConfidence = guideAnswer.confidence;
        this.logger.debug(
          `[Orchestrator] guide answers resolved (confidence=${guideAnswer.confidence.toFixed(2)})`,
        );
      }
    }

    // ── FAQ resolver: curated answers for general/plan/unmatched intents ───────
    if (!answer || resolverConfidence < CONFIDENCE_THRESHOLD) {
      const faq = await this.faqResolver.resolve(
        message,
        locale,
        originCountry,
        destinationCountry,
      );
      if (faq.found && faq.confidence >= CONFIDENCE_THRESHOLD) {
        answer = faq.answer;
        resolverConfidence = faq.confidence;
        this.logger.debug(
          `[Orchestrator] FAQ resolver answered (confidence=${faq.confidence.toFixed(2)})`,
        );
      }
    }

    // ── Return structured answer if confident ──────────────────────────────────
    if (answer && resolverConfidence >= CONFIDENCE_THRESHOLD) {
      const result: OrchestratorAnswer = {
        answer,
        source: 'app_data',
        intent: intent.intent,
        confidence: resolverConfidence,
      };
      this.putCache(cacheKey, result);
      return result;
    }

    // ── Deterministic fallback ─────────────────────────────────────────────────
    // Migration, legal, health, and tax guidance must not be improvised by an
    // LLM. When no reviewed resolver matches, return a safe navigation answer.
    this.logger.debug('[Orchestrator] no reviewed resolver match');
    const fallbackByLocale: Record<string, string> = {
      es: 'No encontré una respuesta revisada para esa pregunta. Abrí Guías y elegí residencia, documentos, vivienda, salud, dinero, impuestos, familia, mascotas o medicamentos. Para una decisión legal, médica o fiscal, confirmá la fuente oficial o consultá a un profesional.',
      pt: 'Não encontrei uma resposta revisada para essa pergunta. Abra Guias e escolha residência, documentos, moradia, saúde, dinheiro, impostos, família, pets ou medicamentos. Para uma decisão jurídica, médica ou fiscal, confirme a fonte oficial ou consulte um profissional.',
      en: 'I did not find a reviewed answer for that question. Open Guides and choose residence, documents, housing, health, money, taxes, family, pets, or medicines. For legal, medical, or tax decisions, confirm the official source or consult a professional.',
    };
    const result: OrchestratorAnswer = {
      answer: fallbackByLocale[locale] ?? fallbackByLocale.en,
      source: 'app_data',
      intent: intent.intent,
      confidence: 0.25,
    };

    this.putCache(cacheKey, result);
    return result;
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────

  private makeCacheKey(
    message: string,
    locale: string,
    originCountry: string,
    destinationCountry: string,
    highlightedCityId?: string,
    currentPhase?: string,
    migrationGoal?: string,
    planTimeline?: string,
    completedItemIds: string[] = [],
  ): string {
    return [
      locale,
      originCountry.toLowerCase().trim(),
      destinationCountry.toLowerCase().trim(),
      highlightedCityId?.toLowerCase().trim() ?? '-',
      currentPhase?.toLowerCase().trim() ?? '-',
      migrationGoal?.toLowerCase().trim() ?? '-',
      planTimeline?.toLowerCase().trim() ?? '-',
      [...completedItemIds].sort().join(',') || '-',
      message.toLowerCase().trim().replace(/\s+/g, ' '),
    ].join(':');
  }

  private getCached(key: string): OrchestratorAnswer | null {
    const entry = this.cache.get(key);
    if (!entry) return null;
    if (Date.now() > entry.expiresAt) {
      this.cache.delete(key);
      return null;
    }
    return entry.answer;
  }

  private putCache(key: string, answer: OrchestratorAnswer): void {
    if (this.cache.size >= MAX_CACHE_ENTRIES) {
      // eslint-disable-next-line @typescript-eslint/no-unsafe-assignment
      const firstKey = this.cache.keys().next().value;
      // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
      if (firstKey) this.cache.delete(firstKey);
    }
    this.cache.set(key, { answer, expiresAt: Date.now() + CACHE_TTL_MS });
  }
}
