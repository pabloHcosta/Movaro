/// Static seasonality data for Brazilian cities.
///
/// Pattern follows [CityCoastalProfile]: zero changes to the entity layer —
/// all data lives here as curated Dart constants, keyed by the base city ID
/// (without the state suffix, e.g. "florianopolis" not "florianopolis-sc").
///
/// Sources: Prefeitura de Florianópolis, ABIH-SC, Prefeitura de Balneário
/// Camboriú, Prefeitura de Bombinhas, and local press reports (2023-2025).
library;

import 'package:movaro_app/features/cities/domain/entities/city.dart';

// ─── Severity ─────────────────────────────────────────────────────────────────

enum CitySeasonalitySeverity {
  /// Population and prices roughly double; near-impossible to find long-term
  /// accommodation during peak.
  high,

  /// Noticeable price inflation and congestion; long-term renting is harder
  /// but not completely impractical.
  medium,
}

// ─── Profile ──────────────────────────────────────────────────────────────────

class CitySeasonalityData {
  const CitySeasonalityData({
    required this.peakMonths,
    required this.lowMonths,
    required this.severity,
    required this.visitorsLabelPt,
    required this.visitorsLabelEs,
    required this.visitorsLabelEn,
    required this.rentNotesPt,
    required this.rentNotesEs,
    required this.rentNotesEn,
    required this.jobNotesPt,
    required this.jobNotesEs,
    required this.jobNotesEn,
    this.populationMultiplierNote,
  });

  /// 1-based month indices that are high season (e.g. [12, 1, 2, 3]).
  final List<int> peakMonths;

  /// 1-based month indices that are noticeably low season.
  final List<int> lowMonths;

  final CitySeasonalitySeverity severity;

  /// Visitor volume label shown on the card (localized).
  final String visitorsLabelPt;
  final String visitorsLabelEs;
  final String visitorsLabelEn;

  /// Housing / rent impact sentence (localized).
  final String rentNotesPt;
  final String rentNotesEs;
  final String rentNotesEn;

  /// Jobs / work impact sentence (localized).
  final String jobNotesPt;
  final String jobNotesEs;
  final String jobNotesEn;

  /// Optional "population ×N" callout (e.g. "×100" for Bombinhas).
  final String? populationMultiplierNote;

  String visitorsLabel(String locale) => switch (locale) {
        'pt' => visitorsLabelPt,
        'es' => visitorsLabelEs,
        _ => visitorsLabelEn,
      };

  String rentNotes(String locale) => switch (locale) {
        'pt' => rentNotesPt,
        'es' => rentNotesEs,
        _ => rentNotesEn,
      };

  String jobNotes(String locale) => switch (locale) {
        'pt' => jobNotesPt,
        'es' => jobNotesEs,
        _ => jobNotesEn,
      };
}

// ─── Lookup service ───────────────────────────────────────────────────────────

class CitySeasonalityProfile {
  const CitySeasonalityProfile._();

  static CitySeasonalityData? of(City city) {
    final base = _baseId(city.id);
    return _data[base];
  }

  static bool hasSeason(City city) => _data.containsKey(_baseId(city.id));

  static String _baseId(String id) =>
      id.replaceFirst(RegExp(r'-[a-z]{2}$'), '');

  // ─── Data ──────────────────────────────────────────────────────────────────

  static const _data = <String, CitySeasonalityData>{
    // ── Santa Catarina — litoral sul ────────────────────────────────────────

    'florianopolis': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [11, 12, 1, 2, 3],
      lowMonths: [5, 6, 7, 8, 9],
      populationMultiplierNote: '×2',
      visitorsLabelPt: '~3 milhões de turistas no verão',
      visitorsLabelEs: '~3 millones de turistas en verano',
      visitorsLabelEn: '~3 million tourists in summer',
      rentNotesPt:
          'Imóveis na ilha praticamente desaparecem do mercado de longa duração '
          'entre nov e mar. Aluguéis de temporada chegam a 10–15× o valor mensal '
          'normal no Réveillon e Carnaval.',
      rentNotesEs:
          'Los inmuebles en la isla casi desaparecen del mercado de largo plazo '
          'entre nov y mar. Los alquileres de temporada llegan a 10–15× el valor '
          'mensual normal en Año Nuevo y Carnaval.',
      rentNotesEn:
          'Long-term rentals on the island nearly vanish between Nov and Mar. '
          'Short-term rates hit 10–15× normal monthly values at New Year\'s and '
          'Carnival.',
      jobNotesPt:
          'Turismo, gastronomia e varejo explodem em vagas temporárias no verão. '
          'Fora da temporada, o mercado de trabalho é mais estável e competitivo '
          'em tecnologia e serviços.',
      jobNotesEs:
          'Turismo, gastronomía y comercio explotan en empleos temporales en '
          'verano. Fuera de temporada, el mercado laboral es más estable y '
          'competitivo en tecnología y servicios.',
      jobNotesEn:
          'Tourism, food & beverage, and retail see a surge of seasonal jobs in '
          'summer. Off-season, tech and services dominate a more stable job '
          'market.',
    ),

    'balneario-camboriu': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 2],
      lowMonths: [5, 6, 7, 8, 9],
      visitorsLabelPt: '1,5–2 milhões de turistas (dez–fev)',
      visitorsLabelEs: '1,5–2 millones de turistas (dic–feb)',
      visitorsLabelEn: '1.5–2 million tourists (Dec–Feb)',
      rentNotesPt:
          'Aluguel de temporada em Camboriú salta de ~R\$900 a R\$6.000–13.000 no '
          'Réveillon e Carnaval. Contratos de longa duração praticamente inexistem '
          'nos meses de pico.',
      rentNotesEs:
          'El alquiler de temporada en Camboriú sube de ~R\$900 a R\$6.000–13.000 '
          'en Año Nuevo y Carnaval. Los contratos de largo plazo prácticamente '
          'no existen en los meses pico.',
      rentNotesEn:
          'Short-term rents in Camboriú jump from ~R\$900 to R\$6,000–13,000 at '
          'New Year\'s and Carnival. Long-term leases are nearly impossible to '
          'find during peak months.',
      jobNotesPt:
          'Hotelaria, bares e comércio de praia concentram vagas de dez a fev. '
          'O restante do ano apresenta oferta bem menor e mais concentrada em '
          'construção civil e imobiliário.',
      jobNotesEs:
          'Hotelería, bares y comercio de playa concentran empleos de dic a feb. '
          'El resto del año la oferta es mucho menor, concentrada en construcción '
          'e inmobiliaria.',
      jobNotesEn:
          'Hotels, bars, and beach retail absorb most jobs Dec–Feb. The rest of '
          'the year sees much lower demand, concentrated in construction and '
          'real-estate.',
    ),

    'bombinhas': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 2, 3],
      lowMonths: [5, 6, 7, 8, 9],
      populationMultiplierNote: '×100',
      visitorsLabelPt: '~2 milhões de turistas (dez–mar)',
      visitorsLabelEs: '~2 millones de turistas (dic–mar)',
      visitorsLabelEn: '~2 million tourists (Dec–Mar)',
      rentNotesPt:
          'Com população local de ~25 mil habitantes, Bombinhas recebe até 2,3 '
          'milhões de turistas na temporada — 100× a população. Aluguel de longa '
          'duração é quase impossível de encontrar no verão.',
      rentNotesEs:
          'Con una población local de ~25 mil habitantes, Bombinhas recibe hasta '
          '2,3 millones de turistas en temporada — 100× la población. El alquiler '
          'a largo plazo es casi imposible de encontrar en verano.',
      rentNotesEn:
          'With a local population of ~25k, Bombinhas receives up to 2.3 million '
          'tourists in season — 100× its population. Long-term leases are nearly '
          'impossible to find in summer.',
      jobNotesPt:
          'A economia local é quase inteiramente sazonal: pousadas, mergulho e '
          'gastronomia no verão. Fora da temporada o município fica quieto e as '
          'oportunidades de renda formal são muito limitadas.',
      jobNotesEs:
          'La economía local es casi completamente estacional: posadas, buceo y '
          'gastronomía en verano. Fuera de temporada el municipio queda tranquilo '
          'y las oportunidades de ingresos formales son muy limitadas.',
      jobNotesEn:
          'The local economy is almost entirely seasonal: guesthouses, scuba '
          'diving, and food service in summer. Off-season the town goes quiet '
          'and formal income opportunities are very limited.',
    ),

    'garopaba': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 2],
      lowMonths: [5, 6, 7, 8],
      visitorsLabelPt: 'Até 10× a população no verão',
      visitorsLabelEs: 'Hasta 10× la población en verano',
      visitorsLabelEn: 'Up to 10× population in summer',
      rentNotesPt:
          'Destino surf muito procurado. Imóveis para aluguel de longa duração '
          'escasseiam de dez a fev; preços sobem 3–5× em relação ao restante do '
          'ano.',
      rentNotesEs:
          'Destino de surf muy buscado. Los alquileres a largo plazo escasean de '
          'dic a feb; los precios suben 3–5× respecto al resto del año.',
      rentNotesEn:
          'Popular surf destination. Long-term rentals dry up Dec–Feb; prices '
          'spike 3–5× compared to the rest of the year.',
      jobNotesPt:
          'Surf shops, pousadas e restaurantes dominam o emprego sazonal. Inverno '
          'tem turismo de baixa qualidade e menor geração de emprego.',
      jobNotesEs:
          'Tiendas de surf, posadas y restaurantes dominan el empleo estacional. '
          'El invierno tiene turismo menor y menor generación de empleo.',
      jobNotesEn:
          'Surf shops, guesthouses, and restaurants drive seasonal employment. '
          'Winter brings reduced tourism and fewer jobs.',
    ),

    'imbituba': CitySeasonalityData(
      severity: CitySeasonalitySeverity.medium,
      peakMonths: [12, 1, 2],
      lowMonths: [6, 7, 8],
      visitorsLabelPt: 'Temporada concentrada no verão',
      visitorsLabelEs: 'Temporada concentrada en verano',
      visitorsLabelEn: 'Concentrated summer season',
      rentNotesPt:
          'Menor pressão que Floripa ou BC. Preços de aluguel sobem ~50–100% na '
          'temporada; contratos de longa duração ainda existem mas são disputados.',
      rentNotesEs:
          'Menor presión que Floripa o BC. Los precios de alquiler suben ~50–100% '
          'en temporada; los contratos de largo plazo aún existen pero son '
          'disputados.',
      rentNotesEn:
          'Less pressure than Floripa or BC. Rental prices rise ~50–100% in '
          'season; long-term leases still exist but are competitive.',
      jobNotesPt:
          'Porto industrial e polo de gastronomia. Mercado de trabalho menos '
          'sazonal que vizinhos, mas turismo ainda concentra empregos no verão.',
      jobNotesEs:
          'Puerto industrial y polo gastronómico. Mercado laboral menos estacional '
          'que los vecinos, pero el turismo aún concentra empleos en verano.',
      jobNotesEn:
          'Industrial port and gastronomy hub. Less seasonal job market than '
          'neighbors, but tourism still concentrates summer employment.',
    ),

    'itajai': CitySeasonalityData(
      severity: CitySeasonalitySeverity.medium,
      peakMonths: [12, 1, 2],
      lowMonths: [6, 7, 8],
      visitorsLabelPt: 'Fluxo turístico moderado no verão',
      visitorsLabelEs: 'Flujo turístico moderado en verano',
      visitorsLabelEn: 'Moderate tourist flow in summer',
      rentNotesPt:
          'Cidade portuária com economia diversificada. Sazonalidade existe mas '
          'é amortecida pela atividade portuária e industrial ao longo do ano.',
      rentNotesEs:
          'Ciudad portuaria con economía diversificada. La estacionalidad existe '
          'pero está amortiguada por la actividad portuaria e industrial todo el '
          'año.',
      rentNotesEn:
          'Port city with diversified economy. Seasonality exists but is buffered '
          'by year-round port and industrial activity.',
      jobNotesPt:
          'Porto de Itajaí é um dos maiores do Brasil — gera empregos estáveis '
          'o ano todo. Turismo complementa mas não domina.',
      jobNotesEs:
          'El Puerto de Itajaí es uno de los más grandes de Brasil — genera '
          'empleos estables todo el año. El turismo complementa pero no domina.',
      jobNotesEn:
          'Port of Itajaí is one of Brazil\'s largest — provides stable year-round '
          'jobs. Tourism complements but doesn\'t dominate.',
    ),

    // ── Rio de Janeiro — litoral ────────────────────────────────────────────

    'armacao-dos-buzios': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 2, 3],
      lowMonths: [6, 7, 8],
      visitorsLabelPt: 'Destino internacional — ~700k turistas/ano',
      visitorsLabelEs: 'Destino internacional — ~700k turistas/año',
      visitorsLabelEn: 'International destination — ~700k tourists/year',
      rentNotesPt:
          'Búzios praticamente dobra de preço no verão. Vila principal (Rua das '
          'Pedras) fica inacessível para moradia de longa duração jan–fev. Bairros '
          'afastados mantêm preços mais estáveis.',
      rentNotesEs:
          'Búzios prácticamente duplica sus precios en verano. La villa principal '
          '(Rua das Pedras) queda inaccesible para vivienda a largo plazo en '
          'ene–feb. Los barrios alejados mantienen precios más estables.',
      rentNotesEn:
          'Búzios almost doubles in price in summer. The main village (Rua das '
          'Pedras) becomes inaccessible for long-term housing Jan–Feb. '
          'Peripheral neighborhoods maintain more stable prices.',
      jobNotesPt:
          'Turismo e gastronomia dominam. Inverno mais tranquilo com bom custo-'
          'benefício para quem trabalha remotamente e quer evitar multidões.',
      jobNotesEs:
          'Turismo y gastronomía dominan. Invierno más tranquilo con buena '
          'relación costo-beneficio para quienes trabajan remotamente y quieren '
          'evitar multitudes.',
      jobNotesEn:
          'Tourism and food service dominate. Quieter winters offer good value '
          'for remote workers who want to avoid crowds.',
    ),

    'arraial-do-cabo': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 2],
      lowMonths: [6, 7, 8],
      visitorsLabelPt: 'Praias lotadas no verão — Caribe brasileiro',
      visitorsLabelEs: 'Playas llenas en verano — Caribe brasileño',
      visitorsLabelEn: 'Packed beaches in summer — Brazilian Caribbean',
      rentNotesPt:
          'Cidade pequena com forte pressão turística no verão. Aluguel quase '
          'inexistente para longa duração em jan–fev. Fora da temporada é um '
          'destino mais acessível.',
      rentNotesEs:
          'Ciudad pequeña con fuerte presión turística en verano. Alquiler casi '
          'inexistente a largo plazo en ene–feb. Fuera de temporada es un destino '
          'más accesible.',
      rentNotesEn:
          'Small city with heavy tourist pressure in summer. Long-term rentals '
          'near-impossible in Jan–Feb. Off-season it becomes much more '
          'accessible.',
      jobNotesPt:
          'Pesca artesanal e turismo. Empregos formais escassos — maioria informal '
          'e sazonal. Indicada para quem tem renda própria (remoto ou freelancer).',
      jobNotesEs:
          'Pesca artesanal y turismo. Empleos formales escasos — mayoría informal '
          'y estacional. Recomendada para quienes tienen ingresos propios (remoto '
          'o freelancer).',
      jobNotesEn:
          'Artisan fishing and tourism. Formal jobs are scarce — mostly informal '
          'and seasonal. Best suited for people with their own income (remote or '
          'freelance).',
    ),

    'cabo-frio': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 2],
      lowMonths: [6, 7, 8],
      visitorsLabelPt: 'Região dos Lagos — alto fluxo turístico',
      visitorsLabelEs: 'Región de los Lagos — alto flujo turístico',
      visitorsLabelEn: 'Lakes Region — high tourist traffic',
      rentNotesPt:
          'Principal polo da Região dos Lagos. Aluguéis de longa duração sobem '
          '50–80% no verão. Infraestrutura maior que Arraial facilita moradia '
          'fora da temporada.',
      rentNotesEs:
          'Principal polo de la Región de los Lagos. Los alquileres a largo plazo '
          'suben 50–80% en verano. La mayor infraestructura que Arraial facilita '
          'la vivienda fuera de temporada.',
      rentNotesEn:
          'Main hub of the Lakes Region. Long-term rentals rise 50–80% in summer. '
          'Better infrastructure than Arraial makes off-season living easier.',
      jobNotesPt:
          'Turismo, sal marinho e comércio. Mais diversificado que Arraial — '
          'há empregos estáveis fora da temporada.',
      jobNotesEs:
          'Turismo, sal marino y comercio. Más diversificado que Arraial — '
          'hay empleos estables fuera de temporada.',
      jobNotesEn:
          'Tourism, sea salt, and trade. More diversified than Arraial — stable '
          'employment exists off-season.',
    ),

    'paraty': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 2, 7],
      lowMonths: [5, 9, 10],
      visitorsLabelPt: 'Patrimônio histórico — alta em verão e julho',
      visitorsLabelEs: 'Patrimonio histórico — alta en verano y julio',
      visitorsLabelEn: 'Historic heritage — peak in summer and July',
      rentNotesPt:
          'Centro histórico tombado quase não tem oferta de longa duração. Bairros '
          'periféricos têm preços mais acessíveis o ano todo.',
      rentNotesEs:
          'El centro histórico protegido casi no tiene oferta a largo plazo. Los '
          'barrios periféricos tienen precios más accesibles todo el año.',
      rentNotesEn:
          'The protected historic center has almost no long-term rental supply. '
          'Peripheral neighborhoods offer more accessible prices year-round.',
      jobNotesPt:
          'Turismo cultural e cachaçaria artesanal. FLIP (festival literário em '
          'jul) é segundo pico. Empregos formais limitados.',
      jobNotesEs:
          'Turismo cultural y producción artesanal de cachaça. FLIP (festival '
          'literario en jul) es el segundo pico. Empleos formales limitados.',
      jobNotesEn:
          'Cultural tourism and artisan cachaça production. FLIP (literary '
          'festival in Jul) creates a second peak. Formal jobs are limited.',
    ),

    'niteroi': CitySeasonalityData(
      severity: CitySeasonalitySeverity.medium,
      peakMonths: [12, 1, 2],
      lowMonths: [6, 7],
      visitorsLabelPt: 'Cidade grande com praias urbanas',
      visitorsLabelEs: 'Ciudad grande con playas urbanas',
      visitorsLabelEn: 'Large city with urban beaches',
      rentNotesPt:
          'Sazonalidade moderada — Niterói é cidade universitária e sede de '
          'petróleo, com demanda estável. Praias como Itacoatiara atraem turismo '
          'mas não dominam a economia.',
      rentNotesEs:
          'Estacionalidad moderada — Niterói es ciudad universitaria y sede '
          'petrolera, con demanda estable. Las playas como Itacoatiara atraen '
          'turismo pero no dominan la economía.',
      rentNotesEn:
          'Moderate seasonality — Niterói is a university city and oil hub with '
          'stable demand. Beaches like Itacoatiara attract tourism but don\'t '
          'dominate the economy.',
      jobNotesPt:
          'Petróleo, saúde e educação são os principais setores — emprego estável '
          'o ano todo. Turismo e gastronomia complementam na temporada.',
      jobNotesEs:
          'Petróleo, salud y educación son los sectores principales — empleo '
          'estable todo el año. Turismo y gastronomía complementan en temporada.',
      jobNotesEn:
          'Oil, healthcare, and education are the main sectors — stable year-round '
          'employment. Tourism and food service complement in season.',
    ),

    'rio-de-janeiro': CitySeasonalityData(
      severity: CitySeasonalitySeverity.medium,
      peakMonths: [12, 1, 2, 3],
      lowMonths: [6, 7, 8],
      visitorsLabelPt: 'Réveillon e Carnaval — picos extremos de turismo',
      visitorsLabelEs: 'Año Nuevo y Carnaval — picos extremos de turismo',
      visitorsLabelEn: 'New Year\'s and Carnival — extreme tourism peaks',
      rentNotesPt:
          'Cidade grande com demanda estável o ano todo. Alta temporada encarece '
          'Zona Sul e Barra. Bairros residenciais (Méier, Tijuca, Jacarepaguá) '
          'têm preços mais estáveis.',
      rentNotesEs:
          'Ciudad grande con demanda estable todo el año. La temporada alta '
          'encarece Zona Sur y Barra. Los barrios residenciales (Méier, Tijuca, '
          'Jacarepaguá) tienen precios más estables.',
      rentNotesEn:
          'Large city with stable year-round demand. Peak season inflates South '
          'Zone and Barra prices. Residential neighborhoods (Méier, Tijuca, '
          'Jacarepaguá) remain more stable.',
      jobNotesPt:
          'Maior polo econômico do RJ. Turismo é importante mas há empregos em '
          'todos os setores o ano todo.',
      jobNotesEs:
          'Mayor polo económico de RJ. El turismo es importante pero hay empleos '
          'en todos los sectores todo el año.',
      jobNotesEn:
          'Largest economic hub in RJ. Tourism matters but jobs exist across all '
          'sectors year-round.',
    ),

    // ── São Paulo — litoral ─────────────────────────────────────────────────

    'guaruja': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 2],
      lowMonths: [6, 7, 8],
      visitorsLabelPt: 'Praia dos paulistanos — altíssima demanda verão',
      visitorsLabelEs: 'Playa de los paulistas — altísima demanda en verano',
      visitorsLabelEn: 'São Paulo\'s favorite beach — very high summer demand',
      rentNotesPt:
          'Principal destino de praia de SP. Verão traz multidões e preços altos. '
          'Inverno é tranquilo e acessível — boa opção para morar fora da '
          'temporada.',
      rentNotesEs:
          'Principal destino de playa de SP. El verano trae multitudes y precios '
          'altos. El invierno es tranquilo y accesible — buena opción para vivir '
          'fuera de temporada.',
      rentNotesEn:
          'SP\'s main beach destination. Summer brings crowds and high prices. '
          'Winter is quiet and affordable — good option for off-season living.',
      jobNotesPt:
          'Hotelaria, bares e serviços de praia concentram empregos no verão. '
          'Fora da temporada há porto e indústria química como alternativas.',
      jobNotesEs:
          'Hotelería, bares y servicios de playa concentran empleos en verano. '
          'Fuera de temporada hay puerto e industria química como alternativas.',
      jobNotesEn:
          'Hotels, bars, and beach services concentrate jobs in summer. Off-season '
          'the port and chemical industry provide alternatives.',
    ),

    'ilhabela': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 2],
      lowMonths: [6, 7, 8, 9],
      visitorsLabelPt: 'Ilha — acesso por balsa, lotada no verão',
      visitorsLabelEs: 'Isla — acceso por ferry, llena en verano',
      visitorsLabelEn: 'Island — ferry access, packed in summer',
      rentNotesPt:
          'Acesso limitado por balsa cria escassez de imóveis. No verão é quase '
          'impossível alugar de longa duração. Nos meses frios a oferta melhora '
          'bastante.',
      rentNotesEs:
          'El acceso limitado por ferry crea escasez de inmuebles. En verano es '
          'casi imposible alquilar a largo plazo. En los meses fríos la oferta '
          'mejora bastante.',
      rentNotesEn:
          'Limited ferry access creates housing scarcity. In summer long-term '
          'rentals are nearly impossible. In cooler months supply improves '
          'significantly.',
      jobNotesPt:
          'Vela e náutica (polo de vela do Brasil), pousadas e gastronomia são os '
          'principais empregos — sazonais. Petrobras tem bases na região.',
      jobNotesEs:
          'Vela y náutica (polo de vela de Brasil), posadas y gastronomía son los '
          'principales empleos — estacionales. Petrobras tiene bases en la región.',
      jobNotesEn:
          'Sailing and nautical sports (Brazil\'s sailing hub), guesthouses, and '
          'food service are the main jobs — seasonal. Petrobras has facilities '
          'in the area.',
    ),

    'ubatuba': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 2],
      lowMonths: [6, 7, 8],
      visitorsLabelPt: '~2 milhões de turistas/ano, pico no verão',
      visitorsLabelEs: '~2 millones de turistas/año, pico en verano',
      visitorsLabelEn: '~2 million tourists/year, peak in summer',
      rentNotesPt:
          'Uma das praias mais bonitas do litoral paulista. Alta temporada dobra '
          'os preços de aluguel. Bairros afastados do centro têm melhor '
          'disponibilidade fora do pico.',
      rentNotesEs:
          'Una de las playas más hermosas del litoral paulista. La temporada alta '
          'duplica los precios de alquiler. Los barrios alejados del centro tienen '
          'mejor disponibilidad fuera del pico.',
      rentNotesEn:
          'One of the most beautiful beaches on the SP coast. Peak season doubles '
          'rents. Neighborhoods away from the center have better availability '
          'off-peak.',
      jobNotesPt:
          'Surf, mergulho, pousadas e restaurantes — economia essencialmente '
          'turística. Mercado de trabalho formal muito sazonal.',
      jobNotesEs:
          'Surf, buceo, posadas y restaurantes — economía esencialmente turística. '
          'Mercado laboral formal muy estacional.',
      jobNotesEn:
          'Surf, diving, guesthouses, and restaurants — essentially a tourist '
          'economy. Formal job market is highly seasonal.',
    ),

    'santos': CitySeasonalityData(
      severity: CitySeasonalitySeverity.medium,
      peakMonths: [12, 1, 2],
      lowMonths: [6, 7],
      visitorsLabelPt: 'Litoral portuário com balneário urbano',
      visitorsLabelEs: 'Litoral portuario con balneario urbano',
      visitorsLabelEn: 'Port coast with urban beach resort',
      rentNotesPt:
          'Santos é cidade grande e portuária — tem demanda estável. Alta temporada '
          'eleva preços na orla mas bairros centrais mantêm estabilidade.',
      rentNotesEs:
          'Santos es una ciudad grande y portuaria — tiene demanda estable. La '
          'temporada alta eleva precios en el borde costero pero los barrios '
          'centrales mantienen estabilidad.',
      rentNotesEn:
          'Santos is a large port city with stable demand. Peak season raises '
          'prices on the waterfront but central neighborhoods stay stable.',
      jobNotesPt:
          'Porto de Santos é o maior da América Latina — logística, comércio e '
          'serviços garantem empregos estáveis o ano todo. Turismo complementa.',
      jobNotesEs:
          'El Puerto de Santos es el más grande de América Latina — logística, '
          'comercio y servicios garantizan empleos estables todo el año. El '
          'turismo complementa.',
      jobNotesEn:
          'Port of Santos is Latin America\'s largest — logistics, trade, and '
          'services ensure stable year-round employment. Tourism complements.',
    ),

    // ── Nordeste ────────────────────────────────────────────────────────────

    'natal': CitySeasonalityData(
      severity: CitySeasonalitySeverity.medium,
      peakMonths: [12, 1, 7],
      lowMonths: [4, 5, 6],
      visitorsLabelPt: 'Sol o ano todo — dois picos turísticos',
      visitorsLabelEs: 'Sol todo el año — dos picos turísticos',
      visitorsLabelEn: 'Sunshine year-round — two tourist peaks',
      rentNotesPt:
          'Natal tem turismo o ano todo. Picos em jan (verão austral) e jul '
          '(inverno europeu). Fora dos picos a cidade é bem mais tranquila e '
          'acessível.',
      rentNotesEs:
          'Natal tiene turismo todo el año. Picos en ene (verano austral) y jul '
          '(invierno europeo). Fuera de los picos la ciudad es mucho más '
          'tranquila y accesible.',
      rentNotesEn:
          'Natal has year-round tourism. Peaks in Jan (austral summer) and Jul '
          '(European winter). Outside peaks the city is much quieter and '
          'affordable.',
      jobNotesPt:
          'Turismo, camaricultura e serviços. Emprego relativamente estável para '
          'o Nordeste. Setor de energia eólica em crescimento.',
      jobNotesEs:
          'Turismo, camaronicultura y servicios. Empleo relativamente estable para '
          'el Nordeste. Sector de energía eólica en crecimiento.',
      jobNotesEn:
          'Tourism, shrimp farming, and services. Relatively stable employment '
          'for the Northeast. Wind energy sector is growing.',
    ),

    'joao-pessoa': CitySeasonalityData(
      severity: CitySeasonalitySeverity.medium,
      peakMonths: [1, 2, 7],
      lowMonths: [4, 5, 6],
      visitorsLabelPt: 'Cidade leste mais oriental das Américas',
      visitorsLabelEs: 'Ciudad más oriental de las Américas',
      visitorsLabelEn: 'Easternmost city of the Americas',
      rentNotesPt:
          'Capital com custo de vida baixo e sazonalidade moderada. Praias como '
          'Tambau e Cabo Branco têm pico no verão e julho.',
      rentNotesEs:
          'Capital con bajo costo de vida y estacionalidad moderada. Playas como '
          'Tambau y Cabo Branco tienen pico en verano y julio.',
      rentNotesEn:
          'Capital city with low cost of living and moderate seasonality. Beaches '
          'like Tambau and Cabo Branco peak in summer and July.',
      jobNotesPt:
          'Serviços públicos, saúde, educação e turismo. Boa base para quem busca '
          'estabilidade com custo baixo.',
      jobNotesEs:
          'Servicios públicos, salud, educación y turismo. Buena base para quienes '
          'buscan estabilidad con bajo costo.',
      jobNotesEn:
          'Public services, healthcare, education, and tourism. Good base for '
          'those seeking stability at low cost.',
    ),

    'maceio': CitySeasonalityData(
      severity: CitySeasonalitySeverity.medium,
      peakMonths: [12, 1, 2, 7],
      lowMonths: [4, 5, 6],
      visitorsLabelPt: 'Lagoas e piscinas naturais — forte apelo turístico',
      visitorsLabelEs: 'Lagunas y piscinas naturales — fuerte atractivo turístico',
      visitorsLabelEn: 'Lagoons and natural pools — strong tourist appeal',
      rentNotesPt:
          'Piscinas naturais de Pajuçara são o principal atrativo. Alta temporada '
          'concentrada em jan–fev e julho. Bairros como Farol têm demanda '
          'estável o ano todo.',
      rentNotesEs:
          'Las piscinas naturales de Pajuçara son el principal atractivo. '
          'Temporada alta concentrada en ene–feb y julio. Barrios como Farol '
          'tienen demanda estable todo el año.',
      rentNotesEn:
          'Pajuçara natural pools are the main attraction. Peak season '
          'concentrated in Jan–Feb and July. Neighborhoods like Farol have '
          'stable year-round demand.',
      jobNotesPt:
          'Turismo, petróleo e serviços. Petroquímica da região gera empregos '
          'estáveis. Alerta de afundamento de solo em alguns bairros.',
      jobNotesEs:
          'Turismo, petróleo y servicios. La petroquímica de la región genera '
          'empleos estables. Alerta de hundimiento del suelo en algunos barrios.',
      jobNotesEn:
          'Tourism, oil, and services. Regional petrochemicals provide stable '
          'jobs. Land subsidence alert in some neighborhoods.',
    ),

    'maragogi': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 2, 7],
      lowMonths: [4, 5, 6],
      visitorsLabelPt: 'Galápagos do Brasil — turismo intenso',
      visitorsLabelEs: 'Galápagos de Brasil — turismo intenso',
      visitorsLabelEn: 'Brazil\'s Galápagos — intense tourism',
      rentNotesPt:
          'Cidade pequena (60 mil hab.) com pressão turística elevada. Piscinas '
          'naturais atraem turistas internacionais. Oferta de moradia muito '
          'limitada na alta temporada.',
      rentNotesEs:
          'Ciudad pequeña (60 mil hab.) con alta presión turística. Las piscinas '
          'naturales atraen turistas internacionales. Oferta de vivienda muy '
          'limitada en temporada alta.',
      rentNotesEn:
          'Small city (60k pop.) with high tourist pressure. Natural pools attract '
          'international visitors. Housing supply is very limited in peak season.',
      jobNotesPt:
          'Economia quase exclusivamente turística. Boa para nômades digitais que '
          'querem destino paradisíaco e baixo custo — mas emprego formal é '
          'escasso.',
      jobNotesEs:
          'Economía casi exclusivamente turística. Buena para nómades digitales '
          'que quieren un destino paradisíaco y bajo costo — pero el empleo '
          'formal es escaso.',
      jobNotesEn:
          'Almost exclusively tourist economy. Good for digital nomads wanting a '
          'paradise destination at low cost — but formal employment is scarce.',
    ),

    'aracaju': CitySeasonalityData(
      severity: CitySeasonalitySeverity.medium,
      peakMonths: [1, 2, 7],
      lowMonths: [4, 5, 6],
      visitorsLabelPt: 'Capital sergipana com praias urbanas',
      visitorsLabelEs: 'Capital sergipana con playas urbanas',
      visitorsLabelEn: 'Sergipe capital with urban beaches',
      rentNotesPt:
          'Menor capital do Brasil — custo de vida baixo e sazonalidade moderada. '
          'Boa qualidade de vida para imigrantes com orçamento apertado.',
      rentNotesEs:
          'Capital más pequeña de Brasil — bajo costo de vida y estacionalidad '
          'moderada. Buena calidad de vida para inmigrantes con presupuesto '
          'ajustado.',
      rentNotesEn:
          'Brazil\'s smallest capital — low cost of living and moderate '
          'seasonality. Good quality of life for immigrants on a tight budget.',
      jobNotesPt:
          'Serviços públicos, petróleo e gás (Petrobras tem base aqui), turismo. '
          'Mercado de trabalho estável para o padrão nordestino.',
      jobNotesEs:
          'Servicios públicos, petróleo y gas (Petrobras tiene base aquí), '
          'turismo. Mercado laboral estable para el estándar del Nordeste.',
      jobNotesEn:
          'Public services, oil and gas (Petrobras has a base here), and tourism. '
          'Stable job market by Northeast standards.',
    ),

    'recife': CitySeasonalityData(
      severity: CitySeasonalitySeverity.medium,
      peakMonths: [1, 2, 7],
      lowMonths: [4, 5, 6],
      visitorsLabelPt: 'Metrópole do Nordeste — Veneza brasileira',
      visitorsLabelEs: 'Metrópolis del Nordeste — Venecia brasileña',
      visitorsLabelEn: 'Northeast metropolis — Brazilian Venice',
      rentNotesPt:
          'Cidade grande com demanda estável. Sazonalidade existe mas não domina '
          'o mercado. Carnaval (fev) é o principal evento de pico.',
      rentNotesEs:
          'Ciudad grande con demanda estable. La estacionalidad existe pero no '
          'domina el mercado. El Carnaval (feb) es el principal evento pico.',
      rentNotesEn:
          'Large city with stable demand. Seasonality exists but doesn\'t dominate '
          'the market. Carnival (Feb) is the main peak event.',
      jobNotesPt:
          'Hub de tecnologia do Nordeste (Porto Digital), saúde, serviços e '
          'turismo. Mercado de trabalho diversificado.',
      jobNotesEs:
          'Hub tecnológico del Nordeste (Porto Digital), salud, servicios y '
          'turismo. Mercado laboral diversificado.',
      jobNotesEn:
          'Northeast tech hub (Porto Digital), healthcare, services, and tourism. '
          'Diversified job market.',
    ),

    'salvador': CitySeasonalityData(
      severity: CitySeasonalitySeverity.medium,
      peakMonths: [12, 1, 2, 7],
      lowMonths: [4, 5, 6],
      visitorsLabelPt: 'Maior Carnaval do mundo — jan–fev pico máximo',
      visitorsLabelEs: 'Carnaval más grande del mundo — ene–feb pico máximo',
      visitorsLabelEn: 'World\'s largest Carnival — Jan–Feb absolute peak',
      rentNotesPt:
          'Terceira maior cidade do Brasil com demanda estável. Pelourinho e '
          'Barra ficam caros no Carnaval mas bairros residenciais mantêm preços '
          'razoáveis o ano todo.',
      rentNotesEs:
          'Tercera ciudad más grande de Brasil con demanda estable. Pelourinho y '
          'Barra se encarecen en Carnaval pero los barrios residenciales mantienen '
          'precios razonables todo el año.',
      rentNotesEn:
          'Brazil\'s third largest city with stable demand. Pelourinho and Barra '
          'get expensive at Carnival but residential neighborhoods stay '
          'affordable year-round.',
      jobNotesPt:
          'Petróleo, turismo, serviços e produção cultural. Mercado de trabalho '
          'robusto para o padrão nordestino.',
      jobNotesEs:
          'Petróleo, turismo, servicios y producción cultural. Mercado laboral '
          'robusto para el estándar del Nordeste.',
      jobNotesEn:
          'Oil, tourism, services, and cultural production. Strong job market by '
          'Northeast standards.',
    ),

    'porto-seguro': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 2, 7],
      lowMonths: [4, 5, 6],
      visitorsLabelPt: 'Destino famílias e jovens — pico dez–fev e julho',
      visitorsLabelEs: 'Destino familias y jóvenes — pico dic–feb y julio',
      visitorsLabelEn: 'Families & youth destination — peaks Dec–Feb & July',
      rentNotesPt:
          'Arraial d\'Ajuda e Trancoso (distritos) praticamente trancam o mercado '
          'de aluguel de longa duração no verão. Centro de Porto Seguro tem '
          'mais oferta.',
      rentNotesEs:
          'Arraial d\'Ajuda y Trancoso (distritos) prácticamente bloquean el '
          'mercado de alquiler a largo plazo en verano. El centro de Porto Seguro '
          'tiene más oferta.',
      rentNotesEn:
          'Arraial d\'Ajuda and Trancoso (districts) essentially lock up the '
          'long-term rental market in summer. Porto Seguro\'s center has more '
          'supply.',
      jobNotesPt:
          'Turismo domina completamente. Descobrimento do Brasil foi aqui — forte '
          'turismo histórico + praia. Empregos formais muito sazonais.',
      jobNotesEs:
          'El turismo domina completamente. El descubrimiento de Brasil fue aquí '
          '— fuerte turismo histórico + playa. Empleos formales muy estacionales.',
      jobNotesEn:
          'Tourism dominates completely. Discovery of Brazil happened here — '
          'strong historical + beach tourism. Formal jobs are highly seasonal.',
    ),

    'tibau-do-sul': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 7],
      lowMonths: [4, 5, 6],
      visitorsLabelPt: 'Pipa — destino cult e internacional',
      visitorsLabelEs: 'Pipa — destino cult e internacional',
      visitorsLabelEn: 'Pipa — cult and international destination',
      rentNotesPt:
          'Tibau do Sul (onde fica Praia de Pipa) é um destino cult. Alta '
          'temporada provoca escassez extrema de moradia. Fora do pico é paraíso '
          'para nômades digitais.',
      rentNotesEs:
          'Tibau do Sul (donde está Praia de Pipa) es un destino cult. La '
          'temporada alta provoca escasez extrema de vivienda. Fuera del pico es '
          'un paraíso para nómades digitales.',
      rentNotesEn:
          'Tibau do Sul (home of Praia de Pipa) is a cult destination. Peak season '
          'causes extreme housing scarcity. Off-peak it\'s paradise for digital '
          'nomads.',
      jobNotesPt:
          'Turismo e kitesurf. Muito procurado por estrangeiros — nível de inglês '
          'local mais alto que a média. Empregos formais escassos.',
      jobNotesEs:
          'Turismo y kitesurf. Muy buscado por extranjeros — nivel de inglés '
          'local más alto que el promedio. Empleos formales escasos.',
      jobNotesEn:
          'Tourism and kitesurfing. Popular with foreigners — local English level '
          'above average. Formal jobs are scarce.',
    ),

    'jijoca-de-jericoacoara': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 7],
      lowMonths: [4, 5, 6],
      visitorsLabelPt: 'Jericoacoara — top 10 praias do mundo',
      visitorsLabelEs: 'Jericoacoara — top 10 playas del mundo',
      visitorsLabelEn: 'Jericoacoara — top 10 beaches in the world',
      rentNotesPt:
          'Acesso por trilha na areia — sem asfalto. Turismo de luxo e aventura. '
          'Moradia de longa duração é muito difícil na alta; fora dela, há '
          'comunidade de expats estável.',
      rentNotesEs:
          'Acceso por pista en arena — sin asfalto. Turismo de lujo y aventura. '
          'La vivienda a largo plazo es muy difícil en temporada alta; fuera de '
          'ella hay una comunidad estable de expats.',
      rentNotesEn:
          'Access via sand track — no pavement. Luxury and adventure tourism. '
          'Long-term housing is very difficult in peak season; off-season there\'s '
          'a stable expat community.',
      jobNotesPt:
          'Buggy, kitesurf e pousadas de luxo. Salários acima da média regional '
          'mas mercado muito pequeno. Indicado para autônomos e nômades.',
      jobNotesEs:
          'Buggy, kitesurf y posadas de lujo. Salarios por encima del promedio '
          'regional pero mercado muy pequeño. Indicado para autónomos y nómades.',
      jobNotesEn:
          'Buggies, kitesurfing, and luxury guesthouses. Above-average regional '
          'wages but very small market. Best for freelancers and nomads.',
    ),

    'sao-miguel-do-gostoso': CitySeasonalityData(
      severity: CitySeasonalitySeverity.high,
      peakMonths: [12, 1, 7],
      lowMonths: [4, 5, 6],
      visitorsLabelPt: 'Capital mundial do kitesurf — pico no verão e julho',
      visitorsLabelEs: 'Capital mundial del kitesurf — pico en verano y julio',
      visitorsLabelEn: 'World kitesurf capital — peaks in summer and July',
      rentNotesPt:
          'Cidade pequena com forte fluxo de kitesurfistas internacionais. '
          'Alta temporada escoa toda a oferta de moradia. Fora do pico é '
          'tranquila e barata.',
      rentNotesEs:
          'Ciudad pequeña con fuerte flujo de kitesurfistas internacionales. '
          'La temporada alta agota toda la oferta de vivienda. Fuera del pico '
          'es tranquila y barata.',
      rentNotesEn:
          'Small city with heavy international kitesurf traffic. Peak season '
          'drains all housing supply. Off-peak it\'s quiet and cheap.',
      jobNotesPt:
          'Kitesurf, pousadas e restaurantes. Comunidade de expats crescente. '
          'Nível de inglês e espanhol local acima da média nordestina.',
      jobNotesEs:
          'Kitesurf, posadas y restaurantes. Comunidad de expats en crecimiento. '
          'Nivel de inglés y español local por encima del promedio del Nordeste.',
      jobNotesEn:
          'Kitesurfing, guesthouses, and restaurants. Growing expat community. '
          'Local English and Spanish levels above Northeast average.',
    ),
  };
}
