import { Injectable } from '@nestjs/common';

import { CitiesCatalogService } from '../../../../cities/application/services/cities-catalog.service';
import { CityCardEntity } from '../../../../cities/domain/entities/city-card.entity';
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

type TravelPriceLevel = 'low' | 'mid' | 'high';

interface DestinationTravelSeasonalityProfile {
  months: TravelPriceLevel[];
  lowUsdMin: number;
  lowUsdMax: number;
  seasonalWarningKey?: string;
}

const CITY_TO_IATA: Record<string, string> = {
  'florianopolis-sc': 'FLN',
  'balneario-camboriu-sc': 'NVT',
  'itajai-sc': 'NVT',
  'joinville-sc': 'NVT',
  'blumenau-sc': 'NVT',
  'sao-paulo-sp': 'GRU',
  'curitiba-pr': 'CWB',
  'rio-de-janeiro-rj': 'GIG',
  'armacao-dos-buzios-rj': 'GIG',
  'porto-alegre-rs': 'POA',
  'belo-horizonte-mg': 'CNF',
  'salvador-ba': 'SSA',
  'recife-pe': 'REC',
  'fortaleza-ce': 'FOR',
  'natal-rn': 'NAT',
  'joao-pessoa-pb': 'JPA',
  'aracaju-se': 'AJU',
  'maceio-al': 'MCZ',
  'campo-grande-ms': 'CGR',
  'manaus-am': 'MAO',
  'belem-pa': 'BEL',
};

const DEFAULT_TRAVEL_MONTHS: TravelPriceLevel[] = [
  'high',
  'high',
  'mid',
  'low',
  'low',
  'mid',
  'mid',
  'mid',
  'low',
  'low',
  'low',
  'high',
];

const COASTAL_SOUTH_TRAVEL_MONTHS: TravelPriceLevel[] = [
  'high',
  'high',
  'low',
  'low',
  'mid',
  'mid',
  'mid',
  'mid',
  'low',
  'low',
  'low',
  'high',
];

const NORTHEAST_TRAVEL_MONTHS: TravelPriceLevel[] = [
  'mid',
  'mid',
  'mid',
  'low',
  'low',
  'mid',
  'mid',
  'high',
  'low',
  'low',
  'mid',
  'high',
];

const NORTH_TRAVEL_MONTHS: TravelPriceLevel[] = [
  'high',
  'high',
  'high',
  'mid',
  'low',
  'low',
  'mid',
  'mid',
  'low',
  'low',
  'mid',
  'high',
];

const DESTINATION_TRAVEL_PROFILES: Record<
  string,
  DestinationTravelSeasonalityProfile
> = {
  GRU: { months: DEFAULT_TRAVEL_MONTHS, lowUsdMin: 133, lowUsdMax: 160 },
  FLN: {
    months: COASTAL_SOUTH_TRAVEL_MONTHS,
    lowUsdMin: 150,
    lowUsdMax: 200,
    seasonalWarningKey: 'fln',
  },
  NVT: {
    months: COASTAL_SOUTH_TRAVEL_MONTHS,
    lowUsdMin: 160,
    lowUsdMax: 210,
    seasonalWarningKey: 'nvt',
  },
  CWB: { months: DEFAULT_TRAVEL_MONTHS, lowUsdMin: 170, lowUsdMax: 250 },
  GIG: {
    months: DEFAULT_TRAVEL_MONTHS,
    lowUsdMin: 150,
    lowUsdMax: 220,
    seasonalWarningKey: 'gig',
  },
  POA: { months: DEFAULT_TRAVEL_MONTHS, lowUsdMin: 140, lowUsdMax: 190 },
  CNF: { months: DEFAULT_TRAVEL_MONTHS, lowUsdMin: 175, lowUsdMax: 240 },
  SSA: { months: NORTHEAST_TRAVEL_MONTHS, lowUsdMin: 200, lowUsdMax: 280 },
  REC: { months: NORTHEAST_TRAVEL_MONTHS, lowUsdMin: 210, lowUsdMax: 290 },
  FOR: { months: NORTHEAST_TRAVEL_MONTHS, lowUsdMin: 210, lowUsdMax: 300 },
  NAT: { months: NORTHEAST_TRAVEL_MONTHS, lowUsdMin: 220, lowUsdMax: 310 },
  JPA: { months: NORTHEAST_TRAVEL_MONTHS, lowUsdMin: 215, lowUsdMax: 295 },
  AJU: { months: NORTHEAST_TRAVEL_MONTHS, lowUsdMin: 205, lowUsdMax: 285 },
  MCZ: { months: NORTHEAST_TRAVEL_MONTHS, lowUsdMin: 215, lowUsdMax: 300 },
  CGR: { months: DEFAULT_TRAVEL_MONTHS, lowUsdMin: 165, lowUsdMax: 235 },
  MAO: {
    months: NORTH_TRAVEL_MONTHS,
    lowUsdMin: 260,
    lowUsdMax: 360,
    seasonalWarningKey: 'mao',
  },
  BEL: {
    months: NORTH_TRAVEL_MONTHS,
    lowUsdMin: 250,
    lowUsdMax: 340,
    seasonalWarningKey: 'bel',
  },
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
    const city = resolvedCityId
      ? await this.safeGetCityById(resolvedCityId)
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
          city,
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
    city: CityCardEntity | null,
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
          city,
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
    city: CityCardEntity | null,
  ): string {
    const liveCityName = city?.name ?? cityName;
    const cityReference = liveCityName ?? this.genericDestinationLabel(locale);
    const seasonalityMonths = this.resolveSeasonalityLowMonths(city, cityId);
    const cheapestFlightMonths = this.resolveCheapestFlightMonths(cityId);
    const arrivalWindow = this.bestArrivalWindow(
      seasonalityMonths,
      cheapestFlightMonths,
    );
    const planningNote = this.bestTimePlanningNote(locale, currentPhase);
    const cityPressureNote = this.cityPressureNote(locale, cityReference, city);
    const flightNote = this.flightWindowNote(
      locale,
      cheapestFlightMonths,
      cityId,
    );
    const arrivalWindowLabel = this.joinMonths(
      arrivalWindow.map((month) => this.monthLabel(month, locale)),
      locale,
    );

    if (locale === 'es') {
      return `Si tu ciudad base es ${cityReference}, la mejor ventana suele ser ${arrivalWindowLabel}. ${cityPressureNote} ${flightNote} ${planningNote}`;
    }
    if (locale === 'en') {
      return `If your base city is ${cityReference}, the best arrival window is usually ${arrivalWindowLabel}. ${cityPressureNote} ${flightNote} ${planningNote}`;
    }
    return `Se a sua cidade base é ${cityReference}, a melhor janela costuma ser ${arrivalWindowLabel}. ${cityPressureNote} ${flightNote} ${planningNote}`;
  }

  private resolveSeasonalityLowMonths(
    city: CityCardEntity | null,
    cityId: string | null,
  ): number[] {
    const fromSnapshot = city?.seasonalitySnapshot?.lowMonths ?? [];
    if (fromSnapshot.length > 0) {
      return fromSnapshot;
    }

    const seasonalProfile = cityId
      ? CITY_TO_SEASONALITY_PROFILE[cityId] ?? 'default'
      : 'default';
    return LOW_MONTHS_BY_PROFILE[seasonalProfile];
  }

  private resolveCheapestFlightMonths(cityId: string | null): number[] {
    const iata = cityId ? CITY_TO_IATA[cityId] : null;
    if (!iata) {
      return [];
    }

    const profile = DESTINATION_TRAVEL_PROFILES[iata];
    if (!profile) {
      return [];
    }

    return profile.months
      .map((level, index) => ({ level, month: index + 1 }))
      .filter((item) => item.level === 'low')
      .map((item) => item.month);
  }

  private bestArrivalWindow(
    seasonalityMonths: number[],
    cheapestFlightMonths: number[],
  ): number[] {
    if (seasonalityMonths.length === 0 && cheapestFlightMonths.length === 0) {
      return [4, 5, 9, 10];
    }

    if (seasonalityMonths.length === 0) {
      return cheapestFlightMonths;
    }

    if (cheapestFlightMonths.length === 0) {
      return seasonalityMonths;
    }

    const cheapestSet = new Set(cheapestFlightMonths);
    const overlap = seasonalityMonths.filter((month) => cheapestSet.has(month));
    return overlap.length > 0 ? overlap : seasonalityMonths;
  }

  private cityPressureNote(
    locale: GuidanceLocale,
    cityReference: string,
    city: CityCardEntity | null,
  ): string {
    const snapshot = city?.seasonalitySnapshot;
    if (snapshot) {
      const rentNote =
        locale === 'es'
          ? snapshot.rentNotesEs
          : locale === 'en'
            ? snapshot.rentNotesEn
            : snapshot.rentNotesPt;
      return rentNote;
    }

    const profile = city?.id
      ? CITY_TO_SEASONALITY_PROFILE[city.id] ?? 'default'
      : 'default';
    return this.climateNote(profile, locale, cityReference);
  }

  private flightWindowNote(
    locale: GuidanceLocale,
    cheapestFlightMonths: number[],
    cityId: string | null,
  ): string {
    if (cheapestFlightMonths.length === 0) {
      if (locale === 'es') {
        return 'Sin ciudad definida, la referencia de pasajes todavía es más genérica.';
      }
      if (locale === 'en') {
        return 'Without a defined city, flight timing stays more generic.';
      }
      return 'Sem cidade definida, a referência de passagem ainda fica mais genérica.';
    }

    const iata = cityId ? CITY_TO_IATA[cityId] : null;
    const profile = iata ? DESTINATION_TRAVEL_PROFILES[iata] : null;
    const warning = profile?.seasonalWarningKey
      ? this.flightWarning(locale, profile.seasonalWarningKey)
      : null;

    const cheapestWindowLabel = this.joinMonths(
      cheapestFlightMonths.map((month) => this.monthLabel(month, locale)),
      locale,
    );

    if (locale === 'es') {
      return `En vuelo, ${cheapestWindowLabel} suele ser la ventana más liviana. ${warning ?? ''}`.trim();
    }
    if (locale === 'en') {
      return `For flights, ${cheapestWindowLabel} is usually the lightest window. ${warning ?? ''}`.trim();
    }
    return `Na passagem, ${cheapestWindowLabel} costuma ser a janela mais leve. ${warning ?? ''}`.trim();
  }

  private flightWarning(
    locale: GuidanceLocale,
    key: string,
  ): string | null {
    switch (key) {
      case 'fln':
        return locale === 'es'
          ? 'Florianópolis suele tener menos vuelos directos fuera de marzo-abril.'
          : locale === 'en'
            ? 'Florianopolis usually has fewer direct flights outside Mar-Apr.'
            : 'Florianópolis costuma ter menos voos diretos fora de mar-abr.';
      case 'nvt':
        return locale === 'es'
          ? 'Navegantes reacciona bastante a verano y feriados largos.'
          : locale === 'en'
            ? 'Navegantes reacts strongly to summer peaks and long holidays.'
            : 'Navegantes reage bastante ao verão e aos feriados longos.';
      case 'gig':
        return locale === 'es'
          ? 'Febrero suele concentrar la alta más fuerte por Carnaval.'
          : locale === 'en'
            ? 'February usually concentrates the strongest peak because of Carnival.'
            : 'Fevereiro costuma concentrar a alta mais forte por causa do Carnaval.';
      case 'mao':
        return locale === 'es'
          ? 'Manaos conviene cruzarla con la ventana de lluvias antes de emitir.'
          : locale === 'en'
            ? 'For Manaus, cross-check the rainiest window before issuing tickets.'
            : 'Para Manaus, vale cruzar isso com a janela de chuvas antes de emitir.';
      case 'bel':
        return locale === 'es'
          ? 'Belém también conviene mirarla junto con la estacionalidad de lluvias.'
          : locale === 'en'
            ? 'For Belem, also check the local rainy season before locking dates.'
            : 'Para Belém, também vale olhar a sazonalidade de chuvas antes de fechar.';
      default:
        return null;
    }
  }

  private async safeGetCityById(cityId: string): Promise<CityCardEntity | null> {
    try {
      return await this.citiesCatalogService.getCityById(cityId);
    } catch {
      return null;
    }
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
