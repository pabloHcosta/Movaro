import { Injectable } from '@nestjs/common';

import { AssistantKnowledgeService } from '../assistant-knowledge.service';
import { normalizeChatCorridor } from '../chat-country-normalizer';
import type { GuideItem } from '../../../data/argentina-brazil-guide.datasource';
import { findRegisteredGuideCatalogByCorridor } from '../../../data/guide-catalog.registry';

export interface DocResolverResult {
  confidence: number;
  items: GuideItem[];
  summary: string;
}

/** Keyword → guide item IDs to prioritise */
const KEYWORD_TO_IDS: Array<{ keywords: string[]; ids: string[] }> = [
  {
    keywords: ['cpf', 'cadastro de pessoa física', 'cadastro pessoa'],
    ids: ['item_2_1_cpf'],
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
    ids: ['item_2_2_residencia'],
  },
  {
    keywords: [
      'apostila',
      'apostille',
      'tradução',
      'traduccion',
      'translation',
    ],
    ids: ['item_0_2_document_folder'],
  },
  {
    keywords: ['diploma', 'revalidação', 'revalida', 'mec'],
    ids: ['item_3_5_revalidacao_estudos'],
  },
  {
    keywords: ['ctps', 'carteira de trabalho', 'work booklet'],
    ids: ['item_2_3_ctps'],
  },
  {
    keywords: ['crnm', 'carteira de registro', 'registro nacional'],
    ids: ['item_4_5_registro_rnm'],
  },
  {
    keywords: ['cnh', 'carteira de motorista', 'driver', 'habilitação'],
    ids: ['item_4_1_cnh'],
  },
  {
    keywords: [
      'conta bancária',
      'conta banco',
      'bank account',
      'banco',
      'bank',
    ],
    ids: ['item_3_1_conta_bancaria'],
  },
  {
    keywords: ['sus', 'saúde', 'salud', 'health', 'plano de saúde'],
    ids: ['item_4_2_saude'],
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
    ids: ['item_1_2_housing_temporary', 'item_3_2_aluguel_fixo'],
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
    ids: ['item_0_3_budget', 'item_1_3_money'],
  },
  {
    keywords: [
      'documentos',
      'documents',
      'documentación',
      'papelada',
      'papeleria',
    ],
    ids: ['item_0_2_document_folder', 'item_2_1_cpf', 'item_2_2_residencia'],
  },
];

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
        ? normalizeChatCorridor(originCountry, destinationCountry)
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

    const catalog = corridorKey
      ? findRegisteredGuideCatalogByCorridor(corridorKey)
      : null;
    if (!catalog) {
      return { confidence: 0, items: [], summary: '' };
    }

    const allItemsById = new Map<string, GuideItem>(
      catalog.items.map((item) => [item.id, item]),
    );
    const lower = message.toLowerCase();
    const matchedIds = new Set<string>();

    for (const { keywords, ids } of KEYWORD_TO_IDS) {
      if (keywords.some((kw) => lower.includes(kw))) {
        for (const id of ids) matchedIds.add(id);
      }
    }

    const items = [...matchedIds]
      .map((id) => allItemsById.get(id))
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
