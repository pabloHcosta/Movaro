import { CorridorGuidanceResolverService } from './corridor-guidance-resolver.service';
import { CitiesCatalogService } from '../../../../cities/application/services/cities-catalog.service';
import { AssistantKnowledgeService } from '../assistant-knowledge.service';

describe('CorridorGuidanceResolverService', () => {
  const citiesCatalogService = {
    getCityDisplayNameById: jest.fn().mockReturnValue('Florianopolis'),
    resolveCityId: jest.fn().mockImplementation((id: string) =>
      id == 'florianopolis' ? 'florianopolis-sc' : id,
    ),
  } as unknown as CitiesCatalogService;
  const assistantKnowledgeService = {
    getQuickPromptTemplate: jest.fn().mockResolvedValue(null),
  } as unknown as AssistantKnowledgeService;

  it('answers CPF quick prompts deterministically with plan context', async () => {
    const service = new CorridorGuidanceResolverService(
      citiesCatalogService,
      assistantKnowledgeService,
    );

    const result = await service.resolve({
      message: 'Como tirar o CPF?',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
      currentPhase: 'documents',
      completedItemIds: [],
      recommendedCityId: 'florianopolis',
    });

    expect(result.found).toBe(true);
    expect(result.answer).toContain('CPF');
    expect(result.answer).toContain('Receita Federal');
  });

  it('returns deterministic unsupported-corridor guidance for quick prompts', async () => {
    const service = new CorridorGuidanceResolverService(
      citiesCatalogService,
      assistantKnowledgeService,
    );

    const result = await service.resolve({
      message: 'Preciso de visto?',
      originCountry: 'argentina',
      destinationCountry: 'canada',
      locale: 'pt',
    });

    expect(result.found).toBe(true);
    expect(result.answer).toContain('Ainda não existem respostas guiadas sem IA');
  });

  it('normalizes country aliases before resolving corridor guidance', async () => {
    const service = new CorridorGuidanceResolverService(
      citiesCatalogService,
      assistantKnowledgeService,
    );

    const result = await service.resolve({
      message: 'Como tirar o CPF?',
      originCountry: 'AR',
      destinationCountry: 'Brazil',
      locale: 'pt',
      currentPhase: 'documents',
      completedItemIds: [],
    });

    expect(result.found).toBe(true);
    expect(result.answer).toContain('CPF');
    expect(result.answer).not.toContain('Ainda não existem respostas guiadas sem IA');
  });

  it('returns a short non-AI visa answer for exact quick prompts', async () => {
    const service = new CorridorGuidanceResolverService(
      citiesCatalogService,
      assistantKnowledgeService,
    );

    const result = await service.resolve({
      message: 'Preciso de visto?',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
      completedItemIds: [],
    });

    expect(result.found).toBe(true);
    expect(result.answer).toContain('90 dias');
    expect(result.answer).toContain('residência Mercosul');
  });

  it('returns a city-aware best-time answer for exact quick prompts', async () => {
    const service = new CorridorGuidanceResolverService(
      citiesCatalogService,
      assistantKnowledgeService,
    );

    const result = await service.resolve({
      message: 'Melhor época pra ir?',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
      recommendedCityId: 'florianopolis',
      currentPhase: 'documents',
      completedItemIds: [],
    });

    expect(result.found).toBe(true);
    expect(result.answer).toContain('Florianopolis');
    expect(result.answer).toContain('mar');
    expect(result.answer).toContain('verão');
  });
});
