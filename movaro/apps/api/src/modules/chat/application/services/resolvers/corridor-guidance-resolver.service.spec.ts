import { CorridorGuidanceResolverService } from './corridor-guidance-resolver.service';
import { CitiesCatalogService } from '../../../../cities/application/services/cities-catalog.service';
import { AssistantKnowledgeService } from '../assistant-knowledge.service';

describe('CorridorGuidanceResolverService', () => {
  const citiesCatalogService = {
    getCityDisplayNameById: jest.fn().mockReturnValue('Florianopolis'),
    getCityById: jest.fn().mockResolvedValue({
      id: 'florianopolis-sc',
      name: 'Florianopolis',
      seasonalitySnapshot: {
        lowMonths: [3, 4, 9, 10, 11],
        rentNotesPt:
          'Na alta temporada, aluguel e oferta ficam mais pressionados em Florianopolis.',
        rentNotesEs:
          'En temporada alta, alquiler y oferta se presionan más en Florianopolis.',
        rentNotesEn:
          'In peak season, rent and supply get tighter in Florianopolis.',
      },
    }),
    resolveCityId: jest
      .fn()
      .mockImplementation((id: string) =>
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
      highlightedCityId: 'florianopolis',
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
    expect(result.answer).toContain(
      'Ainda não existem respostas guiadas sem IA',
    );
  });

  it('recognizes Uruguay -> Brasil as partial guided coverage', async () => {
    const service = new CorridorGuidanceResolverService(
      citiesCatalogService,
      assistantKnowledgeService,
    );

    const result = await service.resolve({
      message: 'Como funciona a moradia nesse corredor?',
      originCountry: 'UY',
      destinationCountry: 'BR',
      locale: 'pt',
    });

    expect(result.found).toBe(true);
    expect(result.answer).toContain('cobertura parcial');
    expect(result.answer).not.toContain(
      'Ainda não existem respostas guiadas sem IA',
    );
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
    expect(result.answer).not.toContain(
      'Ainda não existem respostas guiadas sem IA',
    );
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
    expect(result.answer).toContain('acordo bilateral Brasil–Argentina');
    expect(result.answer).toContain('não é prazo universal');
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
      highlightedCityId: 'florianopolis',
      currentPhase: 'documents',
      completedItemIds: [],
    });

    expect(result.found).toBe(true);
    expect(result.answer).toContain('Florianopolis');
    expect(result.answer).toContain('mar');
    expect(result.answer).toContain('passagem');
    expect(result.answer).toContain('aluguel');
  });

  it('uses canonical app progress when answering the next-step question', async () => {
    const service = new CorridorGuidanceResolverService(
      citiesCatalogService,
      assistantKnowledgeService,
    );

    const result = await service.resolve({
      message: 'Já concluí o CPF. O que faço agora?',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
      currentPhase: 'documents',
      completedItemIds: ['item_2_1_cpf'],
    });

    expect(result.found).toBe(true);
    expect(result.topic).toBe('next_step');
    expect(result.answer).toContain('Criar e validar a conta Gov.br');
    expect(result.answer).not.toContain('Obter CPF na Receita Federal');
  });

  it('normalizes legacy progress IDs before selecting the next task', async () => {
    const service = new CorridorGuidanceResolverService(
      citiesCatalogService,
      assistantKnowledgeService,
    );

    const result = await service.resolve({
      message: 'Qual é o próximo passo?',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
      currentPhase: 'documents',
      completedItemIds: ['doc-01'],
    });

    expect(result.answer).toContain('Criar e validar a conta Gov.br');
    expect(result.answer).not.toContain('Obter CPF na Receita Federal');
  });
});
