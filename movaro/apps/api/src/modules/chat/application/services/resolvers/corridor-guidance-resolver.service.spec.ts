import { CorridorGuidanceResolverService } from './corridor-guidance-resolver.service';
import { CitiesCatalogService } from '../../../../cities/application/services/cities-catalog.service';
import { AssistantKnowledgeService } from '../assistant-knowledge.service';

describe('CorridorGuidanceResolverService', () => {
  const citiesCatalogService = {
    getCityDisplayNameById: jest.fn().mockReturnValue('Florianopolis'),
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
    expect(result.answer).toContain('próximo ponto prático');
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
});
