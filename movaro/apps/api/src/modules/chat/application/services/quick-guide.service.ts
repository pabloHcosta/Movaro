import { createHash } from 'node:crypto';

import { Injectable } from '@nestjs/common';

import { QuickHelpIntentDefinition } from '../../data/quick-help-intents.catalog';
import {
  QUICK_HELP_ENTRIES,
  QuickHelpCoverageStatus,
  QuickHelpEntryDefinition,
  QuickHelpLocale,
  QuickHelpRiskLevel,
  QuickHelpTopic,
} from '../../data/quick-help-trust.catalog';
import { ResolveQuickGuideDto } from '../../presentation/dto/resolve-quick-guide.dto';
import {
  QuickHelpIntentMatch,
  QuickHelpQueryPlan,
  QuickHelpQueryPlannerService,
} from './quick-help-query-planner.service';

export interface ResolvedSection {
  intentId: string;
  topic: QuickHelpTopic;
  title: string;
  answer: string;
  coverage: 'conditional' | 'partial';
  claimIds: string[];
}

type RecoveryReason =
  | 'unmatched_query'
  | 'unsupported_corridor'
  | 'partial_coverage'
  | 'stale_evidence';

interface RecoverySuggestionDefinition {
  id: string;
  topic: QuickHelpTopic;
  question: Record<QuickHelpLocale, string>;
}

const RECOVERY_SUGGESTIONS: RecoverySuggestionDefinition[] = [
  {
    id: 'documents-cpf',
    topic: 'documents',
    question: {
      pt: 'Como faço o CPF e o que ele não substitui?',
      es: '¿Cómo tramito el CPF y qué no reemplaza?',
      en: 'How do I get a CPF and what does it not replace?',
    },
  },
  {
    id: 'documents-residence',
    topic: 'documents',
    question: {
      pt: 'Quais documentos preciso para residência?',
      es: '¿Qué documentos necesito para la residencia?',
      en: 'Which documents do I need for residence?',
    },
  },
  {
    id: 'education-school',
    topic: 'education',
    question: {
      pt: 'Como matriculo meu filho na escola pública?',
      es: '¿Cómo inscribo a mi hijo en la escuela pública?',
      en: 'How do I enroll my child in public school?',
    },
  },
  {
    id: 'housing-guarantee',
    topic: 'housing',
    question: {
      pt: 'Quais garantias podem pedir no aluguel?',
      es: '¿Qué garantías pueden pedir para alquilar?',
      en: 'Which guarantees can a landlord request?',
    },
  },
  {
    id: 'work-formal',
    topic: 'work',
    question: {
      pt: 'O que preciso para trabalhar formalmente?',
      es: '¿Qué necesito para trabajar formalmente?',
      en: 'What do I need for formal employment?',
    },
  },
  {
    id: 'health-sus',
    topic: 'health',
    question: {
      pt: 'Como uma pessoa estrangeira acessa o SUS?',
      es: '¿Cómo accede una persona extranjera al SUS?',
      en: 'How can a foreign national access SUS?',
    },
  },
  {
    id: 'finance-bank-account',
    topic: 'finance',
    question: {
      pt: 'Consigo abrir conta sem a CRNM física?',
      es: '¿Puedo abrir una cuenta sin la CRNM física?',
      en: 'Can I open an account without the physical CRNM?',
    },
  },
  {
    id: 'tax-foreign-income',
    topic: 'tax',
    question: {
      pt: 'Como organizo renda da Argentina ao morar no Brasil?',
      es: '¿Cómo organizo ingresos de Argentina al vivir en Brasil?',
      en: 'How do I organize Argentine income while living in Brazil?',
    },
  },
  {
    id: 'family-reunification',
    topic: 'family',
    question: {
      pt: 'Quem pode pedir residência por reunião familiar?',
      es: '¿Quién puede pedir residencia por reunificación familiar?',
      en: 'Who can apply for residence through family reunification?',
    },
  },
  {
    id: 'health-controlled-medicine',
    topic: 'health',
    question: {
      pt: 'Como levo medicamento controlado para o Brasil?',
      es: '¿Cómo llevo medicamento controlado a Brasil?',
      en: 'How do I bring controlled medicine to Brazil?',
    },
  },
  {
    id: 'education-diploma',
    topic: 'education',
    question: {
      pt: 'Meu diploma argentino vale no Brasil?',
      es: '¿Mi título argentino vale en Brasil?',
      en: 'Is my Argentine qualification valid in Brazil?',
    },
  },
  {
    id: 'health-vaccination',
    topic: 'health',
    question: {
      pt: 'Como atualizo minha vacinação no Brasil?',
      es: '¿Cómo actualizo mis vacunas en Brasil?',
      en: 'How do I update my vaccinations in Brazil?',
    },
  },
  {
    id: 'pets-entry',
    topic: 'pets_customs',
    question: {
      pt: 'Como levo meu cão ou gato para o Brasil?',
      es: '¿Cómo llevo mi perro o gato a Brasil?',
      en: 'How do I bring my dog or cat to Brazil?',
    },
  },
  {
    id: 'utilities-phone',
    topic: 'utilities',
    question: {
      pt: 'Como ativo um chip brasileiro sem CRNM?',
      es: '¿Cómo activo un chip brasileño sin CRNM?',
      en: 'How do I activate a Brazilian SIM without CRNM?',
    },
  },
  {
    id: 'protection-rights',
    topic: 'protection',
    question: {
      pt: 'Onde peço ajuda se sofrer xenofobia?',
      es: '¿Dónde pido ayuda si sufro xenofobia?',
      en: 'Where can I get help if I experience xenophobia?',
    },
  },
  {
    id: 'consumer-complaint',
    topic: 'consumer',
    question: {
      pt: 'Como faço uma reclamação contra uma empresa?',
      es: '¿Cómo hago un reclamo contra una empresa?',
      en: 'How do I file a complaint against a company?',
    },
  },
  {
    id: 'long-term-pension',
    topic: 'long_term',
    question: {
      pt: 'Como funcionam contribuições no Brasil e na Argentina?',
      es: '¿Cómo funcionan los aportes en Brasil y Argentina?',
      en: 'How do contributions in Brazil and Argentina work?',
    },
  },
];

@Injectable()
export class QuickGuideService {
  constructor(private readonly queryPlanner: QuickHelpQueryPlannerService) {}

  resolve(dto: ResolveQuickGuideDto) {
    const locale = this.normalizeLocale(dto.locale);
    if (dto.destinationCountry.trim().toLowerCase() !== 'brasil') {
      return this.buildNotCovered(
        dto,
        locale,
        undefined,
        'unsupported_corridor',
      );
    }
    const plan = this.queryPlanner.plan(dto.message, locale, dto.answers);
    if (plan.matches.length === 0)
      return this.buildNotCovered(dto, locale, plan);
    return this.buildPlannedResolution(dto, locale, plan);
  }

  private buildPlannedResolution(
    dto: ResolveQuickGuideDto,
    locale: QuickHelpLocale,
    plan: QuickHelpQueryPlan,
  ) {
    const sections = plan.matches.map((match) =>
      this.resolveSection(match, locale),
    );
    const supported = plan.matches
      .map((match) => ({ match, entry: this.entryFor(match.intent) }))
      .filter(
        (
          item,
        ): item is {
          match: QuickHelpIntentMatch;
          entry: QuickHelpEntryDefinition;
        } => item.entry !== undefined && !item.match.intent.partialAnswer,
      );
    const selectedClaims = supported.flatMap(({ match, entry }) => {
      const allowed = match.intent.claimIds
        ? new Set(match.intent.claimIds)
        : null;
      return entry.claims.filter((claim) => !allowed || allowed.has(claim.id));
    });
    const requiredEvidenceIds = new Set(
      selectedClaims.flatMap((claim) => claim.evidenceIds),
    );
    const evidenceDefinitions = this.uniqueBy(
      supported
        .flatMap(({ entry }) => entry.evidence)
        .filter((evidence) => requiredEvidenceIds.has(evidence.id)),
      (evidence) => evidence.id,
    );
    const claimsHaveEvidence = selectedClaims.every(
      (claim) =>
        claim.evidenceIds.length > 0 &&
        claim.evidenceIds.every((id) =>
          evidenceDefinitions.some((evidence) => evidence.id === id),
        ),
    );
    const editorialCurrent = supported.every(({ entry }) =>
      this.isCurrent(entry.expiresAt),
    );
    const evidenceCurrent = evidenceDefinitions.every((evidence) =>
      this.isCurrent(evidence.validUntil),
    );
    const isCurrent = editorialCurrent && evidenceCurrent;
    const hasPartialSection = sections.some(
      (section) => section.coverage === 'partial',
    );
    const status: QuickHelpCoverageStatus =
      !claimsHaveEvidence || !isCurrent || hasPartialSection
        ? 'partial'
        : plan.clarification
          ? 'needs_context'
          : 'conditional';
    const claims = selectedClaims.map((claim) => ({
      id: claim.id,
      text: claim.text[locale],
      evidenceIds: claim.evidenceIds,
      status: status === 'partial' ? ('conditional' as const) : claim.status,
    }));
    const evidence = evidenceDefinitions.map((item) => ({
      id: item.id,
      title: item.title[locale],
      publisher: item.publisher,
      url: item.url,
      checkedAt: item.checkedAt,
      validUntil: item.validUntil,
      jurisdiction: item.jurisdiction,
      scope: item.scope[locale],
    }));
    const directAnswer =
      sections.length === 1
        ? sections[0].answer
        : {
            pt: `Separei sua dúvida em ${sections.length} partes para não misturar regras e próximos passos.`,
            es: `Separé tu duda en ${sections.length} partes para no mezclar reglas y próximos pasos.`,
            en: `I split your question into ${sections.length} parts so rules and next steps stay clear.`,
          }[locale];
    const reviewedAt = this.earliestDate(
      supported.map(({ entry }) => entry.reviewedAt),
    );
    const expiresAt = this.earliestDate([
      ...supported.map(({ entry }) => entry.expiresAt),
      ...evidenceDefinitions.map((item) => item.validUntil),
    ]);
    const contentVersions = this.unique(
      supported.map(({ entry }) => entry.contentVersion),
    );
    const reason = this.coverageReason(status, locale);
    const practicalGuidance = this.practicalGuidance(plan.matches, locale);
    const evidenceCoverage =
      selectedClaims.length + (hasPartialSection ? 1 : 0) === 0
        ? 0
        : selectedClaims.length /
          (selectedClaims.length +
            sections.filter((section) => section.coverage === 'partial')
              .length);

    return {
      resolutionId: this.resolutionId(
        dto.message,
        `${contentVersions.join('+')}:${JSON.stringify(dto.answers ?? {})}`,
      ),
      entryId:
        supported.length === 1 && sections.length === 1
          ? supported[0].entry.id
          : `quick-help-multi-${plan.matches.map((match) => match.intent.id).join('+')}`,
      topic: sections.length === 1 ? sections[0].topic : 'general',
      question: dto.message.trim(),
      answer: directAnswer,
      directAnswer,
      answerMode: plan.decisionBranch
        ? 'decision_tree'
        : sections.length > 1
          ? 'multi_part'
          : (supported[0]?.entry.answerMode ?? 'direct'),
      riskLevel: this.highestRisk(
        supported.map(({ entry }) => entry.riskLevel),
      ),
      jurisdiction:
        this.unique(supported.map(({ entry }) => entry.jurisdiction)).join(
          ', ',
        ) || null,
      coverage: status,
      coverageReason: reason,
      reviewedAt,
      expiresAt,
      editorialOwner:
        this.unique(supported.map(({ entry }) => entry.editorialOwner)).join(
          ', ',
        ) || null,
      contentVersion: contentVersions.join('+') || null,
      context: {
        originCountry: dto.originCountry,
        destinationCountry: dto.destinationCountry,
        cityId: dto.highlightedCityId ?? null,
      },
      contextMissing: plan.clarification ? [plan.clarification.contextKey] : [],
      resolvedIntents: plan.matches.map((match) => match.intent.id),
      sections,
      claims,
      steps: plan.decisionBranch
        ? plan.decisionBranch.steps.map((step, index) => ({
            id: `${plan.decisionBranch!.value}-${index + 1}`,
            label: step[locale],
          }))
        : [],
      nextSteps: practicalGuidance.nextSteps,
      fallbackPath: practicalGuidance.fallbackPath,
      decisionTitle: plan.decisionBranch?.title[locale] ?? null,
      followUpQuestion: plan.clarification
        ? {
            id: plan.clarification.id,
            contextKey: plan.clarification.contextKey,
            prompt: plan.clarification.prompt[locale],
            options: plan.clarification.options.map((option) => ({
              value: option.value,
              label: option.label[locale],
            })),
          }
        : null,
      // Help shares reviewed knowledge with the journey, never navigation or
      // progress state. The complete resolution stays on this surface.
      actions: [],
      caveats: this.unique(
        supported
          .map(({ entry }) => entry.caveat?.[locale])
          .filter((value): value is string => Boolean(value)),
      ),
      evidence,
      sources: evidence,
      trust: {
        status,
        reason,
        evidenceCoverage,
        freshness:
          evidence.length === 0
            ? ('not_available' as const)
            : isCurrent
              ? ('current' as const)
              : ('expired' as const),
      },
      retrieval: {
        strategy: plan.strategy,
        compound: plan.compound,
        matches: plan.matches.map((match) => ({
          intentId: match.intent.id,
          score: Number(match.score.toFixed(3)),
          lexicalScore: Number(match.lexicalScore.toFixed(3)),
          conceptScore: Number(match.conceptScore.toFixed(3)),
        })),
      },
      recovery:
        status === 'partial'
          ? this.buildRecovery(
              locale,
              !isCurrent ? 'stale_evidence' : 'partial_coverage',
              sections.map((section) => section.topic),
            )
          : null,
    };
  }

  private resolveSection(
    match: QuickHelpIntentMatch,
    locale: QuickHelpLocale,
  ): ResolvedSection {
    if (match.intent.partialAnswer) {
      return {
        intentId: match.intent.id,
        topic: match.intent.topic,
        title: match.intent.title[locale],
        answer: match.intent.partialAnswer[locale],
        coverage: 'partial',
        claimIds: [],
      };
    }
    const entry = this.entryFor(match.intent);
    if (!entry) {
      return {
        intentId: match.intent.id,
        topic: match.intent.topic,
        title: match.intent.title[locale],
        answer:
          match.intent.partialAnswer?.[locale] ?? this.notCoveredAnswer(locale),
        coverage: 'partial',
        claimIds: [],
      };
    }
    const allowed = match.intent.claimIds
      ? new Set(match.intent.claimIds)
      : null;
    const claims = entry.claims.filter(
      (claim) => !allowed || allowed.has(claim.id),
    );
    return {
      intentId: match.intent.id,
      topic: match.intent.topic,
      title: match.intent.title[locale],
      answer: claims.map((claim) => claim.text[locale]).join(' '),
      coverage: 'conditional',
      claimIds: claims.map((claim) => claim.id),
    };
  }

  private buildNotCovered(
    dto: ResolveQuickGuideDto,
    locale: QuickHelpLocale,
    plan?: QuickHelpQueryPlan,
    recoveryReason: RecoveryReason = 'unmatched_query',
  ) {
    const status: QuickHelpCoverageStatus = 'not_covered';
    const answer = this.notCoveredAnswer(locale);
    const reason = this.coverageReason(status, locale);
    return {
      resolutionId: this.resolutionId(dto.message, 'unverified'),
      entryId: 'quick-help-general-unverified',
      topic: 'general',
      question: dto.message.trim(),
      answer,
      directAnswer: answer,
      answerMode: 'direct',
      riskLevel: 'low',
      jurisdiction: null,
      coverage: status,
      coverageReason: reason,
      reviewedAt: null,
      expiresAt: null,
      editorialOwner: null,
      contentVersion: null,
      context: {
        originCountry: dto.originCountry,
        destinationCountry: dto.destinationCountry,
        cityId: dto.highlightedCityId ?? null,
      },
      contextMissing: [],
      resolvedIntents: [],
      sections: [],
      claims: [],
      steps: [],
      nextSteps: [],
      fallbackPath: [],
      decisionTitle: null,
      followUpQuestion: null,
      actions: [],
      caveats: [reason],
      evidence: [],
      sources: [],
      trust: {
        status,
        reason,
        evidenceCoverage: 0,
        freshness: 'not_available' as const,
      },
      retrieval: {
        strategy: plan?.strategy ?? 'hybrid_lexical_concept',
        compound: false,
        matches: [],
      },
      recovery: this.buildRecovery(locale, recoveryReason),
    };
  }

  private buildRecovery(
    locale: QuickHelpLocale,
    reason: RecoveryReason,
    preferredTopics: QuickHelpTopic[] = [],
  ) {
    if (reason === 'unsupported_corridor') {
      return {
        reason,
        message: {
          pt: 'A base revisada desta versão cobre mudança para o Brasil. Não adapte esta resposta a outro destino.',
          es: 'La base revisada de esta versión cubre mudanzas a Brasil. No adaptes esta respuesta a otro destino.',
          en: 'The reviewed knowledge in this version covers moves to Brazil. Do not adapt this answer to another destination.',
        }[locale],
        suggestions: [],
      };
    }
    const preferred = new Set(preferredTopics);
    const ranked = [...RECOVERY_SUGGESTIONS].sort(
      (a, b) => Number(preferred.has(b.topic)) - Number(preferred.has(a.topic)),
    );
    return {
      reason,
      message: {
        unmatched_query: {
          pt: 'Tente uma destas perguntas revisadas ou volte e descreva um único problema por vez.',
          es: 'Probá una de estas preguntas revisadas o volvé y describí un solo problema por vez.',
          en: 'Try one of these reviewed questions or go back and describe one problem at a time.',
        }[locale],
        partial_coverage: {
          pt: 'Ainda não confirmamos todos os detalhes deste caso. Estas perguntas próximas já têm cobertura revisada.',
          es: 'Todavía no confirmamos todos los detalles de este caso. Estas preguntas cercanas ya tienen cobertura revisada.',
          en: 'We have not confirmed every detail of this case. These related questions already have reviewed coverage.',
        }[locale],
        stale_evidence: {
          pt: 'A vigência desta resposta precisa ser renovada. Use uma pergunta revisada ou confirme diretamente na fonte oficial.',
          es: 'La vigencia de esta respuesta debe renovarse. Usá una pregunta revisada o confirmá directamente en la fuente oficial.',
          en: 'This answer needs a freshness review. Use a reviewed question or confirm directly with the official source.',
        }[locale],
        unsupported_corridor: '',
      }[reason],
      suggestions: ranked.slice(0, 3).map((item) => ({
        id: item.id,
        topic: item.topic,
        question: item.question[locale],
      })),
    };
  }

  private practicalGuidance(
    matches: QuickHelpIntentMatch[],
    locale: QuickHelpLocale,
  ) {
    const nextByTopic: Partial<
      Record<QuickHelpTopic, Record<QuickHelpLocale, string[]>>
    > = {
      documents: {
        pt: [
          'Abra a fonte oficial correspondente ao documento.',
          'Confirme o fundamento antes de reunir ou traduzir documentos.',
        ],
        es: [
          'Abrí la fuente oficial correspondiente al documento.',
          'Confirmá el fundamento antes de reunir o traducir documentos.',
        ],
        en: [
          'Open the official source for the document.',
          'Confirm the basis before collecting or translating documents.',
        ],
      },
      education: {
        pt: [
          'Identifique a rede responsável pelo endereço.',
          'Peça à rede local a lista atual de documentos e o calendário.',
        ],
        es: [
          'Identificá la red responsable del domicilio.',
          'Pedí a la red local la lista actual de documentos y el calendario.',
        ],
        en: [
          'Identify the network responsible for the address.',
          'Ask the local network for its current document list and calendar.',
        ],
      },
      housing: {
        pt: [
          'Confirme por escrito qual garantia será usada.',
          'Verifique imóvel, contrato e identidade antes de pagar.',
        ],
        es: [
          'Confirmá por escrito qué garantía se utilizará.',
          'Verificá inmueble, contrato e identidad antes de pagar.',
        ],
        en: [
          'Confirm in writing which guarantee will be used.',
          'Verify the property, contract, and identity before paying.',
        ],
      },
      work: {
        pt: [
          'Confirme sua situação para trabalho formal.',
          'Use o serviço oficial da Carteira de Trabalho Digital.',
        ],
        es: [
          'Confirmá tu situación para trabajo formal.',
          'Usá el servicio oficial de la Libreta de Trabajo Digital.',
        ],
        en: [
          'Confirm your status for formal work.',
          'Use the official Digital Work Card service.',
        ],
      },
      health: {
        pt: [
          'Localize a UBS ou serviço adequado da sua região.',
          'Confirme diretamente na unidade como será feito o cadastro local.',
        ],
        es: [
          'Ubicá la UBS o el servicio adecuado de tu zona.',
          'Confirmá directamente en la unidad cómo se realiza el registro local.',
        ],
        en: [
          'Locate the appropriate UBS or service in your area.',
          'Confirm the local registration process directly with the unit.',
        ],
      },
      driving: {
        pt: [
          'Confira primeiro a regra nacional da Senatran.',
          'Confirme o procedimento no Detran do estado onde você mora.',
        ],
        es: [
          'Revisá primero la regla nacional de Senatran.',
          'Confirmá el trámite en el Detran del estado donde vivís.',
        ],
        en: [
          'Check the national Senatran rule first.',
          'Confirm the procedure with the Detran in your state.',
        ],
      },
      costs: {
        pt: ['Informe cidade e composição familiar para obter uma faixa útil.'],
        es: [
          'Indicá ciudad y composición familiar para obtener un rango útil.',
        ],
        en: ['Provide city and household composition for a useful range.'],
      },
      flights: {
        pt: ['Abra a busca e compare datas e aeroportos próximos.'],
        es: ['Abrí la búsqueda y compará fechas y aeropuertos cercanos.'],
        en: ['Open search and compare dates and nearby airports.'],
      },
      finance: {
        pt: [
          'Identifique primeiro o bloqueio: documento, endereço, telefone, conta ou validação gov.br.',
          'Peça a lista de documentos e o motivo de eventual recusa por um canal oficial da instituição.',
        ],
        es: [
          'Identificá primero el bloqueo: documento, domicilio, teléfono, cuenta o validación gov.br.',
          'Pedí la lista de documentos y el motivo de un eventual rechazo por un canal oficial de la institución.',
        ],
        en: [
          'Identify the blocker first: document, address, phone, account, or gov.br validation.',
          'Request the document list and any refusal reason through an official institution channel.',
        ],
      },
      tax: {
        pt: [
          'Registre datas de entrada, tipo de residência e início de vínculos no Brasil.',
          'Separe renda, bens, empresas e impostos pagos por país antes de procurar um contador.',
        ],
        es: [
          'Registrá fechas de ingreso, tipo de residencia e inicio de vínculos en Brasil.',
          'Separá ingresos, bienes, empresas e impuestos pagados por país antes de buscar un contador.',
        ],
        en: [
          'Record entry dates, residence type, and the start of Brazilian links.',
          'Separate income, assets, companies, and tax paid by country before consulting an accountant.',
        ],
      },
      family: {
        pt: [
          'Liste cada familiar, vínculo, nacionalidade, idade e fundamento possível.',
          'Separe autorização de viagem, guarda e residência antes de preparar documentos de menores.',
        ],
        es: [
          'Listá cada familiar, vínculo, nacionalidad, edad y posible fundamento.',
          'Separá autorización de viaje, guarda y residencia antes de preparar documentos de menores.',
        ],
        en: [
          'List each family member, relationship, nationality, age, and possible basis.',
          'Separate travel authorization, custody, and residence before preparing a minor’s documents.',
        ],
      },
      pets_customs: {
        pt: [
          'Separe cada item por categoria: animal, alimento, medicamento, bagagem, mudança ou veículo.',
          'Confira a regra vigente e a transportadora antes de emitir a viagem.',
        ],
        es: [
          'Separá cada ítem por categoría: animal, alimento, medicamento, equipaje, mudanza o vehículo.',
          'Revisá la regla vigente y el transportista antes de emitir el viaje.',
        ],
        en: [
          'Separate each item by category: animal, food, medicine, baggage, household move, or vehicle.',
          'Check the current rule and carrier before booking travel.',
        ],
      },
      utilities: {
        pt: [
          'Peça a lista de documentos diretamente à prestadora da sua área.',
          'Guarde oferta, contrato e protocolo de cada ativação ou recusa.',
        ],
        es: [
          'Pedí la lista de documentos directamente a la prestadora de tu zona.',
          'Guardá oferta, contrato y protocolo de cada activación o rechazo.',
        ],
        en: [
          'Request the document list directly from the provider in your area.',
          'Keep the offer, contract, and protocol for each activation or refusal.',
        ],
      },
      protection: {
        pt: [
          'Se houver perigo agora, procure primeiro o serviço de emergência adequado.',
          'Preserve provas apenas quando isso não aumentar o risco e use o canal específico para a situação.',
        ],
        es: [
          'Si hay peligro ahora, buscá primero el servicio de emergencia adecuado.',
          'Conservá pruebas sólo si eso no aumenta el riesgo y usá el canal específico para la situación.',
        ],
        en: [
          'If there is danger now, contact the appropriate emergency service first.',
          'Preserve evidence only when doing so does not increase risk, and use the channel for the specific situation.',
        ],
      },
      consumer: {
        pt: [
          'Reúna oferta, contrato, comprovantes, capturas e protocolos em ordem de data.',
          'Registre primeiro com a empresa e depois use o canal público ou regulador correspondente.',
        ],
        es: [
          'Reuní oferta, contrato, comprobantes, capturas y protocolos en orden de fecha.',
          'Registrá primero con la empresa y luego usá el canal público o regulador correspondiente.',
        ],
        en: [
          'Gather the offer, contract, receipts, screenshots, and protocols in date order.',
          'Register with the company first, then use the relevant public platform or regulator.',
        ],
      },
      long_term: {
        pt: [
          'Separe períodos, números de inscrição e comprovantes de contribuição de cada país.',
          'Para naturalização, identifique a modalidade antes de contar prazo ou reunir documentos.',
        ],
        es: [
          'Separá períodos, números de inscripción y comprobantes de aportes de cada país.',
          'Para naturalización, identificá la modalidad antes de contar plazos o reunir documentos.',
        ],
        en: [
          'Separate contribution periods, registration numbers, and records for each country.',
          'For naturalization, identify the type before counting time or collecting documents.',
        ],
      },
    };
    const fallbackByTopic: Partial<
      Record<QuickHelpTopic, Record<QuickHelpLocale, string[]>>
    > = {
      documents: {
        pt: [
          'Se o serviço não corresponder ao seu caso, não use uma lista genérica: confirme o fundamento no canal oficial da Polícia Federal.',
        ],
        es: [
          'Si el servicio no corresponde a tu caso, no uses una lista genérica: confirmá el fundamento en el canal oficial de la Policía Federal.',
        ],
        en: [
          'If the service does not match your case, do not use a generic list: confirm the basis through the official Federal Police channel.',
        ],
      },
      education: {
        pt: [
          'Se houver bloqueio, peça a exigência e a orientação da rede de ensino por escrito.',
        ],
        es: [
          'Si hay un bloqueo, pedí por escrito el requisito y la orientación de la red educativa.',
        ],
        en: [
          'If blocked, ask the education network for the requirement and guidance in writing.',
        ],
      },
      housing: {
        pt: [
          'Se houver cobrança ou recusa duvidosa, não faça novos pagamentos; preserve contrato, anúncio e comprovantes e procure orientação formal.',
        ],
        es: [
          'Si hay un cobro o rechazo dudoso, no hagas nuevos pagos; guardá contrato, anuncio y comprobantes y buscá orientación formal.',
        ],
        en: [
          'If a charge or refusal seems questionable, make no further payments; preserve the contract, listing, and receipts and seek formal guidance.',
        ],
      },
      work: {
        pt: [
          'Se cobrarem inscrição, curso ou taxa para contratar, interrompa o processo e verifique a oferta.',
        ],
        es: [
          'Si te cobran inscripción, curso o tasa para contratarte, detené el proceso y verificá la oferta.',
        ],
        en: [
          'If you are charged an application, course, or hiring fee, stop and verify the offer.',
        ],
      },
      health: {
        pt: [
          'Se houver urgência ou piora, procure atendimento imediato; a Ajuda não avalia sintomas.',
        ],
        es: [
          'Si hay urgencia o empeoramiento, buscá atención inmediata; Ayuda no evalúa síntomas.',
        ],
        en: [
          'If the situation is urgent or worsening, seek immediate care; Help does not assess symptoms.',
        ],
      },
      driving: {
        pt: [
          'Se a regra não confirmar seu caso, não dirija até validar a situação com Senatran ou Detran.',
        ],
        es: [
          'Si la regla no confirma tu caso, no conduzcas hasta validar la situación con Senatran o Detran.',
        ],
        en: [
          'If the rule does not confirm your case, do not drive until checking with Senatran or Detran.',
        ],
      },
      finance: {
        pt: [
          'Se uma instituição recusar, não envie documentos ou dinheiro a intermediários; use SAC, ouvidoria e canais oficiais de reclamação.',
        ],
        es: [
          'Si una institución rechaza la solicitud, no envíes documentos o dinero a intermediarios; usá atención al cliente, defensoría y canales oficiales.',
        ],
        en: [
          'If an institution refuses, do not send documents or money to intermediaries; use customer service, ombudsman, and official complaint channels.',
        ],
      },
      tax: {
        pt: [
          'Se faltarem datas ou documentos, não estime o imposto: monte a linha do tempo e leve as lacunas a um contador Brasil–Argentina.',
        ],
        es: [
          'Si faltan fechas o documentos, no estimes el impuesto: armá la línea de tiempo y llevá las dudas a un contador Brasil–Argentina.',
        ],
        en: [
          'If dates or documents are missing, do not estimate tax: build a timeline and take the gaps to a Brazil–Argentina accountant.',
        ],
      },
      family: {
        pt: [
          'Se houver desacordo de responsáveis, guarda ou documento ausente, interrompa o preparo genérico e procure orientação consular ou jurídica.',
        ],
        es: [
          'Si hay desacuerdo entre responsables, guarda o documentos faltantes, detené la preparación genérica y buscá orientación consular o jurídica.',
        ],
        en: [
          'If there is parental disagreement, custody, or a missing document, stop using a generic checklist and seek consular or legal guidance.',
        ],
      },
      pets_customs: {
        pt: [
          'Se o item não aparecer claramente na regra, não presuma que está liberado: confirme com a autoridade e a transportadora antes do embarque.',
        ],
        es: [
          'Si el ítem no aparece claramente en la regla, no supongas que está permitido: confirmá con la autoridad y el transportista antes del viaje.',
        ],
        en: [
          'If the item is not clearly covered by the rule, do not assume it is allowed: confirm with the authority and carrier before travel.',
        ],
      },
      utilities: {
        pt: [
          'Se houver recusa ou cobrança, peça o motivo por escrito e guarde o protocolo antes de escalar ao regulador.',
        ],
        es: [
          'Si hay rechazo o cobro, pedí el motivo por escrito y guardá el protocolo antes de escalar al regulador.',
        ],
        en: [
          'If refused or charged, request the reason in writing and keep the protocol before escalating to the regulator.',
        ],
      },
      protection: {
        pt: [
          'Se não puder buscar ajuda com segurança pelo próprio aparelho, use um telefone ou local confiável e atendimento humano.',
        ],
        es: [
          'Si no podés buscar ayuda de forma segura desde tu dispositivo, usá un teléfono o lugar confiable y atención humana.',
        ],
        en: [
          'If you cannot safely seek help from your device, use a trusted phone or location and human support.',
        ],
      },
      consumer: {
        pt: [
          'Em fraude ativa, bloqueie contas e meios de pagamento antes de seguir a reclamação administrativa.',
        ],
        es: [
          'Ante un fraude activo, bloqueá cuentas y medios de pago antes de continuar el reclamo administrativo.',
        ],
        en: [
          'During active fraud, secure accounts and payment methods before continuing the administrative complaint.',
        ],
      },
      long_term: {
        pt: [
          'Se faltarem registros ou houver divergência, não estime períodos: peça o extrato a cada organismo e faça a análise formal.',
        ],
        es: [
          'Si faltan registros o hay divergencias, no estimes períodos: pedí el historial a cada organismo y hacé el análisis formal.',
        ],
        en: [
          'If records are missing or inconsistent, do not estimate periods: request records from each authority and obtain a formal review.',
        ],
      },
    };
    return {
      nextSteps: this.unique(
        matches.flatMap(
          (match) => nextByTopic[match.intent.topic]?.[locale] ?? [],
        ),
      ).slice(0, 3),
      fallbackPath: this.unique(
        matches.flatMap(
          (match) => fallbackByTopic[match.intent.topic]?.[locale] ?? [],
        ),
      ).slice(0, 2),
    };
  }

  private entryFor(intent: QuickHelpIntentDefinition) {
    if (!intent.entryId) return undefined;
    return QUICK_HELP_ENTRIES.find((entry) => entry?.id === intent.entryId);
  }

  private coverageReason(
    status: QuickHelpCoverageStatus,
    locale: QuickHelpLocale,
  ) {
    const copy: Record<
      QuickHelpCoverageStatus,
      Record<QuickHelpLocale, string>
    > = {
      confirmed: {
        pt: 'As afirmações estão vinculadas a fontes oficiais vigentes para o contexto informado.',
        es: 'Las afirmaciones están vinculadas a fuentes oficiales vigentes para el contexto informado.',
        en: 'The claims are linked to current official sources for the provided context.',
      },
      conditional: {
        pt: 'As afirmações têm fontes oficiais, mas a aplicação depende de detalhes do seu caso ou da operação local.',
        es: 'Las afirmaciones tienen fuentes oficiales, pero su aplicación depende de detalles de tu caso o de la gestión local.',
        en: 'The claims have official sources, but application depends on case details or local operation.',
      },
      needs_context: {
        pt: 'Uma resposta sua muda o caminho recomendado. Escolha uma opção para continuar.',
        es: 'Una respuesta tuya cambia el camino recomendado. Elegí una opción para continuar.',
        en: 'One answer changes the recommended path. Choose an option to continue.',
      },
      partial: {
        pt: 'Parte da dúvida ainda não possui evidência revisada suficiente; ela está identificada separadamente.',
        es: 'Parte de la duda todavía no tiene evidencia revisada suficiente; está identificada por separado.',
        en: 'Part of the question does not yet have enough reviewed evidence; it is identified separately.',
      },
      not_covered: {
        pt: 'Ainda não há uma resposta revisada específica para esta dúvida.',
        es: 'Todavía no hay una respuesta revisada específica para esta duda.',
        en: 'There is not yet a specific reviewed answer for this question.',
      },
    };
    return copy[status][locale];
  }

  private notCoveredAnswer(locale: QuickHelpLocale) {
    return {
      pt: 'Ainda não temos uma resposta revisada específica para essa dúvida. Tente informar o problema principal, como CPF, matrícula escolar, garantia de aluguel, SUS, trabalho formal ou habilitação.',
      es: 'Todavía no tenemos una respuesta revisada específica para esa duda. Intentá indicar el problema principal, como CPF, matrícula escolar, garantía de alquiler, SUS, trabajo formal o licencia.',
      en: 'We do not yet have a specific reviewed answer for this question. Try naming the main problem, such as CPF, school enrollment, rental guarantees, SUS, formal work, or driving licence.',
    }[locale];
  }

  private highestRisk(values: QuickHelpRiskLevel[]): QuickHelpRiskLevel {
    const rank: Record<QuickHelpRiskLevel, number> = {
      low: 0,
      medium: 1,
      financial: 2,
      legal: 3,
      medical: 4,
    };
    return values.reduce<QuickHelpRiskLevel>(
      (highest, value) => (rank[value] > rank[highest] ? value : highest),
      'low',
    );
  }

  private earliestDate(values: string[]) {
    return values.length === 0 ? null : [...values].sort()[0];
  }

  private resolutionId(message: string, contentVersion: string) {
    const digest = createHash('sha256')
      .update(`${contentVersion}:${message.trim().toLowerCase()}`)
      .digest('hex')
      .slice(0, 16);
    return `quick-help-${digest}`;
  }

  private isCurrent(validUntil: string) {
    const expiry = Date.parse(`${validUntil}T23:59:59.999Z`);
    return Number.isFinite(expiry) && expiry >= Date.now();
  }

  private unique<T>(values: T[]) {
    return [...new Set(values)];
  }

  private uniqueBy<T>(values: T[], key: (value: T) => string) {
    const seen = new Set<string>();
    return values.filter((value) => {
      const id = key(value);
      if (seen.has(id)) return false;
      seen.add(id);
      return true;
    });
  }

  private normalizeLocale(locale?: string): QuickHelpLocale {
    return locale === 'es' || locale === 'en' ? locale : 'pt';
  }
}
