import { Injectable, Logger } from '@nestjs/common';

import { SupabaseAdminService } from '../../../../common/supabase/supabase-admin.service';

type SupportedLocale = 'pt' | 'es' | 'en';

interface AssistantLanguageRuleRecord {
  language_code: SupportedLocale;
  priority: number;
  keyword_patterns: string[] | null;
  regex_patterns: string[] | null;
  fallback_language_code: SupportedLocale;
}

interface AssistantFaqEntryRecord {
  id: string;
  corridor_key: string | null;
  priority: number;
  answer_pt: string | null;
  answer_es: string | null;
  answer_en: string | null;
  answer_default: string | null;
}

interface AssistantFaqKeywordRecord {
  entry_id: string;
  language_code: SupportedLocale | null;
  keyword: string;
  weight: number;
}

interface AssistantDocumentEntryRecord {
  document_code: string;
  corridor_key: string | null;
  priority: number;
  phase: string | null;
  title_pt: string | null;
  title_es: string | null;
  title_en: string | null;
  summary_pt: string | null;
  summary_es: string | null;
  summary_en: string | null;
  notes_pt: string | null;
  notes_es: string | null;
  notes_en: string | null;
}

interface AssistantDocumentKeywordRecord {
  entry_id: string;
  language_code: SupportedLocale | null;
  keyword: string;
  weight: number;
}

interface AssistantQuickPromptRecord {
  corridor_key: string | null;
  prompt_key: string;
  label_pt: string | null;
  label_es: string | null;
  label_en: string | null;
  message_pt: string | null;
  message_es: string | null;
  message_en: string | null;
  message_default: string | null;
}

interface AssistantGuideAnswerRecord {
  corridor_key: string | null;
  destination_country: string | null;
  section: string;
  priority: number;
  question_pt: string | null;
  question_es: string | null;
  question_en: string | null;
  answer_pt: string | null;
  answer_es: string | null;
  answer_en: string | null;
  keywords: Record<string, string[]> | null;
}

interface LanguageRule {
  languageCode: SupportedLocale;
  priority: number;
  keywordPatterns: string[];
  regexPatterns: string[];
  fallbackLanguageCode: SupportedLocale;
}

interface AssistantFaqEntry {
  id: string;
  corridorKey: string | null;
  priority: number;
  answers: Partial<Record<SupportedLocale, string>>;
  answerDefault: string | null;
  keywords: Array<{
    languageCode: SupportedLocale | null;
    keyword: string;
    weight: number;
  }>;
}

interface AssistantDocumentEntry {
  documentCode: string;
  corridorKey: string | null;
  priority: number;
  phase: string | null;
  titles: Partial<Record<SupportedLocale, string>>;
  summaries: Partial<Record<SupportedLocale, string>>;
  notes: Partial<Record<SupportedLocale, string>>;
  keywords: Array<{
    languageCode: SupportedLocale | null;
    keyword: string;
    weight: number;
  }>;
}

interface AssistantQuickPromptTemplate {
  corridorKey: string | null;
  promptKey: string;
  labels: Partial<Record<SupportedLocale, string>>;
  messages: Partial<Record<SupportedLocale, string>>;
  messageDefault: string | null;
}

interface AssistantGuideAnswer {
  corridorKey: string | null;
  destinationCountry: string | null;
  section: string;
  priority: number;
  questions: Partial<Record<SupportedLocale, string>>;
  answers: Partial<Record<SupportedLocale, string>>;
  keywords: Record<string, string[]>;
}

const CACHE_TTL_MS = 5 * 60 * 1000;

const STATIC_LANGUAGE_RULES: LanguageRule[] = [
  {
    languageCode: 'pt',
    priority: 300,
    keywordPatterns: [
      'como',
      'quais',
      'quanto',
      'preciso',
      'documentos',
      'moradia',
      'trabalho',
      'cidade',
      'visto',
      'cpf',
      'não',
      'quero',
    ],
    regexPatterns: ['\\b(voc[eê]|vocês|pra|não|quão|moradia|alugu[eé]l)\\b'],
    fallbackLanguageCode: 'en',
  },
  {
    languageCode: 'es',
    priority: 300,
    keywordPatterns: [
      'como',
      'cuáles',
      'cuanto',
      'necesito',
      'documentos',
      'vivienda',
      'trabajo',
      'ciudad',
      'visa',
      'residencia',
      'quiero',
    ],
    regexPatterns: ['\\b(necesit[oá]s|quer[eé]s|vivienda|alquiler|cu[aá]l|cu[aá]nto)\\b'],
    fallbackLanguageCode: 'en',
  },
  {
    languageCode: 'en',
    priority: 250,
    keywordPatterns: [
      'how',
      'what',
      'which',
      'need',
      'documents',
      'housing',
      'work',
      'city',
      'visa',
      'cost',
      'move',
      'rent',
      'job',
    ],
    regexPatterns: ['\\b(how|what|which|where|need|housing|documents|move|rent|job)\\b'],
    fallbackLanguageCode: 'en',
  },
];

@Injectable()
export class AssistantKnowledgeService {
  private readonly logger = new Logger(AssistantKnowledgeService.name);

  private languageRulesCache:
    | { expiresAt: number; value: LanguageRule[] }
    | null = null;

  private faqEntriesCache:
    | { expiresAt: number; value: AssistantFaqEntry[] }
    | null = null;

  private documentEntriesCache:
    | { expiresAt: number; value: AssistantDocumentEntry[] }
    | null = null;

  private quickPromptTemplatesCache:
    | { expiresAt: number; value: AssistantQuickPromptTemplate[] }
    | null = null;

  private guideAnswersCache:
    | { expiresAt: number; value: AssistantGuideAnswer[] }
    | null = null;

  constructor(private readonly supabaseAdminService: SupabaseAdminService) {}

  async detectLanguage(
    message: string,
    requestedLocale?: string,
  ): Promise<SupportedLocale> {
    const normalizedMessage = message.toLowerCase();
    const rules = await this.getLanguageRules();

    let bestLanguage: SupportedLocale | null = null;
    let bestScore = 0;

    for (const rule of rules) {
      let score = 0;
      for (const keyword of rule.keywordPatterns) {
        if (normalizedMessage.includes(keyword)) {
          score += keyword.length * 0.12;
        }
      }
      for (const regexPattern of rule.regexPatterns) {
        const regex = new RegExp(regexPattern, 'i');
        if (regex.test(message)) {
          score += 1.4;
        }
      }
      score += rule.priority * 0.001;

      if (score > bestScore) {
        bestScore = score;
        bestLanguage = rule.languageCode;
      }
    }

    if (bestLanguage && bestScore >= 1) {
      return bestLanguage;
    }

    const tokenCount = message
      .trim()
      .split(/\s+/)
      .filter((token) => token.length > 0).length;

    if (
      tokenCount <= 2 &&
      (requestedLocale === 'pt' || requestedLocale === 'es' || requestedLocale === 'en')
    ) {
      return requestedLocale;
    }

    return 'en';
  }

  async resolveFaq(
    message: string,
    locale: SupportedLocale,
    corridorKey: string,
  ): Promise<{ found: boolean; confidence: number; answer: string }> {
    const entries = await this.getFaqEntries();
    if (entries.length === 0) {
      return { found: false, confidence: 0, answer: '' };
    }

    const normalizedMessage = message.toLowerCase();
    let bestEntry: AssistantFaqEntry | null = null;
    let bestScore = 0;

    for (const entry of entries) {
      if (entry.corridorKey && entry.corridorKey !== corridorKey) {
        continue;
      }

      let score = entry.priority * 0.002;
      for (const keyword of entry.keywords) {
        if (keyword.languageCode && keyword.languageCode !== locale) {
          continue;
        }
        if (normalizedMessage.includes(keyword.keyword.toLowerCase())) {
          score += keyword.weight;
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestEntry = entry;
      }
    }

    if (!bestEntry || bestScore < 1.1) {
      return { found: false, confidence: 0, answer: '' };
    }

    const answer =
      bestEntry.answers[locale] ??
      bestEntry.answers.en ??
      bestEntry.answerDefault ??
      '';

    if (!answer) {
      return { found: false, confidence: 0, answer: '' };
    }

    return {
      found: true,
      confidence: Math.min(0.92, 0.62 + bestScore * 0.08),
      answer,
    };
  }

  async resolveDocuments(
    message: string,
    locale: SupportedLocale,
    corridorKey: string,
  ): Promise<
    Array<{
      id: string;
      phase: string | null;
      title: string;
      summary: string;
      notes?: string;
    }>
  > {
    const entries = await this.getDocumentEntries();
    if (entries.length === 0) {
      return [];
    }

    const normalizedMessage = message.toLowerCase();
    const matched = entries
      .filter((entry) => !entry.corridorKey || entry.corridorKey === corridorKey)
      .map((entry) => {
        let score = entry.priority * 0.002;
        for (const keyword of entry.keywords) {
          if (keyword.languageCode && keyword.languageCode !== locale) {
            continue;
          }
          if (normalizedMessage.includes(keyword.keyword.toLowerCase())) {
            score += keyword.weight;
          }
        }
        return { entry, score };
      })
      .filter((item) => item.score >= 1)
      .sort((a, b) => b.score - a.score)
      .slice(0, 4)
      .map(({ entry }) => ({
        id: entry.documentCode,
        phase: entry.phase,
        title:
          entry.titles[locale] ?? entry.titles.en ?? entry.documentCode,
        summary:
          entry.summaries[locale] ?? entry.summaries.en ?? '',
        ...(entry.notes[locale] || entry.notes.en
          ? {
              notes:
                entry.notes[locale] ?? entry.notes.en ?? undefined,
            }
          : {}),
      }))
      .filter((item) => item.summary.length > 0);

    return matched;
  }

  async getQuickPromptTemplate(
    promptKey: string,
    locale: SupportedLocale,
    corridorKey?: string,
  ): Promise<{ label: string; message: string } | null> {
    const templates = await this.getQuickPromptTemplates();
    const exact =
      templates.find(
        (template) =>
          template.promptKey === promptKey &&
          template.corridorKey === corridorKey,
      ) ??
      templates.find(
        (template) =>
          template.promptKey === promptKey && template.corridorKey == null,
      );

    if (!exact) {
      return null;
    }

    const label = exact.labels[locale] ?? exact.labels.en ?? null;
    const message =
      exact.messages[locale] ??
      exact.messages.en ??
      exact.messageDefault ??
      null;

    if (!label || !message) {
      return null;
    }

    return { label, message };
  }

  async getGuideAnswers(
    locale: SupportedLocale,
    destinationCountry: string,
    corridorKey?: string,
  ): Promise<
    Array<{
      section: string;
      question: string;
      answer: string;
      keywords: string[];
    }>
  > {
    const entries = await this.getGuideAnswersCache();
    if (entries.length === 0) {
      return [];
    }

    const normalizedDestination = destinationCountry.toLowerCase().trim();

    return entries
      .filter((entry) => {
        const destinationMatches =
          !entry.destinationCountry ||
          entry.destinationCountry.toLowerCase().trim() === normalizedDestination;
        const corridorMatches =
          !entry.corridorKey || entry.corridorKey === corridorKey;
        return destinationMatches && corridorMatches;
      })
      .sort((a, b) => b.priority - a.priority)
      .map((entry) => ({
        section: entry.section,
        question:
          entry.questions[locale] ?? entry.questions.en ?? '',
        answer:
          entry.answers[locale] ?? entry.answers.en ?? '',
        keywords: entry.keywords[locale] ?? entry.keywords.en ?? [],
      }))
      .filter((entry) => entry.question.length > 0 && entry.answer.length > 0);
  }

  private async getLanguageRules(): Promise<LanguageRule[]> {
    const cached = this.languageRulesCache;
    if (cached && cached.expiresAt > Date.now()) {
      return cached.value;
    }

    const fallback = STATIC_LANGUAGE_RULES;
    if (!this.supabaseAdminService.isConfigured) {
      return fallback;
    }

    try {
      const { data, error } = await this.supabaseAdminService.admin
        .from('assistant_language_rules')
        .select(
          'language_code, priority, keyword_patterns, regex_patterns, fallback_language_code',
        )
        .eq('is_active', true)
        .order('priority', { ascending: false });

      if (error || !data || data.length === 0) {
        return fallback;
      }

      const rules = (data as AssistantLanguageRuleRecord[]).map((row) => ({
        languageCode: row.language_code,
        priority: row.priority,
        keywordPatterns: row.keyword_patterns ?? [],
        regexPatterns: row.regex_patterns ?? [],
        fallbackLanguageCode: row.fallback_language_code,
      }));

      this.languageRulesCache = {
        expiresAt: Date.now() + CACHE_TTL_MS,
        value: rules,
      };

      return rules;
    } catch (error) {
      this.logger.warn(`Assistant language rules fallback enabled: ${String(error)}`);
      return fallback;
    }
  }

  private async getFaqEntries(): Promise<AssistantFaqEntry[]> {
    const cached = this.faqEntriesCache;
    if (cached && cached.expiresAt > Date.now()) {
      return cached.value;
    }

    if (!this.supabaseAdminService.isConfigured) {
      return [];
    }

    try {
      const [entriesResult, keywordsResult] = await Promise.all([
        this.supabaseAdminService.admin
          .from('assistant_faq_entries')
          .select(
            'id, corridor_key, priority, answer_pt, answer_es, answer_en, answer_default',
          )
          .eq('status', 'published')
          .order('priority', { ascending: false }),
        this.supabaseAdminService.admin
          .from('assistant_faq_keywords')
          .select('entry_id, language_code, keyword, weight'),
      ]);

      if (entriesResult.error || keywordsResult.error || !entriesResult.data) {
        return [];
      }

      const keywordsByEntry = new Map<string, AssistantFaqKeywordRecord[]>();
      for (const keyword of (keywordsResult.data ?? []) as AssistantFaqKeywordRecord[]) {
        const current = keywordsByEntry.get(keyword.entry_id) ?? [];
        current.push(keyword);
        keywordsByEntry.set(keyword.entry_id, current);
      }

      const entries = (entriesResult.data as AssistantFaqEntryRecord[]).map((row) => ({
        id: row.id,
        corridorKey: row.corridor_key,
        priority: row.priority,
        answers: {
          ...(row.answer_pt ? { pt: row.answer_pt } : {}),
          ...(row.answer_es ? { es: row.answer_es } : {}),
          ...(row.answer_en ? { en: row.answer_en } : {}),
        },
        answerDefault: row.answer_default,
        keywords: (keywordsByEntry.get(row.id) ?? []).map((keyword) => ({
          languageCode: keyword.language_code,
          keyword: keyword.keyword,
          weight: Number(keyword.weight ?? 1),
        })),
      }));

      this.faqEntriesCache = {
        expiresAt: Date.now() + CACHE_TTL_MS,
        value: entries,
      };

      return entries;
    } catch (error) {
      this.logger.warn(`Assistant FAQ fallback enabled: ${String(error)}`);
      return [];
    }
  }

  private async getDocumentEntries(): Promise<AssistantDocumentEntry[]> {
    const cached = this.documentEntriesCache;
    if (cached && cached.expiresAt > Date.now()) {
      return cached.value;
    }

    if (!this.supabaseAdminService.isConfigured) {
      return [];
    }

    try {
      const [entriesResult, keywordsResult] = await Promise.all([
        this.supabaseAdminService.admin
          .from('assistant_document_entries')
          .select(
            'id, document_code, corridor_key, priority, phase, title_pt, title_es, title_en, summary_pt, summary_es, summary_en, notes_pt, notes_es, notes_en',
          )
          .eq('status', 'published')
          .order('priority', { ascending: false }),
        this.supabaseAdminService.admin
          .from('assistant_document_keywords')
          .select('entry_id, language_code, keyword, weight'),
      ]);

      if (entriesResult.error || keywordsResult.error || !entriesResult.data) {
        return [];
      }

      const keywordsByEntry = new Map<string, AssistantDocumentKeywordRecord[]>();
      for (const keyword of (keywordsResult.data ?? []) as AssistantDocumentKeywordRecord[]) {
        const current = keywordsByEntry.get(keyword.entry_id) ?? [];
        current.push(keyword);
        keywordsByEntry.set(keyword.entry_id, current);
      }

      const entries = (
        entriesResult.data as (AssistantDocumentEntryRecord & { id: string })[]
      ).map((row) => ({
        documentCode: row.document_code,
        corridorKey: row.corridor_key,
        priority: row.priority,
        phase: row.phase,
        titles: {
          ...(row.title_pt ? { pt: row.title_pt } : {}),
          ...(row.title_es ? { es: row.title_es } : {}),
          ...(row.title_en ? { en: row.title_en } : {}),
        },
        summaries: {
          ...(row.summary_pt ? { pt: row.summary_pt } : {}),
          ...(row.summary_es ? { es: row.summary_es } : {}),
          ...(row.summary_en ? { en: row.summary_en } : {}),
        },
        notes: {
          ...(row.notes_pt ? { pt: row.notes_pt } : {}),
          ...(row.notes_es ? { es: row.notes_es } : {}),
          ...(row.notes_en ? { en: row.notes_en } : {}),
        },
        keywords: (keywordsByEntry.get(row.id) ?? []).map((keyword) => ({
          languageCode: keyword.language_code,
          keyword: keyword.keyword,
          weight: Number(keyword.weight ?? 1),
        })),
      }));

      this.documentEntriesCache = {
        expiresAt: Date.now() + CACHE_TTL_MS,
        value: entries,
      };

      return entries;
    } catch (error) {
      this.logger.warn(`Assistant document knowledge fallback enabled: ${String(error)}`);
      return [];
    }
  }

  private async getQuickPromptTemplates(): Promise<AssistantQuickPromptTemplate[]> {
    const cached = this.quickPromptTemplatesCache;
    if (cached && cached.expiresAt > Date.now()) {
      return cached.value;
    }

    if (!this.supabaseAdminService.isConfigured) {
      return [];
    }

    try {
      const { data, error } = await this.supabaseAdminService.admin
        .from('assistant_quick_prompt_templates')
        .select(
          'corridor_key, prompt_key, label_pt, label_es, label_en, message_pt, message_es, message_en, message_default',
        )
        .eq('status', 'published');

      if (error || !data) {
        return [];
      }

      const templates = (data as AssistantQuickPromptRecord[]).map((row) => ({
        corridorKey: row.corridor_key,
        promptKey: row.prompt_key,
        labels: {
          ...(row.label_pt ? { pt: row.label_pt } : {}),
          ...(row.label_es ? { es: row.label_es } : {}),
          ...(row.label_en ? { en: row.label_en } : {}),
        },
        messages: {
          ...(row.message_pt ? { pt: row.message_pt } : {}),
          ...(row.message_es ? { es: row.message_es } : {}),
          ...(row.message_en ? { en: row.message_en } : {}),
        },
        messageDefault: row.message_default,
      }));

      this.quickPromptTemplatesCache = {
        expiresAt: Date.now() + CACHE_TTL_MS,
        value: templates,
      };

      return templates;
    } catch (error) {
      this.logger.warn(`Assistant quick prompt fallback enabled: ${String(error)}`);
      return [];
    }
  }

  private async getGuideAnswersCache(): Promise<AssistantGuideAnswer[]> {
    const cached = this.guideAnswersCache;
    if (cached && cached.expiresAt > Date.now()) {
      return cached.value;
    }

    if (!this.supabaseAdminService.isConfigured) {
      return [];
    }

    try {
      const { data, error } = await this.supabaseAdminService.admin
        .from('assistant_guide_answers')
        .select(
          'corridor_key, destination_country, section, priority, question_pt, question_es, question_en, answer_pt, answer_es, answer_en, keywords',
        )
        .eq('status', 'published')
        .order('priority', { ascending: false });

      if (error || !data) {
        return [];
      }

      const answers = (data as AssistantGuideAnswerRecord[]).map((row) => ({
        corridorKey: row.corridor_key,
        destinationCountry: row.destination_country,
        section: row.section,
        priority: row.priority,
        questions: {
          ...(row.question_pt ? { pt: row.question_pt } : {}),
          ...(row.question_es ? { es: row.question_es } : {}),
          ...(row.question_en ? { en: row.question_en } : {}),
        },
        answers: {
          ...(row.answer_pt ? { pt: row.answer_pt } : {}),
          ...(row.answer_es ? { es: row.answer_es } : {}),
          ...(row.answer_en ? { en: row.answer_en } : {}),
        },
        keywords: row.keywords ?? {},
      }));

      this.guideAnswersCache = {
        expiresAt: Date.now() + CACHE_TTL_MS,
        value: answers,
      };

      return answers;
    } catch (error) {
      this.logger.warn(`Assistant guide answers fallback enabled: ${String(error)}`);
      return [];
    }
  }
}
