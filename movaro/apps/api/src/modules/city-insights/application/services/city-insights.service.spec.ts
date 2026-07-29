import { AppConfigService } from '../../../../common/config/app-config.service';
import { SupabaseAdminService } from '../../../../common/supabase/supabase-admin.service';
import { CitiesCatalogService } from '../../../cities/application/services/cities-catalog.service';
import { CityInsightsService } from './city-insights.service';

describe('CityInsightsService', () => {
  afterEach(() => {
    jest.restoreAllMocks();
  });

  const makeService = (
    resolvedCityId: string,
    cityName: string,
    {
      geminiConfigured = false,
      groqConfigured = false,
      stateName = 'Rio de Janeiro',
      population = 500000,
      regionName = 'Sudeste',
    }: {
      geminiConfigured?: boolean;
      groqConfigured?: boolean;
      stateName?: string;
      population?: number;
      regionName?: string;
    } = {},
  ) => {
    const citiesCatalogService = {
      resolveCityId: jest.fn().mockReturnValue(resolvedCityId),
      getCityById: jest.fn().mockResolvedValue({
        id: resolvedCityId,
        name: cityName,
        stateName,
        population,
        regionName,
        latitude: -22.9,
        longitude: -43.2,
      }),
    } as unknown as CitiesCatalogService;

    const appConfigService = {
      isGeminiConfigured: geminiConfigured,
      geminiApiKey: geminiConfigured ? 'test-key' : null,
      isGroqConfigured: groqConfigured,
      groqApiKey: groqConfigured ? 'test-groq-key' : null,
    } as AppConfigService;

    const supabaseAdminService = {
      isConfigured: false,
    } as SupabaseAdminService;

    return new CityInsightsService(
      citiesCatalogService,
      appConfigService,
      supabaseAdminService,
    );
  };

  it('returns curated insights for Rio de Janeiro', async () => {
    jest.spyOn(global, 'fetch').mockRejectedValue(new Error('network'));
    const service = makeService('rio-de-janeiro-rj', 'Rio de Janeiro');

    const result = await service.getInsights({
      cityId: 'rio-de-janeiro',
      locale: 'pt',
      limit: 5,
    });

    expect(result.length).toBeGreaterThan(0);
    expect(result[0]?.source).toBe('curated');
    expect(result.some((item) => item.type === 'motivation')).toBe(true);
    expect(result.some((item) => item.theme === 'beaches')).toBe(true);
  });

  it('falls back to generic templates for smaller cities when Gemini is unavailable', async () => {
    jest.spyOn(global, 'fetch').mockRejectedValue(new Error('network'));
    const service = makeService('niteroi-rj', 'Niterói');

    const result = await service.getInsights({
      cityId: 'niteroi',
      goal: 'work',
      timeline: '3_months',
      locale: 'pt',
      limit: 5,
    });

    expect(result.length).toBeGreaterThan(0);
    expect(result[0]?.source).toBe('template');
    expect(result.some((item) => item.theme === 'neighborhoods')).toBe(true);
    expect(result.some((item) => item.theme === 'beaches')).toBe(true);
  });

  it('adapts template themes for inland cities instead of forcing coastal content', async () => {
    jest.spyOn(global, 'fetch').mockRejectedValue(new Error('network'));
    const service = makeService('londrina-pr', 'Londrina', {
      stateName: 'Paraná',
      population: 575000,
      regionName: 'Sul',
    });

    const result = await service.getInsights({
      cityId: 'londrina',
      locale: 'pt',
      limit: 5,
    });

    expect(result).toHaveLength(5);
    expect(result.some((item) => item.theme === 'beaches')).toBe(false);
    expect(result.some((item) => item.theme === 'parks')).toBe(true);
    expect(result.some((item) => item.theme === 'food_and_cafes')).toBe(true);
  });

  it('enriches template insights with real place highlights from open data', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: true,
      json: async () => ({
        elements: [
          {
            type: 'node',
            id: 1,
            lat: -22.97,
            lon: -43.2,
            tags: {
              name: 'Praia de Icaraí',
              natural: 'beach',
            },
          },
          {
            type: 'node',
            id: 2,
            lat: -22.96,
            lon: -43.18,
            tags: {
              name: 'Campo de São Bento',
              leisure: 'park',
            },
          },
        ],
      }),
    } as Response);

    const service = makeService('niteroi-rj', 'Niterói');

    const result = await service.getInsights({
      cityId: 'niteroi',
      locale: 'pt',
      limit: 5,
    });

    expect(
      result.some(
        (item) =>
          item.theme === 'beaches' &&
          (item.placeHighlights ?? []).includes('Praia de Icaraí'),
      ),
    ).toBe(true);
  });

  it('uses Gemini generation for smaller cities when no curated set exists', async () => {
    jest.spyOn(global, 'fetch').mockResolvedValue({
      ok: true,
      json: async () => ({
        candidates: [
          {
            content: {
              parts: [
                {
                  text: JSON.stringify([
                    {
                      type: 'lifestyle',
                      theme: 'beaches',
                      title: 'Rotina entre baia e cidade',
                      shortText:
                        'Niterói mistura vista, travessias e bairros com ritmo mais residencial.',
                      content:
                        'A cidade costuma agradar quem quer proximidade com o Rio sem viver no mesmo nível de intensidade. O dia a dia tende a combinar deslocamento planejado com uma rotina mais leve.',
                      ctaLabel: 'Explorar cidade',
                    },
                  ]),
                },
              ],
            },
          },
        ],
      }),
    } as Response);

    const service = makeService('niteroi-rj', 'Niterói', {
      geminiConfigured: true,
    });

    const result = await service.getInsights({
      cityId: 'niteroi',
      locale: 'pt',
      limit: 5,
    });

    expect(result).toHaveLength(1);
    expect(result[0]?.source).toBe('generated');
    expect(result[0]?.title).toContain('Rotina');
    expect(result[0]?.theme).toBe('beaches');
  });

  it('prefers Groq before Gemini for smaller cities', async () => {
    const fetchSpy = jest
      .spyOn(global, 'fetch')
      .mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          choices: [
            {
              message: {
                content: JSON.stringify({
                  items: [
                    {
                      type: 'motivation',
                      theme: 'viewpoints',
                      title: 'Uma cidade para sustentar a decisão',
                      shortText:
                        'Niterói pode reforçar a sensação de escolha consciente sem o peso de uma capital maior.',
                      content:
                        'Para muita gente, a cidade entrega uma combinação útil de paisagem, travessia e rotina urbana mais respirável. Isso ajuda a manter a decisão emocionalmente viva.',
                      ctaLabel: 'Explorar cidade',
                    },
                  ],
                }),
              },
            },
          ],
        }),
      } as Response)
      .mockRejectedValue(new Error('network'));

    const service = makeService('niteroi-rj', 'Niterói', {
      geminiConfigured: true,
      groqConfigured: true,
    });

    const result = await service.getInsights({
      cityId: 'niteroi',
      locale: 'pt',
      limit: 5,
    });

    expect(result).toHaveLength(1);
    expect(result[0]?.source).toBe('generated');
    expect(result[0]?.type).toBe('motivation');
    expect(result[0]?.theme).toBe('viewpoints');
    expect(fetchSpy).toHaveBeenCalled();
    expect(String(fetchSpy.mock.calls[0]?.[0])).toContain('api.groq.com');
  });

  it('returns mapped explore places from openstreetmap data', async () => {
    jest
      .spyOn(global, 'fetch')
      .mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          elements: [
            {
              type: 'node',
              id: 12,
              lat: -22.98,
              lon: -43.19,
              tags: {
                name: 'Parque Lage',
                leisure: 'park',
                'addr:suburb': 'Jardim Botânico',
                wikipedia: 'pt:Parque Lage',
              },
            },
          ],
        }),
      } as Response)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          query: {
            pages: {
              1: {
                thumbnail: {
                  source: 'https://upload.wikimedia.org/example.jpg',
                },
              },
            },
          },
        }),
      } as Response);

    const service = makeService('rio-de-janeiro-rj', 'Rio de Janeiro');
    const result = await service.getExplorePlaces({
      cityId: 'rio-de-janeiro',
      theme: 'parks',
      locale: 'pt',
      limit: 6,
    });

    expect(result).toHaveLength(1);
    expect(result[0]?.name).toBe('Parque Lage');
    expect(result[0]?.category).toBe('Parque e respiro');
    expect(result[0]?.neighborhood).toBe('Jardim Botânico');
    expect(result[0]?.source).toBe('openstreetmap');
    expect(result[0]?.imageUrl).toContain('wikimedia');
  });

  it('falls back to template explore items when openstreetmap fails', async () => {
    jest.spyOn(global, 'fetch').mockRejectedValue(new Error('network'));

    const service = makeService('jijoca-de-jericoacoara-ce', 'Jericoacoara', {
      stateName: 'Ceará',
      regionName: 'Nordeste',
      population: 27000,
    });

    const result = await service.getExplorePlaces({
      cityId: 'jijoca-de-jericoacoara-ce',
      theme: 'beaches',
      locale: 'pt',
      limit: 3,
    });

    expect(result).toHaveLength(1);
    expect(result[0]?.source).toBe('template');
    expect(result[0]?.category).toBe('Praia');
    expect(new Set(result.map((item) => item.name)).size).toBe(result.length);
  });

  it('tries a secondary overpass instance after a rate limit response', async () => {
    const fetchSpy = jest
      .spyOn(global, 'fetch')
      .mockResolvedValueOnce({
        ok: false,
        status: 429,
        headers: {
          get: jest.fn().mockReturnValue(null),
        },
        text: () => Promise.resolve('rate limited'),
      } as unknown as Response)
      .mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve({ elements: [] }),
      } as Response);
    const service = makeService('rio-de-janeiro-rj', 'Rio de Janeiro');
    const fetchOverpassElements = (
      service as unknown as {
        fetchOverpassElements: (query: string) => Promise<unknown[]>;
      }
    ).fetchOverpassElements.bind(service);

    const result = await fetchOverpassElements(
      '[out:json];node(0,0,1,1);out;',
    );

    expect(result).toEqual([]);
    expect(fetchSpy).toHaveBeenCalledTimes(2);
    expect(fetchSpy.mock.calls[0]?.[0]).toBe(
      'https://overpass-api.de/api/interpreter',
    );
    expect(fetchSpy.mock.calls[1]?.[0]).toBe(
      'https://overpass.private.coffee/api/interpreter',
    );
  });

  it('shares an in-flight overpass request for identical queries', async () => {
    let resolveFetch: ((response: Response) => void) | undefined;
    const fetchSpy = jest.spyOn(global, 'fetch').mockImplementation(
      () =>
        new Promise<Response>((resolve) => {
          resolveFetch = resolve;
        }),
    );
    const service = makeService('rio-de-janeiro-rj', 'Rio de Janeiro');
    const query = '[out:json];node(0,0,1,1);out;';
    const fetchOverpassElements = (
      service as unknown as {
        fetchOverpassElements: (input: string) => Promise<unknown[]>;
      }
    ).fetchOverpassElements.bind(service);

    const first = fetchOverpassElements(query);
    const second = fetchOverpassElements(query);
    resolveFetch?.({
      ok: true,
      json: () => Promise.resolve({ elements: [] }),
    } as Response);

    await expect(Promise.all([first, second])).resolves.toEqual([[], []]);
    expect(fetchSpy).toHaveBeenCalledTimes(1);
  });

  it('searches wikimedia commons for a place image when osm tags do not provide one', async () => {
    jest
      .spyOn(global, 'fetch')
      .mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          elements: [
            {
              type: 'node',
              id: 99,
              lat: -27.59,
              lon: -48.54,
              tags: {
                name: 'Mercado Público',
                amenity: 'marketplace',
                'addr:suburb': 'Centro',
              },
            },
          ],
        }),
      } as Response)
      .mockResolvedValueOnce({
        ok: true,
        json: async () => ({
          query: {
            pages: {
              1: {
                thumbnail: {
                  source:
                    'https://upload.wikimedia.org/commons/example-market.jpg',
                },
              },
            },
          },
        }),
      } as Response);

    const service = makeService('florianopolis-sc', 'Florianópolis', {
      stateName: 'Santa Catarina',
      regionName: 'Sul',
      population: 537000,
    });

    const result = await service.getExplorePlaces({
      cityId: 'florianopolis',
      theme: 'food_and_cafes',
      locale: 'pt',
      limit: 6,
    });

    expect(result).toHaveLength(1);
    expect(result[0]?.imageUrl).toContain('wikimedia');
    expect(result[0]?.name).toBe('Mercado Público');
  });

  it('extracts web place context from html search results as an experimental enrichment', async () => {
    jest
      .spyOn(global, 'fetch')
      .mockResolvedValueOnce({
        ok: true,
        text: async () => `
          <html>
            <body>
              <a class="result__a" href="//duckduckgo.com/l/?uddg=https%3A%2F%2Fexample.com%2Fcopacabana">
                Copacabana - Rio de Janeiro
              </a>
              <div class="result__snippet">
                Copacabana is one of the most iconic beaches in Rio de Janeiro and a classic local ritual.
              </div>
            </body>
          </html>
        `,
      } as Response)
      .mockResolvedValueOnce({
        ok: true,
        text: async () => `
          <html>
            <head>
              <meta property="og:title" content="Copacabana" />
              <meta property="og:description" content="Copacabana is one of the most iconic beaches in Rio de Janeiro and helps the city feel immediately alive." />
              <meta property="og:image" content="https://example.com/copacabana.jpg" />
            </head>
          </html>
        `,
      } as Response);

    const service = makeService('rio-de-janeiro-rj', 'Rio de Janeiro');

    const result = await (service as any).searchWebPlaceContext({
      placeName: 'Copacabana',
      cityName: 'Rio de Janeiro',
      stateName: 'Rio de Janeiro',
      locale: 'en',
      theme: 'beaches',
    });

    expect(result).toEqual({
      title: 'Copacabana',
      shortText:
        'Copacabana is one of the most iconic beaches in Rio de Janeiro and helps the city feel immediately alive.',
      imageUrl: 'https://example.com/copacabana.jpg',
      sourceUrl: 'https://example.com/copacabana',
    });
  });

  it('prioritizes discovery-led banners over generic retention cards when stronger place-based content exists', async () => {
    jest.spyOn(global, 'fetch').mockRejectedValue(new Error('network'));
    const service = makeService('porto-alegre-rs', 'Porto Alegre', {
      stateName: 'Rio Grande do Sul',
      population: 1330000,
      regionName: 'Sul',
    });

    jest
      .spyOn(service as any, 'searchWebThemeSuggestions')
      .mockImplementation(async ({ theme }: { theme: string }) => {
        if (theme === 'neighborhoods') {
          return ['Moinhos de Vento', 'Cidade Baixa'];
        }
        if (theme === 'food_and_cafes') {
          return ['Café do Mercado', 'Rua da República'];
        }
        if (theme === 'parks') {
          return ['Parque Farroupilha'];
        }
        return [];
      });

    const result = await service.getInsights({
      cityId: 'porto-alegre-rs',
      locale: 'pt',
      goal: 'work',
      limit: 5,
    });

    expect(result.slice(0, 3).map((item) => item.title)).toEqual(
      expect.arrayContaining(['Moinhos de Vento', 'Café do Mercado']),
    );
    expect(
      result.filter((item) =>
        [
          'Como pode ser viver em Porto Alegre',
          'Procure a agenda que faz a cidade mexer',
        ].includes(item.title),
      ).length,
    ).toBeLessThanOrEqual(1);
  });
});
