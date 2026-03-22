import { Injectable, Logger } from '@nestjs/common';

import { AppConfigService } from '../../../../common/config/app-config.service';
import { ChatHistoryItemDto } from '../../presentation/dto/ask-chat.dto';

export interface GeminiResponse {
  text: string;
  tokenCount?: number;
}

const GEMINI_API_BASE =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

const CORRIDOR_KNOWLEDGE = `
Key context for Argentina → Brasil corridor:
- CPF (Cadastro de Pessoa Física) is the most critical first step for Argentines in Brazil. Without it, almost nothing works (bank account, lease, formal work).
- MERCOSUL agreement facilitates residency but still requires a bureaucratic process at the Federal Police.
- VITEM V is the common work visa type for professionals.
- Diploma recognition (revalidação) through MEC/REVALIDA is lengthy, especially for healthcare and law professionals.
- ARS→BRL exchange rate is volatile; cost data may need periodic verification.
- Common destination cities: São Paulo, Florianópolis, Curitiba, Rio de Janeiro, Campinas, Porto Alegre.
`;

@Injectable()
export class GeminiFallbackService {
  private readonly logger = new Logger(GeminiFallbackService.name);

  constructor(private readonly configService: AppConfigService) {}

  async ask(
    message: string,
    {
      appDataBlock = '',
      originCountry = 'argentina',
      destinationCountry = 'brasil',
      locale = 'pt',
      history = [] as ChatHistoryItemDto[],
    } = {},
  ): Promise<GeminiResponse> {
    const apiKey = this.configService.geminiApiKey;

    if (!apiKey) {
      this.logger.warn('Gemini API key not configured — returning fallback message');
      return { text: this.noKeyFallback(locale) };
    }

    const systemPrompt = this.buildSystemPrompt({
      originCountry,
      destinationCountry,
      locale,
      appDataBlock,
    });

    // Build Gemini contents array with history
    const contents: GeminiContent[] = [
      ...history.map((h) => ({
        role: h.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: h.text }],
      })),
      { role: 'user', parts: [{ text: message }] },
    ];

    try {
      const url = `${GEMINI_API_BASE}?key=${apiKey}`;
      const body = {
        systemInstruction: { parts: [{ text: systemPrompt }] },
        contents,
        generationConfig: {
          temperature: 0.3,
          maxOutputTokens: 600,
        },
      };

      const res = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(15_000),
      });

      if (!res.ok) {
        const errText = await res.text().catch(() => '');
        this.logger.error(`Gemini API error ${res.status}: ${errText}`);
        return { text: this.errorFallback(locale) };
      }

      const data = (await res.json()) as GeminiApiResponse;
      const text =
        data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim() ?? '';

      if (!text) {
        return { text: this.errorFallback(locale) };
      }

      return {
        text,
        tokenCount: data?.usageMetadata?.totalTokenCount,
      };
    } catch (err) {
      this.logger.error(`Gemini fallback error: ${err}`);
      return { text: this.errorFallback(locale) };
    }
  }

  private buildSystemPrompt(opts: {
    originCountry: string;
    destinationCountry: string;
    locale: string;
    appDataBlock: string;
  }): string {
    const corridor = `${this.cap(opts.originCountry)} → ${this.cap(opts.destinationCountry)}`;
    const langRule = this.langRule(opts.locale);

    return `=== MOVARO AI ASSISTANT ===

You are the Movaro Assistant — an in-app guide that helps users plan and execute their international migration.
You exist inside the Movaro app. Your sole purpose is to help users navigate the migration process.

ACTIVE CORRIDOR: ${corridor}
${langRule}

TONE: Warm, practical, direct. Like a friend who already went through the migration process.
Keep responses SHORT: 2-4 paragraphs maximum. Use bullet points only when listing steps or documents.
Never start every response with "Claro!" or "Sure!" — vary your openings.

SCOPE: Only answer questions about migration, documentation, costs, housing, work, and city selection
for the ${corridor} corridor. Decline political, medical investment advice.

SOURCE OF TRUTH RULES:
1. When app data is available for a topic, use ONLY that data.
2. When app data is NOT available, you may use general knowledge BUT flag it clearly.
3. NEVER invent specific costs, deadlines, phone numbers, or document requirements.
4. Use safe language: "Segundo os dados do app..." or "Essa informação pode variar."

${CORRIDOR_KNOWLEDGE}

${opts.appDataBlock ? `--- APP DATA (source of truth) ---\n${opts.appDataBlock}\n--- END OF APP DATA ---` : ''}

=== END OF SYSTEM PROMPT ===`;
  }

  private cap(s: string): string {
    return s ? s[0].toUpperCase() + s.slice(1) : s;
  }

  private langRule(locale: string): string {
    if (locale === 'pt') return 'ALWAYS respond in Português Brasileiro.';
    if (locale === 'es') return 'ALWAYS respond in Español.';
    return 'ALWAYS respond in English.';
  }

  private noKeyFallback(locale: string): string {
    if (locale === 'es') return 'El asistente de IA no está disponible en este momento. Consulta los guías en la pestaña Guías para información sobre tu migración.';
    if (locale === 'en') return 'The AI assistant is not available right now. Check the Guides tab for migration information.';
    return 'O assistente de IA não está disponível no momento. Consulte os guias na aba Guias para informações sobre sua migração.';
  }

  private errorFallback(locale: string): string {
    if (locale === 'es') return 'Tuve un problema al procesar tu pregunta. ¿Podés intentar de nuevo?';
    if (locale === 'en') return 'I had trouble processing your question. Could you try again?';
    return 'Tive um problema ao processar sua pergunta. Pode tentar novamente?';
  }
}

// ── Gemini API types ───────────────────────────────────────────────────────────

interface GeminiContent {
  role: string;
  parts: Array<{ text: string }>;
}

interface GeminiApiResponse {
  candidates?: Array<{
    content?: {
      parts?: Array<{ text?: string }>;
    };
  }>;
  usageMetadata?: {
    totalTokenCount?: number;
  };
}
