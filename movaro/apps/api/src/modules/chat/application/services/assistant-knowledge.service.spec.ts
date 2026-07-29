import { AssistantKnowledgeService } from './assistant-knowledge.service';
import { SupabaseAdminService } from '../../../../common/supabase/supabase-admin.service';

describe('AssistantKnowledgeService', () => {
  it('detects Spanish from the user message regardless of requested locale', async () => {
    const service = new AssistantKnowledgeService({
      isConfigured: false,
    } as SupabaseAdminService);

    const locale = await service.detectLanguage(
      'Necesito documentos para vivir en Brasil',
      'pt',
    );

    expect(locale).toBe('es');
  });

  it('falls back to the explicit app locale when language evidence is weak', async () => {
    const service = new AssistantKnowledgeService({
      isConfigured: false,
    } as SupabaseAdminService);

    const locale = await service.detectLanguage(
      'Ich brauche Hilfe mit meinen Dokumenten',
      'pt',
    );

    expect(locale).toBe('pt');
  });

  it('keeps a long Portuguese progress update in Portuguese', async () => {
    const service = new AssistantKnowledgeService({
      isConfigured: false,
    } as SupabaseAdminService);

    const locale = await service.detectLanguage(
      'Já concluí meus documentos e agora preciso saber qual é a próxima etapa do plano',
      'pt',
    );

    expect(locale).toBe('pt');
  });

  it('uses FAQ content from Supabase when a published entry matches the corridor', async () => {
    const service = new AssistantKnowledgeService({
      isConfigured: true,
      admin: {
        from: jest.fn((table: string) => {
          if (table === 'assistant_faq_entries') {
            return {
              select: jest.fn().mockReturnThis(),
              eq: jest.fn().mockReturnThis(),
              order: jest.fn().mockResolvedValue({
                data: [
                  {
                    id: 'faq-1',
                    corridor_key: 'argentina->brasil',
                    priority: 500,
                    answer_pt: 'Resposta em portugues',
                    answer_es: 'Respuesta en espanol',
                    answer_en: 'English answer',
                    answer_default: 'English answer',
                  },
                ],
                error: null,
              }),
            };
          }

          return {
            select: jest.fn().mockResolvedValue({
              data: [
                {
                  entry_id: 'faq-1',
                  language_code: 'es',
                  keyword: 'necesito documentos',
                  weight: 1.5,
                },
              ],
              error: null,
            }),
          };
        }),
      },
    } as unknown as SupabaseAdminService);

    const result = await service.resolveFaq(
      'Necesito documentos para Brasil',
      'es',
      'argentina->brasil',
    );

    expect(result.found).toBe(true);
    expect(result.answer).toBe('Respuesta en espanol');
  });
});
