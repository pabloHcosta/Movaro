import 'package:movaro_app/features/home/domain/city_feed_item.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_detail_payloads.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';

/// Static curated feed content for the City Feed.
///
/// V1 is fully curated (no external API). Content is localized using the
/// passed [locale] language code. Each item carries city and stage filters.
class CityFeedDatasource {
  const CityFeedDatasource._();

  static List<CityFeedItem> build({
    required String? cityCode,
    required UserJourneyStage stage,
    required String locale,
    City? city,
    CityWeather? weather,
    CityDetailSocialProof? socialProof,
    CityDetailClimateSummary? climateSummary,
    CityDetailArrivalStory? arrivalStory,
    CityDetailComparison? comparison,
    GuideActionItem? guideCurrentItem,
  }) {
    final dynamicItems = _dynamicItems(
      locale,
      stage: stage,
      city: city,
      weather: weather,
      socialProof: socialProof,
      climateSummary: climateSummary,
      arrivalStory: arrivalStory,
      comparison: comparison,
      guideCurrentItem: guideCurrentItem,
    );
    final seenIds = dynamicItems.map((item) => item.id).toSet();
    final hasRealCost = city?.budgetSnapshot != null;
    final hasRealClimate = climateSummary != null || weather != null;
    final hasRealSocial = socialProof != null;
    final fallbackItems = _all(locale)
        .where((item) => item.isRelevantFor(cityCode: cityCode, stage: stage))
        .where((item) => !seenIds.contains(item.id))
        .where(
          (item) =>
              !(hasRealCost && item.type == CityFeedItemType.costUpdate) &&
              !(hasRealSocial && item.type == CityFeedItemType.migrantStory) &&
              !(hasRealClimate &&
                  item.id.startsWith('lifestyle_') &&
                  (item.cityCodes.isNotEmpty || cityCode != null)),
        )
        .toList();

    return [...dynamicItems, ...fallbackItems];
  }

  static String _t(
    String locale, {
    required String pt,
    required String es,
    required String en,
  }) => switch (locale) {
    'pt' => pt,
    'es' => es,
    _ => en,
  };

  static List<CityFeedItem> _all(String locale) => [
    // ── COST UPDATES ────────────────────────────────────────────────────────
    CityFeedItem(
      id: 'cost_sp_rent_2024',
      type: CityFeedItemType.costUpdate,
      badge: _t(locale, pt: 'São Paulo', es: 'São Paulo', en: 'São Paulo'),
      title: _t(
        locale,
        pt: 'Aluguel em SP: o que esperar',
        es: 'Alquiler en SP: que esperar',
        en: 'Rent in SP: what to expect',
      ),
      body: _t(
        locale,
        pt: 'Kitnet/studio: R\$1.200–2.200 · Apartamento 1 quarto: R\$2.000–3.500 · Quarto em rep: R\$800–1.400. Centro expandido e Zona Sul têm melhor custo-benefício.',
        es: 'Monoambiente/studio: R\$1.200–2.200 · Depto 1 amb: R\$2.000–3.500 · Habitacion compartida: R\$800–1.400. Centro expandido y Zona Sur tienen mejor relacion precio-calidad.',
        en: 'Studio: R\$1,200–2,200 · 1-bed apartment: R\$2,000–3,500 · Shared room: R\$800–1,400. Centro and Zona Sul offer best value.',
      ),
      cityCodes: const ['sao-paulo', 'sp'],
      sourceLabel: _curatedSourceLabel(locale),
    ),

    CityFeedItem(
      id: 'cost_floripa_rent_2024',
      type: CityFeedItemType.costUpdate,
      badge: _t(
        locale,
        pt: 'Florianópolis',
        es: 'Florianopolis',
        en: 'Florianópolis',
      ),
      title: _t(
        locale,
        pt: 'Custo de vida em Floripa',
        es: 'Costo de vida en Floripa',
        en: 'Cost of living in Floripa',
      ),
      body: _t(
        locale,
        pt: 'Aluguel 1 quarto: R\$1.800–3.200 (mais barato fora da praia). Alimentação: R\$1.200–2.000/mês. Transporte: R\$200–400. Total estimado solo: R\$4.000–6.500/mês.',
        es: 'Alquiler 1 amb: R\$1.800–3.200 (mas barato lejos de la playa). Comida: R\$1.200–2.000/mes. Transporte: R\$200–400. Total estimado solo: R\$4.000–6.500/mes.',
        en: 'Studio rental: R\$1,800–3,200 (cheaper inland). Food: R\$1,200–2,000/month. Transport: R\$200–400. Estimated solo: R\$4,000–6,500/month.',
      ),
      cityCodes: const ['florianopolis', 'floripa'],
      sourceLabel: _curatedSourceLabel(locale),
    ),

    CityFeedItem(
      id: 'cost_curitiba_rent_2024',
      type: CityFeedItemType.costUpdate,
      badge: _t(locale, pt: 'Curitiba', es: 'Curitiba', en: 'Curitiba'),
      title: _t(
        locale,
        pt: 'Curitiba: a mais acessível do Sul',
        es: 'Curitiba: la mas accesible del Sur',
        en: 'Curitiba: most affordable in the South',
      ),
      body: _t(
        locale,
        pt: 'Aluguel studio: R\$1.200–2.000 · Bairro Água Verde e Portão têm bom custo-benefício. Custo de vida ~20% menor que São Paulo com qualidade de vida alta.',
        es: 'Alquiler studio: R\$1.200–2.000 · Barrios Agua Verde y Portao tienen buena relacion precio-calidad. Costo de vida ~20% menor que SP con alta calidad de vida.',
        en: 'Studio: R\$1,200–2,000 · Água Verde and Portão neighborhoods offer best value. Cost of living ~20% lower than SP with high quality of life.',
      ),
      cityCodes: const ['curitiba'],
      sourceLabel: _curatedSourceLabel(locale),
    ),

    CityFeedItem(
      id: 'cost_rj_rent_2024',
      type: CityFeedItemType.costUpdate,
      badge: _t(
        locale,
        pt: 'Rio de Janeiro',
        es: 'Rio de Janeiro',
        en: 'Rio de Janeiro',
      ),
      title: _t(
        locale,
        pt: 'Morar no Rio: o que custa',
        es: 'Vivir en Rio: cuanto cuesta',
        en: 'Living in Rio: the real cost',
      ),
      body: _t(
        locale,
        pt: 'Botafogo, Flamengo e Laranjeiras: R\$1.800–3.500 1 quarto. Evite Zona Norte para morar inicialmente — logística mais difícil para estrangeiro. Barra e Recreio têm metro metragem maior por menos.',
        es: 'Botafogo, Flamengo y Laranjeiras: R\$1.800–3.500 1 amb. Evita Zona Norte al principio — logistica mas dificil para extranjero. Barra y Recreio tienen mas metros por menos.',
        en: 'Botafogo, Flamengo, Laranjeiras: R\$1,800–3,500 for 1 bed. Avoid Zona Norte initially — harder logistics for newcomers. Barra and Recreio offer more space for less.',
      ),
      cityCodes: const ['rio-de-janeiro', 'rj'],
      sourceLabel: _curatedSourceLabel(locale),
    ),

    CityFeedItem(
      id: 'cost_poa_rent_2024',
      type: CityFeedItemType.costUpdate,
      badge: _t(
        locale,
        pt: 'Porto Alegre',
        es: 'Porto Alegre',
        en: 'Porto Alegre',
      ),
      title: _t(
        locale,
        pt: 'Porto Alegre: salários e custos',
        es: 'Porto Alegre: salarios y costos',
        en: 'Porto Alegre: salaries and costs',
      ),
      body: _t(
        locale,
        pt: 'Aluguel 1 quarto: R\$1.400–2.400 · Bairros Moinhos de Vento e Bom Fim são os mais populares entre migrantes. Custo total estimado: R\$3.500–5.500/mês.',
        es: 'Alquiler 1 amb: R\$1.400–2.400 · Barrios Moinhos de Vento y Bom Fim son los mas populares entre migrantes. Costo total estimado: R\$3.500–5.500/mes.',
        en: '1-bed rental: R\$1,400–2,400 · Moinhos de Vento and Bom Fim are most popular with migrants. Estimated total: R\$3,500–5,500/month.',
      ),
      cityCodes: const ['porto-alegre'],
      sourceLabel: _curatedSourceLabel(locale),
    ),

    // ── SALARY INTELLIGENCE ─────────────────────────────────────────────────
    CityFeedItem(
      id: 'salary_tech_sp',
      type: CityFeedItemType.opportunity,
      title: _t(
        locale,
        pt: 'Quanto se ganha em TI no Brasil',
        es: 'Cuanto se gana en IT en Brasil',
        en: 'Tech salaries in Brazil',
      ),
      body: _t(
        locale,
        pt: 'Desenvolvedor pleno: R\$6.000–14.000 · UX Designer: R\$4.500–9.000 · Product Manager: R\$8.000–18.000 · QA/Tester: R\$3.500–7.000. Salários remotos (~35% do mercado) tendem a ser maiores.',
        es: 'Desarrollador mid: R\$6.000–14.000 · UX Designer: R\$4.500–9.000 · Product Manager: R\$8.000–18.000 · QA/Tester: R\$3.500–7.000. Salarios remotos (~35% del mercado) suelen ser mayores.',
        en: 'Mid developer: R\$6,000–14,000 · UX Designer: R\$4,500–9,000 · Product Manager: R\$8,000–18,000 · QA: R\$3,500–7,000. Remote roles (~35% of market) tend to pay more.',
      ),
      stages: const [UserJourneyStage.explorer, UserJourneyStage.planner],
    ),

    CityFeedItem(
      id: 'salary_freelancer',
      type: CityFeedItemType.opportunity,
      title: _t(
        locale,
        pt: 'Freelancer argentino no Brasil: como funciona',
        es: 'Freelancer argentino en Brasil: como funciona',
        en: 'Argentine freelancer in Brazil: how it works',
      ),
      body: _t(
        locale,
        pt: 'MEI permite faturar até R\$81.000/ano com impostos fixos baixos (~R\$70/mês). Plataformas que aceitam CPF: Workana, 99Freelas, GetNinjas. Upwork e Fiverr aceitam antes do CPF.',
        es: 'MEI permite facturar hasta R\$81.000/ano con impuestos fijos bajos (~R\$70/mes). Plataformas que aceptan CPF: Workana, 99Freelas, GetNinjas. Upwork y Fiverr aceptan antes del CPF.',
        en: 'MEI allows up to R\$81,000/year with low fixed taxes (~R\$70/month). Platforms accepting CPF: Workana, 99Freelas, GetNinjas. Upwork and Fiverr work before CPF.',
      ),
      stages: const [UserJourneyStage.planner, UserJourneyStage.executor],
    ),

    // ── PRACTICAL TIPS ──────────────────────────────────────────────────────
    CityFeedItem(
      id: 'tip_housing_no_fiador',
      type: CityFeedItemType.practicalTip,
      title: _t(
        locale,
        pt: 'Alugar sem fiador: 3 caminhos reais',
        es: 'Alquilar sin garante: 3 caminos reales',
        en: 'Renting without a guarantor: 3 real paths',
      ),
      body: _t(
        locale,
        pt: '1. QuintoAndar: aceita seguro-fiança, processo 100% digital. 2. Facebook Marketplace: direto com proprietário, sem imobiliária. 3. Airbnb mensal: R\$1.800–3.500, cobre endereço para CPF.',
        es: '1. QuintoAndar: acepta seguro-fianza, proceso 100% digital. 2. Facebook Marketplace: directo con propietario, sin inmobiliaria. 3. Airbnb mensual: R\$1.800–3.500, cubre direccion para CPF.',
        en: '1. QuintoAndar: accepts rental insurance, 100% digital process. 2. Facebook Marketplace: direct from owner, no agency. 3. Monthly Airbnb: R\$1,800–3,500, covers address for CPF.',
      ),
      stages: const [UserJourneyStage.planner, UserJourneyStage.executor],
    ),

    CityFeedItem(
      id: 'tip_bank_first',
      type: CityFeedItemType.practicalTip,
      title: _t(
        locale,
        pt: 'Primeiro banco: por onde começar',
        es: 'Primer banco: por donde empezar',
        en: 'First bank account: where to start',
      ),
      body: _t(
        locale,
        pt: 'Comece pelo banco que pedir menos fricção para abrir conta com CPF e documento. Se um banco digital recusar, tente outro ou vá para uma agência tradicional com comprovante de endereço.',
        es: 'Empieza por el banco que pida menos friccion para abrir cuenta con CPF y documento. Si un banco digital rechaza, prueba otro o ve a una sucursal tradicional con comprobante de domicilio.',
        en: 'Start with the bank that creates the least friction for opening an account with CPF and ID. If one digital bank rejects you, try another or go to a traditional branch with proof of address.',
      ),
      stages: const [UserJourneyStage.executor],
      guideItemId: 'item_3_1_conta_bancaria',
      sourceLabel: _curatedSourceLabel(locale),
    ),

    CityFeedItem(
      id: 'tip_cpf_fast',
      type: CityFeedItemType.practicalTip,
      title: _t(
        locale,
        pt: 'CPF nos Correios: o caminho mais rápido',
        es: 'CPF en Correios: el camino mas rapido',
        en: 'CPF at Correios: the fastest route',
      ),
      body: _t(
        locale,
        pt: 'Se você deixar o CPF para o Brasil, resolva isso logo nos primeiros dias com seu endereço inicial em mãos. Correios e Receita entram como rotas usuais, mas confirme canal, custo e disponibilidade antes de sair.',
        es: 'Si dejas el CPF para Brasil, resuelvelo en los primeros dias con tu direccion inicial a mano. Correios y Receita suelen ser rutas comunes, pero confirma canal, costo y disponibilidad antes de salir.',
        en: 'If you leave CPF for Brazil, handle it in the first days with your initial address ready. Correios and Receita are common routes, but confirm channel, cost, and availability before you go.',
      ),
      stages: const [UserJourneyStage.executor],
      guideItemId: 'item_2_1_cpf',
      sourceLabel: _curatedSourceLabel(locale),
    ),

    CityFeedItem(
      id: 'tip_pf_appointment',
      type: CityFeedItemType.practicalTip,
      badge: _t(locale, pt: '⚠️ Urgente', es: '⚠️ Urgente', en: '⚠️ Urgent'),
      title: _t(
        locale,
        pt: 'Polícia Federal: agende ainda na Argentina',
        es: 'Policia Federal: saca el turno en Argentina',
        en: 'Federal Police: book while in Argentina',
      ),
      body: _t(
        locale,
        pt: 'Se sua cidade de chegada costuma ter fila, vale tentar o agendamento ainda antes do embarque. O portal oficial aceita essa consulta antecipada, mas o tempo real varia por unidade.',
        es: 'Si tu ciudad de llegada suele tener fila, conviene intentar el turno antes de viajar. El portal oficial permite esa consulta anticipada, pero el tiempo real varia por unidad.',
        en: 'If your arrival city tends to have backlogs, it is worth trying to book before you travel. The official portal allows that early check, but real wait times vary by unit.',
      ),
      stages: const [UserJourneyStage.planner, UserJourneyStage.executor],
      guideItemId: 'item_2_2_residencia',
      sourceLabel: _officialSourceLabel(locale),
      sourceUrl: 'https://servicos.pf.gov.br/agenda-web/acessar',
    ),

    CityFeedItem(
      id: 'tip_wise_airport',
      type: CityFeedItemType.practicalTip,
      title: _t(
        locale,
        pt: 'Não troque dinheiro no aeroporto',
        es: 'No cambies dinero en el aeropuerto',
        en: 'Don\'t exchange money at the airport',
      ),
      body: _t(
        locale,
        pt: 'Câmbio de aeroporto cobra 30–50% acima da taxa real. Configure Wise ou Remitly antes de viajar — são até 8x mais baratos. Leve R\$300–500 em espécie como backup.',
        es: 'El cambio del aeropuerto cobra 30–50% sobre la tasa real. Configura Wise o Remitly antes de viajar — son hasta 8x mas baratos. Lleva R\$300–500 en efectivo como respaldo.',
        en: 'Airport exchange charges 30–50% above the real rate. Set up Wise or Remitly before traveling — up to 8x cheaper. Carry R\$300–500 cash as backup.',
      ),
      stages: const [UserJourneyStage.planner, UserJourneyStage.executor],
    ),

    // ── MIGRANT STORIES ─────────────────────────────────────────────────────
    CityFeedItem(
      id: 'story_pablo_sp',
      type: CityFeedItemType.migrantStory,
      title: _t(
        locale,
        pt: '"Cheguei em SP sem nada. Em 3 meses estava trabalhando."',
        es: '"Llegue a SP sin nada. En 3 meses estaba trabajando."',
        en: '"I arrived in SP with nothing. In 3 months I had a job."',
      ),
      body: _t(
        locale,
        pt: 'Pablo, designer, 29. "Fui ao Correios no segundo dia, CPF saiu na hora. C6 Bank aprovou em 24h. Primeiro aluguel foi via QuintoAndar sem fiador. O mais difícil foi a PF — a fila era de 45 dias porque não agendei antes."',
        es: 'Pablo, disenador, 29. "Fui a Correios el segundo dia, CPF salio al instante. C6 Bank aprobo en 24h. Primer alquiler fue via QuintoAndar sin garante. Lo mas dificil fue la PF — la fila era de 45 dias porque no saque turno antes."',
        en: 'Pablo, designer, 29. "I went to Correios on day two, CPF issued on the spot. C6 Bank approved in 24h. First rental through QuintoAndar without a guarantor. The hardest part was the PF — 45-day wait because I hadn\'t booked in advance."',
      ),
      cityCodes: const ['sao-paulo', 'sp'],
      sourceLabel: _communitySourceLabel(locale),
    ),

    CityFeedItem(
      id: 'story_lucia_floripa',
      type: CityFeedItemType.migrantStory,
      title: _t(
        locale,
        pt: '"Floripa foi melhor do que eu esperava — mas é cara."',
        es: '"Floripa fue mejor de lo que esperaba — pero es cara."',
        en: '"Floripa was better than I expected — but it\'s expensive."',
      ),
      body: _t(
        locale,
        pt: 'Lucía, professora de yoga, 32. "O custo de vida me pegou de surpresa — achei que seria mais barato que SP. Mas a qualidade de vida compensa. Encontrei quarto compartilhado em grupo do Facebook por R\$1.100/mês."',
        es: 'Lucia, profesora de yoga, 32. "El costo de vida me sorprendio — pense que seria mas barato que SP. Pero la calidad de vida lo vale. Encontre habitacion compartida en grupo de Facebook por R\$1.100/mes."',
        en: 'Lucía, yoga teacher, 32. "Cost of living caught me off guard — I thought it would be cheaper than SP. But the quality of life makes up for it. Found a shared room in a Facebook group for R\$1,100/month."',
      ),
      cityCodes: const ['florianopolis', 'floripa'],
      sourceLabel: _communitySourceLabel(locale),
    ),

    CityFeedItem(
      id: 'story_martin_cwb',
      type: CityFeedItemType.migrantStory,
      title: _t(
        locale,
        pt: '"Curitiba: o melhor custo-benefício para quem vem da Argentina."',
        es: '"Curitiba: la mejor relacion precio-calidad para quien viene de Argentina."',
        en: '"Curitiba: the best value for anyone coming from Argentina."',
      ),
      body: _t(
        locale,
        pt: 'Martín, contador, 41. "Escolhi Curitiba porque parecia mais familiar — a cultura é mais próxima de Buenos Aires do que SP. Aluguel de apartamento mobiliado por R\$2.200 com tudo incluso. Vida excelente."',
        es: 'Martin, contador, 41. "Elegí Curitiba porque parecia mas familiar — la cultura es mas cercana a Buenos Aires que SP. Departamento amoblado por R\$2.200 con todo incluido. Vida excelente."',
        en: 'Martín, accountant, 41. "I chose Curitiba because it felt more familiar — the culture is closer to Buenos Aires than SP. Furnished apartment for R\$2,200 all included. Excellent quality of life."',
      ),
      cityCodes: const ['curitiba'],
      sourceLabel: _communitySourceLabel(locale),
    ),

    CityFeedItem(
      id: 'story_generic_bank',
      type: CityFeedItemType.migrantStory,
      title: _t(
        locale,
        pt: '"Nubank me recusou 2 vezes. C6 aprovou em 20 minutos."',
        es: '"Nubank me rechazo 2 veces. C6 aprobo en 20 minutos."',
        en: '"Nubank rejected me twice. C6 approved in 20 minutes."',
      ),
      body: _t(
        locale,
        pt: 'Andres, 35. "Fui pelo Nubank porque todo mundo usa. Recusado. Tentei Inter — recusado. C6 Bank: aprovado com CPF + passaporte em 20 minutos. Se você é novo no Brasil, comece pelo C6."',
        es: 'Andres, 35. "Fui por Nubank porque todo el mundo lo usa. Rechazado. Probe Inter — rechazado. C6 Bank: aprobado con CPF + pasaporte en 20 minutos. Si eres nuevo en Brasil, empieza por C6."',
        en: 'Andres, 35. "I went with Nubank because everyone uses it. Rejected. Tried Inter — rejected. C6 Bank: approved with CPF + passport in 20 minutes. If you\'re new to Brazil, start with C6."',
      ),
      sourceLabel: _communitySourceLabel(locale),
    ),

    // ── LIFESTYLE ────────────────────────────────────────────────────────────
    CityFeedItem(
      id: 'lifestyle_sp_day',
      type: CityFeedItemType.lifestyleTip,
      title: _t(
        locale,
        pt: 'Como é um dia típico em São Paulo',
        es: 'Como es un dia tipico en Sao Paulo',
        en: 'What a typical day in São Paulo looks like',
      ),
      body: _t(
        locale,
        pt: 'Metrô é a melhor opção para se locomover — evite carro. Almoço no boteco custa R\$18–35 (prato feito). Coworking nas Paulistas custa R\$40–70/dia. Parque Ibirapuera é de graça e lotado nos fins de semana.',
        es: 'Metro es la mejor opcion para moverse — evita el auto. Almuerzo en boteco cuesta R\$18–35 (plato del dia). Coworking en Paulistas cuesta R\$40–70/dia. Parque Ibirapuera es gratis y lleno los fines de semana.',
        en: 'Metro is the best way to get around — avoid driving. Lunch at a boteco costs R\$18–35 (daily special). Coworking on Paulistas costs R\$40–70/day. Parque Ibirapuera is free and packed on weekends.',
      ),
      cityCodes: const ['sao-paulo', 'sp'],
      stages: const [UserJourneyStage.explorer, UserJourneyStage.planner],
    ),

    CityFeedItem(
      id: 'lifestyle_floripa_beach',
      type: CityFeedItemType.lifestyleTip,
      title: _t(
        locale,
        pt: 'Floripa não é só praia — e a temporada muda tudo',
        es: 'Floripa no es solo playa — y la temporada cambia todo',
        en: 'Floripa is not just beaches — and the season changes everything',
      ),
      body: _t(
        locale,
        pt: 'Verão (dez–mar): preços dobrando, trânsito caótico, turistas por todo lado. Inverno (jun–ago): calmo, preços razoáveis — melhor época para se instalar. Trabalho remoto funciona muito bem fora da temporada.',
        es: 'Verano (dic–mar): precios duplicandose, trafico caotico, turistas por todos lados. Invierno (jun–ago): tranquilo, precios razonables — mejor epoca para instalarse. Trabajo remoto funciona muy bien fuera de temporada.',
        en: 'Summer (Dec–Mar): prices double, traffic chaotic, tourists everywhere. Winter (Jun–Aug): calm, reasonable prices — best time to settle in. Remote work works very well outside peak season.',
      ),
      cityCodes: const ['florianopolis', 'floripa'],
      stages: const [UserJourneyStage.explorer, UserJourneyStage.planner],
    ),

    // ── WARNINGS ────────────────────────────────────────────────────────────
    CityFeedItem(
      id: 'warning_rental_scam',
      type: CityFeedItemType.warning,
      badge: _t(locale, pt: 'Alerta', es: 'Alerta', en: 'Warning'),
      title: _t(
        locale,
        pt: 'Golpe do aluguel: como funciona',
        es: 'Estafa del alquiler: como funciona',
        en: 'Rental scam: how it works',
      ),
      body: _t(
        locale,
        pt: 'Anúncio com fotos bonitas, preço abaixo do mercado, proprietário "no exterior". Pedem depósito antes da visita. Sinal: nunca vi o imóvel, nunca falei por vídeo, pressa para fechar. Regra: nunca pague sem visitar pessoalmente.',
        es: 'Anuncio con fotos bonitas, precio por debajo del mercado, propietario "en el exterior". Piden deposito antes de la visita. Senal: nunca vi el inmueble, nunca hable por video, prisa para cerrar. Regla: nunca pagues sin visitar en persona.',
        en: 'Nice photos, below-market price, landlord "abroad". Deposit demanded before viewing. Signs: never saw the property, never spoke by video, pressure to close fast. Rule: never pay without visiting in person.',
      ),
    ),

    CityFeedItem(
      id: 'warning_job_scam',
      type: CityFeedItemType.warning,
      badge: _t(locale, pt: 'Alerta', es: 'Alerta', en: 'Warning'),
      title: _t(
        locale,
        pt: 'Oferta de emprego suspeita: 3 sinais',
        es: 'Oferta de trabajo sospechosa: 3 senales',
        en: 'Suspicious job offer: 3 red flags',
      ),
      body: _t(
        locale,
        pt: '1. Salário muito acima do mercado. 2. Pede pagamento antecipado por "material" ou "treinamento". 3. Empresa sem presença no LinkedIn ou CNPJ verificável. Verifique sempre pelo CNPJ no site da Receita Federal.',
        es: '1. Salario muy por encima del mercado. 2. Pide pago anticipado por "material" o "capacitacion". 3. Empresa sin presencia en LinkedIn o CNPJ verificable. Verifica siempre por CNPJ en el sitio de Receita Federal.',
        en: '1. Salary far above market. 2. Asks for upfront payment for "materials" or "training". 3. Company has no LinkedIn presence or verifiable CNPJ. Always verify via CNPJ on the Receita Federal website.',
      ),
    ),

    // ── OPPORTUNITIES ────────────────────────────────────────────────────────
    CityFeedItem(
      id: 'opportunity_mei_income',
      type: CityFeedItemType.opportunity,
      title: _t(
        locale,
        pt: 'MEI: a forma mais simples de trabalhar no Brasil',
        es: 'MEI: la forma mas simple de trabajar en Brasil',
        en: 'MEI: the simplest way to work in Brazil',
      ),
      body: _t(
        locale,
        pt: 'Microempreendedor Individual (MEI): abra em 10 min pelo Gov.br, fature até R\$81.000/ano, pague ~R\$70/mês de imposto fixo. Ideal para freelancers, consultores e quem recebe da Argentina. Exige CPF.',
        es: 'Microemprendedor Individual (MEI): abra en 10 min por Gov.br, facture hasta R\$81.000/ano, pague ~R\$70/mes de impuesto fijo. Ideal para freelancers, consultores y quien cobra de Argentina. Requiere CPF.',
        en: 'Individual Microentrepreneur (MEI): open in 10 min on Gov.br, bill up to R\$81,000/year, pay ~R\$70/month flat tax. Ideal for freelancers, consultants, and those receiving from Argentina. Requires CPF.',
      ),
      stages: const [UserJourneyStage.planner, UserJourneyStage.executor],
    ),

    CityFeedItem(
      id: 'opportunity_remote_arg',
      type: CityFeedItemType.opportunity,
      title: _t(
        locale,
        pt: 'Recebendo da Argentina no Brasil: como fazer',
        es: 'Cobrar de Argentina en Brasil: como hacerlo',
        en: 'Getting paid from Argentina in Brazil: how it works',
      ),
      body: _t(
        locale,
        pt: 'Wise ou Payoneer recebem ARS/USD e convertem para BRL com câmbio justo. MEI emite nota fiscal em reais para clientes argentinos. Obrigação de declarar renda em ambos os países — consulte um contador local.',
        es: 'Wise o Payoneer reciben ARS/USD y convierten a BRL con cambio justo. MEI emite factura en reales para clientes argentinos. Obligacion de declarar ingresos en ambos paises — consulta un contador local.',
        en: 'Wise or Payoneer receive ARS/USD and convert to BRL at fair rates. MEI issues invoices in BRL for Argentine clients. You must declare income in both countries — consult a local accountant.',
      ),
      stages: const [UserJourneyStage.planner, UserJourneyStage.executor],
    ),

    CityFeedItem(
      id: 'opportunity_explorer_question',
      type: CityFeedItemType.lifestyleTip,
      title: _t(
        locale,
        pt: 'Antes de decidir: as 3 perguntas certas',
        es: 'Antes de decidir: las 3 preguntas correctas',
        en: 'Before deciding: the 3 right questions',
      ),
      body: _t(
        locale,
        pt: '1. Minha renda em BRL cobre o custo básico? (mínimo ~R\$4.000/mês solo). 2. Tenho 3 meses de reserva para imprevistos? 3. Existe algo concreto me esperando (trabalho, escola, família)? Sim para as 3 = hora de planejar.',
        es: '1. ¿Mis ingresos en BRL cubren el costo basico? (minimo ~R\$4.000/mes solo). 2. ¿Tengo 3 meses de reserva para imprevistos? 3. ¿Hay algo concreto esperandome (trabajo, escuela, familia)? Si para las 3 = hora de planificar.',
        en: '1. Does my income in BRL cover basic costs? (minimum ~R\$4,000/month solo). 2. Do I have 3 months of savings for unexpected costs? 3. Is there something concrete waiting for me (job, school, family)? Yes to all 3 = time to plan.',
      ),
      stages: const [UserJourneyStage.explorer],
    ),
  ];

  static List<CityFeedItem> _dynamicItems(
    String locale, {
    required UserJourneyStage stage,
    City? city,
    CityWeather? weather,
    CityDetailSocialProof? socialProof,
    CityDetailClimateSummary? climateSummary,
    CityDetailArrivalStory? arrivalStory,
    CityDetailComparison? comparison,
    GuideActionItem? guideCurrentItem,
  }) {
    final items = <CityFeedItem>[];

    if (guideCurrentItem != null) {
      items.add(
        CityFeedItem(
          id: 'guide_now_${guideCurrentItem.id}',
          type: switch (guideCurrentItem.urgencyLevel) {
            GuideUrgencyLevel.urgent ||
            GuideUrgencyLevel.critical => CityFeedItemType.warning,
            _ => CityFeedItemType.practicalTip,
          },
          badge: _phaseLabel(locale, guideCurrentItem.phase),
          title: _t(
            locale,
            pt: 'Agora: ${guideCurrentItem.title}',
            es: 'Ahora: ${guideCurrentItem.title}',
            en: 'Now: ${guideCurrentItem.title}',
          ),
          body:
              guideCurrentItem.urgencySignal ??
              guideCurrentItem.whyItMatters ??
              guideCurrentItem.shortDescription,
          guideItemId: guideCurrentItem.id,
        ),
      );
    }

    final budget = city?.budgetSnapshot;
    if (city != null && budget != null) {
      items.add(
        CityFeedItem(
          id: 'real_budget_${city.id}',
          type: CityFeedItemType.costUpdate,
          badge: city.name,
          title: _t(
            locale,
            pt: 'Quanto custa viver em ${city.name}',
            es: 'Cuanto cuesta vivir en ${city.name}',
            en: 'What it costs to live in ${city.name}',
          ),
          body: _t(
            locale,
            pt: 'Base real da cidade: viver no modo enxuto começa perto de R\$${budget.fairLivingTotal}; com mais folga, R\$${budget.wellLivingTotal}. Fonte: ${budget.sourceLabel}.',
            es: 'Base real de la ciudad: vivir en modo ajustado empieza cerca de R\$${budget.fairLivingTotal}; con mas margen, R\$${budget.wellLivingTotal}. Fuente: ${budget.sourceLabel}.',
            en: 'Real city baseline: lean living starts near R\$${budget.fairLivingTotal}; with more room, R\$${budget.wellLivingTotal}. Source: ${budget.sourceLabel}.',
          ),
          updatedAt: budget.updatedAt,
          sourceLabel: budget.sourceLabel,
          sourceUrl: budget.sourceUrl,
        ),
      );
    }

    final climate = climateSummary;
    if (city != null && climate != null) {
      final condition = climate.currentWeather.conditionLabel;
      final temp = climate.currentWeather.temperatureCelsius.round();
      final seasonality = climate.seasonality;
      final seasonalityText = seasonality == null
          ? null
          : _t(
              locale,
              pt: '${seasonality.visitorsLabel}. ${seasonality.rentNotes}',
              es: '${seasonality.visitorsLabel}. ${seasonality.rentNotes}',
              en: '${seasonality.visitorsLabel}. ${seasonality.rentNotes}',
            );
      items.add(
        CityFeedItem(
          id: 'real_climate_${city.id}',
          type: CityFeedItemType.lifestyleTip,
          badge: _t(
            locale,
            pt: 'Clima real',
            es: 'Clima real',
            en: 'Live climate',
          ),
          title: _t(
            locale,
            pt: 'Clima agora em ${city.name}',
            es: 'Clima ahora en ${city.name}',
            en: 'Weather now in ${city.name}',
          ),
          body: _t(
            locale,
            pt: 'Agora faz $temp°C e ${condition.toLowerCase()}. ${seasonalityText ?? ''}'
                .trim(),
            es: 'Ahora hace $temp°C y ${condition.toLowerCase()}. ${seasonalityText ?? ''}'
                .trim(),
            en: 'It is $temp°C and ${condition.toLowerCase()} now. ${seasonalityText ?? ''}'
                .trim(),
          ),
          sourceLabel: climate.sources.isEmpty
              ? null
              : climate.sources.first.label,
          sourceUrl: climate.sources.isEmpty ? null : climate.sources.first.url,
        ),
      );
    } else if (city != null && weather != null) {
      final fallbackCondition = _weatherCodeLabel(locale, weather.weatherCode);
      items.add(
        CityFeedItem(
          id: 'weather_${city.id}',
          type: CityFeedItemType.lifestyleTip,
          badge: _t(
            locale,
            pt: 'Clima real',
            es: 'Clima real',
            en: 'Live climate',
          ),
          title: _t(
            locale,
            pt: 'Clima agora em ${city.name}',
            es: 'Clima ahora en ${city.name}',
            en: 'Weather now in ${city.name}',
          ),
          body: _t(
            locale,
            pt: '${weather.temperatureCelsius.round()}°C agora, ${fallbackCondition.toLowerCase()}. Use isso como leitura do dia, não da estação inteira.',
            es: '${weather.temperatureCelsius.round()}°C ahora, ${fallbackCondition.toLowerCase()}. Usalo como lectura del dia, no de toda la estacion.',
            en: '${weather.temperatureCelsius.round()}°C now, ${fallbackCondition.toLowerCase()}. Use this as a day reading, not the whole season.',
          ),
        ),
      );
    }

    if (socialProof != null) {
      final opinion = socialProof.publicOpinion;
      final text =
          socialProof.routineInsight?.shortText ??
          socialProof.neighborhoodInsight?.shortText ??
          opinion?.summary;
      if (text != null && text.isNotEmpty) {
        items.add(
          CityFeedItem(
            id: 'social_${socialProof.cityId}',
            type: CityFeedItemType.migrantStory,
            badge: _t(
              locale,
              pt: 'Sinal social',
              es: 'Senal social',
              en: 'Social signal',
            ),
            title: _t(
              locale,
              pt: 'Como ${socialProof.cityName} aparece para quem já vive aí',
              es: 'Como se ve ${socialProof.cityName} para quien ya vive ahi',
              en: 'How ${socialProof.cityName} reads to people already there',
            ),
            body: text,
            sourceLabel:
                opinion?.provider ?? socialProof.sources.firstOrNull?.label,
            sourceUrl:
                opinion?.placeUrl ?? socialProof.sources.firstOrNull?.url,
          ),
        );
      }
    }

    if (arrivalStory != null) {
      final storyText = arrivalStory.story?.shortText;
      final firstNeighborhood = arrivalStory.neighborhoods.firstOrNull;
      final focus = arrivalStory.firstMonthFocus
          .take(2)
          .map((item) => item.label)
          .join(' + ');
      final body = [
        if (storyText != null && storyText.isNotEmpty) storyText,
        if (focus.isNotEmpty)
          _t(
            locale,
            pt: 'Primeiro foco: $focus.',
            es: 'Primer foco: $focus.',
            en: 'First focus: $focus.',
          ),
        if (firstNeighborhood != null)
          _t(
            locale,
            pt: 'Bom ponto para começar: ${firstNeighborhood.name}.',
            es: 'Buen punto para empezar: ${firstNeighborhood.name}.',
            en: 'Useful starting area: ${firstNeighborhood.name}.',
          ),
      ].join(' ');
      if (body.isNotEmpty) {
        items.add(
          CityFeedItem(
            id: 'arrival_${arrivalStory.cityId}',
            type: stage == UserJourneyStage.executor
                ? CityFeedItemType.practicalTip
                : CityFeedItemType.lifestyleTip,
            badge: _t(
              locale,
              pt: 'Primeiro mês',
              es: 'Primer mes',
              en: 'First month',
            ),
            title: _t(
              locale,
              pt: 'Como começar em ${arrivalStory.cityName}',
              es: 'Como empezar en ${arrivalStory.cityName}',
              en: 'How to start in ${arrivalStory.cityName}',
            ),
            body: body,
            sourceLabel: arrivalStory.sources.firstOrNull?.label,
            sourceUrl: arrivalStory.sources.firstOrNull?.url,
          ),
        );
      }
    }

    if (comparison != null && comparison.metrics.isNotEmpty) {
      final usefulMetric = comparison.metrics.firstWhere(
        (metric) => metric.primaryValue != null,
        orElse: () => comparison.metrics.first,
      );
      final best = usefulMetric.comparisons.firstWhere(
        (item) => item.cityId == comparison.cityId,
        orElse: () => usefulMetric.comparisons.first,
      );
      final competitors = usefulMetric.comparisons
          .where((item) => item.cityId != comparison.cityId)
          .toList(growable: false);
      if (competitors.isNotEmpty) {
        items.add(
          CityFeedItem(
            id: 'comparison_${comparison.cityId}',
            type: CityFeedItemType.opportunity,
            badge: _t(
              locale,
              pt: 'Comparativo',
              es: 'Comparativa',
              en: 'Comparison',
            ),
            title: _t(
              locale,
              pt: 'Como ${comparison.cityName} se compara',
              es: 'Como se compara ${comparison.cityName}',
              en: 'How ${comparison.cityName} compares',
            ),
            body: _t(
              locale,
              pt: '${usefulMetric.label}: ${comparison.cityName} está em ${best.value ?? '-'}${usefulMetric.unit}. Compare com ${competitors.map((item) => item.cityName).join(' e ')}.',
              es: '${usefulMetric.label}: ${comparison.cityName} esta en ${best.value ?? '-'}${usefulMetric.unit}. Comparalo con ${competitors.map((item) => item.cityName).join(' y ')}.',
              en: '${usefulMetric.label}: ${comparison.cityName} is at ${best.value ?? '-'}${usefulMetric.unit}. Compare it with ${competitors.map((item) => item.cityName).join(' and ')}.',
            ),
          ),
        );
      }
    }

    return items;
  }

  static String _phaseLabel(String locale, GuidePhase phase) => switch (phase) {
    GuidePhase.preparation => _t(
      locale,
      pt: 'Preparação',
      es: 'Preparacion',
      en: 'Preparation',
    ),
    GuidePhase.housing => _t(
      locale,
      pt: 'Moradia',
      es: 'Vivienda',
      en: 'Housing',
    ),
    GuidePhase.documents => _t(
      locale,
      pt: 'Documentos',
      es: 'Documentos',
      en: 'Documents',
    ),
    GuidePhase.work => _t(locale, pt: 'Trabalho', es: 'Trabajo', en: 'Work'),
    GuidePhase.arrival => _t(
      locale,
      pt: 'Chegada',
      es: 'Llegada',
      en: 'Arrival',
    ),
  };

  static String _curatedSourceLabel(String locale) => _t(
    locale,
    pt: 'Curadoria Movaro',
    es: 'Curaduria Movaro',
    en: 'Movaro curation',
  );

  static String _communitySourceLabel(String locale) => _t(
    locale,
    pt: 'Relato comunitário curado',
    es: 'Relato comunitario curado',
    en: 'Curated community story',
  );

  static String _officialSourceLabel(String locale) => _t(
    locale,
    pt: 'Fonte oficial',
    es: 'Fuente oficial',
    en: 'Official source',
  );

  static String _weatherCodeLabel(String locale, int? code) {
    if (code == null) {
      return _t(
        locale,
        pt: 'tempo estável',
        es: 'clima estable',
        en: 'stable weather',
      );
    }
    if (code == 0) {
      return _t(
        locale,
        pt: 'céu limpo',
        es: 'cielo despejado',
        en: 'clear skies',
      );
    }
    if ({1, 2, 3}.contains(code)) {
      return _t(
        locale,
        pt: 'tempo aberto',
        es: 'tiempo abierto',
        en: 'partly clear weather',
      );
    }
    if ({45, 48}.contains(code)) {
      return _t(locale, pt: 'névoa', es: 'niebla', en: 'fog');
    }
    if ({51, 53, 55, 56, 57}.contains(code)) {
      return _t(locale, pt: 'garoa', es: 'llovizna', en: 'drizzle');
    }
    if ({61, 63, 65, 66, 67, 80, 81, 82}.contains(code)) {
      return _t(locale, pt: 'chuva', es: 'lluvia', en: 'rain');
    }
    if ({71, 73, 75, 77, 85, 86}.contains(code)) {
      return _t(locale, pt: 'neve', es: 'nieve', en: 'snow');
    }
    if ({95, 96, 99}.contains(code)) {
      return _t(locale, pt: 'trovoadas', es: 'tormenta', en: 'thunderstorms');
    }
    return _t(
      locale,
      pt: 'tempo variável',
      es: 'clima variable',
      en: 'mixed weather',
    );
  }
}
