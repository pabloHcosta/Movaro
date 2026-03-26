import { DocResolverService } from './doc-resolver.service';
import { AssistantKnowledgeService } from '../assistant-knowledge.service';

describe('DocResolverService', () => {
  it('uses document knowledge from Supabase when available for the corridor', async () => {
    const service = new DocResolverService({
      resolveDocuments: jest.fn().mockResolvedValue([
        {
          id: 'doc-01',
          phase: 'documents',
          title: 'Obtener CPF',
          summary: 'Resolver el CPF temprano destraba banco y alquiler.',
          notes: 'Conviene resolver esto antes de trámites más pesados.',
        },
      ]),
    } as unknown as AssistantKnowledgeService);

    const result = await service.resolve(
      'Necesito CPF para Brasil',
      'es',
      'argentina',
      'brasil',
    );

    expect(result.confidence).toBeGreaterThan(0.6);
    expect(result.summary).toContain('Obtener CPF');
    expect(result.summary).toContain('banco y alquiler');
  });

  it('falls back to static guide items when db knowledge does not match', async () => {
    const service = new DocResolverService({
      resolveDocuments: jest.fn().mockResolvedValue([]),
    } as unknown as AssistantKnowledgeService);

    const result = await service.resolve(
      'Como tirar o CPF?',
      'pt',
      'argentina',
      'brasil',
    );

    expect(result.confidence).toBeGreaterThan(0.5);
    expect(result.summary).toContain('Informações do guia de migração');
    expect(result.summary).toContain('CPF');
  });
});
