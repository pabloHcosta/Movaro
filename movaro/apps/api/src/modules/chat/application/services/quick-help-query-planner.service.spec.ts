import { QuickHelpQueryPlannerService } from './quick-help-query-planner.service';

describe('QuickHelpQueryPlannerService', () => {
  const planner = new QuickHelpQueryPlannerService();

  it.each([
    ['Como tirar CPF?', 'pt', 'documents.cpf_registration'],
    [
      'Necesito autorización de residencia Mercosur',
      'es',
      'documents.residence_authorization',
    ],
    ['How do I enroll my child in school?', 'en', 'education.basic_enrollment'],
    [
      'O proprietário pode pedir caução e fiador?',
      'pt',
      'housing.rental_guarantees',
    ],
    [
      'Creo que el anuncio de alquiler es una estafa',
      'es',
      'housing.rental_fraud',
    ],
    ['Como acessar a Carteira de Trabalho Digital?', 'pt', 'work.digital_card'],
    ['Can a foreigner access SUS?', 'en', 'health.sus_access'],
    ['Quiero cambiar mi licencia por la CNH', 'es', 'driving.foreign_licence'],
    ['Quanto custa morar no Brasil?', 'pt', 'costs.monthly_budget'],
    ['I want to compare flights', 'en', 'flights.search'],
  ])('routes %s to %s', (query, locale, expectedIntent) => {
    const plan = planner.plan(query, locale as 'pt' | 'es' | 'en');
    expect(plan.matches[0]?.intent.id).toBe(expectedIntent);
  });

  it('matches a specific multilingual intent instead of a broad topic', () => {
    const plan = planner.plan('¿Cómo inscribo a mi hijo en la escuela?', 'es');

    expect(plan.matches[0]?.intent.id).toBe('education.basic_enrollment');
    expect(plan.strategy).toBe('hybrid_lexical_concept');
  });

  it('decomposes clearly compound questions', () => {
    const plan = planner.plan(
      'Preciso matricular meu filho e também acessar o SUS',
      'pt',
    );

    expect(plan.compound).toBe(true);
    expect(plan.matches.map((match) => match.intent.id)).toEqual(
      expect.arrayContaining([
        'education.basic_enrollment',
        'health.sus_access',
      ]),
    );
  });

  it('asks only the high-information clarification for a broad request', () => {
    const plan = planner.plan('Quero estudar no Brasil', 'pt');

    expect(plan.matches[0]?.intent.id).toBe('education.overview');
    expect(plan.clarification?.contextKey).toBe('educationLevel');
  });

  it('uses a clarification answer to select the next intent', () => {
    const plan = planner.plan('Quero estudar no Brasil', 'pt', {
      educationLevel: 'university',
    });

    expect(plan.matches).toHaveLength(1);
    expect(plan.matches[0]?.intent.id).toBe('education.university_admission');
    expect(plan.clarification).toBeNull();
  });

  it('does not mistake CPF inside a rental constraint for a second task', () => {
    const plan = planner.plan(
      'Como alugar sem CPF e sem histórico de crédito?',
      'pt',
    );

    expect(plan.matches.map((match) => match.intent.id)).toEqual([
      'housing.without_brazilian_history',
    ]);
  });

  it.each([
    ['Posso entrar com DNI para morar?', 'pt', 'documents.entry_document'],
    ['Perdí mi CRNM', 'es', 'documents.crnm_lifecycle'],
    ['Can I open an account without CRNM?', 'en', 'finance.bank_account'],
    ['El banco rechazó mi cuenta', 'es', 'finance.bank_refusal'],
    ['Como subir minha conta gov.br para prata?', 'pt', 'finance.govbr_access'],
    ['Como ter Pix sem CRNM?', 'pt', 'finance.pix_access'],
    [
      '¿Cómo envío dinero de Argentina a Brasil?',
      'es',
      'finance.international_remittance',
    ],
    ['Estrangeiro pode ser MEI?', 'pt', 'work.mei_access'],
    [
      'Vivo en Brasil y trabajo remoto para Argentina',
      'es',
      'work.remote_foreign_income',
    ],
    [
      'Do I need professional board registration?',
      'en',
      'work.regulated_profession',
    ],
    ['Quando viro residente fiscal?', 'pt', 'tax.residence_status'],
    ['¿Declaro ingresos de Argentina en Brasil?', 'es', 'tax.foreign_income'],
    ['Who qualifies for family reunification?', 'en', 'family.reunification'],
    ['Autorização para viajar com meu filho', 'pt', 'family.minor_travel'],
    [
      'Posso viajar com protocolo de residência?',
      'pt',
      'documents.travel_during_process',
    ],
    [
      '¿Cómo continúo mi tratamiento en Brasil?',
      'es',
      'health.continuous_treatment',
    ],
    [
      'How do I bring controlled medicine to Brazil?',
      'en',
      'health.controlled_medicine',
    ],
    ['Quantos meses de caução?', 'pt', 'housing.cash_deposit'],
    ['¿Quién paga IPTU y expensas?', 'es', 'housing.contract_lifecycle'],
    ['Como sair do aluguel antes do prazo?', 'pt', 'housing.early_termination'],
    [
      'Is an Argentine diploma valid in Brazil?',
      'en',
      'education.diploma_revalidation',
    ],
    ['Como atualizo minhas vacinas?', 'pt', 'health.vaccination'],
    ['¿Cómo empiezo el prenatal?', 'es', 'health.prenatal'],
    ['How do I access mental healthcare?', 'en', 'health.mental_health'],
    ['Como funciona carência do plano de saúde?', 'pt', 'health.private_plan'],
    ['¿Cómo llevo mi perro a Brasil?', 'es', 'pets_customs.dog_cat'],
    ['What do I declare at the border?', 'en', 'pets_customs.baggage_goods'],
    ['Como ativo chip sem CRNM?', 'pt', 'utilities.mobile_line'],
    ['¿Cómo contrato internet sin CRNM?', 'es', 'utilities.internet_contract'],
    [
      'How do I change the electricity account holder?',
      'en',
      'utilities.electricity',
    ],
    ['Onde denuncio xenofobia?', 'pt', 'protection.discrimination_violence'],
    ['Mi empleador retuvo mi documento', 'es', 'protection.labor_exploitation'],
    [
      'Where can a migrant get free legal aid?',
      'en',
      'protection.legal_social_aid',
    ],
    ['Como reclamar de uma empresa?', 'pt', 'consumer.general_complaint'],
    [
      '¿Cómo reclamo a mi operadora en Anatel?',
      'es',
      'consumer.telecom_complaint',
    ],
    [
      'How does the Brazil Argentina pension agreement work?',
      'en',
      'long_term.social_security',
    ],
    ['Quando posso pedir naturalização?', 'pt', 'long_term.naturalization'],
  ] as const)('routes P0 coverage: %s', (query, locale, expectedIntent) => {
    const plan = planner.plan(query, locale);

    expect(plan.matches[0]?.intent.id).toBe(expectedIntent);
  });
});
