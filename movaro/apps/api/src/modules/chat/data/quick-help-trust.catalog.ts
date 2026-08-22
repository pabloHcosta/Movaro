export type QuickHelpLocale = 'pt' | 'es' | 'en';
export type QuickHelpTopic =
  | 'documents'
  | 'education'
  | 'housing'
  | 'work'
  | 'health'
  | 'finance'
  | 'tax'
  | 'family'
  | 'pets_customs'
  | 'utilities'
  | 'protection'
  | 'consumer'
  | 'long_term'
  | 'costs'
  | 'driving'
  | 'flights'
  | 'general';
export type QuickHelpRiskLevel =
  | 'low'
  | 'medium'
  | 'legal'
  | 'medical'
  | 'financial';
export type QuickHelpCoverageStatus =
  | 'confirmed'
  | 'conditional'
  | 'needs_context'
  | 'partial'
  | 'not_covered';

export type LocalizedText = Record<QuickHelpLocale, string>;

export interface QuickHelpEvidenceDefinition {
  id: string;
  publisher: string;
  title: LocalizedText;
  url: string;
  checkedAt: string;
  validUntil: string;
  jurisdiction: string;
  scope: LocalizedText;
}

export interface QuickHelpClaimDefinition {
  id: string;
  text: LocalizedText;
  evidenceIds: string[];
  status: 'verified' | 'conditional';
}

export interface QuickHelpEntryDefinition {
  id: string;
  topic: QuickHelpTopic;
  contentVersion: string;
  editorialOwner: string;
  reviewedAt: string;
  expiresAt: string;
  jurisdiction: string;
  riskLevel: QuickHelpRiskLevel;
  answerMode: 'direct' | 'decision_tree' | 'referral';
  coverageStatus: Extract<QuickHelpCoverageStatus, 'confirmed' | 'conditional'>;
  claims: QuickHelpClaimDefinition[];
  evidence: QuickHelpEvidenceDefinition[];
  caveat?: LocalizedText;
}

const CONTENT_VERSION = '2026.08.22-p2-recovery';
const EDITORIAL_OWNER = 'Movaro Content Operations';

export const QUICK_HELP_ENTRIES: QuickHelpEntryDefinition[] = [
  {
    id: 'documents-cpf-residence-overview',
    topic: 'documents',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-18',
    expiresAt: '2026-11-18',
    jurisdiction: 'BR-federal',
    riskLevel: 'legal',
    answerMode: 'direct',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'documents-cpf-and-residence-are-separate',
        text: {
          pt: 'CPF e autorização de residência são procedimentos diferentes: obter CPF não regulariza, por si só, a situação migratória.',
          es: 'El CPF y la autorización de residencia son trámites diferentes: obtener el CPF no regulariza por sí solo la situación migratoria.',
          en: 'CPF registration and residence authorization are separate procedures: obtaining a CPF does not by itself regularize migration status.',
        },
        evidenceIds: ['receita-cpf', 'pf-residence'],
        status: 'verified',
      },
      {
        id: 'documents-confirm-route',
        text: {
          pt: 'A rota e os documentos da residência dependem do fundamento do pedido; confirme o serviço correspondente na Polícia Federal.',
          es: 'La vía y los documentos de residencia dependen del fundamento de la solicitud; confirmá el servicio correspondiente en la Policía Federal.',
          en: 'The residence route and required documents depend on the basis of the application; confirm the applicable service with the Federal Police.',
        },
        evidenceIds: ['pf-residence'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'receita-cpf',
        publisher: 'Receita Federal',
        title: {
          pt: 'Inscrição no CPF',
          es: 'Inscripción en el CPF',
          en: 'CPF registration',
        },
        url: 'https://www.gov.br/pt-br/servicos/inscrever-no-cpf?id=10416&origem=servico',
        checkedAt: '2026-08-18',
        validUntil: '2026-11-18',
        jurisdiction: 'BR-federal',
        scope: {
          pt: 'Procedimento oficial de inscrição no CPF.',
          es: 'Procedimiento oficial de inscripción en el CPF.',
          en: 'Official CPF registration procedure.',
        },
      },
      {
        id: 'pf-residence',
        publisher: 'Polícia Federal',
        title: {
          pt: 'Autorização de residência',
          es: 'Autorización de residencia',
          en: 'Residence authorization',
        },
        url: 'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia',
        checkedAt: '2026-08-18',
        validUntil: '2026-11-18',
        jurisdiction: 'BR-federal',
        scope: {
          pt: 'Rotas e serviços federais de autorização de residência.',
          es: 'Vías y servicios federales de autorización de residencia.',
          en: 'Federal residence authorization routes and services.',
        },
      },
    ],
    caveat: {
      pt: 'A resposta não identifica ainda qual fundamento de residência se aplica ao seu caso.',
      es: 'La respuesta todavía no identifica qué fundamento de residencia se aplica a tu caso.',
      en: 'The answer does not yet identify which residence basis applies to your case.',
    },
  },
  {
    id: 'education-basic-network-overview',
    topic: 'education',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-18',
    expiresAt: '2027-02-18',
    jurisdiction: 'BR-federal-local-operation',
    riskLevel: 'medium',
    answerMode: 'direct',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'education-network-first-step',
        text: {
          pt: 'Para matrícula na educação básica, procure a rede municipal ou estadual responsável pelo endereço e confirme nela a documentação e a vaga.',
          es: 'Para la matrícula en educación básica, buscá la red municipal o estadual correspondiente al domicilio y confirmá allí la documentación y la vacante.',
          en: 'For basic-school enrollment, contact the municipal or state network responsible for the address and confirm documents and placement with it.',
        },
        evidenceIds: ['mec-basic-education'],
        status: 'conditional',
      },
      {
        id: 'education-migrant-enrollment-cannot-wait-for-regularization',
        text: {
          pt: 'A falta de documentos escolares ou migratórios não deve impedir o pedido de matrícula de criança ou adolescente migrante; a rede deve orientar classificação ou reclassificação quando não houver comprovação escolar suficiente.',
          es: 'La falta de documentos escolares o migratorios no debe impedir la solicitud de matrícula de una niña, niño o adolescente migrante; la red debe orientar la clasificación o reclasificación cuando no haya comprobación escolar suficiente.',
          en: 'Missing school or migration documents should not prevent a migrant child or teenager from requesting enrollment; the school network should guide classification or reclassification when prior schooling cannot be sufficiently documented.',
        },
        evidenceIds: ['migrant_school_enrollment'],
        status: 'verified',
      },
    ],
    evidence: [
      {
        id: 'mec-basic-education',
        publisher: 'Ministério da Educação',
        title: {
          pt: 'Educação básica',
          es: 'Educación básica',
          en: 'Basic education',
        },
        url: 'https://www.gov.br/mec/pt-br/assuntos/eb',
        checkedAt: '2026-08-18',
        validUntil: '2027-02-18',
        jurisdiction: 'BR-federal-local-operation',
        scope: {
          pt: 'Visão federal da educação básica; procedimentos de matrícula variam por rede local.',
          es: 'Información federal sobre educación básica; la matrícula varía según la red local.',
          en: 'Federal basic-education overview; enrollment procedures vary by local network.',
        },
      },
      {
        id: 'migrant_school_enrollment',
        publisher: 'Conselho Nacional de Educação',
        title: {
          pt: 'Diretrizes para matrícula de crianças e adolescentes migrantes',
          es: 'Directrices para la matrícula de niñas, niños y adolescentes migrantes',
          en: 'Guidelines for enrolling migrant children and teenagers',
        },
        url: 'https://www.gov.br/mec/pt-br/assuntos/noticias/2020/novembro/cne-aprova-diretrizes-para-matricula-de-criancas-e-adolescentes-migrantes-refugiados-apatridas-e-solicitantes-de-refugio',
        checkedAt: '2026-08-22',
        validUntil: '2027-02-22',
        jurisdiction: 'BR-federal-local-operation',
        scope: {
          pt: 'Matrícula, documentação ausente e classificação na educação básica.',
          es: 'Matrícula, documentación ausente y clasificación en educación básica.',
          en: 'Enrollment, missing documents, and placement in basic education.',
        },
      },
    ],
    caveat: {
      pt: 'Documentos, calendário e disponibilidade são operados pela rede municipal ou estadual.',
      es: 'Los documentos, el calendario y la disponibilidad son gestionados por la red municipal o estadual.',
      en: 'Documents, calendar, and availability are handled by the municipal or state network.',
    },
  },
  {
    id: 'housing-rental-guarantees',
    topic: 'housing',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-18',
    expiresAt: '2026-11-18',
    jurisdiction: 'BR-federal',
    riskLevel: 'legal',
    answerMode: 'direct',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'housing-one-guarantee',
        text: {
          pt: 'No mesmo contrato de locação, o locador pode exigir uma modalidade de garantia prevista em lei, mas não mais de uma simultaneamente.',
          es: 'En un mismo contrato de alquiler, el propietario puede exigir una modalidad de garantía prevista por ley, pero no más de una al mismo tiempo.',
          en: 'In the same tenancy agreement, the landlord may require one legally permitted guarantee, but not more than one at the same time.',
        },
        evidenceIds: ['tenancy-law'],
        status: 'verified',
      },
    ],
    evidence: [
      {
        id: 'tenancy-law',
        publisher: 'Planalto',
        title: {
          pt: 'Lei do Inquilinato',
          es: 'Ley de alquileres de Brasil',
          en: 'Brazilian Tenancy Law',
        },
        url: 'https://www.planalto.gov.br/ccivil_03/leis/l8245.htm',
        checkedAt: '2026-08-18',
        validUntil: '2026-11-18',
        jurisdiction: 'BR-federal',
        scope: {
          pt: 'Modalidades e limites legais das garantias locatícias.',
          es: 'Modalidades y límites legales de las garantías de alquiler.',
          en: 'Legal types and limits of tenancy guarantees.',
        },
      },
    ],
    caveat: {
      pt: 'Esta orientação não valida um contrato específico nem a identidade de quem está cobrando.',
      es: 'Esta orientación no valida un contrato específico ni la identidad de quien cobra.',
      en: 'This guidance does not validate a specific contract or the identity of the person requesting payment.',
    },
  },
  {
    id: 'work-digital-card',
    topic: 'work',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-18',
    expiresAt: '2027-02-18',
    jurisdiction: 'BR-federal',
    riskLevel: 'medium',
    answerMode: 'direct',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'work-ctps-service',
        text: {
          pt: 'A Carteira de Trabalho Digital é o serviço oficial para acompanhar vínculos formais; o acesso não substitui a verificação da situação migratória aplicável ao seu caso.',
          es: 'La Libreta de Trabajo Digital es el servicio oficial para consultar vínculos formales; el acceso no reemplaza la verificación de la situación migratoria aplicable a tu caso.',
          en: 'The Digital Work Card is the official service for formal employment records; access does not replace checking the migration status applicable to your case.',
        },
        evidenceIds: ['digital-work-card'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'digital-work-card',
        publisher: 'Ministério do Trabalho e Emprego',
        title: {
          pt: 'Carteira de Trabalho Digital',
          es: 'Libreta de Trabajo Digital',
          en: 'Digital Work Card',
        },
        url: 'https://www.gov.br/pt-br/servicos/obter-a-carteira-de-trabalho',
        checkedAt: '2026-08-18',
        validUntil: '2027-02-18',
        jurisdiction: 'BR-federal',
        scope: {
          pt: 'Acesso e uso do serviço oficial da Carteira de Trabalho Digital.',
          es: 'Acceso y uso del servicio oficial de la Libreta de Trabajo Digital.',
          en: 'Access to and use of the official Digital Work Card service.',
        },
      },
    ],
    caveat: {
      pt: 'A resposta não verifica sua autorização individual para trabalhar nem uma oferta de emprego específica.',
      es: 'La respuesta no verifica tu autorización individual para trabajar ni una oferta específica.',
      en: 'The answer does not verify your individual authorization to work or a specific job offer.',
    },
  },
  {
    id: 'health-sus-access',
    topic: 'health',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-18',
    expiresAt: '2026-11-18',
    jurisdiction: 'BR-federal-local-operation',
    riskLevel: 'medical',
    answerMode: 'referral',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'health-foreign-access',
        text: {
          pt: 'Pessoas estrangeiras podem acessar o SUS; para atendimento e acompanhamento, a unidade local orienta o cadastro e os documentos usados no município.',
          es: 'Las personas extranjeras pueden acceder al SUS; para atención y seguimiento, la unidad local orienta sobre el registro y los documentos del municipio.',
          en: 'Foreign nationals can access SUS; for care and follow-up, the local unit provides guidance on registration and documents used by the municipality.',
        },
        evidenceIds: ['sus_foreigner'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'sus_foreigner',
        publisher: 'Ministério da Saúde',
        title: {
          pt: 'Acesso de estrangeiros ao SUS',
          es: 'Acceso de extranjeros al SUS',
          en: 'SUS access for foreign nationals',
        },
        url: 'https://www.gov.br/saude/pt-br/composicao/saps/equidade-em-saude/saude-de-migrantes-refugiados-e-apatridas',
        checkedAt: '2026-08-18',
        validUntil: '2026-11-18',
        jurisdiction: 'BR-federal-local-operation',
        scope: {
          pt: 'Diretriz nacional de acesso de pessoas estrangeiras ao SUS.',
          es: 'Directriz nacional de acceso de personas extranjeras al SUS.',
          en: 'National guidance on SUS access for foreign nationals.',
        },
      },
    ],
    caveat: {
      pt: 'Isto é orientação de acesso ao sistema, não avaliação médica. Em urgência, procure atendimento imediato.',
      es: 'Esta es una orientación de acceso al sistema, no una evaluación médica. En una urgencia, buscá atención inmediata.',
      en: 'This is healthcare-access guidance, not medical assessment. Seek immediate care in an emergency.',
    },
  },
  {
    id: 'driving-foreign-licence-overview',
    topic: 'driving',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-18',
    expiresAt: '2026-11-18',
    jurisdiction: 'BR-federal-state-operation',
    riskLevel: 'legal',
    answerMode: 'direct',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'driving-check-conditions',
        text: {
          pt: 'O uso de habilitação estrangeira no Brasil depende das condições do documento e da permanência; confirme a regra nacional e o procedimento do Detran do estado antes de dirigir ou solicitar a troca.',
          es: 'El uso de una licencia extranjera en Brasil depende de las condiciones del documento y de la permanencia; confirmá la regla nacional y el trámite del Detran estadual antes de conducir o solicitar el cambio.',
          en: 'Use of a foreign licence in Brazil depends on document and stay conditions; confirm the national rule and the state Detran procedure before driving or requesting an exchange.',
        },
        evidenceIds: ['senatran-driving'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'senatran-driving',
        publisher: 'Senatran',
        title: {
          pt: 'Dirigir no Brasil',
          es: 'Conducir en Brasil',
          en: 'Driving in Brazil',
        },
        url: 'https://www.gov.br/transportes/pt-br/assuntos/transito/conteudo-Senatran/dirigir-no-brasil',
        checkedAt: '2026-08-18',
        validUntil: '2026-11-18',
        jurisdiction: 'BR-federal-state-operation',
        scope: {
          pt: 'Condições nacionais para dirigir no Brasil; a execução pode depender do Detran estadual.',
          es: 'Condiciones nacionales para conducir en Brasil; la gestión puede depender del Detran estadual.',
          en: 'National conditions for driving in Brazil; implementation may depend on the state Detran.',
        },
      },
    ],
    caveat: {
      pt: 'Sem país emissor, validade da habilitação e tempo de permanência, a resposta não confirma sua autorização individual para dirigir.',
      es: 'Sin país emisor, vigencia de la licencia y tiempo de permanencia, la respuesta no confirma tu autorización individual para conducir.',
      en: 'Without issuing country, licence validity, and length of stay, the answer does not confirm your individual authorization to drive.',
    },
  },
  {
    id: 'documents-entry-residence-lifecycle',
    topic: 'documents',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2026-11-22',
    jurisdiction: 'BR-federal-Mercosur',
    riskLevel: 'legal',
    answerMode: 'decision_tree',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'entry-purpose-changes-document',
        text: {
          pt: 'O documento usado em uma viagem turística no Mercosul não deve ser presumido como suficiente para uma mudança: a Polícia Federal orienta o uso de passaporte em viagens com finalidade de trabalho, estudo, residência ou saúde.',
          es: 'El documento usado para un viaje turístico en el Mercosur no debe presumirse suficiente para una mudanza: la Policía Federal indica pasaporte para viajes por trabajo, estudio, residencia o salud.',
          en: 'A document used for Mercosur tourism should not be assumed sufficient for a move: Federal Police guidance calls for a passport for work, study, residence, or health travel.',
        },
        evidenceIds: ['pf-mercosur-travel-document'],
        status: 'conditional',
      },
      {
        id: 'residence-route-is-separate-from-entry',
        text: {
          pt: 'A entrada no país e o pedido de autorização de residência são etapas diferentes; nacionais argentinos devem selecionar na Polícia Federal o serviço e o fundamento de residência correspondentes ao caso.',
          es: 'El ingreso al país y la solicitud de residencia son etapas diferentes; las personas argentinas deben elegir en la Policía Federal el servicio y fundamento correspondiente a su caso.',
          en: 'Entry into Brazil and a residence application are separate stages; Argentine nationals must select the Federal Police service and residence basis that matches their case.',
        },
        evidenceIds: ['pf-residence-faq', 'pf-argentina-residence'],
        status: 'conditional',
      },
      {
        id: 'crnm-lifecycle-has-specific-services',
        text: {
          pt: 'Renovar ou transformar a residência, registrar uma autorização já aprovada, substituir a CRNM e pedir segunda via são serviços diferentes; use o serviço correspondente ao estado atual do processo.',
          es: 'Renovar o transformar la residencia, registrar una autorización aprobada, sustituir la CRNM y pedir un duplicado son trámites diferentes; usá el que corresponda al estado actual del proceso.',
          en: 'Renewing or changing residence, registering an approved authorization, replacing a CRNM, and requesting a duplicate are different services; use the one matching the current process state.',
        },
        evidenceIds: ['pf-residence-faq'],
        status: 'verified',
      },
      {
        id: 'residence-travel-needs-reentry-check',
        text: {
          pt: 'Antes de sair do Brasil com residência ou registro em andamento, confirme com a Polícia Federal a validade dos documentos disponíveis e os requisitos de reentrada; protocolo, autorização aprovada e CRNM física são estados diferentes.',
          es: 'Antes de salir de Brasil con la residencia o registro en trámite, confirmá con la Policía Federal la vigencia de los documentos y los requisitos de reingreso; protocolo, autorización aprobada y CRNM física son estados diferentes.',
          en: 'Before leaving Brazil with residence or registration in progress, confirm document validity and re-entry requirements with Federal Police; a protocol, approved authorization, and physical CRNM are different states.',
        },
        evidenceIds: ['pf-residence-faq'],
        status: 'conditional',
      },
      {
        id: 'residence-divergence-needs-specific-correction',
        text: {
          pt: 'Nome, filiação, data ou outro dado divergente não deve ser corrigido iniciando um pedido genérico novo: identifique se o erro está no requerimento, no registro ou na CRNM e use o serviço específico indicado pela Polícia Federal.',
          es: 'Un nombre, filiación, fecha u otro dato divergente no debe corregirse iniciando una solicitud genérica nueva: identificá si el error está en la solicitud, el registro o la CRNM y usá el trámite específico indicado por la Policía Federal.',
          en: 'A conflicting name, parentage, date, or other detail should not be corrected through a new generic application: identify whether the error is in the application, registration, or CRNM and use the specific Federal Police service.',
        },
        evidenceIds: ['pf-residence-faq'],
        status: 'conditional',
      },
      {
        id: 'residence-delay-needs-traceable-escalation',
        text: {
          pt: 'Se o processo não avançar, guarde número do requerimento, protocolo, unidade, data e comprovantes; peça primeiro atualização no canal responsável e, sem solução, registre uma manifestação rastreável na ouvidoria sem confundir ouvidoria com recurso jurídico.',
          es: 'Si el trámite no avanza, guardá número de solicitud, protocolo, unidad, fecha y comprobantes; pedí primero una actualización al canal responsable y, si no se resuelve, registrá una manifestación rastreable en la defensoría sin confundirla con un recurso jurídico.',
          en: 'If the process does not move forward, keep the application number, protocol, office, date, and receipts; first request an update from the responsible channel and, if unresolved, file a traceable ombudsman report without treating it as a legal appeal.',
        },
        evidenceIds: ['pf-residence-faq', 'falabr_ombudsman'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'pf-mercosur-travel-document',
        publisher: 'Polícia Federal',
        title: {
          pt: 'Documento de viagem no Mercosul',
          es: 'Documento de viaje en el Mercosur',
          en: 'Mercosur travel documents',
        },
        url: 'https://www.gov.br/pf/pt-br/assuntos/passaporte/suporte/duvidas_/inicio/mercosul',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-Mercosur',
        scope: {
          pt: 'Documento de viagem conforme a finalidade declarada da entrada.',
          es: 'Documento de viaje según la finalidad declarada del ingreso.',
          en: 'Travel document according to the declared purpose of entry.',
        },
      },
      {
        id: 'pf-residence-faq',
        publisher: 'Polícia Federal',
        title: {
          pt: 'Dúvidas frequentes de imigração',
          es: 'Preguntas frecuentes de inmigración',
          en: 'Immigration frequently asked questions',
        },
        url: 'https://www.gov.br/pf/pt-br/assuntos/imigracao/duvidas-frequentes',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal',
        scope: {
          pt: 'Serviços de residência, registro, renovação, substituição e segunda via.',
          es: 'Trámites de residencia, registro, renovación, sustitución y duplicado.',
          en: 'Residence, registration, renewal, replacement, and duplicate services.',
        },
      },
      {
        id: 'pf-argentina-residence',
        publisher: 'Polícia Federal',
        title: {
          pt: 'Acordo de residência Brasil–Argentina',
          es: 'Acuerdo de residencia Brasil–Argentina',
          en: 'Brazil–Argentina residence agreement',
        },
        url: 'https://www.gov.br/pf/pt-br/assuntos/imigracao/autorizacao-residencia/acordo-de-residencia-brasil-e-argentina',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-bilateral',
        scope: {
          pt: 'Serviço de residência aplicável a nacionais da Argentina.',
          es: 'Trámite de residencia aplicable a nacionales de Argentina.',
          en: 'Residence service applicable to Argentine nationals.',
        },
      },
      {
        id: 'falabr_ombudsman',
        publisher: 'Controladoria-Geral da União',
        title: {
          pt: 'Fala.BR — Plataforma de Ouvidoria',
          es: 'Fala.BR — Plataforma de defensoría',
          en: 'Fala.BR — Federal ombudsman platform',
        },
        url: 'https://falabr.cgu.gov.br/web/home',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-ombudsman',
        scope: {
          pt: 'Registro e acompanhamento de manifestações dirigidas a órgãos federais.',
          es: 'Registro y seguimiento de manifestaciones dirigidas a organismos federales.',
          en: 'Filing and tracking reports addressed to federal agencies.',
        },
      },
    ],
    caveat: {
      pt: 'Não viaje com base apenas nesta síntese. Confirme antes da saída o documento de entrada, o fundamento e a lista vigente do serviço escolhido.',
      es: 'No viajes basándote solamente en este resumen. Confirmá antes de salir el documento de ingreso, el fundamento y la lista vigente del trámite elegido.',
      en: 'Do not travel based only on this summary. Before departure, confirm the entry document, basis, and current list for the selected service.',
    },
  },
  {
    id: 'finance-banking-pix-govbr',
    topic: 'finance',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2026-11-22',
    jurisdiction: 'BR-federal-institution-operation',
    riskLevel: 'financial',
    answerMode: 'decision_tree',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'finance-foreign-id-may-be-accepted',
        text: {
          pt: 'Uma instituição pode aceitar documento estrangeiro reconhecido para identificar a pessoa migrante, mas define seus requisitos e não é obrigada a aprovar a abertura da conta.',
          es: 'Una institución puede aceptar un documento extranjero reconocido para identificar a la persona migrante, pero define sus requisitos y no está obligada a aprobar la cuenta.',
          en: 'An institution may accept a recognized foreign document to identify a migrant, but it sets its requirements and is not required to approve the account.',
        },
        evidenceIds: ['bcb-migrant-finance'],
        status: 'conditional',
      },
      {
        id: 'finance-govbr-levels-differ',
        text: {
          pt: 'A conta gov.br possui níveis bronze, prata e ouro; CPF pode iniciar o cadastro, mas serviços sensíveis podem exigir validação adicional por banco, biometria ou certificado.',
          es: 'La cuenta gov.br tiene niveles bronce, plata y oro; el CPF puede iniciar el registro, pero servicios sensibles pueden exigir validación adicional por banco, biometría o certificado.',
          en: 'A gov.br account has bronze, silver, and gold levels; CPF can start registration, but sensitive services may require additional bank, biometric, or certificate validation.',
        },
        evidenceIds: ['govbr-account-levels'],
        status: 'verified',
      },
      {
        id: 'finance-pix-requires-participating-account',
        text: {
          pt: 'O Pix é usado por meio de uma conta corrente, poupança ou conta de pagamento pré-paga em instituição participante; não é um aplicativo nem um documento migratório separado.',
          es: 'Pix se usa mediante una cuenta corriente, de ahorro o de pago prepaga en una institución participante; no es una aplicación ni un documento migratorio separado.',
          en: 'Pix is used through a current, savings, or prepaid payment account at a participating institution; it is not a separate app or migration document.',
        },
        evidenceIds: ['bcb-pix-faq'],
        status: 'verified',
      },
      {
        id: 'finance-remittance-needs-authorized-provider',
        text: {
          pt: 'Para enviar ou receber recursos do exterior, confirme previamente com instituição autorizada os documentos, a taxa de câmbio, o IOF, as tarifas e o Valor Efetivo Total da operação.',
          es: 'Para enviar o recibir dinero del exterior, confirmá previamente con una institución autorizada los documentos, tipo de cambio, IOF, tarifas y costo efectivo total.',
          en: 'To send or receive money internationally, confirm documents, exchange rate, IOF, fees, and the total effective cost with an authorized institution beforehand.',
        },
        evidenceIds: ['bcb-international-remittance'],
        status: 'conditional',
      },
      {
        id: 'finance-refusal-needs-reason-and-escalation',
        text: {
          pt: 'Uma recusa de conta não prova que todo migrante precisa de CRNM: peça a exigência e o motivo no canal oficial da instituição, guarde o protocolo e, após atendimento e ouvidoria, use o canal do Banco Central quando a reclamação envolver instituição supervisionada.',
          es: 'El rechazo de una cuenta no demuestra que toda persona migrante necesite CRNM: pedí el requisito y el motivo por el canal oficial de la institución, guardá el protocolo y, después de atención y defensoría, usá el canal del Banco Central cuando se trate de una entidad supervisada.',
          en: 'An account refusal does not prove that every migrant needs a CRNM: request the requirement and reason through the institution’s official channel, keep the protocol, and after customer service and ombudsman review use the Central Bank channel for a supervised institution.',
        },
        evidenceIds: ['bcb-migrant-finance', 'bcb_financial_complaint'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'bcb-migrant-finance',
        publisher: 'Banco Central do Brasil',
        title: {
          pt: 'Informações financeiras para migrantes e refugiados',
          es: 'Información financiera para migrantes y refugiados',
          en: 'Financial information for migrants and refugees',
        },
        url: 'https://www.gov.br/mj/pt-br/assuntos/seus-direitos/refugio/publicacoes/anexos/cartilha-bc-portugues_versao-4-0_final.pdf',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-institution-operation',
        scope: {
          pt: 'Identificação, abertura de conta, serviços financeiros e canais de reclamação.',
          es: 'Identificación, apertura de cuenta, servicios financieros y reclamos.',
          en: 'Identification, account opening, financial services, and complaint channels.',
        },
      },
      {
        id: 'govbr-account-levels',
        publisher: 'Governo Digital',
        title: {
          pt: 'Níveis da conta gov.br',
          es: 'Niveles de la cuenta gov.br',
          en: 'gov.br account levels',
        },
        url: 'https://www.gov.br/governodigital/pt-br/identidade/conta-gov-br/niveis-da-conta-govbr/saiba-mais-sobre-os-niveis-da-conta-govbr',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal',
        scope: {
          pt: 'Criação, níveis de segurança e meios de validação da conta gov.br.',
          es: 'Creación, niveles de seguridad y validación de la cuenta gov.br.',
          en: 'Creation, security levels, and validation methods for gov.br accounts.',
        },
      },
      {
        id: 'bcb-pix-faq',
        publisher: 'Banco Central do Brasil',
        title: {
          pt: 'Perguntas frequentes sobre Pix',
          es: 'Preguntas frecuentes sobre Pix',
          en: 'Pix frequently asked questions',
        },
        url: 'https://www.bcb.gov.br/meubc/faqs/s/pix',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-financial',
        scope: {
          pt: 'Quem pode usar Pix, tipos de conta e funcionamento de chaves.',
          es: 'Quién puede usar Pix, tipos de cuenta y funcionamiento de claves.',
          en: 'Who can use Pix, account types, and how keys work.',
        },
      },
      {
        id: 'bcb-international-remittance',
        publisher: 'Banco Central do Brasil',
        title: {
          pt: 'Enviar ou receber recursos do exterior',
          es: 'Enviar o recibir recursos del exterior',
          en: 'Sending or receiving funds internationally',
        },
        url: 'https://www.bcb.gov.br/meubc/faqs/p/como-faco-para-enviar-recursos-para-o-exterior-ou-para-receber-recursos-do-exterior-em-moeda-estrangeira',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-foreign-exchange',
        scope: {
          pt: 'Instituição autorizada, documentação e custo efetivo da operação de câmbio.',
          es: 'Institución autorizada, documentación y costo efectivo de la operación cambiaria.',
          en: 'Authorized institution, documents, and effective cost of a foreign-exchange transaction.',
        },
      },
      {
        id: 'bcb_financial_complaint',
        publisher: 'Banco Central do Brasil',
        title: {
          pt: 'Registrar reclamação contra instituição supervisionada',
          es: 'Registrar un reclamo contra una entidad supervisada',
          en: 'File a complaint about a supervised institution',
        },
        url: 'https://www.bcb.gov.br/meubc/registrar_reclamacao',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-financial-supervision',
        scope: {
          pt: 'Sequência, limites e canal de reclamação sobre instituição supervisionada.',
          es: 'Secuencia, límites y canal de reclamo sobre una entidad supervisada.',
          en: 'Sequence, limits, and complaint channel for a supervised institution.',
        },
      },
    ],
    caveat: {
      pt: 'O Movaro não recomenda uma instituição específica nem confirma taxa, câmbio, limite ou aprovação de conta.',
      es: 'Movaro no recomienda una institución específica ni confirma tasa, cambio, límite o aprobación de cuenta.',
      en: 'Movaro does not recommend a specific institution or confirm fees, exchange rates, limits, or account approval.',
    },
  },
  {
    id: 'work-independent-remote-professional',
    topic: 'work',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2026-11-22',
    jurisdiction: 'BR-federal-professional-operation',
    riskLevel: 'legal',
    answerMode: 'decision_tree',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'work-mei-has-eligibility-rules',
        text: {
          pt: 'Abrir MEI depende de atividade permitida, limite e requisitos cadastrais vigentes; possuir CPF, isoladamente, não confirma o enquadramento.',
          es: 'Abrir un MEI depende de la actividad permitida, límite y requisitos vigentes; tener CPF por sí solo no confirma el encuadre.',
          en: 'Opening a MEI depends on an eligible activity, current limits, and registration requirements; CPF alone does not confirm eligibility.',
        },
        evidenceIds: ['mte-migrant-work-faq'],
        status: 'conditional',
      },
      {
        id: 'work-diploma-and-board-are-separate',
        text: {
          pt: 'Revalidar um diploma e obter autorização de um conselho profissional são verificações diferentes; a exigência depende da atividade que será exercida.',
          es: 'Revalidar un diploma y obtener autorización de un consejo profesional son verificaciones diferentes; la exigencia depende de la actividad.',
          en: 'Diploma revalidation and authorization by a professional board are different checks; requirements depend on the activity performed.',
        },
        evidenceIds: ['mec-diploma-service'],
        status: 'conditional',
      },
      {
        id: 'work-remote-needs-tax-screening',
        text: {
          pt: 'Morar no Brasil e receber renda de empresa ou cliente no exterior exige verificar residência fiscal, forma do vínculo e país da fonte antes de escolher CLT, autônomo, MEI ou empresa.',
          es: 'Vivir en Brasil y cobrar de una empresa o cliente del exterior exige verificar residencia fiscal, vínculo y país de la fuente antes de elegir relación laboral, autónomo, MEI o empresa.',
          en: 'Living in Brazil while receiving income from a foreign company or client requires checking tax residence, work arrangement, and source country before choosing employment, self-employment, MEI, or a company.',
        },
        evidenceIds: ['receita-tax-residence'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'mte-migrant-work-faq',
        publisher: 'Ministério do Trabalho e Emprego',
        title: {
          pt: 'Dúvidas de migrantes sobre trabalho',
          es: 'Preguntas de migrantes sobre trabajo',
          en: 'Migrant work questions',
        },
        url: 'https://www.gov.br/trabalho-e-emprego/pt-br/acesso-a-informacao/acoes-e-programas/programas-projetos-acoes-obras-e-atividades/proteja/duvidas-frequentes',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal',
        scope: {
          pt: 'Trabalho formal, modalidades e proteção de pessoas migrantes.',
          es: 'Trabajo formal, modalidades y protección de personas migrantes.',
          en: 'Formal work, work arrangements, and migrant protection.',
        },
      },
      {
        id: 'mec-diploma-service',
        publisher: 'Ministério da Educação',
        title: {
          pt: 'Revalidar ou reconhecer diploma estrangeiro',
          es: 'Revalidar o reconocer un diploma extranjero',
          en: 'Revalidate or recognize a foreign diploma',
        },
        url: 'https://www.gov.br/pt-br/servicos/reconhecer-ou-revalidar-diploma-de-curso-superior-obtido-no-exterior',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-institution-operation',
        scope: {
          pt: 'Processo oficial para validade nacional de diplomas de ensino superior.',
          es: 'Proceso oficial para la validez nacional de títulos universitarios.',
          en: 'Official process for national validity of higher-education qualifications.',
        },
      },
      {
        id: 'receita-tax-residence',
        publisher: 'Receita Federal',
        title: {
          pt: 'Residente e não residente',
          es: 'Residente y no residente',
          en: 'Resident and non-resident',
        },
        url: 'https://www.gov.br/receitafederal/pt-br/assuntos/meu-imposto-de-renda/preenchimento/dsdp/nao-residente',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-tax',
        scope: {
          pt: 'Fatos que alteram a condição de residência fiscal no Brasil.',
          es: 'Hechos que cambian la residencia fiscal en Brasil.',
          en: 'Facts that change Brazilian tax residence status.',
        },
      },
    ],
    caveat: {
      pt: 'Esta resposta não confirma enquadramento profissional, empresarial, trabalhista ou tributário individual.',
      es: 'Esta respuesta no confirma un encuadre profesional, empresarial, laboral o tributario individual.',
      en: 'This answer does not confirm an individual professional, business, employment, or tax classification.',
    },
  },
  {
    id: 'tax-foreign-income-screening',
    topic: 'tax',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2026-11-22',
    jurisdiction: 'BR-federal-tax-cross-border',
    riskLevel: 'financial',
    answerMode: 'referral',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'tax-residence-depends-on-facts-and-dates',
        text: {
          pt: 'A condição de residente fiscal pode começar na chegada em algumas situações ou quando se completa o período definido pela Receita; datas, tipo de permanência e vínculo de trabalho precisam ser verificados.',
          es: 'La residencia fiscal puede comenzar al llegar en algunas situaciones o al completar el período definido por la Receita; deben verificarse fechas, tipo de permanencia y vínculo laboral.',
          en: 'Tax residence may begin on arrival in some situations or after the period defined by the Federal Revenue; dates, stay type, and employment links must be checked.',
        },
        evidenceIds: ['receita-tax-residence-screening'],
        status: 'conditional',
      },
      {
        id: 'tax-foreign-income-needs-individual-review',
        text: {
          pt: 'Renda, bens, investimentos e empresa no exterior devem ser separados por país, natureza, datas e imposto já pago antes de avaliar declaração ou tributação no Brasil.',
          es: 'Ingresos, bienes, inversiones y empresas del exterior deben separarse por país, naturaleza, fechas e impuesto pagado antes de evaluar la declaración o tributación en Brasil.',
          en: 'Foreign income, assets, investments, and companies must be separated by country, type, dates, and tax already paid before assessing Brazilian reporting or tax.',
        },
        evidenceIds: ['receita-irpf-2026'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'receita-tax-residence-screening',
        publisher: 'Receita Federal',
        title: {
          pt: 'Residente e não residente',
          es: 'Residente y no residente',
          en: 'Resident and non-resident',
        },
        url: 'https://www.gov.br/receitafederal/pt-br/assuntos/meu-imposto-de-renda/preenchimento/dsdp/nao-residente',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-tax',
        scope: {
          pt: 'Critérios temporais e jurídicos de residência fiscal.',
          es: 'Criterios temporales y jurídicos de residencia fiscal.',
          en: 'Timing and legal criteria for tax residence.',
        },
      },
      {
        id: 'receita-irpf-2026',
        publisher: 'Receita Federal',
        title: {
          pt: 'Perguntas e respostas do IRPF 2026',
          es: 'Preguntas y respuestas del impuesto a la renta 2026',
          en: '2026 individual income tax questions and answers',
        },
        url: 'https://www.gov.br/receitafederal/pt-br/centrais-de-conteudo/publicacoes/perguntas-e-respostas/dirpf/p-r-irpf-2026-v1-00-2026-04-23.pdf/view',
        checkedAt: '2026-08-22',
        validUntil: '2027-04-01',
        jurisdiction: 'BR-federal-tax',
        scope: {
          pt: 'Regras declarativas do exercício 2026, inclusive rendimentos do exterior.',
          es: 'Reglas declarativas del ejercicio 2026, incluidos ingresos del exterior.',
          en: '2026 filing rules, including foreign income.',
        },
      },
    ],
    caveat: {
      pt: 'Triagem informativa: não calcula imposto, não decide dupla tributação e não substitui contador com experiência Brasil–Argentina.',
      es: 'Orientación informativa: no calcula impuestos, no decide doble tributación y no reemplaza a un contador con experiencia Brasil–Argentina.',
      en: 'Informational screening: it does not calculate tax, decide double taxation, or replace an accountant experienced with Brazil–Argentina matters.',
    },
  },
  {
    id: 'family-reunion-minors',
    topic: 'family',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2026-11-22',
    jurisdiction: 'BR-federal-family',
    riskLevel: 'legal',
    answerMode: 'decision_tree',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'family-each-person-needs-a-route',
        text: {
          pt: 'Reunião familiar depende do vínculo aceito e dos documentos de quem chama e de quem pede; não se deve presumir que todos os familiares usam o mesmo fundamento.',
          es: 'La reunificación familiar depende del vínculo admitido y de los documentos de quien llama y quien solicita; no debe suponerse que toda la familia usa el mismo fundamento.',
          en: 'Family reunification depends on an accepted relationship and documents for both sponsor and applicant; not every family member should be assumed to use the same basis.',
        },
        evidenceIds: ['pf-family-reunion'],
        status: 'conditional',
      },
      {
        id: 'family-minor-travel-is-separate',
        text: {
          pt: 'Autorização de viagem de menor, guarda e autorização para fixar residência são questões diferentes; confirme a regra aplicável à nacionalidade, filiação, acompanhante e trajeto.',
          es: 'La autorización de viaje de un menor, la guarda y el permiso para fijar residencia son cuestiones diferentes; confirmá la regla según nacionalidad, filiación, acompañante y trayecto.',
          en: 'A minor’s travel authorization, custody, and permission to establish residence are different matters; confirm the rule for nationality, parentage, companion, and route.',
        },
        evidenceIds: ['family-minor-travel'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'pf-family-reunion',
        publisher: 'Polícia Federal',
        title: {
          pt: 'Reunião familiar — dúvidas frequentes',
          es: 'Reunificación familiar — preguntas frecuentes',
          en: 'Family reunification — frequently asked questions',
        },
        url: 'https://www.gov.br/pf/pt-br/assuntos/imigracao/pt/duvidas',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal',
        scope: {
          pt: 'Vínculos aceitos e responsabilidades no pedido de reunião familiar.',
          es: 'Vínculos admitidos y responsabilidades en la reunificación familiar.',
          en: 'Accepted relationships and responsibilities in family reunification.',
        },
      },
      {
        id: 'family-minor-travel',
        publisher: 'Ministério das Relações Exteriores',
        title: {
          pt: 'Autorização de viagem para menor',
          es: 'Autorización de viaje para menores',
          en: 'Travel authorization for minors',
        },
        url: 'https://www.gov.br/mre/pt-br/assuntos/portal-consular/servicos-consulares/autorizacao-de-viagem-para-menores',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-consular',
        scope: {
          pt: 'Autorização de viagem internacional de crianças e adolescentes.',
          es: 'Autorización de viaje internacional de niñas, niños y adolescentes.',
          en: 'International travel authorization for children and adolescents.',
        },
      },
    ],
    caveat: {
      pt: 'Casos com guarda, desacordo entre responsáveis, documentos ausentes ou risco à criança exigem orientação jurídica ou consular individual.',
      es: 'Los casos con guarda, desacuerdo entre responsables, documentos faltantes o riesgo para el menor requieren orientación jurídica o consular individual.',
      en: 'Cases involving custody, parental disagreement, missing documents, or risk to a child require individual legal or consular guidance.',
    },
  },
  {
    id: 'health-treatment-medicines',
    topic: 'health',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2026-11-22',
    jurisdiction: 'BR-federal-health-local-care',
    riskLevel: 'medical',
    answerMode: 'referral',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'health-carrying-and-buying-are-different',
        text: {
          pt: 'Levar medicamento na bagagem, importar depois da chegada e comprar em farmácia brasileira são situações diferentes; receita estrangeira não deve ser presumida como suficiente para dispensação no Brasil.',
          es: 'Llevar un medicamento en el equipaje, importarlo después de llegar y comprarlo en una farmacia brasileña son situaciones diferentes; no debe suponerse que una receta extranjera sea suficiente para la dispensa en Brasil.',
          en: 'Carrying medicine in baggage, importing it after arrival, and purchasing it at a Brazilian pharmacy are different situations; a foreign prescription should not be assumed sufficient for dispensing in Brazil.',
        },
        evidenceIds: ['anvisa-controlled-import'],
        status: 'conditional',
      },
      {
        id: 'health-controlled-medicine-may-need-authorization',
        text: {
          pt: 'A regra depende da substância controlada: algumas situações admitem entrada com receita e quantidade individual, enquanto outras podem exigir autorização excepcional prévia da Anvisa.',
          es: 'La regla depende de la sustancia controlada: algunas situaciones admiten ingreso con receta y cantidad individual, mientras otras pueden exigir autorización excepcional previa de Anvisa.',
          en: 'The rule depends on the controlled substance: some situations allow entry with a prescription and personal quantity, while others may require prior exceptional authorization from Anvisa.',
        },
        evidenceIds: ['anvisa-controlled-import'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'anvisa-controlled-import',
        publisher: 'Anvisa',
        title: {
          pt: 'Importação de produtos controlados',
          es: 'Importación de productos controlados',
          en: 'Importing controlled products',
        },
        url: 'https://www.gov.br/anvisa/pt-br/assuntos/medicamentos/controlados/importacao',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-health',
        scope: {
          pt: 'Requisitos para importação pessoal e excepcional de medicamentos controlados.',
          es: 'Requisitos para importación personal y excepcional de medicamentos controlados.',
          en: 'Requirements for personal and exceptional import of controlled medicines.',
        },
      },
    ],
    caveat: {
      pt: 'Não interrompa tratamento nem altere dose com base na Ajuda. Prepare resumo clínico, nomes dos princípios ativos e procure atendimento brasileiro antes de acabar sua reserva.',
      es: 'No interrumpas el tratamiento ni cambies dosis basándote en Ayuda. Prepará un resumen clínico, principios activos y buscá atención en Brasil antes de agotar tu reserva.',
      en: 'Do not stop treatment or change dosage based on Help. Prepare a clinical summary and active ingredient names, and seek Brazilian care before your supply runs out.',
    },
  },
  {
    id: 'housing-rental-lifecycle',
    topic: 'housing',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2026-11-22',
    jurisdiction: 'BR-federal-contract',
    riskLevel: 'legal',
    answerMode: 'decision_tree',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'housing-deposit-limit-and-form',
        text: {
          pt: 'Na caução em dinheiro, a Lei do Inquilinato limita o valor a três meses de aluguel e prevê depósito em caderneta de poupança.',
          es: 'Para la caución en dinero, la Ley de Alquileres limita el valor a tres meses de alquiler y prevé depósito en una cuenta de ahorro.',
          en: 'For a cash deposit, the Tenancy Law limits the amount to three months’ rent and provides for deposit in a savings account.',
        },
        evidenceIds: ['tenancy-law-lifecycle'],
        status: 'verified',
      },
      {
        id: 'housing-charges-must-be-checked-in-contract',
        text: {
          pt: 'Aluguel, condomínio, IPTU, seguro, reparos, vistoria, prazo e condições de saída devem ser conferidos separadamente no contrato e nos comprovantes.',
          es: 'Alquiler, expensas, IPTU, seguro, reparaciones, inspección, plazo y salida deben revisarse por separado en el contrato y comprobantes.',
          en: 'Rent, condominium fees, IPTU, insurance, repairs, inspection, term, and exit conditions should be checked separately in the contract and supporting documents.',
        },
        evidenceIds: ['procon-migrant-housing'],
        status: 'conditional',
      },
      {
        id: 'housing-early-termination-is-proportional',
        text: {
          pt: 'Se o locatário devolver o imóvel antes do fim do prazo, a multa contratual deve ser calculada proporcionalmente ao período já cumprido, observadas as exceções legais e o contrato.',
          es: 'Si el inquilino devuelve el inmueble antes del fin del plazo, la multa contractual debe calcularse proporcionalmente al período cumplido, considerando las excepciones legales y el contrato.',
          en: 'If the tenant returns the property before the end of the term, the contractual penalty must be calculated proportionally to the period already completed, subject to legal exceptions and the contract.',
        },
        evidenceIds: ['tenancy-law-lifecycle'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'tenancy-law-lifecycle',
        publisher: 'Planalto',
        title: {
          pt: 'Lei do Inquilinato',
          es: 'Ley de alquileres de Brasil',
          en: 'Brazilian Tenancy Law',
        },
        url: 'https://www.planalto.gov.br/ccivil_03/leis/l8245.htm',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal',
        scope: {
          pt: 'Garantias, obrigações e encerramento da locação urbana.',
          es: 'Garantías, obligaciones y finalización del alquiler urbano.',
          en: 'Guarantees, obligations, and termination of urban tenancies.',
        },
      },
      {
        id: 'procon-migrant-housing',
        publisher: 'Procon-SP',
        title: {
          pt: 'Moradia para pessoas refugiadas e imigrantes',
          es: 'Vivienda para personas refugiadas e inmigrantes',
          en: 'Housing for refugees and migrants',
        },
        url: 'https://www.procon.sp.gov.br/wp-content/uploads/2025/07/folder-refugiados-e-imigrantes-tema-moradia-portugues2.pdf',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-SP-consumer-guidance',
        scope: {
          pt: 'Checklist prático de contrato, encargos, garantia e prevenção de problemas.',
          es: 'Lista práctica de contrato, cargos, garantía y prevención de problemas.',
          en: 'Practical checklist for contracts, charges, guarantees, and problem prevention.',
        },
      },
    ],
    caveat: {
      pt: 'A resposta não valida um contrato, calcula multa definitiva nem substitui análise jurídica do documento assinado.',
      es: 'La respuesta no valida un contrato, no calcula una multa definitiva ni reemplaza el análisis jurídico del documento firmado.',
      en: 'The answer does not validate a contract, calculate a final penalty, or replace legal review of the signed document.',
    },
  },
  {
    id: 'education-diploma-profession',
    topic: 'education',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2026-11-22',
    jurisdiction: 'BR-federal-institution-professional',
    riskLevel: 'legal',
    answerMode: 'decision_tree',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'education-no-automatic-mercosur-diploma',
        text: {
          pt: 'Um diploma argentino não recebe validade nacional automática por ser do Mercosul; graduação, mestrado e doutorado seguem processos diferentes de revalidação ou reconhecimento.',
          es: 'Un título argentino no obtiene validez nacional automática por ser del Mercosur; grado, maestría y doctorado siguen procesos distintos de revalidación o reconocimiento.',
          en: 'An Argentine qualification does not gain automatic national validity because it is from Mercosur; undergraduate, master’s, and doctoral qualifications follow different revalidation or recognition processes.',
        },
        evidenceIds: ['carolina-bori-applicants'],
        status: 'verified',
      },
      {
        id: 'education-institution-controls-process',
        text: {
          pt: 'A instituição brasileira competente analisa documentos, curso equivalente, disponibilidade e procedimento; a Plataforma Carolina Bori organiza solicitações, mas não garante aceitação.',
          es: 'La institución brasileña competente analiza documentos, curso equivalente, disponibilidad y procedimiento; Carolina Bori organiza solicitudes, pero no garantiza la aceptación.',
          en: 'The competent Brazilian institution assesses documents, equivalent course, availability, and procedure; Carolina Bori organizes applications but does not guarantee acceptance.',
        },
        evidenceIds: ['carolina-bori-applicants'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'carolina-bori-applicants',
        publisher: 'Ministério da Educação',
        title: {
          pt: 'Reconhecer ou revalidar diploma obtido no exterior',
          es: 'Reconocer o revalidar un título obtenido en el exterior',
          en: 'Recognize or revalidate a foreign qualification',
        },
        url: 'https://www.gov.br/pt-br/servicos/reconhecer-ou-revalidar-diploma-de-curso-superior-obtido-no-exterior',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-institution-operation',
        scope: {
          pt: 'Documentos, instituição competente e fluxo de revalidação ou reconhecimento.',
          es: 'Documentos, institución competente y proceso de revalidación o reconocimiento.',
          en: 'Documents, competent institution, and revalidation or recognition process.',
        },
      },
    ],
    caveat: {
      pt: 'Validade acadêmica e autorização para exercer profissão regulamentada não são a mesma decisão.',
      es: 'La validez académica y la autorización para ejercer una profesión regulada no son la misma decisión.',
      en: 'Academic validity and authorization to practice a regulated profession are not the same decision.',
    },
  },
  {
    id: 'health-prevention-care-network',
    topic: 'health',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2026-11-22',
    jurisdiction: 'BR-federal-health-local-care',
    riskLevel: 'medical',
    answerMode: 'referral',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'health-vaccination-needs-record-review',
        text: {
          pt: 'Adultos e crianças devem levar a carteira ou os registros disponíveis para que a unidade de saúde compare as doses com o Calendário Nacional de Vacinação; não é seguro reiniciar ou completar esquemas apenas por memória.',
          es: 'Adultos y niños deben llevar la libreta o los registros disponibles para que la unidad compare las dosis con el Calendario Nacional de Vacunación; no es seguro reiniciar o completar esquemas sólo de memoria.',
          en: 'Adults and children should bring available vaccination records so the health unit can compare doses with the National Vaccination Calendar; schedules should not be restarted or completed from memory alone.',
        },
        evidenceIds: ['vaccination_calendar'],
        status: 'conditional',
      },
      {
        id: 'health-prenatal-starts-in-primary-care',
        text: {
          pt: 'O pré-natal no SUS deve ser iniciado o quanto antes, normalmente pela atenção primária; a equipe avalia o risco e organiza exames e encaminhamentos.',
          es: 'El control prenatal en el SUS debe comenzar cuanto antes, normalmente en atención primaria; el equipo evalúa el riesgo y organiza estudios y derivaciones.',
          en: 'SUS prenatal care should begin as early as possible, usually through primary care; the team assesses risk and organizes tests and referrals.',
        },
        evidenceIds: ['pregnancy_prenatal'],
        status: 'conditional',
      },
      {
        id: 'health-mental-care-uses-raps',
        text: {
          pt: 'A atenção em saúde mental é organizada pela Rede de Atenção Psicossocial, com portas que variam conforme necessidade e município; em crise ou risco imediato, procure urgência.',
          es: 'La atención de salud mental se organiza mediante la Red de Atención Psicosocial, con puertas que varían según la necesidad y el municipio; ante crisis o riesgo inmediato, buscá urgencias.',
          en: 'Mental healthcare is organized through the Psychosocial Care Network, with entry points varying by need and municipality; seek urgent care during a crisis or immediate risk.',
        },
        evidenceIds: ['mental_health_raps'],
        status: 'conditional',
      },
      {
        id: 'health-private-plan-has-waiting-periods',
        text: {
          pt: 'Plano privado não substitui o direito ao SUS e pode ter carências dentro dos limites regulatórios; antes de contratar, compare registro da operadora, cobertura, rede, coparticipação e carências por escrito.',
          es: 'Un plan privado no reemplaza el derecho al SUS y puede tener carencias dentro de los límites regulatorios; antes de contratar, compará registro, cobertura, red, copago y carencias por escrito.',
          en: 'Private insurance does not replace the right to SUS and may have waiting periods within regulatory limits; before signing, compare registration, coverage, network, copay, and waiting periods in writing.',
        },
        evidenceIds: ['private_health_waiting_periods'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'vaccination_calendar',
        publisher: 'Ministério da Saúde',
        title: {
          pt: 'Calendário Nacional de Vacinação',
          es: 'Calendario Nacional de Vacunación',
          en: 'National Vaccination Calendar',
        },
        url: 'https://www.gov.br/saude/pt-br/vacinacao/calendario',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-local-operation',
        scope: {
          pt: 'Vacinas e faixas etárias previstas no calendário nacional vigente.',
          es: 'Vacunas y edades previstas en el calendario nacional vigente.',
          en: 'Vaccines and age groups in the current national schedule.',
        },
      },
      {
        id: 'pregnancy_prenatal',
        publisher: 'Ministério da Saúde',
        title: {
          pt: 'Gravidez e pré-natal',
          es: 'Embarazo y control prenatal',
          en: 'Pregnancy and prenatal care',
        },
        url: 'https://www.gov.br/saude/pt-br/assuntos/saude-de-a-a-z/g/gravidez',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-local-operation',
        scope: {
          pt: 'Entrada e acompanhamento do pré-natal na rede pública.',
          es: 'Ingreso y seguimiento prenatal en la red pública.',
          en: 'Entry and follow-up for prenatal care in the public network.',
        },
      },
      {
        id: 'mental_health_raps',
        publisher: 'Ministério da Saúde',
        title: {
          pt: 'Rede de Atenção Psicossocial',
          es: 'Red de Atención Psicosocial',
          en: 'Psychosocial Care Network',
        },
        url: 'https://www.gov.br/saude/pt-br/composicao/saes/desmad/raps',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-local-operation',
        scope: {
          pt: 'Componentes e organização da rede pública de saúde mental.',
          es: 'Componentes y organización de la red pública de salud mental.',
          en: 'Components and organization of the public mental health network.',
        },
      },
      {
        id: 'private_health_waiting_periods',
        publisher: 'Agência Nacional de Saúde Suplementar',
        title: {
          pt: 'Carência em planos de saúde',
          es: 'Carencias en planes de salud',
          en: 'Private health plan waiting periods',
        },
        url: 'https://www.gov.br/ans/pt-br/assuntos/consumidor/carencia',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-private-health',
        scope: {
          pt: 'Limites regulatórios e funcionamento de carências contratuais.',
          es: 'Límites regulatorios y funcionamiento de las carencias contractuales.',
          en: 'Regulatory limits and operation of contractual waiting periods.',
        },
      },
    ],
    caveat: {
      pt: 'A Central não avalia sintomas, risco gestacional, esquema vacinal individual nem adequação de um plano privado.',
      es: 'La Central no evalúa síntomas, riesgo del embarazo, esquema de vacunación individual ni la adecuación de un plan privado.',
      en: 'Help does not assess symptoms, pregnancy risk, an individual vaccination schedule, or whether a private plan is suitable.',
    },
  },
  {
    id: 'pets-customs-border-preparation',
    topic: 'pets_customs',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2026-11-22',
    jurisdiction: 'BR-federal-border',
    riskLevel: 'legal',
    answerMode: 'decision_tree',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'pets-dog-cat-needs-current-health-route',
        text: {
          pt: 'A entrada de cão ou gato exige cumprir a rota sanitária vigente antes do embarque; documentos do animal e aceite da transportadora são verificações separadas.',
          es: 'El ingreso de un perro o gato exige cumplir la vía sanitaria vigente antes del embarque; los documentos del animal y la aceptación del transportista son controles separados.',
          en: 'A dog or cat must follow the current animal-health entry route before travel; animal documents and carrier acceptance are separate checks.',
        },
        evidenceIds: ['pet_entry'],
        status: 'conditional',
      },
      {
        id: 'customs-items-need-separate-classification',
        text: {
          pt: 'Bagagem acompanhada, bagagem desacompanhada, bens de mudança, alimentos, medicamentos e veículos não devem ser tratados como uma única categoria; declaração e restrições dependem do item e da forma de entrada.',
          es: 'Equipaje acompañado, equipaje no acompañado, bienes de mudanza, alimentos, medicamentos y vehículos no deben tratarse como una sola categoría; la declaración y las restricciones dependen del ítem y de la forma de ingreso.',
          en: 'Accompanied baggage, unaccompanied baggage, household goods, food, medicines, and vehicles should not be treated as one category; declaration and restrictions depend on the item and entry method.',
        },
        evidenceIds: ['traveler_customs'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'pet_entry',
        publisher: 'Ministério da Agricultura e Pecuária',
        title: {
          pt: 'Ingresso de cães e gatos no Brasil',
          es: 'Ingreso de perros y gatos a Brasil',
          en: 'Bringing dogs and cats into Brazil',
        },
        url: 'https://www.gov.br/agricultura/pt-br/assuntos/vigilancia-agropecuaria/viajantes-e-bagagens/lista-de-bens-agropecuarios-que-podem-ou-nao-ingressar-no-brasil/animais-vivos/caes-e-gatos',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-animal-health',
        scope: {
          pt: 'Requisitos sanitários federais para cães e gatos.',
          es: 'Requisitos sanitarios federales para perros y gatos.',
          en: 'Federal animal-health requirements for dogs and cats.',
        },
      },
      {
        id: 'traveler_customs',
        publisher: 'Receita Federal',
        title: {
          pt: 'Guia do viajante — bagagem e declaração',
          es: 'Guía del viajero — equipaje y declaración',
          en: 'Traveler guide — baggage and declaration',
        },
        url: 'https://www.gov.br/receitafederal/pt-br/assuntos/aduana-e-comercio-exterior/viagens-internacionais/guia-do-viajante/perguntas-e-respostas',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-customs',
        scope: {
          pt: 'Classificação, declaração e tratamento aduaneiro de bens de viajante.',
          es: 'Clasificación, declaración y tratamiento aduanero de bienes de viajeros.',
          en: 'Classification, declaration, and customs treatment of traveler goods.',
        },
      },
    ],
    caveat: {
      pt: 'Confirme a exigência para cada item e para a data da viagem; a Central não autoriza embarque nem importação.',
      es: 'Confirmá el requisito de cada ítem y para la fecha del viaje; la Central no autoriza embarques ni importaciones.',
      en: 'Confirm each item’s requirements for the travel date; Help does not authorize travel or importation.',
    },
  },
  {
    id: 'utilities-activation-and-records',
    topic: 'utilities',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2027-02-22',
    jurisdiction: 'BR-federal-provider-local-operation',
    riskLevel: 'medium',
    answerMode: 'decision_tree',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'utilities-prepaid-registration-needs-identification',
        text: {
          pt: 'A ativação de linha pré-paga exige cadastro do titular; para pessoa estrangeira, a operação e os documentos aceitos devem ser confirmados com a prestadora.',
          es: 'La activación de una línea prepaga exige registrar al titular; para una persona extranjera, la operación y los documentos aceptados deben confirmarse con la prestadora.',
          en: 'Prepaid mobile activation requires subscriber registration; foreign nationals should confirm the process and accepted documents with the provider.',
        },
        evidenceIds: ['prepaid_registration'],
        status: 'conditional',
      },
      {
        id: 'utilities-telecom-contract-must-be-traceable',
        text: {
          pt: 'Antes de contratar telefone ou internet, confirme oferta, preço, fidelização, instalação e cancelamento em um registro que possa ser consultado depois.',
          es: 'Antes de contratar telefonía o internet, confirmá oferta, precio, permanencia, instalación y cancelación en un registro que pueda consultarse después.',
          en: 'Before contracting phone or internet service, confirm the offer, price, commitment term, installation, and cancellation in a record you can review later.',
        },
        evidenceIds: ['telecom_consumer_rights'],
        status: 'conditional',
      },
      {
        id: 'utilities-energy-first-contact-is-provider',
        text: {
          pt: 'Para ligação, troca de titularidade, cobrança ou problema de energia, registre primeiro o pedido na distribuidora e guarde o protocolo; exigências operacionais variam por área de concessão.',
          es: 'Para conexión, cambio de titularidad, cobro o problema de energía, registrá primero el pedido en la distribuidora y guardá el protocolo; los requisitos varían por área de concesión.',
          en: 'For connection, account-holder changes, charges, or electricity issues, first register the request with the distributor and keep the protocol; operational requirements vary by concession area.',
        },
        evidenceIds: ['electricity_consumer_support'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'prepaid_registration',
        publisher: 'Anatel',
        title: {
          pt: 'Cadastro de linha pré-paga',
          es: 'Registro de línea prepaga',
          en: 'Prepaid line registration',
        },
        url: 'https://www.gov.br/anatel/pt-br/dados/utilidade-publica/cadastro-pre-pago',
        checkedAt: '2026-08-22',
        validUntil: '2027-02-22',
        jurisdiction: 'BR-federal-telecom',
        scope: {
          pt: 'Identificação e cadastro de titulares de linhas pré-pagas.',
          es: 'Identificación y registro de titulares de líneas prepagas.',
          en: 'Identification and registration of prepaid subscribers.',
        },
      },
      {
        id: 'telecom_consumer_rights',
        publisher: 'Anatel',
        title: {
          pt: 'Direitos de consumidores de telecomunicações',
          es: 'Derechos de consumidores de telecomunicaciones',
          en: 'Telecommunications consumer rights',
        },
        url: 'https://www.gov.br/anatel/pt-br/consumidor/conheca-seus-direitos',
        checkedAt: '2026-08-22',
        validUntil: '2027-02-22',
        jurisdiction: 'BR-federal-telecom',
        scope: {
          pt: 'Informação, contratação, atendimento e cancelamento de serviços.',
          es: 'Información, contratación, atención y cancelación de servicios.',
          en: 'Information, contracting, support, and cancellation of services.',
        },
      },
      {
        id: 'electricity_consumer_support',
        publisher: 'ANEEL',
        title: {
          pt: 'Como resolver problemas com energia elétrica',
          es: 'Cómo resolver problemas con energía eléctrica',
          en: 'How to resolve electricity service problems',
        },
        url: 'https://www.gov.br/aneel/pt-br/consumidores/como-resolver',
        checkedAt: '2026-08-22',
        validUntil: '2027-02-22',
        jurisdiction: 'BR-federal-local-distributor',
        scope: {
          pt: 'Sequência de atendimento e escalada para serviços de energia.',
          es: 'Secuencia de atención y escalamiento para servicios de energía.',
          en: 'Support and escalation sequence for electricity services.',
        },
      },
    ],
    caveat: {
      pt: 'Água, saneamento e comprovante de endereço dependem do município, da prestadora e do contrato de moradia; confirme a lista local.',
      es: 'Agua, saneamiento y comprobante de domicilio dependen del municipio, la prestadora y el contrato de vivienda; confirmá la lista local.',
      en: 'Water, sanitation, and proof-of-address rules depend on the municipality, provider, and housing contract; confirm the local list.',
    },
  },
  {
    id: 'protection-and-human-support',
    topic: 'protection',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2026-11-22',
    jurisdiction: 'BR-federal-local-support',
    riskLevel: 'legal',
    answerMode: 'referral',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'protection-immediate-danger-comes-first',
        text: {
          pt: 'Se houver perigo imediato, priorize o serviço de emergência adequado; para violações de direitos sem risco imediato, a Ouvidoria Nacional de Direitos Humanos recebe e encaminha denúncias.',
          es: 'Si hay peligro inmediato, priorizá el servicio de emergencia adecuado; para vulneraciones de derechos sin riesgo inmediato, la Defensoría Nacional de Derechos Humanos recibe y deriva denuncias.',
          en: 'If there is immediate danger, prioritize the appropriate emergency service; for rights violations without immediate danger, the National Human Rights Ombudsman receives and routes reports.',
        },
        evidenceIds: ['human_rights_hotline'],
        status: 'conditional',
      },
      {
        id: 'protection-labor-abuse-has-official-reporting',
        text: {
          pt: 'Falta de pagamento, retenção de documentos, exploração ou outras irregularidades trabalhistas podem ser registradas no canal oficial de denúncia; preserve mensagens, contrato, horários e comprovantes sem se expor a novo risco.',
          es: 'La falta de pago, retención de documentos, explotación u otras irregularidades laborales pueden registrarse en el canal oficial; guardá mensajes, contrato, horarios y comprobantes sin exponerte a un nuevo riesgo.',
          en: 'Nonpayment, document retention, exploitation, or other labor violations can be reported through the official channel; preserve messages, contracts, hours, and receipts without exposing yourself to further risk.',
        },
        evidenceIds: ['labor_complaint'],
        status: 'conditional',
      },
      {
        id: 'protection-support-is-local-and-specialized',
        text: {
          pt: 'Assistência jurídica, social, abrigo e apoio a migrantes variam por cidade e situação; use uma rede confiável para identificar o serviço local adequado.',
          es: 'La asistencia jurídica, social, el refugio y el apoyo a migrantes varían por ciudad y situación; usá una red confiable para identificar el servicio local adecuado.',
          en: 'Legal aid, social assistance, shelter, and migrant support vary by city and situation; use a trusted network to identify the appropriate local service.',
        },
        evidenceIds: ['migrant_support_network'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'human_rights_hotline',
        publisher: 'Ministério dos Direitos Humanos e da Cidadania',
        title: {
          pt: 'Ouvidoria Nacional de Direitos Humanos',
          es: 'Defensoría Nacional de Derechos Humanos',
          en: 'National Human Rights Ombudsman',
        },
        url: 'https://www.gov.br/mdh/pt-br/ondh',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-referral',
        scope: {
          pt: 'Canais nacionais para denúncias de violações de direitos humanos.',
          es: 'Canales nacionales para denuncias de vulneraciones de derechos humanos.',
          en: 'National channels for reporting human rights violations.',
        },
      },
      {
        id: 'labor_complaint',
        publisher: 'Ministério do Trabalho e Emprego',
        title: {
          pt: 'Realizar denúncia trabalhista',
          es: 'Realizar una denuncia laboral',
          en: 'File a labor complaint',
        },
        url: 'https://www.gov.br/pt-br/servicos/realizar-denuncia-trabalhista',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-labor',
        scope: {
          pt: 'Canal oficial para registrar irregularidades trabalhistas.',
          es: 'Canal oficial para registrar irregularidades laborales.',
          en: 'Official channel for reporting labor violations.',
        },
      },
      {
        id: 'migrant_support_network',
        publisher: 'ACNUR Brasil',
        title: {
          pt: 'Onde encontrar ajuda no Brasil',
          es: 'Dónde encontrar ayuda en Brasil',
          en: 'Where to find help in Brazil',
        },
        url: 'https://help.unhcr.org/brazil/onde-encontrar-ajuda/',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-local-referral-network',
        scope: {
          pt: 'Rede territorial de serviços e organizações de apoio.',
          es: 'Red territorial de servicios y organizaciones de apoyo.',
          en: 'Territorial network of support services and organizations.',
        },
      },
    ],
    caveat: {
      pt: 'A Central não monitora risco, não envia denúncia e não substitui emergência, polícia, defensoria ou atendimento humano.',
      es: 'La Central no monitorea riesgos, no envía denuncias y no reemplaza emergencias, policía, defensoría ni atención humana.',
      en: 'Help does not monitor risk, file reports, or replace emergency services, police, legal aid, or human support.',
    },
  },
  {
    id: 'consumer-complaint-escalation',
    topic: 'consumer',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2027-02-22',
    jurisdiction: 'BR-federal-sector-regulators',
    riskLevel: 'medium',
    answerMode: 'decision_tree',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'consumer-complaint-needs-protocol-and-evidence',
        text: {
          pt: 'Uma reclamação rastreável começa com contrato ou oferta, comprovantes, capturas e protocolo da empresa; se não resolver, Consumidor.gov.br ou o Procon podem ser a próxima etapa conforme o fornecedor e o caso.',
          es: 'Un reclamo rastreable comienza con contrato u oferta, comprobantes, capturas y protocolo de la empresa; si no se resuelve, Consumidor.gov.br o Procon pueden ser el paso siguiente según el proveedor y el caso.',
          en: 'A traceable complaint begins with the contract or offer, receipts, screenshots, and the company protocol; if unresolved, Consumidor.gov.br or Procon may be the next step depending on the provider and case.',
        },
        evidenceIds: ['consumer_rights'],
        status: 'conditional',
      },
      {
        id: 'consumer-telecom-has-sector-escalation',
        text: {
          pt: 'Em telefonia ou internet, registre primeiro a demanda na prestadora e guarde o protocolo antes de escalar à Anatel.',
          es: 'En telefonía o internet, registrá primero el reclamo en la prestadora y guardá el protocolo antes de escalar a Anatel.',
          en: 'For phone or internet issues, first register the complaint with the provider and keep the protocol before escalating to Anatel.',
        },
        evidenceIds: ['telecom_complaint'],
        status: 'conditional',
      },
      {
        id: 'consumer-energy-has-sector-escalation',
        text: {
          pt: 'Em energia elétrica, a sequência começa na distribuidora e pode avançar para ouvidoria e canais indicados pela ANEEL, sempre com os protocolos anteriores.',
          es: 'En energía eléctrica, la secuencia comienza en la distribuidora y puede avanzar a la defensoría y a los canales indicados por ANEEL, siempre con los protocolos anteriores.',
          en: 'For electricity issues, the sequence starts with the distributor and may proceed to the ombudsman and ANEEL channels, keeping earlier protocols.',
        },
        evidenceIds: ['electricity_complaint'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'consumer_rights',
        publisher: 'Secretaria Nacional do Consumidor',
        title: {
          pt: 'Consumidor.gov.br',
          es: 'Consumidor.gov.br',
          en: 'Consumidor.gov.br',
        },
        url: 'https://www.consumidor.gov.br/pages/principal/',
        checkedAt: '2026-08-22',
        validUntil: '2027-02-22',
        jurisdiction: 'BR-federal-consumer-platform',
        scope: {
          pt: 'Plataforma pública de interlocução com empresas participantes.',
          es: 'Plataforma pública de contacto con empresas participantes.',
          en: 'Public complaint platform for participating companies.',
        },
      },
      {
        id: 'telecom_complaint',
        publisher: 'Anatel',
        title: {
          pt: 'Registrar reclamação na Anatel',
          es: 'Registrar un reclamo en Anatel',
          en: 'File a complaint with Anatel',
        },
        url: 'https://www.gov.br/anatel/pt-br/consumidor/quer-reclamar/reclamacao',
        checkedAt: '2026-08-22',
        validUntil: '2027-02-22',
        jurisdiction: 'BR-federal-telecom',
        scope: {
          pt: 'Pré-requisitos e canal de reclamação sobre telecomunicações.',
          es: 'Requisitos y canal de reclamos de telecomunicaciones.',
          en: 'Requirements and channel for telecommunications complaints.',
        },
      },
      {
        id: 'electricity_complaint',
        publisher: 'ANEEL',
        title: {
          pt: 'Reclamar da distribuidora de energia',
          es: 'Reclamar contra la distribuidora de energía',
          en: 'Complain about an electricity distributor',
        },
        url: 'https://www.gov.br/aneel/pt-br/canais_atendimento/reclame-da-distribuidora/consumidor-govbr',
        checkedAt: '2026-08-22',
        validUntil: '2027-02-22',
        jurisdiction: 'BR-federal-electricity',
        scope: {
          pt: 'Sequência e canais para reclamações do setor elétrico.',
          es: 'Secuencia y canales para reclamos del sector eléctrico.',
          en: 'Sequence and channels for electricity-sector complaints.',
        },
      },
    ],
    caveat: {
      pt: 'Se houver fraude em andamento, proteja contas e meios de pagamento antes da reclamação administrativa; a Central não contesta transações.',
      es: 'Si hay un fraude en curso, protegé cuentas y medios de pago antes del reclamo administrativo; la Central no impugna transacciones.',
      en: 'If fraud is ongoing, protect accounts and payment methods before an administrative complaint; Help does not dispute transactions.',
    },
  },
  {
    id: 'long-term-pension-naturalization',
    topic: 'long_term',
    contentVersion: CONTENT_VERSION,
    editorialOwner: EDITORIAL_OWNER,
    reviewedAt: '2026-08-22',
    expiresAt: '2026-11-22',
    jurisdiction: 'BR-federal-bilateral',
    riskLevel: 'legal',
    answerMode: 'referral',
    coverageStatus: 'conditional',
    claims: [
      {
        id: 'long-term-contributions-need-country-records',
        text: {
          pt: 'O acordo previdenciário permite coordenar períodos conforme suas regras, mas não transforma automaticamente contribuições argentinas em contribuições brasileiras; mantenha registros dos dois países e confirme o benefício no organismo competente.',
          es: 'El acuerdo previsional permite coordinar períodos según sus reglas, pero no convierte automáticamente aportes argentinos en aportes brasileños; conservá registros de ambos países y confirmá el beneficio ante el organismo competente.',
          en: 'The social security agreement can coordinate contribution periods under its rules, but it does not automatically convert Argentine contributions into Brazilian ones; keep records from both countries and confirm the benefit with the competent authority.',
        },
        evidenceIds: ['social_security_agreements'],
        status: 'conditional',
      },
      {
        id: 'long-term-naturalization-is-separate',
        text: {
          pt: 'Naturalização não é renovação de residência: é um pedido separado, com modalidades e requisitos próprios; identifique primeiro a modalidade antes de contar prazo ou reunir documentos.',
          es: 'La naturalización no es una renovación de residencia: es una solicitud separada, con modalidades y requisitos propios; identificá primero la modalidad antes de contar plazos o reunir documentos.',
          en: 'Naturalization is not residence renewal: it is a separate application with its own types and requirements; identify the type before counting time or collecting documents.',
        },
        evidenceIds: ['naturalization_service'],
        status: 'conditional',
      },
    ],
    evidence: [
      {
        id: 'social_security_agreements',
        publisher: 'Ministério da Previdência Social',
        title: {
          pt: 'Acordos internacionais de previdência em vigor',
          es: 'Acuerdos internacionales de previsión vigentes',
          en: 'International social security agreements in force',
        },
        url: 'https://www.gov.br/previdencia/pt-br/assuntos/acordos-internacionais/acordos-internacionais-em-vigor',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-bilateral-social-security',
        scope: {
          pt: 'Acordos vigentes e coordenação previdenciária internacional.',
          es: 'Acuerdos vigentes y coordinación previsional internacional.',
          en: 'Agreements in force and international social security coordination.',
        },
      },
      {
        id: 'naturalization_service',
        publisher: 'Ministério da Justiça e Segurança Pública',
        title: {
          pt: 'Naturalizar-se brasileiro',
          es: 'Naturalizarse brasileño',
          en: 'Apply for Brazilian naturalization',
        },
        url: 'https://www.gov.br/mj/pt-br/assuntos/seus-direitos/migracoes/naturalizacao/naturalizar-se',
        checkedAt: '2026-08-22',
        validUntil: '2026-11-22',
        jurisdiction: 'BR-federal-naturalization',
        scope: {
          pt: 'Modalidades, requisitos e serviço oficial de naturalização.',
          es: 'Modalidades, requisitos y servicio oficial de naturalización.',
          en: 'Types, requirements, and official naturalization service.',
        },
      },
    ],
    caveat: {
      pt: 'INSS, ANSES e Ministério da Justiça decidem cada pedido; a Central não calcula benefício nem confirma direito à naturalização.',
      es: 'INSS, ANSES y el Ministerio de Justicia deciden cada solicitud; la Central no calcula beneficios ni confirma derecho a la naturalización.',
      en: 'INSS, ANSES, and the Justice Ministry decide each request; Help does not calculate benefits or confirm naturalization eligibility.',
    },
  },
];
