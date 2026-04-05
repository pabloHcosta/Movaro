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
      item_2_1_cpf: 'doc-01',
      item_2_2_residencia: 'doc-02',
      item_0_2_antecedentes: 'prep-04',
      item_1_2_housing_temporary: 'hou-01',
      item_3_1_conta_bancaria: 'wor-01',
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
