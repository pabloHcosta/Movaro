import { findRegisteredGuideCatalogByCorridor } from '../../../data/guide-catalog.registry';
import type { GuideItem } from '../../../data/argentina-brazil-guide.datasource';

export type GuidanceTopic =
  | 'documents'
  | 'cpf'
  | 'visa'
  | 'costs'
  | 'housing'
  | 'activities'
  | 'best_time';

export type GuidanceLocale = 'pt' | 'es' | 'en';

export interface CorridorGuidanceContext {
  cityName: string | null;
  currentPhase?: string;
  completedItemIds: string[];
}

export interface CorridorGuidanceProfile {
  key: string;
  coverageLevel?: 'full' | 'partial';
  guideItems: GuideItem[];
  phaseOrder: readonly string[];
  completedItemAliases?: Record<string, string>;
  quickPromptLabel(locale: GuidanceLocale): string;
  quickPromptMessage(locale: GuidanceLocale): string;
  buildAnswer(
    topic: GuidanceTopic,
    locale: GuidanceLocale,
    context: CorridorGuidanceContext,
    helpers: {
      phaseHint: (
        locale: GuidanceLocale,
        currentPhase: string | undefined,
        completedItemIds: string[],
      ) => string;
      nextPendingItem: (
        currentPhase: string | undefined,
        completedItemIds: string[],
        preferredPhases?: string[],
      ) => string | null;
    },
  ): string;
}

const argentinaBrazilGuideCatalog =
  findRegisteredGuideCatalogByCorridor('argentina->brasil');

if (!argentinaBrazilGuideCatalog) {
  throw new Error('Missing guide catalog for argentina->brasil');
}

export const argentinaBrazilGuidanceProfile: CorridorGuidanceProfile = {
  key: 'argentina->brasil',
  coverageLevel: 'full',
  guideItems: argentinaBrazilGuideCatalog.items,
  phaseOrder: argentinaBrazilGuideCatalog.phaseOrder,
  completedItemAliases: argentinaBrazilGuideCatalog.completedItemAliases,
  quickPromptLabel(locale) {
    if (locale === 'es') return '¿Cómo obtener mi CPF?';
    if (locale === 'en') return 'How do I get my CPF?';
    return 'Como tirar o CPF?';
  },
  quickPromptMessage(locale) {
    if (locale === 'es') return '¿Cómo obtener mi CPF?';
    if (locale === 'en') return 'How do I get my CPF?';
    return 'Como tirar o CPF?';
  },
  buildAnswer(topic, locale, context, helpers) {
    switch (topic) {
      case 'cpf': {
        const alreadyDone = context.completedItemIds.includes('doc-01');
        if (locale === 'es') {
          return alreadyDone
            ? `El CPF ya aparece como resuelto en tu progreso. Si todavía falta usarlo en la práctica, el siguiente paso suele ser banco, alquiler o registro laboral.`
            : `Para argentinos en Brasil, el CPF es uno de los primeros movimientos prácticos:

- Se pide con documento válido
- Desbloquea banco, alquiler, contratos y trabajo formal
- Conviene resolverlo antes de depender de trámites más pesados

${helpers.phaseHint(locale, context.currentPhase, context.completedItemIds)}`;
        }
        if (locale === 'en') {
          return alreadyDone
            ? `CPF already appears as completed in your progress. If it is not being used yet, the next practical move is usually banking, rent, or work registration.`
            : `For Argentinians in Brazil, CPF is one of the first practical moves:

- It is requested with a valid identity document
- It unlocks banking, rent, contracts, and formal work
- It should come before heavier execution steps

${helpers.phaseHint(locale, context.currentPhase, context.completedItemIds)}`;
        }
        return alreadyDone
          ? `O CPF já aparece como concluído no seu progresso. Se ainda falta usar isso na prática, o próximo movimento costuma ser banco, aluguel ou regularização de trabalho.`
          : `Para argentinos no Brasil, o CPF é um dos primeiros movimentos práticos:

- Ele é solicitado com documento válido
- Destrava banco, aluguel, contratos e trabalho formal
- Vale resolver isso antes de depender de etapas mais pesadas

${helpers.phaseHint(locale, context.currentPhase, context.completedItemIds)}`;
      }

      case 'visa': {
        const hasResidence = context.completedItemIds.includes('doc-02');
        if (locale === 'es') {
          return hasResidence
            ? `La residencia MERCOSUR ya aparece en tu progreso. Lo importante ahora es usar esa regularización para avanzar con CRNM, banco y trabajo formal.`
            : `Para el corredor Argentina -> Brasil, la lógica práctica no suele ser “visa primero”, sino revisar la residencia MERCOSUR:

- Argentinos normalmente usan la vía MERCOSUR
- Eso es distinto de una consulta genérica de visa de turismo
- Si tu plan ya está en ejecución, esta etapa no conviene dejarla para el final

${helpers.phaseHint(locale, context.currentPhase, context.completedItemIds)}`;
        }
        if (locale === 'en') {
          return hasResidence
            ? `MERCOSUR residency already appears in your progress. The important next step is to use that regularization to move into CRNM, banking, and formal work.`
            : `For the Argentina -> Brazil corridor, the practical path is usually not “tourist visa first”, but reviewing the MERCOSUR residency route:

- Argentinians usually rely on the MERCOSUR path
- That is different from a generic tourist-visa question
- If your plan is already moving, this should not be left for the end

${helpers.phaseHint(locale, context.currentPhase, context.completedItemIds)}`;
        }
        return hasResidence
          ? `A residência MERCOSUL já aparece no seu progresso. O importante agora é usar essa regularização para avançar em CRNM, banco e trabalho formal.`
          : `Para o corredor Argentina -> Brasil, a lógica prática normalmente não é “visto de turismo primeiro”, e sim revisar a rota de residência MERCOSUL:

- Argentinos normalmente usam a via MERCOSUL
- Isso é diferente de uma pergunta genérica sobre visto de turista
- Se seu plano já está em execução, essa etapa não vale deixar para o final

${helpers.phaseHint(locale, context.currentPhase, context.completedItemIds)}`;
      }

      case 'costs':
        if (locale === 'es') {
          return `Sin usar IA, la lectura de costos para este corredor debería arrancar por tres bloques:

- llegada: pasajes, reserva y primeros días
- vivienda: alquiler, garantía o depósito, y costo de entrada
- vida mensual: comida, transporte e imprevistos

${context.cityName ? `Como tu plan apunta a ${context.cityName}, usá esa ciudad como base para revisar alquiler, entrada de vivienda y transporte.` : 'Si todavía no cerraste ciudad, compará primero 2 o 3 opciones antes de fijar un presupuesto más rígido.'}`;
        }
        if (locale === 'en') {
          return `Without using AI, the cost read for this corridor should start with three blocks:

- arrival: flights, reserve, and first days
- housing: rent, guarantee or deposit, and move-in cost
- monthly life: food, transport, and surprises

${context.cityName ? `Since your plan points to ${context.cityName}, use that city as your base for rent, move-in costs, and transport.` : 'If your city is not locked yet, compare 2 or 3 options before fixing a tighter budget.'}`;
        }
        return `Sem usar IA, a leitura de custos para esse corredor deveria começar por três blocos:

- chegada: passagens, reserva e primeiros dias
- moradia: aluguel, garantia ou caução, e custo de entrada
- vida mensal: alimentação, transporte e imprevistos

${context.cityName ? `Como seu plano aponta para ${context.cityName}, use essa cidade como base para revisar aluguel, entrada de moradia e transporte.` : 'Se a cidade ainda não está fechada, compare primeiro 2 ou 3 opções antes de travar um orçamento mais rígido.'}`;

      case 'housing': {
        const currentHint = helpers.nextPendingItem(
          context.currentPhase,
          context.completedItemIds,
          ['housing', 'preparation'],
        );
        if (locale === 'es') {
          return `Para este flujo, “dónde quedarse” debería resolverse en dos tiempos:

- primeros 30-60 días: alojamiento temporal ya confirmado
- alquiler más estable: solo después de entender barrio, garantías y documentos

${context.cityName ? `Si tu base sigue siendo ${context.cityName}, evaluá esa ciudad primero antes de buscar algo definitivo.` : ''}${currentHint ? `\n\nTu siguiente foco de vivienda hoy es: ${currentHint}.` : ''}`;
        }
        if (locale === 'en') {
          return `For this flow, “where to stay” should be solved in two stages:

- first 30-60 days: temporary accommodation already confirmed
- more stable rent: only after you understand neighborhood, guarantees, and documents

${context.cityName ? `If ${context.cityName} is still your base, evaluate that city first before committing to something permanent.` : ''}${currentHint ? `\n\nYour next housing focus today is: ${currentHint}.` : ''}`;
        }
        return `Para esse fluxo, “onde ficar” deveria ser resolvido em dois tempos:

- primeiros 30-60 dias: acomodação temporária já confirmada
- aluguel mais estável: só depois de entender bairro, garantias e documentos

${context.cityName ? `Se ${context.cityName} continua sendo sua base, avalie essa cidade primeiro antes de fechar algo definitivo.` : ''}${currentHint ? `\n\nSeu próximo foco de moradia hoje é: ${currentHint}.` : ''}`;
      }

      case 'activities':
        if (locale === 'es') {
          return context.cityName
            ? `Si tu ciudad base hoy es ${context.cityName}, esta pregunta conviene leerla como adaptación práctica:

- qué tipo de rutina la ciudad favorece
- qué barrios y movilidad hacen sentido para tu llegada
- si la ciudad combina con tu prioridad principal del plan

No hace falta IA para eso si el app ya tiene ciudad recomendada, contexto de costo y guía de llegada.`
            : `“Qué hacer allá” no debería salir como respuesta genérica. Sin ciudad definida, primero conviene cerrar la base del plan y recién después hablar de rutina, barrios y adaptación.`;
        }
        if (locale === 'en') {
          return context.cityName
            ? `If your base city today is ${context.cityName}, this question should be read as practical adaptation:

- what kind of routine the city supports
- which neighborhoods and mobility patterns fit your arrival
- whether the city matches your main plan priority

That does not need AI if the app already has recommended city, cost context, and arrival guidance.`
            : `“What to do there” should not come back as a generic answer. Without a defined city, the plan should first lock the base and only then talk about routine, neighborhoods, and adaptation.`;
        }
        return context.cityName
          ? `Se sua cidade base hoje é ${context.cityName}, essa pergunta faz mais sentido como adaptação prática:

- que tipo de rotina a cidade favorece
- que bairros e mobilidade combinam com sua chegada
- se a cidade conversa com a prioridade principal do seu plano

Isso não precisa de IA se o app já tem cidade recomendada, contexto de custo e guia de chegada.`
          : `“O que fazer lá” não deveria voltar como uma resposta genérica. Sem cidade definida, primeiro vale fechar a base do plano e só depois falar de rotina, bairros e adaptação.`;

      case 'best_time':
        if (locale === 'es') {
          return `La “mejor época” para ir no debería salir como consejo solto. En este producto, depende de:

- qué tan avanzada está tu documentación
- si ya resolviste reserva y vivienda temporal
- si tu ciudad base ya está elegida

${helpers.phaseHint(locale, context.currentPhase, context.completedItemIds)}`;
        }
        if (locale === 'en') {
          return `The “best time” to go should not come back as a loose tip. In this product, it depends on:

- how advanced your paperwork is
- whether reserve and temporary housing are already handled
- whether your base city is already chosen

${helpers.phaseHint(locale, context.currentPhase, context.completedItemIds)}`;
        }
        return `A “melhor época” para ir não deveria voltar como dica solta. Nesse produto, ela depende de:

- quão adiantada está sua documentação
- se você já resolveu reserva e moradia temporária
- se sua cidade base já foi escolhida

${helpers.phaseHint(locale, context.currentPhase, context.completedItemIds)}`;

      case 'documents':
      default: {
        const progress = helpers.phaseHint(
          locale,
          context.currentPhase,
          context.completedItemIds,
        );
        const cityLine = context.cityName
          ? locale === 'es'
            ? `Si tu ciudad base sigue siendo ${context.cityName}, mantené la documentación lista antes de avanzar con vivienda y banco.`
            : locale === 'en'
              ? `If ${context.cityName} is still your base city, keep your paperwork ready before moving into housing and banking.`
              : `Se ${context.cityName} continua sendo sua cidade base, mantenha a documentação pronta antes de avançar em moradia e banco.`
          : '';
        if (locale === 'es') {
          return `Para Argentina -> Brasil, la base documental inicial es bastante clara:

- Pasaporte o DNI válido
- CPF
- Ruta de residencia MERCOSUR
- Antecedentes apostillados si vas a regularizar residencia
- Documentos personales que después puedan exigir apostilla o traducción

${progress}${cityLine ? `\n\n${cityLine}` : ''}`;
        }
        if (locale === 'en') {
          return `For Argentina -> Brazil, the initial document stack is fairly clear:

- Valid passport or ID
- CPF
- MERCOSUR residency path
- Apostilled criminal record if you are regularizing residency
- Personal documents that may later require apostille or sworn translation

${progress}${cityLine ? `\n\n${cityLine}` : ''}`;
        }
        return `Para Argentina -> Brasil, a base documental inicial é bem objetiva:

- Passaporte ou DNI válido
- CPF
- Caminho de residência MERCOSUL
- Antecedentes apostilados se você for regularizar residência
- Documentos pessoais que depois possam exigir apostila ou tradução

${progress}${cityLine ? `\n\n${cityLine}` : ''}`;
      }
    }
  },
};

const uruguayBrazilGuideCatalog =
  findRegisteredGuideCatalogByCorridor('uruguai->brasil');

if (!uruguayBrazilGuideCatalog) {
  throw new Error('Missing guide catalog for uruguai->brasil');
}

export const uruguayBrazilGuidanceProfile: CorridorGuidanceProfile = {
  key: 'uruguai->brasil',
  coverageLevel: 'partial',
  guideItems: uruguayBrazilGuideCatalog.items,
  phaseOrder: uruguayBrazilGuideCatalog.phaseOrder,
  quickPromptLabel(locale) {
    if (locale === 'es') return '¿Primer documento local?';
    if (locale === 'en') return 'First local document?';
    return 'Primeiro documento local?';
  },
  quickPromptMessage(locale) {
    if (locale === 'es')
      return '¿Cuál es el primer documento local que debería resolver al llegar a Brasil?';
    if (locale === 'en')
      return 'What is the first local document I should solve after arriving in Brazil?';
    return 'Qual é o primeiro documento local que eu deveria resolver ao chegar no Brasil?';
  },
  buildAnswer(topic, locale) {
    if (locale === 'es') {
      return `Este corredor ya fue reconocido por Movaro, pero todavía tiene cobertura parcial. Hoy la recomendación segura es usar el asistente para orientación inicial y confirmar reglas operativas antes de tratarlo como guía cerrada. Tema consultado: ${topic}.`;
    }
    if (locale === 'en') {
      return `This corridor is already recognized by Movaro, but it still has partial coverage. For now, the safe recommendation is to use the assistant for initial orientation and confirm operational rules before treating it as a closed guide. Topic requested: ${topic}.`;
    }
    return `Esse corredor já foi reconhecido pelo Movaro, mas ainda está com cobertura parcial. Por enquanto, a recomendação segura é usar o assistente para orientação inicial e confirmar regras operacionais antes de tratar isso como um guia fechado. Tema consultado: ${topic}.`;
  },
};

export const corridorGuidanceProfiles: CorridorGuidanceProfile[] = [
  argentinaBrazilGuidanceProfile,
  uruguayBrazilGuidanceProfile,
];
