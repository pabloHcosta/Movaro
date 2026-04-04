import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/location/location_data.dart';

class ArgentinaBrazilGuideDataSource {
  const ArgentinaBrazilGuideDataSource._();

  static const List<_BrazilConsularPost> _argentinaConsularPosts = [
    _BrazilConsularPost(
      city: 'Buenos Aires',
      latitude: -34.6037,
      longitude: -58.3816,
      officialUrl: 'https://cgbuenosaires.itamaraty.gov.br',
    ),
    _BrazilConsularPost(
      city: 'Córdoba',
      latitude: -31.4201,
      longitude: -64.1888,
      officialUrl: 'https://cordoba.itamaraty.gov.br',
    ),
    _BrazilConsularPost(
      city: 'Mendoza',
      latitude: -32.8895,
      longitude: -68.8458,
      officialUrl: 'https://mendoza.itamaraty.gov.br',
    ),
    _BrazilConsularPost(
      city: 'Paso de los Libres',
      latitude: -29.7125,
      longitude: -57.0877,
      officialUrl: 'https://pasodeloslibres.itamaraty.gov.br',
    ),
    _BrazilConsularPost(
      city: 'Puerto Iguazú',
      latitude: -25.5972,
      longitude: -54.5786,
      officialUrl: 'https://puertoiguazu.itamaraty.gov.br',
    ),
  ];

  /// Returns `true` when the origin→destination pair matches Argentina→Brazil,
  /// regardless of whether values are ISO codes or journey values.
  static bool isArgentinaToBrazil(String origin, String destination) {
    final o = origin.toUpperCase();
    final d = destination.toUpperCase();
    return (o == 'ARGENTINA' || o == 'AR') &&
        (d == 'BRAZIL' || d == 'BR' || d == 'BRASIL');
  }

  static List<GuideActionItem> build(
    MigrationPlan plan, {
    LocationData? currentLocation,
    String? localeCode,
    CopilotExchangeRates? exchangeRates,
  }) {
    final locale = _locale(localeCode);
    final items = <GuideActionItem>[
      GuideActionItem(
        id: 'item_0_1_rule_90_days',
        title: _t(
          locale,
          pt: 'Entenda a regra dos 90 dias',
          es: 'Entiende la regla de los 90 dias',
          en: 'Understand the 90-day rule',
        ),
        shortDescription: _t(
          locale,
          pt: 'Você pode entrar no Brasil sem visto, mas precisa saber quando regularizar sua permanência.',
          es: 'Puedes entrar a Brasil sin visa, pero necesitas saber cuando regularizar tu estadia.',
          en: 'You can enter Brazil without a visa, but you need to know when to regularize your stay.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.preparation,
        orderIndex: 0,
        isCompleted: false,
        icon: Icons.schedule_rounded,
        context: _t(
          locale,
          pt: 'Essa regra define o tempo que você tem para entrar e se organizar sem ficar irregular.',
          es: 'Esta regla define cuanto tiempo tienes para entrar y organizarte sin quedar irregular.',
          en: 'This rule defines how long you have to enter and get organized without becoming irregular.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Se você ignorar esse prazo, pode travar sua regularização logo no começo.',
          es: 'Si ignoras este plazo, puedes trabar tu regularizacion muy al principio.',
          en: 'If you ignore this deadline, you can stall your regularization right at the start.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Ver regra oficial',
          es: 'Ver regla oficial',
          en: 'See official rule',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks
            .argentinaResidenceAgreement
            .toString(),
        steps: _list(
          locale,
          pt: [
            'Confirme a data em que você entra no Brasil.',
            'Considere esses 90 dias como sua janela para iniciar a residência.',
            'Organize CPF e documentação sem empurrar o processo para o fim do prazo.',
          ],
          es: [
            'Confirma la fecha en que entras a Brasil.',
            'Toma esos 90 dias como tu ventana para iniciar la residencia.',
            'Organiza CPF y documentacion sin dejar el proceso para el final.',
          ],
          en: [
            'Confirm the date you enter Brazil.',
            'Treat those 90 days as your window to start residency.',
            'Organize CPF and documents without pushing the process to the end.',
          ],
        ),
        requirements: _list(
          locale,
          pt: ['DNI ou passaporte válido'],
          es: ['DNI o pasaporte valido'],
          en: ['Valid national ID or passport'],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você sabe até quando precisa iniciar sua regularização e já organizou os próximos passos dentro desse prazo.',
          es: 'Ya sabes hasta cuando debes iniciar tu regularizacion y organizaste los proximos pasos dentro de ese plazo.',
          en: 'You know by when you must start regularization and have organized the next steps inside that window.',
        ),
        tips: _list(
          locale,
          pt: [
            'Anote a data de entrada e coloque um lembrete 30 dias antes do vencimento.',
          ],
          es: [
            'Anota la fecha de entrada y pon un recordatorio 30 dias antes del vencimiento.',
          ],
          en: [
            'Write down your entry date and set a reminder 30 days before it expires.',
          ],
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(locale, pt: '2 min', es: '2 min', en: '2 min'),
        preArrivalRequired: true,
        urgencyLevel: GuideUrgencyLevel.urgent,
        urgencySignal: _t(
          locale,
          pt: 'Leia isso antes de embarcar — o prazo começa no dia que você cruza a fronteira.',
          es: 'Lee esto antes de embarcar — el plazo comienza el dia que cruzas la frontera.',
          en: 'Read this before boarding — the clock starts the day you cross the border.',
        ),
      ),
      GuideActionItem(
        id: 'item_0_2_antecedentes',
        title: _t(
          locale,
          pt: 'Peça seu certificado de antecedentes',
          es: 'Pide tu certificado de antecedentes',
          en: 'Request your criminal record certificate',
        ),
        shortDescription: _t(
          locale,
          pt: 'Resolva isso antes da viagem para não travar sua residência no Brasil.',
          es: 'Resuelvelo antes del viaje para no trabar tu residencia en Brasil.',
          en: 'Handle this before traveling so your residency does not get blocked in Brazil.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.preparation,
        orderIndex: 1,
        isCompleted: false,
        icon: Icons.gpp_good_outlined,
        context: _t(
          locale,
          pt: 'É um dos documentos que a Polícia Federal pode exigir logo no início.',
          es: 'Es uno de los documentos que la Policia Federal puede pedir al principio.',
          en: 'It is one of the documents the Federal Police may ask for early on.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Sem ele, seu pedido de residência pode atrasar e o relógio dos 90 dias continua correndo.',
          es: 'Sin esto, tu residencia puede demorarse mientras el reloj de los 90 dias sigue corriendo.',
          en: 'Without it, your residency request can be delayed while the 90-day clock keeps running.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Solicitar certificado',
          es: 'Solicitar certificado',
          en: 'Request certificate',
        ),
        steps: _list(
          locale,
          pt: [
            'Acesse o site do Registro Nacional de Reincidencia.',
            'Peça a emissão com antecedência e acompanhe o prazo.',
            'Salve o PDF e leve uma cópia com seus outros documentos.',
          ],
          es: [
            'Entra al sitio del Registro Nacional de Reincidencia.',
            'Pide la emision con tiempo y sigue el plazo.',
            'Guarda el PDF y lleva una copia con tus otros documentos.',
          ],
          en: [
            'Go to the National Recidivism Registry website.',
            'Request issuance early and track the timeline.',
            'Save the PDF and carry a copy with your other documents.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já tem o certificado válido salvo e pronto para usar no pedido de residência.',
          es: 'Ya tienes el certificado valido guardado y listo para usar en la residencia.',
          en: 'You already have a valid certificate saved and ready for your residency request.',
        ),
        tips: _list(
          locale,
          pt: [
            'A validade é curta. Planeje a emissão perto da sua chegada, sem deixar para depois da viagem.',
          ],
          es: [
            'La validez es corta. Planifica la emision cerca de tu llegada, sin dejarlo para despues del viaje.',
          ],
          en: [
            'Validity is short. Time the issue close to your arrival without leaving it for after the trip.',
          ],
        ),
        blockingReason: _t(
          locale,
          pt: 'Esse documento destrava a etapa de residência Mercosul.',
          es: 'Este documento destraba la etapa de residencia Mercosur.',
          en: 'This document unlocks the Mercosur residency step.',
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '5-15 dias',
          es: '5-15 dias',
          en: '5-15 days',
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'ante_1',
            title: _t(
              locale,
              pt: 'Solicitar certificado no site do RNR',
              es: 'Solicitar certificado en el sitio del RNR',
              en: 'Request the certificate on the RNR website',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'ante_2',
            title: _t(
              locale,
              pt: 'Aguardar emissão (5-15 dias úteis)',
              es: 'Esperar la emision (5-15 dias habiles)',
              en: 'Wait for issuance (5-15 business days)',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'ante_3',
            title: _t(
              locale,
              pt: 'Salvar PDF e imprimir cópia',
              es: 'Guardar PDF e imprimir copia',
              en: 'Save the PDF and print a copy',
            ),
            isCompleted: false,
          ),
        ],
        preArrivalRequired: true,
        urgencyLevel: GuideUrgencyLevel.critical,
        urgencySignal: _t(
          locale,
          pt: 'Peça AGORA — o certificado tem validade curta. Se você pedir tarde, vai vencer antes de usar.',
          es: 'Pedilo AHORA — el certificado tiene validez corta. Si lo pides tarde, vencera antes de usarlo.',
          en: 'Request NOW — the certificate has short validity. If you request too late, it will expire before you use it.',
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Validade de 90 dias: solicite próximo à data de embarque.',
            'Resolva na Argentina — pedido após a viagem causa semanas de atraso.',
          ],
          es: [
            'Validez de 90 dias: solicita cerca de la fecha de embarque.',
            'Resolvelo en Argentina — pedirlo despues del viaje causa semanas de retraso.',
          ],
          en: [
            'Valid for 90 days only — request close to your departure date.',
            'Handle this in Argentina — requesting after the trip causes weeks of delay.',
          ],
        ),
      ),
      GuideActionItem(
        id: 'item_0_3_budget',
        title: _t(
          locale,
          pt: 'Calcule quanto você vai precisar no começo',
          es: 'Calcula cuanto vas a necesitar al inicio',
          en: 'Calculate what you need for the first months',
        ),
        shortDescription: _t(
          locale,
          pt: 'Os primeiros meses costumam concentrar os gastos mais pesados da mudança.',
          es: 'Los primeros meses suelen concentrar los gastos mas pesados de la mudanza.',
          en: 'The first months usually concentrate the heaviest migration costs.',
        ),
        fullContent: null,
        type: GuideActionType.tool,
        toolType: GuideToolType.budget,
        phase: GuidePhase.preparation,
        orderIndex: 2,
        isCompleted: false,
        icon: Icons.account_balance_wallet_outlined,
        context: _t(
          locale,
          pt: 'Monte uma reserva realista antes de embarcar para não travar logo no começo.',
          es: 'Arma una reserva realista antes de embarcar para no trabarte al principio.',
          en: 'Build a realistic buffer before boarding so you do not get stuck right at the start.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Sem reserva calculada, imprevistos nos primeiros dias podem forçar decisões ruins.',
          es: 'Sin reserva calculada, imprevistos en los primeros dias pueden forzar malas decisiones.',
          en: 'Without a calculated buffer, surprises in the first days can force bad decisions.',
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já tem um número concreto de quanto precisa para os primeiros 1-3 meses.',
          es: 'Ya tienes un numero concreto de cuanto necesitas para los primeros 1-3 meses.',
          en: 'You already have a concrete number for what you need for the first 1-3 months.',
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '15 min',
          es: '15 min',
          en: '15 min',
        ),
        preArrivalRequired: true,
        urgencyLevel: GuideUrgencyLevel.watch,
        urgencySignal: _t(
          locale,
          pt: 'Faça antes de viajar — chegada sem reserva calculada é a causa mais comum de crise no primeiro mês.',
          es: 'Hazlo antes de viajar — llegar sin reserva calculada es la causa mas comun de crisis en el primer mes.',
          en: 'Do this before traveling — arriving without a calculated buffer is the most common cause of crisis in month one.',
        ),
      ),
      GuideActionItem(
        id: 'item_0_5_mercado_trabalho',
        title: _t(
          locale,
          pt: 'Pesquise o mercado de trabalho na sua área',
          es: 'Investiga el mercado laboral en tu area',
          en: 'Research the job market in your field',
        ),
        shortDescription: _t(
          locale,
          pt: 'Entender o que seu perfil vale no Brasil antes de sair evita surpresas ruins e ajuda a calcular quanto você precisa para se sustentar.',
          es: 'Entender cuanto vale tu perfil en Brasil antes de salir evita malas sorpresas y ayuda a calcular cuanto necesitas para sostenerte.',
          en: 'Knowing what your profile is worth in Brazil before leaving prevents bad surprises and helps you estimate how much you need to sustain yourself.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.preparation,
        orderIndex: 3,
        isCompleted: false,
        icon: Icons.work_outline_rounded,
        context: _t(
          locale,
          pt: 'O mercado de trabalho brasileiro tem dinâmicas e faixas salariais bem diferentes da Argentina. Entender isso antes de chegar te dá uma vantagem real no planejamento.',
          es: 'El mercado laboral brasileno tiene dinamicas y rangos salariales muy diferentes a los de Argentina. Entender esto antes de llegar te da una ventaja real en la planificacion.',
          en: 'The Brazilian job market has very different dynamics and salary ranges from Argentina. Understanding this before arriving gives you a real advantage in planning.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Salário esperado, plataformas certas e como funciona CLT vs PJ no Brasil determinam sua estratégia de renda desde o dia 1. Saber disso antes de sair te poupa semanas de ajuste.',
          es: 'El salario esperado, las plataformas correctas y como funciona CLT vs PJ en Brasil determinan tu estrategia de ingresos desde el dia 1. Saberlo antes de salir te ahorra semanas de ajuste.',
          en: 'Expected salary, the right platforms, and how CLT vs PJ works in Brazil determine your income strategy from day one. Knowing this before leaving saves you weeks of adjustment.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Ver vagas no Brasil',
          es: 'Ver vacantes en Brasil',
          en: 'Browse jobs in Brazil',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.officialJobsPortal
            .toString(),
        steps: _list(
          locale,
          pt: [
            'Pesquise vagas na sua área no LinkedIn Brasil, Catho e VAGAS.com.',
            'Anote os salários médios anunciados — costumam ser CLT, já com encargos.',
            'Compare com o custo de vida da cidade que você escolheu.',
            'Entenda se seu perfil se encaixa melhor como CLT, PJ, freelancer ou MEI.',
            'Converta os valores para pesos argentinos para ter uma referência concreta.',
          ],
          es: [
            'Busca vacantes en tu area en LinkedIn Brasil, Catho y VAGAS.com.',
            'Anota los salarios promedio anunciados — suelen ser CLT, con cargas incluidas.',
            'Comparalos con el costo de vida de la ciudad que elegiste.',
            'Entiende si tu perfil encaja mejor como CLT, PJ, freelancer o MEI.',
            'Convierte los valores a pesos argentinos para tener una referencia concreta.',
          ],
          en: [
            'Search for openings in your field on LinkedIn Brasil, Catho, and VAGAS.com.',
            'Note the average advertised salaries — they are usually CLT, with deductions already included.',
            'Compare them against the cost of living in your chosen city.',
            'Determine whether your profile fits better as CLT, PJ, freelancer, or MEI.',
            'Convert the figures to Argentine pesos for a concrete reference.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você conhece os salários médios na sua área, entende as diferenças entre CLT/PJ/freelance e tem clareza se dá para se sustentar na cidade escolhida.',
          es: 'Conoces los salarios promedio en tu area, entiendes las diferencias entre CLT/PJ/freelance y tienes claridad si puedes sostenerte en la ciudad elegida.',
          en: 'You know the average salaries in your field, understand the differences between CLT/PJ/freelance, and have clarity on whether you can sustain yourself in your chosen city.',
        ),
        tips: _list(
          locale,
          pt: [
            _marketExchangeTip(locale, exchangeRates: exchangeRates),
            'Salários CLT anunciados já incluem FGTS e encargos — o líquido é o valor anunciado mesmo.',
            'LinkedIn Brasil é muito mais ativo que na Argentina — perfil em português aumenta muito o retorno.',
            'Para trabalho remoto mantendo cliente argentino: MEI simplifica a regularização da renda.',
          ],
          es: [
            _marketExchangeTip(locale, exchangeRates: exchangeRates),
            'Los salarios CLT anunciados ya incluyen FGTS y cargas — el neto es el valor anunciado.',
            'LinkedIn Brasil es mucho mas activo que en Argentina — perfil en portugues aumenta mucho el retorno.',
            'Para trabajo remoto manteniendo cliente argentino: MEI simplifica la regularizacion del ingreso.',
          ],
          en: [
            _marketExchangeTip(locale, exchangeRates: exchangeRates),
            'Advertised CLT salaries already include FGTS and deductions — the net is the advertised figure.',
            'LinkedIn Brasil is far more active than in Argentina — a Portuguese profile significantly increases response rate.',
            'For remote work keeping an Argentine client: MEI simplifies income regularization.',
          ],
        ),
        communityTips: _list(
          locale,
          pt: [
            '"Designer UX: R\$4.000–9.000/mês. Dev full stack: R\$6.000–18.000. Médico: R\$8.000–20.000. Professor universitário: R\$4.000–9.000. Engenheiro: R\$6.000–15.000."',
            '"Workana e 99Freelas aceitam estrangeiros com CPF — ótimo para começar freelancer antes de ter CTPS ou emprego fixo."',
            '"Catho funciona muito bem para vagas formais CLT, especialmente para quem está começando e quer retorno rápido."',
            '"R\$5.000/mês em São Paulo cobre o básico com folga mínima. Em Curitiba ou Floripa, o mesmo valor já dá conforto real."',
          ],
          es: [
            '"Diseñador UX: R\$4.000–9.000/mes. Dev full stack: R\$6.000–18.000. Medico: R\$8.000–20.000. Profesor universitario: R\$4.000–9.000. Ingeniero: R\$6.000–15.000."',
            '"Workana y 99Freelas aceptan extranjeros con CPF — ideal para empezar freelance antes de tener CTPS o trabajo fijo."',
            '"Catho funciona muy bien para vacantes formales CLT, especialmente para quien empieza y quiere respuesta rapida."',
            '"R\$5.000/mes en Sao Paulo cubre lo basico con margen minimo. En Curitiba o Floripa, el mismo valor ya da comodidad real."',
          ],
          en: [
            '"UX Designer: R\$4,000–9,000/month. Full stack dev: R\$6,000–18,000. Doctor: R\$8,000–20,000. University professor: R\$4,000–9,000. Engineer: R\$6,000–15,000."',
            '"Workana and 99Freelas accept foreigners with CPF — great for starting freelance before having CTPS or a permanent job."',
            '"Catho works very well for formal CLT roles, especially for those just starting who want fast responses."',
            '"R\$5,000/month in São Paulo covers the basics with minimal margin. In Curitiba or Floripa, the same amount provides real comfort."',
          ],
        ),
        preArrivalRequired: true,
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '30 min',
          es: '30 min',
          en: '30 min',
        ),
      ),
      GuideActionItem(
        id: 'item_0_6_saude_entender',
        title: _t(
          locale,
          pt: 'Entenda o sistema de saúde antes de chegar',
          es: 'Entiende el sistema de salud antes de llegar',
          en: 'Understand the health system before you arrive',
        ),
        shortDescription: _t(
          locale,
          pt: 'Chegar sem saber onde ir em uma emergência, quanto custa um plano ou o que o SUS cobre é um risco desnecessário.',
          es: 'Llegar sin saber adonde ir en una emergencia, cuanto cuesta un plan o que cubre el SUS es un riesgo innecesario.',
          en: 'Arriving without knowing where to go in an emergency, how much a plan costs, or what SUS covers is an unnecessary risk.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.preparation,
        orderIndex: 4,
        isCompleted: false,
        icon: Icons.health_and_safety_outlined,
        context: _t(
          locale,
          pt: 'O Brasil tem sistema público de saúde universal (SUS). Entender onde ir numa urgência, como funciona a atenção básica e quando o CPF entra na rotina do SUS evita muita ansiedade na chegada.',
          es: 'Brasil tiene un sistema publico de salud universal (SUS). Entender adonde ir en una urgencia, como funciona la atencion basica y cuando entra el CPF en la rutina del SUS evita mucha ansiedad al llegar.',
          en: 'Brazil has a universal public health system (SUS). Understanding where to go in an emergency, how primary care works, and when CPF matters in the SUS routine prevents a lot of stress on arrival.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Uma emergência médica sem saber onde ir ou sem cobertura pode custar caro em dinheiro, tempo e estresse no pior momento possível da mudança.',
          es: 'Una emergencia medica sin saber adonde ir o sin cobertura puede costar caro en dinero, tiempo y estres en el peor momento posible de la mudanza.',
          en: 'A medical emergency without knowing where to go or without coverage can cost a lot in money, time, and stress at the worst possible moment of the move.',
        ),
        steps: _list(
          locale,
          pt: [
            'Entenda que urgências e emergências no SUS não dependem de ter CPF ou Cartão SUS emitido.',
            'Saiba a diferença entre UBS (consultas de rotina), UPA (urgência 24h) e Hospital (emergência).',
            'Pesquise o custo de planos privados básicos na sua cidade: geralmente R\$150–400/mês.',
            'Veja como fazer o Cartão SUS/CNS depois da chegada — aí sim o CPF entra para organizar seu cadastro.',
            'Se tiver condição crônica ou uso de medicamento contínuo, leve estoque dos primeiros 60 dias da Argentina.',
            'Verifique se seus medicamentos habituais têm equivalente no Brasil — o nome comercial pode ser diferente.',
          ],
          es: [
            'Entiende que las urgencias y emergencias en el SUS no dependen de tener CPF o Tarjeta SUS emitida.',
            'Conoce la diferencia entre UBS (consultas de rutina), UPA (urgencias 24h) y Hospital (emergencias).',
            'Investiga el costo de planes privados basicos en tu ciudad: generalmente R\$150–400/mes.',
            'Mira como sacar la Tarjeta SUS/CNS despues de llegar — ahi si el CPF entra para ordenar tu registro.',
            'Si tienes condicion cronica o uso de medicamento continuo, lleva stock de los primeros 60 dias desde Argentina.',
            'Verifica si tus medicamentos habituales tienen equivalente en Brasil — el nombre comercial puede ser diferente.',
          ],
          en: [
            'Understand that urgent and emergency SUS care does not depend on already having a CPF or SUS card.',
            'Know the difference between UBS (routine appointments), UPA (24h urgent care), and Hospital (emergencies).',
            'Research the cost of basic private plans in your city: typically R\$150–400/month.',
            'Check how to get your SUS/CNS card after arrival — that is when CPF becomes part of the regular registration flow.',
            'If you have a chronic condition or ongoing medication, bring a 60-day supply from Argentina.',
            'Check whether your regular medications have equivalents in Brazil — the brand name may be different.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você entende como funciona o SUS, sabe a diferença entre UBS/UPA/Hospital, conhece os custos de plano privado e tem um plano claro para os primeiros dias.',
          es: 'Entiendes como funciona el SUS, conoces la diferencia entre UBS/UPA/Hospital, los costos de plan privado y tienes un plan claro para los primeros dias.',
          en: 'You understand how SUS works, know the difference between UBS/UPA/Hospital, know what private plans cost, and have a clear plan for the first days.',
        ),
        tips: _list(
          locale,
          pt: [
            'Para urgências nos primeiros dias (antes do Cartão SUS), vá à UPA — é gratuito mesmo sem documentação completa.',
            'Planos básicos: Amil One, SulAmérica Especial, Hapvida custam entre R\$150–300/mês para adultos.',
            'O Cartão SUS (CNS) costuma ser organizado na UBS depois da chegada, normalmente usando o CPF para vincular seu cadastro.',
          ],
          es: [
            'Para urgencias en los primeros dias (antes de la Tarjeta SUS), ve a la UPA — es gratis incluso sin documentacion completa.',
            'Planes basicos: Amil One, SulAmerica Especial, Hapvida cuestan entre R\$150–300/mes para adultos.',
            'La Tarjeta SUS (CNS) suele organizarse en la UBS despues de llegar, normalmente usando el CPF para vincular tu registro.',
          ],
          en: [
            'For emergencies in the first days (before your SUS card), go to the UPA — it is free even without complete documentation.',
            'Basic plans: Amil One, SulAmérica Especial, Hapvida cost R\$150–300/month for adults.',
            'The SUS card (CNS) is usually arranged at the UBS after arrival, normally using CPF to link your record.',
          ],
        ),
        communityTips: _list(
          locale,
          pt: [
            '"Fui à UPA no primeiro dia sem cartão SUS e fui atendido normalmente. O sistema funciona mesmo sem documentação completa."',
            '"Plano de R\$200/mês me deu acesso a médico em 24h. Valeu muito nos primeiros 3 meses antes de ter estabilidade."',
            '"Trouxe meus remédios da Argentina — o nome comercial era diferente aqui e perdi uma semana procurando equivalente sem saber o nome genérico."',
            '"O SUS cobre TUDO, mas para consultas com especialista a fila pode ser longa. Plano privado básico vale para quem tem renda."',
          ],
          es: [
            '"Fui a la UPA el primer dia sin tarjeta SUS y me atendieron normalmente. El sistema funciona incluso sin documentacion completa."',
            '"Un plan de R\$200/mes me dio acceso a medico en 24h. Valio mucho en los primeros 3 meses antes de tener estabilidad."',
            '"Traje mis medicamentos de Argentina — el nombre comercial era diferente aca y pase una semana buscando equivalente sin saber el nombre generico."',
            '"El SUS cubre TODO, pero para consultas con especialista la cola puede ser larga. Plan privado basico vale para quien tiene ingresos."',
          ],
          en: [
            '"I went to the UPA on the first day without a SUS card and was seen normally. The system works even without complete documentation."',
            '"A R\$200/month plan gave me access to a doctor within 24h. Very worth it in the first 3 months before having stability."',
            '"I brought my medications from Argentina — the brand name was different here and I spent a week searching for the equivalent without knowing the generic name."',
            '"SUS covers EVERYTHING, but for specialist appointments the queue can be long. A basic private plan is worth it for those with income."',
          ],
        ),
        preArrivalRequired: true,
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '20 min',
          es: '20 min',
          en: '20 min',
        ),
      ),
      GuideActionItem(
        id: 'item_1_3_money',
        title: _t(
          locale,
          pt: 'Organize o dinheiro dos primeiros dias',
          es: 'Organiza el dinero de los primeros dias',
          en: 'Set up money for the first days',
        ),
        shortDescription: _t(
          locale,
          pt: 'Antes da conta brasileira, você precisa de um jeito confiável de pagar e sacar.',
          es: 'Antes de tener cuenta brasileña, necesitas una forma confiable de pagar y retirar dinero.',
          en: 'Before you have a Brazilian account, you need a reliable way to pay and withdraw money.',
        ),
        fullContent: null,
        type: GuideActionType.external,
        phase: GuidePhase.preparation,
        orderIndex: 3,
        isCompleted: false,
        icon: Icons.payments_outlined,
        context: _t(
          locale,
          pt: 'Nos primeiros dias, você ainda não terá conta bancária nem Pix. Precisa de pelo menos duas formas de pagar funcionando.',
          es: 'En los primeros dias, aun no tendras cuenta bancaria ni Pix. Necesitas al menos dos formas de pago funcionando.',
          en: 'In the first days, you will not have a bank account or Pix yet. You need at least two working payment methods.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Se seu único meio de pagamento falhar, você fica travado para transporte, comida e hospedagem logo na chegada.',
          es: 'Si tu unico medio de pago falla, quedas trabado para transporte, comida y alojamiento desde la llegada.',
          en: 'If your only payment method fails, you are stuck for transport, food, and housing right on arrival.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Configurar pagamentos',
          es: 'Configurar pagos',
          en: 'Set up payments',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: 'https://wise.com',
        steps: _list(
          locale,
          pt: [
            'Verifique se seu cartão argentino funciona para compras e saques internacionais.',
            'Crie uma conta em um serviço de câmbio (Wise, Payoneer ou similar) antes de viajar.',
            'Troque um valor em reais ou dólares em espécie como backup.',
            'Teste pelo menos um pagamento antes de embarcar.',
          ],
          es: [
            'Verifica si tu tarjeta argentina funciona para compras y extracciones internacionales.',
            'Crea una cuenta en un servicio de cambio (Wise, Payoneer o similar) antes de viajar.',
            'Cambia algo de efectivo en reales o dolares como respaldo.',
            'Prueba al menos un pago antes de embarcar.',
          ],
          en: [
            'Check that your Argentine card works for international purchases and withdrawals.',
            'Create an account in a transfer service (Wise, Payoneer, or similar) before traveling.',
            'Exchange some cash into BRL or USD as a backup.',
            'Test at least one payment before boarding.',
          ],
        ),
        requirements: _list(
          locale,
          pt: [
            'Cartão com habilitação internacional',
            'Documento para abrir conta em serviço de câmbio',
          ],
          es: [
            'Tarjeta habilitada para uso internacional',
            'Documento para abrir cuenta en servicio de cambio',
          ],
          en: [
            'Card enabled for international use',
            'ID to open a transfer service account',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você tem pelo menos duas formas de pagar no Brasil funcionando e testadas.',
          es: 'Tienes al menos dos formas de pagar en Brasil funcionando y probadas.',
          en: 'You have at least two working and tested payment methods for Brazil.',
        ),
        tips: _list(
          locale,
          pt: [
            'Evite câmbio de aeroporto — o spread costuma ser muito alto.',
            'Wise e serviços similares costumam ter taxas menores que o cartão do banco.',
          ],
          es: [
            'Evita el cambio del aeropuerto — el spread suele ser muy alto.',
            'Wise y similares suelen tener tasas menores que la tarjeta del banco.',
          ],
          en: [
            'Avoid airport exchange — the spread is usually very high.',
            'Wise and similar services often have lower fees than your bank card.',
          ],
        ),
        decisionOptions: [
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Cartão internacional',
              es: 'Tarjeta internacional',
              en: 'International card',
            ),
            description: _t(
              locale,
              pt: 'Usa seu cartão argentino habilitado para compras e saques.',
              es: 'Usa tu tarjeta argentina habilitada para compras y extracciones.',
              en: 'Use your Argentine card enabled for purchases and withdrawals.',
            ),
            pros: _list(
              locale,
              pt: ['Já tem', 'Aceito em muitos lugares'],
              es: ['Ya la tienes', 'Aceptada en muchos lugares'],
              en: ['Already have it', 'Widely accepted'],
            ),
            cons: _list(
              locale,
              pt: ['Spread alto', 'Pode falhar em alguns estabelecimentos'],
              es: ['Spread alto', 'Puede fallar en algunos comercios'],
              en: ['High spread', 'May fail at some merchants'],
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Serviço de câmbio (Wise)',
              es: 'Servicio de cambio (Wise)',
              en: 'Transfer service (Wise)',
            ),
            description: _t(
              locale,
              pt: 'Transferência com câmbio mais justo e cartão virtual/físico.',
              es: 'Transferencia con cambio mas justo y tarjeta virtual/fisica.',
              en: 'Transfer with fairer exchange rate and virtual/physical card.',
            ),
            pros: _list(
              locale,
              pt: ['Câmbio melhor', 'Cartão multimoeda'],
              es: ['Cambio mejor', 'Tarjeta multimoneda'],
              en: ['Better exchange', 'Multi-currency card'],
            ),
            cons: _list(
              locale,
              pt: ['Precisa configurar antes', 'Verificação de identidade'],
              es: ['Hay que configurarlo antes', 'Verificacion de identidad'],
              en: ['Needs setup beforehand', 'Identity verification'],
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Dinheiro em espécie',
              es: 'Efectivo',
              en: 'Cash',
            ),
            description: _t(
              locale,
              pt: 'Reais ou dólares para emergências e gastos imediatos.',
              es: 'Reales o dolares para emergencias y gastos inmediatos.',
              en: 'BRL or USD for emergencies and immediate expenses.',
            ),
            pros: _list(
              locale,
              pt: ['Funciona sempre', 'Sem dependência digital'],
              es: ['Funciona siempre', 'Sin dependencia digital'],
              en: ['Always works', 'No digital dependency'],
            ),
            cons: _list(
              locale,
              pt: ['Risco de perda/roubo', 'Câmbio pode ser ruim'],
              es: ['Riesgo de perdida/robo', 'El cambio puede ser malo'],
              en: ['Risk of loss/theft', 'Exchange rate can be poor'],
            ),
          ),
        ],
        checklistItems: [
          ChecklistSubItem(
            id: 'money_1',
            title: _t(
              locale,
              pt: 'Cartão internacional ativado e testado',
              es: 'Tarjeta internacional activada y probada',
              en: 'International card activated and tested',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'money_2',
            title: _t(
              locale,
              pt: 'Conta Wise ou similar criada',
              es: 'Cuenta Wise o similar creada',
              en: 'Wise or similar account created',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'money_3',
            title: _t(
              locale,
              pt: 'Valor de backup em espécie separado',
              es: 'Valor de respaldo en efectivo separado',
              en: 'Backup cash amount set aside',
            ),
            isCompleted: false,
          ),
        ],
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '30 min',
          es: '30 min',
          en: '30 min',
        ),
        preArrivalRequired: true,
        urgencyLevel: GuideUrgencyLevel.urgent,
        urgencySignal: _t(
          locale,
          pt: 'Configure antes de embarcar — câmbio de aeroporto consome 30-50% do seu dinheiro.',
          es: 'Configura antes de embarcar — el cambio del aeropuerto consume entre 30-50% de tu dinero.',
          en: 'Set up before boarding — airport exchange burns 30-50% of your money.',
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Câmbio de aeroporto: taxas 30-50% piores que Wise ou cartão. Evite na chegada.',
            'Não dependa de um único meio de pagamento — se travar, você fica sem acesso a dinheiro.',
          ],
          es: [
            'Cambio del aeropuerto: tasas 30-50% peores que Wise o tarjeta. Evitalo a la llegada.',
            'No dependas de un solo medio de pago — si falla, quedas sin acceso al dinero.',
          ],
          en: [
            'Airport exchange: rates are 30-50% worse than Wise or card. Avoid it on arrival.',
            'Do not rely on a single payment method — if it fails, you are left without money access.',
          ],
        ),
      ),
      GuideActionItem(
        id: 'item_0_4_flight',
        title: _t(
          locale,
          pt: 'Planeje o voo e a logística da chegada',
          es: 'Planifica el vuelo y la logistica de llegada',
          en: 'Plan the flight and arrival logistics',
        ),
        shortDescription: _t(
          locale,
          pt: 'Feche a chegada com data, primeira hospedagem e plano do aeroporto para a porta.',
          es: 'Cierra la llegada con fecha, primer alojamiento y plan desde el aeropuerto hasta la puerta.',
          en: 'Lock in the arrival with a date, first stay, and a plan from the airport to your door.',
        ),
        fullContent: null,
        type: GuideActionType.tool,
        toolType: GuideToolType.flight,
        phase: GuidePhase.preparation,
        orderIndex: 4,
        isCompleted: false,
        icon: Icons.flight_takeoff_rounded,
        context: _t(
          locale,
          pt: 'Essa etapa organiza sua entrada no Brasil sem improviso.',
          es: 'Esta etapa organiza tu entrada a Brasil sin improvisacion.',
          en: 'This step organizes your arrival in Brazil without improvising.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Chegar sem hospedagem e sem plano de deslocamento costuma virar gasto extra e estresse logo no primeiro dia.',
          es: 'Llegar sin alojamiento y sin plan de traslado suele convertirse en gasto extra y estres desde el primer dia.',
          en: 'Arriving without accommodation and a transport plan often turns into extra cost and stress on day one.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Buscar voo',
          es: 'Buscar vuelo',
          en: 'Search flights',
        ),
        primaryActionType: GuidePrimaryActionType.tool,
        steps: _list(
          locale,
          pt: [
            'Defina a data de chegada com margem para resolver CPF e moradia temporária.',
            'Reserve pelo menos 3 noites na primeira hospedagem.',
            'Decida como vai sair do aeroporto e onde terá internet ao aterrissar.',
          ],
          es: [
            'Define la fecha de llegada con margen para resolver CPF y vivienda temporal.',
            'Reserva al menos 3 noches en el primer alojamiento.',
            'Decide como vas a salir del aeropuerto y donde tendras internet al aterrizar.',
          ],
          en: [
            'Set the arrival date with enough margin to handle CPF and temporary housing.',
            'Book at least 3 nights in your first stay.',
            'Decide how you will leave the airport and where you will have internet after landing.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já tem voo, endereço inicial e plano claro para sair do aeroporto.',
          es: 'Ya tienes vuelo, direccion inicial y un plan claro para salir del aeropuerto.',
          en: 'You already have your flight, first address, and a clear plan to leave the airport.',
        ),
        tips: _list(
          locale,
          pt: [
            'Se levar muita bagagem, compare despacho com transporte separado.',
            'Tenha uma opção de pagamento funcionando já no desembarque.',
          ],
          es: [
            'Si llevas mucho equipaje, compara despacho con transporte separado.',
            'Ten una opcion de pago funcionando desde el desembarque.',
          ],
          en: [
            'If you are carrying a lot of luggage, compare checked bags versus separate transport.',
            'Have at least one payment option working from the moment you land.',
          ],
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '20 min',
          es: '20 min',
          en: '20 min',
        ),
        preArrivalRequired: true,
        urgencyLevel: GuideUrgencyLevel.urgent,
        urgencySignal: _t(
          locale,
          pt: 'Reserve voo e hospedagem antes de viajar — sem endereço confirmado você não consegue CPF no primeiro dia.',
          es: 'Reserva vuelo y alojamiento antes de viajar — sin direccion confirmada no puedes tramitar el CPF el primer dia.',
          en: 'Book flight and housing before leaving — without a confirmed address you cannot start CPF on day one.',
        ),
      ),
      GuideActionItem(
        id: 'item_1_1_chip',
        title: _t(
          locale,
          pt: 'Compre um chip brasileiro',
          es: 'Compra un chip brasileno',
          en: 'Buy a Brazilian SIM card',
        ),
        shortDescription: _t(
          locale,
          pt: 'Sem número brasileiro, você trava banco, apps e alguns agendamentos importantes.',
          es: 'Sin numero brasileno, se traban banco, apps y algunos turnos importantes.',
          en: 'Without a Brazilian number, banking, apps, and some key bookings get blocked.',
        ),
        fullContent: null,
        type: GuideActionType.checklist,
        phase: GuidePhase.arrival,
        orderIndex: 8,
        isCompleted: false,
        icon: Icons.sim_card_outlined,
        dependencies: <String>['item_2_1_cpf'],
        context: _t(
          locale,
          pt: 'Depois de emitir o CPF, ter um número brasileiro ajuda a ativar banco, Pix e apps essenciais já com seu cadastro principal no Brasil.',
          es: 'Despues de emitir el CPF, tener un numero brasileno ayuda a activar banco, Pix y apps esenciales ya con tu registro principal en Brasil.',
          en: 'After issuing CPF, having a Brazilian number helps you activate bank access, Pix, and essential apps with your main registration in Brazil.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Com CPF em mãos, o chip vira uma etapa prática de execução para receber SMS, validar cadastros e consolidar sua rotina digital no Brasil.',
          es: 'Con el CPF en mano, el chip pasa a ser una etapa practica para recibir SMS, validar registros y consolidar tu rutina digital en Brasil.',
          en: 'With CPF in hand, the SIM becomes a practical execution step to receive SMS, validate registrations, and stabilize your digital routine in Brazil.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Ver operadoras',
          es: 'Ver operadoras',
          en: 'See carriers',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: 'https://www.claro.com.br/celular/prepago',
        steps: _list(
          locale,
          pt: [
            'Depois do CPF, compre um chip pré-pago em loja de operadora ou revenda confiável.',
            'Ative a linha e registre o CPF no atendimento para evitar limitações depois.',
            'Teste SMS e internet móvel antes de sair da loja.',
          ],
          es: [
            'Despues del CPF, compra un chip prepago en tienda de operadora o punto confiable.',
            'Activa la linea y registra el CPF en la atencion para evitar limites despues.',
            'Prueba SMS e internet movil antes de salir de la tienda.',
          ],
          en: [
            'After CPF, buy a prepaid SIM at a carrier store or trusted reseller.',
            'Activate the line and register your CPF during activation to avoid later limits.',
            'Test SMS and mobile data before leaving the store.',
          ],
        ),
        requirements: _list(
          locale,
          pt: [
            'CPF emitido',
            'Documento com foto',
            'R\$ 20-50 para chip e crédito inicial',
          ],
          es: [
            'CPF emitido',
            'Documento con foto',
            'R\$ 20-50 para chip y credito inicial',
          ],
          en: [
            'Issued CPF',
            'Photo ID',
            'R\$ 20-50 for the SIM and initial credit',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você tem um número brasileiro ativo, recebe SMS e consegue usar internet móvel.',
          es: 'Tienes un numero brasileno activo, recibes SMS y puedes usar internet movil.',
          en: 'You have an active Brazilian number, receive SMS, and can use mobile internet.',
        ),
        tips: _list(
          locale,
          pt: [
            'No aeroporto, os chips costumam ser mais caros. Se puder, compre em loja na cidade.',
            'Guarde o número — ele pode virar sua chave Pix depois.',
          ],
          es: [
            'En el aeropuerto los chips suelen ser mas caros. Si puedes, compra en tienda en la ciudad.',
            'Guarda el numero — sera tu clave Pix despues.',
          ],
          en: [
            'At the airport, SIMs tend to cost more. If you can, buy at a store in the city.',
            'Save the number — it will become your Pix key later.',
          ],
        ),
        decisionOptions: [
          GuideDecisionOption(
            title: 'Claro',
            description: _t(
              locale,
              pt: 'Boa cobertura geral e presença em aeroportos.',
              es: 'Buena cobertura general y presencia en aeropuertos.',
              en: 'Good overall coverage and airport presence.',
            ),
            pros: _list(
              locale,
              pt: ['Fácil de encontrar', 'Cobertura ampla'],
              es: ['Facil de encontrar', 'Cobertura amplia'],
              en: ['Easy to find', 'Wide coverage'],
            ),
            cons: _list(
              locale,
              pt: ['Preço intermediário'],
              es: ['Precio intermedio'],
              en: ['Mid-range price'],
            ),
          ),
          GuideDecisionOption(
            title: 'Vivo',
            description: _t(
              locale,
              pt: 'Melhor sinal em muitas regiões do Brasil.',
              es: 'Mejor senal en muchas regiones de Brasil.',
              en: 'Best signal in many Brazilian regions.',
            ),
            pros: _list(
              locale,
              pt: ['Melhor cobertura 4G/5G'],
              es: ['Mejor cobertura 4G/5G'],
              en: ['Best 4G/5G coverage'],
            ),
            cons: _list(
              locale,
              pt: ['Pode ser um pouco mais caro'],
              es: ['Puede ser un poco mas caro'],
              en: ['Can be slightly more expensive'],
            ),
          ),
          GuideDecisionOption(
            title: 'TIM',
            description: _t(
              locale,
              pt: 'Opção mais econômica para pré-pago.',
              es: 'Opcion mas economica para prepago.',
              en: 'Most affordable prepaid option.',
            ),
            pros: _list(
              locale,
              pt: ['Preço mais baixo', 'Bons pacotes de dados'],
              es: ['Precio mas bajo', 'Buenos paquetes de datos'],
              en: ['Lower price', 'Good data plans'],
            ),
            cons: _list(
              locale,
              pt: ['Cobertura pode variar fora de capitais'],
              es: ['La cobertura puede variar fuera de capitales'],
              en: ['Coverage can vary outside capitals'],
            ),
          ),
        ],
        checklistItems: [
          ChecklistSubItem(
            id: 'chip_1',
            title: _t(
              locale,
              pt: 'Chip pré-pago comprado',
              es: 'Chip prepago comprado',
              en: 'Prepaid SIM purchased',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'chip_2',
            title: _t(
              locale,
              pt: 'Ativado com documento',
              es: 'Activado con documento',
              en: 'Activated with ID',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'chip_3',
            title: _t(
              locale,
              pt: 'CPF registrado na operadora',
              es: 'CPF registrado en la operadora',
              en: 'CPF registered with the carrier',
            ),
            isCompleted: false,
          ),
        ],
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '15 min',
          es: '15 min',
          en: '15 min',
        ),
      ),
      GuideActionItem(
        id: 'item_1_2_housing_temporary',
        title: _t(
          locale,
          pt: 'Defina como você vai morar no começo',
          es: 'Define como vas a vivir al principio',
          en: 'Decide how you will live at the beginning',
        ),
        shortDescription: _t(
          locale,
          pt: 'Nos primeiros 30 a 60 dias, o objetivo é chegar com segurança e ganhar tempo para resolver documentos.',
          es: 'En los primeros 30 a 60 dias, el objetivo es llegar con seguridad y ganar tiempo para resolver documentos.',
          en: 'In the first 30 to 60 days, the goal is to arrive safely and buy time to solve documents.',
        ),
        fullContent: null,
        type: GuideActionType.tool,
        toolType: GuideToolType.housing,
        phase: GuidePhase.housing,
        orderIndex: 6,
        isCompleted: false,
        icon: Icons.house_outlined,
        context: _t(
          locale,
          pt: 'Antes do aluguel fixo, você precisa de uma base prática para os primeiros dias.',
          es: 'Antes del alquiler fijo, necesitas una base practica para los primeros dias.',
          en: 'Before a fixed rental, you need a practical base for your first days.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Sem CPF, renda local ou fiador, o aluguel tradicional costuma travar logo no começo.',
          es: 'Sin CPF, ingresos locales o garante, el alquiler tradicional suele trabarse enseguida.',
          en: 'Without CPF, local income, or a guarantor, traditional rent usually gets blocked quickly.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Ver opções de moradia',
          es: 'Ver opciones de vivienda',
          en: 'See housing options',
        ),
        primaryActionType: GuidePrimaryActionType.tool,
        steps: _list(
          locale,
          pt: [
            'Escolha uma solução inicial para 30 a 60 dias.',
            'Priorize reserva com comprovante de endereço no seu nome.',
            'Fique perto de transporte e dos lugares onde vai resolver documentos.',
          ],
          es: [
            'Elige una solucion inicial para 30 a 60 dias.',
            'Prioriza una reserva con comprobante de domicilio a tu nombre.',
            'Quedate cerca del transporte y de los lugares donde vas a resolver documentos.',
          ],
          en: [
            'Choose an initial solution for 30 to 60 days.',
            'Prioritize a booking with proof of address in your name.',
            'Stay close to transport and the places where you will solve documents.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já decidiu sua estratégia inicial e tem a primeira hospedagem reservada.',
          es: 'Ya decidiste tu estrategia inicial y tienes el primer alojamiento reservado.',
          en: 'You have decided your initial strategy and booked your first stay.',
        ),
        tips: _list(
          locale,
          pt: [
            'Mensalidades em Airbnb e quartos compartilhados costumam ser mais realistas no início.',
            'Evite assumir aluguel fixo antes de entender bairros, custo real e exigências.',
          ],
          es: [
            'Las estadias mensuales en Airbnb y habitaciones compartidas suelen ser mas realistas al inicio.',
            'Evita asumir alquiler fijo antes de entender barrios, costo real y exigencias.',
          ],
          en: [
            'Monthly Airbnb stays and shared rooms are often more realistic at the start.',
            'Avoid taking on a fixed rental before understanding neighborhoods, real costs, and requirements.',
          ],
        ),
        decisionOptions: [
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Airbnb por mês',
              es: 'Airbnb por mes',
              en: 'Monthly Airbnb',
            ),
            description: _t(
              locale,
              pt: 'Mais simples para chegar rápido e ganhar desconto em estadias longas.',
              es: 'Lo mas simple para llegar rapido y conseguir descuento en estadias largas.',
              en: 'The simplest way to arrive quickly and get discounts on long stays.',
            ),
            pros: _list(
              locale,
              pt: ['Reserva rápida', 'Mobília pronta'],
              es: ['Reserva rapida', 'Amueblado'],
              en: ['Fast booking', 'Furnished'],
            ),
            cons: _list(
              locale,
              pt: ['Custo mais alto'],
              es: ['Costo mas alto'],
              en: ['Higher cost'],
            ),
            recommended: true,
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Quarto compartilhado',
              es: 'Habitacion compartida',
              en: 'Shared room',
            ),
            description: _t(
              locale,
              pt: 'Boa opção para reduzir custo enquanto organiza documentos.',
              es: 'Buena opcion para bajar costos mientras organizas documentos.',
              en: 'A good option to reduce costs while you organize documents.',
            ),
            pros: _list(
              locale,
              pt: ['Mais barato'],
              es: ['Mas barato'],
              en: ['Cheaper'],
            ),
            cons: _list(
              locale,
              pt: ['Menos privacidade'],
              es: ['Menos privacidad'],
              en: ['Less privacy'],
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Flat ou hotel',
              es: 'Flat u hotel',
              en: 'Flat or hotel',
            ),
            description: _t(
              locale,
              pt: 'Funciona bem para chegada curta ou quando você precisa de flexibilidade total.',
              es: 'Funciona bien para una llegada corta o cuando necesitas flexibilidad total.',
              en: 'Works well for a short arrival period or when you need full flexibility.',
            ),
            pros: _list(
              locale,
              pt: ['Entrada imediata'],
              es: ['Entrada inmediata'],
              en: ['Immediate move-in'],
            ),
            cons: _list(
              locale,
              pt: ['Caro para mais de algumas semanas'],
              es: ['Caro para mas de algunas semanas'],
              en: ['Expensive beyond a few weeks'],
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Aluguel tradicional',
              es: 'Alquiler tradicional',
              en: 'Traditional rental',
            ),
            description: _t(
              locale,
              pt: 'Melhor deixar para depois da documentação básica e definição de bairro.',
              es: 'Conviene dejarlo para despues de la documentacion basica y de definir barrio.',
              en: 'Better to leave for later, after basic documents and neighborhood choice.',
            ),
            pros: _list(
              locale,
              pt: ['Pode sair mais barato no longo prazo'],
              es: ['Puede ser mas barato a largo plazo'],
              en: ['Can be cheaper long-term'],
            ),
            cons: _list(
              locale,
              pt: ['Exige mais documentação e garantia'],
              es: ['Exige mas documentacion y garantia'],
              en: ['Requires more documents and guarantees'],
            ),
          ),
        ],
        estimatedEffort: GuideEstimatedEffort.medium,
        estimatedTimeLabel: _t(
          locale,
          pt: '1-2 dias',
          es: '1-2 dias',
          en: '1-2 days',
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Golpe comum: fotos reais, proprietário falso, depósito exigido antes da visita. Nunca pague sem visitar.',
            'Desconfie de preços muito abaixo do mercado — costumam ser armadilhas para migrantes.',
            'Não assine nada sem ler: cláusulas abusivas em contratos de curto prazo são frequentes.',
          ],
          es: [
            'Estafa comun: fotos reales, propietario falso, deposito exigido antes de visitar. Nunca pagues sin visitar.',
            'Desconfia de precios muy por debajo del mercado — suelen ser trampas para migrantes.',
            'No firmes nada sin leer: clausulas abusivas en contratos de corto plazo son frecuentes.',
          ],
          en: [
            'Common scam: real photos, fake landlord, deposit demanded before visit. Never pay without visiting.',
            'Beware of prices well below market — these are often traps targeting migrants.',
            'Do not sign anything without reading it: abusive clauses in short-term contracts are common.',
          ],
        ),
        communityTips: _list(
          locale,
          pt: [
            '"Airbnb com desconto mensal foi a melhor opção — cobre endereço pro CPF e é fácil de cancelar."',
            '"Procura grupos de argentinos no Brasil no Facebook — tem gente alugando quarto direto sem burocracia."',
          ],
          es: [
            '"Airbnb con descuento mensual fue la mejor opcion — cubre direccion para el CPF y es facil de cancelar."',
            '"Busca grupos de argentinos en Brasil en Facebook — hay gente alquilando habitacion directo sin burocracia."',
          ],
          en: [
            '"Monthly Airbnb discount was the best option — covers address for CPF and is easy to cancel."',
            '"Look for Argentine groups in Brazil on Facebook — people rent rooms directly without bureaucracy."',
          ],
        ),
      ),
      GuideActionItem(
        id: 'item_2_1_cpf',
        title: _t(
          locale,
          pt: 'Organize seu CPF',
          es: 'Resuelve tu CPF',
          en: 'Sort out your CPF',
        ),
        shortDescription: _t(
          locale,
          pt: 'Você pode resolver isso ainda na Argentina pelo consulado ou nos primeiros dias no Brasil.',
          es: 'Puedes resolverlo todavia en Argentina por consulado o en los primeros dias en Brasil.',
          en: 'You can handle this while still in Argentina through the consulate or in your first days in Brazil.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.preparation,
        orderIndex: 5,
        isCompleted: false,
        icon: Icons.badge_outlined,
        context: _t(
          locale,
          pt: 'É o seu número fiscal no Brasil e entra em quase toda a vida prática da mudança.',
          es: 'Es tu numero fiscal en Brasil y aparece en casi toda la vida practica de la mudanza.',
          en: 'It is your Brazilian tax ID and shows up in almost every practical part of the move.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Sem CPF, você trava banco, trabalho formal, aluguel, contratos e boa parte dos cadastros.',
          es: 'Sin CPF, se traban banco, trabajo formal, alquiler, contratos y gran parte de los registros.',
          en: 'Without CPF, banking, formal work, rentals, contracts, and many registrations get blocked.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Solicitar CPF',
          es: 'Solicitar CPF',
          en: 'Request CPF',
        ),
        steps: _list(
          locale,
          pt: [
            'Escolha a rota: consulado/embaixada do Brasil ainda na Argentina ou Receita/parceiro depois da chegada.',
            'Confira no portal oficial quais documentos valem para a rota escolhida.',
            'Faça o pedido e confirme o número emitido para já usar em banco, Pix e cadastros.',
          ],
          es: [
            'Elige la ruta: consulado/embajada de Brasil todavia en Argentina o Receita/punto asociado despues de llegar.',
            'Revisa en el portal oficial que documentos sirven para la ruta elegida.',
            'Haz el tramite y confirma el numero emitido para usarlo en banco, Pix y registros.',
          ],
          en: [
            'Choose the route: Brazilian consulate/embassy while still in Argentina or Receita/partner service after arrival.',
            'Check the official portal for which documents are valid for your chosen route.',
            'Submit the request and confirm the issued number so you can use it for banking, Pix, and registrations.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já tem um CPF válido e consegue informá-lo em cadastros.',
          es: 'Ya tienes un CPF valido y puedes informarlo en registros.',
          en: 'You already have a valid CPF and can provide it in registrations.',
        ),
        tips: _list(
          locale,
          pt: [
            'Não espere a residência sair. O CPF pode ser pedido antes e até no exterior.',
            'Se você preferir deixar para o Brasil, resolva isso logo nos primeiros dias.',
          ],
          es: [
            'No esperes a que salga la residencia. El CPF puede pedirse antes e incluso en el exterior.',
            'Si prefieres dejarlo para Brasil, resuelvelo en los primeros dias.',
          ],
          en: [
            'Do not wait for residency approval. CPF can be requested before that and even abroad.',
            'If you prefer to leave it for Brazil, handle it in your first few days.',
          ],
        ),
        blockingReason: _t(
          locale,
          pt: 'CPF destrava conta bancária, trabalho formal, Pix, MEI e boa parte do resto do plano.',
          es: 'El CPF destraba cuenta bancaria, trabajo formal, Pix, MEI y gran parte del resto del plan.',
          en: 'CPF unlocks bank accounts, formal work, Pix, MEI, and much of the rest of the plan.',
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '30 min',
          es: '30 min',
          en: '30 min',
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'cpf_1',
            title: _t(
              locale,
              pt: 'Escolher a rota do CPF (Argentina ou Brasil)',
              es: 'Elegir la ruta del CPF (Argentina o Brasil)',
              en: 'Choose your CPF route (Argentina or Brazil)',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'cpf_2',
            title: _t(
              locale,
              pt: 'Separar os documentos pedidos pela rota escolhida',
              es: 'Separar los documentos pedidos por la ruta elegida',
              en: 'Prepare the documents required by your chosen route',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'cpf_3',
            title: _t(
              locale,
              pt: 'Confirmar e guardar o número emitido',
              es: 'Confirmar y guardar el numero emitido',
              en: 'Confirm and save the issued number',
            ),
            isCompleted: false,
          ),
        ],
        urgencyLevel: GuideUrgencyLevel.urgent,
        urgencySignal: _t(
          locale,
          pt: 'Se puder fazer ainda na Argentina, você chega mais destravado. Se não, resolva nos primeiros dias no Brasil.',
          es: 'Si puedes hacerlo todavia en Argentina, llegaras mas destrabado. Si no, resuelvelo en los primeros dias en Brasil.',
          en: 'If you can do it while still in Argentina, you arrive less blocked. If not, handle it in your first few days in Brazil.',
        ),
        communityTips: _list(
          locale,
          pt: [
            '"Fui aos Correios com passaporte + comprovante do Airbnb. CPF saiu na hora, custou R\$7."',
            '"Na Receita Federal é de graça mas fila maior. Correios cobram mas são mais rápidos."',
            '"Com o número do CPF em mãos, já abre conta digital — não precisa esperar o cartão chegar."',
          ],
          es: [
            '"Fui a los Correios con pasaporte + comprobante del Airbnb. El CPF salio al instante, costo R\$7."',
            '"En la Receita Federal es gratis pero hay mas fila. Correios cobran pero son mas rapidos."',
            '"Con el numero del CPF ya puedes abrir cuenta digital — no hace falta esperar la tarjeta."',
          ],
          en: [
            '"I went to Correios with passport + Airbnb confirmation. CPF issued immediately, cost R\$7."',
            '"Receita Federal is free but longer queue. Correios charges but is faster."',
            '"With the CPF number in hand you can already open a digital account — no need to wait for the card."',
          ],
        ),
      ),
      GuideActionItem(
        id: 'item_2_2_residencia',
        title: _t(
          locale,
          pt: 'Inicie sua residência Mercosul',
          es: 'Inicia tu residencia Mercosur',
          en: 'Start your Mercosur residence process',
        ),
        shortDescription: _t(
          locale,
          pt: 'Esse é o protocolo que coloca sua regularização em andamento dentro da janela legal dos 90 dias.',
          es: 'Este es el tramite que pone tu regularizacion en marcha dentro de la ventana legal de 90 dias.',
          en: 'This is the filing step that puts your regularization in motion within the legal 90-day window.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.documents,
        orderIndex: 8,
        isCompleted: false,
        icon: Icons.account_balance_outlined,
        dependencies: <String>['item_2_1_cpf'],
        context: _t(
          locale,
          pt: 'Como argentino, a rota Mercosul costuma ser o caminho principal para regularizar sua permanência no Brasil.',
          es: 'Como argentino, la ruta Mercosur suele ser el camino principal para regularizar tu permanencia en Brasil.',
          en: 'As an Argentine citizen, the Mercosur route is usually the main path to regularize your stay in Brazil.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Isso evita ficar irregular após os 90 dias e libera etapas importantes de trabalho e estabilidade.',
          es: 'Esto evita quedar irregular despues de los 90 dias y libera etapas importantes de trabajo y estabilidad.',
          en: 'This keeps you from becoming irregular after 90 days and unlocks important work and stability steps.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Ver rota oficial da residência',
          es: 'Ver ruta oficial de residencia',
          en: 'See the official residency path',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks
            .argentinaResidenceAgreement
            .toString(),
        steps: _list(
          locale,
          pt: [
            'Confirme no portal oficial quais documentos entram na sua rota Mercosul.',
            'Monte a pasta com documentos, cópias, foto e comprovantes antes de sair correndo atrás de vaga.',
            'Se a sua cidade costuma ter fila, tente agendar cedo; se não, vá com a pasta pronta logo no início da chegada.',
            'Vá ao atendimento e guarde o protocolo recebido.',
          ],
          es: [
            'Confirma en el portal oficial que documentos entran en tu ruta Mercosur.',
            'Arma la carpeta con documentos, copias, foto y comprobantes antes de salir corriendo por un turno.',
            'Si tu ciudad suele tener cola, intenta agendar temprano; si no, llega con la carpeta lista al inicio.',
            'Asiste al turno y guarda el protocolo recibido.',
          ],
          en: [
            'Confirm on the official portal which documents apply to your Mercosur route.',
            'Build the folder with documents, copies, photo, and proofs before rushing for an appointment.',
            'If your city usually has a backlog, try booking early; if not, arrive with the folder ready at the start.',
            'Attend the appointment and keep the protocol you receive.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já compareceu ao atendimento e está com o protocolo de residência em mãos.',
          es: 'Ya asististe al turno y tienes el protocolo de residencia en la mano.',
          en: 'You have already attended the appointment and have your residency protocol in hand.',
        ),
        tips: _list(
          locale,
          pt: [
            'Agendar antes de embarcar pode ajudar em cidades com fila, mas não é obrigação legal geral.',
            'O que é obrigatório é não deixar o protocolo para a reta final dos 90 dias.',
            'Leve originais e cópias para não perder a ida.',
          ],
          es: [
            'Agendar antes de viajar puede ayudar en ciudades con cola, pero no es una obligacion legal general.',
            'Lo obligatorio es no dejar el tramite para la recta final de los 90 dias.',
            'Lleva originales y copias para no perder la ida.',
          ],
          en: [
            'Booking before boarding can help in cities with long queues, but it is not a general legal requirement.',
            'What matters legally is not leaving the filing to the last stretch of the 90 days.',
            'Bring originals and copies so you do not waste the visit.',
          ],
        ),
        blockingReason: _t(
          locale,
          pt: 'A residência destrava regularização migratória, CTPS e parte das exigências para trabalho e contratos.',
          es: 'La residencia destraba regularizacion migratoria, CTPS y parte de las exigencias para trabajo y contratos.',
          en: 'Residency unlocks migration regularization, CTPS, and part of the requirements for work and contracts.',
        ),
        estimatedEffort: GuideEstimatedEffort.medium,
        estimatedTimeLabel: _t(
          locale,
          pt: '1 dia + espera',
          es: '1 dia + espera',
          en: '1 day + wait',
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'res_1',
            title: _t(
              locale,
              pt: 'Verificar a rota oficial e a agenda da Polícia Federal',
              es: 'Revisar la ruta oficial y la agenda de la Policia Federal',
              en: 'Check the official route and Federal Police booking',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'res_2',
            title: _t(
              locale,
              pt: 'Reunir documentos e fotos 3x4',
              es: 'Reunir documentos y fotos 3x4',
              en: 'Gather documents and 3x4 photos',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'res_3',
            title: _t(
              locale,
              pt: 'Comparecer ao atendimento e biometria',
              es: 'Asistir al turno y biometria',
              en: 'Attend appointment and biometrics',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'res_4',
            title: _t(
              locale,
              pt: 'Receber protocolo de residência',
              es: 'Recibir protocolo de residencia',
              en: 'Receive residency protocol',
            ),
            isCompleted: false,
          ),
        ],
        urgencyLevel: GuideUrgencyLevel.critical,
        urgencySignal: _t(
          locale,
          pt: 'Seu pedido precisa entrar dentro da janela dos 90 dias. Se a sua cidade tem fila, tente agendar cedo; se não, chegue com a pasta pronta.',
          es: 'Tu tramite tiene que entrar dentro de la ventana de 90 dias. Si tu ciudad tiene cola, intenta agendar temprano; si no, llega con la carpeta lista.',
          en: 'Your filing needs to happen within the 90-day window. If your city has queues, try booking early; if not, arrive with the folder ready.',
        ),
        survivalPhrases: [
          SurvivalPhrase(
            phrase: 'Tenho agendamento para hoje',
            translation: _t(
              locale,
              pt: 'Ao chegar na Polícia Federal',
              es: 'Al llegar a la Policia Federal',
              en: 'When arriving at Federal Police',
            ),
          ),
          SurvivalPhrase(
            phrase: 'Quero solicitar minha residência pelo Acordo do Mercosul',
            translation: _t(
              locale,
              pt: 'Para identificar a rota correta',
              es: 'Para identificar la via correcta',
              en: 'To identify the right process',
            ),
          ),
          SurvivalPhrase(
            phrase: 'Preciso do protocolo de residência',
            translation: _t(
              locale,
              pt: 'Ao final do atendimento',
              es: 'Al final del turno',
              en: 'At the end of the appointment',
            ),
          ),
        ],
        communityTips: _list(
          locale,
          pt: [
            '"Na minha cidade fez diferença agendar cedo; em outras, o mais importante foi chegar com a pasta pronta."',
            '"Leve originais E cópias de tudo. Eles pedem cópia na maioria das vezes, mas o original confirma."',
            '"O protocolo que você recebe já serve como documento — com ele dá pra abrir conta e alugar."',
          ],
          es: [
            '"En mi ciudad hizo diferencia agendar temprano; en otras, lo clave fue llegar con la carpeta lista."',
            '"Lleva originales Y copias de todo. Piden copia la mayoria de las veces, pero el original confirma."',
            '"El protocolo que recibes ya sirve como documento — con el puedes abrir cuenta y alquilar."',
          ],
          en: [
            '"In my city it helped to book early; in others, the key was arriving with the folder ready."',
            '"Bring originals AND copies of everything. They usually ask for copies but the original confirms."',
            '"The protocol you receive already works as a document — with it you can open an account and rent."',
          ],
        ),
      ),
      GuideActionItem(
        id: 'item_2_3_ctps',
        title: _t(
          locale,
          pt: 'Emitir Carteira de Trabalho Digital',
          es: 'Emitir la Carteira de Trabalho Digital',
          en: 'Issue the digital work card',
        ),
        shortDescription: _t(
          locale,
          pt: 'Com CPF e protocolo em mãos, a CTPS sai rápido pelo app do governo.',
          es: 'Con CPF y protocolo en mano, la CTPS sale rapido por la app del gobierno.',
          en: 'With CPF and your protocol in hand, CTPS is issued quickly in the government app.',
        ),
        fullContent: null,
        type: GuideActionType.external,
        phase: GuidePhase.documents,
        orderIndex: 9,
        isCompleted: false,
        icon: Icons.work_outline_rounded,
        dependencies: <String>['item_2_2_residencia'],
        context: _t(
          locale,
          pt: 'A CTPS é obrigatória para qualquer contratação formal (CLT) no Brasil.',
          es: 'La CTPS es obligatoria para cualquier contratacion formal (CLT) en Brasil.',
          en: 'CTPS is required for any formal employment (CLT) in Brazil.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Sem CTPS, nenhum empregador pode te registrar legalmente.',
          es: 'Sin CTPS, ningun empleador puede registrarte legalmente.',
          en: 'Without CTPS, no employer can legally register you.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Emitir CTPS',
          es: 'Emitir CTPS',
          en: 'Issue CTPS',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget:
            'https://www.gov.br/pt-br/servicos/obter-a-carteira-de-trabalho',
        steps: _list(
          locale,
          pt: [
            'Crie ou acesse sua conta Gov.br com CPF.',
            'Acesse o serviço "Carteira de Trabalho" no portal ou app.',
            'Confirme os dados e emita a CTPS digital.',
          ],
          es: [
            'Crea o accede a tu cuenta Gov.br con CPF.',
            'Accede al servicio "Carteira de Trabalho" en el portal o app.',
            'Confirma los datos y emite la CTPS digital.',
          ],
          en: [
            'Create or access your Gov.br account with CPF.',
            'Access the "Carteira de Trabalho" service in the portal or app.',
            'Confirm your data and issue the digital CTPS.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já tem a CTPS digital emitida e acessível no app ou portal Gov.br.',
          es: 'Ya tienes la CTPS digital emitida y accesible en la app o portal Gov.br.',
          en: 'You already have the digital CTPS issued and accessible in the Gov.br app or portal.',
        ),
        tips: _list(
          locale,
          pt: [
            'A CTPS digital é 100% online — não precisa ir a nenhum lugar.',
            'Se der erro no Gov.br, tente pelo navegador em vez do app.',
          ],
          es: [
            'La CTPS digital es 100% online — no necesitas ir a ningun lugar.',
            'Si da error en Gov.br, intenta por el navegador en vez de la app.',
          ],
          en: [
            'Digital CTPS is 100% online — you do not need to visit anywhere.',
            'If Gov.br gives an error, try the browser instead of the app.',
          ],
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'ctps_1',
            title: _t(
              locale,
              pt: 'Conta Gov.br criada',
              es: 'Cuenta Gov.br creada',
              en: 'Gov.br account created',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'ctps_2',
            title: _t(
              locale,
              pt: 'CTPS digital emitida',
              es: 'CTPS digital emitida',
              en: 'Digital CTPS issued',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'ctps_3',
            title: _t(
              locale,
              pt: 'Número da CTPS anotado',
              es: 'Numero de CTPS anotado',
              en: 'CTPS number noted down',
            ),
            isCompleted: false,
          ),
        ],
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '5-10 min',
          es: '5-10 min',
          en: '5-10 min',
        ),
      ),
      GuideActionItem(
        id: 'item_3_1_conta_bancaria',
        title: _t(
          locale,
          pt: 'Abra sua primeira conta no Brasil',
          es: 'Abre tu primera cuenta en Brasil',
          en: 'Open your first account in Brazil',
        ),
        shortDescription: _t(
          locale,
          pt: 'Comece pelo caminho mais fácil para receber, pagar e entrar no dia a dia brasileiro.',
          es: 'Empieza por el camino mas facil para cobrar, pagar y entrar en la vida diaria brasilena.',
          en: 'Start with the easiest path to get paid, pay, and enter daily life in Brazil.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.work,
        orderIndex: 10,
        isCompleted: false,
        icon: Icons.account_balance_rounded,
        dependencies: <String>['item_2_1_cpf'],
        context: _t(
          locale,
          pt: 'Você não precisa esperar a vida estar 100% resolvida para abrir a primeira conta.',
          es: 'No necesitas esperar a tener toda la vida resuelta para abrir la primera cuenta.',
          en: 'You do not need to have everything solved before opening your first account.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Sem conta local, você atrasa Pix, recebimentos, pagamentos e integração com apps e serviços.',
          es: 'Sin cuenta local, retrasas Pix, cobros, pagos e integracion con apps y servicios.',
          en: 'Without a local account, you delay Pix, income, payments, and integration with apps and services.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Escolher banco',
          es: 'Elegir banco',
          en: 'Choose a bank',
        ),
        steps: _list(
          locale,
          pt: [
            'Decida entre banco digital, banco tradicional ou conta focada em câmbio.',
            'Separe CPF, documento e selfie para abrir pelo app.',
            'Depois da aprovação, ative Pix e peça o cartão físico.',
          ],
          es: [
            'Decide entre banco digital, banco tradicional o cuenta enfocada en cambio.',
            'Separa CPF, documento y selfie para abrirla por la app.',
            'Despues de la aprobacion, activa Pix y pide la tarjeta fisica.',
          ],
          en: [
            'Decide between a digital bank, a traditional bank, or a foreign-exchange focused account.',
            'Prepare CPF, ID, and selfie to open it in the app.',
            'After approval, activate Pix and request the physical card.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Sua conta já está ativa e pronta para receber e pagar no Brasil.',
          es: 'Tu cuenta ya esta activa y lista para cobrar y pagar en Brasil.',
          en: 'Your account is already active and ready to receive and pay in Brazil.',
        ),
        tips: _list(
          locale,
          pt: [
            'Bancos digitais costumam aprovar mais rápido no início.',
            'Se você recebe do exterior, vale comparar uma conta comum com uma solução de câmbio.',
          ],
          es: [
            'Los bancos digitales suelen aprobar mas rapido al inicio.',
            'Si cobras del exterior, vale comparar una cuenta comun con una solucion de cambio.',
          ],
          en: [
            'Digital banks usually approve faster at the start.',
            'If you receive money from abroad, compare a regular account with a foreign-exchange solution.',
          ],
        ),
        decisionOptions: [
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'C6 Bank ou Inter (recomendado para estrangeiros)',
              es: 'C6 Bank o Inter (recomendado para extranjeros)',
              en: 'C6 Bank or Inter (recommended for foreigners)',
            ),
            description: _t(
              locale,
              pt: 'Aceitam DNI/passaporte estrangeiro mais facilmente que a maioria dos digitais.',
              es: 'Aceptan DNI/pasaporte extranjero mas facilmente que la mayoria de los digitales.',
              en: 'Accept foreign ID/passport more easily than most digital banks.',
            ),
            pros: _list(
              locale,
              pt: [
                'Menor rejeição para estrangeiros',
                'Processo 100% pelo app',
              ],
              es: ['Menor rechazo para extranjeros', 'Proceso 100% por app'],
              en: ['Lower rejection rate for foreigners', '100% app process'],
            ),
            cons: _list(
              locale,
              pt: ['Suporte presencial limitado'],
              es: ['Soporte presencial limitado'],
              en: ['Limited in-person support'],
            ),
            recommended: true,
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Banco tradicional',
              es: 'Banco tradicional',
              en: 'Traditional bank',
            ),
            description: _t(
              locale,
              pt: 'Pode fazer sentido depois que sua documentação estiver mais robusta.',
              es: 'Puede tener sentido cuando tu documentacion este mas fuerte.',
              en: 'May make sense once your documentation is stronger.',
            ),
            pros: _list(
              locale,
              pt: ['Rede física', 'Mais produtos'],
              es: ['Red fisica', 'Mas productos'],
              en: ['Branch network', 'More products'],
            ),
            cons: _list(
              locale,
              pt: ['Pode exigir mais documentos'],
              es: ['Puede exigir mas documentos'],
              en: ['May require more documents'],
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Conta com foco em câmbio',
              es: 'Cuenta enfocada en cambio',
              en: 'FX-focused account',
            ),
            description: _t(
              locale,
              pt: 'Útil para quem recebe dinheiro da Argentina ou do exterior.',
              es: 'Util para quien cobra dinero desde Argentina o del exterior.',
              en: 'Useful if you receive money from Argentina or abroad.',
            ),
            pros: _list(
              locale,
              pt: ['Ajuda na conversão'],
              es: ['Ayuda con la conversion'],
              en: ['Helps with conversion'],
            ),
            cons: _list(
              locale,
              pt: ['Nem sempre substitui a conta principal'],
              es: ['No siempre reemplaza la cuenta principal'],
              en: ['Does not always replace your main account'],
            ),
          ),
        ],
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '15 min',
          es: '15 min',
          en: '15 min',
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'bank_1',
            title: _t(
              locale,
              pt: 'Escolher banco digital (C6 Bank ou Inter — melhor para estrangeiros)',
              es: 'Elegir banco digital (C6 Bank o Inter — mejor para extranjeros)',
              en: 'Choose a digital bank (C6 Bank or Inter — best for foreigners)',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'bank_2',
            title: _t(
              locale,
              pt: 'Abrir conta pelo app com CPF + DNI',
              es: 'Abrir cuenta por app con CPF + DNI',
              en: 'Open account in the app with CPF + ID',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'bank_3',
            title: _t(
              locale,
              pt: 'Configurar chave Pix',
              es: 'Configurar clave Pix',
              en: 'Set up Pix key',
            ),
            isCompleted: false,
          ),
        ],
        urgencyLevel: GuideUrgencyLevel.watch,
        urgencySignal: _t(
          locale,
          pt: 'Nubank rejeita muitos estrangeiros sem histórico no Brasil — comece por C6 Bank ou Inter.',
          es: 'Nubank rechaza a muchos extranjeros sin historial en Brasil — empieza por C6 Bank o Inter.',
          en: 'Nubank rejects many foreigners with no Brazilian credit history — start with C6 Bank or Inter.',
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Nubank: rejeita frequentemente estrangeiros sem histórico no Brasil. Não é o melhor primeiro banco.',
            'Se a conta for reprovada, tente outro banco — cada pedido não prejudica o próximo.',
            'Não use conta de terceiros para receber pagamentos — gera problemas legais e fiscais.',
          ],
          es: [
            'Nubank: rechaza frecuentemente a extranjeros sin historial en Brasil. No es el mejor primer banco.',
            'Si la cuenta es rechazada, intenta con otro banco — cada solicitud no perjudica la siguiente.',
            'No uses la cuenta de un tercero para cobrar pagos — genera problemas legales y fiscales.',
          ],
          en: [
            'Nubank: frequently rejects foreigners with no Brazilian history. Not the best first bank.',
            'If rejected, try another bank — each application does not hurt the next one.',
            'Do not use a third party\'s account to receive payments — this creates legal and tax issues.',
          ],
        ),
        survivalPhrases: [
          SurvivalPhrase(
            phrase: 'Quero abrir uma conta corrente',
            translation: _t(
              locale,
              pt: 'Ao chegar no banco ou app',
              es: 'Al llegar al banco o app',
              en: 'When opening an account',
            ),
          ),
          SurvivalPhrase(
            phrase: 'Quais documentos são necessários?',
            translation: _t(
              locale,
              pt: 'Para confirmar o que levar',
              es: 'Para confirmar qué llevar',
              en: 'To confirm what to bring',
            ),
          ),
          SurvivalPhrase(
            phrase: 'Preciso cadastrar minha chave Pix',
            translation: _t(
              locale,
              pt: 'Depois de aprovado',
              es: 'Despues de la aprobacion',
              en: 'After account approval',
            ),
          ),
        ],
        communityTips: _list(
          locale,
          pt: [
            '"C6 Bank aprovou minha conta com CPF + passaporte argentino na hora. Nubank pediu comprovante de renda que eu não tinha."',
            '"Se o primeiro banco rejeitar, tente outro — cada solicitação não afeta a próxima."',
            '"Bradesco presencial costuma ser mais flexível para estrangeiros do que os digitais."',
          ],
          es: [
            '"C6 Bank aprobó mi cuenta con CPF + pasaporte argentino de inmediato. Nubank pedia comprobante de ingresos que no tenia."',
            '"Si el primer banco rechaza, prueba otro — cada solicitud no afecta la siguiente."',
            '"Bradesco presencial suele ser mas flexible para extranjeros que los digitales."',
          ],
          en: [
            '"C6 Bank approved my account with CPF + Argentine passport right away. Nubank asked for income proof I didn\'t have."',
            '"If the first bank rejects you, try another — each application does not affect the next."',
            '"In-branch Bradesco tends to be more flexible for foreigners than digital banks."',
          ],
        ),
      ),
      GuideActionItem(
        id: 'item_3_2_aluguel_fixo',
        title: _t(
          locale,
          pt: 'Buscar aluguel fixo na sua cidade',
          es: 'Buscar alquiler fijo en tu ciudad',
          en: 'Search for long-term rent in your city',
        ),
        shortDescription: _t(
          locale,
          pt: 'Depois da base inicial, você pode avançar para uma moradia mais estável.',
          es: 'Despues de la base inicial, puedes avanzar a una vivienda mas estable.',
          en: 'After the initial setup, you can move toward more stable housing.',
        ),
        fullContent: null,
        type: GuideActionType.tool,
        toolType: GuideToolType.housing,
        phase: GuidePhase.work,
        orderIndex: 12,
        isCompleted: false,
        icon: Icons.real_estate_agent_outlined,
        dependencies: <String>['item_2_1_cpf'],
        context: _t(
          locale,
          pt: 'Depois de CPF e primeiras semanas na moradia temporária, é hora de buscar algo fixo.',
          es: 'Despues de CPF y las primeras semanas en la vivienda temporal, es hora de buscar algo fijo.',
          en: 'After CPF and a few weeks in temporary housing, it is time to search for something permanent.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Moradia estável é pré-requisito para contrato de trabalho, escola e rotina.',
          es: 'Vivienda estable es prerrequisito para contrato laboral, escuela y rutina.',
          en: 'Stable housing is a prerequisite for work contracts, school, and daily routine.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Buscar imóveis',
          es: 'Buscar inmuebles',
          en: 'Search properties',
        ),
        steps: _list(
          locale,
          pt: [
            'Defina orçamento, bairro e exigências mínimas.',
            'Compare opções nos portais de aluguel.',
            'Visite ao menos 2-3 imóveis antes de decidir.',
            'Leia o contrato com atenção e confira garantias exigidas.',
          ],
          es: [
            'Define presupuesto, barrio y requisitos minimos.',
            'Compara opciones en los portales de alquiler.',
            'Visita al menos 2-3 inmuebles antes de decidir.',
            'Lee el contrato con atencion y revisa garantias exigidas.',
          ],
          en: [
            'Define budget, neighborhood, and minimum requirements.',
            'Compare options on rental portals.',
            'Visit at least 2-3 properties before deciding.',
            'Read the contract carefully and check required guarantees.',
          ],
        ),
        requirements: _list(
          locale,
          pt: ['CPF', 'Comprovante de renda ou fiador', 'Depósito caução'],
          es: [
            'CPF',
            'Comprobante de ingresos o garante',
            'Deposito de garantia',
          ],
          en: ['CPF', 'Proof of income or guarantor', 'Security deposit'],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você assinou contrato de aluguel e tem chaves do novo endereço.',
          es: 'Firmaste contrato de alquiler y tienes las llaves de la nueva direccion.',
          en: 'You signed a lease and have the keys to your new address.',
        ),
        estimatedEffort: GuideEstimatedEffort.longer,
        estimatedTimeLabel: _t(
          locale,
          pt: '1-4 semanas',
          es: '1-4 semanas',
          en: '1-4 weeks',
        ),
        urgencyLevel: GuideUrgencyLevel.watch,
        urgencySignal: _t(
          locale,
          pt: 'Fiador é exigido na maioria dos imóveis — descubra sua opção de garantia antes de visitar.',
          es: 'El garante es exigido en la mayoria de los inmuebles — descubre tu opcion de garantia antes de visitar.',
          en: 'A guarantor is required for most rentals — find out your guarantee option before viewing properties.',
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Fiador: exige brasileiro com imóvel próprio quitado. Sem fiador, busque imóveis com seguro-fiança ou título de capitalização.',
            'Golpe do falso anúncio: pedem depósito antecipado por foto bonita. Nunca pague sem visitar.',
            'Pressão para fechar rápido ("outro interessado") é sinal de alerta — tome seu tempo.',
            'Exigências ilegais: peça de comprovante de renda acima de 3x o aluguel é abusiva.',
          ],
          es: [
            'Garante: exige un brasileiro con inmueble propio libre de hipoteca. Sin garante, busca inmuebles con seguro-fianza o titulo de capitalizacion.',
            'Estafa del falso anuncio: piden deposito anticipado por foto bonita. Nunca pagues sin visitar.',
            'Presion para cerrar rapido ("hay otro interesado") es senal de alerta — toma tu tiempo.',
            'Exigencias ilegales: pedir comprobante de ingresos mayor a 3x el alquiler es abusivo.',
          ],
          en: [
            'Guarantor: requires a Brazilian with a fully-owned property. Without one, look for insurance-based or capitalization guarantee options.',
            'Fake listing scam: deposit demanded before visit based on nice photos. Never pay without visiting.',
            'Pressure to close fast ("another buyer interested") is a red flag — take your time.',
            'Illegal demands: requiring proof of income over 3x the rent is abusive and often illegal.',
          ],
        ),
        survivalPhrases: [
          SurvivalPhrase(
            phrase: 'Quero alugar este imóvel',
            translation: _t(
              locale,
              pt: 'Ao visitar o imóvel',
              es: 'Al visitar el inmueble',
              en: 'When visiting the property',
            ),
          ),
          SurvivalPhrase(
            phrase: 'Qual é o valor do aluguel e do condomínio?',
            translation: _t(
              locale,
              pt: 'Para entender o custo total',
              es: 'Para entender el costo total',
              en: 'To understand total cost',
            ),
          ),
          SurvivalPhrase(
            phrase: 'Vocês aceitam seguro-fiança no lugar de fiador?',
            translation: _t(
              locale,
              pt: 'Para resolver sem fiador brasileiro',
              es: 'Para resolver sin garante brasileno',
              en: 'If you have no Brazilian guarantor',
            ),
          ),
          SurvivalPhrase(
            phrase: 'Posso ver o contrato antes de assinar?',
            translation: _t(
              locale,
              pt: 'Sempre peça antes de comprometer',
              es: 'Siempre pide antes de comprometerte',
              en: 'Always ask before committing',
            ),
          ),
        ],
        communityTips: _list(
          locale,
          pt: [
            '"Achei apartamento pelo QuintoAndar sem fiador — eles aceitam seguro-fiança e o processo é 100% online."',
            '"Facebook Marketplace tem bastante quarto e kitnet direto com proprietário, sem imobiliária."',
            '"Peça sempre a versão digital do contrato para traduzir com IA antes de assinar."',
          ],
          es: [
            '"Encontre departamento por QuintoAndar sin garante — aceptan seguro-fianza y el proceso es 100% online."',
            '"Facebook Marketplace tiene bastante habitacion y estudio directo con propietario, sin inmobiliaria."',
            '"Pide siempre la version digital del contrato para traducirlo con IA antes de firmar."',
          ],
          en: [
            '"I found an apartment through QuintoAndar without a guarantor — they accept rental insurance and the process is 100% online."',
            '"Facebook Marketplace has plenty of rooms and studios direct from owners, no agency."',
            '"Always ask for the digital version of the lease to translate it with AI before signing."',
          ],
        ),
      ),
      GuideActionItem(
        id: 'item_3_3_pix',
        title: _t(
          locale,
          pt: 'Configure seus pagamentos no Brasil',
          es: 'Configura tus pagos en Brasil',
          en: 'Set up payments in Brazil',
        ),
        shortDescription: _t(
          locale,
          pt: 'Pix entra no seu dia a dia desde o primeiro mercado até aluguel, salário e serviços.',
          es: 'Pix entra en tu dia a dia desde el primer supermercado hasta alquiler, salario y servicios.',
          en: 'Pix shows up in daily life from your first grocery run to rent, salary, and services.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.work,
        orderIndex: 11,
        isCompleted: false,
        icon: Icons.pix_outlined,
        dependencies: <String>['item_3_1_conta_bancaria'],
        context: _t(
          locale,
          pt: 'No Brasil, pagar e receber rápido quase sempre significa Pix.',
          es: 'En Brasil, pagar y cobrar rapido casi siempre significa Pix.',
          en: 'In Brazil, paying and receiving fast almost always means Pix.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Sem Pix configurado, você fica fora do jeito normal de pagar contas, dividir gastos e receber dinheiro.',
          es: 'Sin Pix configurado, quedas fuera de la forma normal de pagar cuentas, dividir gastos y recibir dinero.',
          en: 'Without Pix set up, you are outside the normal way people pay bills, split costs, and receive money.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Configurar Pix',
          es: 'Configurar Pix',
          en: 'Set up Pix',
        ),
        steps: _list(
          locale,
          pt: [
            'Entre no app da sua conta.',
            'Cadastre uma chave Pix, de preferência o CPF.',
            'Faça um teste pequeno para garantir que está funcionando.',
          ],
          es: [
            'Entra en la app de tu cuenta.',
            'Registra una clave Pix, de preferencia el CPF.',
            'Haz una prueba pequena para confirmar que funciona.',
          ],
          en: [
            'Open your banking app.',
            'Register a Pix key, preferably your CPF.',
            'Run a small test transfer to confirm it works.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já consegue enviar e receber Pix pela conta principal.',
          es: 'Ya puedes enviar y recibir Pix desde tu cuenta principal.',
          en: 'You can already send and receive Pix from your main account.',
        ),
        tips: _list(
          locale,
          pt: ['Além do Pix, aprenda a pagar boleto pelo app do banco.'],
          es: ['Ademas de Pix, aprende a pagar boleto desde la app del banco.'],
          en: ['Besides Pix, learn how to pay boletos in your banking app.'],
        ),
        blockingReason: _t(
          locale,
          pt: 'Pagamentos travados dificultam moradia, compras, recebimentos e rotina básica.',
          es: 'Pagos trabados dificultan vivienda, compras, cobros y rutina basica.',
          en: 'Blocked payments make housing, purchases, income, and basic routine harder.',
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'pix_1',
            title: _t(
              locale,
              pt: 'Chave Pix cadastrada (CPF)',
              es: 'Clave Pix registrada (CPF)',
              en: 'Pix key registered (CPF)',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'pix_2',
            title: _t(
              locale,
              pt: 'Transferência de teste feita',
              es: 'Transferencia de prueba hecha',
              en: 'Test transfer completed',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'pix_3',
            title: _t(
              locale,
              pt: 'Pagamento de boleto testado',
              es: 'Pago de boleto probado',
              en: 'Boleto payment tested',
            ),
            isCompleted: false,
          ),
        ],
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(locale, pt: '5 min', es: '5 min', en: '5 min'),
      ),
      GuideActionItem(
        id: 'item_3_4_trabalho',
        title: _t(
          locale,
          pt: 'Defina como sua renda vai funcionar no Brasil',
          es: 'Define como va a funcionar tu ingreso en Brasil',
          en: 'Define how your income will work in Brazil',
        ),
        shortDescription: _t(
          locale,
          pt: 'Essa etapa é menos sobre informação e mais sobre escolher o caminho certo para começar a receber.',
          es: 'Esta etapa es menos sobre informacion y mas sobre elegir el camino correcto para empezar a cobrar.',
          en: 'This step is less about information and more about choosing the right path to start earning.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.work,
        orderIndex: 13,
        isCompleted: false,
        icon: Icons.work_history_outlined,
        dependencies: <String>['item_2_3_ctps'],
        context: _t(
          locale,
          pt: 'Você precisa de um plano de renda viável já nos primeiros meses.',
          es: 'Necesitas un plan de ingresos viable ya en los primeros meses.',
          en: 'You need a viable income plan in the first months.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'A escolha errada gera atraso em documentos, impostos, nota fiscal ou busca de trabalho.',
          es: 'Una mala eleccion genera atraso en documentos, impuestos, factura o busqueda laboral.',
          en: 'The wrong choice creates delays in documents, taxes, invoicing, or job search.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Escolher caminho de renda',
          es: 'Elegir camino de ingreso',
          en: 'Choose income path',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.officialJobsPortal
            .toString(),
        requirements: _list(
          locale,
          pt: ['CPF', 'CTPS (para CLT)', 'Conta bancária ativa'],
          es: ['CPF', 'CTPS (para CLT)', 'Cuenta bancaria activa'],
          en: ['CPF', 'CTPS (for CLT)', 'Active bank account'],
        ),
        steps: _list(
          locale,
          pt: [
            'Decida se seu foco inicial é CLT, freelancer/MEI ou renda remota da Argentina.',
            'Liste o que falta para esse caminho funcionar de verdade.',
            'Faça a primeira ação concreta: candidatar, abrir MEI ou estruturar recebimento.',
          ],
          es: [
            'Decide si tu foco inicial sera CLT, freelancer/MEI o ingreso remoto desde Argentina.',
            'Lista lo que falta para que ese camino funcione de verdad.',
            'Haz la primera accion concreta: postularte, abrir MEI o estructurar cobro.',
          ],
          en: [
            'Decide whether your initial focus is CLT, freelancer/MEI, or remote income from Argentina.',
            'List what is still missing for that path to work in reality.',
            'Take the first concrete action: apply, open MEI, or structure payments.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já escolheu um caminho principal de renda e executou o primeiro passo real dele.',
          es: 'Ya elegiste un camino principal de ingresos y ejecutaste su primer paso real.',
          en: 'You have already chosen a main income path and completed its first real step.',
        ),
        tips: _list(
          locale,
          pt: [
            'Quem vai trabalhar formalmente precisa priorizar CTPS e regularização.',
            'Quem vai seguir como autônomo deve checar cedo se MEI faz sentido para a atividade.',
          ],
          es: [
            'Quien va a trabajar formalmente debe priorizar CTPS y regularizacion.',
            'Quien siga como autonomo debe revisar temprano si MEI tiene sentido para su actividad.',
          ],
          en: [
            'Anyone going into formal work should prioritize CTPS and regularization.',
            'Anyone going independent should check early whether MEI fits their activity.',
          ],
        ),
        decisionOptions: [
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Emprego CLT',
              es: 'Empleo CLT',
              en: 'Formal employment',
            ),
            description: _t(
              locale,
              pt: 'Melhor para quem quer renda previsível e benefícios formais.',
              es: 'Mejor para quien quiere ingresos previsibles y beneficios formales.',
              en: 'Best for someone who wants predictable income and formal benefits.',
            ),
            pros: _list(
              locale,
              pt: ['Mais estabilidade', 'Benefícios trabalhistas'],
              es: ['Mas estabilidad', 'Beneficios laborales'],
              en: ['More stability', 'Employment benefits'],
            ),
            cons: _list(
              locale,
              pt: ['Exige mais documentação'],
              es: ['Exige mas documentacion'],
              en: ['Requires more documentation'],
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Freelancer ou MEI',
              es: 'Freelancer o MEI',
              en: 'Freelancer or MEI',
            ),
            description: _t(
              locale,
              pt: 'Bom para quem já consegue vender serviço e precisa emitir nota.',
              es: 'Bueno para quien ya puede vender servicios y necesita facturar.',
              en: 'Good for someone who can already sell services and needs to issue invoices.',
            ),
            pros: _list(
              locale,
              pt: ['Mais flexibilidade', 'Pode começar rápido'],
              es: ['Mas flexibilidad', 'Puede empezar rapido'],
              en: ['More flexibility', 'Can start quickly'],
            ),
            cons: _list(
              locale,
              pt: ['Renda menos previsível'],
              es: ['Ingreso menos previsible'],
              en: ['Less predictable income'],
            ),
            recommended: true,
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Remoto para empresa argentina',
              es: 'Remoto para empresa argentina',
              en: 'Remote for an Argentine company',
            ),
            description: _t(
              locale,
              pt: 'Pode ser a transição mais simples se você já tem renda ativa.',
              es: 'Puede ser la transicion mas simple si ya tienes ingresos activos.',
              en: 'May be the simplest transition if you already have active income.',
            ),
            pros: _list(
              locale,
              pt: ['Continuidade imediata'],
              es: ['Continuidad inmediata'],
              en: ['Immediate continuity'],
            ),
            cons: _list(
              locale,
              pt: ['Exige atenção fiscal'],
              es: ['Exige atencion fiscal'],
              en: ['Requires tax attention'],
            ),
          ),
        ],
        blockingReason: _t(
          locale,
          pt: 'Renda organizada define moradia, estabilidade e quais documentos viram prioridade.',
          es: 'Ingresos organizados definen vivienda, estabilidad y que documentos pasan a ser prioridad.',
          en: 'Organized income defines housing, stability, and which documents become priority.',
        ),
        estimatedEffort: GuideEstimatedEffort.medium,
        estimatedTimeLabel: _t(
          locale,
          pt: '30-60 min',
          es: '30-60 min',
          en: '30-60 min',
        ),
        communityTips: _list(
          locale,
          pt: [
            '"UX Designer: R\$4.000–9.000. Desenvolvedor: R\$5.000–15.000. Salário médio geral em SP/RJ: R\$3.500–6.000."',
            '"Workana e 99Freelas aceitam estrangeiros com CPF — ótimo pra começar freelancer antes do emprego fixo."',
            '"Se você trabalha remotamente para empresa argentina, pode precisar declarar renda nos dois países. MEI simplifica isso."',
            '"LinkedIn Brasil funciona muito bem. Perfil em português aumenta muito o retorno."',
          ],
          es: [
            '"UX Designer: R\$4.000–9.000. Desarrollador: R\$5.000–15.000. Salario promedio general en SP/RJ: R\$3.500–6.000."',
            '"Workana y 99Freelas aceptan extranjeros con CPF — genial para empezar freelance antes del trabajo fijo."',
            '"Si trabajas remotamente para empresa argentina, puede que tengas que declarar ingresos en los dos paises. MEI simplifica eso."',
            '"LinkedIn Brasil funciona muy bien. Perfil en portugues aumenta mucho la respuesta."',
          ],
          en: [
            '"UX Designer: R\$4,000–9,000. Developer: R\$5,000–15,000. Average salary in SP/RJ: R\$3,500–6,000."',
            '"Workana and 99Freelas accept foreigners with CPF — great for freelancing before landing a full-time role."',
            '"If you work remotely for an Argentine company, you may need to declare income in both countries. MEI simplifies this."',
            '"Brazilian LinkedIn works very well. A Portuguese profile significantly increases response rate."',
          ],
        ),
      ),
      GuideActionItem(
        id: 'item_4_1_cnh',
        title: _t(
          locale,
          pt: 'Converter carteira argentina para CNH',
          es: 'Convertir licencia argentina a CNH',
          en: 'Convert Argentine license to CNH',
        ),
        shortDescription: _t(
          locale,
          pt: 'Se você vai dirigir no Brasil, a conversão evita recomeçar do zero.',
          es: 'Si vas a manejar en Brasil, la conversion evita empezar de cero.',
          en: 'If you plan to drive in Brazil, conversion keeps you from starting from scratch.',
        ),
        fullContent: null,
        type: GuideActionType.external,
        phase: GuidePhase.arrival,
        orderIndex: 15,
        isCompleted: false,
        icon: Icons.directions_car_outlined,
        dependencies: <String>['item_2_2_residencia'],
        context: _t(
          locale,
          pt: 'A conversão permite que você dirija legalmente no Brasil usando sua experiência argentina.',
          es: 'La conversion permite que manejes legalmente en Brasil usando tu experiencia argentina.',
          en: 'Conversion lets you drive legally in Brazil using your Argentine driving experience.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Dirigir com carteira vencida ou estrangeira sem conversão pode gerar multa e apreensão do veículo.',
          es: 'Manejar con licencia vencida o extranjera sin conversion puede generar multa y detencion del vehiculo.',
          en: 'Driving with an expired or unconverted foreign license can result in fines and vehicle seizure.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Buscar DETRAN',
          es: 'Buscar DETRAN',
          en: 'Find DETRAN',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: 'https://www.detran.sp.gov.br',
        steps: _list(
          locale,
          pt: [
            'Verifique se sua carteira argentina está válida e dentro do prazo aceito para conversão.',
            'Reúna CPF, residência, carteira argentina original e tradução juramentada.',
            'Agende atendimento no DETRAN do seu estado.',
            'Faça exame médico e psicotécnico no local indicado.',
            'Pague as taxas e aguarde a emissão da CNH.',
          ],
          es: [
            'Verifica si tu licencia argentina esta valida y dentro del plazo aceptado para conversion.',
            'Reune CPF, residencia, licencia argentina original y traduccion jurada.',
            'Agenda turno en el DETRAN de tu estado.',
            'Haz examen medico y psicotecnico en el lugar indicado.',
            'Paga las tasas y espera la emision de la CNH.',
          ],
          en: [
            'Check that your Argentine license is valid and within the accepted conversion window.',
            'Gather CPF, residency, original Argentine license, and sworn translation.',
            'Schedule an appointment at your state DETRAN.',
            'Take the medical and psychological exams at the indicated location.',
            'Pay the fees and wait for the CNH to be issued.',
          ],
        ),
        requirements: _list(
          locale,
          pt: [
            'CPF',
            'Residência regular',
            'Carteira de motorista argentina válida',
            'Tradução juramentada da carteira',
            'Exame médico e psicotécnico aprovados',
          ],
          es: [
            'CPF',
            'Residencia regular',
            'Licencia de conducir argentina valida',
            'Traduccion jurada de la licencia',
            'Examen medico y psicotecnico aprobados',
          ],
          en: [
            'CPF',
            'Regular residency',
            'Valid Argentine driver license',
            'Sworn translation of the license',
            'Approved medical and psychological exams',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já tem a CNH brasileira emitida ou o processo no DETRAN iniciado.',
          es: 'Ya tienes la CNH brasilena emitida o el proceso en DETRAN iniciado.',
          en: 'You already have the Brazilian CNH issued or the DETRAN process started.',
        ),
        tips: _list(
          locale,
          pt: [
            'O processo varia entre estados. Consulte o DETRAN da sua cidade antes de começar.',
            'A tradução juramentada precisa ser feita por tradutor registrado na junta comercial.',
          ],
          es: [
            'El proceso varia entre estados. Consulta el DETRAN de tu ciudad antes de empezar.',
            'La traduccion jurada debe ser hecha por traductor registrado.',
          ],
          en: [
            'The process varies by state. Check your city DETRAN before starting.',
            'The sworn translation must be done by a registered translator.',
          ],
        ),
        decisionOptions: [
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Converter carteira existente',
              es: 'Convertir licencia existente',
              en: 'Convert existing license',
            ),
            description: _t(
              locale,
              pt: 'Usa sua carteira argentina como base para obter a CNH.',
              es: 'Usa tu licencia argentina como base para obtener la CNH.',
              en: 'Use your Argentine license as a base to get the CNH.',
            ),
            pros: _list(
              locale,
              pt: ['Sem autoescola', 'Mais rápido'],
              es: ['Sin autoescuela', 'Mas rapido'],
              en: ['No driving school', 'Faster'],
            ),
            cons: _list(
              locale,
              pt: ['Precisa de tradução juramentada', 'Taxas do DETRAN'],
              es: ['Necesita traduccion jurada', 'Tasas del DETRAN'],
              en: ['Needs sworn translation', 'DETRAN fees'],
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Tirar CNH do zero',
              es: 'Sacar CNH desde cero',
              en: 'Get CNH from scratch',
            ),
            description: _t(
              locale,
              pt: 'Processo completo com autoescola e provas.',
              es: 'Proceso completo con autoescuela y examenes.',
              en: 'Full process with driving school and exams.',
            ),
            pros: _list(
              locale,
              pt: ['Não precisa da carteira argentina'],
              es: ['No necesita la licencia argentina'],
              en: ['Does not need Argentine license'],
            ),
            cons: _list(
              locale,
              pt: ['Mais demorado', 'Mais caro', 'Exige autoescola'],
              es: ['Mas lento', 'Mas caro', 'Exige autoescuela'],
              en: ['Slower', 'More expensive', 'Requires driving school'],
            ),
          ),
        ],
        checklistItems: [
          ChecklistSubItem(
            id: 'cnh_1',
            title: _t(
              locale,
              pt: 'Tradução juramentada providenciada',
              es: 'Traduccion jurada obtenida',
              en: 'Sworn translation obtained',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'cnh_2',
            title: _t(
              locale,
              pt: 'Atendimento no DETRAN agendado',
              es: 'Turno en DETRAN agendado',
              en: 'DETRAN appointment scheduled',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'cnh_3',
            title: _t(
              locale,
              pt: 'Exames médico e psicotécnico feitos',
              es: 'Examenes medico y psicotecnico hechos',
              en: 'Medical and psychological exams done',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'cnh_4',
            title: _t(
              locale,
              pt: 'CNH emitida',
              es: 'CNH emitida',
              en: 'CNH issued',
            ),
            isCompleted: false,
          ),
        ],
        estimatedEffort: GuideEstimatedEffort.longer,
        estimatedTimeLabel: _t(
          locale,
          pt: '2-4 semanas',
          es: '2-4 semanas',
          en: '2-4 weeks',
        ),
      ),
      GuideActionItem(
        id: 'item_4_2_saude',
        title: _t(
          locale,
          pt: 'Tire seu Cartão SUS e defina sua cobertura',
          es: 'Saca tu Tarjeta SUS y define tu cobertura',
          en: 'Get your SUS card and set up your health coverage',
        ),
        shortDescription: _t(
          locale,
          pt: 'Depois de se instalar, organize o que vai usar no dia a dia: SUS, UPA de referência e, se fizer sentido, plano privado.',
          es: 'Despues de instalarte, organiza lo que usaras en el dia a dia: SUS, UPA de referencia y, si tiene sentido, plan privado.',
          en: 'After settling in, organize what you will use day to day: SUS, your reference UPA, and a private plan if it makes sense.',
        ),
        fullContent: null,
        type: GuideActionType.checklist,
        phase: GuidePhase.arrival,
        orderIndex: 16,
        isCompleted: false,
        icon: Icons.local_hospital_outlined,
        context: _t(
          locale,
          pt: 'Você pode usar o SUS e, em alguns casos, complementar com plano privado.',
          es: 'Puedes usar el SUS y, en algunos casos, complementar con un plan privado.',
          en: 'You can use SUS and, in some cases, complement it with a private plan.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Chegar sem saber onde se atender cria risco desnecessário justamente no período mais instável da mudança.',
          es: 'Llegar sin saber donde atenderte crea un riesgo innecesario justo en el periodo mas inestable del cambio.',
          en: 'Arriving without knowing where to get care creates unnecessary risk during the most unstable part of the move.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Ver Cartão SUS',
          es: 'Ver Cartao SUS',
          en: 'See SUS card',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.susPortal.toString(),
        steps: _list(
          locale,
          pt: [
            'Veja se o SUS já cobre o que você precisa no começo.',
            'Se quiser organizar seu cadastro no SUS, confira na UBS da região como fazer o CNS/Cartão SUS com seus documentos.',
            'Se tiver CLT, confirme se o trabalho oferece plano.',
            'Se for autônomo, compare se vale contratar algo privado nos primeiros meses.',
            'Localize a UPA ou posto de saúde mais perto da sua casa.',
          ],
          es: [
            'Mira si el SUS ya cubre lo que necesitas al principio.',
            'Si quieres ordenar tu registro en el SUS, revisa en la UBS de tu zona como sacar el CNS/Tarjeta SUS con tus documentos.',
            'Si tienes trabajo CLT, confirma si ofrece plan.',
            'Si eres autonomo, compara si vale contratar algo privado en los primeros meses.',
            'Localiza la UPA o puesto de salud mas cerca de tu casa.',
          ],
          en: [
            'Check whether SUS already covers what you need at the start.',
            'If you want to organize your SUS registration, check with the local UBS how to obtain your CNS/SUS card with your documents.',
            'If you have CLT work, confirm whether it offers a health plan.',
            'If you are self-employed, compare whether private cover is worth it in the first months.',
            'Find the nearest UPA or health clinic to your home.',
          ],
        ),
        requirements: _list(
          locale,
          pt: ['Documento com foto', 'CPF quando solicitado pela UBS'],
          es: ['Documento con foto', 'CPF cuando la UBS lo pida'],
          en: ['Photo ID', 'CPF when requested by the UBS'],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já sabe qual será sua cobertura inicial e como acessá-la se precisar.',
          es: 'Ya sabes cual sera tu cobertura inicial y como acceder a ella si la necesitas.',
          en: 'You already know what your initial coverage will be and how to access it if needed.',
        ),
        tips: _list(
          locale,
          pt: [
            'Mesmo com plano, vale entender qual posto ou UPA atende sua região.',
            'Para urgência, a referência continua sendo UPA/hospital mesmo antes de organizar o CNS.',
            'O Cartão Nacional de Saúde (CNS) costuma ser organizado na UBS com os documentos que a unidade pedir.',
          ],
          es: [
            'Incluso con plan, conviene saber que puesto o UPA atiende tu zona.',
            'Para urgencias, la referencia sigue siendo UPA/hospital incluso antes de organizar el CNS.',
            'La Tarjeta Nacional de Salud (CNS) suele organizarse en la UBS con los documentos que la unidad pida.',
          ],
          en: [
            'Even with a plan, it is worth knowing which clinic or UPA serves your area.',
            'For urgent care, UPA/hospital remains the reference even before organizing the CNS.',
            'The National Health Card (CNS) is usually arranged at the UBS with whichever documents the unit requests.',
          ],
        ),
        decisionOptions: [
          GuideDecisionOption(
            title: _t(locale, pt: 'Só SUS', es: 'Solo SUS', en: 'SUS only'),
            description: _t(
              locale,
              pt: 'Sistema público e gratuito. Cobre consultas, exames, internações e emergências.',
              es: 'Sistema publico y gratuito. Cubre consultas, examenes, internaciones y emergencias.',
              en: 'Free public system. Covers appointments, exams, hospitalizations, and emergencies.',
            ),
            pros: _list(
              locale,
              pt: ['Gratuito', 'Cobertura completa'],
              es: ['Gratis', 'Cobertura completa'],
              en: ['Free', 'Full coverage'],
            ),
            cons: _list(
              locale,
              pt: ['Fila para especialistas', 'Varia por região'],
              es: ['Fila para especialistas', 'Varia por region'],
              en: ['Queue for specialists', 'Varies by region'],
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'SUS + plano privado',
              es: 'SUS + plan privado',
              en: 'SUS + private plan',
            ),
            description: _t(
              locale,
              pt: 'Combina SUS para emergências com plano privado para consultas e exames rápidos.',
              es: 'Combina SUS para emergencias con plan privado para consultas y examenes rapidos.',
              en: 'Combines SUS for emergencies with a private plan for fast appointments and exams.',
            ),
            pros: _list(
              locale,
              pt: ['Atendimento mais rápido', 'Rede ampla'],
              es: ['Atencion mas rapida', 'Red amplia'],
              en: ['Faster care', 'Wide network'],
            ),
            cons: _list(
              locale,
              pt: ['Custo mensal', 'Carência em alguns planos'],
              es: ['Costo mensual', 'Carencia en algunos planes'],
              en: ['Monthly cost', 'Waiting period on some plans'],
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Plano do empregador',
              es: 'Plan del empleador',
              en: 'Employer plan',
            ),
            description: _t(
              locale,
              pt: 'Oferecido pela empresa se você entrar em regime CLT.',
              es: 'Ofrecido por la empresa si entras en regimen CLT.',
              en: 'Offered by the company if you enter a CLT contract.',
            ),
            pros: _list(
              locale,
              pt: ['Geralmente sem custo extra', 'Já inclui dependentes'],
              es: ['Generalmente sin costo extra', 'Ya incluye dependientes'],
              en: ['Usually no extra cost', 'Often includes dependents'],
            ),
            cons: _list(
              locale,
              pt: ['Só se tiver CLT', 'Coparticipação em alguns'],
              es: ['Solo si tienes CLT', 'Coparticipacion en algunos'],
              en: ['Only with CLT', 'Copay on some plans'],
            ),
          ),
        ],
        checklistItems: [
          ChecklistSubItem(
            id: 'saude_1',
            title: _t(
              locale,
              pt: 'Cartão SUS / CNS obtido',
              es: 'Tarjeta SUS / CNS obtenida',
              en: 'SUS / CNS card obtained',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'saude_2',
            title: _t(
              locale,
              pt: 'UPA ou posto mais perto identificado',
              es: 'UPA o puesto mas cercano identificado',
              en: 'Nearest UPA or clinic identified',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'saude_3',
            title: _t(
              locale,
              pt: 'Decisão sobre plano privado tomada',
              es: 'Decision sobre plan privado tomada',
              en: 'Private plan decision made',
            ),
            isCompleted: false,
          ),
        ],
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '15 min',
          es: '15 min',
          en: '15 min',
        ),
      ),
      GuideActionItem(
        id: 'item_4_5_registro_rnm',
        title: _t(
          locale,
          pt: 'Acompanhe o registro RNM / CRNM',
          es: 'Sigue el registro RNM / CRNM',
          en: 'Track your RNM / CRNM registration',
        ),
        shortDescription: _t(
          locale,
          pt: 'Depois da autorização concedida, existe uma etapa própria de registro migratório e emissão da CRNM.',
          es: 'Despues de la autorizacion concedida, existe una etapa propia de registro migratorio y emision de la CRNM.',
          en: 'After residence is granted, there is a separate migration registration and CRNM issuance step.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.arrival,
        orderIndex: 17,
        isCompleted: false,
        icon: Icons.badge_rounded,
        dependencies: <String>['item_2_2_residencia'],
        context: _t(
          locale,
          pt: 'Autorização de residência e registro migratório não são a mesma coisa. Quando a autorização sair, acompanhe o registro para não perder o prazo oficial.',
          es: 'Autorizacion de residencia y registro migratorio no son lo mismo. Cuando salga la autorizacion, sigue el registro para no perder el plazo oficial.',
          en: 'Residence authorization and migration registration are not the same thing. Once authorization is granted, follow the registration step so you do not miss the official deadline.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'O protocolo inicial preserva direitos, mas o registro e a emissão da CRNM fecham a documentação migratória da etapa temporária.',
          es: 'El protocolo inicial preserva derechos, pero el registro y la emision de la CRNM cierran la documentacion migratoria de la etapa temporaria.',
          en: 'The initial protocol preserves rights, but registration and CRNM issuance complete the migration documentation for the temporary stage.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Ver registro RNM',
          es: 'Ver registro RNM',
          en: 'See RNM registration',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.rnMRegistrationGuide
            .toString(),
        steps: _list(
          locale,
          pt: [
            'Acompanhe quando a autorização de residência for concedida ou publicada.',
            'Confira a orientação oficial do RNM/CRNM e o prazo aplicável ao seu caso.',
            'Faça o registro na janela correta e guarde o protocolo/cartão emitido.',
          ],
          es: [
            'Sigue cuando la autorizacion de residencia sea concedida o publicada.',
            'Revisa la orientacion oficial del RNM/CRNM y el plazo que aplica a tu caso.',
            'Haz el registro en la ventana correcta y guarda el protocolo/tarjeta emitida.',
          ],
          en: [
            'Track when residence authorization is granted or published.',
            'Check the official RNM/CRNM guidance and the deadline that applies to your case.',
            'Complete the registration in the correct window and keep the issued protocol/card.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já entendeu o passo de registro e está acompanhando a emissão do seu RNM / CRNM sem perder o prazo oficial.',
          es: 'Ya entendiste el paso de registro y estas siguiendo la emision de tu RNM / CRNM sin perder el plazo oficial.',
          en: 'You already understand the registration step and are tracking your RNM / CRNM issuance without missing the official deadline.',
        ),
        tips: _list(
          locale,
          pt: [
            'O protocolo da residência já ajuda no meio do caminho, então você não depende de um cartão instantâneo.',
            'Quando a autorização for concedida já no Brasil, o registro costuma ter prazo próprio de 30 dias.',
          ],
          es: [
            'El protocolo de residencia ya ayuda en el camino, asi que no dependes de una tarjeta instantanea.',
            'Cuando la autorizacion se concede ya en Brasil, el registro suele tener un plazo propio de 30 dias.',
          ],
          en: [
            'The residency protocol already helps in the meantime, so you do not depend on an instant card.',
            'When authorization is granted in Brazil, registration usually has its own 30-day deadline.',
          ],
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '10 min + acompanhamento',
          es: '10 min + seguimiento',
          en: '10 min + follow-up',
        ),
        urgencyLevel: GuideUrgencyLevel.watch,
        urgencySignal: _t(
          locale,
          pt: 'Essa etapa só entra depois da autorização concedida, mas não deixe passar se o portal da PF abrir a janela do RNM.',
          es: 'Este paso solo entra despues de la autorizacion concedida, pero no lo dejes pasar si el portal de la PF abre la ventana del RNM.',
          en: 'This step only applies after residence is granted, but do not miss it if the PF portal opens your RNM window.',
        ),
      ),
      GuideActionItem(
        id: 'item_4_3_permanencia',
        title: _t(
          locale,
          pt: 'Transformar residência temporária em permanente',
          es: 'Transformar residencia temporaria en permanente',
          en: 'Convert temporary residence into permanent residence',
        ),
        shortDescription: _t(
          locale,
          pt: 'Esse passo precisa ser feito antes do vencimento da residência temporária.',
          es: 'Este paso tiene que hacerse antes del vencimiento de la residencia temporaria.',
          en: 'This step must happen before temporary residence expires.',
        ),
        fullContent: null,
        type: GuideActionType.external,
        phase: GuidePhase.arrival,
        orderIndex: 18,
        isCompleted: false,
        icon: Icons.event_available_outlined,
        dependencies: <String>['item_4_5_registro_rnm'],
        context: _t(
          locale,
          pt: 'A residência temporária Mercosul tem validade de 2 anos. Antes do vencimento, você precisa pedir a permanente.',
          es: 'La residencia temporaria Mercosur tiene validez de 2 anos. Antes del vencimiento, debes pedir la permanente.',
          en: 'Mercosur temporary residence is valid for 2 years. Before it expires, you must apply for permanent residence.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Se o prazo vencer sem pedido, você pode perder o status e ter que recomeçar todo o processo migratório.',
          es: 'Si el plazo vence sin pedido, puedes perder el estatus y tener que empezar de nuevo todo el proceso.',
          en: 'If the deadline passes without an application, you may lose your status and have to restart the entire process.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Acessar portal PF',
          es: 'Acceder al portal PF',
          en: 'Access PF portal',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.pfPortal.toString(),
        steps: _list(
          locale,
          pt: [
            'Verifique a data de vencimento da sua residência temporária.',
            'Reúna os documentos exigidos (CPF, comprovante de endereço, antecedentes e seus documentos migratórios atualizados).',
            'Agende atendimento na Polícia Federal para solicitar a transformação.',
            'Compareça ao atendimento e acompanhe o andamento pelo portal.',
          ],
          es: [
            'Verifica la fecha de vencimiento de tu residencia temporaria.',
            'Reune los documentos requeridos (CPF, comprobante de domicilio, antecedentes y tus documentos migratorios actualizados).',
            'Agenda turno en la Policia Federal para solicitar la transformacion.',
            'Asiste al turno y sigue el tramite por el portal.',
          ],
          en: [
            'Check the expiration date of your temporary residence.',
            'Gather required documents (CPF, proof of address, criminal record, and your updated migration documents).',
            'Schedule an appointment at the Federal Police to apply for conversion.',
            'Attend the appointment and track progress through the portal.',
          ],
        ),
        requirements: _list(
          locale,
          pt: [
            'CPF',
            'Residência temporária válida ou protocolo',
            'Comprovante de endereço atualizado',
            'Certidão de antecedentes federais',
            'Taxa GRU paga',
          ],
          es: [
            'CPF',
            'Residencia temporaria valida o protocolo',
            'Comprobante de domicilio actualizado',
            'Certificado de antecedentes federales',
            'Tasa GRU pagada',
          ],
          en: [
            'CPF',
            'Valid temporary residence or protocol',
            'Updated proof of address',
            'Federal criminal record certificate',
            'GRU fee paid',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Seu pedido de residência permanente foi protocolado na Polícia Federal.',
          es: 'Tu pedido de residencia permanente fue protocolado en la Policia Federal.',
          en: 'Your permanent residence application has been filed with the Federal Police.',
        ),
        tips: _list(
          locale,
          pt: [
            'Comece a reunir documentos pelo menos 3 meses antes do vencimento.',
            'Acompanhe o protocolo pelo site da PF para não perder prazos.',
          ],
          es: [
            'Empieza a reunir documentos al menos 3 meses antes del vencimiento.',
            'Sigue el protocolo por el sitio de la PF para no perder plazos.',
          ],
          en: [
            'Start gathering documents at least 3 months before expiration.',
            'Track the protocol on the PF website to avoid missing deadlines.',
          ],
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'perm_1',
            title: _t(
              locale,
              pt: 'Data de vencimento da temporária anotada',
              es: 'Fecha de vencimiento de la temporaria anotada',
              en: 'Temporary residence expiration date noted',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'perm_2',
            title: _t(
              locale,
              pt: 'Documentação reunida',
              es: 'Documentacion reunida',
              en: 'Documentation gathered',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'perm_3',
            title: _t(
              locale,
              pt: 'GRU paga',
              es: 'GRU pagada',
              en: 'GRU fee paid',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'perm_4',
            title: _t(
              locale,
              pt: 'Atendimento na PF agendado',
              es: 'Turno en PF agendado',
              en: 'PF appointment scheduled',
            ),
            isCompleted: false,
          ),
        ],
        estimatedEffort: GuideEstimatedEffort.longer,
        estimatedTimeLabel: _t(
          locale,
          pt: '1-3 meses',
          es: '1-3 meses',
          en: '1-3 months',
        ),
      ),
      GuideActionItem(
        id: 'item_4_4_mei',
        title: _t(
          locale,
          pt: 'Abrir MEI para trabalhar como autônomo',
          es: 'Abrir MEI para trabajar como autonomo',
          en: 'Open MEI to work independently',
        ),
        shortDescription: _t(
          locale,
          pt: 'MEI é a forma mais simples de formalizar uma atividade autônoma no Brasil.',
          es: 'MEI es la forma mas simple de formalizar una actividad autonoma en Brasil.',
          en: 'MEI is the simplest way to formalize self-employed work in Brazil.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.work,
        orderIndex: 14,
        isCompleted: false,
        icon: Icons.storefront_outlined,
        dependencies: <String>['item_2_1_cpf'],
        context: _t(
          locale,
          pt: 'MEI é a forma mais simples de formalizar renda autônoma no Brasil.',
          es: 'MEI es la forma mas simple de formalizar ingresos autonomos en Brasil.',
          en: 'MEI is the simplest way to formalize self-employed income in Brazil.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Ele ajuda a emitir nota, abrir caminhos bancários e organizar parte da sua vida fiscal.',
          es: 'Ayuda a facturar, abrir caminos bancarios y organizar parte de tu vida fiscal.',
          en: 'It helps you issue invoices, open banking paths, and organize part of your tax life.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Abrir MEI',
          es: 'Abrir MEI',
          en: 'Open MEI',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget:
            'https://www.gov.br/empresas-e-negocios/pt-br/empreendedor',
        steps: _list(
          locale,
          pt: [
            'Confirme se sua atividade pode ser MEI.',
            'Entre com CPF e conta Gov.br.',
            'Conclua a abertura e guarde seu CNPJ.',
          ],
          es: [
            'Confirma si tu actividad puede ser MEI.',
            'Ingresa con CPF y cuenta Gov.br.',
            'Completa la apertura y guarda tu CNPJ.',
          ],
          en: [
            'Confirm your activity can fit under MEI.',
            'Log in with your CPF and Gov.br account.',
            'Finish the setup and keep your CNPJ.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Seu MEI já está ativo e você sabe emitir nota e pagar a guia mensal.',
          es: 'Tu MEI ya esta activo y sabes emitir factura y pagar la guia mensual.',
          en: 'Your MEI is active and you know how to issue invoices and pay the monthly guide.',
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(
          locale,
          pt: '10 min',
          es: '10 min',
          en: '10 min',
        ),
        communityTips: _list(
          locale,
          pt: [
            '"Abri MEI em 10 minutos pelo site gov.br. Precisei só do CPF e de um endereço de correspondência."',
            '"MEI permite faturar até R\$81.000/ano com impostos fixos baixos — ótimo para freelancer e nômade."',
            '"Se você recebe da Argentina, o MEI permite emitir nota fiscal em reais e regularizar a renda facilmente."',
          ],
          es: [
            '"Abre el MEI en 10 minutos por el sitio gov.br. Solo necesite CPF y una direccion de correspondencia."',
            '"MEI permite facturar hasta R\$81.000/ano con impuestos fijos bajos — genial para freelancer y nomada."',
            '"Si cobras desde Argentina, el MEI permite emitir factura en reales y regularizar los ingresos facilmente."',
          ],
          en: [
            '"I opened my MEI in 10 minutes on gov.br. Just needed CPF and a mailing address."',
            '"MEI allows billing up to R\$81,000/year with low fixed taxes — great for freelancers and nomads."',
            '"If you receive payment from Argentina, MEI lets you issue invoices in BRL and easily regularize income."',
          ],
        ),
      ),
    ];

    if (plan.goal == 'study') {
      items.add(
        GuideActionItem(
          id: 'item_3_5_revalidacao_estudos',
          title: _t(
            locale,
            pt: 'Verificar se seu diploma precisa de revalidação',
            es: 'Ver si tu diploma necesita revalidacion',
            en: 'Check whether your diploma needs revalidation',
          ),
          shortDescription: _t(
            locale,
            pt: 'Se você vai estudar ou usar formação anterior no Brasil, veja quando a revalidação realmente é necessária.',
            es: 'Si vas a estudiar o usar formacion previa en Brasil, revisa cuando la revalidacion realmente es necesaria.',
            en: 'If you will study or use previous education in Brazil, check when revalidation is actually necessary.',
          ),
          fullContent: null,
          type: GuideActionType.external,
          externalUrl: PreparationResourceLinks.diplomaValidationGuide
              .toString(),
          externalLabel: 'gov.br',
          phase: GuidePhase.work,
          orderIndex: 14,
          isCompleted: false,
          icon: Icons.school_outlined,
          dependencies: const <String>['item_2_2_residencia'],
          context: _t(
            locale,
            pt: 'Nem todo diploma estrangeiro precisa de revalidação imediata. Depende da profissão e do uso.',
            es: 'No todo diploma extranjero necesita revalidacion inmediata. Depende de la profesion y del uso.',
            en: 'Not every foreign diploma needs immediate revalidation. It depends on the profession and use.',
          ),
          whyItMatters: _t(
            locale,
            pt: 'Iniciar revalidação sem necessidade real gera custo e tempo perdido. Mas ignorar quando é necessário pode travar sua carreira.',
            es: 'Iniciar revalidacion sin necesidad real genera costo y tiempo perdido. Pero ignorarlo cuando es necesario puede trabar tu carrera.',
            en: 'Starting revalidation without real need wastes time and money. But ignoring it when required can block your career.',
          ),
          primaryActionLabel: _t(
            locale,
            pt: 'Ver regras oficiais',
            es: 'Ver reglas oficiales',
            en: 'See official rules',
          ),
          primaryActionType: GuidePrimaryActionType.external,
          primaryActionTarget: PreparationResourceLinks.diplomaValidationGuide
              .toString(),
          steps: _list(
            locale,
            pt: [
              'Identifique se sua profissão exige diploma revalidado no Brasil.',
              'Consulte a lista de universidades autorizadas para revalidação.',
              'Reúna diploma apostilado, histórico e tradução juramentada.',
              'Faça a inscrição na plataforma Carolina Bori ou direto na universidade.',
            ],
            es: [
              'Identifica si tu profesion exige diploma revalidado en Brasil.',
              'Consulta la lista de universidades autorizadas para revalidacion.',
              'Reune diploma apostillado, historial y traduccion jurada.',
              'Inscribete en la plataforma Carolina Bori o directo en la universidad.',
            ],
            en: [
              'Identify whether your profession requires a revalidated diploma in Brazil.',
              'Check the list of authorized universities for revalidation.',
              'Gather apostilled diploma, transcript, and sworn translation.',
              'Apply through the Carolina Bori platform or directly at the university.',
            ],
          ),
          requirements: _list(
            locale,
            pt: [
              'Diploma apostilado',
              'Histórico acadêmico',
              'Tradução juramentada',
              'CPF e residência',
            ],
            es: [
              'Diploma apostillado',
              'Historial academico',
              'Traduccion jurada',
              'CPF y residencia',
            ],
            en: [
              'Apostilled diploma',
              'Academic transcript',
              'Sworn translation',
              'CPF and residency',
            ],
          ),
          doneCriteria: _t(
            locale,
            pt: 'Você já sabe se precisa revalidar e, se sim, já iniciou o processo.',
            es: 'Ya sabes si necesitas revalidar y, si es asi, ya iniciaste el proceso.',
            en: 'You already know whether you need revalidation and, if so, you have started the process.',
          ),
          estimatedEffort: GuideEstimatedEffort.longer,
          estimatedTimeLabel: _t(
            locale,
            pt: '3-12 meses',
            es: '3-12 meses',
            en: '3-12 months',
          ),
        ),
      );
    }

    final priorityIds = _priorityOrder(plan.goal);
    final priorityRanks = <String, int>{
      for (var index = 0; index < priorityIds.length; index++)
        priorityIds[index]: index,
    };

    final reordered = items.map((item) => item.copyWith()).toList()
      ..sort((a, b) {
        final aRank = priorityRanks[a.id] ?? 999;
        final bRank = priorityRanks[b.id] ?? 999;
        if (aRank != bRank) {
          return aRank.compareTo(bRank);
        }
        return a.orderIndex.compareTo(b.orderIndex);
      });

    for (var index = 0; index < reordered.length; index++) {
      reordered[index] = reordered[index].copyWith(orderIndex: index);
    }

    return reordered
        .map((item) => _contextualizeItem(item, plan, currentLocation, locale))
        .toList(growable: false);
  }

  static List<String> _priorityOrder(String goal) {
    switch (goal) {
      case 'work':
      case 'find_job_br':
        // Sequence: understand rules → base documents and research before travel
        // → optional CPF route before boarding → money/arrival logistics
        // → residency filing on arrival → work card → bank → Pix → income path
        return const [
          'item_0_1_rule_90_days',
          'item_0_2_antecedentes',
          'item_0_3_budget',
          'item_0_5_mercado_trabalho', // research BEFORE leaving
          'item_0_6_saude_entender', // understand health BEFORE leaving
          'item_2_1_cpf', // can be done before travel or on arrival
          'item_1_3_money',
          'item_0_4_flight',
          'item_1_2_housing_temporary',
          'item_2_2_residencia',
          'item_1_1_chip',
          'item_2_3_ctps',
          'item_3_1_conta_bancaria',
          'item_3_3_pix',
          'item_3_4_trabalho',
          'item_3_2_aluguel_fixo',
          'item_4_2_saude', // get SUS card AFTER arriving
        ];
      case 'remote_income':
      case 'remote_work':
      case 'entrepreneur':
        // Sequence: understand rules → research income model → understand health
        // → optional CPF route before boarding → money/logistics
        // → bank/Pix/MEI → residency filing → work definition → rent
        return const [
          'item_0_1_rule_90_days',
          'item_0_2_antecedentes',
          'item_0_3_budget',
          'item_0_5_mercado_trabalho', // research BEFORE leaving
          'item_0_6_saude_entender', // understand health BEFORE leaving
          'item_2_1_cpf',
          'item_1_3_money',
          'item_0_4_flight',
          'item_1_2_housing_temporary',
          'item_3_1_conta_bancaria',
          'item_3_3_pix',
          'item_4_4_mei',
          'item_2_2_residencia',
          'item_1_1_chip',
          'item_3_4_trabalho',
          'item_3_2_aluguel_fixo',
          'item_4_2_saude', // get SUS card AFTER arriving
        ];
      case 'study':
        // Sequence: understand rules → research job market (part-time context)
        // → understand health → optional CPF route before travel
        // → money/arrival logistics → residency → work card → bank → Pix → rent
        return const [
          'item_0_1_rule_90_days',
          'item_0_2_antecedentes',
          'item_0_3_budget',
          'item_0_5_mercado_trabalho', // understand part-time/internship market
          'item_0_6_saude_entender', // understand health BEFORE leaving
          'item_2_1_cpf',
          'item_1_3_money',
          'item_0_4_flight',
          'item_1_2_housing_temporary',
          'item_2_2_residencia',
          'item_1_1_chip',
          'item_2_3_ctps',
          'item_3_1_conta_bancaria',
          'item_3_3_pix',
          'item_3_2_aluguel_fixo',
          'item_4_2_saude', // get SUS card AFTER arriving
        ];
      case 'family_partner':
      case 'quality_of_life':
      case 'beach_life':
      case 'fresh_start':
        // Sequence: understand rules → research local economy → understand health
        // → optional CPF route before travel → money/arrival logistics
        // → residency → bank → Pix → rent → get SUS card
        return const [
          'item_0_1_rule_90_days',
          'item_0_2_antecedentes',
          'item_0_3_budget',
          'item_0_5_mercado_trabalho', // understand local economy before deciding
          'item_0_6_saude_entender', // understand health BEFORE leaving
          'item_2_1_cpf',
          'item_1_3_money',
          'item_0_4_flight',
          'item_1_2_housing_temporary',
          'item_2_2_residencia',
          'item_1_1_chip',
          'item_3_1_conta_bancaria',
          'item_3_3_pix',
          'item_3_2_aluguel_fixo',
          'item_4_2_saude', // get SUS card AFTER arriving
        ];
      default:
        return const [];
    }
  }

  static GuideActionItem _contextualizeItem(
    GuideActionItem item,
    MigrationPlan plan,
    LocationData? currentLocation,
    String locale,
  ) {
    return switch (item.id) {
      'item_2_1_cpf' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Gratuito pela rota consular/Receita. Parceiros presenciais podem cobrar taxa baixa de atendimento.',
          es: 'Gratis por la ruta consular/Receita. Los puntos presenciales asociados pueden cobrar una tasa baja.',
          en: 'Free through the consular/Receita route. In-person partner service points may charge a small fee.',
        ),
        decisionOptions: _cpfDecisionOptions(plan, currentLocation, locale),
        requirements: _list(
          locale,
          pt: [
            'Documento de identidade válido',
            'Dados pessoais completos',
            'Documentos pedidos pela rota escolhida (consulado ou atendimento no Brasil)',
          ],
          es: [
            'Documento de identidad valido',
            'Datos personales completos',
            'Documentos pedidos por la ruta elegida (consulado o atencion en Brasil)',
          ],
          en: [
            'Valid identity document',
            'Complete personal data',
            'Documents required by the chosen route (consulate or service in Brazil)',
          ],
        ),
        estimatedTime: _t(
          locale,
          pt: '10-15 minutos',
          es: '10-15 minutos',
          en: '10-15 minutes',
        ),
        executionModes: const [
          GuideExecutionMode.inPerson,
          GuideExecutionMode.online,
        ],
        locationAwareOptions: _cpfOptions(plan, currentLocation, locale),
        mapLinks: _cpfMapLinks(plan, currentLocation, locale),
        externalOfficialLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'CPF no Brasil',
              es: 'CPF en Brasil',
              en: 'CPF in Brazil',
            ),
            url: PreparationResourceLinks.cpfInBrazil.toString(),
          ),
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'CPF no exterior',
              es: 'CPF en el exterior',
              en: 'CPF abroad',
            ),
            url: PreparationResourceLinks.cpfInExterior.toString(),
          ),
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Rede consular do Brasil na Argentina',
              es: 'Red consular de Brasil en Argentina',
              en: 'Brazilian consular network in Argentina',
            ),
            url:
                'https://www.gov.br/mre/pt-br/assuntos/portal-consular/reparticoes-consulares-do-brasil',
          ),
        ],
      ),
      'item_2_2_residencia' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Pode envolver taxas, foto, cópias e deslocamento. O valor exato depende da etapa e da cidade.',
          es: 'Puede incluir tasas, foto, copias y traslado. El valor exacto depende de la etapa y de la ciudad.',
          en: 'This may involve fees, photos, copies, and transport. The exact amount depends on the stage and city.',
        ),
        requirements: _list(
          locale,
          pt: [
            'Documento de identidade válido',
            'Certificado de antecedentes',
            'Comprovante de endereço',
            'Fotos e comprovantes exigidos',
          ],
          es: [
            'Documento de identidad valido',
            'Certificado de antecedentes',
            'Comprobante de domicilio',
            'Fotos y comprobantes requeridos',
          ],
          en: [
            'Valid identity document',
            'Criminal record certificate',
            'Proof of address',
            'Required photos and proofs',
          ],
        ),
        estimatedTime: _t(
          locale,
          pt: 'Agendamento + atendimento presencial',
          es: 'Turno + atencion presencial',
          en: 'Appointment + in-person visit',
        ),
        executionModes: const [
          GuideExecutionMode.online,
          GuideExecutionMode.inPerson,
        ],
        locationAwareOptions: _residencyOptions(plan, currentLocation, locale),
        mapLinks: _residencyMapLinks(plan, currentLocation, locale),
        externalOfficialLinks: _pfOfficialSupportLinks(
          plan,
          currentLocation,
          locale,
        ),
      ),
      'item_4_5_registro_rnm' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Consulte o portal oficial para saber se há taxa ou exigência complementar na etapa do registro.',
          es: 'Consulta el portal oficial para saber si hay tasa o exigencia complementaria en la etapa del registro.',
          en: 'Check the official portal to see whether there is any fee or extra requirement at the registration stage.',
        ),
        requirements: _list(
          locale,
          pt: [
            'Autorização de residência concedida ou publicada',
            'Documento de identidade válido',
            'CPF e dados de contato atualizados',
          ],
          es: [
            'Autorizacion de residencia concedida o publicada',
            'Documento de identidad valido',
            'CPF y datos de contacto actualizados',
          ],
          en: [
            'Residence authorization granted or published',
            'Valid identity document',
            'CPF and updated contact details',
          ],
        ),
        estimatedTime: _t(
          locale,
          pt: 'Consulta + acompanhamento do portal',
          es: 'Consulta + seguimiento del portal',
          en: 'Portal check + follow-up',
        ),
        executionModes: const [
          GuideExecutionMode.online,
          GuideExecutionMode.inPerson,
        ],
        locationAwareOptions: _registrationOptions(
          plan,
          currentLocation,
          locale,
        ),
        mapLinks: _residencyMapLinks(plan, currentLocation, locale),
        externalOfficialLinks: _pfRegistrationSupportLinks(
          plan,
          currentLocation,
          locale,
        ),
      ),
      'item_3_1_conta_bancaria' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Conta digital costuma ser sem mensalidade. Cartão e crédito dependem de análise.',
          es: 'La cuenta digital suele ser sin mantenimiento. Tarjeta y credito dependen de analisis.',
          en: 'Digital accounts are often free. Cards and credit depend on approval.',
        ),
        requirements: _list(
          locale,
          pt: ['CPF', 'Documento com foto', 'Selfie ou validação no app'],
          es: ['CPF', 'Documento con foto', 'Selfie o validacion en la app'],
          en: ['CPF', 'Photo ID', 'Selfie or in-app verification'],
        ),
        estimatedTime: _t(
          locale,
          pt: '5-20 minutos',
          es: '5-20 minutos',
          en: '5-20 minutes',
        ),
        executionModes: const [
          GuideExecutionMode.online,
          GuideExecutionMode.inPerson,
        ],
        locationAwareOptions: _bankOptions(plan, currentLocation, locale),
        externalOfficialLinks: [
          GuideSupportLink(label: 'Nubank', url: 'https://nubank.com.br'),
          GuideSupportLink(label: 'Inter', url: 'https://inter.co'),
        ],
      ),
      'item_2_3_ctps' => item.copyWith(
        costInfo: _t(locale, pt: 'Gratuito', es: 'Gratis', en: 'Free'),
        requirements: _list(
          locale,
          pt: ['CPF', 'Conta Gov.br', 'Regularização migratória em andamento'],
          es: ['CPF', 'Cuenta Gov.br', 'Regularizacion migratoria en marcha'],
          en: ['CPF', 'Gov.br account', 'Migration regularization in progress'],
        ),
        estimatedTime: _t(
          locale,
          pt: '5-10 minutos',
          es: '5-10 minutos',
          en: '5-10 minutes',
        ),
        executionModes: const [GuideExecutionMode.online],
        locationAwareOptions: [
          GuideLocationAwareOption(
            title: _t(
              locale,
              pt: 'Fazer pelo app oficial',
              es: 'Hacerlo por la app oficial',
              en: 'Do it in the official app',
            ),
            subtitle: _t(
              locale,
              pt: 'Processo 100% digital',
              es: 'Proceso 100% digital',
              en: '100% digital flow',
            ),
            officialUrl:
                'https://www.gov.br/pt-br/servicos/obter-a-carteira-de-trabalho',
            officialLabel: 'gov.br',
          ),
        ],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'gov.br',
            url:
                'https://www.gov.br/pt-br/servicos/obter-a-carteira-de-trabalho',
          ),
        ],
      ),
      'item_1_2_housing_temporary' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Varia bastante por cidade, bairro e tempo de estadia.',
          es: 'Varia mucho segun ciudad, barrio y tiempo de estadia.',
          en: 'Varies a lot by city, neighborhood, and stay length.',
        ),
        requirements: _list(
          locale,
          pt: [
            'Reserva confirmada',
            'Comprovante com endereço',
            'Margem para depósito e imprevistos',
          ],
          es: [
            'Reserva confirmada',
            'Comprobante con direccion',
            'Margen para deposito e imprevistos',
          ],
          en: [
            'Confirmed booking',
            'Proof with address',
            'Buffer for deposit and surprises',
          ],
        ),
        estimatedTime: _t(
          locale,
          pt: '30-60 minutos',
          es: '30-60 minutos',
          en: '30-60 minutes',
        ),
        executionModes: const [GuideExecutionMode.online],
        locationAwareOptions: _housingOptions(plan, locale),
      ),
      'item_0_4_flight' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Preço de voo varia por antecedência, rota e bagagem.',
          es: 'El precio del vuelo varia por anticipacion, ruta y equipaje.',
          en: 'Flight price varies by timing, route, and baggage.',
        ),
        requirements: _list(
          locale,
          pt: [
            'Data definida',
            'Primeira hospedagem',
            'Forma de sair do aeroporto',
          ],
          es: [
            'Fecha definida',
            'Primer alojamiento',
            'Forma de salir del aeropuerto',
          ],
          en: [
            'Date decided',
            'First accommodation',
            'Way to leave the airport',
          ],
        ),
        estimatedTime: _t(
          locale,
          pt: '20-30 minutos',
          es: '20-30 minutos',
          en: '20-30 minutes',
        ),
        executionModes: const [GuideExecutionMode.online],
      ),
      'item_0_1_rule_90_days' => item.copyWith(
        costInfo: _t(locale, pt: 'Gratuito', es: 'Gratis', en: 'Free'),
        executionModes: const [GuideExecutionMode.online],
        externalOfficialLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Acordo de residência AR-BR',
              es: 'Acuerdo de residencia AR-BR',
              en: 'AR-BR residence agreement',
            ),
            url: PreparationResourceLinks.argentinaResidenceAgreement
                .toString(),
          ),
        ],
      ),
      'item_1_3_money' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Varia conforme câmbio e serviço escolhido.',
          es: 'Varia segun cambio y servicio elegido.',
          en: 'Varies by exchange rate and chosen service.',
        ),
        executionModes: const [GuideExecutionMode.online],
      ),
      'item_1_1_chip' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'R\$ 20-50 (chip + crédito inicial)',
          es: 'R\$ 20-50 (chip + credito inicial)',
          en: 'R\$ 20-50 (SIM + initial credit)',
        ),
        executionModes: const [GuideExecutionMode.inPerson],
      ),
      'item_4_1_cnh' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'R\$ 200-500 (taxas DETRAN + exames + tradução)',
          es: 'R\$ 200-500 (tasas DETRAN + examenes + traduccion)',
          en: 'R\$ 200-500 (DETRAN fees + exams + translation)',
        ),
        executionModes: const [
          GuideExecutionMode.inPerson,
          GuideExecutionMode.online,
        ],
        locationAwareOptions: [
          GuideLocationAwareOption(
            title: _t(
              locale,
              pt: 'DETRAN mais próximo',
              es: 'DETRAN mas cercano',
              en: 'Nearest DETRAN',
            ),
            subtitle: _t(
              locale,
              pt: 'Buscar no Google Maps',
              es: 'Buscar en Google Maps',
              en: 'Search on Google Maps',
            ),
            mapUrl: plan.recommendedCity != null
                ? PreparationResourceLinks.buildDetranMapSearch(
                    plan.recommendedCity!,
                  ).toString()
                : null,
          ),
        ],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'DETRAN',
            url: 'https://www.detran.sp.gov.br',
          ),
        ],
      ),
      'item_4_2_saude' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'SUS é gratuito. Plano privado varia.',
          es: 'SUS es gratis. Plan privado varia.',
          en: 'SUS is free. Private plan varies.',
        ),
        executionModes: const [
          GuideExecutionMode.inPerson,
          GuideExecutionMode.online,
        ],
        locationAwareOptions: [
          GuideLocationAwareOption(
            title: _t(
              locale,
              pt: 'UPA mais próxima',
              es: 'UPA mas cercana',
              en: 'Nearest UPA',
            ),
            subtitle: _t(
              locale,
              pt: 'Buscar no Google Maps',
              es: 'Buscar en Google Maps',
              en: 'Search on Google Maps',
            ),
            mapUrl: plan.recommendedCity != null
                ? PreparationResourceLinks.buildUpaMapSearch(
                    plan.recommendedCity!,
                  ).toString()
                : null,
          ),
        ],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'SUS',
            url: PreparationResourceLinks.susPortal.toString(),
          ),
          GuideSupportLink(
            label: 'ANS',
            url: PreparationResourceLinks.ansPortal.toString(),
          ),
        ],
      ),
      'item_4_3_permanencia' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Taxa GRU (valor atualizado no site da PF)',
          es: 'Tasa GRU (valor actualizado en el sitio de la PF)',
          en: 'GRU fee (current amount on the PF website)',
        ),
        executionModes: const [
          GuideExecutionMode.inPerson,
          GuideExecutionMode.online,
        ],
        locationAwareOptions: _registrationOptions(
          plan,
          currentLocation,
          locale,
        ),
        mapLinks: _residencyMapLinks(plan, currentLocation, locale),
        externalOfficialLinks: _pfRegistrationSupportLinks(
          plan,
          currentLocation,
          locale,
        ),
      ),
      'item_0_2_antecedentes' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Gratuito ou taxa baixa conforme o canal.',
          es: 'Gratis o tasa baja segun el canal.',
          en: 'Free or a small fee depending on channel.',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget:
            'https://www.argentina.gob.ar/justicia/reincidencia/antecedentespenales',
        executionModes: const [GuideExecutionMode.online],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'Registro Nacional de Reincidencia',
            url:
                'https://www.argentina.gob.ar/justicia/reincidencia/antecedentespenales',
          ),
        ],
      ),
      'item_3_3_pix' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Normalmente gratuito para pessoa física.',
          es: 'Normalmente gratis para personas fisicas.',
          en: 'Usually free for individuals.',
        ),
        requirements: _list(
          locale,
          pt: [
            'Conta bancária ativa',
            'App do banco',
            'CPF ou outra chave Pix',
          ],
          es: ['Cuenta activa', 'App del banco', 'CPF u otra clave Pix'],
          en: ['Active bank account', 'Bank app', 'CPF or another Pix key'],
        ),
        estimatedTime: _t(
          locale,
          pt: '5 minutos',
          es: '5 minutos',
          en: '5 minutes',
        ),
        executionModes: const [GuideExecutionMode.online],
      ),
      'item_3_4_trabalho' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Depende do caminho escolhido.',
          es: 'Depende del camino elegido.',
          en: 'Depends on the chosen path.',
        ),
        executionModes: const [
          GuideExecutionMode.online,
          GuideExecutionMode.inPerson,
        ],
        externalOfficialLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Portal Emprego Brasil',
              es: 'Portal Empleo Brasil',
              en: 'Brazil Jobs Portal',
            ),
            url: PreparationResourceLinks.officialJobsPortal.toString(),
          ),
        ],
      ),
      'item_4_4_mei' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Abertura gratuita. Guia mensal ~R\$ 70.',
          es: 'Apertura gratis. Guia mensual ~R\$ 70.',
          en: 'Free to open. Monthly fee ~R\$ 70.',
        ),
        executionModes: const [GuideExecutionMode.online],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'Portal do Empreendedor',
            url: 'https://www.gov.br/empresas-e-negocios/pt-br/empreendedor',
          ),
        ],
      ),
      'item_0_5_mercado_trabalho' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Gratuito — apenas tempo de pesquisa.',
          es: 'Gratis — solo tiempo de investigacion.',
          en: 'Free — research time only.',
        ),
        executionModes: const [GuideExecutionMode.online],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'LinkedIn Brasil',
            url: 'https://www.linkedin.com/jobs',
          ),
          GuideSupportLink(label: 'Catho', url: 'https://www.catho.com.br'),
          GuideSupportLink(
            label: 'VAGAS.com',
            url: PreparationResourceLinks.officialJobsPortal.toString(),
          ),
        ],
      ),
      'item_0_6_saude_entender' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Gratuito — pesquisa informacional.',
          es: 'Gratis — investigacion informacional.',
          en: 'Free — informational research.',
        ),
        executionModes: const [GuideExecutionMode.online],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'SUS',
            url: PreparationResourceLinks.susPortal.toString(),
          ),
          GuideSupportLink(
            label: 'ANS',
            url: PreparationResourceLinks.ansPortal.toString(),
          ),
        ],
      ),
      _ => item,
    };
  }

  static String _locale([String? localeCode]) {
    final code = (localeCode ?? PlatformDispatcher.instance.locale.languageCode)
        .toLowerCase();
    if (code == 'pt' || code == 'es') {
      return code;
    }
    return 'en';
  }

  static String _t(
    String locale, {
    required String pt,
    required String es,
    required String en,
  }) {
    return switch (locale) {
      'pt' => pt,
      'es' => es,
      _ => en,
    };
  }

  static List<String> _list(
    String locale, {
    required List<String> pt,
    required List<String> es,
    required List<String> en,
  }) {
    return switch (locale) {
      'pt' => pt,
      'es' => es,
      _ => en,
    };
  }

  static List<GuideLocationAwareOption> _cpfOptions(
    MigrationPlan plan,
    LocationData? currentLocation,
    String locale,
  ) {
    final city = _contextCity(plan, currentLocation);
    final inDestination = _isInDestinationCountry(currentLocation, plan);
    final nearestConsularPost = _nearestArgentinaConsularPost(currentLocation);
    final consularDistance =
        nearestConsularPost == null || currentLocation == null
        ? null
        : const Distance()
              .as(
                LengthUnit.Kilometer,
                LatLng(currentLocation.latitude, currentLocation.longitude),
                LatLng(
                  nearestConsularPost.latitude,
                  nearestConsularPost.longitude,
                ),
              )
              .round();
    return [
      GuideLocationAwareOption(
        title: _t(
          locale,
          pt: 'Fazer na Argentina',
          es: 'Hacerlo en Argentina',
          en: 'Do it in Argentina',
        ),
        subtitle: _t(
          locale,
          pt: nearestConsularPost == null
              ? 'Use a rota oficial de CPF no exterior via consulado ou embaixada do Brasil'
              : _consularCpfSubtitlePt(
                  nearestConsularPost.city,
                  consularDistance,
                ),
          es: nearestConsularPost == null
              ? 'Usa la ruta oficial de CPF en el exterior por consulado o embajada de Brasil'
              : _consularCpfSubtitleEs(
                  nearestConsularPost.city,
                  consularDistance,
                ),
          en: nearestConsularPost == null
              ? 'Use the official CPF abroad route through a Brazilian consulate or embassy'
              : _consularCpfSubtitleEn(
                  nearestConsularPost.city,
                  consularDistance,
                ),
        ),
        address: nearestConsularPost?.city,
        distanceKm: consularDistance,
        officialUrl: PreparationResourceLinks.cpfInExterior.toString(),
        officialLabel: 'gov.br',
      ),
      if (nearestConsularPost != null)
        GuideLocationAwareOption(
          title: _t(
            locale,
            pt: 'Posto consular mais próximo',
            es: 'Puesto consular mas cercano',
            en: 'Nearest consular post',
          ),
          subtitle: _t(
            locale,
            pt: 'Consulte horários, e-consular e exigências locais do posto de ${nearestConsularPost.city}',
            es: 'Consulta horarios, e-consular y exigencias locales del puesto de ${nearestConsularPost.city}',
            en: 'Check hours, e-consular flow, and local requirements for the ${nearestConsularPost.city} post',
          ),
          address: nearestConsularPost.city,
          distanceKm: consularDistance,
          officialUrl: nearestConsularPost.officialUrl,
          officialLabel: 'Itamaraty',
        ),
      GuideLocationAwareOption(
        title: _t(
          locale,
          pt: inDestination
              ? 'Atendimento presencial próximo'
              : 'Fazer no Brasil',
          es: inDestination
              ? 'Atencion presencial cercana'
              : 'Hacerlo en Brasil',
          en: inDestination ? 'Nearby in-person option' : 'Do it in Brazil',
        ),
        subtitle: _t(
          locale,
          pt: inDestination
              ? 'Buscar Receita Federal ou parceiro autorizado'
              : 'Se deixar para o Brasil, use $city como referência para planejar esse passo',
          es: inDestination
              ? 'Buscar Receita Federal o punto autorizado'
              : 'Si lo dejas para Brasil, usa $city como referencia para planear este paso',
          en: inDestination
              ? 'Search Receita Federal or an authorized point'
              : 'If you leave it for Brazil, use $city as the planning reference for this step',
        ),
        address: city,
        distanceKm: inDestination ? _distanceKm(plan, currentLocation) : null,
        mapUrl: _mapSearchUrl('Receita Federal $city'),
        officialUrl: PreparationResourceLinks.cpfInBrazil.toString(),
        officialLabel: 'gov.br',
      ),
    ];
  }

  static List<GuideDecisionOption> _cpfDecisionOptions(
    MigrationPlan plan,
    LocationData? currentLocation,
    String locale,
  ) {
    final nearestConsularPost = _nearestArgentinaConsularPost(currentLocation);
    final consularDistance =
        nearestConsularPost == null || currentLocation == null
        ? null
        : const Distance()
              .as(
                LengthUnit.Kilometer,
                LatLng(currentLocation.latitude, currentLocation.longitude),
                LatLng(
                  nearestConsularPost.latitude,
                  nearestConsularPost.longitude,
                ),
              )
              .round();
    final consularRecommended =
        currentLocation != null &&
        _isInArgentina(currentLocation) &&
        consularDistance != null &&
        consularDistance <= 200;

    return [
      GuideDecisionOption(
        title: _t(
          locale,
          pt: 'Fazer ainda na Argentina',
          es: 'Hacerlo todavia en Argentina',
          en: 'Do it while still in Argentina',
        ),
        description: _t(
          locale,
          pt: nearestConsularPost == null
              ? 'Boa rota se você já tem acesso fácil a um posto consular brasileiro e quer chegar ao Brasil com banco e cadastros menos travados.'
              : 'Boa rota se você consegue chegar ao posto de ${nearestConsularPost.city} sem transformar isso em uma viagem cara ou lenta.',
          es: nearestConsularPost == null
              ? 'Buena ruta si ya tienes acceso facil a un puesto consular brasileño y quieres llegar a Brasil con banco y registros menos trabados.'
              : 'Buena ruta si puedes llegar al puesto de ${nearestConsularPost.city} sin convertirlo en un viaje caro o lento.',
          en: nearestConsularPost == null
              ? 'Good route if you already have easy access to a Brazilian consular post and want to reach Brazil with banking and registrations less blocked.'
              : 'Good route if you can reach the ${nearestConsularPost.city} consular post without turning this into an expensive or slow trip.',
        ),
        helperLabel: nearestConsularPost == null
            ? null
            : _t(
                locale,
                pt: 'Posto mais próximo: ${nearestConsularPost.city}',
                es: 'Puesto mas cercano: ${nearestConsularPost.city}',
                en: 'Nearest post: ${nearestConsularPost.city}',
              ),
        helperUrl: nearestConsularPost?.officialUrl,
        pros: _list(
          locale,
          pt: [
            'Você chega com o CPF já resolvido para banco, Pix e parte dos cadastros.',
            'Relatos práticos costumam descrever o atendimento consular como rápido quando a vaga já está marcada.',
          ],
          es: [
            'Llegas con el CPF ya resuelto para banco, Pix y parte de los registros.',
            'Los relatos practicos suelen describir la atencion consular como rapida cuando el turno ya esta marcado.',
          ],
          en: [
            'You arrive with CPF already sorted for banking, Pix, and part of your registrations.',
            'Practical reports often describe the consular visit as quick once the appointment is booked.',
          ],
        ),
        cons: _list(
          locale,
          pt: [
            consularDistance == null
                ? 'Só vale a pena se você tiver acesso real a um posto consular brasileiro.'
                : consularDistance > 200
                ? 'Do seu ponto atual, o posto mais próximo fica longe; isso pode virar uma viagem só para o CPF.'
                : 'Ainda depende de agenda, deslocamento e regra operacional do posto consular.',
            'Nem toda pessoa vai preferir investir esse tempo antes de resolver voo, moradia e documentos da residência.',
          ],
          es: [
            consularDistance == null
                ? 'Solo vale la pena si tienes acceso real a un puesto consular brasileño.'
                : consularDistance > 200
                ? 'Desde tu ubicacion actual, el puesto mas cercano queda lejos; esto puede convertirse en un viaje solo por el CPF.'
                : 'Igual depende del turno, del desplazamiento y de la operacion del puesto consular.',
            'No toda persona va a querer gastar ese tiempo antes de resolver vuelo, vivienda y documentos de residencia.',
          ],
          en: [
            consularDistance == null
                ? 'It is only worth it if you have real access to a Brazilian consular post.'
                : consularDistance > 200
                ? 'From your current location, the nearest post is far away; this can turn into a dedicated trip just for CPF.'
                : 'It still depends on booking, travel, and the post’s own operating rules.',
            'Not everyone will want to spend that time before solving flights, housing, and residency documents.',
          ],
        ),
        recommended: consularRecommended,
      ),
      GuideDecisionOption(
        title: _t(
          locale,
          pt: 'Fazer nos primeiros dias no Brasil',
          es: 'Hacerlo en los primeros dias en Brasil',
          en: 'Do it in your first days in Brazil',
        ),
        description: _t(
          locale,
          pt: 'Boa rota para quem quer concentrar energia na viagem e resolver o CPF já com o endereço inicial e a chegada acontecendo.',
          es: 'Buena ruta para quien quiere concentrar energia en el viaje y resolver el CPF ya con la direccion inicial y la llegada en marcha.',
          en: 'A good route if you want to focus on the move itself and handle CPF once your initial address and arrival are already in motion.',
        ),
        helperLabel: nearestConsularPost == null
            ? null
            : _t(
                locale,
                pt: consularDistance != null && consularDistance > 200
                    ? 'Seu posto consular de referência fica longe'
                    : 'Boa opção se você prefere não depender de agenda consular',
                es: consularDistance != null && consularDistance > 200
                    ? 'Tu puesto consular de referencia queda lejos'
                    : 'Buena opcion si prefieres no depender de un turno consular',
                en: consularDistance != null && consularDistance > 200
                    ? 'Your reference consular post is far away'
                    : 'A good option if you prefer not to depend on a consular appointment',
              ),
        pros: _list(
          locale,
          pt: [
            'Você evita uma viagem extra na Argentina se não mora perto de um consulado.',
            'O canal oficial no Brasil aceita estrangeiros por web, e-mail e pontos parceiros; em unidades conveniadas a espera costuma ser curta.',
          ],
          es: [
            'Evitas un viaje extra en Argentina si no vives cerca de un consulado.',
            'El canal oficial en Brasil acepta extranjeros por web, e-mail y puntos asociados; en unidades conveniadas la espera suele ser corta.',
          ],
          en: [
            'You avoid an extra trip in Argentina if you do not live near a consulate.',
            'The official Brazil route accepts foreigners through web, email, and partner points; wait times at partner units are often short.',
          ],
        ),
        cons: _list(
          locale,
          pt: [
            'Você chega ao Brasil ainda sem o CPF, então banco, Pix e parte dos cadastros ficam para depois da chegada.',
            'Relatos práticos mostram que a experiência no Brasil pode variar mais entre canais e às vezes exige acompanhamento posterior.',
          ],
          es: [
            'Llegas a Brasil todavia sin CPF, entonces banco, Pix y parte de los registros quedan para despues de llegar.',
            'Los relatos practicos muestran que la experiencia en Brasil puede variar mas entre canales y a veces exige seguimiento posterior.',
          ],
          en: [
            'You arrive in Brazil still without CPF, so banking, Pix, and part of your registrations stay blocked until after arrival.',
            'Practical reports show that the Brazil route can vary more across channels and sometimes requires later follow-up.',
          ],
        ),
        recommended: !consularRecommended,
      ),
    ];
  }

  static List<GuideSupportLink> _cpfMapLinks(
    MigrationPlan plan,
    LocationData? currentLocation,
    String locale,
  ) {
    final city = _contextCity(plan, currentLocation);
    return [
      GuideSupportLink(
        label: _t(locale, pt: 'Abrir mapa', es: 'Abrir mapa', en: 'Open map'),
        url: _mapSearchUrl('Receita Federal $city'),
      ),
    ];
  }

  static List<GuideLocationAwareOption> _residencyOptions(
    MigrationPlan plan,
    LocationData? currentLocation,
    String locale,
  ) {
    final city = _contextCity(plan, currentLocation);
    final inDestination = _isInDestinationCountry(currentLocation, plan);
    return [
      GuideLocationAwareOption(
        title: _t(
          locale,
          pt: inDestination
              ? 'Unidade da Polícia Federal'
              : 'Onde resolver ao chegar',
          es: inDestination
              ? 'Unidad de Policia Federal'
              : 'Donde resolverlo al llegar',
          en: inDestination
              ? 'Federal Police unit'
              : 'Where to handle it when you arrive',
        ),
        subtitle: _t(
          locale,
          pt: inDestination
              ? 'Busque a unidade que atende imigração'
              : 'Use $city como referência e chegue com a pasta pronta; o agendamento antecipado é recomendação, não regra geral',
          es: inDestination
              ? 'Busca la unidad que atiende inmigracion'
              : 'Usa $city como referencia y llega con la carpeta lista; agendar antes es recomendacion, no regla general',
          en: inDestination
              ? 'Search for the unit that handles immigration'
              : 'Use $city as your planning reference and arrive with the folder ready; booking early is a recommendation, not a universal rule',
        ),
        address: city,
        distanceKm: inDestination ? _distanceKm(plan, currentLocation) : null,
        mapUrl: _mapSearchUrl('Polícia Federal imigração $city'),
        officialUrl: PreparationResourceLinks.pfScheduling.toString(),
        officialLabel: 'PF',
      ),
      GuideLocationAwareOption(
        title: _t(
          locale,
          pt: 'Ver rota oficial Mercosul',
          es: 'Ver ruta oficial Mercosur',
          en: 'See official Mercosur route',
        ),
        subtitle: _t(
          locale,
          pt: 'Consulte a exigência oficial antes de montar a pasta final',
          es: 'Consulta la exigencia oficial antes de armar la carpeta final',
          en: 'Check the official requirements before finalizing your folder',
        ),
        officialUrl: PreparationResourceLinks.argentinaResidenceAgreement
            .toString(),
        officialLabel: 'gov.br',
      ),
    ];
  }

  static List<GuideLocationAwareOption> _registrationOptions(
    MigrationPlan plan,
    LocationData? currentLocation,
    String locale,
  ) {
    final city = _contextCity(plan, currentLocation);
    final inDestination = _isInDestinationCountry(currentLocation, plan);
    return [
      GuideLocationAwareOption(
        title: _t(
          locale,
          pt: 'Ver passo oficial do RNM / CRNM',
          es: 'Ver paso oficial del RNM / CRNM',
          en: 'See the official RNM / CRNM step',
        ),
        subtitle: _t(
          locale,
          pt: 'Use isso quando a autorização já tiver saído ou sido publicada',
          es: 'Usa esto cuando la autorizacion ya haya salido o sido publicada',
          en: 'Use this once residence has already been granted or published',
        ),
        officialUrl: PreparationResourceLinks.rnMRegistrationGuide.toString(),
        officialLabel: 'PF',
      ),
      GuideLocationAwareOption(
        title: _t(
          locale,
          pt: inDestination
              ? 'Unidade migratória da PF'
              : 'Unidade migratória de referência',
          es: inDestination
              ? 'Unidad migratoria de la PF'
              : 'Unidad migratoria de referencia',
          en: inDestination ? 'PF migration unit' : 'Reference migration unit',
        ),
        subtitle: _t(
          locale,
          pt: 'Acompanhe a unidade responsável por $city',
          es: 'Sigue la unidad responsable por $city',
          en: 'Track the unit responsible for $city',
        ),
        address: city,
        distanceKm: inDestination ? _distanceKm(plan, currentLocation) : null,
        mapUrl: _mapSearchUrl('Polícia Federal imigração $city'),
      ),
    ];
  }

  static List<GuideSupportLink> _residencyMapLinks(
    MigrationPlan plan,
    LocationData? currentLocation,
    String locale,
  ) {
    final city = _contextCity(plan, currentLocation);
    return [
      GuideSupportLink(
        label: _t(locale, pt: 'Abrir mapa', es: 'Abrir mapa', en: 'Open map'),
        url: _mapSearchUrl('Polícia Federal imigração $city'),
      ),
    ];
  }

  static List<GuideSupportLink> _pfOfficialSupportLinks(
    MigrationPlan plan,
    LocationData? currentLocation,
    String locale,
  ) {
    final city = plan.recommendedCity ?? plan.preferredCity;
    final contact = city == null
        ? null
        : PreparationResourceLinks.resolvePfUnitContact(city);

    return [
      GuideSupportLink(
        label: _t(
          locale,
          pt: 'Residência Mercosul',
          es: 'Residencia Mercosur',
          en: 'Mercosur residence',
        ),
        url: PreparationResourceLinks.argentinaResidenceAgreement.toString(),
      ),
      GuideSupportLink(
        label: _t(
          locale,
          pt: 'Agenda oficial da PF',
          es: 'Agenda oficial de la PF',
          en: 'Official PF booking',
        ),
        url: PreparationResourceLinks.pfScheduling.toString(),
      ),
      if (city != null && contact != null)
        GuideSupportLink(
          label: _t(
            locale,
            pt: 'Unidade responsável em ${city.name}',
            es: 'Unidad responsable en ${city.name}',
            en: 'Responsible unit in ${city.name}',
          ),
          url: contact.buildMailtoUri(city).toString(),
        )
      else
        GuideSupportLink(
          label: _t(
            locale,
            pt: 'Lista oficial de unidades da PF',
            es: 'Lista oficial de unidades de la PF',
            en: 'Official PF unit directory',
          ),
          url: PreparationResourceLinks.pfUnitDirectory.toString(),
        ),
    ];
  }

  static List<GuideSupportLink> _pfRegistrationSupportLinks(
    MigrationPlan plan,
    LocationData? currentLocation,
    String locale,
  ) {
    final city = plan.recommendedCity ?? plan.preferredCity;
    final contact = city == null
        ? null
        : PreparationResourceLinks.resolvePfUnitContact(city);

    return [
      GuideSupportLink(
        label: _t(
          locale,
          pt: 'Registro RNM / CRNM',
          es: 'Registro RNM / CRNM',
          en: 'RNM / CRNM registration',
        ),
        url: PreparationResourceLinks.rnMRegistrationGuide.toString(),
      ),
      GuideSupportLink(
        label: _t(
          locale,
          pt: 'Portal de imigração da PF',
          es: 'Portal de inmigracion de la PF',
          en: 'PF immigration portal',
        ),
        url: PreparationResourceLinks.pfPortal.toString(),
      ),
      if (city != null && contact != null)
        GuideSupportLink(
          label: _t(
            locale,
            pt: 'Unidade responsável em ${city.name}',
            es: 'Unidad responsable en ${city.name}',
            en: 'Responsible unit in ${city.name}',
          ),
          url: contact.buildMailtoUri(city).toString(),
        )
      else
        GuideSupportLink(
          label: _t(
            locale,
            pt: 'Lista oficial de unidades da PF',
            es: 'Lista oficial de unidades de la PF',
            en: 'Official PF unit directory',
          ),
          url: PreparationResourceLinks.pfUnitDirectory.toString(),
        ),
    ];
  }

  static List<GuideLocationAwareOption> _bankOptions(
    MigrationPlan plan,
    LocationData? currentLocation,
    String locale,
  ) {
    final city = _contextCity(plan, currentLocation);
    final inDestination = _isInDestinationCountry(currentLocation, plan);
    return [
      GuideLocationAwareOption(
        title: _t(
          locale,
          pt: 'Abrir conta pelo celular',
          es: 'Abrir cuenta por el celular',
          en: 'Open account on your phone',
        ),
        subtitle: _t(
          locale,
          pt: 'Mais rápido para começar agora',
          es: 'Lo mas rapido para empezar ahora',
          en: 'Fastest path to start now',
        ),
        officialUrl: 'https://nubank.com.br',
        officialLabel: 'Nubank',
      ),
      GuideLocationAwareOption(
        title: _t(
          locale,
          pt: inDestination
              ? 'Buscar agência física'
              : 'Onde buscar ajuda presencial',
          es: inDestination
              ? 'Buscar sucursal fisica'
              : 'Donde buscar ayuda presencial',
          en: inDestination
              ? 'Find a physical branch'
              : 'Where to get in-person help',
        ),
        subtitle: _t(
          locale,
          pt: 'Se você preferir atendimento presencial',
          es: 'Si prefieres atencion presencial',
          en: 'If you prefer in-person support',
        ),
        address: city,
        distanceKm: inDestination ? _distanceKm(plan, currentLocation) : null,
        mapUrl: _mapSearchUrl('banco $city'),
      ),
    ];
  }

  static List<GuideLocationAwareOption> _housingOptions(
    MigrationPlan plan,
    String locale,
  ) {
    final city = plan.recommendedCity == null
        ? _t(
            locale,
            pt: 'sua cidade de destino',
            es: 'tu ciudad de destino',
            en: 'your destination city',
          )
        : '${plan.recommendedCity!.name}, ${plan.recommendedCity!.stateName}';
    return [
      GuideLocationAwareOption(
        title: _t(
          locale,
          pt: 'Buscar moradia temporária',
          es: 'Buscar vivienda temporal',
          en: 'Search temporary housing',
        ),
        subtitle: _t(
          locale,
          pt: 'Use a busca da cidade escolhida para comparar opções reais',
          es: 'Usa la busqueda de la ciudad elegida para comparar opciones reales',
          en: 'Use the selected city search to compare real options',
        ),
        address: city,
        mapUrl: _mapSearchUrl('Airbnb $city'),
      ),
    ];
  }

  static String _contextCity(
    MigrationPlan plan,
    LocationData? currentLocation,
  ) {
    if (_isInDestinationCountry(currentLocation, plan)) {
      final location = currentLocation!;
      final region = location.stateName.trim();
      final city = location.cityName.trim().isNotEmpty
          ? location.cityName.trim()
          : location.stateName.trim();
      return region.isNotEmpty ? '$city, $region' : city;
    }
    final destinationCity = plan.recommendedCity;
    if (destinationCity != null) {
      return '${destinationCity.name}, ${destinationCity.stateName}';
    }
    return _t(
      _locale(),
      pt: 'cidade de destino',
      es: 'ciudad de destino',
      en: 'destination city',
    );
  }

  static int? _distanceKm(MigrationPlan plan, LocationData? currentLocation) {
    final destinationCity = plan.recommendedCity;
    if (!_isInDestinationCountry(currentLocation, plan) ||
        currentLocation == null ||
        destinationCity == null) {
      return null;
    }
    final distanceKm = const Distance().as(
      LengthUnit.Kilometer,
      LatLng(currentLocation.latitude, currentLocation.longitude),
      LatLng(destinationCity.latitude, destinationCity.longitude),
    );
    return distanceKm.round();
  }

  static _BrazilConsularPost? _nearestArgentinaConsularPost(
    LocationData? currentLocation,
  ) {
    if (currentLocation == null || !_isInArgentina(currentLocation)) {
      return null;
    }
    _BrazilConsularPost? best;
    var bestDistance = double.infinity;
    for (final post in _argentinaConsularPosts) {
      final distanceKm = const Distance().as(
        LengthUnit.Kilometer,
        LatLng(currentLocation.latitude, currentLocation.longitude),
        LatLng(post.latitude, post.longitude),
      );
      if (distanceKm < bestDistance) {
        best = post;
        bestDistance = distanceKm;
      }
    }
    return best;
  }

  static bool _isInArgentina(LocationData? currentLocation) {
    if (currentLocation == null) {
      return false;
    }
    final code = currentLocation.countryCode.trim().toUpperCase();
    final name = currentLocation.countryName.trim().toUpperCase();
    return code == 'AR' || name == 'ARGENTINA';
  }

  static String _consularCpfSubtitlePt(String city, int? distanceKm) {
    if (distanceKm == null) {
      return 'O posto de $city é a referência oficial mais próxima para tentar resolver isso antes da viagem';
    }
    if (distanceKm <= 40) {
      return 'Você está perto de $city: essa costuma ser a rota mais limpa para chegar ao Brasil com o CPF já resolvido';
    }
    if (distanceKm <= 200) {
      return 'O posto de $city fica a ~$distanceKm km: é viável se você já consegue encaixar essa ida antes da viagem';
    }
    return 'O posto de $city fica a ~$distanceKm km: só compensa se você já vai passar por lá, para não transformar o CPF em uma viagem paralela';
  }

  static String _consularCpfSubtitleEs(String city, int? distanceKm) {
    if (distanceKm == null) {
      return 'El puesto de $city es la referencia oficial mas cercana para intentar resolver esto antes del viaje';
    }
    if (distanceKm <= 40) {
      return 'Estas cerca de $city: esta suele ser la ruta mas limpia para llegar a Brasil con el CPF ya resuelto';
    }
    if (distanceKm <= 200) {
      return 'El puesto de $city queda a ~$distanceKm km: es viable si ya puedes encajar esa ida antes del viaje';
    }
    return 'El puesto de $city queda a ~$distanceKm km: solo conviene si ya vas a pasar por ahi, para no convertir el CPF en un viaje paralelo';
  }

  static String _consularCpfSubtitleEn(String city, int? distanceKm) {
    if (distanceKm == null) {
      return '$city is the closest official post if you want to try solving this before the trip';
    }
    if (distanceKm <= 40) {
      return 'You are close to $city: this is usually the cleanest route if you want to arrive in Brazil with CPF already sorted';
    }
    if (distanceKm <= 200) {
      return 'The $city post is about $distanceKm km away: viable if you can fit that visit in before departure';
    }
    return 'The $city post is about $distanceKm km away: only worth it if you will already pass through there, so CPF does not become a side trip';
  }

  static String _mapSearchUrl(String query) {
    return 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';
  }

  static bool _isInDestinationCountry(
    LocationData? currentLocation,
    MigrationPlan plan,
  ) {
    if (currentLocation == null) {
      return false;
    }
    final destination = plan.destinationCountry.trim().toUpperCase();
    final currentCode = currentLocation.countryCode.trim().toUpperCase();
    final currentName = currentLocation.countryName.trim().toUpperCase();
    if (destination == 'BRASIL' ||
        destination == 'BRAZIL' ||
        destination == 'BR') {
      return currentCode == 'BR' ||
          currentName == 'BRASIL' ||
          currentName == 'BRAZIL';
    }
    return false;
  }
}

class _BrazilConsularPost {
  const _BrazilConsularPost({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.officialUrl,
  });

  final String city;
  final double latitude;
  final double longitude;
  final String officialUrl;
}

String _marketExchangeTip(
  String locale, {
  required CopilotExchangeRates? exchangeRates,
}) {
  if (exchangeRates == null) {
    return ArgentinaBrazilGuideDataSource._t(
      locale,
      pt: 'Use a cotação oficial do dia para converter salário em R\$ para ARS antes de comparar propostas.',
      es: 'Usa el tipo de cambio oficial del dia para convertir salario en R\$ a ARS antes de comparar propuestas.',
      en: 'Use the official daily exchange rate to convert salary in BRL to ARS before comparing offers.',
    );
  }

  final usdToBrl = exchangeRates.usdToBrl.toStringAsFixed(2);
  final usdToArs = exchangeRates.usdToArs.toStringAsFixed(0);
  final fetchedAt = _formatFetchedAt(exchangeRates.fetchedAt);

  return ArgentinaBrazilGuideDataSource._t(
    locale,
    pt: 'Hoje 1 USD = R\$$usdToBrl e ~ARS $usdToArs (cotação de $fetchedAt). Para converter: salário em R\$ ÷ $usdToBrl × dólar em ARS.',
    es: 'Hoy 1 USD = R\$$usdToBrl y ~ARS $usdToArs (cotizacion de $fetchedAt). Para convertir: salario en R\$ ÷ $usdToBrl × dolar en ARS.',
    en: 'Today 1 USD = R\$$usdToBrl and ~ARS $usdToArs (rate from $fetchedAt). To convert: salary in BRL ÷ $usdToBrl × USD in ARS.',
  );
}

String _formatFetchedAt(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) {
    return raw;
  }
  final year = parsed.year.toString().padLeft(4, '0');
  final month = parsed.month.toString().padLeft(2, '0');
  final day = parsed.day.toString().padLeft(2, '0');
  return '$day/$month/$year';
}
