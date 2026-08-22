import { LocalizedText, QuickHelpTopic } from './quick-help-trust.catalog';

export interface QuickHelpClarificationOption {
  value: string;
  label: LocalizedText;
  targetIntentId?: string;
}

export interface QuickHelpClarificationDefinition {
  id: string;
  contextKey: string;
  prompt: LocalizedText;
  options: QuickHelpClarificationOption[];
}

export interface QuickHelpDecisionBranch {
  value: string;
  title: LocalizedText;
  steps: LocalizedText[];
}

export interface QuickHelpIntentDefinition {
  id: string;
  topic: QuickHelpTopic;
  title: LocalizedText;
  aliases: Record<'pt' | 'es' | 'en', string[]>;
  negativeAliases?: string[];
  concepts: string[][];
  priority: number;
  entryId?: string;
  claimIds?: string[];
  partialAnswer?: LocalizedText;
  clarification?: QuickHelpClarificationDefinition;
  decisionContextKey?: string;
  decisionBranches?: QuickHelpDecisionBranch[];
}

const helpTopicsAnswer: LocalizedText = {
  pt: 'Identifiquei o tema, mas ainda não há evidência revisada suficiente para responder esse caso específico aqui. Reformule com o documento, serviço ou bloqueio principal para eu tentar uma resposta mais precisa.',
  es: 'Identifiqué el tema, pero todavía no hay evidencia revisada suficiente para responder este caso específico acá. Reformulá con el documento, servicio o bloqueo principal para intentar una respuesta más precisa.',
  en: 'I identified the topic, but there is not enough reviewed evidence to answer this specific case here. Rephrase with the main document, service, or blocker for a more precise answer.',
};

export const QUICK_HELP_INTENTS: QuickHelpIntentDefinition[] = [
  {
    id: 'documents.cpf_registration',
    topic: 'documents',
    title: { pt: 'CPF', es: 'CPF', en: 'CPF registration' },
    aliases: {
      pt: ['tirar cpf', 'fazer cpf', 'obter cpf', 'inscrição no cpf', 'cpf'],
      es: [
        'sacar cpf',
        'obtener cpf',
        'tramitar cpf',
        'inscripción en el cpf',
        'cpf',
      ],
      en: ['get a cpf', 'apply for cpf', 'cpf registration', 'cpf'],
    },
    concepts: [['cpf', 'cadastro fiscal', 'tax id']],
    negativeAliases: ['alugar sem cpf', 'alquiler sin cpf', 'rent without cpf'],
    priority: 120,
    entryId: 'documents-cpf-residence-overview',
    claimIds: ['documents-cpf-and-residence-are-separate'],
  },
  {
    id: 'documents.residence_authorization',
    topic: 'documents',
    title: {
      pt: 'Autorização de residência',
      es: 'Autorización de residencia',
      en: 'Residence authorization',
    },
    aliases: {
      pt: [
        'autorização de residência',
        'residência mercosul',
        'regularizar residência',
        'documentos para residência',
        'crnm',
        'rne',
      ],
      es: [
        'autorización de residencia',
        'residencia mercosur',
        'regularizar residencia',
        'documentos para residencia',
        'crnm',
        'rne',
      ],
      en: [
        'residence authorization',
        'mercosur residence',
        'regularize residence',
        'residence documents',
        'crnm',
        'rne',
      ],
    },
    concepts: [
      ['residencia', 'residência', 'residence', 'crnm', 'rne'],
      ['mercosul', 'mercosur', 'regularização', 'regularizacion'],
    ],
    negativeAliases: [
      'conta sem crnm',
      'cuenta sin crnm',
      'account without crnm',
      'pix sem crnm',
      'pix sin crnm',
      'pix without crnm',
      'chip sem crnm',
      'chip sin crnm',
      'sim without crnm',
      'internet sem crnm',
      'internet sin crnm',
      'internet without crnm',
    ],
    priority: 115,
    entryId: 'documents-cpf-residence-overview',
    claimIds: ['documents-confirm-route'],
    clarification: {
      id: 'residence-basis',
      contextKey: 'residenceBasis',
      prompt: {
        pt: 'Qual é a base principal do seu pedido de residência?',
        es: '¿Cuál es la base principal de tu solicitud de residencia?',
        en: 'What is the main basis for your residence application?',
      },
      options: [
        {
          value: 'mercosur',
          label: {
            pt: 'Nacionalidade Mercosul',
            es: 'Nacionalidad Mercosur',
            en: 'Mercosur nationality',
          },
        },
        {
          value: 'family',
          label: {
            pt: 'Reunião familiar',
            es: 'Reunificación familiar',
            en: 'Family reunification',
          },
        },
        {
          value: 'work_study',
          label: {
            pt: 'Trabalho ou estudo',
            es: 'Trabajo o estudio',
            en: 'Work or study',
          },
        },
        {
          value: 'unknown',
          label: {
            pt: 'Ainda não sei',
            es: 'Todavía no sé',
            en: 'I am not sure yet',
          },
        },
      ],
    },
    decisionContextKey: 'residenceBasis',
    decisionBranches: [
      {
        value: 'mercosur',
        title: {
          pt: 'Caminho inicial — Mercosul',
          es: 'Camino inicial — Mercosur',
          en: 'Starting path — Mercosur',
        },
        steps: [
          {
            pt: 'Abra o serviço de autorização de residência da Polícia Federal e selecione o fundamento Mercosul.',
            es: 'Abrí el servicio de autorización de residencia de la Policía Federal y elegí el fundamento Mercosur.',
            en: 'Open the Federal Police residence service and select the Mercosur basis.',
          },
          {
            pt: 'Confira a lista vigente antes de reunir ou traduzir documentos.',
            es: 'Revisá la lista vigente antes de reunir o traducir documentos.',
            en: 'Check the current list before collecting or translating documents.',
          },
        ],
      },
      {
        value: 'family',
        title: {
          pt: 'Caminho inicial — reunião familiar',
          es: 'Camino inicial — reunificación familiar',
          en: 'Starting path — family reunification',
        },
        steps: [
          {
            pt: 'Identifique o vínculo familiar aceito no serviço oficial antes de preparar o pedido.',
            es: 'Identificá el vínculo familiar aceptado en el servicio oficial antes de preparar la solicitud.',
            en: 'Identify the accepted family relationship in the official service before preparing the application.',
          },
          {
            pt: 'Confira na Polícia Federal os documentos correspondentes ao vínculo.',
            es: 'Confirmá en la Policía Federal los documentos correspondientes al vínculo.',
            en: 'Confirm the documents for that relationship with the Federal Police.',
          },
        ],
      },
      {
        value: 'work_study',
        title: {
          pt: 'Caminho inicial — trabalho ou estudo',
          es: 'Camino inicial — trabajo o estudio',
          en: 'Starting path — work or study',
        },
        steps: [
          {
            pt: 'Separe trabalho e estudo: são fundamentos diferentes e podem exigir serviços distintos.',
            es: 'Separá trabajo y estudio: son fundamentos diferentes y pueden requerir servicios distintos.',
            en: 'Separate work and study: they are different bases and may require different services.',
          },
          {
            pt: 'Confirme o fundamento e a lista vigente na Polícia Federal antes de iniciar.',
            es: 'Confirmá el fundamento y la lista vigente en la Policía Federal antes de comenzar.',
            en: 'Confirm the basis and current list with the Federal Police before starting.',
          },
        ],
      },
      {
        value: 'unknown',
        title: {
          pt: 'Primeiro identifique o fundamento',
          es: 'Primero identificá el fundamento',
          en: 'Identify the basis first',
        },
        steps: [
          {
            pt: 'Não reúna documentos por uma lista genérica: escolha primeiro o motivo jurídico da residência.',
            es: 'No reúnas documentos con una lista genérica: elegí primero el motivo jurídico de la residencia.',
            en: 'Do not collect documents from a generic list: first identify the legal basis for residence.',
          },
          {
            pt: 'Compare os fundamentos disponíveis no serviço oficial da Polícia Federal.',
            es: 'Compará los fundamentos disponibles en el servicio oficial de la Policía Federal.',
            en: 'Compare the available bases in the official Federal Police service.',
          },
        ],
      },
    ],
  },
  {
    id: 'documents.overview',
    topic: 'documents',
    title: { pt: 'Documentos', es: 'Documentos', en: 'Documents' },
    aliases: {
      pt: [
        'quais documentos preciso',
        'documentos para o brasil',
        'documentação',
      ],
      es: [
        'qué documentos necesito',
        'documentos para brasil',
        'documentación',
      ],
      en: ['what documents do i need', 'documents for brazil', 'paperwork'],
    },
    concepts: [['documentos', 'documentación', 'documents', 'paperwork']],
    priority: 50,
    entryId: 'documents-cpf-residence-overview',
    clarification: {
      id: 'document-goal',
      contextKey: 'documentGoal',
      prompt: {
        pt: 'Qual documento você quer resolver primeiro?',
        es: '¿Qué documento querés resolver primero?',
        en: 'Which document do you want to resolve first?',
      },
      options: [
        {
          value: 'cpf',
          label: { pt: 'CPF', es: 'CPF', en: 'CPF' },
          targetIntentId: 'documents.cpf_registration',
        },
        {
          value: 'residence',
          label: {
            pt: 'Residência ou CRNM',
            es: 'Residencia o CRNM',
            en: 'Residence or CRNM',
          },
          targetIntentId: 'documents.residence_authorization',
        },
        {
          value: 'both',
          label: {
            pt: 'Entender os dois',
            es: 'Entender ambos',
            en: 'Understand both',
          },
        },
      ],
    },
  },
  {
    id: 'education.basic_enrollment',
    topic: 'education',
    title: {
      pt: 'Matrícula escolar',
      es: 'Matrícula escolar',
      en: 'School enrollment',
    },
    aliases: {
      pt: [
        'matrícula na escola',
        'matricular meu filho',
        'escola pública',
        'creche',
        'ensino fundamental',
        'ensino médio',
      ],
      es: [
        'matrícula escolar',
        'inscribir a mi hijo',
        'escuela pública',
        'jardín',
        'primaria',
        'secundaria',
      ],
      en: [
        'school enrollment',
        'enroll my child',
        'public school',
        'daycare',
        'primary school',
        'secondary school',
      ],
    },
    concepts: [
      ['escola', 'escuela', 'school', 'creche', 'daycare'],
      ['matricula', 'matrícula', 'inscribir', 'enroll'],
    ],
    priority: 110,
    entryId: 'education-basic-network-overview',
    claimIds: ['education-network-first-step'],
  },
  {
    id: 'education.enrollment_without_documents',
    topic: 'education',
    title: {
      pt: 'Matrícula sem todos os documentos',
      es: 'Matrícula sin todos los documentos',
      en: 'Enrollment without every document',
    },
    aliases: {
      pt: [
        'matrícula sem histórico escolar',
        'escola recusou por falta de documento',
        'matricular criança estrangeira sem crnm',
        'como definir a série sem histórico',
      ],
      es: [
        'matrícula sin certificado escolar',
        'la escuela rechazó por falta de documentos',
        'inscribir niño extranjero sin crnm',
        'cómo definir el grado sin antecedentes escolares',
      ],
      en: [
        'enroll without school records',
        'school refused due to missing documents',
        'enroll a foreign child without crnm',
        'school grade without prior records',
      ],
    },
    concepts: [
      ['escola', 'escuela', 'school', 'matricula', 'matrícula', 'enroll'],
      [
        'sem documento',
        'sin documento',
        'missing document',
        'sem historico',
        'sin certificado',
        'without school records',
        'recusou',
        'rechazo',
        'refused',
      ],
    ],
    priority: 175,
    entryId: 'education-basic-network-overview',
    claimIds: ['education-migrant-enrollment-cannot-wait-for-regularization'],
  },
  {
    id: 'education.university_admission',
    topic: 'education',
    title: { pt: 'Universidade', es: 'Universidad', en: 'University' },
    aliases: {
      pt: [
        'entrar na universidade',
        'faculdade',
        'sisu',
        'vestibular',
        'revalidar diploma',
      ],
      es: [
        'entrar a la universidad',
        'facultad',
        'sisu',
        'examen de ingreso',
        'revalidar diploma',
      ],
      en: [
        'enter university',
        'college admission',
        'sisu',
        'entrance exam',
        'validate diploma',
      ],
    },
    concepts: [
      ['universidade', 'universidad', 'university', 'faculdade', 'college'],
      ['diploma', 'sisu', 'vestibular'],
    ],
    priority: 115,
    partialAnswer: helpTopicsAnswer,
  },
  {
    id: 'education.overview',
    topic: 'education',
    title: { pt: 'Educação', es: 'Educación', en: 'Education' },
    aliases: {
      pt: ['estudar no brasil', 'educação no brasil'],
      es: ['estudiar en brasil', 'educación en brasil'],
      en: ['study in brazil', 'education in brazil'],
    },
    concepts: [
      ['estudar', 'estudiar', 'study', 'educacao', 'educación', 'education'],
    ],
    priority: 45,
    entryId: 'education-basic-network-overview',
    clarification: {
      id: 'education-level',
      contextKey: 'educationLevel',
      prompt: {
        pt: 'Você quer resolver escola básica ou universidade?',
        es: '¿Querés resolver escuela básica o universidad?',
        en: 'Do you need help with basic school or university?',
      },
      options: [
        {
          value: 'basic',
          label: {
            pt: 'Escola ou creche',
            es: 'Escuela o jardín',
            en: 'School or daycare',
          },
          targetIntentId: 'education.basic_enrollment',
        },
        {
          value: 'university',
          label: {
            pt: 'Universidade ou diploma',
            es: 'Universidad o diploma',
            en: 'University or diploma',
          },
          targetIntentId: 'education.university_admission',
        },
      ],
    },
  },
  {
    id: 'housing.rental_guarantees',
    topic: 'housing',
    title: {
      pt: 'Garantias do aluguel',
      es: 'Garantías del alquiler',
      en: 'Rental guarantees',
    },
    aliases: {
      pt: [
        'caução e fiador',
        'garantia do aluguel',
        'seguro fiança',
        'pode pedir duas garantias',
        'fiador',
      ],
      es: [
        'depósito y garante',
        'garantía del alquiler',
        'seguro de caución',
        'puede pedir dos garantías',
        'garante',
      ],
      en: [
        'deposit and guarantor',
        'rental guarantee',
        'rental insurance',
        'two guarantees',
        'guarantor',
      ],
    },
    concepts: [
      [
        'caucao',
        'caução',
        'deposito',
        'depósito',
        'deposit',
        'fiador',
        'garante',
        'guarantor',
      ],
      ['garantia', 'guarantee', 'seguro fianca'],
    ],
    priority: 120,
    entryId: 'housing-rental-guarantees',
  },
  {
    id: 'housing.without_brazilian_history',
    topic: 'housing',
    title: {
      pt: 'Alugar sem histórico no Brasil',
      es: 'Alquilar sin historial en Brasil',
      en: 'Renting without Brazilian history',
    },
    aliases: {
      pt: [
        'alugar sem cpf',
        'alugar sem fiador',
        'sem histórico de crédito',
        'recém chegado aluguel',
      ],
      es: [
        'alquilar sin cpf',
        'alquilar sin garante',
        'sin historial crediticio',
        'recién llegado alquiler',
      ],
      en: [
        'rent without cpf',
        'rent without guarantor',
        'no credit history',
        'new arrival rent',
      ],
    },
    concepts: [
      ['sem cpf', 'sin cpf', 'without cpf'],
      ['sem fiador', 'sin garante', 'without guarantor'],
      ['historico de credito', 'historial crediticio', 'credit history'],
    ],
    priority: 115,
    partialAnswer: helpTopicsAnswer,
  },
  {
    id: 'housing.rental_fraud',
    topic: 'housing',
    title: {
      pt: 'Possível golpe no aluguel',
      es: 'Posible estafa de alquiler',
      en: 'Possible rental scam',
    },
    aliases: {
      pt: [
        'golpe do aluguel',
        'paguei sinal',
        'proprietário desapareceu',
        'anúncio falso',
      ],
      es: [
        'estafa de alquiler',
        'pagué una reserva',
        'propietario desapareció',
        'anuncio falso',
      ],
      en: [
        'rental scam',
        'paid a deposit',
        'landlord disappeared',
        'fake listing',
      ],
    },
    concepts: [
      ['golpe', 'estafa', 'scam', 'fraude', 'fraud'],
      ['sinal', 'reserva', 'deposit'],
    ],
    priority: 130,
    partialAnswer: {
      pt: 'Há sinais de possível fraude. Não faça novos pagamentos, preserve anúncio, conversas e comprovantes e procure orientação formal de defesa do consumidor ou segurança pública. Ainda não temos uma resposta jurídica revisada específica para o seu caso.',
      es: 'Hay señales de posible fraude. No hagas nuevos pagos, guardá el anuncio, las conversaciones y los comprobantes y buscá orientación formal de defensa del consumidor o seguridad pública. Todavía no tenemos una respuesta jurídica revisada específica para tu caso.',
      en: 'There may be signs of fraud. Do not make further payments, preserve the listing, messages, and receipts, and seek formal consumer-protection or public-safety guidance. We do not yet have reviewed legal guidance for your specific case.',
    },
  },
  {
    id: 'work.digital_card',
    topic: 'work',
    title: {
      pt: 'Trabalho formal e CTPS',
      es: 'Trabajo formal y CTPS',
      en: 'Formal work and digital work card',
    },
    aliases: {
      pt: [
        'carteira de trabalho digital',
        'ctps',
        'trabalho formal',
        'documentos para trabalhar',
      ],
      es: [
        'libreta de trabajo digital',
        'ctps',
        'trabajo formal',
        'documentos para trabajar',
      ],
      en: [
        'digital work card',
        'ctps',
        'formal employment',
        'documents to work',
      ],
    },
    concepts: [
      ['ctps', 'carteira de trabalho', 'libreta de trabajo', 'work card'],
      ['trabalho formal', 'trabajo formal', 'formal work'],
    ],
    priority: 115,
    entryId: 'work-digital-card',
  },
  {
    id: 'work.job_search',
    topic: 'work',
    title: { pt: 'Buscar trabalho', es: 'Buscar trabajo', en: 'Finding work' },
    aliases: {
      pt: [
        'buscar emprego',
        'procurar trabalho',
        'onde achar vagas',
        'currículo',
      ],
      es: [
        'buscar empleo',
        'buscar trabajo',
        'dónde encontrar vacantes',
        'currículum',
      ],
      en: ['find a job', 'job search', 'where to find jobs', 'resume'],
    },
    concepts: [
      ['emprego', 'empleo', 'job', 'vaga', 'vacante'],
      ['curriculo', 'currículum', 'resume'],
    ],
    priority: 100,
    partialAnswer: helpTopicsAnswer,
  },
  {
    id: 'health.sus_access',
    topic: 'health',
    title: { pt: 'Acesso ao SUS', es: 'Acceso al SUS', en: 'Access to SUS' },
    aliases: {
      pt: [
        'acessar o sus',
        'atendimento no sus',
        'estrangeiro no sus',
        'posto de saúde',
        'ubs',
        'cartão sus',
      ],
      es: [
        'acceder al sus',
        'atención en el sus',
        'extranjero en el sus',
        'centro de salud',
        'ubs',
        'tarjeta sus',
      ],
      en: [
        'access sus',
        'sus care',
        'foreigner sus',
        'health clinic',
        'ubs',
        'sus card',
      ],
    },
    concepts: [
      ['sus', 'ubs', 'posto de saude', 'centro de salud', 'health clinic'],
      ['estrangeiro', 'extranjero', 'foreigner', 'migrante', 'migrant'],
    ],
    priority: 115,
    entryId: 'health-sus-access',
  },
  {
    id: 'health.emergency',
    topic: 'health',
    title: {
      pt: 'Urgência de saúde',
      es: 'Urgencia de salud',
      en: 'Health emergency',
    },
    aliases: {
      pt: [
        'emergência médica',
        'urgência médica',
        'preciso de atendimento agora',
      ],
      es: ['emergencia médica', 'urgencia médica', 'necesito atención ahora'],
      en: ['medical emergency', 'urgent medical care', 'need care now'],
    },
    concepts: [
      [
        'emergencia',
        'emergência',
        'emergency',
        'urgencia',
        'urgência',
        'urgent',
      ],
    ],
    priority: 150,
    entryId: 'health-sus-access',
    partialAnswer: {
      pt: 'Se houver risco imediato, procure um serviço de urgência agora. A Ajuda pode explicar acesso ao SUS, mas não avalia sintomas nem substitui atendimento médico.',
      es: 'Si hay riesgo inmediato, buscá un servicio de urgencias ahora. Ayuda puede explicar el acceso al SUS, pero no evalúa síntomas ni reemplaza la atención médica.',
      en: 'If there is immediate risk, seek emergency care now. Help can explain access to SUS, but it cannot assess symptoms or replace medical care.',
    },
  },
  {
    id: 'driving.foreign_licence',
    topic: 'driving',
    title: {
      pt: 'Habilitação estrangeira',
      es: 'Licencia extranjera',
      en: 'Foreign driving licence',
    },
    aliases: {
      pt: [
        'dirigir com carteira argentina',
        'habilitação estrangeira',
        'trocar pela cnh',
        'cnh para estrangeiro',
      ],
      es: [
        'conducir con licencia argentina',
        'licencia extranjera',
        'cambiar por cnh',
        'cnh para extranjeros',
      ],
      en: [
        'drive with argentine licence',
        'foreign driving licence',
        'exchange for cnh',
        'cnh for foreigners',
      ],
    },
    concepts: [
      ['cnh', 'habilitacao', 'habilitação', 'licencia', 'licence'],
      ['dirigir', 'conducir', 'drive'],
    ],
    priority: 120,
    entryId: 'driving-foreign-licence-overview',
    clarification: {
      id: 'driving-goal',
      contextKey: 'drivingGoal',
      prompt: {
        pt: 'O que você precisa resolver com a habilitação?',
        es: '¿Qué necesitás resolver con la licencia?',
        en: 'What do you need to resolve with the licence?',
      },
      options: [
        {
          value: 'temporary',
          label: {
            pt: 'Dirigir temporariamente',
            es: 'Conducir temporalmente',
            en: 'Drive temporarily',
          },
        },
        {
          value: 'exchange',
          label: {
            pt: 'Trocar pela CNH',
            es: 'Cambiar por la CNH',
            en: 'Exchange for CNH',
          },
        },
      ],
    },
    decisionContextKey: 'drivingGoal',
    decisionBranches: [
      {
        value: 'temporary',
        title: {
          pt: 'Antes de dirigir',
          es: 'Antes de conducir',
          en: 'Before driving',
        },
        steps: [
          {
            pt: 'Confirme na regra da Senatran se o país emissor, a validade e o tempo de permanência atendem às condições.',
            es: 'Confirmá en la regla de Senatran si el país emisor, la vigencia y el tiempo de permanencia cumplen las condiciones.',
            en: 'Confirm in the Senatran rule whether issuing country, validity, and length of stay meet the conditions.',
          },
          {
            pt: 'Leve o documento original válido e a identificação exigida.',
            es: 'Llevá el documento original vigente y la identificación exigida.',
            en: 'Carry the valid original document and required identification.',
          },
        ],
      },
      {
        value: 'exchange',
        title: {
          pt: 'Para iniciar a troca',
          es: 'Para iniciar el cambio',
          en: 'To start the exchange',
        },
        steps: [
          {
            pt: 'Consulte primeiro a regra nacional da Senatran.',
            es: 'Consultá primero la regla nacional de Senatran.',
            en: 'Check the national Senatran rule first.',
          },
          {
            pt: 'Depois confirme documentos, taxas e agendamento no Detran do seu estado.',
            es: 'Después confirmá documentos, tasas y turno en el Detran de tu estado.',
            en: 'Then confirm documents, fees, and booking with your state Detran.',
          },
        ],
      },
    ],
  },
  {
    id: 'documents.entry_document',
    topic: 'documents',
    title: {
      pt: 'Documento para entrar e mudar',
      es: 'Documento para ingresar y mudarse',
      en: 'Documents for entry and moving',
    },
    aliases: {
      pt: [
        'posso entrar com dni para morar',
        'preciso de passaporte para mudar',
        'documento para entrar no brasil e morar',
        'dni ou passaporte para residência',
      ],
      es: [
        'puedo entrar con dni para vivir',
        'necesito pasaporte para mudarme',
        'documento para entrar a brasil y vivir',
        'dni o pasaporte para residencia',
      ],
      en: [
        'can i enter with an id card to live',
        'do i need a passport to move',
        'document to enter brazil and live',
        'id card or passport for residence',
      ],
    },
    concepts: [
      ['dni', 'passaporte', 'pasaporte', 'passport', 'documento de viagem'],
      ['morar', 'mudanca', 'mudanza', 'move', 'residencia', 'residence'],
    ],
    priority: 150,
    entryId: 'documents-entry-residence-lifecycle',
    claimIds: [
      'entry-purpose-changes-document',
      'residence-route-is-separate-from-entry',
    ],
  },
  {
    id: 'documents.crnm_lifecycle',
    topic: 'documents',
    title: {
      pt: 'Renovar, corrigir ou substituir CRNM',
      es: 'Renovar, corregir o sustituir la CRNM',
      en: 'Renew, correct, or replace a CRNM',
    },
    aliases: {
      pt: [
        'renovar crnm',
        'transformar residência permanente',
        'perdi minha crnm',
        'segunda via crnm',
      ],
      es: [
        'renovar crnm',
        'transformar residencia permanente',
        'perdí mi crnm',
        'duplicado crnm',
      ],
      en: [
        'renew crnm',
        'change to permanent residence',
        'lost my crnm',
        'duplicate crnm',
      ],
    },
    concepts: [
      ['crnm', 'rnm', 'registro migratorio', 'migration card'],
      ['renovar', 'renew', 'segunda via', 'duplicate', 'perdi', 'lost'],
    ],
    priority: 145,
    entryId: 'documents-entry-residence-lifecycle',
    claimIds: ['crnm-lifecycle-has-specific-services'],
  },
  {
    id: 'documents.data_divergence',
    topic: 'documents',
    title: {
      pt: 'Corrigir dados divergentes',
      es: 'Corregir datos divergentes',
      en: 'Correct conflicting data',
    },
    aliases: {
      pt: [
        'corrigir dados crnm',
        'nome errado na crnm',
        'filiação divergente nos documentos',
        'data de nascimento errada no registro',
      ],
      es: [
        'corregir datos crnm',
        'nombre incorrecto en la crnm',
        'filiación diferente en los documentos',
        'fecha de nacimiento incorrecta en el registro',
      ],
      en: [
        'correct crnm data',
        'wrong name on crnm',
        'parentage differs across documents',
        'wrong birth date in migration record',
      ],
    },
    concepts: [
      ['crnm', 'rnm', 'registro', 'documento', 'document'],
      [
        'corrigir',
        'corregir',
        'correct',
        'errado',
        'incorrecto',
        'wrong',
        'divergente',
        'diferente',
        'conflicting',
      ],
    ],
    priority: 180,
    entryId: 'documents-entry-residence-lifecycle',
    claimIds: ['residence-divergence-needs-specific-correction'],
  },
  {
    id: 'documents.process_delayed',
    topic: 'documents',
    title: {
      pt: 'Processo migratório parado',
      es: 'Trámite migratorio demorado',
      en: 'Stalled migration process',
    },
    aliases: {
      pt: [
        'meu protocolo está demorando',
        'processo de residência parado',
        'crnm não chegou',
        'pedido migratório sem resposta',
      ],
      es: [
        'mi protocolo está demorando',
        'trámite de residencia detenido',
        'la crnm no llegó',
        'solicitud migratoria sin respuesta',
      ],
      en: [
        'my residence protocol is delayed',
        'residence process is stalled',
        'crnm has not arrived',
        'migration application has no response',
      ],
    },
    concepts: [
      ['protocolo', 'processo', 'trámite', 'process', 'crnm', 'residencia'],
      [
        'demorando',
        'parado',
        'detenido',
        'demorado',
        'delayed',
        'stalled',
        'nao chegou',
        'no llegó',
        'not arrived',
      ],
    ],
    priority: 185,
    entryId: 'documents-entry-residence-lifecycle',
    claimIds: ['residence-delay-needs-traceable-escalation'],
    clarification: {
      id: 'migration-process-stage',
      contextKey: 'migrationProcessStage',
      prompt: {
        pt: 'Em que ponto o processo parou?',
        es: '¿En qué punto se detuvo el trámite?',
        en: 'At which stage did the process stop?',
      },
      options: [
        {
          value: 'before_appointment',
          label: {
            pt: 'Antes do atendimento',
            es: 'Antes de la cita',
            en: 'Before the appointment',
          },
        },
        {
          value: 'under_review',
          label: { pt: 'Em análise', es: 'En análisis', en: 'Under review' },
        },
        {
          value: 'card_pending',
          label: {
            pt: 'CRNM não chegou',
            es: 'La CRNM no llegó',
            en: 'CRNM not delivered',
          },
        },
      ],
    },
    decisionContextKey: 'migrationProcessStage',
    decisionBranches: [
      {
        value: 'before_appointment',
        title: {
          pt: 'Sem atendimento concluído',
          es: 'Sin cita completada',
          en: 'Appointment not completed',
        },
        steps: [
          {
            pt: 'Confirme se o requerimento foi finalizado e se existe agendamento válido.',
            es: 'Confirmá si la solicitud fue finalizada y si existe un turno válido.',
            en: 'Confirm that the application was completed and that a valid appointment exists.',
          },
          {
            pt: 'Guarde número do requerimento, comprovante e mensagem de erro antes de contatar a unidade.',
            es: 'Guardá el número de solicitud, comprobante y mensaje de error antes de contactar a la unidad.',
            en: 'Keep the application number, receipt, and error message before contacting the office.',
          },
        ],
      },
      {
        value: 'under_review',
        title: {
          pt: 'Pedido em análise',
          es: 'Solicitud en análisis',
          en: 'Application under review',
        },
        steps: [
          {
            pt: 'Reúna protocolo, unidade, data do atendimento e eventual exigência recebida.',
            es: 'Reuní protocolo, unidad, fecha de atención y cualquier requerimiento recibido.',
            en: 'Gather the protocol, office, appointment date, and any request for additional information.',
          },
          {
            pt: 'Peça atualização no canal responsável; sem solução, registre manifestação rastreável na ouvidoria.',
            es: 'Pedí una actualización al canal responsable; si no se resuelve, registrá una manifestación rastreable en la defensoría.',
            en: 'Request an update from the responsible channel; if unresolved, file a traceable ombudsman report.',
          },
        ],
      },
      {
        value: 'card_pending',
        title: {
          pt: 'Documento físico pendente',
          es: 'Documento físico pendiente',
          en: 'Physical document pending',
        },
        steps: [
          {
            pt: 'Separe protocolo, comprovante de aprovação ou registro e unidade de atendimento.',
            es: 'Separá protocolo, comprobante de aprobación o registro y unidad de atención.',
            en: 'Collect the protocol, approval or registration receipt, and service office.',
          },
          {
            pt: 'Confirme com a unidade o estado da emissão antes de pedir segunda via ou iniciar outro serviço.',
            es: 'Confirmá con la unidad el estado de emisión antes de pedir un duplicado o iniciar otro trámite.',
            en: 'Confirm issuance status with the office before requesting a duplicate or starting another service.',
          },
        ],
      },
    ],
  },
  {
    id: 'documents.travel_during_process',
    topic: 'documents',
    title: {
      pt: 'Viajar com residência em andamento',
      es: 'Viajar con la residencia en trámite',
      en: 'Travel while residence is in progress',
    },
    aliases: {
      pt: [
        'posso viajar com protocolo de residência',
        'sair do brasil enquanto espero crnm',
        'reentrar no brasil sem crnm física',
        'viajar com residência em andamento',
      ],
      es: [
        'puedo viajar con protocolo de residencia',
        'salir de brasil mientras espero la crnm',
        'volver a entrar sin crnm física',
        'viajar con residencia en trámite',
      ],
      en: [
        'can i travel with a residence protocol',
        'leave brazil while waiting for crnm',
        'reenter brazil without physical crnm',
        'travel while residence is pending',
      ],
    },
    concepts: [
      [
        'viajar',
        'viaje',
        'travel',
        'sair',
        'salir',
        'leave',
        'reentrar',
        'reingresar',
        'reenter',
      ],
      ['protocolo', 'protocol', 'residencia', 'residence', 'crnm'],
    ],
    priority: 160,
    entryId: 'documents-entry-residence-lifecycle',
    claimIds: ['residence-travel-needs-reentry-check'],
  },
  {
    id: 'finance.bank_account',
    topic: 'finance',
    title: {
      pt: 'Abrir conta como migrante',
      es: 'Abrir una cuenta como migrante',
      en: 'Open an account as a migrant',
    },
    aliases: {
      pt: [
        'abrir conta sem crnm',
        'conta com passaporte',
        'conta bancária estrangeiro',
        'banco para migrante',
      ],
      es: [
        'abrir cuenta sin crnm',
        'cuenta con pasaporte',
        'cuenta bancaria extranjero',
        'banco para migrante',
      ],
      en: [
        'open account without crnm',
        'bank account with passport',
        'foreign national bank account',
        'bank for migrants',
      ],
    },
    concepts: [
      ['banco', 'bank', 'conta', 'cuenta', 'account'],
      [
        'migrante',
        'estrangeiro',
        'extranjero',
        'foreign',
        'passaporte',
        'pasaporte',
        'passport',
        'crnm',
      ],
    ],
    negativeAliases: [
      'melhor banco',
      'mejor banco',
      'best bank',
      'recomendar banco',
      'recommend a bank',
    ],
    priority: 150,
    entryId: 'finance-banking-pix-govbr',
    claimIds: ['finance-foreign-id-may-be-accepted'],
  },
  {
    id: 'finance.bank_refusal',
    topic: 'finance',
    title: {
      pt: 'Banco recusou a conta',
      es: 'El banco rechazó la cuenta',
      en: 'Bank refused the account',
    },
    aliases: {
      pt: [
        'banco recusou minha conta',
        'não consigo abrir conta',
        'banco não aceita passaporte',
        'conta rejeitada',
      ],
      es: [
        'el banco rechazó mi cuenta',
        'no puedo abrir una cuenta',
        'el banco no acepta pasaporte',
        'cuenta rechazada',
      ],
      en: [
        'bank refused my account',
        'cannot open a bank account',
        'bank will not accept passport',
        'account rejected',
      ],
    },
    concepts: [
      ['banco', 'bank', 'conta', 'cuenta', 'account'],
      ['recusou', 'rejeitou', 'rechazo', 'rejected', 'refused', 'nao aceita'],
    ],
    negativeAliases: [
      'melhor banco',
      'mejor banco',
      'best bank',
      'recomendar banco',
      'recommend a bank',
    ],
    priority: 155,
    entryId: 'finance-banking-pix-govbr',
    claimIds: [
      'finance-foreign-id-may-be-accepted',
      'finance-refusal-needs-reason-and-escalation',
    ],
    clarification: {
      id: 'bank-refusal-reason',
      contextKey: 'bankRefusalReason',
      prompt: {
        pt: 'O que o banco informou?',
        es: '¿Qué informó el banco?',
        en: 'What did the bank tell you?',
      },
      options: [
        {
          value: 'crnm',
          label: { pt: 'Exigiu CRNM', es: 'Exigió CRNM', en: 'Required CRNM' },
        },
        {
          value: 'address',
          label: {
            pt: 'Recusou endereço',
            es: 'Rechazó el domicilio',
            en: 'Rejected address proof',
          },
        },
        {
          value: 'no_reason',
          label: { pt: 'Não explicou', es: 'No explicó', en: 'Gave no reason' },
        },
      ],
    },
    decisionContextKey: 'bankRefusalReason',
    decisionBranches: [
      {
        value: 'crnm',
        title: {
          pt: 'Exigência de CRNM',
          es: 'Exigencia de CRNM',
          en: 'CRNM requirement',
        },
        steps: [
          {
            pt: 'Peça por escrito a lista de documentos aceita para pessoa migrante e o motivo da recusa.',
            es: 'Pedí por escrito la lista de documentos aceptados para personas migrantes y el motivo del rechazo.',
            en: 'Request the accepted migrant-document list and refusal reason in writing.',
          },
          {
            pt: 'Guarde o protocolo e escale ao atendimento ou ouvidoria; depois, avalie o canal do Banco Central.',
            es: 'Guardá el protocolo y escalá a atención o defensoría; después, evaluá el canal del Banco Central.',
            en: 'Keep the protocol and escalate to customer service or the ombudsman; then consider the Central Bank channel.',
          },
        ],
      },
      {
        value: 'address',
        title: {
          pt: 'Comprovante não aceito',
          es: 'Comprobante no aceptado',
          en: 'Address proof rejected',
        },
        steps: [
          {
            pt: 'Peça a lista exata de comprovantes e alternativas aceitas pela instituição.',
            es: 'Pedí la lista exacta de comprobantes y alternativas aceptadas por la institución.',
            en: 'Request the institution’s exact list of accepted proofs and alternatives.',
          },
          {
            pt: 'Não altere ou invente comprovante; peça o motivo da recusa e preserve o protocolo.',
            es: 'No alteres ni inventes un comprobante; pedí el motivo del rechazo y conservá el protocolo.',
            en: 'Do not alter or fabricate proof; request the refusal reason and keep the protocol.',
          },
        ],
      },
      {
        value: 'no_reason',
        title: {
          pt: 'Recusa sem explicação',
          es: 'Rechazo sin explicación',
          en: 'Refusal without explanation',
        },
        steps: [
          {
            pt: 'Solicite o motivo e os requisitos por um canal oficial e anote data, instituição e protocolo.',
            es: 'Solicitá el motivo y los requisitos por un canal oficial y anotá fecha, institución y protocolo.',
            en: 'Request the reason and requirements through an official channel and record the date, institution, and protocol.',
          },
          {
            pt: 'Se o atendimento não resolver, avance para ouvidoria e depois para o canal regulatório aplicável.',
            es: 'Si atención no resuelve, avanzá a defensoría y después al canal regulatorio aplicable.',
            en: 'If customer service does not resolve it, move to the ombudsman and then the applicable regulatory channel.',
          },
        ],
      },
    ],
  },
  {
    id: 'finance.govbr_access',
    topic: 'finance',
    title: {
      pt: 'Criar e aumentar a conta gov.br',
      es: 'Crear y aumentar la cuenta gov.br',
      en: 'Create and upgrade a gov.br account',
    },
    aliases: {
      pt: [
        'criar conta gov br',
        'subir gov br para prata',
        'gov br sem banco',
        'gov br estrangeiro',
      ],
      es: [
        'crear cuenta gov br',
        'subir gov br a plata',
        'gov br sin banco',
        'gov br extranjero',
      ],
      en: [
        'create gov br account',
        'upgrade gov br to silver',
        'gov br without a bank',
        'gov br foreign national',
      ],
    },
    concepts: [
      ['gov br', 'govbr'],
      [
        'bronze',
        'prata',
        'plata',
        'silver',
        'ouro',
        'oro',
        'gold',
        'nivel',
        'level',
      ],
    ],
    priority: 150,
    entryId: 'finance-banking-pix-govbr',
    claimIds: ['finance-govbr-levels-differ'],
  },
  {
    id: 'finance.pix_access',
    topic: 'finance',
    title: { pt: 'Usar Pix', es: 'Usar Pix', en: 'Use Pix' },
    aliases: {
      pt: [
        'como ter pix sendo estrangeiro',
        'pix sem crnm',
        'pix antes da residência',
        'preciso de cpf para pix',
      ],
      es: [
        'cómo tener pix siendo extranjero',
        'pix sin crnm',
        'pix antes de la residencia',
        'necesito cpf para pix',
      ],
      en: [
        'how to get pix as a foreign national',
        'pix without crnm',
        'pix before residence',
        'do i need cpf for pix',
      ],
    },
    concepts: [
      ['pix'],
      [
        'estrangeiro',
        'extranjero',
        'foreign',
        'crnm',
        'residencia',
        'residence',
        'cpf',
      ],
    ],
    priority: 155,
    entryId: 'finance-banking-pix-govbr',
    claimIds: ['finance-pix-requires-participating-account'],
  },
  {
    id: 'finance.international_remittance',
    topic: 'finance',
    title: {
      pt: 'Enviar dinheiro Argentina–Brasil',
      es: 'Enviar dinero Argentina–Brasil',
      en: 'Send money between Argentina and Brazil',
    },
    aliases: {
      pt: [
        'enviar dinheiro da argentina para brasil',
        'receber dinheiro do exterior',
        'transferir economias para o brasil',
        'remessa internacional argentina brasil',
      ],
      es: [
        'enviar dinero de argentina a brasil',
        'recibir dinero del exterior',
        'transferir ahorros a brasil',
        'remesa internacional argentina brasil',
      ],
      en: [
        'send money from argentina to brazil',
        'receive money from abroad',
        'transfer savings to brazil',
        'international remittance argentina brazil',
      ],
    },
    concepts: [
      [
        'remessa',
        'remesa',
        'remittance',
        'transferir',
        'transfer',
        'enviar',
        'send',
        'receber',
        'recibir',
        'receive',
      ],
      ['dinheiro', 'dinero', 'money', 'economias', 'ahorros', 'savings'],
      ['argentina', 'exterior', 'abroad', 'brasil', 'brazil'],
    ],
    priority: 160,
    entryId: 'finance-banking-pix-govbr',
    claimIds: ['finance-remittance-needs-authorized-provider'],
  },
  {
    id: 'work.mei_access',
    topic: 'work',
    title: {
      pt: 'Trabalhar como MEI',
      es: 'Trabajar como MEI',
      en: 'Work as a MEI',
    },
    aliases: {
      pt: [
        'estrangeiro pode ser mei',
        'abrir mei como migrante',
        'mei sem crnm',
        'trabalhar pj estrangeiro',
      ],
      es: [
        'extranjero puede ser mei',
        'abrir mei como migrante',
        'mei sin crnm',
        'trabajar como pj extranjero',
      ],
      en: [
        'can a foreign national be a mei',
        'open mei as a migrant',
        'mei without crnm',
        'foreign self employment',
      ],
    },
    concepts: [
      [
        'mei',
        'microempreendedor',
        'pj',
        'autonomo',
        'autónomo',
        'self employed',
      ],
      ['estrangeiro', 'extranjero', 'foreign', 'migrante'],
    ],
    priority: 145,
    entryId: 'work-independent-remote-professional',
    claimIds: ['work-mei-has-eligibility-rules'],
  },
  {
    id: 'work.remote_foreign_income',
    topic: 'work',
    title: {
      pt: 'Trabalho remoto para o exterior',
      es: 'Trabajo remoto para el exterior',
      en: 'Remote work for another country',
    },
    aliases: {
      pt: [
        'morar no brasil e trabalhar para argentina',
        'trabalho remoto empresa estrangeira',
        'receber salário do exterior',
        'freelancer para fora morando no brasil',
      ],
      es: [
        'vivir en brasil y trabajar para argentina',
        'trabajo remoto empresa extranjera',
        'cobrar sueldo del exterior',
        'freelance para afuera viviendo en brasil',
      ],
      en: [
        'live in brazil and work for a foreign company',
        'remote work for argentina',
        'receive salary from abroad',
        'foreign freelance income in brazil',
      ],
    },
    concepts: [
      ['remoto', 'remote', 'home office', 'freelance'],
      ['exterior', 'argentina', 'estrangeira', 'extranjera', 'foreign'],
      ['salario', 'sueldo', 'salary', 'renda', 'ingreso', 'income'],
    ],
    negativeAliases: [
      'previdência',
      'previsión',
      'social security',
      'pension agreement',
      'acordo previdenciário',
      'acuerdo previsional',
    ],
    priority: 155,
    entryId: 'work-independent-remote-professional',
    claimIds: ['work-remote-needs-tax-screening'],
  },
  {
    id: 'work.regulated_profession',
    topic: 'work',
    title: {
      pt: 'Diploma e profissão regulamentada',
      es: 'Título y profesión regulada',
      en: 'Qualification and regulated profession',
    },
    aliases: {
      pt: [
        'posso trabalhar antes de revalidar diploma',
        'profissão regulamentada estrangeiro',
        'preciso de conselho profissional',
        'diploma argentino para trabalhar',
      ],
      es: [
        'puedo trabajar antes de revalidar el título',
        'profesión regulada extranjero',
        'necesito consejo profesional',
        'título argentino para trabajar',
      ],
      en: [
        'can i work before diploma revalidation',
        'regulated profession foreign qualification',
        'need professional board registration',
        'argentine diploma for work',
      ],
    },
    concepts: [
      [
        'diploma',
        'titulo',
        'título',
        'qualification',
        'profissao',
        'profesion',
        'profession',
      ],
      [
        'revalidar',
        'revalidation',
        'conselho',
        'consejo',
        'board',
        'regulamentada',
        'regulada',
        'regulated',
      ],
    ],
    priority: 160,
    entryId: 'work-independent-remote-professional',
    claimIds: ['work-diploma-and-board-are-separate'],
  },
  {
    id: 'tax.residence_status',
    topic: 'tax',
    title: {
      pt: 'Quando viro residente fiscal',
      es: 'Cuándo paso a ser residente fiscal',
      en: 'When tax residence begins',
    },
    aliases: {
      pt: [
        'quando viro residente fiscal no brasil',
        'regra dos 184 dias',
        'residência fiscal estrangeiro',
        'imposto quando mudo para o brasil',
      ],
      es: [
        'cuándo soy residente fiscal en brasil',
        'regla de los 184 días',
        'residencia fiscal extranjero',
        'impuestos al mudarme a brasil',
      ],
      en: [
        'when do i become tax resident in brazil',
        '184 day rule brazil',
        'foreign national tax residence',
        'tax when moving to brazil',
      ],
    },
    concepts: [
      [
        'residente fiscal',
        'residencia fiscal',
        'tax resident',
        '184 dias',
        '184 days',
      ],
      ['imposto', 'impuesto', 'tax'],
    ],
    negativeAliases: [
      'quanto imposto vou pagar',
      'exactamente cuánto impuesto',
      'exact tax amount',
      'calcule meu imposto',
      'calculate my tax',
    ],
    priority: 160,
    entryId: 'tax-foreign-income-screening',
    claimIds: ['tax-residence-depends-on-facts-and-dates'],
  },
  {
    id: 'tax.foreign_income',
    topic: 'tax',
    title: {
      pt: 'Renda e patrimônio no exterior',
      es: 'Ingresos y patrimonio en el exterior',
      en: 'Foreign income and assets',
    },
    aliases: {
      pt: [
        'declarar renda da argentina no brasil',
        'salário exterior imposto brasil',
        'investimentos argentina imposto',
        'dupla tributação brasil argentina',
      ],
      es: [
        'declarar ingresos de argentina en brasil',
        'sueldo exterior impuesto brasil',
        'inversiones argentina impuesto',
        'doble imposición brasil argentina',
      ],
      en: [
        'report argentine income in brazil',
        'foreign salary brazil tax',
        'foreign investments brazil tax',
        'brazil argentina double taxation',
      ],
    },
    concepts: [
      [
        'renda',
        'ingreso',
        'income',
        'salario',
        'sueldo',
        'salary',
        'investimento',
        'inversion',
        'investment',
      ],
      ['argentina', 'exterior', 'foreign', 'fora'],
      ['imposto', 'impuesto', 'tax', 'declarar', 'report'],
    ],
    negativeAliases: [
      'quanto imposto vou pagar',
      'exactamente cuánto impuesto',
      'exact tax amount',
      'calcule meu imposto',
      'calculate my tax',
    ],
    priority: 165,
    entryId: 'tax-foreign-income-screening',
    claimIds: ['tax-foreign-income-needs-individual-review'],
  },
  {
    id: 'family.reunification',
    topic: 'family',
    title: {
      pt: 'Reunião familiar',
      es: 'Reunificación familiar',
      en: 'Family reunification',
    },
    aliases: {
      pt: [
        'quem pode pedir reunião familiar',
        'residência para companheiro',
        'residência para filho',
        'trazer família para o brasil',
      ],
      es: [
        'quién puede pedir reunificación familiar',
        'residencia para pareja',
        'residencia para hijo',
        'llevar familia a brasil',
      ],
      en: [
        'who qualifies for family reunification',
        'residence for partner',
        'residence for child',
        'bring family to brazil',
      ],
    },
    concepts: [
      ['reuniao familiar', 'reunificacion familiar', 'family reunification'],
      [
        'companheiro',
        'pareja',
        'partner',
        'filho',
        'hijo',
        'child',
        'familia',
        'family',
      ],
    ],
    negativeAliases: [
      'matricular meu filho',
      'inscribo a mi hijo',
      'enroll my child',
      'escola',
      'escuela',
      'school',
    ],
    priority: 155,
    entryId: 'family-reunion-minors',
    claimIds: ['family-each-person-needs-a-route'],
  },
  {
    id: 'family.minor_travel',
    topic: 'family',
    title: {
      pt: 'Viagem e guarda de menor',
      es: 'Viaje y guarda de un menor',
      en: 'Minor travel and custody',
    },
    aliases: {
      pt: [
        'autorização para viajar com filho',
        'mudar com menor sem outro responsável',
        'guarda compartilhada mudança brasil',
        'documentos criança para viagem',
      ],
      es: [
        'autorización para viajar con hijo',
        'mudarse con menor sin el otro responsable',
        'guarda compartida mudanza brasil',
        'documentos del niño para viajar',
      ],
      en: [
        'authorization to travel with child',
        'move with child without other parent',
        'shared custody move to brazil',
        'child travel documents',
      ],
    },
    concepts: [
      ['menor', 'crianca', 'criança', 'nino', 'niño', 'child'],
      [
        'viagem',
        'viaje',
        'travel',
        'guarda',
        'custody',
        'autorizacao',
        'autorización',
        'authorization',
      ],
    ],
    priority: 160,
    entryId: 'family-reunion-minors',
    claimIds: ['family-minor-travel-is-separate'],
  },
  {
    id: 'health.continuous_treatment',
    topic: 'health',
    title: {
      pt: 'Continuar tratamento no Brasil',
      es: 'Continuar tratamiento en Brasil',
      en: 'Continue treatment in Brazil',
    },
    aliases: {
      pt: [
        'como continuar tratamento no brasil',
        'vou ficar sem remédio',
        'receita argentina vale no brasil',
        'tratamento iniciado na argentina',
      ],
      es: [
        'cómo continuar tratamiento en brasil',
        'me voy a quedar sin medicamento',
        'receta argentina vale en brasil',
        'tratamiento iniciado en argentina',
      ],
      en: [
        'how to continue treatment in brazil',
        'running out of medicine',
        'is a foreign prescription valid in brazil',
        'treatment started abroad',
      ],
    },
    concepts: [
      [
        'tratamento',
        'tratamiento',
        'treatment',
        'medicamento',
        'medicine',
        'remedio',
      ],
      [
        'continuar',
        'continue',
        'receita',
        'receta',
        'prescription',
        'argentina',
      ],
    ],
    priority: 160,
    entryId: 'health-treatment-medicines',
    claimIds: ['health-carrying-and-buying-are-different'],
  },
  {
    id: 'health.controlled_medicine',
    topic: 'health',
    title: {
      pt: 'Levar medicamento controlado',
      es: 'Llevar medicamento controlado',
      en: 'Bring controlled medicine',
    },
    aliases: {
      pt: [
        'levar medicamento controlado para o brasil',
        'entrar com remédio controlado',
        'anvisa autorização medicamento',
        'remédio psiquiátrico na bagagem',
      ],
      es: [
        'llevar medicamento controlado a brasil',
        'entrar con remedio controlado',
        'anvisa autorización medicamento',
        'medicación psiquiátrica en equipaje',
      ],
      en: [
        'bring controlled medicine to brazil',
        'enter brazil with controlled medication',
        'anvisa medicine authorization',
        'psychiatric medicine in baggage',
      ],
    },
    concepts: [
      [
        'medicamento controlado',
        'remedio controlado',
        'controlled medicine',
        'controlled medication',
      ],
      [
        'bagagem',
        'equipaje',
        'baggage',
        'anvisa',
        'autorizacao',
        'authorization',
      ],
    ],
    priority: 170,
    entryId: 'health-treatment-medicines',
    claimIds: ['health-controlled-medicine-may-need-authorization'],
  },
  {
    id: 'housing.cash_deposit',
    topic: 'housing',
    title: {
      pt: 'Caução do aluguel',
      es: 'Depósito del alquiler',
      en: 'Rental cash deposit',
    },
    aliases: {
      pt: [
        'quantos meses de caução',
        'caução de três aluguéis',
        'onde fica depositada a caução',
        'devolução da caução',
      ],
      es: [
        'cuántos meses de depósito',
        'depósito de tres alquileres',
        'dónde se deposita la caución',
        'devolución del depósito',
      ],
      en: [
        'how many months rental deposit',
        'three month cash deposit',
        'where rental deposit is held',
        'return of rental deposit',
      ],
    },
    concepts: [
      ['caucao', 'caução', 'deposito', 'depósito', 'deposit'],
      ['aluguel', 'alquiler', 'rent', 'meses', 'months', 'devolucao', 'return'],
    ],
    priority: 150,
    entryId: 'housing-rental-lifecycle',
    claimIds: ['housing-deposit-limit-and-form'],
  },
  {
    id: 'housing.contract_lifecycle',
    topic: 'housing',
    title: {
      pt: 'Contrato, cobranças e saída do aluguel',
      es: 'Contrato, cobros y salida del alquiler',
      en: 'Rental contract, charges, and exit',
    },
    aliases: {
      pt: [
        'quem paga iptu e condomínio',
        'multa para sair do aluguel',
        'vistoria de entrada aluguel',
        'cobranças contrato aluguel',
        'rescindir contrato antes do prazo',
      ],
      es: [
        'quién paga iptu y expensas',
        'multa por salir del alquiler',
        'inspección de entrada alquiler',
        'cobros contrato alquiler',
        'rescindir contrato antes del plazo',
      ],
      en: [
        'who pays iptu and condominium fees',
        'penalty to leave rental',
        'rental move in inspection',
        'rental contract charges',
        'terminate lease early',
      ],
    },
    concepts: [
      ['contrato', 'contract', 'lease', 'aluguel', 'alquiler', 'rent'],
      [
        'iptu',
        'condominio',
        'expensas',
        'fees',
        'multa',
        'penalty',
        'vistoria',
        'inspection',
        'rescindir',
        'terminate',
      ],
    ],
    priority: 150,
    entryId: 'housing-rental-lifecycle',
    claimIds: ['housing-charges-must-be-checked-in-contract'],
  },
  {
    id: 'housing.early_termination',
    topic: 'housing',
    title: {
      pt: 'Sair do aluguel antes do prazo',
      es: 'Salir del alquiler antes del plazo',
      en: 'Leave a rental before the end of the term',
    },
    aliases: {
      pt: [
        'sair do aluguel antes do prazo',
        'calcular multa proporcional aluguel',
        'rescindir contrato de aluguel',
        'devolver imóvel antes do fim',
      ],
      es: [
        'salir del alquiler antes del plazo',
        'calcular multa proporcional alquiler',
        'rescindir contrato de alquiler',
        'devolver inmueble antes del fin',
      ],
      en: [
        'leave rental before lease ends',
        'calculate proportional rental penalty',
        'terminate rental contract early',
        'return property before end of term',
      ],
    },
    concepts: [
      [
        'sair',
        'salir',
        'leave',
        'rescindir',
        'terminate',
        'devolver',
        'return',
      ],
      ['aluguel', 'alquiler', 'rent', 'contrato', 'contract', 'lease'],
      [
        'prazo',
        'plazo',
        'term',
        'multa',
        'penalty',
        'proporcional',
        'proportional',
      ],
    ],
    priority: 160,
    entryId: 'housing-rental-lifecycle',
    claimIds: ['housing-early-termination-is-proportional'],
  },
  {
    id: 'education.diploma_revalidation',
    topic: 'education',
    title: {
      pt: 'Revalidar diploma argentino',
      es: 'Revalidar título argentino',
      en: 'Revalidate an Argentine qualification',
    },
    aliases: {
      pt: [
        'diploma argentino vale no brasil',
        'revalidar diploma argentina',
        'reconhecimento automático mercosul',
        'plataforma carolina bori',
      ],
      es: [
        'título argentino vale en brasil',
        'revalidar título argentino',
        'reconocimiento automático mercosur',
        'plataforma carolina bori',
      ],
      en: [
        'is an argentine diploma valid in brazil',
        'revalidate argentine diploma',
        'automatic mercosur diploma recognition',
        'carolina bori platform',
      ],
    },
    concepts: [
      ['diploma', 'titulo', 'título', 'qualification'],
      [
        'revalidar',
        'revalidation',
        'reconhecimento',
        'reconocimiento',
        'recognition',
        'carolina bori',
        'mercosul',
        'mercosur',
      ],
    ],
    priority: 160,
    entryId: 'education-diploma-profession',
    claimIds: [
      'education-no-automatic-mercosur-diploma',
      'education-institution-controls-process',
    ],
  },
  {
    id: 'health.vaccination',
    topic: 'health',
    title: {
      pt: 'Atualizar vacinação',
      es: 'Actualizar vacunas',
      en: 'Update vaccinations',
    },
    aliases: {
      pt: [
        'atualizar vacinas',
        'carteira de vacinação argentina',
        'vacina criança brasil',
      ],
      es: [
        'actualizar vacunas',
        'libreta de vacunación argentina',
        'vacunas niño brasil',
      ],
      en: [
        'update vaccinations',
        'argentine vaccination record',
        'child vaccines brazil',
      ],
    },
    concepts: [
      ['vacina', 'vacinação', 'vacuna', 'vacunación', 'vaccine', 'vaccination'],
      ['carteira', 'libreta', 'record', 'calendario', 'calendar'],
    ],
    priority: 165,
    entryId: 'health-prevention-care-network',
    claimIds: ['health-vaccination-needs-record-review'],
  },
  {
    id: 'health.prenatal',
    topic: 'health',
    title: {
      pt: 'Pré-natal no SUS',
      es: 'Prenatal en el SUS',
      en: 'SUS prenatal care',
    },
    aliases: {
      pt: [
        'como começar pré natal',
        'grávida estrangeira sus',
        'pré natal sem cpf',
      ],
      es: [
        'cómo empezar el prenatal',
        'embarazada extranjera sus',
        'prenatal sin cpf',
      ],
      en: [
        'how to start prenatal care',
        'foreign pregnant woman sus',
        'prenatal care without cpf',
      ],
    },
    concepts: [
      ['pre natal', 'prenatal', 'gravida', 'grávida', 'embarazada', 'pregnant'],
      ['sus', 'ubs', 'saude', 'salud', 'health'],
    ],
    priority: 175,
    entryId: 'health-prevention-care-network',
    claimIds: ['health-prenatal-starts-in-primary-care'],
  },
  {
    id: 'health.mental_health',
    topic: 'health',
    title: { pt: 'Saúde mental', es: 'Salud mental', en: 'Mental healthcare' },
    aliases: {
      pt: [
        'atendimento saúde mental',
        'psicólogo no sus',
        'caps para estrangeiro',
      ],
      es: [
        'atención de salud mental',
        'psicólogo en el sus',
        'caps para extranjero',
      ],
      en: [
        'mental healthcare in brazil',
        'psychologist through sus',
        'caps for foreign national',
      ],
    },
    concepts: [
      [
        'saude mental',
        'salud mental',
        'mental health',
        'psicologo',
        'psicólogo',
        'psychologist',
        'caps',
      ],
    ],
    priority: 170,
    entryId: 'health-prevention-care-network',
    claimIds: ['health-mental-care-uses-raps'],
  },
  {
    id: 'health.private_plan',
    topic: 'health',
    title: {
      pt: 'Plano de saúde privado',
      es: 'Plan de salud privado',
      en: 'Private health plan',
    },
    aliases: {
      pt: [
        'plano de saúde vale a pena',
        'carência plano de saúde',
        'sus ou plano privado',
      ],
      es: [
        'conviene un plan de salud',
        'carencia plan de salud',
        'sus o plan privado',
      ],
      en: [
        'is private health insurance worth it',
        'health plan waiting period',
        'sus or private insurance',
      ],
    },
    concepts: [
      ['plano de saude', 'plan de salud', 'health plan', 'private insurance'],
      ['carencia', 'carência', 'waiting period', 'cobertura', 'coverage'],
    ],
    priority: 160,
    entryId: 'health-prevention-care-network',
    claimIds: ['health-private-plan-has-waiting-periods'],
  },
  {
    id: 'pets_customs.dog_cat',
    topic: 'pets_customs',
    title: {
      pt: 'Levar cão ou gato',
      es: 'Llevar perro o gato',
      en: 'Bring a dog or cat',
    },
    aliases: {
      pt: [
        'levar cachorro para o brasil',
        'viajar com gato argentina brasil',
        'documentos pet brasil',
      ],
      es: [
        'llevar perro a brasil',
        'viajar con gato argentina brasil',
        'documentos mascota brasil',
      ],
      en: [
        'bring dog to brazil',
        'travel with cat argentina brazil',
        'pet documents brazil',
      ],
    },
    concepts: [
      [
        'cachorro',
        'cao',
        'cão',
        'perro',
        'dog',
        'gato',
        'cat',
        'pet',
        'mascota',
      ],
      ['viajar', 'levar', 'llevar', 'bring', 'brasil', 'brazil'],
    ],
    priority: 170,
    entryId: 'pets-customs-border-preparation',
    claimIds: ['pets-dog-cat-needs-current-health-route'],
  },
  {
    id: 'pets_customs.other_animal',
    topic: 'pets_customs',
    title: {
      pt: 'Levar outro animal',
      es: 'Llevar otro animal',
      en: 'Bring another animal',
    },
    aliases: {
      pt: [
        'levar outro animal para o brasil',
        'viajar com ave',
        'entrar com coelho',
      ],
      es: [
        'llevar otro animal a brasil',
        'viajar con ave',
        'entrar con conejo',
      ],
      en: [
        'bring another animal to brazil',
        'travel with a bird',
        'enter with a rabbit',
      ],
    },
    concepts: [
      ['animal', 'ave', 'bird', 'coelho', 'conejo', 'rabbit'],
      ['brasil', 'brazil', 'viajar', 'travel', 'levar', 'bring'],
    ],
    priority: 150,
    partialAnswer: {
      pt: 'As regras de cães e gatos não devem ser reutilizadas para outras espécies. Informe a espécie e confirme antes da viagem a autorização sanitária aplicável com a autoridade agropecuária e a transportadora.',
      es: 'Las reglas de perros y gatos no deben reutilizarse para otras especies. Informá la especie y confirmá antes del viaje la autorización sanitaria aplicable con la autoridad agropecuaria y el transportista.',
      en: 'Dog and cat rules should not be reused for other species. Identify the species and confirm the applicable animal-health authorization with the agricultural authority and carrier before travel.',
    },
  },
  {
    id: 'pets_customs.baggage_goods',
    topic: 'pets_customs',
    title: {
      pt: 'Bagagem e bens da mudança',
      es: 'Equipaje y bienes de mudanza',
      en: 'Baggage and household goods',
    },
    aliases: {
      pt: [
        'o que declarar na fronteira',
        'levar mudança para o brasil',
        'bagagem desacompanhada',
      ],
      es: [
        'qué declarar en la frontera',
        'llevar mudanza a brasil',
        'equipaje no acompañado',
      ],
      en: [
        'what to declare at the border',
        'bring household goods to brazil',
        'unaccompanied baggage',
      ],
    },
    concepts: [
      [
        'bagagem',
        'equipaje',
        'baggage',
        'mudanca',
        'mudança',
        'mudanza',
        'household goods',
      ],
      [
        'declarar',
        'declare',
        'fronteira',
        'frontera',
        'border',
        'alfandega',
        'aduana',
        'customs',
      ],
    ],
    priority: 165,
    entryId: 'pets-customs-border-preparation',
    claimIds: ['customs-items-need-separate-classification'],
  },
  {
    id: 'pets_customs.food_vehicle',
    topic: 'pets_customs',
    title: {
      pt: 'Alimentos, plantas ou veículo',
      es: 'Alimentos, plantas o vehículo',
      en: 'Food, plants, or vehicle',
    },
    aliases: {
      pt: [
        'levar alimentos para o brasil',
        'entrar com plantas',
        'levar carro argentino para o brasil',
      ],
      es: [
        'llevar alimentos a brasil',
        'entrar con plantas',
        'llevar auto argentino a brasil',
      ],
      en: [
        'bring food to brazil',
        'enter with plants',
        'bring argentine car to brazil',
      ],
    },
    concepts: [
      [
        'alimento',
        'comida',
        'food',
        'planta',
        'plant',
        'semente',
        'semilla',
        'seed',
        'carro',
        'auto',
        'vehicle',
      ],
      ['brasil', 'brazil', 'fronteira', 'frontera', 'border'],
    ],
    priority: 155,
    entryId: 'pets-customs-border-preparation',
    claimIds: ['customs-items-need-separate-classification'],
  },
  {
    id: 'utilities.mobile_line',
    topic: 'utilities',
    title: {
      pt: 'Chip e linha brasileira',
      es: 'Chip y línea brasileña',
      en: 'Brazilian SIM and line',
    },
    aliases: {
      pt: [
        'comprar chip sem crnm',
        'ativar telefone estrangeiro',
        'linha pré paga com passaporte',
      ],
      es: [
        'comprar chip sin crnm',
        'activar teléfono extranjero',
        'línea prepaga con pasaporte',
      ],
      en: [
        'buy sim without crnm',
        'activate phone as foreign national',
        'prepaid line with passport',
      ],
    },
    concepts: [
      [
        'chip',
        'sim',
        'telefone',
        'telefono',
        'phone',
        'linha',
        'line',
        'pre pago',
        'prepago',
        'prepaid',
      ],
      [
        'estrangeiro',
        'extranjero',
        'foreign',
        'crnm',
        'passaporte',
        'pasaporte',
        'passport',
      ],
    ],
    priority: 165,
    entryId: 'utilities-activation-and-records',
    claimIds: ['utilities-prepaid-registration-needs-identification'],
  },
  {
    id: 'utilities.internet_contract',
    topic: 'utilities',
    title: {
      pt: 'Contratar internet',
      es: 'Contratar internet',
      en: 'Contract home internet',
    },
    aliases: {
      pt: [
        'contratar internet sem crnm',
        'internet residencial estrangeiro',
        'fidelidade internet',
      ],
      es: [
        'contratar internet sin crnm',
        'internet residencial extranjero',
        'permanencia internet',
      ],
      en: [
        'get internet without crnm',
        'home internet foreign national',
        'internet commitment term',
      ],
    },
    concepts: [
      ['internet', 'banda larga', 'broadband', 'wifi'],
      ['contratar', 'contract', 'fidelidade', 'permanencia', 'commitment'],
    ],
    priority: 155,
    entryId: 'utilities-activation-and-records',
    claimIds: ['utilities-telecom-contract-must-be-traceable'],
  },
  {
    id: 'utilities.electricity',
    topic: 'utilities',
    title: {
      pt: 'Ligar ou transferir energia',
      es: 'Conectar o transferir energía',
      en: 'Connect or transfer electricity',
    },
    aliases: {
      pt: [
        'ligar energia',
        'ligo a energia',
        'conectar energia',
        'ligar energia sem crnm',
        'trocar titular conta de luz',
        'dívida morador anterior energia',
      ],
      es: [
        'conectar energía sin crnm',
        'cambiar titular de luz',
        'deuda ocupante anterior energía',
      ],
      en: [
        'connect electricity without crnm',
        'change electricity account holder',
        'previous occupant electricity debt',
      ],
    },
    concepts: [
      ['energia', 'luz', 'electricidad', 'electricity'],
      [
        'ligar',
        'conectar',
        'connect',
        'titular',
        'account holder',
        'divida',
        'deuda',
        'debt',
      ],
    ],
    priority: 160,
    entryId: 'utilities-activation-and-records',
    claimIds: ['utilities-energy-first-contact-is-provider'],
  },
  {
    id: 'utilities.water_address',
    topic: 'utilities',
    title: {
      pt: 'Água e comprovante de endereço',
      es: 'Agua y comprobante de domicilio',
      en: 'Water and proof of address',
    },
    aliases: {
      pt: [
        'ligar água sem crnm',
        'o que serve como comprovante de endereço',
        'conta não está no meu nome',
      ],
      es: [
        'conectar agua sin crnm',
        'qué sirve como comprobante de domicilio',
        'la cuenta no está a mi nombre',
      ],
      en: [
        'connect water without crnm',
        'what counts as proof of address',
        'bill is not in my name',
      ],
    },
    concepts: [
      ['agua', 'água', 'water', 'saneamento', 'sanitation'],
      [
        'comprovante de endereco',
        'comprobante de domicilio',
        'proof of address',
        'titular',
      ],
    ],
    priority: 150,
    entryId: 'utilities-activation-and-records',
    claimIds: ['utilities-energy-first-contact-is-provider'],
  },
  {
    id: 'protection.immediate_danger',
    topic: 'protection',
    title: {
      pt: 'Perigo ou emergência',
      es: 'Peligro o emergencia',
      en: 'Danger or emergency',
    },
    aliases: {
      pt: [
        'estou em perigo agora',
        'emergência violência',
        'preciso de ajuda urgente',
      ],
      es: [
        'estoy en peligro ahora',
        'emergencia violencia',
        'necesito ayuda urgente',
      ],
      en: ['i am in danger now', 'violence emergency', 'need urgent help'],
    },
    concepts: [
      [
        'perigo',
        'peligro',
        'danger',
        'emergencia',
        'emergência',
        'emergency',
        'urgente',
        'urgent',
      ],
    ],
    priority: 220,
    entryId: 'protection-and-human-support',
    claimIds: ['protection-immediate-danger-comes-first'],
  },
  {
    id: 'protection.discrimination_violence',
    topic: 'protection',
    title: {
      pt: 'Violência ou discriminação',
      es: 'Violencia o discriminación',
      en: 'Violence or discrimination',
    },
    aliases: {
      pt: [
        'sofri xenofobia',
        'denunciar discriminação',
        'violência contra migrante',
      ],
      es: [
        'sufrí xenofobia',
        'denunciar discriminación',
        'violencia contra migrante',
      ],
      en: [
        'experienced xenophobia',
        'report discrimination',
        'violence against migrant',
      ],
    },
    concepts: [
      [
        'xenofobia',
        'xenophobia',
        'discriminacao',
        'discriminação',
        'discriminacion',
        'discrimination',
        'violencia',
        'violência',
        'violence',
      ],
    ],
    priority: 190,
    entryId: 'protection-and-human-support',
    claimIds: ['protection-immediate-danger-comes-first'],
  },
  {
    id: 'protection.labor_exploitation',
    topic: 'protection',
    title: {
      pt: 'Exploração no trabalho',
      es: 'Explotación laboral',
      en: 'Labor exploitation',
    },
    aliases: {
      pt: [
        'trabalho não pagou',
        'reteram meu documento no trabalho',
        'denunciar exploração trabalhista',
      ],
      es: [
        'no me pagaron el trabajo',
        'retuvieron mi documento en el trabajo',
        'denunciar explotación laboral',
      ],
      en: [
        'work did not pay me',
        'employer kept my document',
        'report labor exploitation',
      ],
    },
    concepts: [
      [
        'exploracao',
        'exploração',
        'explotacion',
        'exploitation',
        'nao pagou',
        'no pagaron',
        'not paid',
        'reteve documento',
        'retuvieron documento',
        'kept document',
      ],
      ['trabalho', 'trabajo', 'work', 'empregador', 'empleador', 'employer'],
    ],
    priority: 205,
    entryId: 'protection-and-human-support',
    claimIds: ['protection-labor-abuse-has-official-reporting'],
  },
  {
    id: 'protection.legal_social_aid',
    topic: 'protection',
    title: {
      pt: 'Ajuda jurídica ou social',
      es: 'Ayuda jurídica o social',
      en: 'Legal or social support',
    },
    aliases: {
      pt: [
        'assistência jurídica gratuita migrante',
        'onde pedir ajuda social',
        'abrigo para migrante',
      ],
      es: [
        'asistencia jurídica gratuita migrante',
        'dónde pedir ayuda social',
        'refugio para migrante',
      ],
      en: [
        'free legal aid for migrant',
        'where to get social support',
        'shelter for migrant',
      ],
    },
    concepts: [
      [
        'assistencia',
        'assistência',
        'asistencia',
        'assistance',
        'ajuda',
        'ayuda',
        'help',
        'abrigo',
        'refugio',
        'shelter',
      ],
      ['juridica', 'jurídica', 'legal', 'social', 'migrante', 'migrant'],
    ],
    priority: 175,
    entryId: 'protection-and-human-support',
    claimIds: ['protection-support-is-local-and-specialized'],
  },
  {
    id: 'consumer.general_complaint',
    topic: 'consumer',
    title: {
      pt: 'Fazer uma reclamação',
      es: 'Hacer un reclamo',
      en: 'File a consumer complaint',
    },
    aliases: {
      pt: [
        'como reclamar de uma empresa',
        'usar consumidor gov',
        'empresa não resolveu',
      ],
      es: [
        'cómo reclamar contra una empresa',
        'usar consumidor gov',
        'la empresa no resolvió',
      ],
      en: [
        'how to complain about a company',
        'use consumidor gov',
        'company did not resolve issue',
      ],
    },
    concepts: [
      ['reclamar', 'reclamo', 'complaint', 'consumidor gov', 'procon'],
      ['empresa', 'company', 'fornecedor', 'proveedor', 'provider'],
    ],
    priority: 165,
    entryId: 'consumer-complaint-escalation',
    claimIds: ['consumer-complaint-needs-protocol-and-evidence'],
  },
  {
    id: 'consumer.telecom_complaint',
    topic: 'consumer',
    title: {
      pt: 'Reclamar de telefone ou internet',
      es: 'Reclamar de teléfono o internet',
      en: 'Complain about phone or internet',
    },
    aliases: {
      pt: [
        'reclamar operadora telefone',
        'internet não resolveu protocolo',
        'denunciar operadora anatel',
      ],
      es: [
        'reclamar operadora teléfono',
        'internet no resolvió protocolo',
        'denunciar operadora anatel',
      ],
      en: [
        'complain about phone provider',
        'internet provider unresolved protocol',
        'report carrier to anatel',
      ],
    },
    concepts: [
      [
        'operadora',
        'carrier',
        'telefone',
        'telefono',
        'phone',
        'internet',
        'anatel',
      ],
      ['reclamar', 'reclamo', 'complaint', 'protocolo', 'protocol'],
    ],
    priority: 170,
    entryId: 'consumer-complaint-escalation',
    claimIds: ['consumer-telecom-has-sector-escalation'],
  },
  {
    id: 'consumer.energy_complaint',
    topic: 'consumer',
    title: {
      pt: 'Reclamar da energia',
      es: 'Reclamar por energía',
      en: 'Complain about electricity',
    },
    aliases: {
      pt: [
        'reclamar distribuidora energia',
        'problema conta de luz aneel',
        'ouvidoria energia protocolo',
      ],
      es: [
        'reclamar distribuidora energía',
        'problema factura de luz aneel',
        'defensoría energía protocolo',
      ],
      en: [
        'complain about electricity distributor',
        'electricity bill issue aneel',
        'energy ombudsman protocol',
      ],
    },
    concepts: [
      [
        'energia',
        'electricidad',
        'electricity',
        'luz',
        'aneel',
        'distribuidora',
        'distributor',
      ],
      [
        'reclamar',
        'reclamo',
        'complaint',
        'ouvidoria',
        'ombudsman',
        'protocolo',
        'protocol',
      ],
    ],
    priority: 170,
    entryId: 'consumer-complaint-escalation',
    claimIds: ['consumer-energy-has-sector-escalation'],
  },
  {
    id: 'consumer.fraud_first_response',
    topic: 'consumer',
    title: {
      pt: 'Suspeita de fraude',
      es: 'Sospecha de fraude',
      en: 'Suspected fraud',
    },
    aliases: {
      pt: [
        'caí em golpe pix',
        'fraude cartão o que fazer',
        'conta invadida reclamar',
      ],
      es: [
        'caí en estafa pix',
        'fraude tarjeta qué hacer',
        'cuenta hackeada reclamar',
      ],
      en: [
        'pix scam what to do',
        'card fraud what to do',
        'account hacked complaint',
      ],
    },
    concepts: [
      [
        'fraude',
        'fraud',
        'golpe',
        'estafa',
        'scam',
        'invadida',
        'hackeada',
        'hacked',
      ],
      ['pix', 'cartao', 'tarjeta', 'card', 'conta', 'cuenta', 'account'],
    ],
    priority: 210,
    entryId: 'consumer-complaint-escalation',
  },
  {
    id: 'long_term.social_security',
    topic: 'long_term',
    title: {
      pt: 'Previdência Brasil–Argentina',
      es: 'Previsión Brasil–Argentina',
      en: 'Brazil–Argentina social security',
    },
    aliases: {
      pt: [
        'somar contribuição argentina brasil',
        'somo contribuições da argentina e brasil',
        'contribuições argentina brasil',
        'acordo previdenciário brasil argentina',
        'aposentadoria nos dois países',
      ],
      es: [
        'sumar aportes argentina brasil',
        'acuerdo previsional brasil argentina',
        'jubilación en ambos países',
      ],
      en: [
        'combine argentina brazil contributions',
        'brazil argentina social security agreement',
        'brazil argentina pension agreement',
        'retirement in both countries',
      ],
    },
    concepts: [
      [
        'previdencia',
        'previdência',
        'prevision',
        'previsión',
        'social security',
        'pension agreement',
        'previdenciario',
        'previsional',
        'inss',
        'anses',
      ],
      [
        'contribuicao',
        'contribución',
        'contribution',
        'aposentadoria',
        'jubilacion',
        'retirement',
      ],
    ],
    priority: 170,
    entryId: 'long-term-pension-naturalization',
    claimIds: ['long-term-contributions-need-country-records'],
  },
  {
    id: 'long_term.naturalization',
    topic: 'long_term',
    title: {
      pt: 'Naturalização brasileira',
      es: 'Naturalización brasileña',
      en: 'Brazilian naturalization',
    },
    aliases: {
      pt: [
        'quando posso pedir naturalização',
        'virar cidadão brasileiro',
        'naturalização de filho',
      ],
      es: [
        'cuándo puedo pedir naturalización',
        'ser ciudadano brasileño',
        'naturalización de hijo',
      ],
      en: [
        'when can i apply for naturalization',
        'become a brazilian citizen',
        'child naturalization',
      ],
    },
    concepts: [
      [
        'naturalizacao',
        'naturalização',
        'naturalizacion',
        'naturalization',
        'cidadania',
        'ciudadania',
        'citizenship',
      ],
      ['brasileiro', 'brasileno', 'brazilian', 'filho', 'hijo', 'child'],
    ],
    negativeAliases: [
      'matricular meu filho',
      'inscribo a mi hijo',
      'enroll my child',
      'escola',
      'escuela',
      'school',
    ],
    priority: 175,
    entryId: 'long-term-pension-naturalization',
    claimIds: ['long-term-naturalization-is-separate'],
  },
  {
    id: 'costs.monthly_budget',
    topic: 'costs',
    title: { pt: 'Custo mensal', es: 'Costo mensual', en: 'Monthly cost' },
    aliases: {
      pt: [
        'quanto custa morar',
        'custo mensal',
        'custo de vida',
        'orçamento mensal',
      ],
      es: [
        'cuánto cuesta vivir',
        'costo mensual',
        'costo de vida',
        'presupuesto mensual',
      ],
      en: ['cost to live', 'monthly cost', 'cost of living', 'monthly budget'],
    },
    concepts: [
      ['custo', 'costo', 'cost', 'orcamento', 'presupuesto', 'budget'],
    ],
    priority: 100,
    partialAnswer: helpTopicsAnswer,
  },
  {
    id: 'flights.search',
    topic: 'flights',
    title: { pt: 'Buscar voos', es: 'Buscar vuelos', en: 'Search flights' },
    aliases: {
      pt: ['buscar voo', 'passagem aérea', 'comparar voos'],
      es: ['buscar vuelo', 'pasaje aéreo', 'comparar vuelos'],
      en: ['search flights', 'air ticket', 'compare flights'],
    },
    concepts: [['voo', 'vuelo', 'flight', 'passagem', 'pasaje', 'ticket']],
    priority: 100,
    partialAnswer: {
      pt: 'A Central pode explicar documentos de viagem, aeroportos e fatores de preço, mas não faz uma cotação dentro desta resposta. Informe a dúvida específica sobre a viagem para receber uma orientação revisada aqui.',
      es: 'La Central puede explicar documentos de viaje, aeropuertos y factores de precio, pero no realiza una cotización dentro de esta respuesta. Indicá la duda específica del viaje para recibir orientación revisada acá.',
      en: 'Help can explain travel documents, airports, and price factors, but it does not quote flights within this answer. State the specific travel question to receive reviewed guidance here.',
    },
  },
];
