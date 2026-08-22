import { QuickGuideService } from './quick-guide.service';
import { QuickHelpQueryPlannerService } from './quick-help-query-planner.service';

describe('Quick Guide P3 quality evaluation', () => {
  const service = new QuickGuideService(new QuickHelpQueryPlannerService());

  beforeAll(() => {
    jest.useFakeTimers().setSystemTime(new Date('2026-08-22T12:00:00Z'));
  });

  afterAll(() => {
    jest.useRealTimers();
  });

  it.each([
    ['pt', 'Como faço o CPF?', 'documents.cpf_registration'],
    ['es', '¿Cómo tramito el CPF?', 'documents.cpf_registration'],
    ['en', 'How do I get a CPF?', 'documents.cpf_registration'],
    ['pt', 'Como matriculo meu filho na escola?', 'education.basic_enrollment'],
    [
      'es',
      '¿Cómo inscribo a mi hijo en la escuela?',
      'education.basic_enrollment',
    ],
    ['en', 'How do I enroll my child in school?', 'education.basic_enrollment'],
    [
      'pt',
      'Quais garantias podem pedir no aluguel?',
      'housing.rental_guarantees',
    ],
    ['es', '¿Cómo accede un extranjero al SUS?', 'health.sus_access'],
    ['en', 'What do I need for formal work?', 'work.digital_card'],
    [
      'pt',
      'Quero trocar minha habilitação pela CNH',
      'driving.foreign_licence',
    ],
    ['pt', 'Como ter Pix sem CRNM?', 'finance.pix_access'],
    [
      'es',
      '¿Cómo envío dinero de Argentina a Brasil?',
      'finance.international_remittance',
    ],
    ['en', 'When do I become a tax resident?', 'tax.residence_status'],
    ['pt', 'Quem pode pedir reunião familiar?', 'family.reunification'],
    [
      'es',
      '¿Cómo llevo un medicamento controlado a Brasil?',
      'health.controlled_medicine',
    ],
    [
      'en',
      'Is an Argentine diploma valid in Brazil?',
      'education.diploma_revalidation',
    ],
    [
      'pt',
      'Posso viajar com protocolo de residência?',
      'documents.travel_during_process',
    ],
    [
      'es',
      '¿Cómo salgo del alquiler antes del plazo?',
      'housing.early_termination',
    ],
    ['pt', 'Como atualizo minhas vacinas?', 'health.vaccination'],
    ['es', '¿Cómo empiezo el prenatal?', 'health.prenatal'],
    ['en', 'How do I access mental healthcare?', 'health.mental_health'],
    ['pt', 'Como levo meu cachorro para o Brasil?', 'pets_customs.dog_cat'],
    ['es', '¿Qué declaro en la frontera?', 'pets_customs.baggage_goods'],
    ['en', 'How do I activate a SIM without CRNM?', 'utilities.mobile_line'],
    [
      'pt',
      'Onde denuncio exploração no trabalho?',
      'protection.labor_exploitation',
    ],
    ['es', '¿Cómo reclamo contra una empresa?', 'consumer.general_complaint'],
    [
      'en',
      'How does the Brazil Argentina pension agreement work?',
      'long_term.social_security',
    ],
    [
      'pt',
      'Meu processo de residência está parado',
      'documents.process_delayed',
    ],
    ['es', 'El banco rechazó mi cuenta', 'finance.bank_refusal'],
    [
      'en',
      'School refused enrollment due to missing documents',
      'education.enrollment_without_documents',
    ],
  ] as const)(
    'resolves the reviewed intent in %s: %s',
    (locale, message, expectedIntent) => {
      const result = service.resolve({
        message,
        originCountry: 'argentina',
        destinationCountry: 'brasil',
        locale,
      });

      expect(result.resolvedIntents).toContain(expectedIntent);
      expect(result.coverage).not.toBe('not_covered');
      expect(result.actions).toEqual([]);
    },
  );

  it('keeps independently sourced intents separate in a compound question', () => {
    const result = service.resolve({
      message: 'Preciso matricular meu filho e também acessar o SUS',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
    });

    expect(result.sections.map((section) => section.intentId)).toEqual(
      expect.arrayContaining([
        'education.basic_enrollment',
        'health.sus_access',
      ]),
    );
    expect(
      result.sections.every((section) => section.claimIds.length > 0),
    ).toBe(true);
  });

  it.each([
    ['pt', 'Qual é o melhor banco do Brasil?'],
    ['es', 'Decime exactamente cuánto impuesto voy a pagar'],
    ['en', 'Diagnose this severe chest pain for me'],
  ] as const)(
    'fails safely outside reviewed coverage in %s',
    (locale, message) => {
      const result = service.resolve({
        message,
        originCountry: 'argentina',
        destinationCountry: 'brasil',
        locale,
      });

      expect(['partial', 'not_covered']).toContain(result.coverage);
      if (result.coverage === 'not_covered') {
        expect(result.claims).toEqual([]);
        expect(result.sources).toEqual([]);
        expect(result.recovery?.suggestions.length).toBeGreaterThan(0);
      }
    },
  );

  it.each(['pt', 'es', 'en'] as const)(
    'only offers recovery questions that resolve to reviewed evidence in %s',
    (locale) => {
      const firstAttempt = service.resolve({
        message: 'xyzzy unsupported request',
        originCountry: 'argentina',
        destinationCountry: 'brasil',
        locale,
      });

      expect(firstAttempt.coverage).toBe('not_covered');
      expect(firstAttempt.recovery?.suggestions.length).toBeGreaterThan(0);
      for (const suggestion of firstAttempt.recovery?.suggestions ?? []) {
        const recovered = service.resolve({
          message: suggestion.question,
          originCountry: 'argentina',
          destinationCountry: 'brasil',
          locale,
        });
        expect(recovered.coverage).not.toBe('not_covered');
        expect(recovered.claims.length).toBeGreaterThan(0);
        expect(recovered.sources.length).toBeGreaterThan(0);
      }
    },
  );
});
