import { Injectable, Logger } from '@nestjs/common';

import { ChatContextBuilderService } from './chat-context-builder.service';
import { GeminiFallbackService } from './gemini-fallback.service';
import {
  ChatIntent,
  IntentDetectorService,
} from './intent-detector.service';
import { CityResolverService } from './resolvers/city-resolver.service';
import { CostResolverService } from './resolvers/cost-resolver.service';
import { DocResolverService } from './resolvers/doc-resolver.service';
import { AskChatDto } from '../../presentation/dto/ask-chat.dto';

export type AnswerSource = 'app_data' | 'ai';

export interface OrchestratorAnswer {
  answer: string;
  source: AnswerSource;
  intent: ChatIntent;
  confidence: number;
}

/** Minimum confidence to return a resolver answer without Gemini fallback. */
const CONFIDENCE_THRESHOLD = 0.65;

@Injectable()
export class OrchestratorService {
  private readonly logger = new Logger(OrchestratorService.name);

  constructor(
    private readonly intentDetector: IntentDetectorService,
    private readonly cityResolver: CityResolverService,
    private readonly costResolver: CostResolverService,
    private readonly docResolver: DocResolverService,
    private readonly geminiFallback: GeminiFallbackService,
    private readonly chatContextBuilder: ChatContextBuilderService,
  ) {}

  async ask(dto: AskChatDto): Promise<OrchestratorAnswer> {
    const locale = dto.locale ?? 'pt';
    const { message, originCountry, destinationCountry } = dto;

    this.logger.debug(
      `[Orchestrator] ask: "${message.substring(0, 60)}" | locale=${locale}`,
    );

    // ── Intent detection ───────────────────────────────────────────────────────
    const intent = this.intentDetector.detect(message);
    this.logger.debug(
      `[Orchestrator] intent=${intent.intent} confidence=${intent.confidence.toFixed(2)}`,
    );

    // ── Route to resolver ──────────────────────────────────────────────────────
    let answer: string | null = null;
    let resolverConfidence = 0;

    switch (intent.intent) {
      case 'city_info': {
        const cityId =
          intent.entities['cityId'] ?? dto.recommendedCityId ?? null;
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

      case 'plan':
      case 'general':
      default:
        // Fall through to Gemini
        break;
    }

    // ── Return resolver answer if confident ────────────────────────────────────
    if (answer && resolverConfidence >= CONFIDENCE_THRESHOLD) {
      this.logger.debug(
        `[Orchestrator] resolver answered (confidence=${resolverConfidence.toFixed(2)})`,
      );
      return {
        answer,
        source: 'app_data',
        intent: intent.intent,
        confidence: resolverConfidence,
      };
    }

    // ── Gemini fallback ────────────────────────────────────────────────────────
    this.logger.debug('[Orchestrator] falling back to Gemini');

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

    const geminiResult = await this.geminiFallback.ask(message, {
      appDataBlock,
      originCountry,
      destinationCountry,
      locale,
      history: dto.history ?? [],
    });

    return {
      answer: geminiResult.text,
      source: 'ai',
      intent: intent.intent,
      confidence: 0.5,
    };
  }
}
