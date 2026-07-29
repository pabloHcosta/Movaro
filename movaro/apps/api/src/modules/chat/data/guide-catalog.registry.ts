import {
  ARGENTINA_BRAZIL_GUIDE_ITEMS,
  PHASE_ORDER,
  type GuideItem,
} from './argentina-brazil-guide.datasource';
import {
  URUGUAY_BRAZIL_GUIDE_ITEMS,
  URUGUAY_BRAZIL_PHASE_ORDER,
} from './uruguay-brazil-guide.datasource';

export interface RegisteredGuideCatalog {
  corridorKey: string;
  destinationCountry: string;
  items: GuideItem[];
  phaseOrder: readonly string[];
  coverageLevel?: 'full' | 'partial';
  completedItemAliases?: Record<string, string>;
}

const REGISTERED_GUIDE_CATALOGS: RegisteredGuideCatalog[] = [
  {
    corridorKey: 'argentina->brasil',
    destinationCountry: 'brasil',
    items: ARGENTINA_BRAZIL_GUIDE_ITEMS,
    phaseOrder: PHASE_ORDER,
    coverageLevel: 'full',
    completedItemAliases: {
      // Backward compatibility for cached clients created before the app IDs
      // became the canonical cross-platform contract.
      'prep-01': 'item_0_3_budget',
      'prep-02': 'item_1_3_money',
      'prep-03': 'item_1_2_housing_temporary',
      'prep-04': 'item_0_2_document_folder',
      'doc-01': 'item_2_1_cpf',
      'doc-02': 'item_2_2_residencia',
      'hou-01': 'item_1_2_housing_temporary',
      'hou-02': 'item_4_9_reavaliar_bairro',
      'hou-03': 'item_3_2_aluguel_fixo',
      'wor-01': 'item_3_1_conta_bancaria',
      'wor-02': 'item_2_3_ctps',
      'wor-03': 'item_3_5_revalidacao_estudos',
      'wor-04': 'item_3_4_work_rights',
      'arr-01': 'item_4_5_registro_rnm',
      'arr-02': 'item_4_2_saude',
      'arr-03': 'item_4_1_cnh',
    },
  },
  {
    corridorKey: 'uruguai->brasil',
    destinationCountry: 'brasil',
    items: URUGUAY_BRAZIL_GUIDE_ITEMS,
    phaseOrder: URUGUAY_BRAZIL_PHASE_ORDER,
    coverageLevel: 'partial',
  },
];

export function listRegisteredGuideCatalogs(): RegisteredGuideCatalog[] {
  return REGISTERED_GUIDE_CATALOGS;
}

export function findRegisteredGuideCatalogByCorridor(
  corridorKey: string,
): RegisteredGuideCatalog | null {
  return (
    REGISTERED_GUIDE_CATALOGS.find(
      (catalog) => catalog.corridorKey === corridorKey,
    ) ?? null
  );
}
