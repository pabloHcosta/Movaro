import type { GuideItem } from './argentina-brazil-guide.datasource';

/**
 * Scaffold catalog for Uruguay -> Brasil.
 *
 * This corridor is intentionally partial for now: the assistant can recognize
 * the route and answer with controlled copy, but the full structured guide has
 * not been curated yet.
 */
export const URUGUAY_BRAZIL_GUIDE_ITEMS: GuideItem[] = [];

export const URUGUAY_BRAZIL_PHASE_ORDER = [
  'preparation',
  'documents',
  'housing',
  'work',
  'arrival',
] as const;
