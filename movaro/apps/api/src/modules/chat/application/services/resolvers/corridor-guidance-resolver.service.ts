import { Injectable } from '@nestjs/common';

import { CitiesCatalogService } from '../../../../cities/application/services/cities-catalog.service';
import { AssistantKnowledgeService } from '../assistant-knowledge.service';
import { normalizeChatCorridor } from '../chat-country-normalizer';
import { AskChatDto } from '../../../presentation/dto/ask-chat.dto';
import {
  corridorGuidanceProfiles,
  CorridorGuidanceProfile,
  GuidanceLocale,
  GuidanceTopic,
} from './corridor-guidance-profiles';

export interface CorridorGuidanceResult {
  found: boolean;
  confidence: number;
  answer: string;
  topic?: GuidanceTopic;
}

type SeasonalityProfileKey =
  | 'default'
  | 'coastal_south'
  | 'northeast'
  | 'north';

const EXACT_QUICK_PROMPTS: Record<GuidanceTopic, string[]> = {
  documents: [],
  cpf: [
    'como tirar o cpf',
    'como obter o cpf',
    'como obtener mi cpf',
    'how do i get my cpf',
  ],
  visa: ['preciso de visto', 'necesito visa', 'do i need a visa'],
  costs: [],
  housing: [],
  activities: [],
  best_time: [
    'melhor epoca pra ir',
    'melhor epoca para ir',
    'mejor epoca para ir',
    'best time to go',
  ],
};

const CITY_TO_SEASONALITY_PROFILE: Record<string, SeasonalityProfileKey> = {
  'florianopolis-sc': 'coastal_south',
  'balneario-camboriu-sc': 'coastal_south',
  'itajai-sc': 'coastal_south',
  'joinville-sc': 'coastal_south',
  'blumenau-sc': 'coastal_south',
  'sao-paulo-sp': 'default',
  'curitiba-pr': 'default',
  'rio-de-janeiro-rj': 'default',
  'armacao-dos-buzios-rj': 'default',
  'porto-alegre-rs': 'default',
  'belo-horizonte-mg': 'default',
  'campo-grande-ms': 'default',
  'salvador-ba': 'northeast',
  'recife-pe': 'northeast',
  'fortaleza-ce': 'northeast',
  'natal-rn': 'northeast',
  'joao-pessoa-pb': 'northeast',
  'aracaju-se': 'northeast',
  'maceio-al': 'northeast',
  'manaus-am': 'north',
  'belem-pa': 'north',
};

const LOW_MONTHS_BY_PROFILE: Record<SeasonalityProfileKey, number[]> = {
  default: [4, 5, 9, 10, 11],
  coastal_south: [3, 4, 9, 10, 11],
  northeast: [4, 5, 9, 10, 11],
  north: [5, 6, 9, 10],
};

const TOPIC_KEYWORDS: Record<GuidanceTopic, string[]> = {
  documents: [
    'documentos',
    'documents',
    'documentación',
    'papelada',
    'papeles',
  ],
  cpf: ['cpf', 'cadastro de pessoa fisica', 'cadastro de pessoa física'],
  visa: ['visto', 'visa', 'visado', 'residencia', 'residência', 'mercosul'],
  costs: [
    'custo',
    'custos',
    'cost',
    'costs',
    'costo',
    'costos',
    'orçamento',
    'presupuesto',
    'budget',
  ],
  housing: [
    'moradia',
    'housing',
    'vivienda',
    'onde ficar',
    'where to stay',
    'donde quedarse',
    'dónde quedarse',
    'aluguel',
    'rent',
    'alquiler',
  ],
  activities: [
    'o que fazer',
    'what to do',
    'que hacer',
    'qué hacer',
    'vida na cidade',
    'life in the city',
    'vida en la ciudad',
  ],
  best_time: [
    'melhor época',
    'melhor epoca',
    'best time',
    'best season',
    'mejor época',
    'mejor epoca',
    'melhor momento',
  ],
};

@Injectable()
export class CorridorGuidanceResolverService {
  constructor(
    private readonly citiesCatalogService: CitiesCatalogService,
    private readonly assistantKnowledgeService: AssistantKnowledgeService,
  ) {}

  async resolve(dto: AskChatDto): Promise<CorridorGuidanceResult> {
    const topic = this.detectTopic(dto.message);
    if (!topic) {
      return { found: false, confidence: 0, answer: '' };
    }

    const corridorKey = this.normalizeCorridor(
      dto.originCountry,
      dto.destinationCountry,
    );
    const profile = corridorGuidanceProfiles.find(
      (item) => item.key === corridorKey,
    );
    const locale = this.normalizeLocale(dto.locale);

    if (!profile) {
      return {
        found: true,
        confidence: 0.9,
        topic,
        answer: this.unsupportedCorridorAnswer(
          locale,
          dto.originCountry,
          dto.destinationCountry,
        ),
      };
    }

    const normalizedCompletedItemIds = this.normalizeCompletedItemIds(
      dto.completedItemIds ?? [],
      profile,
    );

    const resolvedCityId = dto.recommendedCityId
      ? this.citiesCatalogService.resolveCityId(dto.recommendedCityId)
      : null;
    const cityName = dto.recommendedCityId
      ? this.citiesCatalogService.getCityDisplayNameById(dto.recommendedCityId)
      : null;

    const exactQuickPrompt = this.detectExactQuickPromptTopic(dto.message);
    if (exactQuickPrompt) {
      return {
        found: true,
        confidence: 0.97,
        topic: exactQuickPrompt,
        answer: this.buildExactQuickPromptAnswer(
          exactQuickPrompt,
          locale,
          dto.currentPhase,
          normalizedCompletedItemIds,
          cityName,
          resolvedCityId,
        ),
      };
    }

    return {
      found: true,
      confidence: 0.93,
      topic,
      answer: profile.buildAnswer(topic, locale, {
        cityName,
        currentPhase: dto.currentPhase,
        completedItemIds: normalizedCompletedItemIds,
      }, {
        phaseHint: (currentLocale, currentPhase, completedItemIds) =>
          this.phaseHint(profile, currentLocale, currentPhase, completedItemIds),
        nextPendingItem: (currentPhase, completedItemIds, preferredPhases) =>
          this.nextPendingItem(
            profile,
            currentPhase,
            completedItemIds,
            preferredPhases,
          ),
      }),
    };
  }

  async getQuickPromptLabel(
    originCountry: string,
    destinationCountry: string,
    locale: string,
  ): Promise<string> {
    const corridorKey = this.normalizeCorridor(originCountry, destinationCountry);
    const normalizedLocale = this.normalizeLocale(locale);
    const template = await this.assistantKnowledgeService.getQuickPromptTemplate(
      'first_local_document',
      normalizedLocale,
      corridorKey,
    );
    if (template) {
      return template.label;
    }

    const profile = this.resolveProfile(originCountry, destinationCountry);
    if (!profile) {
      return this.genericQuickPromptLabel(normalizedLocale);
    }
    return profile.quickPromptLabel(normalizedLocale);
  }

  async getQuickPromptMessage(
    originCountry: string,
    destinationCountry: string,
    locale: string,
  ): Promise<string> {
    const corridorKey = this.normalizeCorridor(originCountry, destinationCountry);
    const normalizedLocale = this.normalizeLocale(locale);
    const template = await this.assistantKnowledgeService.getQuickPromptTemplate(
      'first_local_document',
      normalizedLocale,
      corridorKey,
    );
    if (template) {
      return template.message;
    }

    const profile = this.resolveProfile(originCountry, destinationCountry);
    if (!profile) {
      return this.genericQuickPromptMessage(normalizedLocale);
    }
    return profile.quickPromptMessage(normalizedLocale);
  }

  private detectTopic(message: string): GuidanceTopic | null {
    const lower = message.toLowerCase();

    let bestTopic: GuidanceTopic | null = null;
    let bestScore = 0;

    for (const [topic, keywords] of Object.entries(TOPIC_KEYWORDS)) {
      const score = keywords.reduce(
        (sum, keyword) => sum + (lower.includes(keyword) ? keyword.length : 0),
        0,
      );
      if (score > bestScore) {
        bestTopic = topic as GuidanceTopic;
        bestScore = score;
      }
    }

    return bestScore > 0 ? bestTopic : null;
  }

  isExactQuickPrompt(message: string): boolean {
    return this.detectExactQuickPromptTopic(message) != null;
  }

  private detectExactQuickPromptTopic(message: string): GuidanceTopic | null {
    const normalizedMessage = this.normalizePrompt(message);

    for (const [topic, prompts] of Object.entries(EXACT_QUICK_PROMPTS)) {
      if (prompts.includes(normalizedMessage)) {
        return topic as GuidanceTopic;
      }
    }

    return null;
  }

  private resolveProfile(
    originCountry: string,
    destinationCountry: string,
  ): CorridorGuidanceProfile | null {
    const corridorKey = this.normalizeCorridor(originCountry, destinationCountry);
    return (
      corridorGuidanceProfiles.find((item) => item.key === corridorKey) ?? null
    );
  }

  private normalizeCorridor(originCountry: string, destinationCountry: string) {
    return normalizeChatCorridor(originCountry, destinationCountry);
  }

  private normalizePrompt(message: string): string {
    return message
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase()
      .replace(/[!?.,;:]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  }

  private normalizeLocale(locale?: string): GuidanceLocale {
    if (locale === 'es' || locale === 'en') {
      return locale;
    }
    return 'pt';
  }

  private normalizeCompletedItemIds(
    completedItemIds: string[],
    profile: CorridorGuidanceProfile,
  ): string[] {
    if (!profile.completedItemAliases) {
      return completedItemIds;
    }

    return completedItemIds.map(
      (itemId) => profile.completedItemAliases?.[itemId] ?? itemId,
    );
  }

  private phaseHint(
    profile: CorridorGuidanceProfile,
    locale: GuidanceLocale,
    currentPhase: string | undefined,
    completedItemIds: string[],
  ): string {
    const nextItem = this.nextPendingItem(
      profile,
      currentPhase,
      completedItemIds,
    );

    if (!nextItem) {
      if (locale === 'es') {
        return 'Tu progreso actual no muestra un cuello de botella claro en esta etapa.';
      }
      if (locale === 'en') {
        return 'Your current progress does not show a clear blocker in this stage.';
      }
      return 'Seu progresso atual não mostra um bloqueio claro nessa etapa.';
    }

    if (locale === 'es') {
      return `Por tu progreso actual, el próximo punto práctico a mover es: ${nextItem}.`;
    }
    if (locale === 'en') {
      return `From your current progress, the next practical item to move is: ${nextItem}.`;
    }
    return `Pelo seu progresso atual, o próximo ponto prático para mover é: ${nextItem}.`;
  }

  private nextPendingItem(
    profile: CorridorGuidanceProfile,
    currentPhase: string | undefined,
    completedItemIds: string[],
    preferredPhases?: string[],
  ): string | null {
    const phases =
      preferredPhases ?? this.orderedPhasesFrom(profile, currentPhase);
    const completed = new Set(completedItemIds);

    for (const phase of phases) {
      const pending = profile.guideItems.find(
        (item) => item.phase === phase && !completed.has(item.id),
      );
      if (pending) {
        return pending.title;
      }
    }

    return profile.guideItems.find(
      (item) => !completed.has(item.id),
    )?.title ?? null;
  }

  private orderedPhasesFrom(
    profile: CorridorGuidanceProfile,
    currentPhase?: string,
  ): string[] {
    if (!currentPhase || !profile.phaseOrder.includes(currentPhase)) {
      return [...profile.phaseOrder];
    }

    const currentIndex = profile.phaseOrder.indexOf(currentPhase);
    return [
      ...profile.phaseOrder.slice(currentIndex),
      ...profile.phaseOrder.slice(0, currentIndex),
    ];
  }

  private unsupportedCorridorAnswer(
    locale: GuidanceLocale,
    originCountry: string,
    destinationCountry: string,
  ): string {
    const corridor = `${originCountry} -> ${destinationCountry}`;
    if (locale === 'es') {
      return `Todavía no hay respuestas guiadas sin IA para el corredor ${corridor}. Cuando este corredor tenga cobertura estructurada, estas preguntas rápidas también van a responderse de forma determinística.`;
    }
    if (locale === 'en') {
      return `There is no structured non-AI guidance yet for the ${corridor} corridor. Once this corridor has product coverage, these quick prompts will also resolve deterministically.`;
    }
    return `Ainda não existem respostas guiadas sem IA para o corredor ${corridor}. Quando esse corredor tiver cobertura estruturada no produto, essas perguntas rápidas também passarão a responder de forma determinística.`;
  }

  private genericQuickPromptLabel(locale: GuidanceLocale): string {
    if (locale === 'es') return 'Primer documento local';
    if (locale === 'en') return 'First local document';
    return 'Primeiro documento local';
  }

  private genericQuickPromptMessage(locale: GuidanceLocale): string {
    if (locale === 'es') {
      return '¿Cuál es el primer documento local que debería resolver al llegar?';
    }
    if (locale === 'en') {
      return 'What is the first local document I should sort out after arrival?';
    }
    return 'Qual é o primeiro documento local que eu deveria resolver ao chegar?';
  }

  private buildExactQuickPromptAnswer(
    topic: GuidanceTopic,
    locale: GuidanceLocale,
    currentPhase: string | undefined,
    completedItemIds: string[],
    cityName: string | null,
    cityId: string | null,
  ): string {
    switch (topic) {
      case 'visa':
        return this.buildVisaQuickAnswer(locale);
      case 'cpf':
        return this.buildCpfQuickAnswer(locale, completedItemIds);
      case 'best_time':
        return this.buildBestTimeQuickAnswer(
          locale,
          currentPhase,
          cityName,
          cityId,
        );
      default:
        return '';
    }
  }

  private buildVisaQuickAnswer(locale: GuidanceLocale): string {
    if (locale === 'es') {
      return 'No para entrar como visitante: argentinos pueden entrar a Brasil con DNI o pasaporte y quedarse hasta 90 días. Si la idea es vivir en Brasil, el camino usual es la residencia Mercosur, no una visa de turismo.';
    }
    if (locale === 'en') {
      return 'Not for visitor entry: Argentinians can enter Brazil with DNI or passport and stay for up to 90 days. If the goal is to live in Brazil, the usual path is Mercosur residency, not a tourist visa.';
    }
    return 'Não para entrar como visitante: argentinos podem entrar no Brasil com DNI ou passaporte e ficar até 90 dias. Se a ideia é morar no Brasil, o caminho usual é a residência Mercosul, não visto de turismo.';
  }

  private buildCpfQuickAnswer(
    locale: GuidanceLocale,
    completedItemIds: string[],
  ): string {
    const alreadyDone = completedItemIds.includes('doc-01');
    if (locale === 'es') {
      return alreadyDone
        ? 'El CPF ya aparece como concluido en tu progreso. Es lo que destraba banco, alquiler y trabajo formal.'
        : 'El CPF es uno de los primeros pasos prácticos en Brasil. Se puede pedir con documento válido en la Receita Federal, Correios o en el consulado brasileño; sin CPF se complica abrir cuenta, alquilar y trabajar formalmente.';
    }
    if (locale === 'en') {
      return alreadyDone
        ? 'CPF already appears as completed in your progress. It is what unlocks banking, rent, and formal work.'
        : 'CPF is one of the first practical steps in Brazil. It can be requested with a valid ID through Receita Federal, Correios, or the Brazilian consulate; without CPF, banking, rent, and formal work get harder.';
    }
    return alreadyDone
      ? 'O CPF já aparece como concluído no seu progresso. É ele que destrava banco, aluguel e trabalho formal.'
      : 'O CPF é um dos primeiros passos práticos no Brasil. Ele pode ser pedido com documento válido na Receita Federal, nos Correios ou no consulado brasileiro; sem CPF, fica mais difícil abrir conta, alugar e trabalhar formalmente.';
  }

  private buildBestTimeQuickAnswer(
    locale: GuidanceLocale,
    currentPhase: string | undefined,
    cityName: string | null,
    cityId: string | null,
  ): string {
    const seasonalProfile = cityId
      ? CITY_TO_SEASONALITY_PROFILE[cityId] ?? 'default'
      : 'default';
    const lowMonths = LOW_MONTHS_BY_PROFILE[seasonalProfile].map((month) =>
      this.monthLabel(month, locale),
    );
    const cityReference = cityName ?? this.genericDestinationLabel(locale);
    const climateNote = this.climateNote(seasonalProfile, locale, cityReference);
    const planningNote = this.bestTimePlanningNote(locale, currentPhase);

    if (locale === 'es') {
      return `Para ${cityReference}, normalmente conviene mirar ${this.joinMonths(lowMonths, locale)}: suelen equilibrar mejor tarifa de vuelo y llegada. ${climateNote} ${planningNote}`;
    }
    if (locale === 'en') {
      return `For ${cityReference}, ${this.joinMonths(lowMonths, locale)} usually gives the best balance between flight price and arrival conditions. ${climateNote} ${planningNote}`;
    }
    return `Para ${cityReference}, ${this.joinMonths(lowMonths, locale)} costumam dar o melhor equilíbrio entre passagem e chegada. ${climateNote} ${planningNote}`;
  }

  private monthLabel(month: number, locale: GuidanceLocale): string {
    const labels: Record<GuidanceLocale, string[]> = {
      pt: ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'],
      es: ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'],
      en: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
    };
    return labels[locale][month - 1] ?? String(month);
  }

  private joinMonths(months: string[], locale: GuidanceLocale): string {
    if (months.length <= 1) {
      return months.join('');
    }
    const last = months[months.length - 1];
    const head = months.slice(0, -1).join(', ');
    const conjunction = locale === 'es' ? ' y ' : locale === 'en' ? ' and ' : ' e ';
    return `${head}${conjunction}${last}`;
  }

  private climateNote(
    profile: SeasonalityProfileKey,
    locale: GuidanceLocale,
    cityReference: string,
  ): string {
    if (profile === 'coastal_south') {
      if (locale === 'es') {
        return `${cityReference} suele estar más llena y cara en pleno verano.`;
      }
      if (locale === 'en') {
        return `${cityReference} is usually busier and pricier in peak summer.`;
      }
      return `${cityReference} costuma ficar mais cheia e mais cara no pico do verão.`;
    }
    if (profile === 'northeast') {
      if (locale === 'es') {
        return 'Fin de año y vacaciones suelen presionar más las tarifas.';
      }
      if (locale === 'en') {
        return 'Year-end and holiday periods usually push fares higher.';
      }
      return 'Fim de ano e férias costumam pressionar mais as tarifas.';
    }
    if (profile === 'north') {
      if (locale === 'es') {
        return 'En ciudades del norte conviene evitar las ventanas más lluviosas.';
      }
      if (locale === 'en') {
        return 'For northern cities, it is better to avoid the rainiest windows.';
      }
      return 'Em cidades do Norte, vale evitar as janelas mais chuvosas.';
    }
    if (locale === 'es') {
      return 'Carnaval, vacaciones y compra encima de la fecha suelen encarecer bastante.';
    }
    if (locale === 'en') {
      return 'Carnival, holiday periods, and last-minute buying usually raise fares a lot.';
    }
    return 'Carnaval, férias e compra em cima da hora costumam encarecer bastante.';
  }

  private bestTimePlanningNote(
    locale: GuidanceLocale,
    currentPhase?: string,
  ): string {
    const documentationOpen =
      !currentPhase || currentPhase === 'preparation' || currentPhase === 'documents';
    if (locale === 'es') {
      return documentationOpen
        ? 'Si tu documentación todavía no está cerrada, no conviene comprar antes de resolver eso.'
        : 'Si tu documentación ya está encaminada, esas ventanas suelen ser las más seguras para monitorear.';
    }
    if (locale === 'en') {
      return documentationOpen
        ? 'If your paperwork is still open, do not lock flights before that.'
        : 'If your paperwork is already moving, those windows are usually the safest to monitor.';
    }
    return documentationOpen
      ? 'Se a sua documentação ainda não está fechada, não vale travar voo antes disso.'
      : 'Se a sua documentação já está andando, essas janelas costumam ser as mais seguras para monitorar.';
  }

  private genericDestinationLabel(locale: GuidanceLocale): string {
    if (locale === 'es') {
      return 'tu ciudad base';
    }
    if (locale === 'en') {
      return 'your base city';
    }
    return 'sua cidade base';
  }
}
