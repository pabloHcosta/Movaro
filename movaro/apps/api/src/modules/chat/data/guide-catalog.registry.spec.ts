import {
  findRegisteredGuideCatalogByCorridor,
  listRegisteredGuideCatalogs,
} from './guide-catalog.registry';

describe('guide-catalog.registry', () => {
  it('registers the default Argentina -> Brasil guide catalog', () => {
    const catalog = findRegisteredGuideCatalogByCorridor('argentina->brasil');

    expect(catalog).not.toBeNull();
    expect(catalog?.destinationCountry).toBe('brasil');
    expect(catalog?.items.length).toBeGreaterThan(0);
    expect(catalog?.phaseOrder.length).toBeGreaterThan(0);
  });

  it('registers Uruguay -> Brasil as a partial corridor scaffold', () => {
    const catalog = findRegisteredGuideCatalogByCorridor('uruguai->brasil');

    expect(catalog).not.toBeNull();
    expect(catalog?.destinationCountry).toBe('brasil');
    expect(catalog?.coverageLevel).toBe('partial');
  });

  it('returns all registered catalogs with unique corridor keys', () => {
    const catalogs = listRegisteredGuideCatalogs();
    const keys = catalogs.map((catalog) => catalog.corridorKey);

    expect(new Set(keys).size).toBe(keys.length);
  });

  it('uses app plan IDs as the canonical Argentina -> Brasil contract', () => {
    const catalog = findRegisteredGuideCatalogByCorridor('argentina->brasil');
    const ids = catalog?.items.map((item) => item.id) ?? [];

    expect(ids).toContain('item_2_1_cpf');
    expect(ids).toContain('item_2_2_residencia');
    expect(ids).toContain('item_0_2_document_folder');
    expect(ids).toContain('item_3_4_formal_work_ready');
    expect(ids.some((id) => /^(prep|doc|hou|wor|arr)-/.test(id))).toBe(false);
    expect(catalog?.completedItemAliases?.['doc-01']).toBe('item_2_1_cpf');
  });

  it('does not prescribe blanket apostille or translation for the bilateral route', () => {
    const catalog = findRegisteredGuideCatalogByCorridor('argentina->brasil');
    const combinedNotes = (catalog?.items ?? [])
      .map((item) => item.notes ?? '')
      .join(' ')
      .toLowerCase();

    expect(combinedNotes).toContain('dispensa de tradução');
    expect(combinedNotes).not.toContain(
      'documentos argentinos precisam de apostila',
    );
  });
});
