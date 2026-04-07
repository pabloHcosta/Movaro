import { ChatContextBuilderService } from './chat-context-builder.service';
import { CitiesCatalogService } from '../../../cities/application/services/cities-catalog.service';

describe('ChatContextBuilderService', () => {
  it('builds city context even when highlightedCityId arrives without state suffix', async () => {
    const service = new ChatContextBuilderService({
      resolveCityId: jest.fn().mockReturnValue('florianopolis-sc'),
      getCityById: jest.fn().mockResolvedValue({
        name: 'Florianopolis',
        stateName: 'Santa Catarina',
        costOfLivingScore: 80,
        rentScore: 75,
        jobMarketScore: 68,
        unemploymentRate: 5.2,
        idhmScore: 0.847,
        topIndustries: ['Tecnologia', 'Turismo'],
        movaroScores: {
          overall: 76,
          economical: 74,
          workOpportunity: 68,
          popularForArgentinians: 90,
          languageAdaptation: 88,
        },
        recommendationReasons: ['Popular entre argentinos'],
        updatedAt: '2026-01-01',
      }),
    } as unknown as CitiesCatalogService);

    const context = await service.buildContext({
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      highlightedCityId: 'florianopolis',
      locale: 'pt',
    });

    expect(context.coverageLevel).toBe('full');
    expect(context.appDataBlock).toContain('Florianopolis');
    expect(context.appDataBlock).toContain('Santa Catarina');
  });

  it('supports country aliases when resolving corridor coverage', async () => {
    const service = new ChatContextBuilderService({
      resolveCityId: jest.fn().mockReturnValue(null),
      getCityById: jest.fn(),
    } as unknown as CitiesCatalogService);

    const context = await service.buildContext({
      originCountry: 'AR',
      destinationCountry: 'Brazil',
      locale: 'pt',
    });

    expect(context.coverageLevel).toBe('full');
    expect(context.supportedCorridor).toBe('Argentina → Brasil');
  });

  it('marks Uruguay -> Brasil as partial coverage', async () => {
    const service = new ChatContextBuilderService({
      resolveCityId: jest.fn().mockReturnValue(null),
      getCityById: jest.fn(),
    } as unknown as CitiesCatalogService);

    const context = await service.buildContext({
      originCountry: 'UY',
      destinationCountry: 'BR',
      locale: 'pt',
    });

    expect(context.coverageLevel).toBe('partial');
    expect(context.supportedCorridor).toBe('Uruguai → Brasil');
  });
});
