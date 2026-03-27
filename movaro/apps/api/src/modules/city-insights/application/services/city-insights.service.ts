import { Injectable, Logger } from '@nestjs/common';

import { AppConfigService } from '../../../../common/config/app-config.service';
import { AppErrorFactory } from '../../../../common/errors/app-error.factory';
import { SupabaseAdminService } from '../../../../common/supabase/supabase-admin.service';
import { CitiesCatalogService } from '../../../cities/application/services/cities-catalog.service';
import { CityInsightExplorePlaceEntity } from '../../domain/entities/city-insight-explore-place.entity';
import {
  CityInsightEntity,
  CityInsightSource,
  CityInsightTheme,
  CityInsightType,
} from '../../domain/entities/city-insight.entity';

type InsightLocale = 'pt' | 'es' | 'en';

interface GetInsightsInput {
  cityId: string;
  goal?: string;
  timeline?: string;
  locale?: string;
  limit: number;
}

interface CachedInsightPayload {
  payload: CityInsightEntity[];
  expiresAt: number;
}

interface GetExplorePlacesInput {
  cityId: string;
  theme: string;
  locale?: string;
  seedPlace?: string;
  limit: number;
}

interface CachedExplorePayload {
  payload: CityInsightExplorePlaceEntity[];
  expiresAt: number;
}

interface CachedWebPlaceContextPayload {
  payload: WebPlaceContext | null;
  expiresAt: number;
}

interface CachedWebThemeSuggestionsPayload {
  payload: string[];
  expiresAt: number;
}

interface WebSearchResult {
  title: string;
  snippet?: string;
  url: string;
}

interface WebPlaceContext {
  title?: string;
  shortText?: string;
  imageUrl?: string;
  sourceUrl?: string;
}

interface OverpassElement {
  type: string;
  id: number;
  lat?: number;
  lon?: number;
  center?: {
    lat: number;
    lon: number;
  };
  tags?: Record<string, string>;
}

interface CuratedInsightSeed {
  type: CityInsightType;
  theme: CityInsightTheme;
  title: Record<InsightLocale, string>;
  shortText: Record<InsightLocale, string>;
  content: Record<InsightLocale, string>;
  placeHighlights?: string[];
  ctaLabel?: Record<InsightLocale, string>;
}

interface CityInsightCityProfile {
  kind: 'coastal' | 'metropolis' | 'border' | 'inland';
  preferredThemes: CityInsightTheme[];
  avoidedThemes: CityInsightTheme[];
}

const GROQ_ENDPOINT = 'https://api.groq.com/openai/v1/chat/completions';
const GROQ_MODEL = 'llama-3.3-70b-versatile';
const GEMINI_ENDPOINT =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
const OVERPASS_ENDPOINT = 'https://overpass-api.de/api/interpreter';
const WIKIPEDIA_API_BASE = 'https://wikipedia.org/w/api.php';
const WIKIMEDIA_COMMONS_API_BASE = 'https://commons.wikimedia.org/w/api.php';

const CITY_IMAGE_URLS: Record<string, string> = {
  'rio-de-janeiro-rj':
    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Cidade_Maravilhosa.jpg/640px-Cidade_Maravilhosa.jpg',
  'sao-paulo-sp':
    'https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Marginal_Pinheiros_e_Jockey_Club.jpg/640px-Marginal_Pinheiros_e_Jockey_Club.jpg',
  'florianopolis-sc':
    'https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Morro_da_Cruz%2C_Florian%C3%B3polis_-_SC%2C_Brazil_-_panoramio_%28cropped%29.jpg/640px-Morro_da_Cruz%2C_Florian%C3%B3polis_-_SC%2C_Brazil_-_panoramio_%28cropped%29.jpg',
  'niteroi-rj':
    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Museu_de_Arte_Contempor%C3%A2nea_by_Diego_Baravelli.jpg/640px-Museu_de_Arte_Contempor%C3%A2nea_by_Diego_Baravelli.jpg',
};

const COASTAL_CITY_BASE_IDS = new Set<string>([
  'florianopolis',
  'rio-de-janeiro',
  'armacao-dos-buzios',
  'arraial-do-cabo',
  'cabo-frio',
  'niteroi',
  'balneario-camboriu',
  'bombinhas',
  'maceio',
  'maragogi',
  'joao-pessoa',
  'recife',
  'natal',
  'aracaju',
  'salvador',
  'porto-seguro',
  'santos',
  'ubatuba',
  'paraty',
  'tibau-do-sul',
  'jijoca-de-jericoacoara',
  'ilhabela',
  'guaruja',
  'garopaba',
  'imbituba',
  'itacare',
  'sao-miguel-do-gostoso',
  'cairu',
  'itajai',
]);

const BORDER_CITY_BASE_IDS = new Set<string>(['foz-do-iguacu']);

const CURATED_CITY_INSIGHTS: Record<string, CuratedInsightSeed[]> = {
  'rio-de-janeiro-rj': [
    {
      type: CityInsightType.Lifestyle,
      theme: CityInsightTheme.Beaches,
      title: {
        pt: 'Entre natureza e rotina urbana',
        es: 'Entre naturaleza y rutina urbana',
        en: 'Between nature and city routine',
      },
      shortText: {
        pt: 'No Rio, praia, trilha e trabalho convivem no mesmo ritmo da cidade.',
        es: 'En Río, playa, senderos y trabajo conviven en la misma rutina.',
        en: 'In Rio, beach, trails, and work share the same daily rhythm.',
      },
      content: {
        pt: 'Viver no Rio costuma significar equilibrar deslocamentos urbanos com momentos ao ar livre. Muitos moradores organizam a semana pensando em praia, parques e bairros com vida de rua ativa.',
        es: 'Vivir en Río suele significar equilibrar los desplazamientos urbanos con momentos al aire libre. Muchas personas organizan su semana entre playa, parques y barrios con vida en la calle.',
        en: 'Living in Rio often means balancing urban commutes with time outdoors. Many residents shape the week around beaches, parks, and neighborhoods with active street life.',
      },
      placeHighlights: ['Copacabana', 'Ipanema', 'Arpoador', 'Prainha'],
      ctaLabel: {
        pt: 'Explorar cidade',
        es: 'Explorar ciudad',
        en: 'Explore city',
      },
    },
    {
      type: CityInsightType.CostOfLiving,
      theme: CityInsightTheme.LocalRoutine,
      title: {
        pt: 'O custo varia muito por bairro',
        es: 'El costo cambia mucho según el barrio',
        en: 'Costs shift sharply by neighborhood',
      },
      shortText: {
        pt: 'A mesma cidade pode parecer acessível ou pesada dependendo da zona escolhida.',
        es: 'La misma ciudad puede sentirse accesible o pesada según la zona elegida.',
        en: 'The same city can feel affordable or heavy depending on the area you choose.',
      },
      content: {
        pt: 'Na prática, aluguel e transporte definem grande parte do orçamento inicial. Bairros mais conectados e próximos da orla tendem a exigir reserva maior, enquanto áreas fora do circuito turístico podem aliviar o custo mensal.',
        es: 'En la práctica, alquiler y transporte definen gran parte del presupuesto inicial. Las zonas más conectadas y cercanas a la costa suelen exigir más reserva.',
        en: 'In practice, rent and transport define much of your starting budget. Better-connected areas near the shoreline usually require a larger financial buffer.',
      },
      ctaLabel: {
        pt: 'Ver custo detalhado',
        es: 'Ver costo detallado',
        en: 'See detailed costs',
      },
    },
    {
      type: CityInsightType.Housing,
      theme: CityInsightTheme.Neighborhoods,
      title: {
        pt: 'Comece por bairros com rotina clara',
        es: 'Empieza por barrios con rutina clara',
        en: 'Start with neighborhoods that fit your routine',
      },
      shortText: {
        pt: 'Antes de fechar moradia, vale comparar tempo de deslocamento, comércio e sensação de segurança.',
        es: 'Antes de cerrar vivienda, conviene comparar traslado, comercio y sensación de seguridad.',
        en: 'Before choosing housing, compare commute time, local commerce, and everyday safety.',
      },
      content: {
        pt: 'Zona Sul, Barra e bairros residenciais da Zona Norte entregam experiências bem diferentes. O melhor ponto de entrada depende do seu orçamento, da necessidade de transporte e do tipo de rotina que você imagina construir.',
        es: 'Zona Sul, Barra y barrios residenciales de la Zona Norte ofrecen experiencias muy distintas. El mejor punto de entrada depende de presupuesto y rutina.',
        en: 'Zona Sul, Barra, and residential areas in Zona Norte offer very different experiences. The right starting point depends on budget and the routine you want to build.',
      },
      placeHighlights: [
        'Botafogo',
        'Flamengo',
        'Barra da Tijuca',
        'Laranjeiras',
      ],
      ctaLabel: {
        pt: 'Ver bairros',
        es: 'Ver barrios',
        en: 'See neighborhoods',
      },
    },
    {
      type: CityInsightType.Motivation,
      theme: CityInsightTheme.Parks,
      title: {
        pt: 'Uma cidade que recompensa presença',
        es: 'Una ciudad que recompensa la presencia',
        en: 'A city that rewards presence',
      },
      shortText: {
        pt: 'Quando a decisão encaixa no seu estilo de vida, o Rio tende a reforçar a sensação de escolha certa.',
        es: 'Cuando la decisión encaja con tu estilo de vida, Río refuerza la sensación de haber elegido bien.',
        en: 'When the move matches your lifestyle, Rio reinforces the feeling that you chose well.',
      },
      content: {
        pt: 'O apelo do Rio não está só nos cartões-postais. Para muita gente, a cidade funciona como lembrete diário do porquê mudar: clima, paisagem, cultura e uma rotina que parece mais viva.',
        es: 'El atractivo de Río no está solo en las postales. Para muchas personas, la ciudad recuerda a diario por qué valió la pena cambiar.',
        en: 'Rio is not only about postcard views. For many people, the city becomes a daily reminder of why the move felt worth it.',
      },
      placeHighlights: [
        'Parque Lage',
        'Jardim Botânico',
        'Aterro do Flamengo',
        'Vista Chinesa',
      ],
      ctaLabel: {
        pt: 'Explorar cidade',
        es: 'Explorar ciudad',
        en: 'Explore city',
      },
    },
    {
      type: CityInsightType.Lifestyle,
      theme: CityInsightTheme.Nightlife,
      title: {
        pt: 'Noite com sensação de cidade viva',
        es: 'Noche con sensación de ciudad viva',
        en: 'A nightlife rhythm that makes the city feel alive',
      },
      shortText: {
        pt: 'Bares, música e rua cheia ajudam a imaginar um sábado que já parece seu.',
        es: 'Bares, música y calles llenas ayudan a imaginar un sábado que ya parece tuyo.',
        en: 'Bars, music, and busy streets help you picture a Saturday that already feels yours.',
      },
      content: {
        pt: 'Parte do desejo de morar no Rio vem da vida fora do expediente. Lugares com mesa na calçada, música e vista para a rua ajudam a transformar a cidade em rotina, não só em cenário.',
        es: 'Parte del deseo de vivir en Río nace fuera del horario de trabajo. Los lugares con mesas en la vereda, música y movimiento convierten la ciudad en rutina, no solo en postal.',
        en: "Part of Rio's pull comes after work. Streets with bars, music, and outdoor tables help the city feel like routine, not just scenery.",
      },
      placeHighlights: ['Lapa', 'Botafogo', 'Baixo Gávea', 'Leblon'],
      ctaLabel: {
        pt: 'Ver onde sair',
        es: 'Ver dónde salir',
        en: 'See where to go out',
      },
    },
    {
      type: CityInsightType.PracticalTip,
      theme: CityInsightTheme.CultureAndEvents,
      title: {
        pt: 'Agenda cultural ajuda a cidade a virar hábito',
        es: 'La agenda cultural ayuda a que la ciudad se vuelva hábito',
        en: 'A cultural agenda helps the city become a habit',
      },
      shortText: {
        pt: 'Museus, shows e centros culturais dão assunto novo para voltar ao app.',
        es: 'Museos, shows y centros culturales dan nuevos motivos para volver a la app.',
        en: 'Museums, shows, and cultural venues create fresh reasons to come back.',
      },
      content: {
        pt: 'Quando a cidade oferece sempre um próximo lugar para descobrir, a mudança fica emocionalmente ativa. O Rio tem circuitos culturais que ajudam a manter esse sentimento de exploração.',
        es: 'Cuando la ciudad siempre ofrece un próximo lugar por descubrir, la mudanza se mantiene emocionalmente activa. Río tiene circuitos culturales que sostienen esa sensación.',
        en: 'When a city always offers one more place to discover, the move stays emotionally active. Rio has cultural circuits that keep that feeling alive.',
      },
      placeHighlights: [
        'Museu do Amanhã',
        'MAR',
        'Theatro Municipal',
        'Circo Voador',
      ],
      ctaLabel: {
        pt: 'Ver agenda',
        es: 'Ver agenda',
        en: 'See agenda',
      },
    },
  ],
  'sao-paulo-sp': [
    {
      type: CityInsightType.Work,
      theme: CityInsightTheme.Neighborhoods,
      title: {
        pt: 'São Paulo favorece começo com estrutura',
        es: 'São Paulo favorece un inicio con estructura',
        en: 'Sao Paulo favors a structured start',
      },
      shortText: {
        pt: 'Para quem prioriza trabalho e serviços, a cidade costuma acelerar os primeiros meses.',
        es: 'Para quien prioriza trabajo y servicios, la ciudad suele acelerar los primeros meses.',
        en: 'For people prioritizing work and services, the city often accelerates the first months.',
      },
      content: {
        pt: 'São Paulo concentra empresas, transporte, bairros com perfis distintos e mais opções para organizar documentação, banco e adaptação. É uma cidade exigente, mas costuma reduzir atrito operacional.',
        es: 'São Paulo concentra empresas, transporte y barrios con perfiles distintos. Es exigente, pero reduce fricción operativa al comenzar.',
        en: 'Sao Paulo concentrates companies, transit, and neighborhoods with different profiles. It is demanding, but it often reduces operational friction at the start.',
      },
      placeHighlights: ['Pinheiros', 'Vila Mariana', 'Perdizes', 'Tatuapé'],
      ctaLabel: {
        pt: 'Explorar cidade',
        es: 'Explorar ciudad',
        en: 'Explore city',
      },
    },
    {
      type: CityInsightType.CostOfLiving,
      theme: CityInsightTheme.LocalRoutine,
      title: {
        pt: 'Planejamento financeiro pesa mais aqui',
        es: 'La planificación financiera pesa más aquí',
        en: 'Financial planning matters more here',
      },
      shortText: {
        pt: 'Moradia e deslocamento podem subir rápido se a escolha inicial não for calibrada.',
        es: 'Vivienda y traslado pueden subir rápido si la elección inicial no está bien calibrada.',
        en: 'Housing and commuting can rise quickly if your first choice is not calibrated.',
      },
      content: {
        pt: 'Na capital paulista, morar perto do eixo de trabalho pode custar mais, mas economizar horas por semana. O equilíbrio ideal costuma vir de um bairro que segure custo sem isolar você da rotina principal.',
        es: 'En la capital paulista, vivir cerca del trabajo puede costar más, pero ahorra horas. El equilibrio suele estar en un barrio conectado sin aislarte.',
        en: 'In Sao Paulo, living near your work axis may cost more but save hours every week. The best balance often comes from a connected neighborhood that still protects your budget.',
      },
      ctaLabel: {
        pt: 'Ver custo detalhado',
        es: 'Ver costo detallado',
        en: 'See detailed costs',
      },
    },
    {
      type: CityInsightType.Housing,
      theme: CityInsightTheme.Neighborhoods,
      title: {
        pt: 'Bairro certo muda toda a experiência',
        es: 'El barrio correcto cambia toda la experiencia',
        en: 'The right neighborhood changes everything',
      },
      shortText: {
        pt: 'Pinheiros, Vila Mariana, Tatuapé ou Saúde entregam rotinas muito diferentes.',
        es: 'Pinheiros, Vila Mariana, Tatuapé o Saúde ofrecen rutinas muy distintas.',
        en: 'Pinheiros, Vila Mariana, Tatuape, and Saude offer very different routines.',
      },
      content: {
        pt: 'Em São Paulo, a escolha do bairro define deslocamento, orçamento e sensação de pertencimento. Vale começar por regiões com metrô, comércio de base e acesso razoável ao seu objetivo principal.',
        es: 'En São Paulo, elegir barrio define traslado, presupuesto y pertenencia. Conviene empezar por zonas con metro y comercio básico.',
        en: 'In Sao Paulo, the neighborhood defines commute, budget, and sense of belonging. A good start is an area with metro access and everyday commerce.',
      },
      placeHighlights: ['Parque Ibirapuera', 'Parque Villa-Lobos', 'Paulista'],
      ctaLabel: {
        pt: 'Ver bairros',
        es: 'Ver barrios',
        en: 'See neighborhoods',
      },
    },
    {
      type: CityInsightType.PracticalTip,
      theme: CityInsightTheme.FoodAndCafes,
      title: {
        pt: 'Comece com rotina compacta',
        es: 'Empieza con una rutina compacta',
        en: 'Start with a compact routine',
      },
      shortText: {
        pt: 'Nos primeiros meses, menos deslocamento costuma significar mais energia para adaptação.',
        es: 'En los primeros meses, menos traslado suele significar más energía para adaptarte.',
        en: 'In the first months, less commuting usually means more energy for adaptation.',
      },
      content: {
        pt: 'Se puder, concentre moradia, trabalho e serviços essenciais em um mesmo eixo. Em São Paulo, essa decisão simples tende a reduzir desgaste e tornar a cidade muito mais sustentável no dia a dia.',
        es: 'Si puedes, concentra vivienda, trabajo y servicios esenciales en un mismo eje. Esa decisión reduce desgaste al principio.',
        en: 'If possible, keep housing, work, and essential services on the same axis. In Sao Paulo, that simple decision often makes daily life much more sustainable.',
      },
      placeHighlights: [
        'Vila Madalena',
        'Rua dos Pinheiros',
        'Beco do Batman',
        'Paulista',
      ],
    },
    {
      type: CityInsightType.Lifestyle,
      theme: CityInsightTheme.Parks,
      title: {
        pt: 'Respiro urbano também entra no sonho paulistano',
        es: 'El respiro urbano también entra en el sueño paulista',
        en: 'Urban breathing room is part of the Sao Paulo dream too',
      },
      shortText: {
        pt: 'Parques bons mudam a percepção da rotina e fazem a cidade render melhor.',
        es: 'Los buenos parques cambian la percepción de la rutina y hacen rendir mejor la ciudad.',
        en: 'Good parks change how daily life feels and make the city easier to enjoy.',
      },
      content: {
        pt: 'São Paulo não retém só pela oportunidade. Ela também prende quando você encontra lugares para caminhar, ler, correr ou simplesmente diminuir o ritmo no meio da semana.',
        es: 'São Paulo no retiene solo por oportunidad. También engancha cuando encuentras lugares para caminar, leer, correr o bajar el ritmo en la semana.',
        en: 'Sao Paulo does not retain people only through opportunity. It also clicks when you find places to walk, read, run, or slow down midweek.',
      },
      placeHighlights: [
        'Parque Ibirapuera',
        'Parque Villa-Lobos',
        'Parque da Aclimação',
        'Praça Pôr do Sol',
      ],
      ctaLabel: {
        pt: 'Ver parques',
        es: 'Ver parques',
        en: 'See parks',
      },
    },
    {
      type: CityInsightType.Motivation,
      theme: CityInsightTheme.CultureAndEvents,
      title: {
        pt: 'Sempre tem algo acontecendo em São Paulo',
        es: 'Siempre pasa algo en São Paulo',
        en: 'There is always something happening in Sao Paulo',
      },
      shortText: {
        pt: 'Agenda, exposições e bairros criativos ajudam a cidade a nunca ficar plana.',
        es: 'Agenda, exposiciones y barrios creativos ayudan a que la ciudad nunca se sienta plana.',
        en: 'Agenda, exhibitions, and creative neighborhoods keep the city from ever feeling flat.',
      },
      content: {
        pt: 'Uma parte forte do vínculo com São Paulo nasce da abundância: uma mostra nova, um show, um café diferente, um bairro para explorar no fim de semana. Isso sustenta o desejo de ficar.',
        es: 'Una parte fuerte del vínculo con São Paulo nace de la abundancia: una muestra nueva, un show, un café distinto, un barrio para explorar el fin de semana.',
        en: "Part of Sao Paulo's pull comes from abundance: a new exhibit, a show, a different cafe, a neighborhood to explore on the weekend. That sustains the desire to stay.",
      },
      placeHighlights: [
        'MASP',
        'Liberdade',
        'Sesc Pompeia',
        'Avenida Paulista',
      ],
      ctaLabel: {
        pt: 'Ver agenda',
        es: 'Ver agenda',
        en: 'See agenda',
      },
    },
  ],
  'florianopolis-sc': [
    {
      type: CityInsightType.Lifestyle,
      theme: CityInsightTheme.Beaches,
      title: {
        pt: 'Rotina com mais respiro e natureza',
        es: 'Rutina con más aire y naturaleza',
        en: 'A routine with more breathing room and nature',
      },
      shortText: {
        pt: 'Florianópolis costuma atrair quem quer trabalhar bem sem abrir mão de mar e ritmo mais leve.',
        es: 'Florianópolis atrae a quien quiere trabajar bien sin soltar el mar y un ritmo más liviano.',
        en: 'Florianopolis attracts people who want solid work life without giving up the sea and a lighter rhythm.',
      },
      content: {
        pt: 'A cidade mistura polos urbanos, praias e bairros residenciais com sensação de refúgio. Para muita gente, esse equilíbrio torna a mudança mais sustentável emocionalmente.',
        es: 'La ciudad mezcla polos urbanos, playas y barrios residenciales con sensación de refugio. Ese equilibrio ayuda a sostener la mudanza.',
        en: 'The city blends urban hubs, beaches, and residential neighborhoods with a sense of retreat. For many people, that balance makes the move easier to sustain.',
      },
      placeHighlights: [
        'Praia Mole',
        'Campeche',
        'Joaquina',
        'Lagoinha do Leste',
      ],
      ctaLabel: {
        pt: 'Explorar cidade',
        es: 'Explorar ciudad',
        en: 'Explore city',
      },
    },
    {
      type: CityInsightType.Housing,
      theme: CityInsightTheme.Neighborhoods,
      title: {
        pt: 'Escolha a ilha pelo seu deslocamento',
        es: 'Elige la isla según tu traslado',
        en: 'Choose your area by commute, not only scenery',
      },
      shortText: {
        pt: 'Lagoa, Campeche, Centro e Continente podem parecer próximos, mas geram rotinas bem diferentes.',
        es: 'Lagoa, Campeche, Centro y Continente pueden parecer cercanos, pero cambian mucho la rutina.',
        en: 'Lagoa, Campeche, Centro, and Continente may look close, but they create very different routines.',
      },
      content: {
        pt: 'Em Floripa, trânsito sazonal e distância entre regiões pesam mais do que parece no mapa. Antes de decidir, vale imaginar seus trajetos de trabalho, mercado e vida social.',
        es: 'En Floripa, el tránsito estacional y la distancia entre zonas pesan más de lo que parece en el mapa.',
        en: 'In Floripa, seasonal traffic and distance between regions matter more than the map suggests. Picture your work, grocery, and social routes before deciding.',
      },
      placeHighlights: [
        'Campeche',
        'Lagoa da Conceição',
        'Itacorubi',
        'Centro',
      ],
      ctaLabel: {
        pt: 'Ver bairros',
        es: 'Ver barrios',
        en: 'See neighborhoods',
      },
    },
    {
      type: CityInsightType.CostOfLiving,
      theme: CityInsightTheme.LocalRoutine,
      title: {
        pt: 'A qualidade de vida cobra seleção',
        es: 'La calidad de vida exige selección',
        en: 'Quality of life comes with selective costs',
      },
      shortText: {
        pt: 'Dependendo da temporada e da região, aluguel e mobilidade sobem com facilidade.',
        es: 'Según la temporada y la zona, alquiler y movilidad pueden subir con facilidad.',
        en: 'Depending on season and area, rent and mobility can rise quickly.',
      },
      content: {
        pt: 'Florianópolis pode funcionar muito bem com um planejamento enxuto, mas exige cuidado na escolha do bairro e no formato da rotina. O ganho costuma vir em bem-estar e sensação de estabilidade.',
        es: 'Florianópolis puede funcionar muy bien con un plan ajustado, pero exige cuidado en el barrio y la rutina.',
        en: 'Florianopolis can work very well with a lean plan, but it demands care in neighborhood choice and routine design. The payoff is usually quality of life and stability.',
      },
      ctaLabel: {
        pt: 'Ver custo detalhado',
        es: 'Ver costo detallado',
        en: 'See detailed costs',
      },
    },
    {
      type: CityInsightType.Motivation,
      theme: CityInsightTheme.Viewpoints,
      title: {
        pt: 'Uma cidade que ajuda a imaginar permanência',
        es: 'Una ciudad que ayuda a imaginar permanencia',
        en: 'A city that makes long-term life easier to imagine',
      },
      shortText: {
        pt: 'Quando a cidade encaixa no estilo de vida desejado, fica mais fácil sustentar a decisão ao longo do tempo.',
        es: 'Cuando la ciudad encaja con el estilo de vida deseado, es más fácil sostener la decisión con el tiempo.',
        en: 'When the city matches the life you want, it becomes easier to sustain the decision over time.',
      },
      content: {
        pt: 'Florianópolis costuma gerar uma visualização forte de futuro: rotina perto da natureza, sensação de segurança relativa e um dia a dia menos acelerado do que grandes capitais.',
        es: 'Florianópolis suele generar una imagen fuerte de futuro: rutina cerca de la naturaleza y un día a día menos acelerado.',
        en: 'Florianopolis often creates a strong future-life picture: routine near nature, relative safety, and a slower pace than larger capitals.',
      },
      placeHighlights: [
        'Lagoa da Conceição',
        'Santo Antônio de Lisboa',
        'Beira-Mar Norte',
        'Parque da Luz',
      ],
      ctaLabel: {
        pt: 'Explorar cidade',
        es: 'Explorar ciudad',
        en: 'Explore city',
      },
    },
    {
      type: CityInsightType.PracticalTip,
      theme: CityInsightTheme.FoodAndCafes,
      title: {
        pt: 'Café, mercado e fim de tarde contam muito aqui',
        es: 'Café, mercado y fin de tarde cuentan mucho aquí',
        en: 'Cafes, markets, and late afternoons matter here',
      },
      shortText: {
        pt: 'Parte do encanto de Floripa aparece nos pequenos rituais entre trabalho e mar.',
        es: 'Parte del encanto de Floripa aparece en los pequeños rituales entre trabajo y mar.',
        en: "Part of Floripa's charm shows up in small rituals between work and the sea.",
      },
      content: {
        pt: 'Quem fica em Floripa costuma se apegar a hábitos simples: café com vista, mercado perto de casa e um fim de tarde que convida a desacelerar. Esses detalhes fazem a cidade parecer vivível.',
        es: 'Quien se queda en Floripa suele apegarse a hábitos simples: café con vista, mercado cerca de casa y un fin de tarde que invita a bajar el ritmo.',
        en: 'People who stay in Floripa often bond with simple habits: a cafe with a view, a market near home, and late afternoons that invite you to slow down. Those details make the city feel livable.',
      },
      placeHighlights: [
        'Mercado Público',
        'Lagoa da Conceição',
        'Santo Antônio de Lisboa',
        'Beira-Mar Norte',
      ],
      ctaLabel: {
        pt: 'Ver rotina local',
        es: 'Ver rutina local',
        en: 'See local routine',
      },
    },
    {
      type: CityInsightType.Lifestyle,
      theme: CityInsightTheme.Parks,
      title: {
        pt: 'Trilhas e parques fazem parte da vida normal',
        es: 'Senderos y parques forman parte de la vida normal',
        en: 'Trails and parks are part of normal life here',
      },
      shortText: {
        pt: 'A cidade retém mais quando você percebe que natureza não é evento, é rotina.',
        es: 'La ciudad retiene más cuando percibes que la naturaleza no es evento, sino rutina.',
        en: 'The city becomes more magnetic when nature feels routine, not special occasion.',
      },
      content: {
        pt: 'Em Floripa, muita gente mede qualidade de vida pela facilidade de encaixar trilha, praia ou parque no meio da semana. Isso cria uma imagem forte de vida possível.',
        es: 'En Floripa, mucha gente mide la calidad de vida por la facilidad de sumar senderos, playa o parque en la semana.',
        en: 'In Floripa, many people measure quality of life by how easily they can fit a trail, a beach, or a park into the week. That creates a strong picture of possible life.',
      },
      placeHighlights: [
        'Parque da Luz',
        'Lagoinha do Leste',
        'Joaquina',
        'Morro da Cruz',
      ],
      ctaLabel: {
        pt: 'Ver trilhas e parques',
        es: 'Ver senderos y parques',
        en: 'See trails and parks',
      },
    },
  ],
};

@Injectable()
export class CityInsightsService {
  private readonly logger = new Logger(CityInsightsService.name);
  private readonly memoryCache = new Map<string, CachedInsightPayload>();
  private readonly exploreMemoryCache = new Map<string, CachedExplorePayload>();
  private readonly webPlaceContextCache = new Map<
    string,
    CachedWebPlaceContextPayload
  >();
  private readonly webThemeSuggestionsCache = new Map<
    string,
    CachedWebThemeSuggestionsPayload
  >();
  private readonly wikipediaImageCache = new Map<string, string | null>();
  private readonly commonsImageCache = new Map<string, string | null>();
  private readonly cacheTtlMs = 1000 * 60 * 60 * 24;

  constructor(
    private readonly citiesCatalogService: CitiesCatalogService,
    private readonly appConfigService: AppConfigService,
    private readonly supabaseAdminService: SupabaseAdminService,
  ) {}

  async getExplorePlaces(
    input: GetExplorePlacesInput,
  ): Promise<CityInsightExplorePlaceEntity[]> {
    const resolvedCityId = this.citiesCatalogService.resolveCityId(
      input.cityId,
    );
    if (!resolvedCityId) {
      throw AppErrorFactory.cityNotFound(input.cityId);
    }

    if (!this.isCityInsightTheme(input.theme)) {
      throw AppErrorFactory.validationError('Invalid city insight theme.');
    }

    const city = await this.citiesCatalogService.getCityById(resolvedCityId);
    const locale = this.normalizeLocale(input.locale);
    const cacheKey = [
      city.id,
      input.theme,
      input.seedPlace ?? 'none',
      locale,
    ]
      .join('::')
      .toLowerCase();

    const cached = this.getCachedExplorePlaces(cacheKey);
    if (cached) {
      return cached.slice(0, input.limit);
    }

    try {
      const items = await this.fetchExplorePlacesFromOpenStreetMap({
        cityId: city.id,
        cityName: city.name,
        latitude: city.latitude,
        longitude: city.longitude,
        stateName: city.stateName,
        regionName: city.regionName ?? undefined,
        theme: input.theme,
        locale,
        limit: input.limit,
        seedPlace: input.seedPlace,
        population: city.population,
      });
      const filteredItems = input.seedPlace
        ? this.filterPlacesBySeedPlace(items, input.seedPlace)
        : items;
      if (filteredItems.length > 0) {
        this.storeExplorePlacesCache(cacheKey, filteredItems);
        return filteredItems.slice(0, input.limit);
      }
    } catch (error) {
      this.logger.warn(`City explore places fetch failed: ${String(error)}`);
    }

    const fallback = await this.buildExplorePlacesFallback({
      cityId: city.id,
      cityName: city.name,
      stateName: city.stateName,
      theme: input.theme,
      locale,
      seedPlace: input.seedPlace,
    });
    this.storeExplorePlacesCache(cacheKey, fallback);
    return fallback.slice(0, input.limit);
  }

  async getInsights(input: GetInsightsInput): Promise<CityInsightEntity[]> {
    const resolvedCityId = this.citiesCatalogService.resolveCityId(
      input.cityId,
    );
    if (!resolvedCityId) {
      throw AppErrorFactory.cityNotFound(input.cityId);
    }

    const city = await this.citiesCatalogService.getCityById(resolvedCityId);
    const locale = this.normalizeLocale(input.locale);
    const cacheKey = this.makeCacheKey({
      cityId: city.id,
      goal: input.goal,
      timeline: input.timeline,
      locale,
    });
    const cached = await this.getCached(cacheKey);
    if (cached) {
      return cached.slice(0, input.limit);
    }

    const curated = this.buildCuratedInsights({
      cityId: city.id,
      cityName: city.name,
      locale,
    });
    if (curated.length > 0) {
      const enrichedCurated = await this.enrichInsightsWithOpenDataPlaces(
        curated,
        {
          cityId: city.id,
          cityName: city.name,
          latitude: city.latitude,
          longitude: city.longitude,
          stateName: city.stateName,
          regionName: city.regionName ?? undefined,
          population: city.population,
          locale,
        },
      );
      const bannerReadyCurated = await this.orchestrateBannerReadyInsights(
        enrichedCurated,
        {
          cityId: city.id,
          cityName: city.name,
          stateName: city.stateName,
          locale,
          goal: input.goal,
          timeline: input.timeline,
        },
      );
      await this.storeCache(cacheKey, bannerReadyCurated, 'curated', {
        cityId: city.id,
        goal: input.goal,
        timeline: input.timeline,
        locale,
      });
      return bannerReadyCurated.slice(0, input.limit);
    }

    const generated = await this.generateInsights({
      cityId: city.id,
      cityName: city.name,
      stateName: city.stateName,
      regionName: city.regionName ?? undefined,
      population: city.population,
      goal: input.goal,
      timeline: input.timeline,
      locale,
    });
    if (generated.length > 0) {
      const enrichedGenerated = await this.enrichInsightsWithOpenDataPlaces(
        generated,
        {
          cityId: city.id,
          cityName: city.name,
          latitude: city.latitude,
          longitude: city.longitude,
          stateName: city.stateName,
          regionName: city.regionName ?? undefined,
          population: city.population,
          locale,
        },
      );
      const bannerReadyGenerated = await this.orchestrateBannerReadyInsights(
        enrichedGenerated,
        {
          cityId: city.id,
          cityName: city.name,
          stateName: city.stateName,
          locale,
          goal: input.goal,
          timeline: input.timeline,
        },
      );
      await this.storeCache(cacheKey, bannerReadyGenerated, 'generated', {
        cityId: city.id,
        goal: input.goal,
        timeline: input.timeline,
        locale,
      });
      return bannerReadyGenerated.slice(0, input.limit);
    }

    const templated = this.buildTemplateFallback({
      cityId: city.id,
      cityName: city.name,
      stateName: city.stateName,
      regionName: city.regionName ?? undefined,
      population: city.population,
      locale,
      goal: input.goal,
      timeline: input.timeline,
    });
    const enrichedTemplated = await this.enrichInsightsWithOpenDataPlaces(
      templated,
      {
        cityId: city.id,
        cityName: city.name,
        latitude: city.latitude,
        longitude: city.longitude,
        stateName: city.stateName,
        regionName: city.regionName ?? undefined,
        population: city.population,
        locale,
      },
    );
    const bannerReadyTemplated = await this.orchestrateBannerReadyInsights(
      enrichedTemplated,
      {
        cityId: city.id,
        cityName: city.name,
        stateName: city.stateName,
        locale,
        goal: input.goal,
        timeline: input.timeline,
      },
    );
    await this.storeCache(cacheKey, bannerReadyTemplated, 'template', {
      cityId: city.id,
      goal: input.goal,
      timeline: input.timeline,
      locale,
    });
    return bannerReadyTemplated.slice(0, input.limit);
  }

  private async getCached(
    cacheKey: string,
  ): Promise<CityInsightEntity[] | null> {
    const memoryHit = this.memoryCache.get(cacheKey);
    if (memoryHit && memoryHit.expiresAt > Date.now()) {
      return memoryHit.payload;
    }

    if (!this.supabaseAdminService.isConfigured) {
      return null;
    }

    try {
      const { data, error } = await this.supabaseAdminService.admin
        .from('city_insights_cache')
        .select('payload, expires_at')
        .eq('cache_key', cacheKey)
        .maybeSingle();
      if (error || !data?.payload || !data?.expires_at) {
        return null;
      }

      const expiresAt = new Date(data.expires_at).getTime();
      if (!Number.isFinite(expiresAt) || expiresAt <= Date.now()) {
        return null;
      }

      const payload = Array.isArray(data.payload)
        ? (data.payload as CityInsightEntity[])
        : null;
      if (!payload) {
        return null;
      }

      this.memoryCache.set(cacheKey, { payload, expiresAt });
      return payload;
    } catch (error) {
      this.logger.warn(`Supabase cache read failed: ${String(error)}`);
      return null;
    }
  }

  private async storeCache(
    cacheKey: string,
    payload: CityInsightEntity[],
    source: CityInsightSource,
    meta: {
      cityId: string;
      goal?: string;
      timeline?: string;
      locale: InsightLocale;
    },
  ): Promise<void> {
    const expiresAt = Date.now() + this.cacheTtlMs;
    this.memoryCache.set(cacheKey, { payload, expiresAt });

    if (!this.supabaseAdminService.isConfigured) {
      return;
    }

    try {
      const { error } = await this.supabaseAdminService.admin
        .from('city_insights_cache')
        .upsert({
          cache_key: cacheKey,
          city_id: meta.cityId,
          goal: meta.goal ?? null,
          timeline: meta.timeline ?? null,
          locale: meta.locale,
          source,
          payload,
          expires_at: new Date(expiresAt).toISOString(),
          updated_at: new Date().toISOString(),
        });
      if (error) {
        this.logger.warn(`Supabase cache write failed: ${error.message}`);
      }
    } catch (error) {
      this.logger.warn(`Supabase cache write failed: ${String(error)}`);
    }
  }

  private getCachedExplorePlaces(
    cacheKey: string,
  ): CityInsightExplorePlaceEntity[] | null {
    const memoryHit = this.exploreMemoryCache.get(cacheKey);
    if (memoryHit && memoryHit.expiresAt > Date.now()) {
      return memoryHit.payload;
    }
    return null;
  }

  private storeExplorePlacesCache(
    cacheKey: string,
    payload: CityInsightExplorePlaceEntity[],
  ): void {
    this.exploreMemoryCache.set(cacheKey, {
      payload,
      expiresAt: Date.now() + this.cacheTtlMs,
    });
  }

  private async fetchExplorePlacesFromOpenStreetMap(input: {
    cityId: string;
    cityName: string;
    latitude: number;
    longitude: number;
    stateName: string;
    regionName?: string;
    theme: CityInsightTheme;
    locale: InsightLocale;
    limit: number;
    seedPlace?: string;
    population: number;
  }): Promise<CityInsightExplorePlaceEntity[]> {
    const query = this.buildOverpassQuery(input);
    const response = await fetch(OVERPASS_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'text/plain;charset=UTF-8',
        'User-Agent': 'Movaro/1.0 city-insights',
      },
      body: query,
      signal: AbortSignal.timeout(14_000),
    });

    if (!response.ok) {
      throw AppErrorFactory.networkError(
        `Overpass ${response.status}: ${await response.text().catch(() => '')}`,
      );
    }

    const data = (await response.json()) as { elements?: OverpassElement[] };
    const elements = Array.isArray(data.elements) ? data.elements : [];
    const candidates = await Promise.all(
      elements.map((element) => this.mapExplorePlace(element, input)),
    );

    return this.dedupeExplorePlaces(
      candidates.filter((item): item is CityInsightExplorePlaceEntity => item != null),
    )
      .filter((item) => !this.isWeakPlaceName(item.name))
      .filter((item): item is CityInsightExplorePlaceEntity => item != null)
      .sort((left, right) =>
        this.rankExplorePlace(right, input) - this.rankExplorePlace(left, input),
      )
      .slice(0, input.limit);
  }

  private buildOverpassQuery(input: {
    latitude: number;
    longitude: number;
    theme: CityInsightTheme;
    population: number;
  }): string {
    const radius = this.themeRadius(input.theme, input.population);
    const selectors = this.overpassSelectors(input.theme)
      .map(
        (selector) => `
  node${selector}(around:${radius},${input.latitude},${input.longitude});
  way${selector}(around:${radius},${input.latitude},${input.longitude});
  relation${selector}(around:${radius},${input.latitude},${input.longitude});`,
      )
      .join('\n');

    return `[out:json][timeout:25];
(
${selectors}
);
out tags center;`;
  }

  private overpassSelectors(theme: CityInsightTheme): string[] {
    switch (theme) {
      case CityInsightTheme.Neighborhoods:
        return [
          '["place"~"suburb|neighbourhood|quarter"]',
          '["boundary"="administrative"]["admin_level"~"9|10"]',
        ];
      case CityInsightTheme.Beaches:
        return ['["natural"="beach"]', '["leisure"="beach_resort"]'];
      case CityInsightTheme.Parks:
        return [
          '["leisure"="park"]',
          '["leisure"="nature_reserve"]',
          '["tourism"="attraction"]["natural"]',
        ];
      case CityInsightTheme.Nightlife:
        return [
          '["amenity"~"bar|pub|biergarten|nightclub"]',
          '["tourism"="attraction"]["amenity"="bar"]',
        ];
      case CityInsightTheme.FoodAndCafes:
        return [
          '["amenity"~"cafe|restaurant|ice_cream|fast_food"]',
          '["shop"="bakery"]',
          '["amenity"="marketplace"]',
        ];
      case CityInsightTheme.CultureAndEvents:
        return [
          '["tourism"~"museum|gallery|artwork"]',
          '["amenity"~"arts_centre|theatre|cinema|library"]',
        ];
      case CityInsightTheme.Viewpoints:
        return ['["tourism"="viewpoint"]'];
      case CityInsightTheme.LocalRoutine:
        return [
          '["amenity"~"cafe|marketplace"]',
          '["leisure"="park"]',
          '["tourism"="attraction"]',
        ];
    }
  }

  private themeRadius(theme: CityInsightTheme, population: number): number {
    const baseRadius = population >= 1000000 ? 16000 : 12000;
    switch (theme) {
      case CityInsightTheme.Beaches:
      case CityInsightTheme.Viewpoints:
        return baseRadius + 8000;
      case CityInsightTheme.Neighborhoods:
        return baseRadius + 6000;
      default:
        return baseRadius;
    }
  }

  private async mapExplorePlace(
    element: OverpassElement,
    input: {
      cityId: string;
      cityName: string;
      stateName: string;
      regionName?: string;
      theme: CityInsightTheme;
      locale: InsightLocale;
    },
  ): Promise<CityInsightExplorePlaceEntity | null> {
    const tags = element.tags ?? {};
    const name = this.normalizeText(tags.name, 72);
    if (!name) {
      return null;
    }

    const latitude = element.lat ?? element.center?.lat;
    const longitude = element.lon ?? element.center?.lon;
    if (latitude == null || longitude == null) {
      return null;
    }

    const neighborhood =
      this.normalizeText(
        tags['addr:suburb'] ??
            tags['addr:neighbourhood'] ??
            tags.neighbourhood ??
            tags.neighborhood ??
            tags.suburb ??
            tags['is_in:suburb'] ??
            tags['addr:city_district'],
        48,
      ) ??
      this.normalizeText(tags['addr:district'], 48);
    const region =
      this.normalizeText(tags['addr:city_district'], 48) ??
      this.normalizeText(tags['is_in:city'], 48) ??
      input.stateName;
    const imageUrl =
      this.resolveImageTag(tags.image) ??
      this.resolveWikimediaCommonsImage(tags.wikimedia_commons) ??
      (await this.resolveWikipediaImage(tags.wikipedia)) ??
      (await this.searchWikimediaCommonsImage({
        placeName: name,
        cityName: input.cityName,
        stateName: input.stateName,
      }));

    return {
      id: `${input.cityId}-${input.theme}-${element.type}-${element.id}`,
      cityId: input.cityId,
      cityName: input.cityName,
      theme: input.theme,
      name,
      category: this.placeCategoryLabel(input.locale, input.theme, tags),
      neighborhood,
      region,
      shortText: this.buildPlaceMicrocopy({
        locale: input.locale,
        theme: input.theme,
        name,
        neighborhood,
        cityName: input.cityName,
      }),
      imageUrl,
      mapUrl: this.buildMapUrl(latitude, longitude, name, input.cityName),
      latitude,
      longitude,
      source: 'openstreetmap',
    };
  }

  private rankExplorePlace(
    item: CityInsightExplorePlaceEntity,
    input: { seedPlace?: string },
  ): number {
    let score = 0;
    if (item.imageUrl) {
      score += 6;
    }
    if (item.neighborhood) {
      score += 3;
    }
    if (item.region) {
      score += 1;
    }
    if (item.category) {
      score += 1;
    }
    if (input.seedPlace) {
      const seed = this.normalizePlaceKey(input.seedPlace);
      const normalizedName = this.normalizePlaceKey(item.name);
      const normalizedNeighborhood = this.normalizePlaceKey(
        item.neighborhood ?? '',
      );
      if (normalizedName.includes(seed) || seed.includes(normalizedName)) {
        score += 12;
      }
      if (
        normalizedNeighborhood.length > 0 &&
        (normalizedNeighborhood.includes(seed) || seed.includes(normalizedNeighborhood))
      ) {
        score += 4;
      }
    }
    if (this.isWeakPlaceName(item.name)) {
      score -= 8;
    }
    if (this.isChainLikePlaceName(item.name)) {
      score -= 10;
    }
    if (this.isSignaturePlaceName(item.name, item.theme)) {
      score += 5;
    }
    return score;
  }

  private dedupeExplorePlaces(
    items: CityInsightExplorePlaceEntity[],
  ): CityInsightExplorePlaceEntity[] {
    const seen = new Set<string>();
    return items.filter((item) => {
      const key = `${item.name}::${item.neighborhood ?? 'none'}`
        .trim()
        .toLowerCase();
      if (seen.has(key)) {
        return false;
      }
      seen.add(key);
      return true;
    });
  }

  private filterPlacesBySeedPlace(
    items: CityInsightExplorePlaceEntity[],
    seedPlace: string,
  ): CityInsightExplorePlaceEntity[] {
    const normalizedSeed = this.normalizePlaceKey(seedPlace);
    return items.filter((item) => {
      const name = this.normalizePlaceKey(item.name);
      const neighborhood = this.normalizePlaceKey(item.neighborhood ?? '');
      return (
        name.includes(normalizedSeed) ||
        normalizedSeed.includes(name) ||
        (neighborhood.length > 0 &&
          (neighborhood.includes(normalizedSeed) ||
            normalizedSeed.includes(neighborhood)))
      );
    });
  }

  private async buildExplorePlacesFallback(input: {
    cityId: string;
    cityName: string;
    stateName: string;
    theme: CityInsightTheme;
    locale: InsightLocale;
    seedPlace?: string;
  }): Promise<CityInsightExplorePlaceEntity[]> {
    const webSuggestions = await this.searchWebThemeSuggestions({
      cityName: input.cityName,
      stateName: input.stateName,
      locale: input.locale,
      theme: input.theme,
    });
    const normalizedSeedPlace = input.seedPlace?.trim();
    const suggestedPlaces =
      normalizedSeedPlace && normalizedSeedPlace.length > 0
        ? [normalizedSeedPlace]
        : webSuggestions.slice(0, 3);
    const fallbackName =
      normalizedSeedPlace && normalizedSeedPlace.length > 0
        ? normalizedSeedPlace
        : (suggestedPlaces[0] ??
          this.localized(
            input.locale,
            `Comece por ${input.cityName}`,
            `Empieza por ${input.cityName}`,
            `Start with ${input.cityName}`,
          ));
    const fallbackQuery =
      normalizedSeedPlace && normalizedSeedPlace.length > 0
        ? `${normalizedSeedPlace} ${input.cityName}`
        : `${this.fallbackPlaceCategory(input.locale, input.theme)} ${input.cityName}`;
    const fallbackImage =
      normalizedSeedPlace && normalizedSeedPlace.length > 0
        ? ((await this.searchWikimediaCommonsImage({
            placeName: normalizedSeedPlace,
            cityName: input.cityName,
            stateName: input.stateName,
          })) ??
          this.cityImageUrl(input.cityId))
        : this.cityImageUrl(input.cityId);

    const names =
      suggestedPlaces.length > 0
        ? suggestedPlaces
        : [fallbackName, fallbackName, fallbackName];

    return Promise.all(
      names.slice(0, 3).map(async (name, index) => {
        const webContext = await this.searchWebPlaceContext({
          placeName: name,
          cityName: input.cityName,
          stateName: input.stateName,
          locale: input.locale,
          theme: input.theme,
        });

        return {
          id: `${input.cityId}-${input.theme}-fallback-${index + 1}`,
          cityId: input.cityId,
          cityName: input.cityName,
          theme: input.theme,
          name: this.normalizeText(webContext?.title, 56) ?? name,
          category: this.fallbackPlaceCategory(input.locale, input.theme),
          neighborhood: undefined,
          region: input.cityName,
          shortText:
            this.normalizeText(webContext?.shortText, 132) ??
            this.buildPlaceMicrocopy({
              locale: input.locale,
              theme: input.theme,
              name,
              cityName: input.cityName,
            }),
          imageUrl: webContext?.imageUrl ?? fallbackImage,
          mapUrl: `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(
            `${name} ${input.cityName}`,
          )}`,
          latitude: undefined,
          longitude: undefined,
          source: 'template',
        };
      }),
    );
  }

  private async enrichInsightsWithOpenDataPlaces(
    items: CityInsightEntity[],
    city: {
      cityId: string;
      cityName: string;
      latitude: number;
      longitude: number;
      stateName: string;
      regionName?: string;
      population: number;
      locale: InsightLocale;
    },
  ): Promise<CityInsightEntity[]> {
    const placeThemes = new Set<CityInsightTheme>([
      CityInsightTheme.Neighborhoods,
      CityInsightTheme.Beaches,
      CityInsightTheme.Parks,
      CityInsightTheme.Nightlife,
      CityInsightTheme.FoodAndCafes,
      CityInsightTheme.CultureAndEvents,
      CityInsightTheme.Viewpoints,
    ]);

    const themedCache = new Map<CityInsightTheme, CityInsightExplorePlaceEntity[]>();

    const loadPlaces = async (theme: CityInsightTheme) => {
      const cached = themedCache.get(theme);
      if (cached) {
        return cached;
      }
      try {
        const places = await this.fetchExplorePlacesFromOpenStreetMap({
          cityId: city.cityId,
          cityName: city.cityName,
          latitude: city.latitude,
          longitude: city.longitude,
          stateName: city.stateName,
          regionName: city.regionName,
          theme,
          locale: city.locale,
          limit: 4,
          population: city.population,
        });
        themedCache.set(theme, places);
        return places;
      } catch (error) {
        this.logger.warn(
          `City insight enrichment failed for ${theme}: ${String(error)}`,
        );
        themedCache.set(theme, []);
        return [];
      }
    };

    return Promise.all(
      items.map(async (item) => {
        if (!item.theme || !placeThemes.has(item.theme)) {
          return item;
        }

        const currentHighlights = (item.placeHighlights ?? [])
          .map((place) => place.trim())
          .filter((place) => place.length > 0);
        if (currentHighlights.length >= 3) {
          return item;
        }

        const places = await loadPlaces(item.theme);
        if (places.length == 0) {
          const webSuggestions = await this.searchWebThemeSuggestions({
            cityName: city.cityName,
            stateName: city.stateName,
            locale: city.locale,
            theme: item.theme,
          });
          if (webSuggestions.length == 0) {
            return item;
          }

          return {
            ...item,
            placeHighlights: webSuggestions.slice(0, 4),
          };
        }

        const mergedHighlights = [
          ...currentHighlights,
          ...places
            .map((place) => place.name.trim())
            .filter((name) => name.length > 0),
        ];

        const dedupedHighlights = Array.from(
          new Set(mergedHighlights.map((name) => name.toLowerCase())),
        )
          .map((normalized) =>
            mergedHighlights.find((candidate) => candidate.toLowerCase() === normalized)!,
          )
          .slice(0, 4);

        return {
          ...item,
          placeHighlights: dedupedHighlights,
        };
      }),
    );
  }

  private async orchestrateBannerReadyInsights(
    items: CityInsightEntity[],
    input: {
      cityId: string;
      cityName: string;
      stateName: string;
      locale: InsightLocale;
      goal?: string;
      timeline?: string;
    },
  ): Promise<CityInsightEntity[]> {
    const placeDrivenThemes = new Set<CityInsightTheme>([
      CityInsightTheme.Neighborhoods,
      CityInsightTheme.Beaches,
      CityInsightTheme.Parks,
      CityInsightTheme.Nightlife,
      CityInsightTheme.FoodAndCafes,
      CityInsightTheme.CultureAndEvents,
      CityInsightTheme.Viewpoints,
    ]);

    const buckets = await Promise.all(
      items.map(async (item) => {
        const highlights = this.normalizeHighlights(item.placeHighlights);
        if (!item.theme || !placeDrivenThemes.has(item.theme) || highlights.length === 0) {
          return [item];
        }

        const alignedHighlights = highlights
          .filter((placeName) => this.highlightMatchesTheme(item.theme!, placeName))
          .slice(0, 2);

        const spotlightItems = await Promise.all(
          alignedHighlights.map(async (placeName, index) => {
            const wikimediaImage = await this.searchWikimediaCommonsImage({
              placeName,
              cityName: input.cityName,
              stateName: input.stateName,
            });
            const webContext = await this.searchWebPlaceContext({
              placeName,
              cityName: input.cityName,
              stateName: input.stateName,
              locale: input.locale,
              theme: item.theme!,
            });

            return {
              ...item,
              id: `${item.id}-spotlight-${index + 1}`,
              title: this.normalizeText(webContext?.title, 56) ?? placeName,
              shortText:
                this.normalizeText(webContext?.shortText, 132) ??
                this.buildPlaceMicrocopy({
                  locale: input.locale,
                  theme: item.theme!,
                  name: placeName,
                  cityName: input.cityName,
                }),
              placeHighlights: [placeName],
              imageUrl:
                wikimediaImage ??
                webContext?.imageUrl ??
                (item.imageUrl && !this.isCityHeroImage(item.imageUrl, input.cityId)
                  ? item.imageUrl
                  : undefined),
              ctaLabel: this.defaultPlaceCtaLabel(input.locale, item.theme!),
            };
          }),
        );

        return spotlightItems.length > 0 ? spotlightItems : [item];
      }),
    );

    const interleaved: CityInsightEntity[] = [];
    var index = 0;
    while (true) {
      var added = false;
      for (const bucket of buckets) {
        if (index < bucket.length) {
          interleaved.push(bucket[index]);
          added = true;
        }
      }
      if (!added) {
        break;
      }
      index += 1;
    }

    const seen = new Set<string>();
    const deduped = interleaved.filter((item) => {
      const key =
        item.placeHighlights && item.placeHighlights.length > 0
          ? this.normalizePlaceKey(item.title)
          : [item.title, item.shortText, item.imageUrl ?? 'none']
              .map((value) => this.normalizePlaceKey(value))
              .join('::');
      if (seen.has(key)) {
        return false;
      }
      seen.add(key);
      return true;
    });

    return this.pruneLowRelevanceInsights(
      deduped
        .map((item, index) => ({
          item,
          index,
          score: this.rankBannerInsightRelevance(item, input),
        }))
        .sort((left, right) => right.score - left.score || left.index - right.index)
        .map((entry) => entry.item),
    );
  }

  private rankBannerInsightRelevance(
    item: CityInsightEntity,
    input: {
      cityId: string;
      cityName: string;
      stateName: string;
      locale: InsightLocale;
      goal?: string;
      timeline?: string;
    },
  ): number {
    let score = 0;
    score += this.themeDiscoveryWeight(item.theme);

    if ((item.placeHighlights?.length ?? 0) > 0) {
      score += 10;
    }
    if (item.imageUrl && !this.isCityHeroImage(item.imageUrl, input.cityId)) {
      score += 5;
    }
    if (item.source === 'curated') {
      score += 4;
    }
    if (item.source === 'generated') {
      score += 3;
    }
    if (item.type === CityInsightType.Motivation || item.type === CityInsightType.Lifestyle) {
      score += 3;
    }
    if (item.type === CityInsightType.PracticalTip) {
      score += 2;
    }
    if (item.type === CityInsightType.CostOfLiving) {
      score -= 5;
    }
    if (this.isGenericRetentionCard(item)) {
      score -= 7;
    }
    score += this.goalThemeBoost(input.goal, item.theme, item.type);
    score += this.timelineThemeBoost(input.timeline, item.theme, item.type);
    return score;
  }

  private pruneLowRelevanceInsights(
    items: CityInsightEntity[],
  ): CityInsightEntity[] {
    const placeDrivenCount = items.filter(
      (item) => (item.placeHighlights?.length ?? 0) > 0,
    ).length;
    if (placeDrivenCount < 3) {
      return items;
    }

    let genericCount = 0;
    return items.filter((item) => {
      if (!this.isGenericRetentionCard(item)) {
        return true;
      }
      genericCount += 1;
      return genericCount <= 1;
    });
  }

  private themeDiscoveryWeight(theme?: CityInsightTheme): number {
    switch (theme) {
      case CityInsightTheme.Neighborhoods:
        return 18;
      case CityInsightTheme.FoodAndCafes:
        return 17;
      case CityInsightTheme.Nightlife:
        return 16;
      case CityInsightTheme.Beaches:
      case CityInsightTheme.Parks:
      case CityInsightTheme.Viewpoints:
        return 15;
      case CityInsightTheme.CultureAndEvents:
        return 14;
      case CityInsightTheme.LocalRoutine:
        return 8;
      default:
        return 6;
    }
  }

  private goalThemeBoost(
    goal: string | undefined,
    theme: CityInsightTheme | undefined,
    type: CityInsightType,
  ): number {
    const normalizedGoal = this.normalizePlaceKey(goal ?? '');
    if (!normalizedGoal) {
      return 0;
    }

    if (/(work|trabalho|empleo|job|career)/.test(normalizedGoal)) {
      if (
        theme === CityInsightTheme.Neighborhoods ||
        theme === CityInsightTheme.FoodAndCafes ||
        theme === CityInsightTheme.LocalRoutine
      ) {
        return 4;
      }
      if (type === CityInsightType.Work) {
        return 3;
      }
    }

    if (/(study|estudo|estudi|college|univers)/.test(normalizedGoal)) {
      if (
        theme === CityInsightTheme.Neighborhoods ||
        theme === CityInsightTheme.CultureAndEvents ||
        theme === CityInsightTheme.FoodAndCafes
      ) {
        return 4;
      }
    }

    if (/(family|familia|children|kids)/.test(normalizedGoal)) {
      if (
        theme === CityInsightTheme.Neighborhoods ||
        theme === CityInsightTheme.Parks ||
        theme === CityInsightTheme.LocalRoutine
      ) {
        return 4;
      }
    }

    return 0;
  }

  private timelineThemeBoost(
    timeline: string | undefined,
    theme: CityInsightTheme | undefined,
    type: CityInsightType,
  ): number {
    const normalizedTimeline = this.normalizePlaceKey(timeline ?? '');
    if (!normalizedTimeline) {
      return 0;
    }

    if (/(1|2|3|curto|soon|quick|rapido|rápido)/.test(normalizedTimeline)) {
      if (
        theme === CityInsightTheme.Neighborhoods ||
        theme === CityInsightTheme.LocalRoutine ||
        type === CityInsightType.PracticalTip
      ) {
        return 3;
      }
    }

    return 0;
  }

  private isGenericRetentionCard(item: CityInsightEntity): boolean {
    if ((item.placeHighlights?.length ?? 0) > 0) {
      return false;
    }

    const normalizedTitle = this.normalizePlaceKey(item.title);
    return [
      'como pode ser viver em',
      'what living in',
      'como puede ser vivir en',
      'o custo varia muito por bairro',
      'planejamento financeiro pesa mais aqui',
      'procure a agenda que faz a cidade mexer',
      'look for the agenda that makes the city move',
    ].some((fragment) => normalizedTitle.includes(fragment));
  }

  private highlightMatchesTheme(
    theme: CityInsightTheme,
    placeName: string,
  ): boolean {
    const normalized = this.normalizePlaceKey(placeName);
    switch (theme) {
      case CityInsightTheme.Beaches:
        return /(praia|beach|playa|orla|surf|mar)/.test(normalized);
      case CityInsightTheme.Parks:
        return /(parque|park|jardim|trilha|reserva|bosque)/.test(normalized);
      case CityInsightTheme.Nightlife:
        return /(lapa|bar|pub|boteco|boate|club|baixa|vila madalena)/.test(
          normalized,
        );
      case CityInsightTheme.FoodAndCafes:
        return /(mercado|cafe|café|padaria|feira|restaurante|food|bistro)/.test(
          normalized,
        );
      case CityInsightTheme.CultureAndEvents:
        return /(museu|museum|teatro|theatre|teatro|centro cultural|mercado)/.test(
          normalized,
        );
      case CityInsightTheme.Viewpoints:
        return /(mirante|vista|view|pico|morro|lagoa)/.test(normalized);
      case CityInsightTheme.Neighborhoods:
        return !/(praia|parque|park|mirante|museu|mercado)/.test(normalized);
      case CityInsightTheme.LocalRoutine:
        return true;
    }
  }

  private buildCuratedInsights(input: {
    cityId: string;
    cityName: string;
    locale: InsightLocale;
  }): CityInsightEntity[] {
    const curated = CURATED_CITY_INSIGHTS[input.cityId];
    if (!curated) {
      return [];
    }

    const now = new Date();
    const expiresAt = new Date(now.getTime() + this.cacheTtlMs).toISOString();

    return curated.map((item, index) => ({
      id: `${input.cityId}-curated-${index + 1}`,
      cityId: input.cityId,
      cityName: input.cityName,
      type: item.type,
      theme: item.theme,
      title: item.title[input.locale],
      shortText: item.shortText[input.locale],
      content: item.content[input.locale],
      placeHighlights: item.placeHighlights,
      imageUrl: this.cityImageUrl(input.cityId),
      ctaLabel: item.ctaLabel?.[input.locale],
      source: 'curated',
      generatedAt: now.toISOString(),
      expiresAt,
    }));
  }

  private async generateInsights(input: {
    cityId: string;
    cityName: string;
    stateName: string;
    regionName?: string;
    population: number;
    goal?: string;
    timeline?: string;
    locale: InsightLocale;
  }): Promise<CityInsightEntity[]> {
    if (this.appConfigService.isGroqConfigured) {
      try {
        const groqText = await this.callGroq(input);
        const parsed = this.parseGeneratedInsightsText(groqText, input);
        if (parsed.length > 0) {
          return parsed;
        }
      } catch (error) {
        this.logger.warn(
          `City insights Groq generation failed: ${String(error)}`,
        );
      }
    }

    if (!this.appConfigService.isGeminiConfigured) {
      return [];
    }

    try {
      const geminiText = await this.callGemini(input);
      return this.parseGeneratedInsightsText(geminiText, input);
    } catch (error) {
      this.logger.warn(`City insights generation failed: ${String(error)}`);
      return [];
    }
  }

  private async callGroq(input: {
    cityId: string;
    cityName: string;
    stateName: string;
    regionName?: string;
    population: number;
    goal?: string;
    timeline?: string;
    locale: InsightLocale;
  }): Promise<string> {
    const response = await fetch(GROQ_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${this.appConfigService.groqApiKey}`,
      },
      body: JSON.stringify({
        model: GROQ_MODEL,
        messages: [
          {
            role: 'system',
            content: this.buildGenerationSystemPrompt(input.locale),
          },
          {
            role: 'user',
            content: this.buildGenerationPrompt(input),
          },
        ],
        temperature: 0.6,
        max_tokens: 900,
        response_format: {
          type: 'json_object',
        },
      }),
      signal: AbortSignal.timeout(15_000),
    });

    if (!response.ok) {
      const error = await response.text().catch(() => '');
      throw new Error(`Groq ${response.status}: ${error.slice(0, 200)}`);
    }

    const data = (await response.json()) as GroqApiResponse;
    return data.choices?.[0]?.message?.content?.trim() ?? '';
  }

  private async callGemini(input: {
    cityId: string;
    cityName: string;
    stateName: string;
    regionName?: string;
    population: number;
    goal?: string;
    timeline?: string;
    locale: InsightLocale;
  }): Promise<string> {
    const response = await fetch(
      `${GEMINI_ENDPOINT}?key=${this.appConfigService.geminiApiKey}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          systemInstruction: {
            parts: [
              {
                text: this.buildGenerationSystemPrompt(input.locale),
              },
            ],
          },
          contents: [
            {
              role: 'user',
              parts: [
                {
                  text: this.buildGenerationPrompt(input),
                },
              ],
            },
          ],
          generationConfig: {
            temperature: 0.6,
            maxOutputTokens: 900,
            responseMimeType: 'application/json',
          },
        }),
        signal: AbortSignal.timeout(15_000),
      },
    );

    if (!response.ok) {
      const error = await response.text().catch(() => '');
      throw new Error(`Gemini ${response.status}: ${error.slice(0, 200)}`);
    }

    const data = (await response.json()) as GeminiApiResponse;
    return (
      data.candidates?.[0]?.content?.parts
        ?.map((part) => part.text ?? '')
        .join('')
        .trim() ?? ''
    );
  }

  private parseGeneratedInsightsText(
    rawText: string,
    input: {
      cityId: string;
      cityName: string;
      goal?: string;
      timeline?: string;
      locale: InsightLocale;
    },
  ): CityInsightEntity[] {
    if (!rawText) {
      return [];
    }

    const decoded = JSON.parse(rawText) as
      | Array<Record<string, unknown>>
      | { items?: Array<Record<string, unknown>> };
    const parsed = Array.isArray(decoded) ? decoded : decoded.items;
    if (!Array.isArray(parsed)) {
      return [];
    }

    const now = new Date();
    const expiresAt = new Date(now.getTime() + this.cacheTtlMs).toISOString();

    return parsed
      .map((item, index) =>
        this.mapGeneratedInsight(item, index, input, now, expiresAt),
      )
      .filter((item): item is CityInsightEntity => item != null);
  }

  private mapGeneratedInsight(
    item: Record<string, unknown>,
    index: number,
    input: {
      cityId: string;
      cityName: string;
      goal?: string;
      timeline?: string;
      locale: InsightLocale;
    },
    now: Date,
    expiresAt: string,
  ): CityInsightEntity | null {
    const type = typeof item.type === 'string' ? item.type : '';
    if (!this.isCityInsightType(type)) {
      return null;
    }

    const title = this.normalizeText(item.title, 72);
    const shortText = this.normalizeText(item.shortText, 140);
    const content = this.normalizeText(item.content, 520);
    if (!title || !shortText || !content) {
      return null;
    }

    return {
      id: `${input.cityId}-generated-${index + 1}`,
      cityId: input.cityId,
      cityName: input.cityName,
      type,
      theme: this.normalizeTheme(item, type),
      title,
      shortText,
      content,
      placeHighlights: this.normalizeHighlights(item.placeHighlights),
      imageUrl: this.shouldAttachCityImage(type)
        ? this.cityImageUrl(input.cityId)
        : undefined,
      ctaLabel: this.normalizeText(item.ctaLabel, 32),
      source: 'generated',
      generatedAt: now.toISOString(),
      expiresAt,
    };
  }

  private buildTemplateFallback(input: {
    cityId: string;
    cityName: string;
    stateName: string;
    regionName?: string;
    population: number;
    locale: InsightLocale;
    goal?: string;
    timeline?: string;
  }): CityInsightEntity[] {
    const now = new Date();
    const expiresAt = new Date(now.getTime() + this.cacheTtlMs).toISOString();
    const goalHint = this.goalSuffix(input.goal, input.locale);
    const timelineHint = this.timelineSuffix(input.timeline, input.locale);
    const profile = this.deriveCityProfile(input);
    const natureTheme = profile.preferredThemes.includes(
      CityInsightTheme.Beaches,
    )
      ? CityInsightTheme.Beaches
      : profile.preferredThemes.includes(CityInsightTheme.Parks)
        ? CityInsightTheme.Parks
        : CityInsightTheme.Viewpoints;
    const natureTitle = this.themeDrivenTitle(input.locale, natureTheme);
    const natureShortText = this.themeDrivenShortText(
      input.locale,
      natureTheme,
    );
    const natureContent = this.themeDrivenContent(input, natureTheme);
    const cultureTheme = profile.preferredThemes.includes(
      CityInsightTheme.CultureAndEvents,
    )
      ? CityInsightTheme.CultureAndEvents
      : CityInsightTheme.FoodAndCafes;

    return [
      {
        id: `${input.cityId}-template-1`,
        cityId: input.cityId,
        cityName: input.cityName,
        type: CityInsightType.Lifestyle,
        theme: CityInsightTheme.LocalRoutine,
        title: this.localized(
          input.locale,
          `Como pode ser viver em ${input.cityName}`,
          `Cómo puede ser vivir en ${input.cityName}`,
          `What living in ${input.cityName} can feel like`,
        ),
        shortText: this.localized(
          input.locale,
          'Pense na rotina, no ritmo da cidade e nos espaços que você quer frequentar.',
          'Piensa en la rutina, el ritmo de la ciudad y los espacios que quieres habitar.',
          'Think about the routine, the city rhythm, and the spaces you want around you.',
        ),
        content:
          this.localized(
            input.locale,
            `${input.cityName} tende a funcionar melhor quando você imagina a vida completa, não só a mudança. Visualize onde você trabalharia, como faria seus deslocamentos e quais hábitos quer sustentar.`,
            `${input.cityName} suele funcionar mejor cuando imaginas la vida completa, no solo la mudanza. Visualiza dónde trabajarías, cómo te moverías y qué hábitos quieres sostener.`,
            `${input.cityName} makes more sense when you picture the full life there, not only the move. Visualize where you would work, how you would commute, and which habits you want to keep.`,
          ) + goalHint,
        placeHighlights: [],
        imageUrl: this.cityImageUrl(input.cityId),
        ctaLabel: this.defaultExploreLabel(input.locale),
        source: 'template',
        generatedAt: now.toISOString(),
        expiresAt,
      },
      {
        id: `${input.cityId}-template-2`,
        cityId: input.cityId,
        cityName: input.cityName,
        type: CityInsightType.Housing,
        theme: CityInsightTheme.Neighborhoods,
        title: this.localized(
          input.locale,
          'Bairro de chegada define o começo',
          'El barrio de llegada define el comienzo',
          'Your arrival neighborhood shapes the start',
        ),
        shortText: this.localized(
          input.locale,
          'A primeira base precisa reduzir atrito, não só parecer bonita no mapa.',
          'La primera base debe reducir fricción, no solo verse linda en el mapa.',
          'Your first base should reduce friction, not only look good on the map.',
        ),
        content:
          this.localized(
            input.locale,
            `Se você ainda não conhece bem ${input.cityName}, vale buscar um ponto de entrada com rotina simples: mercado por perto, deslocamento viável e sensação de praticidade. Depois fica mais fácil refinar a cidade ao seu estilo.`,
            `Si todavía no conoces bien ${input.cityName}, conviene buscar un punto de entrada con rutina simple: mercado cerca, traslado viable y sensación de practicidad. Después será más fácil refinar la ciudad a tu estilo.`,
            `If you do not know ${input.cityName} well yet, start with a base that makes daily life simple: groceries nearby, manageable commuting, and a practical routine. It becomes easier to refine the city to your style later.`,
          ) + timelineHint,
        placeHighlights: [],
        ctaLabel: this.localized(
          input.locale,
          'Ver bairros',
          'Ver barrios',
          'See neighborhoods',
        ),
        source: 'template',
        generatedAt: now.toISOString(),
        expiresAt,
      },
      {
        id: `${input.cityId}-template-3`,
        cityId: input.cityId,
        cityName: input.cityName,
        type: CityInsightType.PracticalTip,
        theme: cultureTheme,
        title:
          cultureTheme == CityInsightTheme.CultureAndEvents
            ? this.localized(
                input.locale,
                'Procure a agenda que faz a cidade mexer',
                'Busca la agenda que hace moverse a la ciudad',
                'Look for the agenda that makes the city move',
              )
            : this.localized(
                input.locale,
                'Descubra os rituais que fazem a cidade encaixar',
                'Descubre los rituales que hacen encajar la ciudad',
                'Find the rituals that make the city click',
              ),
        shortText:
          cultureTheme == CityInsightTheme.CultureAndEvents
            ? this.localized(
                input.locale,
                'Eventos, centros culturais e feiras ajudam a criar vínculo antes mesmo da mudança terminar.',
                'Eventos, centros culturales y ferias ayudan a crear vínculo incluso antes de terminar la mudanza.',
                'Events, cultural venues, and local fairs help create attachment before the move is even done.',
              )
            : this.localized(
                input.locale,
                'Cafés, mercados e lugares de encontro ajudam a cidade a ficar com cara de rotina real.',
                'Cafés, mercados y lugares de encuentro ayudan a que la ciudad se sienta rutina real.',
                'Cafes, markets, and meeting spots help the city feel like real daily life.',
              ),
        content:
          (cultureTheme == CityInsightTheme.CultureAndEvents
            ? this.localized(
                input.locale,
                `Mesmo sem dominar ${input.cityName} ainda, vale observar os circuitos que dão vida à cidade: mercado público, centro cultural, show local, feira de bairro. Isso acelera a sensação de pertencimento.`,
                `Aunque todavía no domines ${input.cityName}, conviene mirar los circuitos que dan vida a la ciudad: mercado público, centro cultural, show local o feria de barrio. Eso acelera la sensación de pertenencia.`,
                `Even if you do not know ${input.cityName} well yet, it helps to notice the circuits that give the city life: a public market, a cultural venue, a local show, a neighborhood fair. That speeds up belonging.`,
              )
            : this.localized(
                input.locale,
                `Em ${input.cityName}, adaptação também passa por encontrar lugares pequenos que fazem sentido para a sua rotina: um café, um mercado bom, uma rua com movimento agradável. Isso ajuda a cidade a deixar de ser só um destino.`,
                `En ${input.cityName}, la adaptación también pasa por encontrar lugares pequeños que encajen con tu rutina: un café, un buen mercado o una calle con movimiento agradable. Eso ayuda a que la ciudad deje de ser solo un destino.`,
                `In ${input.cityName}, adaptation also comes from finding small places that fit your routine: a cafe, a good market, a street with the right movement. That helps the city stop feeling like only a destination.`,
              )) + goalHint,
        placeHighlights: [],
        ctaLabel: this.localized(
          input.locale,
          cultureTheme == CityInsightTheme.CultureAndEvents
            ? 'Ver agenda'
            : 'Ver lugares',
          cultureTheme == CityInsightTheme.CultureAndEvents
            ? 'Ver agenda'
            : 'Ver lugares',
          cultureTheme == CityInsightTheme.CultureAndEvents
            ? 'See agenda'
            : 'See places',
        ),
        source: 'template',
        generatedAt: now.toISOString(),
        expiresAt,
      },
      {
        id: `${input.cityId}-template-4`,
        cityId: input.cityId,
        cityName: input.cityName,
        type: CityInsightType.PracticalTip,
        theme: CityInsightTheme.FoodAndCafes,
        title: this.localized(
          input.locale,
          'Cafés, bares e mercados contam muito na adaptação',
          'Cafés, bares y mercados cuentan mucho en la adaptación',
          'Cafes, bars, and markets matter in your adaptation',
        ),
        shortText: this.localized(
          input.locale,
          'A cidade começa a parecer sua quando você encontra seus pequenos rituais.',
          'La ciudad empieza a sentirse tuya cuando encuentras tus pequeños rituales.',
          'A city starts to feel yours when you find your small rituals.',
        ),
        content: this.localized(
          input.locale,
          `Não é só sobre resolver a mudança. Em ${input.cityName}, a adaptação costuma ganhar força quando você imagina onde tomaria café, encontraria amigos ou faria uma pausa no fim do dia.`,
          `No se trata solo de resolver la mudanza. En ${input.cityName}, la adaptación gana fuerza cuando imaginas dónde tomarías café, verías amigos o harías una pausa al final del día.`,
          `It is not only about getting the move done. In ${input.cityName}, adaptation becomes stronger when you can imagine where you would grab coffee, meet friends, or pause at the end of the day.`,
        ),
        placeHighlights: [],
        ctaLabel: this.localized(
          input.locale,
          'Ver lugares',
          'Ver lugares',
          'See places',
        ),
        source: 'template',
        generatedAt: now.toISOString(),
        expiresAt,
      },
      {
        id: `${input.cityId}-template-5`,
        cityId: input.cityId,
        cityName: input.cityName,
        type: CityInsightType.Motivation,
        theme: natureTheme,
        title: natureTitle,
        shortText: natureShortText,
        content: natureContent,
        placeHighlights: [],
        imageUrl: this.cityImageUrl(input.cityId),
        ctaLabel: this.defaultExploreLabel(input.locale),
        source: 'template',
        generatedAt: now.toISOString(),
        expiresAt,
      },
    ];
  }

  private buildGenerationSystemPrompt(locale: InsightLocale): string {
    return [
      'You are generating city inspiration cards for the Movaro mobile app.',
      'Return JSON only. No markdown. No prose outside the array.',
      'Keep each shortText compact enough for two app lines.',
      'Balance practical guidance with emotional connection.',
      `Write in ${locale === 'pt' ? 'Portuguese (Brazil)' : locale === 'es' ? 'Spanish' : 'English'}.`,
      'Use only these insight types: lifestyle, cost_of_living, housing, work, practical_tip, motivation.',
      'Use only these themes: neighborhoods, beaches, parks, nightlife, food_and_cafes, culture_and_events, viewpoints, local_routine.',
      'Each item must support at least one of: future-life visualization, practical guidance, micro-learning, emotional reinforcement.',
      'Avoid hard claims, exact prices, politics, warnings, or social-media tone.',
      'Prioritize discovery themes people revisit in destination guides: where to go, where to eat, cultural agenda, beaches, parks, trails, viewpoints, neighborhoods.',
    ].join(' ');
  }

  private buildGenerationPrompt(input: {
    cityId: string;
    cityName: string;
    stateName: string;
    regionName?: string;
    population: number;
    goal?: string;
    timeline?: string;
    locale: InsightLocale;
  }): string {
    const profile = this.deriveCityProfile(input);
    const preferredThemes = profile.preferredThemes.join(', ');
    const avoidedThemes = profile.avoidedThemes.join(', ') || 'none';

    return `Generate 5 curated-feeling city insight cards for ${input.cityName}, ${input.stateName}, Brazil.

Context:
- User already has a migration plan.
- Goal: ${input.goal ?? 'not specified'}
- Timeline: ${input.timeline ?? 'not specified'}
- Region: ${input.regionName ?? 'not specified'}
- Population: ${input.population}
- City profile: ${profile.kind}
- Preferred themes: ${preferredThemes}
- Avoid these themes unless strongly justified: ${avoidedThemes}
- Audience: someone considering living in this city and needing motivation plus light practical clarity.

JSON schema:
[
  {
    "type": "lifestyle | cost_of_living | housing | work | practical_tip | motivation",
    "theme": "neighborhoods | beaches | parks | nightlife | food_and_cafes | culture_and_events | viewpoints | local_routine",
    "title": "max 55 chars preferred",
    "shortText": "max 120 chars",
    "content": "2 to 4 concise sentences",
    "placeHighlights": ["real neighborhoods, beaches, parks, bars or landmarks", "up to 4"],
    "ctaLabel": "optional short CTA"
  }
]

Make the set feel varied and useful:
- prioritize real neighborhoods, parks, cafes, cultural spots, viewpoints, bars, beaches, or landmarks that actually fit this city profile
- make the set feel like a moving carousel about places and rituals someone would want to experience after moving
- avoid repeating generic city-ranking language
- 1 housing/neighborhood card
- include neighborhoods plus at least 3 themes from the preferred list
- 1 social-life, food, or nightlife card
- 1 nature, beach, park, or viewpoint card
- 1 card aligned with the user goal when possible
- no repeated ideas`;
  }

  private buildMapUrl(
    latitude: number,
    longitude: number,
    name: string,
    cityName: string,
  ): string {
    return `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(
      `${latitude},${longitude} (${name}, ${cityName})`,
    )}`;
  }

  private resolveImageTag(value?: string): string | undefined {
    if (!value) {
      return undefined;
    }
    const normalized = value.trim();
    if (!/^https?:\/\//i.test(normalized)) {
      return undefined;
    }
    return normalized;
  }

  private resolveWikimediaCommonsImage(value?: string): string | undefined {
    if (!value) {
      return undefined;
    }
    const normalized = value.trim();
    if (!normalized.toLowerCase().startsWith('file:')) {
      return undefined;
    }
    const fileName = normalized.slice(5).trim();
    if (!fileName) {
      return undefined;
    }
    return `https://commons.wikimedia.org/wiki/Special:FilePath/${encodeURIComponent(
      fileName.replace(/ /g, '_'),
    )}`;
  }

  private async resolveWikipediaImage(
    wikipediaTag?: string,
  ): Promise<string | undefined> {
    if (!wikipediaTag) {
      return undefined;
    }

    const normalized = wikipediaTag.trim();
    const cached = this.wikipediaImageCache.get(normalized);
    if (cached !== undefined) {
      return cached ?? undefined;
    }

    const [language, ...titleParts] = normalized.split(':');
    const title = titleParts.join(':').trim();
    if (!language || !title) {
      this.wikipediaImageCache.set(normalized, null);
      return undefined;
    }

    try {
      const uri = new URL(`${WIKIPEDIA_API_BASE}`);
      uri.searchParams.set('action', 'query');
      uri.searchParams.set('format', 'json');
      uri.searchParams.set('prop', 'pageimages');
      uri.searchParams.set('pithumbsize', '640');
      uri.searchParams.set('titles', title);
      uri.searchParams.set('origin', '*');

      const response = await fetch(uri.toString().replace('wikipedia.org', `${language}.wikipedia.org`), {
        headers: { 'User-Agent': 'Movaro/1.0 city-insights' },
        signal: AbortSignal.timeout(8_000),
      });
      if (!response.ok) {
        this.wikipediaImageCache.set(normalized, null);
        return undefined;
      }

      const data = (await response.json()) as {
        query?: {
          pages?: Record<string, { thumbnail?: { source?: string } }>;
        };
      };
      const pages = data.query?.pages ?? {};
      const image = Object.values(pages)[0]?.thumbnail?.source ?? null;
      this.wikipediaImageCache.set(normalized, image);
      return image ?? undefined;
    } catch {
      this.wikipediaImageCache.set(normalized, null);
      return undefined;
    }
  }

  private async searchWikimediaCommonsImage(input: {
    placeName: string;
    cityName: string;
    stateName: string;
  }): Promise<string | undefined> {
    const cacheKey = [
      input.placeName,
      input.cityName,
      input.stateName,
    ]
        .join('::')
        .toLowerCase();
    const cached = this.commonsImageCache.get(cacheKey);
    if (cached !== undefined) {
      return cached ?? undefined;
    }

    try {
      const uri = new URL(WIKIMEDIA_COMMONS_API_BASE);
      uri.searchParams.set('action', 'query');
      uri.searchParams.set('format', 'json');
      uri.searchParams.set('generator', 'search');
      uri.searchParams.set('gsrnamespace', '6');
      uri.searchParams.set(
        'gsrsearch',
        `"${input.placeName}" "${input.cityName}" "${input.stateName}"`,
      );
      uri.searchParams.set('gsrlimit', '1');
      uri.searchParams.set('prop', 'pageimages');
      uri.searchParams.set('pithumbsize', '640');
      uri.searchParams.set('origin', '*');

      const response = await fetch(uri.toString(), {
        headers: { 'User-Agent': 'Movaro/1.0 city-insights' },
        signal: AbortSignal.timeout(8_000),
      });
      if (!response.ok) {
        this.commonsImageCache.set(cacheKey, null);
        return undefined;
      }

      const data = (await response.json()) as {
        query?: {
          pages?: Record<string, { thumbnail?: { source?: string } }>;
        };
      };
      const pages = data.query?.pages ?? {};
      const image = Object.values(pages)[0]?.thumbnail?.source ?? null;
      this.commonsImageCache.set(cacheKey, image);
      return image ?? undefined;
    } catch {
      this.commonsImageCache.set(cacheKey, null);
      return undefined;
    }
  }

  private async searchWebPlaceContext(input: {
    placeName: string;
    cityName: string;
    stateName: string;
    locale: InsightLocale;
    theme: CityInsightTheme;
  }): Promise<WebPlaceContext | undefined> {
    const cacheKey = [
      input.placeName,
      input.cityName,
      input.stateName,
      input.locale,
      input.theme,
    ]
      .join('::')
      .toLowerCase();
    const cached = this.webPlaceContextCache.get(cacheKey);
    if (cached && cached.expiresAt > Date.now()) {
      return cached.payload ?? undefined;
    }

    try {
      const query = this.buildWebSearchQuery(input);
      const searchUrl = `https://html.duckduckgo.com/html/?q=${encodeURIComponent(query)}`;
      const html = await this.fetchText(searchUrl);
      const results = this.parseDuckDuckGoHtmlResults(html);
      const match = results.find((result) =>
        this.isSearchResultRelevant(result, input.placeName, input.cityName),
      );
      if (!match) {
        this.webPlaceContextCache.set(cacheKey, {
          payload: null,
          expiresAt: Date.now() + this.cacheTtlMs,
        });
        return undefined;
      }

      const pageHtml = await this.fetchText(match.url);
      const imageUrl = this.extractPreferredMetaImage(pageHtml);
      const description =
        this.extractPreferredMetaDescription(pageHtml) ?? match.snippet;
      const title =
        this.extractPreferredMetaTitle(pageHtml) ??
        this.cleanSearchTitle(match.title, input.placeName, input.cityName);
      const payload: WebPlaceContext = {
        title: this.cleanSpotlightTitle(title, input.placeName, input.cityName),
        shortText: this.cleanSearchSnippet(description, input.placeName, input.cityName),
        imageUrl,
        sourceUrl: match.url,
      };
      this.webPlaceContextCache.set(cacheKey, {
        payload,
        expiresAt: Date.now() + this.cacheTtlMs,
      });
      return payload;
    } catch (error) {
      this.logger.warn(`Web place context failed: ${String(error)}`);
      this.webPlaceContextCache.set(cacheKey, {
        payload: null,
        expiresAt: Date.now() + 1000 * 60 * 30,
      });
      return undefined;
    }
  }

  private async searchWebThemeSuggestions(input: {
    cityName: string;
    stateName: string;
    locale: InsightLocale;
    theme: CityInsightTheme;
  }): Promise<string[]> {
    const cacheKey = [
      input.cityName,
      input.stateName,
      input.locale,
      input.theme,
    ]
      .join('::')
      .toLowerCase();
    const cached = this.webThemeSuggestionsCache.get(cacheKey);
    if (cached && cached.expiresAt > Date.now()) {
      return cached.payload;
    }

    try {
      const query = this.buildThemeSuggestionQuery(input);
      const html = await this.fetchText(
        `https://html.duckduckgo.com/html/?q=${encodeURIComponent(query)}`,
      );
      const results = this.parseDuckDuckGoHtmlResults(html);
      const suggestions = Array.from(
        new Set(
          results
            .flatMap((result) =>
              this.extractPlaceCandidatesFromSearchResult(
                `${result.title} ${result.snippet ?? ''}`,
                input.theme,
                input.cityName,
              ),
            )
            .filter((candidate) => this.highlightMatchesTheme(input.theme, candidate))
            .filter((candidate) => !this.isWeakPlaceName(candidate))
            .slice(0, 6),
        ),
      );
      this.webThemeSuggestionsCache.set(cacheKey, {
        payload: suggestions,
        expiresAt: Date.now() + this.cacheTtlMs,
      });
      return suggestions;
    } catch (error) {
      this.logger.warn(`Web theme suggestions failed: ${String(error)}`);
      this.webThemeSuggestionsCache.set(cacheKey, {
        payload: [],
        expiresAt: Date.now() + 1000 * 60 * 30,
      });
      return [];
    }
  }

  private buildThemeSuggestionQuery(input: {
    cityName: string;
    locale: InsightLocale;
    theme: CityInsightTheme;
  }): string {
    switch (input.theme) {
      case CityInsightTheme.Neighborhoods:
        return this.localized(
          input.locale,
          `melhores bairros em ${input.cityName}`,
          `mejores barrios en ${input.cityName}`,
          `best neighborhoods in ${input.cityName}`,
        );
      case CityInsightTheme.Beaches:
        return this.localized(
          input.locale,
          `melhores praias em ${input.cityName}`,
          `mejores playas en ${input.cityName}`,
          `best beaches in ${input.cityName}`,
        );
      case CityInsightTheme.Parks:
        return this.localized(
          input.locale,
          `melhores parques em ${input.cityName}`,
          `mejores parques en ${input.cityName}`,
          `best parks in ${input.cityName}`,
        );
      case CityInsightTheme.Nightlife:
        return this.localized(
          input.locale,
          `bares famosos em ${input.cityName}`,
          `bares famosos en ${input.cityName}`,
          `famous bars in ${input.cityName}`,
        );
      case CityInsightTheme.FoodAndCafes:
        return this.localized(
          input.locale,
          `cafés famosos em ${input.cityName}`,
          `cafes famosos en ${input.cityName}`,
          `famous cafes in ${input.cityName}`,
        );
      case CityInsightTheme.CultureAndEvents:
        return this.localized(
          input.locale,
          `lugares culturais em ${input.cityName}`,
          `lugares culturales en ${input.cityName}`,
          `cultural places in ${input.cityName}`,
        );
      case CityInsightTheme.Viewpoints:
        return this.localized(
          input.locale,
          `mirantes em ${input.cityName}`,
          `miradores en ${input.cityName}`,
          `viewpoints in ${input.cityName}`,
        );
      case CityInsightTheme.LocalRoutine:
        return this.localized(
          input.locale,
          `o que fazer em ${input.cityName}`,
          `qué hacer en ${input.cityName}`,
          `things to do in ${input.cityName}`,
        );
    }
  }

  private buildWebSearchQuery(input: {
    placeName: string;
    cityName: string;
    locale: InsightLocale;
    theme: CityInsightTheme;
  }): string {
    const themeHint = (() => {
      switch (input.theme) {
        case CityInsightTheme.Neighborhoods:
          return this.localized(input.locale, 'bairro morar', 'barrio vivir', 'neighborhood live');
        case CityInsightTheme.Beaches:
          return this.localized(input.locale, 'praia famosa', 'playa famosa', 'famous beach');
        case CityInsightTheme.Parks:
          return this.localized(input.locale, 'parque cidade', 'parque ciudad', 'city park');
        case CityInsightTheme.Nightlife:
          return this.localized(input.locale, 'bar vida noturna', 'bar vida nocturna', 'bar nightlife');
        case CityInsightTheme.FoodAndCafes:
          return this.localized(input.locale, 'cafe restaurante', 'cafe restaurante', 'cafe restaurant');
        case CityInsightTheme.CultureAndEvents:
          return this.localized(input.locale, 'cultura museu evento', 'cultura museo evento', 'culture museum event');
        case CityInsightTheme.Viewpoints:
          return this.localized(input.locale, 'mirante vista', 'mirador vista', 'viewpoint scenic');
        case CityInsightTheme.LocalRoutine:
          return this.localized(input.locale, 'o que fazer', 'que hacer', 'things to do');
      }
    })();

    return `"${input.placeName}" "${input.cityName}" ${themeHint}`;
  }

  private async fetchText(url: string): Promise<string> {
    const response = await fetch(url, {
      headers: {
        'User-Agent':
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 MovaroBot/1.0',
        Accept:
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      },
      redirect: 'follow',
      signal: AbortSignal.timeout(12_000),
    });
    if (!response.ok) {
      throw AppErrorFactory.networkError(`Fetch ${response.status} for ${url}`);
    }
    return response.text();
  }

  private parseDuckDuckGoHtmlResults(html: string): WebSearchResult[] {
    const results: WebSearchResult[] = [];
    const blockRegex =
      /<a[^>]*class="result__a"[^>]*href="([^"]+)"[^>]*>([\s\S]*?)<\/a>[\s\S]{0,1600}?(?:<a[^>]*class="result__snippet"[^>]*>|<div[^>]*class="result__snippet"[^>]*>)([\s\S]*?)(?:<\/a>|<\/div>)/gi;
    for (const match of html.matchAll(blockRegex)) {
      const rawHref = match[1] ?? '';
      const title = this.decodeHtmlEntities(this.stripHtml(match[2] ?? ''));
      const snippet = this.decodeHtmlEntities(this.stripHtml(match[3] ?? ''));
      const url = this.resolveDuckDuckGoResultUrl(rawHref);
      if (!title || !url) {
        continue;
      }
      results.push({ title, snippet, url });
      if (results.length >= 5) {
        break;
      }
    }
    return results;
  }

  private resolveDuckDuckGoResultUrl(rawHref: string): string | undefined {
    try {
      const resolved = rawHref.startsWith('//') ? `https:${rawHref}` : rawHref;
      const url = new URL(resolved);
      const redirected = url.searchParams.get('uddg');
      return redirected ?? resolved;
    } catch {
      return undefined;
    }
  }

  private isSearchResultRelevant(
    result: WebSearchResult,
    placeName: string,
    cityName: string,
  ): boolean {
    const haystack = this.normalizePlaceKey(
      `${result.title} ${result.snippet ?? ''} ${result.url}`,
    );
    const placeKey = this.normalizePlaceKey(placeName);
    const cityKey = this.normalizePlaceKey(cityName);
    return haystack.includes(placeKey) && haystack.includes(cityKey);
  }

  private extractPreferredMetaImage(html: string): string | undefined {
    const image =
      this.extractMetaContent(html, 'property', 'og:image') ??
      this.extractMetaContent(html, 'name', 'twitter:image') ??
      this.extractMetaContent(html, 'property', 'og:image:secure_url');
    if (!image || !/^https?:\/\//i.test(image)) {
      return undefined;
    }
    return image;
  }

  private extractPreferredMetaDescription(html: string): string | undefined {
    return (
      this.extractMetaContent(html, 'property', 'og:description') ??
      this.extractMetaContent(html, 'name', 'description') ??
      this.extractMetaContent(html, 'name', 'twitter:description')
    );
  }

  private extractPreferredMetaTitle(html: string): string | undefined {
    return (
      this.extractMetaContent(html, 'property', 'og:title') ??
      this.extractMetaContent(html, 'name', 'twitter:title')
    );
  }

  private extractMetaContent(
    html: string,
    attributeName: 'property' | 'name',
    attributeValue: string,
  ): string | undefined {
    const escapedValue = attributeValue.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const regex = new RegExp(
      `<meta[^>]*${attributeName}=["']${escapedValue}["'][^>]*content=["']([^"']+)["'][^>]*>`,
      'i',
    );
    const reverseRegex = new RegExp(
      `<meta[^>]*content=["']([^"']+)["'][^>]*${attributeName}=["']${escapedValue}["'][^>]*>`,
      'i',
    );
    const match = html.match(regex) ?? html.match(reverseRegex);
    const content = match?.[1];
    return content ? this.decodeHtmlEntities(content.trim()) : undefined;
  }

  private cleanSearchTitle(
    title: string,
    placeName: string,
    cityName: string,
  ): string {
    const cleaned = title
      .replace(/\s*[-|–]\s*Tripadvisor.*$/i, '')
      .replace(/\s*[-|–]\s*Wikip[eé]dia.*$/i, '')
      .replace(/\s*[-|–]\s*Wikipedia.*$/i, '')
      .trim();
    return this.cleanSpotlightTitle(cleaned, placeName, cityName);
  }

  private cleanSpotlightTitle(
    title: string | undefined,
    placeName: string,
    cityName: string,
  ): string {
    const normalizedTitle = this.normalizeText(title, 56);
    if (!normalizedTitle) {
      return placeName;
    }
    const titleKey = this.normalizePlaceKey(normalizedTitle);
    const cityKey = this.normalizePlaceKey(cityName);
    if (titleKey.includes(cityKey) && titleKey.length > cityKey.length + 12) {
      return placeName;
    }
    return normalizedTitle;
  }

  private cleanSearchSnippet(
    snippet: string | undefined,
    placeName: string,
    cityName: string,
  ): string | undefined {
    const normalized = this.normalizeText(snippet, 132);
    if (!normalized) {
      return undefined;
    }
    const cleaned = normalized
      .replace(/\s+/g, ' ')
      .replace(/^learn more\s*[:\-]?\s*/i, '')
      .replace(/^saiba mais\s*[:\-]?\s*/i, '')
      .replace(/^más información\s*[:\-]?\s*/i, '')
      .trim();
    const cleanedKey = this.normalizePlaceKey(cleaned);
    if (
      !cleanedKey.includes(this.normalizePlaceKey(placeName)) &&
      !cleanedKey.includes(this.normalizePlaceKey(cityName))
    ) {
      return undefined;
    }
    return cleaned;
  }

  private extractPlaceCandidatesFromSearchResult(
    value: string,
    theme: CityInsightTheme,
    cityName: string,
  ): string[] {
    const cleaned = this.decodeHtmlEntities(value)
      .replace(/\s+/g, ' ')
      .replace(/\b\d+\b/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
    const patterns = this.placeExtractionPatterns(theme);
    const candidates = patterns.flatMap((pattern) =>
      Array.from(cleaned.matchAll(pattern)).map((match) => match[1]?.trim() ?? ''),
    );

    return candidates
      .map((candidate) =>
        candidate
          .replace(new RegExp(`\\b${cityName}\\b`, 'i'), '')
          .replace(/\b(Rio de Janeiro|São Paulo|Porto Alegre|Florianópolis)\b/gi, '')
          .replace(/^[,;:\-\s]+|[,;:\-\s]+$/g, '')
          .trim(),
      )
      .filter((candidate) => candidate.length >= 4)
      .filter((candidate) => candidate.split(' ').length <= 5)
      .filter((candidate) => !this.normalizePlaceKey(candidate).includes('melhores'))
      .filter((candidate) => !this.normalizePlaceKey(candidate).includes('best'))
      .slice(0, 8);
  }

  private placeExtractionPatterns(theme: CityInsightTheme): RegExp[] {
    switch (theme) {
      case CityInsightTheme.Beaches:
        return [/\b(Praia(?: do| da| de)? [A-ZÀ-ÿ][\wÀ-ÿ'’-]+(?: [A-ZÀ-ÿ][\wÀ-ÿ'’-]+){0,3})/g];
      case CityInsightTheme.Parks:
        return [/\b((?:Parque|Park|Jardim) [A-ZÀ-ÿ][\wÀ-ÿ'’-]+(?: [A-ZÀ-ÿ][\wÀ-ÿ'’-]+){0,3})/g];
      case CityInsightTheme.Viewpoints:
        return [/\b((?:Mirante|Morro|Vista|Viewpoint) [A-ZÀ-ÿ][\wÀ-ÿ'’-]+(?: [A-ZÀ-ÿ][\wÀ-ÿ'’-]+){0,3})/g];
      case CityInsightTheme.CultureAndEvents:
        return [/\b((?:Museu|Museum|Teatro|Theatro|Centro Cultural|Mercado Público) [A-ZÀ-ÿ][\wÀ-ÿ'’-]+(?: [A-ZÀ-ÿ][\wÀ-ÿ'’-]+){0,3})/g];
      case CityInsightTheme.FoodAndCafes:
      case CityInsightTheme.Nightlife:
        return [/\b([A-ZÀ-ÿ][\wÀ-ÿ'’-]+(?: [A-ZÀ-ÿ][\wÀ-ÿ'’-]+){0,3})\b/g];
      case CityInsightTheme.Neighborhoods:
        return [/\b([A-ZÀ-ÿ][\wÀ-ÿ'’-]+(?: [A-ZÀ-ÿ][\wÀ-ÿ'’-]+){0,2})\b/g];
      case CityInsightTheme.LocalRoutine:
        return [];
    }
  }

  private stripHtml(value: string): string {
    return value.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
  }

  private decodeHtmlEntities(value: string): string {
    return value
      .replace(/&amp;/g, '&')
      .replace(/&quot;/g, '"')
      .replace(/&#39;/g, "'")
      .replace(/&apos;/g, "'")
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .replace(/&#x27;/g, "'")
      .replace(/&#x2F;/g, '/')
      .replace(/&nbsp;/g, ' ');
  }

  private placeCategoryLabel(
    locale: InsightLocale,
    theme: CityInsightTheme,
    tags: Record<string, string>,
  ): string {
    if (theme == CityInsightTheme.FoodAndCafes) {
      if (tags.amenity === 'restaurant') {
        return this.localized(locale, 'Restaurante', 'Restaurante', 'Restaurant');
      }
      if (tags.shop === 'bakery') {
        return this.localized(locale, 'Padaria', 'Panadería', 'Bakery');
      }
      return this.localized(locale, 'Café e encontro', 'Café y encuentro', 'Cafe and routine');
    }
    if (theme == CityInsightTheme.Nightlife) {
      if (tags.amenity === 'nightclub') {
        return this.localized(locale, 'Casa noturna', 'Club nocturno', 'Night club');
      }
      return this.localized(locale, 'Bar e noite', 'Bar y noche', 'Bars and nightlife');
    }
    if (theme == CityInsightTheme.Beaches) {
      return this.localized(locale, 'Praia', 'Playa', 'Beach');
    }
    if (theme == CityInsightTheme.Parks) {
      return this.localized(locale, 'Parque e respiro', 'Parque y respiro', 'Park and reset');
    }
    if (theme == CityInsightTheme.Viewpoints) {
      return this.localized(locale, 'Mirante', 'Mirador', 'Viewpoint');
    }
    if (theme == CityInsightTheme.CultureAndEvents) {
      if (tags.tourism === 'museum') {
        return this.localized(locale, 'Museu', 'Museo', 'Museum');
      }
      if (tags.amenity === 'theatre') {
        return this.localized(locale, 'Teatro', 'Teatro', 'Theater');
      }
      return this.localized(locale, 'Cultura local', 'Cultura local', 'Local culture');
    }
    if (theme == CityInsightTheme.Neighborhoods) {
      return this.localized(locale, 'Bairro', 'Barrio', 'Neighborhood');
    }
    return this.localized(locale, 'Rotina local', 'Rutina local', 'Local routine');
  }

  private fallbackPlaceCategory(
    locale: InsightLocale,
    theme: CityInsightTheme,
  ): string {
    return this.placeCategoryLabel(locale, theme, {});
  }

  private buildPlaceMicrocopy(input: {
    locale: InsightLocale;
    theme: CityInsightTheme;
    name: string;
    neighborhood?: string;
    cityName: string;
  }): string {
    const placeContext = input.neighborhood == null
        ? input.cityName
        : `${input.neighborhood}, ${input.cityName}`;

    switch (input.theme) {
      case CityInsightTheme.Neighborhoods:
        return this.localized(
          input.locale,
          `${input.name} ajuda a imaginar uma rotina que encaixa melhor logo na chegada, com cara de bairro para viver e não só visitar.`,
          `${input.name} ayuda a imaginar una rutina que encaja mejor desde la llegada, con sensación de barrio para vivir y no solo visitar.`,
          `${input.name} helps you picture an arrival routine that feels made for living there, not only visiting.`,
        );
      case CityInsightTheme.Beaches:
        return this.localized(
          input.locale,
          `${input.name} ajuda a sentir aquele lado da cidade que mistura mar, fim de tarde e desejo de já estar vivendo aí.`,
          `${input.name} ayuda a sentir ese lado de la ciudad que mezcla mar, atardecer y ganas de ya estar viviendo ahí.`,
          `${input.name} helps you feel the side of the city that mixes sea, sunset, and the desire to already be living there.`,
        );
      case CityInsightTheme.Parks:
        return this.localized(
          input.locale,
          `${input.name} mostra a parte da cidade que faz a semana respirar melhor e deixa a rotina mais desejável.`,
          `${input.name} muestra la parte de la ciudad que hace respirar mejor la semana y vuelve la rutina más deseable.`,
          `${input.name} shows the side of the city that lets the week breathe and makes everyday life feel more desirable.`,
        );
      case CityInsightTheme.Nightlife:
        return this.localized(
          input.locale,
          `${input.name} ajuda a imaginar um sábado de cidade viva, mesa cheia e aquela sensação boa de pertencer.`,
          `${input.name} ayuda a imaginar un sábado de ciudad viva, mesas llenas y esa buena sensación de pertenecer.`,
          `${input.name} helps you picture a Saturday of a living city, full tables, and that good feeling of belonging.`,
        );
      case CityInsightTheme.FoodAndCafes:
        return this.localized(
          input.locale,
          `${input.name} é o tipo de lugar pequeno que faz a cidade sair do sonho e começar a parecer rotina real.`,
          `${input.name} es el tipo de lugar pequeño que hace que la ciudad deje de ser sueño y empiece a sentirse rutina real.`,
          `${input.name} is the kind of small place that makes the city stop feeling like a dream and start feeling like real routine.`,
        );
      case CityInsightTheme.CultureAndEvents:
        return this.localized(
          input.locale,
          `${input.name} ajuda a sentir a identidade cultural que mantém a cidade viva e interessante depois que a novidade passa.`,
          `${input.name} ayuda a sentir la identidad cultural que mantiene viva e interesante a la ciudad incluso después de la novedad.`,
          `${input.name} helps you feel the cultural identity that keeps the city alive and interesting after the novelty fades.`,
        );
      case CityInsightTheme.Viewpoints:
        return this.localized(
          input.locale,
          `Ajuda a visualizar por que tanta gente associa ${input.cityName} a sensação de horizonte novo.`,
          `Ayuda a visualizar por qué tanta gente asocia ${input.cityName} con sensación de horizonte nuevo.`,
          `Helps you see why so many people connect ${input.cityName} with the feeling of a new horizon.`,
        );
      case CityInsightTheme.LocalRoutine:
        return this.localized(
          input.locale,
          `Mostra um pedaço da rotina real que pode fazer ${input.cityName} encaixar melhor no seu dia a dia.`,
          `Muestra una parte de la rutina real que puede hacer que ${input.cityName} encaje mejor en tu día a día.`,
          `Shows a part of the real routine that can make ${input.cityName} fit your day-to-day more naturally.`,
        );
    }
  }

  private normalizeLocale(locale?: string): InsightLocale {
    if (locale?.toLowerCase().startsWith('es') == true) {
      return 'es';
    }
    if (locale?.toLowerCase().startsWith('en') == true) {
      return 'en';
    }
    return 'pt';
  }

  private makeCacheKey(input: {
    cityId: string;
    goal?: string;
    timeline?: string;
    locale: InsightLocale;
  }): string {
    return [
      input.cityId,
      input.goal ?? 'none',
      input.timeline ?? 'none',
      input.locale,
    ]
      .join('::')
      .toLowerCase();
  }

  private isCityInsightType(value: string): value is CityInsightType {
    return Object.values<string>(CityInsightType).includes(value);
  }

  private isCityInsightTheme(value: string): value is CityInsightTheme {
    return Object.values<string>(CityInsightTheme).includes(value);
  }

  private deriveCityProfile(input: {
    cityId: string;
    population: number;
    regionName?: string;
  }): CityInsightCityProfile {
    const baseId = input.cityId.replace(/-[a-z]{2}$/i, '');
    if (COASTAL_CITY_BASE_IDS.has(baseId)) {
      return {
        kind: 'coastal',
        preferredThemes: [
          CityInsightTheme.Neighborhoods,
          CityInsightTheme.Beaches,
          CityInsightTheme.Viewpoints,
          CityInsightTheme.FoodAndCafes,
          CityInsightTheme.Parks,
          CityInsightTheme.Nightlife,
          CityInsightTheme.CultureAndEvents,
          CityInsightTheme.LocalRoutine,
        ],
        avoidedThemes: [],
      };
    }

    if (BORDER_CITY_BASE_IDS.has(baseId)) {
      return {
        kind: 'border',
        preferredThemes: [
          CityInsightTheme.Neighborhoods,
          CityInsightTheme.CultureAndEvents,
          CityInsightTheme.FoodAndCafes,
          CityInsightTheme.Viewpoints,
          CityInsightTheme.Parks,
          CityInsightTheme.LocalRoutine,
        ],
        avoidedThemes: [CityInsightTheme.Beaches],
      };
    }

    if (input.population >= 1000000) {
      return {
        kind: 'metropolis',
        preferredThemes: [
          CityInsightTheme.Neighborhoods,
          CityInsightTheme.CultureAndEvents,
          CityInsightTheme.FoodAndCafes,
          CityInsightTheme.Nightlife,
          CityInsightTheme.Parks,
          CityInsightTheme.LocalRoutine,
          CityInsightTheme.Viewpoints,
        ],
        avoidedThemes: [CityInsightTheme.Beaches],
      };
    }

    return {
      kind: 'inland',
      preferredThemes: [
        CityInsightTheme.Neighborhoods,
        CityInsightTheme.Parks,
        CityInsightTheme.FoodAndCafes,
        CityInsightTheme.CultureAndEvents,
        CityInsightTheme.LocalRoutine,
        CityInsightTheme.Viewpoints,
      ],
      avoidedThemes: [CityInsightTheme.Beaches],
    };
  }

  private normalizeText(value: unknown, maxLength: number): string | undefined {
    if (typeof value !== 'string') {
      return undefined;
    }

    const normalized = value.trim().replace(/\s+/g, ' ');
    if (normalized.length == 0) {
      return undefined;
    }

    if (normalized.length <= maxLength) {
      return normalized;
    }

    return `${normalized.slice(0, maxLength - 1).trimEnd()}…`;
  }

  private normalizePlaceKey(value: string): string {
    return value
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .trim()
      .toLowerCase()
      .replace(/\s+/g, ' ');
  }

  private isWeakPlaceName(value: string): boolean {
    const normalized = this.normalizePlaceKey(value);
    if (normalized.length < 4) {
      return true;
    }
    return [
      'praia',
      'beach',
      'playa',
      'park',
      'parque',
      'mirante',
      'viewpoint',
      'mercado',
      'market',
      'cafe',
      'café',
      'restaurant',
      'restaurante',
      'bar',
      'pub',
      'bairro',
      'neighborhood',
    ].includes(normalized);
  }

  private isChainLikePlaceName(value: string): boolean {
    const normalized = this.normalizePlaceKey(value);
    return [
      'starbucks',
      'mcdonalds',
      'burger king',
      'subway',
      'ragazzo',
      'outback',
      'kfc',
      'bobs',
      'bob s',
      'habibs',
    ].some((item) => normalized.includes(item));
  }

  private isSignaturePlaceName(value: string, theme: CityInsightTheme): boolean {
    const normalized = this.normalizePlaceKey(value);
    switch (theme) {
      case CityInsightTheme.Beaches:
        return /(praia|beach|playa|copacabana|ipanema|campeche|joaquina|jericoacoara)/.test(
          normalized,
        );
      case CityInsightTheme.Parks:
        return /(parque|park|jardim botanico|ibirapuera|lage)/.test(normalized);
      case CityInsightTheme.Viewpoints:
        return /(mirante|vista|morro|lagoa)/.test(normalized);
      case CityInsightTheme.Nightlife:
        return /(lapa|vila madalena|gavea|botafogo)/.test(normalized);
      case CityInsightTheme.FoodAndCafes:
      case CityInsightTheme.CultureAndEvents:
      case CityInsightTheme.LocalRoutine:
        return /(mercado|museu|teatro|cafe|café|feira)/.test(normalized);
      case CityInsightTheme.Neighborhoods:
        return normalized.split(' ').length >= 1;
    }
  }

  private isCityHeroImage(value: string, cityId: string): boolean {
    return value == this.cityImageUrl(cityId);
  }

  private normalizeHighlights(value: unknown): string[] {
    if (!Array.isArray(value)) {
      return [];
    }

    return value
      .filter((item): item is string => typeof item === 'string')
      .map((item) => item.trim())
      .filter((item) => item.length > 0)
      .slice(0, 4);
  }

  private normalizeTheme(
    item: Record<string, unknown>,
    type: CityInsightType,
  ): CityInsightTheme {
    if (typeof item.theme === 'string' && this.isCityInsightTheme(item.theme)) {
      return item.theme;
    }

    const keywords = [
      item.title,
      item.shortText,
      item.content,
      ...(Array.isArray(item.placeHighlights) ? item.placeHighlights : []),
    ]
      .filter((value): value is string => typeof value === 'string')
      .join(' ')
      .toLowerCase();

    if (
      /(praia|praias|beach|playa|mar|orla|surf|campeche|copacabana|ipanema|joaquina)/.test(
        keywords,
      )
    ) {
      return CityInsightTheme.Beaches;
    }
    if (
      /(parque|parques|park|trilha|trilhas|sendero|trail|jardim|bosque)/.test(
        keywords,
      )
    ) {
      return CityInsightTheme.Parks;
    }
    if (
      /(bairro|barrios|neighborhood|zona sul|pinheiros|campeche|lagoa|botafogo)/.test(
        keywords,
      )
    ) {
      return CityInsightTheme.Neighborhoods;
    }
    if (
      /(bar|bares|night|noite|boemia|happy hour|lapa|balada)/.test(keywords)
    ) {
      return CityInsightTheme.Nightlife;
    }
    if (
      /(café|cafe|cafes|cafeteria|restaurante|gastronomia|mercado|brunch|food)/.test(
        keywords,
      )
    ) {
      return CityInsightTheme.FoodAndCafes;
    }
    if (
      /(museu|museum|show|teatro|agenda|evento|eventos|cultural|feira|sesc)/.test(
        keywords,
      )
    ) {
      return CityInsightTheme.CultureAndEvents;
    }
    if (
      /(mirante|vista|viewpoint|sunset|pôr do sol|por do sol|panorama)/.test(
        keywords,
      )
    ) {
      return CityInsightTheme.Viewpoints;
    }

    return type === CityInsightType.Housing
      ? CityInsightTheme.Neighborhoods
      : CityInsightTheme.LocalRoutine;
  }

  private themeDrivenTitle(
    locale: InsightLocale,
    theme: CityInsightTheme,
  ): string {
    switch (theme) {
      case CityInsightTheme.Beaches:
        return this.localized(
          locale,
          'Um lembrete do porquê o litoral puxa você',
          'Un recordatorio de por qué el litoral tira de ti',
          'A reminder of why the coastline keeps pulling you back',
        );
      case CityInsightTheme.Parks:
        return this.localized(
          locale,
          'A natureza pode virar parte da sua semana',
          'La naturaleza puede volverse parte de tu semana',
          'Nature can become part of your week here',
        );
      case CityInsightTheme.Viewpoints:
        return this.localized(
          locale,
          'Existem vistas que ajudam a decisão a ficar viva',
          'Hay vistas que mantienen viva la decisión',
          'Some views keep the decision emotionally alive',
        );
      default:
        return this.localized(
          locale,
          'Um lembrete do porquê você escolheu essa cidade',
          'Un recordatorio de por qué elegiste esta ciudad',
          'A reminder of why you chose this city',
        );
    }
  }

  private themeDrivenShortText(
    locale: InsightLocale,
    theme: CityInsightTheme,
  ): string {
    switch (theme) {
      case CityInsightTheme.Beaches:
        return this.localized(
          locale,
          'Quando a cidade tem água, orla e fim de tarde forte, o sonho fica mais concreto.',
          'Cuando la ciudad tiene agua, costanera y un fin de tarde fuerte, el sueño se vuelve más concreto.',
          'When a city has water, shoreline, and memorable late afternoons, the dream feels more concrete.',
        );
      case CityInsightTheme.Parks:
        return this.localized(
          locale,
          'Parques, trilhas e áreas verdes ajudam a imaginar uma rotina que respira melhor.',
          'Parques, senderos y áreas verdes ayudan a imaginar una rutina que respira mejor.',
          'Parks, trails, and green areas help you picture a routine with more breathing room.',
        );
      case CityInsightTheme.Viewpoints:
        return this.localized(
          locale,
          'Algumas cidades ganham força quando você imagina os lugares de vista e pausa.',
          'Algunas ciudades ganan fuerza cuando imaginas los lugares de vista y pausa.',
          'Some cities become more magnetic when you picture their pause-and-view spots.',
        );
      default:
        return this.localized(
          locale,
          'Mesmo sem executar tarefas hoje, vale reforçar a visão de futuro que motivou o plano.',
          'Aunque hoy no ejecutes tareas, vale reforzar la visión de futuro que motivó el plan.',
          'Even if you are not executing tasks today, it helps to reinforce the future you are moving toward.',
        );
    }
  }

  private themeDrivenContent(
    input: {
      cityName: string;
      locale: InsightLocale;
    },
    theme: CityInsightTheme,
  ): string {
    switch (theme) {
      case CityInsightTheme.Beaches:
        return this.localized(
          input.locale,
          `Em ${input.cityName}, a ideia de morar ganha força quando você imagina praia, orla, travessias e uma rotina com mais horizonte. Esse tipo de imagem ajuda a mudança a continuar emocionalmente ativa.`,
          `En ${input.cityName}, la idea de vivir allí gana fuerza cuando imaginas playa, costanera, travesías y una rutina con más horizonte. Ese tipo de imagen ayuda a mantener la mudanza emocionalmente activa.`,
          `In ${input.cityName}, the idea of living there gets stronger when you picture beaches, shorelines, crossings, and a routine with more horizon. That image helps keep the move emotionally active.`,
        );
      case CityInsightTheme.Parks:
        return this.localized(
          input.locale,
          `Toda mudança longa precisa de uma imagem de vida possível. Em ${input.cityName}, essa imagem pode vir de parques, trilhas e áreas verdes que fazem o dia a dia parecer mais sustentável e habitável.`,
          `Toda mudanza larga necesita una imagen de vida posible. En ${input.cityName}, esa imagen puede venir de parques, senderos y áreas verdes que hacen sentir la rutina más sostenible y habitable.`,
          `Every long move needs a believable picture of life. In ${input.cityName}, that picture may come from parks, trails, and green areas that make daily life feel more sustainable and livable.`,
        );
      case CityInsightTheme.Viewpoints:
        return this.localized(
          input.locale,
          `Toda mudança longa precisa de pequenos reforços emocionais. Em ${input.cityName}, imaginar mirantes, paisagens e lugares de pausa ajuda a sustentar o plano nos dias menos produtivos.`,
          `Toda mudanza larga necesita pequeños refuerzos emocionales. En ${input.cityName}, imaginar miradores, paisajes y lugares de pausa ayuda a sostener el plan en los días menos productivos.`,
          `Every long move needs small emotional reinforcements. In ${input.cityName}, picturing viewpoints, landscapes, and pause-worthy places helps sustain the plan on slower days.`,
        );
      default:
        return this.localized(
          input.locale,
          `Toda mudança longa precisa de pequenos reforços emocionais. Voltar a pensar em como você quer viver em ${input.cityName} ajuda a sustentar o plano nos dias menos produtivos.`,
          `Toda mudanza larga necesita pequeños refuerzos emocionales. Volver a pensar en cómo quieres vivir en ${input.cityName} ayuda a sostener el plan.`,
          `Every long move needs small emotional reinforcements. Returning to how you want to live in ${input.cityName} helps sustain the plan on slower days.`,
        );
    }
  }

  private shouldAttachCityImage(type: CityInsightType): boolean {
    return (
      type === CityInsightType.Lifestyle || type === CityInsightType.Motivation
    );
  }

  private cityImageUrl(cityId: string): string | undefined {
    return CITY_IMAGE_URLS[cityId];
  }

  private localized(
    locale: InsightLocale,
    pt: string,
    es: string,
    en: string,
  ): string {
    if (locale === 'es') {
      return es;
    }
    if (locale === 'en') {
      return en;
    }
    return pt;
  }

  private defaultExploreLabel(locale: InsightLocale): string {
    return this.localized(
      locale,
      'Explorar cidade',
      'Explorar ciudad',
      'Explore city',
    );
  }

  private defaultPlaceCtaLabel(
    locale: InsightLocale,
    theme: CityInsightTheme,
  ): string {
    switch (theme) {
      case CityInsightTheme.Beaches:
        return this.localized(locale, 'Conhecer praia', 'Conocer playa', 'See beach');
      case CityInsightTheme.Neighborhoods:
        return this.localized(locale, 'Conhecer bairro', 'Conocer barrio', 'See neighborhood');
      case CityInsightTheme.Nightlife:
        return this.localized(locale, 'Conhecer bar', 'Conocer bar', 'See nightlife');
      case CityInsightTheme.FoodAndCafes:
        return this.localized(locale, 'Conhecer lugar', 'Conocer lugar', 'See place');
      case CityInsightTheme.Parks:
        return this.localized(locale, 'Conhecer parque', 'Conocer parque', 'See park');
      case CityInsightTheme.CultureAndEvents:
        return this.localized(locale, 'Conhecer lugar', 'Conocer lugar', 'See place');
      case CityInsightTheme.Viewpoints:
        return this.localized(locale, 'Conhecer vista', 'Conocer vista', 'See view');
      case CityInsightTheme.LocalRoutine:
        return this.localized(locale, 'Ver dica', 'Ver dica', 'See tip');
    }
  }

  private goalSuffix(goal: string | undefined, locale: InsightLocale): string {
    if (!goal) {
      return '';
    }

    return this.localized(
      locale,
      ` Se o seu foco principal é ${goal}, use isso como filtro para avaliar o encaixe da cidade.`,
      ` Si tu foco principal es ${goal}, úsalo como filtro para evaluar el encaje de la ciudad.`,
      ` If your main focus is ${goal}, use that as a filter when judging fit.`,
    );
  }

  private timelineSuffix(
    timeline: string | undefined,
    locale: InsightLocale,
  ): string {
    if (!timeline) {
      return '';
    }

    return this.localized(
      locale,
      ` Como seu prazo é ${timeline}, priorize decisões simples e reversíveis no começo.`,
      ` Como tu plazo es ${timeline}, prioriza decisiones simples y reversibles al inicio.`,
      ` Since your timeline is ${timeline}, prioritize simple and reversible early decisions.`,
    );
  }
}

interface GeminiApiResponse {
  candidates?: Array<{
    content?: {
      parts?: Array<{
        text?: string;
      }>;
    };
  }>;
}

interface GroqApiResponse {
  choices?: Array<{
    message?: {
      content?: string;
    };
  }>;
}
