import { Injectable } from '@nestjs/common';

import { AssistantKnowledgeService } from '../assistant-knowledge.service';
import {
  ARGENTINA_BRAZIL_GUIDE_ITEMS,
  GuideItem,
} from '../../../data/argentina-brazil-guide.datasource';

export interface DocResolverResult {
  confidence: number;
  items: GuideItem[];
  summary: string;
}

/** Keyword → guide item IDs to prioritise */
const KEYWORD_TO_IDS: Array<{ keywords: string[]; ids: string[] }> = [
  {
    keywords: ['cpf', 'cadastro de pessoa física', 'cadastro pessoa'],
    ids: ['doc-01'],
  },
  {
    keywords: [
      'residência',
      'residencia',
      'residency',
      'mercosul',
      'mercosur',
      'vitem',
      'visto',
    ],
    ids: ['doc-02'],
  },
  {
    keywords: ['apostila', 'apostille'],
    ids: ['doc-04', 'prep-04'],
  },
  {
    keywords: ['diploma', 'revalidação', 'revalida', 'mec'],
    ids: ['wor-03'],
  },
  {
    keywords: ['ctps', 'carteira de trabalho', 'work booklet'],
    ids: ['wor-02'],
  },
  {
    keywords: ['crnm', 'carteira de registro', 'registro nacional'],
    ids: ['arr-01'],
  },
  {
    keywords: ['cnh', 'carteira de motorista', 'driver', 'habilitação'],
    ids: ['arr-03'],
  },
  {
    keywords: [
      'conta bancária',
      'conta banco',
      'bank account',
      'banco',
      'bank',
    ],
    ids: ['wor-01'],
  },
  {
    keywords: ['sus', 'saúde', 'salud', 'health', 'plano de saúde'],
    ids: ['arr-02'],
  },
  {
    keywords: [
      'moradia',
      'housing',
      'vivienda',
      'aluguel',
      'rent',
      'alquiler',
      'contrato',
    ],
    ids: ['prep-03', 'hou-01', 'hou-03'],
  },
  {
    keywords: [
      'orçamento',
      'budget',
      'presupuesto',
      'dinheiro',
      'grana',
      'custos mudança',
    ],
    ids: ['prep-02'],
  },
  {
    keywords: [
      'documentos',
      'documents',
      'documentación',
      'papelada',
      'papeleria',
    ],
    ids: ['prep-04', 'doc-01', 'doc-02'],
  },
];

const ALL_ITEMS_BY_ID = new Map<string, GuideItem>(
  ARGENTINA_BRAZIL_GUIDE_ITEMS.map((item) => [item.id, item]),
);

@Injectable()
export class DocResolverService {
  constructor(
    private readonly assistantKnowledgeService: AssistantKnowledgeService,
  ) {}

  async resolve(
    message: string,
    locale: string = 'pt',
    originCountry?: string,
    destinationCountry?: string,
  ): Promise<DocResolverResult> {
    const corridorKey =
      originCountry && destinationCountry
        ? `${originCountry.toLowerCase().trim()}->${destinationCountry
            .toLowerCase()
            .trim()}`
        : '';
    const normalizedLocale = locale === 'es' || locale === 'en' ? locale : 'pt';

    if (corridorKey) {
      const dbItems = await this.assistantKnowledgeService.resolveDocuments(
        message,
        normalizedLocale,
        corridorKey,
      );

      if (dbItems.length > 0) {
        const items = dbItems.map((item) => ({
          id: item.id,
          phase: (item.phase ?? 'documents') as GuideItem['phase'],
          title: item.title,
          summary: item.summary,
          notes: item.notes,
        }));

        const confidence = Math.min(0.92, 0.55 + items.length * 0.1);
        return {
          confidence,
          items,
          summary: this.buildSummary(items, normalizedLocale),
        };
      }
    }

    const lower = message.toLowerCase();
    const matchedIds = new Set<string>();

    for (const { keywords, ids } of KEYWORD_TO_IDS) {
      if (keywords.some((kw) => lower.includes(kw))) {
        for (const id of ids) matchedIds.add(id);
      }
    }

    const items = [...matchedIds]
      .map((id) => ALL_ITEMS_BY_ID.get(id))
      .filter((item): item is GuideItem => item !== undefined)
      .slice(0, 4); // max 4 items per response

    if (items.length === 0) {
      return { confidence: 0, items: [], summary: '' };
    }

    const confidence = Math.min(0.92, 0.55 + items.length * 0.1);
    const summary = this.buildSummary(items, normalizedLocale);

    return { confidence, items, summary };
  }

  private buildSummary(items: GuideItem[], locale: string): string {
    const lines: string[] = [];

    if (locale === 'es') {
      lines.push('📋 **Información del guía de migración:**\n');
      for (const item of items) {
        lines.push(`**${item.title}**`);
        lines.push(item.summary);
        if (item.notes) lines.push(`💡 ${item.notes}`);
        lines.push('');
      }
    } else if (locale === 'en') {
      lines.push('📋 **Migration guide information:**\n');
      for (const item of items) {
        lines.push(`**${item.title}**`);
        lines.push(item.summary);
        if (item.notes) lines.push(`💡 ${item.notes}`);
        lines.push('');
      }
    } else {
      lines.push('📋 **Informações do guia de migração:**\n');
      for (const item of items) {
        lines.push(`**${item.title}**`);
        lines.push(item.summary);
        if (item.notes) lines.push(`💡 ${item.notes}`);
        lines.push('');
      }
    }

    return lines.join('\n').trim();
  }
}
