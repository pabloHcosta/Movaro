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
});
