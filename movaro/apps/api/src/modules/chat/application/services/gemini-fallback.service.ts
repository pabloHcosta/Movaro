import { Injectable, Logger } from '@nestjs/common';

import { AppConfigService } from '../../../../common/config/app-config.service';
import { ChatHistoryItemDto } from '../../presentation/dto/ask-chat.dto';

export interface LlmResponse {
  text: string;
  provider?: string;
}

// ── Groq (Llama 3.3 70B) ─────────────────────────────────────────────────────
const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions';
const GROQ_MODEL = 'llama-3.3-70b-versatile';

// ── Gemini 2.0 Flash ──────────────────────────────────────────────────────────
const GEMINI_ENDPOINT =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

const CORRIDOR_KNOWLEDGE = `
Key context for Argentina → Brasil corridor:
- CPF (Cadastro de Pessoa Física) is the most critical first step. Without it: no bank account, no lease, no formal work.
- MERCOSUL residency: Argentines have the right to 2-year temporary residency (renewable) at the Federal Police.
- VITEM V is the common work visa for professionals outside MERCOSUL agreement.
- Diploma recognition (revalidação) via MEC/REVALIDA is lengthy for healthcare and law professionals.
- ARS→BRL rate is volatile — always verify before making financial decisions.
- Top cities for Argentines: São Paulo, Florianópolis, Curitiba, Rio de Janeiro, Campinas, Porto Alegre.
- Nubank is the easiest bank to open without credit history.
- Pix is Brazil's instant payment system — free, 24/7, used for everything.
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
  ): Promise<LlmResponse> {
    const systemPrompt = this.buildSystemPrompt({
      originCountry,
      destinationCountry,
      locale,
      appDataBlock,
    });

    // ── 1st: Try Groq (Llama 3.3 70B — free, fast) ──────────────────────────
    const groqKey = this.configService.groqApiKey;
    if (groqKey) {
      try {
        const text = await this.callGroq(groqKey, systemPrompt, message, history);
        if (text) {
          this.logger.debug('[LLM] Groq answered ✓');
          return { text, provider: 'groq' };
        }
      } catch (err) {
        this.logger.warn(`[LLM] Groq failed: ${err} — trying Gemini`);
      }
    }

    // ── 2nd: Try Gemini (backup) ─────────────────────────────────────────────
    const geminiKey = this.configService.geminiApiKey;
    if (geminiKey) {
      try {
        const text = await this.callGemini(geminiKey, systemPrompt, message, history);
        if (text) {
          this.logger.debug('[LLM] Gemini answered ✓');
          return { text, provider: 'gemini' };
        }
      } catch (err) {
        this.logger.warn(`[LLM] Gemini failed: ${err}`);
      }
    }

    // ── Static fallback ───────────────────────────────────────────────────────
    this.logger.warn('[LLM] All providers failed — returning static fallback');
    return { text: this.staticFallback(locale), provider: 'static' };
  }

  // ── Groq call (OpenAI-compatible) ─────────────────────────────────────────

  private async callGroq(
    apiKey: string,
    systemPrompt: string,
    message: string,
    history: ChatHistoryItemDto[],
  ): Promise<string | null> {
    const messages = [
      { role: 'system', content: systemPrompt },
      ...history.map((h) => ({
        role: h.role === 'assistant' ? 'assistant' : 'user',
        content: h.text,
      })),
      { role: 'user', content: message },
    ];

    const res = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: GROQ_MODEL,
        messages,
        temperature: 0.3,
        max_tokens: 600,
      }),
      signal: AbortSignal.timeout(12_000),
    });

    if (!res.ok) {
      const err = await res.text().catch(() => '');
      throw new Error(`Groq ${res.status}: ${err.slice(0, 200)}`);
    }

    const data = (await res.json()) as GroqApiResponse;
    return data?.choices?.[0]?.message?.content?.trim() ?? null;
  }

  // ── Gemini call ───────────────────────────────────────────────────────────

  private async callGemini(
    apiKey: string,
    systemPrompt: string,
    message: string,
    history: ChatHistoryItemDto[],
  ): Promise<string | null> {
    const contents: GeminiContent[] = [
      ...history.map((h) => ({
        role: h.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: h.text }],
      })),
      { role: 'user', parts: [{ text: message }] },
    ];

    const res = await fetch(`${GEMINI_ENDPOINT}?key=${apiKey}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: systemPrompt }] },
        contents,
        generationConfig: { temperature: 0.3, maxOutputTokens: 600 },
      }),
      signal: AbortSignal.timeout(15_000),
    });

    if (!res.ok) {
      const err = await res.text().catch(() => '');
      throw new Error(`Gemini ${res.status}: ${err.slice(0, 200)}`);
    }

    const data = (await res.json()) as GeminiApiResponse;
    return data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim() ?? null;
  }

  // ── System prompt ─────────────────────────────────────────────────────────

  private buildSystemPrompt(opts: {
    originCountry: string;
    destinationCountry: string;
    locale: string;
    appDataBlock: string;
  }): string {
    const corridor = `${this.cap(opts.originCountry)} → ${this.cap(opts.destinationCountry)}`;

    return `=== MOVARO AI ASSISTANT ===

You are the Movaro Assistant — an in-app guide that helps users plan and execute their international migration.
You exist inside the Movaro app. Your sole purpose is to help users navigate the migration process.

ACTIVE CORRIDOR: ${corridor}
${this.langRule(opts.locale)}

TONE: Warm, practical, direct. Like a friend who already went through migration.
Keep responses SHORT: 2-4 paragraphs max. Use bullet points only when listing steps or documents.
Never start every response with "Claro!" or "Sure!" — vary your openings.

SCOPE: Only answer questions about migration, documentation, costs, housing, work, and city selection
for the ${corridor} corridor. Decline political, medical investment advice.

SOURCE OF TRUTH: When app data is available, use ONLY that data. For general migration concepts,
you may use knowledge but flag it clearly. NEVER invent specific costs, deadlines, or requirements.

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

  private staticFallback(locale: string): string {
    if (locale === 'es')
      return 'No pude obtener una respuesta ahora. Revisá los guías en la pestaña Guías — tienen información completa sobre tu migración.';
    if (locale === 'en')
      return 'I could not get a response right now. Check the Guides tab — it has comprehensive information about your migration.';
    return 'Não consegui obter uma resposta agora. Confira os guias na aba Guias — lá tem informações completas sobre sua migração.';
  }
}

// ── API types ─────────────────────────────────────────────────────────────────

interface GroqApiResponse {
  choices?: Array<{ message?: { content?: string } }>;
}

interface GeminiContent {
  role: string;
  parts: Array<{ text: string }>;
}

interface GeminiApiResponse {
  candidates?: Array<{
    content?: { parts?: Array<{ text?: string }> };
  }>;
}
