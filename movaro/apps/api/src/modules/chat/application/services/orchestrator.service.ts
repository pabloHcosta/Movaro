import { Injectable, Logger } from '@nestjs/common';

import { ChatContextBuilderService } from './chat-context-builder.service';
import { GeminiFallbackService } from './gemini-fallback.service';
import { ChatIntent, IntentDetectorService } from './intent-detector.service';
import { CityResolverService } from './resolvers/city-resolver.service';
import { CostResolverService } from './resolvers/cost-resolver.service';
import { DocResolverService } from './resolvers/doc-resolver.service';
import { FaqResolverService } from './resolvers/faq-resolver.service';
import { AskChatDto } from '../../presentation/dto/ask-chat.dto';

export type AnswerSource = 'app_data' | 'ai';

export interface OrchestratorAnswer {
  answer: string;
  source: AnswerSource;
  intent: ChatIntent;
  confidence: number;
}

/** Minimum confidence to return a resolver answer without LLM fallback. */
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
    private readonly intentDetector: IntentDetectorService,
    private readonly cityResolver: CityResolverService,
    private readonly costResolver: CostResolverService,
    private readonly docResolver: DocResolverService,
    private readonly faqResolver: FaqResolverService,
    private readonly geminiFallback: GeminiFallbackService,
    private readonly chatContextBuilder: ChatContextBuilderService,
  ) {}

  async ask(dto: AskChatDto): Promise<OrchestratorAnswer> {
    const locale = dto.locale ?? 'pt';
    const { message, originCountry, destinationCountry } = dto;

    // ── Cache lookup ───────────────────────────────────────────────────────────
    const cacheKey = this.makeCacheKey(message, locale);
    const cached = this.getCached(cacheKey);
    if (cached) {
      this.logger.debug('[Orchestrator] cache hit ✓');
      return cached;
    }

    this.logger.debug(
      `[Orchestrator] ask: "${message.substring(0, 60)}" | locale=${locale}`,
    );

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
        const cityId = intent.entities['cityId'] ?? dto.recommendedCityId ?? null;
        const result = await this.cityResolver.resolve(cityId ?? undefined, locale);
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
        const result = this.docResolver.resolve(message, locale);
        if (result.confidence >= CONFIDENCE_THRESHOLD) {
          answer = result.summary;
          resolverConfidence = result.confidence;
        }
        break;
      }

      default:
        break;
    }

    // ── FAQ resolver: curated answers for general/plan/unmatched intents ───────
    if (!answer || resolverConfidence < CONFIDENCE_THRESHOLD) {
      const faq = this.faqResolver.resolve(message, locale);
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

    // ── LLM fallback (Groq → Gemini) ───────────────────────────────────────────
    this.logger.debug('[Orchestrator] falling back to LLM');

    let appDataBlock = '';
    try {
      const context = await this.chatContextBuilder.buildContext({
        originCountry,
        destinationCountry,
        locale,
        recommendedCityId: dto.recommendedCityId,
        currentPhase: dto.currentPhase,
        completedItemIds: dto.completedItemIds,
      });
      appDataBlock = context.appDataBlock;
    } catch {
      this.logger.warn('[Orchestrator] context build failed — proceeding without app data');
    }

    const llmResult = await this.geminiFallback.ask(message, {
      appDataBlock,
      originCountry,
      destinationCountry,
      locale,
      history: dto.history ?? [],
    });

    const result: OrchestratorAnswer = {
      answer: llmResult.text,
      source: 'ai',
      intent: intent.intent,
      confidence: 0.5,
    };

    this.putCache(cacheKey, result);
    return result;
  }

  // ── Cache helpers ─────────────────────────────────────────────────────────

  private makeCacheKey(message: string, locale: string): string {
    return `${locale}:${message.toLowerCase().trim().replace(/\s+/g, ' ')}`;
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
      const firstKey = this.cache.keys().next().value;
      if (firstKey) this.cache.delete(firstKey);
    }
    this.cache.set(key, { answer, expiresAt: Date.now() + CACHE_TTL_MS });
  }
}
