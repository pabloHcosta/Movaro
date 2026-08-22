import { QuickGuideService } from './quick-guide.service';
import { QuickHelpQueryPlannerService } from './quick-help-query-planner.service';
import { QUICK_HELP_ENTRIES } from '../../data/quick-help-trust.catalog';
import { QUICK_HELP_INTENTS } from '../../data/quick-help-intents.catalog';

describe('QuickGuideService', () => {
  let service: QuickGuideService;

  beforeEach(() => {
    jest.useFakeTimers().setSystemTime(new Date('2026-08-22T12:00:00Z'));
    service = new QuickGuideService(new QuickHelpQueryPlannerService());
  });

  afterEach(() => {
    jest.useRealTimers();
  });

  it('returns evidence-linked conditional guidance without a plan action', () => {
    const result = service.resolve({
      message: 'Como funciona a escola pública?',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
      highlightedCityId: 'curitiba-pr',
    });

    expect(result.topic).toBe('education');
    expect(result.coverage).toBe('conditional');
    expect(result.context.cityId).toBe('curitiba-pr');
    expect(result.trust).toEqual(
      expect.objectContaining({
        status: 'conditional',
        evidenceCoverage: 1,
        freshness: 'current',
      }),
    );
    expect(result.claims).toEqual([
      expect.objectContaining({
        evidenceIds: ['mec-basic-education'],
      }),
    ]);
    expect(result.evidence[0]).toEqual(
      expect.objectContaining({
        id: 'mec-basic-education',
        validUntil: '2027-02-18',
      }),
    );
    expect(result.sources).toHaveLength(1);
    expect(result.nextSteps).toHaveLength(2);
    expect(result.fallbackPath).toHaveLength(1);
    expect(result.actions).toEqual([]);
  });

  it('fails safely when reviewed coverage is insufficient', () => {
    const result = service.resolve({
      message: 'Uma dúvida ainda não coberta',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
    });

    expect(result.coverage).toBe('not_covered');
    expect(result.trust.evidenceCoverage).toBe(0);
    expect(result.sources).toEqual([]);
    expect(result.caveats).toHaveLength(1);
    expect(result.recovery?.reason).toBe('unmatched_query');
    expect(result.recovery?.suggestions).toHaveLength(3);
    expect(result.recovery?.suggestions[0]).toEqual(
      expect.objectContaining({
        id: expect.any(String),
        question: expect.any(String),
      }),
    );
  });

  it('does not treat an unmatched question as reviewed evidence', () => {
    const result = service.resolve({
      message: 'Uma pergunta sem entrada editorial',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
    });

    expect(result.coverage).toBe('not_covered');
    expect(result.claims).toEqual([]);
    expect(result.evidence).toEqual([]);
  });

  it('asks for decisive context without hiding the reviewed evidence', () => {
    const result = service.resolve({
      message: 'Quais documentos preciso para residência?',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
    });

    expect(result.coverage).toBe('needs_context');
    expect(result.contextMissing).toContain('residenceBasis');
    expect(result.followUpQuestion?.options).toHaveLength(4);
    expect(result.claims.length).toBeGreaterThan(0);
    expect(result.evidence.length).toBeGreaterThan(0);
  });

  it('downgrades evidence after the editorial validity date', () => {
    jest.setSystemTime(new Date('2028-01-01T12:00:00Z'));
    const result = service.resolve({
      message: 'Como funciona a escola pública?',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
    });

    expect(result.coverage).toBe('partial');
    expect(result.trust.freshness).toBe('expired');
  });

  it('decomposes a compound question into independently sourced sections', () => {
    const result = service.resolve({
      message: 'Preciso matricular meu filho e também acessar o SUS',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
      highlightedCityId: 'curitiba-pr',
    });

    expect(result.answerMode).toBe('multi_part');
    expect(result.sections).toHaveLength(2);
    expect(result.resolvedIntents).toEqual(
      expect.arrayContaining([
        'education.basic_enrollment',
        'health.sus_access',
      ]),
    );
    expect(result.retrieval.compound).toBe(true);
  });

  it('continues a clarification through a deterministic decision branch', () => {
    const result = service.resolve({
      message: 'Quais documentos preciso para residência?',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
      answers: { residenceBasis: 'mercosur' },
    });

    expect(result.coverage).toBe('conditional');
    expect(result.followUpQuestion).toBeNull();
    expect(result.answerMode).toBe('decision_tree');
    expect(result.decisionTitle).toContain('Mercosul');
    expect(result.steps).toHaveLength(2);
  });

  it('identifies a complex unsupported intent instead of returning a broad answer', () => {
    const result = service.resolve({
      message: 'Como alugar sem CPF e sem histórico de crédito?',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
    });

    expect(result.resolvedIntents).toContain(
      'housing.without_brazilian_history',
    );
    expect(result.coverage).toBe('partial');
    expect(result.claims).toEqual([]);
    expect(result.recovery?.reason).toBe('partial_coverage');
    expect(result.recovery?.suggestions[0]?.topic).toBe('housing');
  });

  it.each([
    ['Consigo abrir conta sem CRNM?', 'finance', 'financial'],
    ['Quando viro residente fiscal?', 'tax', 'financial'],
    ['Quem pode pedir reunião familiar?', 'family', 'legal'],
    ['Como levo medicamento controlado para o Brasil?', 'health', 'medical'],
    ['Quantos meses de caução podem pedir?', 'housing', 'legal'],
    ['Posso trabalhar antes de revalidar meu diploma?', 'work', 'legal'],
  ] as const)(
    'returns self-contained evidence for %s',
    (message, topic, riskLevel) => {
      const result = service.resolve({
        message,
        originCountry: 'argentina',
        destinationCountry: 'brasil',
        locale: 'pt',
      });

      expect(result.topic).toBe(topic);
      expect(result.coverage).toBe('conditional');
      expect(result.riskLevel).toBe(riskLevel);
      expect(result.claims.length).toBeGreaterThan(0);
      expect(result.sources.length).toBeGreaterThan(0);
      expect(result.actions).toEqual([]);
      expect(result.nextSteps.length).toBeGreaterThan(0);
      expect(result.fallbackPath.length).toBeGreaterThan(0);
    },
  );

  it('separates entry documents from the residence application lifecycle', () => {
    const result = service.resolve({
      message: 'Posso entrar com DNI para morar no Brasil?',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
    });

    expect(result.resolvedIntents).toContain('documents.entry_document');
    expect(result.claims.map((claim) => claim.id)).toEqual(
      expect.arrayContaining([
        'entry-purpose-changes-document',
        'residence-route-is-separate-from-entry',
      ]),
    );
    expect(result.sources.length).toBeGreaterThanOrEqual(2);
  });

  it.each([
    ['Como atualizo minhas vacinas?', 'health', 'vaccination_calendar'],
    ['Como começo o pré-natal?', 'health', 'pregnancy_prenatal'],
    ['Como levo meu cachorro?', 'pets_customs', 'pet_entry'],
    ['O que declaro na fronteira?', 'pets_customs', 'traveler_customs'],
    ['Como ativo chip sem CRNM?', 'utilities', 'prepaid_registration'],
    ['Como ligo a energia?', 'utilities', 'electricity_consumer_support'],
    ['Onde denuncio xenofobia?', 'protection', 'human_rights_hotline'],
    ['Meu trabalho reteve meu documento', 'protection', 'labor_complaint'],
    ['Como reclamar de uma empresa?', 'consumer', 'consumer_rights'],
    ['Como reclamar da operadora?', 'consumer', 'telecom_complaint'],
    [
      'Como somo contribuições da Argentina e Brasil?',
      'long_term',
      'social_security_agreements',
    ],
    [
      'Quando posso pedir naturalização?',
      'long_term',
      'naturalization_service',
    ],
  ] as const)(
    'returns P1 reviewed evidence in place for %s',
    (message, topic, evidenceId) => {
      const result = service.resolve({
        message,
        originCountry: 'argentina',
        destinationCountry: 'brasil',
        locale: 'pt',
      });

      expect(result.topic).toBe(topic);
      expect(result.coverage).toBe('conditional');
      expect(result.evidence).toContainEqual(
        expect.objectContaining({ id: evidenceId }),
      );
      expect(result.nextSteps.length).toBeGreaterThan(0);
      expect(result.actions).toEqual([]);
    },
  );

  it.each([
    [
      'Meu nome está errado na CRNM',
      'documents.data_divergence',
      'pf-residence-faq',
    ],
    [
      'Meu processo de residência está parado',
      'documents.process_delayed',
      'falabr_ombudsman',
    ],
    [
      'O banco recusou minha conta',
      'finance.bank_refusal',
      'bcb_financial_complaint',
    ],
    [
      'A escola recusou a matrícula por falta de documento',
      'education.enrollment_without_documents',
      'migrant_school_enrollment',
    ],
  ] as const)(
    'returns P2 recovery evidence for %s',
    (message, intentId, evidenceId) => {
      const result = service.resolve({
        message,
        originCountry: 'argentina',
        destinationCountry: 'brasil',
        locale: 'pt',
      });

      expect(result.resolvedIntents).toContain(intentId);
      expect(result.coverage).not.toBe('not_covered');
      expect(result.evidence).toContainEqual(
        expect.objectContaining({ id: evidenceId }),
      );
      expect(result.actions).toEqual([]);
    },
  );

  it('turns a stalled residence process into a short in-place decision path', () => {
    const result = service.resolve({
      message: 'Meu processo de residência está parado',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
      answers: { migrationProcessStage: 'under_review' },
    });

    expect(result.resolvedIntents).toContain('documents.process_delayed');
    expect(result.decisionTitle).toBe('Pedido em análise');
    expect(result.steps).toHaveLength(2);
    expect(result.actions).toEqual([]);
  });

  it('keeps bank-refusal escalation inside Help', () => {
    const result = service.resolve({
      message: 'O banco recusou minha conta',
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      locale: 'pt',
      answers: { bankRefusalReason: 'no_reason' },
    });

    expect(result.decisionTitle).toBe('Recusa sem explicação');
    expect(result.steps).toHaveLength(2);
    expect(result.actions).toEqual([]);
  });

  it('does not suggest Brazil answers for an unsupported destination', () => {
    const result = service.resolve({
      message: 'Como faço o CPF?',
      originCountry: 'argentina',
      destinationCountry: 'uruguai',
      locale: 'pt',
    });

    expect(result.coverage).toBe('not_covered');
    expect(result.recovery?.reason).toBe('unsupported_corridor');
    expect(result.recovery?.suggestions).toEqual([]);
  });

  it('keeps every reviewed claim linked to valid, unique evidence', () => {
    const entryIds = new Set<string>();

    for (const entry of QUICK_HELP_ENTRIES) {
      expect(entryIds.has(entry.id)).toBe(false);
      entryIds.add(entry.id);

      const evidenceIds = new Set(entry.evidence.map((item) => item.id));
      expect(evidenceIds.size).toBe(entry.evidence.length);
      expect(entry.claims.length).toBeGreaterThan(0);
      expect(Date.parse(entry.expiresAt)).not.toBeNaN();

      for (const evidence of entry.evidence) {
        expect(evidence.url).toMatch(/^https:\/\//);
        expect(Date.parse(evidence.checkedAt)).not.toBeNaN();
        expect(Date.parse(evidence.validUntil)).not.toBeNaN();
      }
      for (const claim of entry.claims) {
        expect(claim.evidenceIds.length).toBeGreaterThan(0);
        expect(
          claim.evidenceIds.every((evidenceId) => evidenceIds.has(evidenceId)),
        ).toBe(true);
      }
    }
  });

  it('keeps every intent linked to an existing entry, claim and follow-up target', () => {
    const intentIds = new Set(QUICK_HELP_INTENTS.map((intent) => intent.id));
    expect(intentIds.size).toBe(QUICK_HELP_INTENTS.length);
    const entries = QUICK_HELP_ENTRIES;

    for (const intent of QUICK_HELP_INTENTS) {
      if (intent.entryId) {
        const entry = entries.find((item) => item.id === intent.entryId);
        expect(entry).toBeDefined();
        const claimIds = new Set(entry?.claims.map((claim) => claim.id));
        expect(
          (intent.claimIds ?? []).every((claimId) => claimIds.has(claimId)),
        ).toBe(true);
      }
      for (const option of intent.clarification?.options ?? []) {
        if (option.targetIntentId) {
          expect(intentIds.has(option.targetIntentId)).toBe(true);
        }
      }
    }
  });
});
