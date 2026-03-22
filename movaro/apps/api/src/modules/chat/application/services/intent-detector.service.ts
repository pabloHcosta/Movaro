import { Injectable } from '@nestjs/common';

export type ChatIntent =
  | 'city_info'
  | 'cost'
  | 'documents'
  | 'plan'
  | 'general';

export interface IntentResult {
  intent: ChatIntent;
  confidence: number;
  /** Extracted entities like city names, document types, etc. */
  entities: Record<string, string>;
}

/** Keyword sets for each intent. Order matters — first match wins for high-confidence. */
const INTENT_KEYWORDS: Record<ChatIntent, string[]> = {
  city_info: [
    'cidade',
    'city',
    'ciudad',
    'são paulo',
    'sao paulo',
    'florianópolis',
    'florianopolis',
    'curitiba',
    'rio de janeiro',
    'belo horizonte',
    'porto alegre',
    'campinas',
    'onde morar',
    'where to live',
    'dónde vivir',
    'melhor cidade',
    'best city',
    'mejor ciudad',
    'comparar cidades',
    'custo de vida',
    'climate',
    'clima',
    'qualidade de vida',
  ],
  cost: [
    'custo',
    'cost',
    'costo',
    'preço',
    'price',
    'precio',
    'aluguel',
    'rent',
    'alquiler',
    'salário',
    'salary',
    'salario',
    'dinheiro',
    'money',
    'dinero',
    'câmbio',
    'exchange',
    'cambio',
    'brl',
    'ars',
    'real',
    'peso',
    'orçamento',
    'budget',
    'presupuesto',
    'quanto custa',
    'how much',
    'cuánto cuesta',
    'barato',
    'cheap',
    'economic',
    'econômico',
  ],
  documents: [
    'documento',
    'document',
    'cpf',
    'visto',
    'visa',
    'residência',
    'residency',
    'residencia',
    'passaporte',
    'passport',
    'pasaporte',
    'crnm',
    'rne',
    'carteira',
    'apostila',
    'apostille',
    'registro',
    'mercosul',
    'mercosur',
    'diploma',
    'revalidação',
    'revalida',
    'ctps',
    'trabalho',
    'work permit',
    'permiso de trabajo',
    'cnh',
    'carteira de motorista',
    'certidão',
    'translação',
    'tradutor juramentado',
  ],
  plan: [
    'plano',
    'plan',
    'guia',
    'guide',
    'etapa',
    'step',
    'fase',
    'phase',
    'próximo passo',
    'next step',
    'próximo paso',
    'completei',
    'completed',
    'completé',
    'o que fazer',
    'what to do',
    'qué hacer',
    'quanto tempo',
    'how long',
    'cuánto tiempo',
    'prazo',
    'timeline',
    'progresso',
    'progress',
    'progreso',
  ],
  general: [],
};

/** Cities mentioned in queries → their catalog IDs */
const CITY_ALIASES: Record<string, string> = {
  'são paulo': 'sao-paulo',
  'sao paulo': 'sao-paulo',
  sp: 'sao-paulo',
  florianópolis: 'florianopolis',
  florianopolis: 'florianopolis',
  floripa: 'florianopolis',
  curitiba: 'curitiba',
  'rio de janeiro': 'rio-de-janeiro',
  rio: 'rio-de-janeiro',
  'belo horizonte': 'belo-horizonte',
  bh: 'belo-horizonte',
  'porto alegre': 'porto-alegre',
  poa: 'porto-alegre',
  campinas: 'campinas',
  'balneário camboriu': 'balneario-camboriu',
  'balneario camboriu': 'balneario-camboriu',
  'balneário camboriú': 'balneario-camboriu',
};

@Injectable()
export class IntentDetectorService {
  detect(message: string): IntentResult {
    const lower = message.toLowerCase();
    const scores: Partial<Record<ChatIntent, number>> = {};
    const entities: Record<string, string> = {};

    // Score each intent by keyword matches
    for (const [intent, keywords] of Object.entries(INTENT_KEYWORDS)) {
      if (!keywords.length) continue;
      let score = 0;
      for (const kw of keywords) {
        if (lower.includes(kw)) {
          // Weight by keyword length (longer = more specific)
          score += 0.1 + kw.length * 0.02;
        }
      }
      if (score > 0) {
        scores[intent as ChatIntent] = score;
      }
    }

    // Extract city entity
    for (const [alias, cityId] of Object.entries(CITY_ALIASES)) {
      if (lower.includes(alias)) {
        entities['cityId'] = cityId;
        break;
      }
    }

    // Find winning intent
    let bestIntent: ChatIntent = 'general';
    let bestScore = 0;

    for (const [intent, score] of Object.entries(scores)) {
      if ((score ?? 0) > bestScore) {
        bestScore = score ?? 0;
        bestIntent = intent as ChatIntent;
      }
    }

    // Normalise confidence: cap at 0.95, 0 → 'general' with 0.0
    const confidence = bestScore > 0
      ? Math.min(0.95, 0.4 + bestScore * 0.3)
      : 0.0;

    return { intent: bestIntent, confidence, entities };
  }
}
