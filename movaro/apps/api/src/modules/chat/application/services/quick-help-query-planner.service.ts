import { Injectable } from '@nestjs/common';

import {
  QUICK_HELP_INTENTS,
  QuickHelpDecisionBranch,
  QuickHelpIntentDefinition,
} from '../../data/quick-help-intents.catalog';
import { QuickHelpLocale } from '../../data/quick-help-trust.catalog';
import { QuickGuideAnswersDto } from '../../presentation/dto/resolve-quick-guide.dto';

export interface QuickHelpIntentMatch {
  intent: QuickHelpIntentDefinition;
  score: number;
  lexicalScore: number;
  conceptScore: number;
  phraseMatched: boolean;
}

export interface QuickHelpQueryPlan {
  normalizedQuery: string;
  matches: QuickHelpIntentMatch[];
  compound: boolean;
  clarification: QuickHelpIntentDefinition['clarification'] | null;
  decisionBranch: QuickHelpDecisionBranch | null;
  strategy: 'hybrid_lexical_concept';
}

const STOP_WORDS = new Set([
  'a',
  'ao',
  'as',
  'como',
  'da',
  'de',
  'do',
  'e',
  'em',
  'eu',
  'me',
  'meu',
  'na',
  'no',
  'o',
  'os',
  'para',
  'por',
  'preciso',
  'que',
  'the',
  'to',
  'i',
  'my',
  'how',
  'what',
  'in',
  'for',
  'el',
  'la',
  'los',
  'las',
  'un',
  'una',
  'mi',
  'qué',
  'como',
]);

const UNSUPPORTED_QUERY_PATTERNS = [
  /\bmelhor banco\b/,
  /\bmejor banco\b/,
  /\bbest bank\b/,
  /\brecomenda(?:r|cao)? banco\b/,
  /\brecomenda(?:r|cion)? un banco\b/,
  /\brecommend (?:a )?bank\b/,
];

@Injectable()
export class QuickHelpQueryPlannerService {
  plan(
    message: string,
    locale: QuickHelpLocale,
    answers: QuickGuideAnswersDto = {},
  ): QuickHelpQueryPlan {
    const normalizedQuery = this.normalize(message);
    const forcedIntent = this.intentSelectedByAnswer(answers);
    const unsupportedAnswerShape = UNSUPPORTED_QUERY_PATTERNS.some((pattern) =>
      pattern.test(normalizedQuery),
    );
    const ranked = forcedIntent
      ? [this.forcedMatch(forcedIntent)]
      : unsupportedAnswerShape
        ? []
        : QUICK_HELP_INTENTS.map((intent) =>
            this.scoreIntent(normalizedQuery, intent, locale),
          )
            .filter((match) => match.score >= 2.2)
            .sort(
              (a, b) =>
                b.score - a.score || b.intent.priority - a.intent.priority,
            );
    const matches = this.selectMatches(
      this.preferSpecificIntent(ranked),
      normalizedQuery,
    );
    const primary = matches[0]?.intent;
    const clarification =
      primary?.clarification &&
      !this.answerFor(primary.clarification.contextKey, answers)
        ? primary.clarification
        : null;
    const decisionBranch = primary
      ? this.resolveDecisionBranch(primary, answers)
      : null;

    return {
      normalizedQuery,
      matches,
      compound: matches.length > 1,
      clarification,
      decisionBranch,
      strategy: 'hybrid_lexical_concept',
    };
  }

  private scoreIntent(
    normalizedQuery: string,
    intent: QuickHelpIntentDefinition,
    locale: QuickHelpLocale,
  ): QuickHelpIntentMatch {
    const queryTokens = this.tokens(normalizedQuery);
    const aliases = [
      ...intent.aliases[locale],
      ...intent.aliases.pt,
      ...intent.aliases.es,
      ...intent.aliases.en,
    ].map((alias) => this.normalize(alias));
    let lexicalScore = 0;
    let phraseMatched = false;

    for (const alias of new Set(aliases)) {
      const aliasTokens = this.tokens(alias);
      const isMeaningfulPhrase =
        aliasTokens.length >= 2 || normalizedQuery === alias;
      if (isMeaningfulPhrase && normalizedQuery.includes(alias)) {
        phraseMatched = true;
        lexicalScore = Math.max(
          lexicalScore,
          5 + Math.min(alias.length, 40) * 0.04,
        );
      }
      const overlap = aliasTokens.filter((token) =>
        queryTokens.includes(token),
      );
      if (overlap.length > 0) {
        const precision = overlap.length / Math.max(aliasTokens.length, 1);
        const recall = overlap.length / Math.max(queryTokens.length, 1);
        lexicalScore = Math.max(
          lexicalScore,
          overlap.length * 1.15 + precision * 1.4 + recall * 0.5,
        );
      }
    }

    let conceptScore = 0;
    for (const conceptGroup of intent.concepts) {
      const matched = conceptGroup.some((term) =>
        normalizedQuery.includes(this.normalize(term)),
      );
      if (matched) conceptScore += 2.1;
    }
    const negativePenalty =
      (intent.negativeAliases?.some((alias) =>
        normalizedQuery.includes(this.normalize(alias)),
      ) ?? false)
        ? 7
        : 0;

    return {
      intent,
      lexicalScore,
      conceptScore,
      phraseMatched,
      score:
        lexicalScore + conceptScore + intent.priority * 0.001 - negativePenalty,
    };
  }

  private selectMatches(
    ranked: QuickHelpIntentMatch[],
    normalizedQuery: string,
  ) {
    const first = ranked[0];
    if (!first) return [];
    const selected = [first];
    const questionCount = [...normalizedQuery].filter(
      (character) => character === '?',
    ).length;
    const compoundSignal =
      /[;\n]/.test(normalizedQuery) ||
      questionCount > 1 ||
      /\b(tambem|también|also|e preciso|y necesito|and i (?:also )?need)\b/.test(
        normalizedQuery,
      );

    if (!compoundSignal) return selected;
    for (const candidate of ranked.slice(1)) {
      if (selected.length >= 3) break;
      if (candidate.intent.id === first.intent.id) continue;
      const sameTopicMatch = selected.find(
        (match) => match.intent.topic === candidate.intent.topic,
      );
      const strongEnough = candidate.phraseMatched
        ? candidate.score >= 4.5
        : candidate.score >= Math.max(3.2, first.score * 0.48);
      if (!strongEnough) continue;
      if (
        sameTopicMatch &&
        (!candidate.phraseMatched || !sameTopicMatch.phraseMatched)
      ) {
        continue;
      }
      if (
        selected.some(
          (match) =>
            match.intent.topic === candidate.intent.topic &&
            match.intent.id === candidate.intent.id,
        )
      ) {
        continue;
      }
      selected.push(candidate);
    }
    return selected;
  }

  private intentSelectedByAnswer(answers: QuickGuideAnswersDto) {
    if (answers.residenceBasis) {
      return QUICK_HELP_INTENTS.find(
        (item) => item.id === 'documents.residence_authorization',
      );
    }
    if (answers.drivingGoal) {
      return QUICK_HELP_INTENTS.find(
        (item) => item.id === 'driving.foreign_licence',
      );
    }
    for (const intent of QUICK_HELP_INTENTS) {
      const clarification = intent.clarification;
      if (!clarification) continue;
      const value = this.answerFor(clarification.contextKey, answers);
      const target = clarification.options.find(
        (option) => option.value === value,
      )?.targetIntentId;
      if (target) return QUICK_HELP_INTENTS.find((item) => item.id === target);
    }
    return undefined;
  }

  private preferSpecificIntent(ranked: QuickHelpIntentMatch[]) {
    const first = ranked[0];
    if (!first?.intent.id.endsWith('.overview')) return ranked;
    const specific = ranked.find(
      (candidate) =>
        candidate.intent.topic === first.intent.topic &&
        !candidate.intent.id.endsWith('.overview') &&
        candidate.score >= first.score - 3,
    );
    if (!specific) return ranked;
    return [specific, ...ranked.filter((candidate) => candidate !== specific)];
  }

  private forcedMatch(intent: QuickHelpIntentDefinition): QuickHelpIntentMatch {
    return {
      intent,
      score: 100,
      lexicalScore: 100,
      conceptScore: 0,
      phraseMatched: true,
    };
  }

  private resolveDecisionBranch(
    intent: QuickHelpIntentDefinition,
    answers: QuickGuideAnswersDto,
  ) {
    if (!intent.decisionContextKey || !intent.decisionBranches) return null;
    const value = this.answerFor(intent.decisionContextKey, answers);
    return (
      intent.decisionBranches.find((branch) => branch.value === value) ?? null
    );
  }

  private answerFor(key: string, answers: QuickGuideAnswersDto) {
    const value = (answers as Record<string, string | undefined>)[key];
    return typeof value === 'string' && value.trim().length > 0
      ? value.trim()
      : undefined;
  }

  private tokens(value: string) {
    return value
      .split(/[^a-z0-9]+/)
      .filter((token) => token.length > 1 && !STOP_WORDS.has(token));
  }

  private normalize(value: string) {
    return value
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/[^a-z0-9\s?;\n]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  }
}
