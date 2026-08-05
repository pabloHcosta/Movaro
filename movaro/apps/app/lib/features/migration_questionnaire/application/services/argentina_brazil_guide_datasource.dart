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
          pt: 'Entenda sua entrada e a regularização',
          es: 'Entiende tu entrada y la regularización',
          en: 'Understand entry and regularization',
        ),
        shortDescription: _t(
          locale,
          pt: 'A estada como visitante e o pedido de residência são assuntos diferentes. Veja qual rota vale para você.',
          es: 'La estadía como visitante y la residencia son trámites distintos. Mira qué ruta se aplica a tu caso.',
          en: 'Visitor stay and residence are separate matters. Check which route applies to you.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.preparation,
        orderIndex: 0,
        isCompleted: false,
        icon: Icons.schedule_rounded,
        context: _t(
          locale,
          pt: 'Argentinos elegíveis podem solicitar residência permanente pelo acordo bilateral Brasil–Argentina. O prazo de visitante não deve ser tratado como um prazo universal para pedir residência.',
          es: 'Las personas argentinas elegibles pueden solicitar residencia permanente por el acuerdo bilateral Brasil–Argentina. El plazo de visitante no debe tratarse como un plazo universal para pedir residencia.',
          en: 'Eligible Argentine nationals may request permanent residence under the Brazil–Argentina agreement. The visitor period is not a universal residence-application deadline.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Separar entrada, permanência como visitante e residência evita decisões erradas e urgência artificial.',
          es: 'Separar entrada, permanencia como visitante y residencia evita decisiones equivocadas y urgencia artificial.',
          en: 'Separating entry, visitor status, and residence prevents wrong decisions and false urgency.',
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
            'Confirme na fonte oficial quais documentos serão aceitos na sua forma de entrada.',
            'Veja se você é elegível ao acordo bilateral Brasil–Argentina, que prevê residência permanente.',
            'Organize os documentos cedo, mas confirme os requisitos atuais antes de protocolar.',
          ],
          es: [
            'Confirma en la fuente oficial qué documentos acepta tu forma de entrada.',
            'Revisa si eres elegible para el acuerdo bilateral Brasil–Argentina, que prevé residencia permanente.',
            'Organiza los documentos con tiempo, pero confirma los requisitos actuales antes de presentar.',
          ],
          en: [
            'Confirm in the official source which documents your entry method accepts.',
            'Check whether you qualify for the Brazil–Argentina agreement, which provides permanent residence.',
            'Prepare documents early, but confirm current requirements before filing.',
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
          pt: 'Você diferenciou a estada de visitante do pedido de residência e abriu a rota oficial aplicável ao seu caso.',
          es: 'Diferenciaste la estadía como visitante del pedido de residencia y abriste la ruta oficial aplicable a tu caso.',
          en: 'You distinguished visitor stay from residence and opened the official route for your case.',
        ),
        tips: _list(
          locale,
          pt: [
            'Guarde a data de entrada e o comprovante migratório. Regras podem variar conforme situação pessoal e forma de entrada.',
          ],
          es: [
            'Guarda la fecha y el comprobante de entrada. Las reglas pueden variar según tu situación y forma de ingreso.',
          ],
          en: [
            'Keep your entry date and migration receipt. Rules can vary by personal circumstances and entry method.',
          ],
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        estimatedTimeLabel: _t(locale, pt: '2 min', es: '2 min', en: '2 min'),
        preArrivalRequired: true,
        urgencyLevel: GuideUrgencyLevel.watch,
        urgencySignal: _t(
          locale,
          pt: 'Leia antes de viajar e confirme na Polícia Federal; isso é orientação, não consultoria jurídica.',
          es: 'Léelo antes de viajar y confirma con la Policía Federal; es orientación, no asesoría jurídica.',
          en: 'Read before travel and confirm with Federal Police; this is guidance, not legal advice.',
        ),
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Polícia Federal · Acordo Brasil–Argentina',
          sourceUrl: PreparationResourceLinks.argentinaResidenceAgreement
              .toString(),
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'Requisitos e procedimentos podem mudar. Confirme a versão vigente antes do protocolo.',
            es: 'Los requisitos y procedimientos pueden cambiar. Confirma la versión vigente antes de presentar.',
            en: 'Requirements and procedures may change. Confirm the current version before filing.',
          ),
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
          pt: 'Sem ele, seu pedido de residência pode atrasar ou ficar incompleto.',
          es: 'Sin esto, tu pedido de residencia puede demorarse o quedar incompleto.',
          en: 'Without it, your residence request may be delayed or incomplete.',
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
            'Se você tem mais de 18 anos e DNI argentino, pode fazer online. Sem DNI argentino, a rota oficial passa a ser presencial.',
            'Escolha a modalidade disponível para o seu caso: 1 hora, 6 horas, 24 horas ou 5 dias úteis.',
            'Faça o pagamento e conte o prazo a partir da confirmação dele.',
            'Salve o PDF e leve uma cópia com seus outros documentos.',
          ],
          es: [
            'Entra al sitio del Registro Nacional de Reincidencia.',
            'Si tienes mas de 18 años y DNI argentino, puedes hacerlo online. Sin DNI argentino, la ruta oficial pasa a ser presencial.',
            'Elige la modalidad disponible para tu caso: 1 hora, 6 horas, 24 horas o 5 dias habiles.',
            'Haz el pago y cuenta el plazo desde la acreditacion.',
            'Guarda el PDF y lleva una copia con tus otros documentos.',
          ],
          en: [
            'Go to the National Recidivism Registry website.',
            'If you are over 18 and have an Argentine DNI, you can do it online. Without an Argentine DNI, the official path becomes in-person.',
            'Choose the option available for your case: 1 hour, 6 hours, 24 hours, or 5 business days.',
            'Make the payment and count the timeline from payment confirmation.',
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
            'Na via online, o FAQ oficial cita Mi Argentina, Banelco, AFIP ou ANSES como formas aceitas de autenticação/pagamento.',
          ],
          es: [
            'La validez es corta. Planifica la emision cerca de tu llegada, sin dejarlo para despues del viaje.',
            'En la via online, el FAQ oficial menciona Mi Argentina, Banelco, AFIP o ANSES como formas aceptadas de autenticacion/pago.',
          ],
          en: [
            'Validity is short. Time the issue close to your arrival without leaving it for after the trip.',
            'For the online path, the official FAQ lists Mi Argentina, Banelco, AFIP, or ANSES as accepted authentication/payment routes.',
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
          pt: '1 hora a 5 dias úteis',
          es: '1 hora a 5 dias habiles',
          en: '1 hour to 5 business days',
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
              pt: 'Aguardar emissão conforme a modalidade escolhida (1 hora, 6 horas, 24 horas ou 5 dias úteis)',
              es: 'Esperar la emision segun la modalidad elegida (1 hora, 6 horas, 24 horas o 5 dias habiles)',
              en: 'Wait for issuance based on the chosen option (1 hour, 6 hours, 24 hours, or 5 business days)',
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
          pt: 'Defina primeiro quando fará o protocolo. Emitir cedo demais pode deixar o certificado fora da janela aceita pela Polícia Federal.',
          es: 'Primero define cuándo presentarás la solicitud. Emitirlo demasiado pronto puede dejar el certificado fuera del plazo aceptado por la Policía Federal.',
          en: 'First decide when you will file. Requesting too early may put the certificate outside the window accepted by Federal Police.',
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Validade de 90 dias: solicite próximo à data de embarque.',
            'Resolva na Argentina - pedido após a viagem causa semanas de atraso.',
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
          pt: 'Faça antes de viajar: uma reserva calculada reduz decisões apressadas diante de imprevistos no primeiro mês.',
          es: 'Hazlo antes de viajar: una reserva calculada reduce decisiones apuradas ante imprevistos del primer mes.',
          en: 'Do this before traveling: a calculated buffer reduces rushed decisions when surprises arise in the first month.',
        ),
      ),
      GuideActionItem(
        id: 'item_0_5_mercado_trabalho',
        title: _t(
          locale,
          pt: 'Pesquise o mercado de trabalho na sua área',
          es: 'Investigá el mercado laboral en tu área',
          en: 'Research the job market in your field',
        ),
        shortDescription: _t(
          locale,
          pt: 'Entender o que seu perfil vale no Brasil antes de sair evita surpresas ruins e ajuda a calcular quanto você precisa para se sustentar.',
          es: 'Entender cuanto vale tu perfil en Brasil antes de salir evita malas sorpresas y ayuda a calcular cuanto necesitas para sostenerte.',
          en: 'Understanding how your profile may be valued in Brazil before leaving can reduce bad surprises and help you estimate how much support you may need.',
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
          es: 'El mercado laboral brasileño tiene dinámicas y rangos salariales muy diferentes a los de Argentina. Entender esto antes de llegar te da una ventaja real en la planificación.',
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
          pt: 'Prazo variável',
          es: 'Plazo variable',
          en: 'Timing varies',
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
            'Se considerar plano privado, compare operadoras registradas na ANS, rede local, carências e coparticipação.',
            'Veja como solicitar o Cartão SUS/CNS presencialmente depois da chegada; CPF e comprovante facilitam o cadastro se você já os tiver.',
            'Se tiver condição crônica ou uso de medicamento contínuo, leve receita, nome genérico e a documentação exigida pela Anvisa para a quantidade transportada.',
            'Verifique se seus medicamentos habituais têm equivalente no Brasil — o nome comercial pode ser diferente.',
          ],
          es: [
            'Entiende que las urgencias y emergencias en el SUS no dependen de tener CPF o Tarjeta SUS emitida.',
            'Conoce la diferencia entre UBS (consultas de rutina), UPA (urgencias 24h) y Hospital (emergencias).',
            'Si consideras un plan privado, compara operadoras registradas en ANS, red local, carencias y copago.',
            'Mira cómo solicitar la Tarjeta SUS/CNS presencialmente después de llegar; CPF y comprobante facilitan el registro si ya los tienes.',
            'Si tienes una condición crónica o usas medicación continua, lleva receta, nombre genérico y la documentación exigida por Anvisa para la cantidad transportada.',
            'Verifica si tus medicamentos habituales tienen equivalente en Brasil — el nombre comercial puede ser diferente.',
          ],
          en: [
            'Understand that urgent and emergency SUS care does not depend on already having a CPF or SUS card.',
            'Know the difference between UBS (routine appointments), UPA (24h urgent care), and Hospital (emergencies).',
            'If considering private cover, compare ANS-registered providers, local networks, waiting periods, and copays.',
            'Check how to request a SUS/CNS card in person after arrival; a CPF and proof of address make registration easier if you already have them.',
            'For a chronic condition or ongoing medication, bring a prescription, generic name, and the Anvisa documentation required for the quantity carried.',
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
            'Não adie uma urgência por falta de CPF, Cartão SUS ou documento brasileiro.',
            'O Cartão SUS (CNS) organiza o cadastro, mas não cria o direito ao atendimento.',
            'Oferta e tempo de espera variam por município, unidade, demanda e complexidade.',
          ],
          es: [
            'No postergues una urgencia por falta de CPF, Tarjeta SUS o documento brasileño.',
            'La Tarjeta SUS (CNS) organiza el registro, pero no crea el derecho a la atención.',
            'La oferta y el tiempo de espera varían según municipio, unidad, demanda y complejidad.',
          ],
          en: [
            'Do not delay urgent care because you lack a CPF, SUS card, or Brazilian document.',
            'The SUS card (CNS) organizes registration but does not create the right to care.',
            'Availability and wait times vary by municipality, facility, demand, and complexity.',
          ],
        ),
        communityTips: const <String>[],
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
          pt: 'Escolher opção de pagamento',
          es: 'Elegir opcion de pago',
          en: 'Choose payment option',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        steps: _list(
          locale,
          pt: [
            'Verifique se seu cartão argentino funciona para compras e saques internacionais.',
            'Configure pelo menos uma alternativa digital que funcione na rota Argentina → Brasil, como Global66 ou Western Union.',
            'Troque um valor em reais ou dólares em espécie como backup.',
            'Teste pelo menos um pagamento antes de embarcar.',
          ],
          es: [
            'Verifica si tu tarjeta argentina funciona para compras y extracciones internacionales.',
            'Configura al menos una alternativa digital que funcione en la ruta Argentina → Brasil, como Global66 o Western Union.',
            'Cambia algo de efectivo en reales o dolares como respaldo.',
            'Prueba al menos un pago antes de embarcar.',
          ],
          en: [
            'Check that your Argentine card works for international purchases and withdrawals.',
            'Set up at least one digital option that works on the Argentina → Brazil route, such as Global66 or Western Union.',
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
            'Não dependa de uma única opção: combine cartão, app de transferência e reserva em espécie.',
          ],
          es: [
            'Evita el cambio del aeropuerto — el spread suele ser muy alto.',
            'No dependas de una sola opcion: combina tarjeta, app de transferencias y respaldo en efectivo.',
          ],
          en: [
            'Avoid airport exchange — the spread is usually very high.',
            'Do not rely on a single option: combine card, transfer app, and cash backup.',
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
              pt: 'Conta global (Global66)',
              es: 'Cuenta global (Global66)',
              en: 'Global account (Global66)',
            ),
            description: _t(
              locale,
              pt: 'Enviar dinheiro da Argentina ao Brasil e ainda pagar com Pix no país.',
              es: 'Enviar dinero de Argentina a Brasil y ademas pagar con Pix en el pais.',
              en: 'Send money from Argentina to Brazil and also pay with Pix in-country.',
            ),
            pros: _list(
              locale,
              pt: [
                'Rota ARS → BRL ativa',
                'Pix no Brasil',
                'App focado em viajantes',
              ],
              es: [
                'Ruta ARS → BRL activa',
                'Pix en Brasil',
                'App pensada para viajeros',
              ],
              en: [
                'Active ARS → BRL route',
                'Pix in Brazil',
                'Traveler-focused app',
              ],
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
              pt: 'Remessa e saque (Western Union)',
              es: 'Remesa y retiro (Western Union)',
              en: 'Transfer and pickup (Western Union)',
            ),
            description: _t(
              locale,
              pt: 'Enviar online ou em agência, com opção de conta bancária ou retirada.',
              es: 'Enviar online o en agencia, con opcion de cuenta bancaria o retiro.',
              en: 'Send online or in person, with bank deposit or cash pickup options.',
            ),
            pros: _list(
              locale,
              pt: [
                'Presencial ou online',
                'Saque em espécie',
                'Rede conhecida',
              ],
              es: ['Presencial u online', 'Retiro en efectivo', 'Red conocida'],
              en: ['In person or online', 'Cash pickup', 'Well-known network'],
            ),
            cons: _list(
              locale,
              pt: [
                'Câmbio e tarifa variam',
                'Pode sair mais caro que opções digitais',
              ],
              es: [
                'Cambio y tarifa varian',
                'Puede salir mas caro que opciones digitales',
              ],
              en: [
                'Exchange and fees vary',
                'May cost more than digital options',
              ],
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
              pt: 'Conta Global66, Western Union ou similar configurada',
              es: 'Cuenta Global66, Western Union o similar configurada',
              en: 'Global66, Western Union, or similar account set up',
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
          pt: 'Configure antes de embarcar — o câmbio de aeroporto costuma ter spread e tarifas menos favoráveis.',
          es: 'Configura antes de embarcar: el cambio del aeropuerto suele tener margen y comisiones menos favorables.',
          en: 'Set this up before boarding — airport exchange commonly has less favorable spreads and fees.',
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Compare o valor líquido antes de usar câmbio de aeroporto; spreads e tarifas podem ser menos favoráveis.',
            'Não dependa de um único meio de pagamento — se travar, você fica sem acesso a dinheiro.',
          ],
          es: [
            'Compara el valor neto antes de usar el cambio del aeropuerto; el margen y las comisiones pueden ser menos favorables.',
            'No dependas de un solo medio de pago — si falla, quedas sin acceso al dinero.',
          ],
          en: [
            'Compare the net amount before using airport exchange; spreads and fees may be less favorable.',
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
          pt: 'Reserve voo e hospedagem antes de viajar e confira a rota de CPF aplicável; o cadastro também pode ser iniciado no exterior.',
          es: 'Reserva vuelo y alojamiento antes de viajar y revisa la vía de CPF aplicable; el trámite también puede iniciarse en el exterior.',
          en: 'Book travel and initial housing before leaving and check the applicable CPF route; registration can also begin abroad.',
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
        dependencies: const <String>['item_1_0_entry_proof'],
        context: _t(
          locale,
          pt: 'Logo na chegada, ter um número brasileiro ajuda com internet móvel, SMS, apps e contatos locais.',
          es: 'Apenas llegar, tener un numero brasileno ayuda con internet movil, SMS, apps y contactos locales.',
          en: 'Right after arrival, having a Brazilian number helps with mobile data, SMS, apps, and local contacts.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Sem número local logo no começo, você perde tempo com internet ruim, SMS de validação e contato com serviços no Brasil.',
          es: 'Sin numero local al comienzo, pierdes tiempo con mala internet, SMS de validacion y contacto con servicios en Brasil.',
          en: 'Without a local number early on, you lose time with weak connectivity, validation SMS, and contact with services in Brazil.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Escolher operadora',
          es: 'Elegir operadora',
          en: 'Choose a carrier',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: null,
        steps: _list(
          locale,
          pt: [
            'Antes de viajar, confirme que o aparelho está desbloqueado e mantenha roaming ou eSIM como contingência para a chegada.',
            'Compare a cobertura das operadoras no endereço da hospedagem e nos trajetos de trabalho usando os mapas oficiais.',
            'Se já tiver CPF, confira a ativação digital; sem CPF, prefira loja oficial e confirme a rota para estrangeiros antes de pagar.',
            'A TIM publica uma rota para estrangeiros com passaporte, RNE ou identidade de país do Mercosul e endereço de hospedagem.',
            'Teste SMS e internet móvel antes de sair da loja.',
          ],
          es: [
            'Antes de viajar, confirma que el teléfono esté liberado y mantén roaming o eSIM como contingencia para la llegada.',
            'Compara la cobertura en el alojamiento y en los trayectos de trabajo usando los mapas oficiales.',
            'Si ya tienes CPF, revisa la activación digital; sin CPF, ve a una tienda oficial y confirma la vía para extranjeros antes de pagar.',
            'TIM publica una vía para extranjeros con pasaporte, RNE o identidad de un país del Mercosur y dirección de alojamiento.',
            'Prueba SMS e internet movil antes de salir de la tienda.',
          ],
          en: [
            'Before travel, confirm that the phone is unlocked and keep roaming or an eSIM as an arrival contingency.',
            'Compare carrier coverage at the accommodation and along work routes using official maps.',
            'If you already have a CPF, check digital activation; without one, use an official store and confirm the foreigner route before paying.',
            'TIM publishes a foreign-visitor route accepting a passport, RNE, or Mercosur-country ID plus the accommodation address.',
            'Test SMS and mobile data before leaving the store.',
          ],
        ),
        requirements: _list(
          locale,
          pt: [
            'Passaporte, RNE ou identidade estrangeira aceita',
            'Endereço da hospedagem',
            'Aparelho desbloqueado e compatível',
            'CPF, se a rota de ativação escolhida exigir',
          ],
          es: [
            'Pasaporte, RNE o identidad extranjera aceptada',
            'Dirección del alojamiento',
            'Teléfono liberado y compatible',
            'CPF, si la vía de activación elegida lo exige',
          ],
          en: [
            'Accepted passport, RNE, or foreign ID',
            'Accommodation address',
            'Unlocked compatible phone',
            'CPF if required by the selected activation route',
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
            'Não use o CPF de outra pessoa: a linha e eventuais responsabilidades ficam vinculadas ao titular cadastrado.',
            'Cobertura teórica varia dentro de prédios; confirme também com moradores ou na hospedagem.',
            'Guarde o número — depois de abrir uma conta compatível, ele pode ser cadastrado como chave Pix.',
          ],
          es: [
            'No uses el CPF de otra persona: la línea y las responsabilidades quedan vinculadas al titular registrado.',
            'La cobertura teórica varía dentro de edificios; confirma también con residentes o en el alojamiento.',
            'Guarda el número: después de abrir una cuenta compatible, podrás registrarlo como clave Pix.',
          ],
          en: [
            'Do not use someone else’s CPF: the line and related responsibilities remain tied to the registered holder.',
            'Theoretical coverage varies inside buildings; also confirm with residents or the accommodation.',
            'Keep the number — after opening a compatible account, it can be registered as a Pix key.',
          ],
        ),
        decisionOptions: [
          GuideDecisionOption(
            title: 'Claro',
            description: _t(
              locale,
              pt: 'Compare o mapa no endereço real e confirme a documentação de ativação antes da compra.',
              es: 'Compara el mapa en la dirección real y confirma la documentación de activación antes de comprar.',
              en: 'Compare the map at the real address and confirm activation documents before purchase.',
            ),
            pros: _list(
              locale,
              pt: ['Mapa oficial disponível', 'Opções pré-pagas'],
              es: ['Mapa oficial disponible', 'Opciones prepagas'],
              en: ['Official map available', 'Prepaid options'],
            ),
            cons: _list(
              locale,
              pt: ['A rota sem CPF deve ser confirmada diretamente'],
              es: ['La vía sin CPF debe confirmarse directamente'],
              en: ['The no-CPF route must be confirmed directly'],
            ),
          ),
          GuideDecisionOption(
            title: 'Vivo',
            description: _t(
              locale,
              pt: 'Compare a cobertura da hospedagem e dos trajetos; não presuma qualidade nacional uniforme.',
              es: 'Compara la cobertura del alojamiento y los trayectos; no supongas calidad uniforme en todo el país.',
              en: 'Compare coverage at the accommodation and along key routes; do not assume uniform nationwide quality.',
            ),
            pros: _list(
              locale,
              pt: ['Mapa oficial disponível', 'Opções pré-pagas'],
              es: ['Mapa oficial disponible', 'Opciones prepagas'],
              en: ['Official map available', 'Prepaid options'],
            ),
            cons: _list(
              locale,
              pt: ['Confirme a exigência de CPF antes de comprar'],
              es: ['Confirma la exigencia de CPF antes de comprar'],
              en: ['Confirm CPF requirements before buying'],
            ),
          ),
          GuideDecisionOption(
            title: 'TIM',
            description: _t(
              locale,
              pt: 'Tem orientação pública específica para visitantes estrangeiros e aceita documento do Mercosul.',
              es: 'Tiene orientación pública específica para visitantes extranjeros y acepta documento del Mercosur.',
              en: 'Publishes specific guidance for foreign visitors and accepts Mercosur identification.',
            ),
            pros: _list(
              locale,
              pt: [
                'Rota para estrangeiro documentada',
                'Passaporte ou identidade argentina aceitos',
              ],
              es: [
                'Vía para extranjeros documentada',
                'Acepta pasaporte o identidad argentina',
              ],
              en: [
                'Documented foreign-visitor route',
                'Accepts a passport or Argentine ID',
              ],
            ),
            cons: _list(
              locale,
              pt: ['Ainda é necessário comparar a cobertura no endereço'],
              es: ['Igual debes comparar la cobertura en la dirección'],
              en: ['Coverage at the actual address still needs comparison'],
            ),
            recommended: true,
          ),
        ],
        supportLinks: [
          GuideSupportLink(
            label: 'Anatel · Mapas de cobertura',
            url: PreparationResourceLinks.anatelMobileCoverage.toString(),
          ),
          GuideSupportLink(
            label: 'Anatel · Cadastro pré-pago',
            url: PreparationResourceLinks.anatelPrepaidRegistration.toString(),
          ),
          GuideSupportLink(
            label: 'TIM · Estrangeiros no Brasil',
            url: PreparationResourceLinks.timForeignVisitors.toString(),
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
              pt: 'SMS e internet testados',
              es: 'SMS e internet probados',
              en: 'SMS and mobile data tested',
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
        urgencySignal: _t(
          locale,
          pt: 'Resolva no dia da chegada, depois de guardar o comprovante de entrada.',
          es: 'Resuélvelo el día de llegada, después de guardar el comprobante de ingreso.',
          en: 'Handle this on arrival day, after saving proof of entry.',
        ),
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Anatel · Cobertura e cadastro pré-pago',
          sourceUrl: PreparationResourceLinks.anatelMobileCoverage.toString(),
          lastVerified: DateTime(2026, 7, 29),
          scopeNote: _t(
            locale,
            pt: 'Cobertura é estimada e a ativação sem CPF varia por operadora; confirme antes de pagar.',
            es: 'La cobertura es estimada y la activación sin CPF varía por operadora; confirma antes de pagar.',
            en: 'Coverage is estimated and no-CPF activation varies by carrier; confirm before paying.',
          ),
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
        phase: GuidePhase.preparation,
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
            '"A monthly Airbnb discount worked well for me — it covered an address for CPF and was easy to cancel."',
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
            'O serviço oficial é gratuito; unidades conveniadas podem cobrar a tarifa publicada no portal.',
            'Documentos aceitos e prazo variam conforme atendimento no exterior, Receita Federal ou unidade conveniada.',
            'Guarde o comprovante de inscrição e confirme a situação cadastral no canal oficial.',
          ],
          es: [
            'El servicio oficial es gratuito; las unidades asociadas pueden cobrar la tarifa publicada en el portal.',
            'Los documentos aceptados y el plazo cambian según consulado, Receita Federal o unidad asociada.',
            'Guarda el comprobante y verifica tu situación cadastral en el canal oficial.',
          ],
          en: [
            'The official service is free; partner units may charge the fee published on the portal.',
            'Accepted documents and timing vary by consulate, Receita Federal, or partner unit.',
            'Keep the registration receipt and verify your status through the official channel.',
          ],
        ),
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Receita Federal · Inscrição no CPF',
          sourceUrl: PreparationResourceLinks.cpfInBrazil.toString(),
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'Evite intermediários não oficiais e confirme documentos, tarifa e canal antes do atendimento.',
            es: 'Evita intermediarios no oficiales y confirma documentos, tarifa y canal antes del trámite.',
            en: 'Avoid unofficial intermediaries and confirm documents, fee, and channel before service.',
          ),
        ),
      ),
      GuideActionItem(
        id: 'item_2_2_residencia',
        title: _t(
          locale,
          pt: 'Escolha e inicie sua rota de residência',
          es: 'Elige e inicia tu ruta de residencia',
          en: 'Choose and start your residence route',
        ),
        shortDescription: _t(
          locale,
          pt: 'Para argentinos elegíveis, o acordo bilateral prevê residência permanente; confirme se essa é a melhor base para seu caso.',
          es: 'Para argentinos elegibles, el acuerdo bilateral prevé residencia permanente; confirma si es la mejor base para tu caso.',
          en: 'For eligible Argentines, the bilateral agreement provides permanent residence; confirm whether it best fits your case.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.documents,
        orderIndex: 8,
        isCompleted: false,
        icon: Icons.account_balance_outlined,
        dependencies: const <String>[],
        context: _t(
          locale,
          pt: 'Existem bases legais diferentes. O acordo bilateral Brasil–Argentina pode permitir pedido direto de residência permanente; a rota Mercosul temporária não deve ser apresentada como única opção.',
          es: 'Existen bases legales diferentes. El acuerdo bilateral Brasil–Argentina puede permitir pedir residencia permanente directa; la ruta Mercosur temporaria no debe presentarse como única opción.',
          en: 'Different legal bases exist. The Brazil–Argentina agreement may allow direct permanent residence; temporary Mercosur residence should not be shown as the only option.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Escolher a base correta evita pagar, reunir documentos ou planejar uma transformação de status que talvez não se aplique.',
          es: 'Elegir la base correcta evita pagar, reunir documentos o planificar un cambio de estatus que quizá no corresponda.',
          en: 'Choosing the correct basis avoids unnecessary fees, documents, or status-conversion planning.',
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
            'Abra a página oficial do acordo bilateral Brasil–Argentina.',
            'Confirme sua elegibilidade e compare essa base com qualquer outra rota indicada para sua situação.',
            'Reúna somente os documentos listados na versão atual do serviço.',
            'Preencha o requerimento, siga as instruções de agenda e guarde o protocolo.',
          ],
          es: [
            'Abre la página oficial del acuerdo bilateral Brasil–Argentina.',
            'Confirma tu elegibilidad y compara esta base con cualquier otra ruta indicada para tu situación.',
            'Reúne únicamente los documentos de la versión vigente del servicio.',
            'Completa el requerimiento, sigue las instrucciones de turno y guarda el protocolo.',
          ],
          en: [
            'Open the official Brazil–Argentina bilateral agreement page.',
            'Confirm eligibility and compare this basis with any other route indicated for your circumstances.',
            'Gather only the documents listed in the current service version.',
            'Complete the application, follow booking instructions, and keep the protocol.',
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
            'Agendar cedo pode reduzir atrito operacional, mas não transforme uma recomendação em prazo legal.',
            'A própria página oficial deve ser a referência para requisitos, taxas e sequência.',
            'Leve originais e cópias apenas quando o serviço vigente os pedir.',
          ],
          es: [
            'Agendar temprano puede reducir fricción, pero no conviertas una recomendación en plazo legal.',
            'La página oficial debe ser la referencia de requisitos, tasas y secuencia.',
            'Lleva originales y copias cuando el servicio vigente los pida.',
          ],
          en: [
            'Booking early can reduce friction, but do not turn a recommendation into a legal deadline.',
            'Use the official page for current requirements, fees, and sequence.',
            'Bring originals and copies when the current service asks for them.',
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
        urgencyLevel: GuideUrgencyLevel.watch,
        urgencySignal: _t(
          locale,
          pt: 'Confirme a base legal antes de protocolar. Para argentinos elegíveis, avalie primeiro o acordo bilateral de residência permanente.',
          es: 'Confirma la base legal antes de presentar. Si eres elegible, evalúa primero el acuerdo bilateral de residencia permanente.',
          en: 'Confirm the legal basis before filing. Eligible Argentines should evaluate the bilateral permanent-residence agreement first.',
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
            phrase: 'Quero confirmar a base legal da minha residência',
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
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Polícia Federal · Acordo Brasil–Argentina',
          sourceUrl: PreparationResourceLinks.argentinaResidenceAgreement
              .toString(),
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'A elegibilidade é individual. Movaro organiza a informação, mas não substitui a decisão da Polícia Federal.',
            es: 'La elegibilidad es individual. Movaro organiza la información, pero no reemplaza la decisión de la Policía Federal.',
            en: 'Eligibility is individual. Movaro organizes information but does not replace Federal Police decisions.',
          ),
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
          pt: 'Abrir opções de banco',
          es: 'Abrir opciones de banco',
          en: 'Open bank options',
        ),
        steps: _list(
          locale,
          pt: [
            'Compare instituições reguladas pelo Banco Central antes de decidir.',
            'Decida entre banco digital, banco tradicional ou conta focada em câmbio.',
            'Separe CPF, documento e selfie para abrir pelo app.',
            'Depois da aprovação, confirme acesso ao app e peça o cartão físico.',
          ],
          es: [
            'Compara instituciones reguladas por el Banco Central antes de decidir.',
            'Decide entre banco digital, banco tradicional o cuenta enfocada en cambio.',
            'Separa CPF, documento y selfie para abrirla por la app.',
            'Despues de la aprobacion, confirma acceso a la app y pide la tarjeta fisica.',
          ],
          en: [
            'Compare institutions regulated by Brazil’s Central Bank before deciding.',
            'Decide between a digital bank, a traditional bank, or a foreign-exchange focused account.',
            'Prepare CPF, ID, and selfie to open it in the app.',
            'After approval, confirm app access and request the physical card.',
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
            'Compare conta digital, tradicional e de câmbio por tarifa, documentos e suporte.',
            'Aprovação depende da análise individual de cada instituição.',
            'Se você recebe do exterior, vale comparar uma conta comum com uma solução de câmbio.',
          ],
          es: [
            'Compara cuenta digital, tradicional y de cambio por tarifa, documentos y soporte.',
            'La aprobación depende del análisis de cada institución.',
            'Si cobras del exterior, vale comparar una cuenta comun con una solucion de cambio.',
          ],
          en: [
            'Compare digital, traditional, and FX accounts by fees, documents, and support.',
            'Approval depends on each institution’s individual review.',
            'If you receive money from abroad, compare a regular account with a foreign-exchange solution.',
          ],
        ),
        decisionOptions: [
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Conta digital regulada',
              es: 'Cuenta digital regulada',
              en: 'Regulated digital account',
            ),
            description: _t(
              locale,
              pt: 'São as rotas digitais mais simples para comparar abertura, app e integração com Pix.',
              es: 'Son las rutas digitales mas simples para comparar apertura, app e integracion con Pix.',
              en: 'These are the simplest digital routes to compare onboarding, app experience, and Pix integration.',
            ),
            pros: _list(
              locale,
              pt: [
                'Processo 100% pelo app',
                'Você consegue comparar aprovação e experiência sem ir a agência',
              ],
              es: [
                'Proceso 100% por app',
                'Puedes comparar aprobacion y experiencia sin ir a una sucursal',
              ],
              en: [
                '100% app process',
                'You can compare approval and app experience without visiting a branch',
              ],
            ),
            cons: _list(
              locale,
              pt: [
                'Suporte presencial limitado',
                'A aprovação pode variar entre bancos e perfis',
              ],
              es: [
                'Soporte presencial limitado',
                'La aprobacion puede variar entre bancos y perfiles',
              ],
              en: [
                'Limited in-person support',
                'Approval can vary across banks and profiles',
              ],
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
          pt: 'Prazo variável',
          es: 'Plazo variable',
          en: 'Timing varies',
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'bank_1',
            title: _t(
              locale,
              pt: 'Comparar tarifas, documentos e atendimento de instituições reguladas',
              es: 'Comparar tarifas, documentos y atención de instituciones reguladas',
              en: 'Compare fees, documents, and support at regulated institutions',
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
              pt: 'Acesso ao app confirmado e cartão físico solicitado',
              es: 'Acceso a la app confirmado y tarjeta fisica solicitada',
              en: 'App access confirmed and physical card requested',
            ),
            isCompleted: false,
          ),
        ],
        urgencyLevel: GuideUrgencyLevel.watch,
        urgencySignal: _t(
          locale,
          pt: 'Nenhuma instituição é obrigada a aprovar a conta. Compare requisitos e tenha uma alternativa.',
          es: 'Ninguna institución está obligada a aprobar la cuenta. Compará requisitos y tené una alternativa.',
          en: 'No institution is required to approve an account. Compare requirements and keep an alternative.',
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Não há marca universalmente mais fácil para estrangeiros; cada análise é individual.',
            'Uma reprovação não garante aprovação nem reprovação em outra instituição.',
            'Não use conta de terceiros para receber pagamentos — gera problemas legais e fiscais.',
          ],
          es: [
            'No existe una marca universalmente más fácil para extranjeros; cada análisis es individual.',
            'Un rechazo no garantiza aprobación ni rechazo en otra institución.',
            'No uses la cuenta de un tercero para cobrar pagos — genera problemas legales y fiscales.',
          ],
          en: [
            'No brand is universally easier for foreigners; each review is individual.',
            'A rejection does not guarantee approval or rejection at another institution.',
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
            'Confira se a instituição é autorizada pelo Banco Central antes de enviar documentos.',
            'Compare tarifas, atendimento presencial e facilidade de movimentar renda do exterior.',
            'Não entregue senha, código de autenticação ou acesso remoto a supostos atendentes.',
          ],
          es: [
            'Verificá que la institución esté autorizada por el Banco Central antes de enviar documentos.',
            'Compará tarifas, atención presencial y facilidad para mover ingresos del exterior.',
            'No entregues contraseña, código de autenticación ni acceso remoto a supuestos agentes.',
          ],
          en: [
            'Verify Central Bank authorization before sending documents.',
            'Compare fees, in-person support, and foreign-income transfer options.',
            'Never give passwords, authentication codes, or remote access to alleged agents.',
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
          pt: 'A garantia varia por contrato. Confirme a modalidade antes de pagar ou assinar.',
          es: 'La garantía cambia según el contrato. Confirmá la modalidad antes de pagar o firmar.',
          en: 'The guarantee varies by contract. Confirm the type before paying or signing.',
        ),
        warningFlags: _list(
          locale,
          pt: [
            'O contrato pode usar uma das garantias permitidas em lei; não aceite acúmulo de garantias sem revisão.',
            'Golpe do falso anúncio: pedem depósito antecipado por foto bonita. Nunca pague sem visitar.',
            'Pressão para fechar rápido ("outro interessado") é sinal de alerta — tome seu tempo.',
            'Na caução em dinheiro, confirme o limite legal e exija recibo e previsão contratual.',
          ],
          es: [
            'El contrato puede usar una de las garantías permitidas; no aceptes acumular garantías sin revisión.',
            'Estafa del falso anuncio: piden deposito anticipado por foto bonita. Nunca pagues sin visitar.',
            'Presion para cerrar rapido ("hay otro interesado") es senal de alerta — toma tu tiempo.',
            'Para depósito en dinero, confirmá el límite legal y exigí recibo y cláusula contractual.',
          ],
          en: [
            'The contract may use one legally permitted guarantee; do not accept stacked guarantees without review.',
            'Fake listing scam: deposit demanded before visit based on nice photos. Never pay without visiting.',
            'Pressure to close fast ("another buyer interested") is a red flag — take your time.',
            'For a cash deposit, confirm the legal cap and require a receipt and contract clause.',
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
            'Ative o Pix na conta e, se quiser facilitar recebimentos, cadastre uma chave.',
            'Faça um teste pequeno para garantir que enviar e receber está funcionando.',
          ],
          es: [
            'Entra en la app de tu cuenta.',
            'Activa Pix en la cuenta y, si quieres facilitar cobros, registra una clave.',
            'Haz una prueba pequena para confirmar que enviar y recibir funciona.',
          ],
          en: [
            'Open your banking app.',
            'Enable Pix in the account and, if you want easier inbound payments, register a key.',
            'Run a small test to confirm both sending and receiving work.',
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
          pt: [
            'A chave Pix facilita receber, mas você ainda pode usar Pix com os dados da conta.',
            'Além do Pix, aprenda a pagar boleto pelo app do banco.',
          ],
          es: [
            'La clave Pix facilita cobrar, pero aun puedes usar Pix con los datos de la cuenta.',
            'Ademas de Pix, aprende a pagar boleto desde la app del banco.',
          ],
          en: [
            'A Pix key makes receiving easier, but you can still use Pix with account details.',
            'Besides Pix, learn how to pay boletos in your banking app.',
          ],
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
              pt: 'Pix ativado na conta',
              es: 'Pix activado en la cuenta',
              en: 'Pix enabled on the account',
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
        primaryActionTarget: null,
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
          pt: 'Regularize sua licença argentina no Brasil',
          es: 'Regulariza tu licencia argentina en Brasil',
          en: 'Regularize your Argentine license in Brazil',
        ),
        shortDescription: _t(
          locale,
          pt: 'A habilitação estrangeira válida costuma servir por até 180 dias. Depois disso, você precisa seguir o processo brasileiro.',
          es: 'La licencia extranjera valida suele servir hasta 180 dias. Despues de eso, debes seguir el proceso brasileno.',
          en: 'A valid foreign license is usually accepted for up to 180 days. After that, you need to follow the Brazilian process.',
        ),
        fullContent: null,
        type: GuideActionType.external,
        phase: GuidePhase.arrival,
        orderIndex: 15,
        isCompleted: false,
        icon: Icons.directions_car_outlined,
        applicabilityConditions: const <String>['will_drive'],
        dependencies: <String>['item_2_2_residencia'],
        context: _t(
          locale,
          pt: 'O processo depende do DETRAN do seu estado, da validade da licença argentina e da sua situação migratória no Brasil.',
          es: 'El proceso depende del DETRAN de tu estado, de la validez de la licencia argentina y de tu situacion migratoria en Brasil.',
          en: 'The process depends on your state DETRAN, the validity of your Argentine license, and your migration status in Brazil.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Depois da janela inicial de uso da licença estrangeira, continuar dirigindo sem regularizar a situação pode gerar multa e bloqueios.',
          es: 'Despues de la ventana inicial de uso de la licencia extranjera, seguir manejando sin regularizar puede generar multas y bloqueos.',
          en: 'After the initial foreign-license window, continuing to drive without regularizing can lead to fines and restrictions.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Buscar DETRAN',
          es: 'Buscar DETRAN',
          en: 'Find DETRAN',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        steps: _list(
          locale,
          pt: [
            'Verifique se sua licença argentina está válida, foi emitida há mais de 12 meses e ainda está dentro da janela de uso no Brasil.',
            'Confirme no DETRAN do seu estado qual é o procedimento para habilitação estrangeira.',
            'Reúna CPF, documento migratório regular, comprovante de endereço, licença original e tradução juramentada.',
            'Se o DETRAN pedir, providencie também certidão/declaração consular para habilitação da América do Sul.',
            'Agende atendimento no DETRAN do seu estado.',
            'Faça os exames exigidos pelo seu estado. Em geral há exame médico e psicológico, e podem existir exigências extras conforme o caso.',
            'Pague as taxas e aguarde a emissão da CNH.',
          ],
          es: [
            'Verifica si tu licencia argentina esta valida, fue emitida hace mas de 12 meses y aun esta dentro de la ventana de uso en Brasil.',
            'Confirma en el DETRAN de tu estado cual es el procedimiento para licencia extranjera.',
            'Reune CPF, documento migratorio regular, comprobante de domicilio, licencia original y traduccion jurada.',
            'Si el DETRAN lo pide, consigue tambien certificado/declaracion consular para licencias de America del Sur.',
            'Agenda turno en el DETRAN de tu estado.',
            'Haz los examenes exigidos por tu estado. En general hay examen medico y psicologico, y pueden existir exigencias extra segun el caso.',
            'Paga las tasas y espera la emision de la CNH.',
          ],
          en: [
            'Check that your Argentine license is valid, was issued more than 12 months ago, and is still inside the Brazilian usage window.',
            'Confirm with your state DETRAN which process applies to foreign licenses.',
            'Gather CPF, regular migration document, proof of address, the original license, and a sworn translation.',
            'If DETRAN asks for it, obtain a consular certificate/declaration for a South American license.',
            'Schedule an appointment at your state DETRAN.',
            'Take the exams required by your state. In general these include medical and psychological evaluation, and extra requirements may apply.',
            'Pay the fees and wait for the CNH to be issued.',
          ],
        ),
        requirements: _list(
          locale,
          pt: [
            'CPF',
            'RNM/RNE ou protocolo migratório aceito pelo DETRAN',
            'Comprovante de endereço',
            'Carteira de motorista argentina válida e emitida há mais de 12 meses',
            'Tradução juramentada da carteira',
            'Exames exigidos pelo DETRAN aprovados',
          ],
          es: [
            'CPF',
            'RNM/RNE o protocolo migratorio aceptado por el DETRAN',
            'Comprobante de domicilio',
            'Licencia de conducir argentina valida y emitida hace mas de 12 meses',
            'Traduccion jurada de la licencia',
            'Examenes exigidos por el DETRAN aprobados',
          ],
          en: [
            'CPF',
            'RNM/RNE or migration protocol accepted by DETRAN',
            'Proof of address',
            'Valid Argentine driver license issued more than 12 months ago',
            'Sworn translation of the license',
            'Approved DETRAN-required exams',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você já confirmou o procedimento do seu estado e iniciou corretamente a regularização da habilitação.',
          es: 'Ya confirmaste el procedimiento de tu estado e iniciaste correctamente la regularizacion de la licencia.',
          en: 'You have confirmed your state procedure and correctly started the license regularization process.',
        ),
        tips: _list(
          locale,
          pt: [
            'O processo varia bastante entre estados. Não comece por relatos genéricos; comece pelo DETRAN do seu estado.',
            'A tradução juramentada precisa ser feita por tradutor oficial registrado na junta comercial.',
            'Para Argentina e outros países da América do Sul, alguns estados podem pedir certidão/declaração consular além da tradução.',
          ],
          es: [
            'El proceso varia bastante entre estados. No empieces por relatos genericos; empieza por el DETRAN de tu estado.',
            'La traduccion jurada debe ser hecha por traductor oficial registrado.',
            'Para Argentina y otros paises de America del Sur, algunos estados pueden pedir certificado/declaracion consular ademas de la traduccion.',
          ],
          en: [
            'The process varies a lot by state. Do not start from generic advice; start with your state DETRAN.',
            'The sworn translation must be done by an official registered translator.',
            'For Argentina and other South American countries, some states may request a consular certificate/declaration in addition to the translation.',
          ],
        ),
        decisionOptions: [
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Regularizar a habilitação estrangeira',
              es: 'Regularizar la licencia extranjera',
              en: 'Regularize the foreign license',
            ),
            description: _t(
              locale,
              pt: 'É o caminho para quem já dirige e quer seguir o procedimento aceito pelo DETRAN do estado.',
              es: 'Es el camino para quien ya maneja y quiere seguir el procedimiento aceptado por el DETRAN del estado.',
              en: 'This is the route for someone who already drives and wants to follow the procedure accepted by the state DETRAN.',
            ),
            pros: _list(
              locale,
              pt: [
                'Aproveita sua habilitação atual',
                'Pode evitar parte do processo de primeira habilitação',
              ],
              es: [
                'Aprovecha tu licencia actual',
                'Puede evitar parte del proceso de primera licencia',
              ],
              en: [
                'Leverages your current license',
                'May avoid part of the first-license process',
              ],
            ),
            cons: _list(
              locale,
              pt: [
                'Depende das regras do seu estado',
                'Pode exigir documento consular, tradução e exames',
              ],
              es: [
                'Depende de las reglas de tu estado',
                'Puede exigir documento consular, traduccion y examenes',
              ],
              en: [
                'Depends on your state rules',
                'May require consular documents, translation, and exams',
              ],
            ),
            recommended: true,
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
        urgencyLevel: GuideUrgencyLevel.urgent,
        urgencySignal: _t(
          locale,
          pt: 'Organize isso logo nas primeiras semanas. Você não depende do cartão para urgência, mas não deve deixar sua cobertura básica para o fim.',
          es: 'Organiza esto en las primeras semanas. No dependes de la tarjeta para urgencias, pero no debes dejar tu cobertura basica para el final.',
          en: 'Organize this in your first weeks. You do not depend on the card for urgent care, but you should not leave your basic coverage setup to the end.',
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
              pt: ['Gratuito', 'Rede pública nacional'],
              es: ['Gratis', 'Red pública nacional'],
              en: ['Free', 'Nationwide public network'],
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
              pt: 'Mantém o acesso ao SUS e adiciona a rede contratada, sujeita a cobertura, carências e disponibilidade.',
              es: 'Mantiene el acceso al SUS y agrega la red contratada, sujeta a cobertura, carencias y disponibilidad.',
              en: 'Keeps access to SUS and adds a contracted network, subject to coverage, waiting periods, and availability.',
            ),
            pros: _list(
              locale,
              pt: ['Rede adicional', 'Opções conforme o contrato'],
              es: ['Red adicional', 'Opciones según el contrato'],
              en: ['Additional network', 'Contract-dependent options'],
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
          pt: 'Abrir registro oficial',
          es: 'Abrir registro oficial',
          en: 'Open official registration',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.rnMRegistrationGuide
            .toString(),
        steps: _list(
          locale,
          pt: [
            'Confirme se sua autorização de residência já foi deferida ou publicada.',
            'Abra o serviço oficial de registro de estrangeiro no Brasil.',
            'Preencha o pedido de registro, faça o agendamento e compareça à unidade da Polícia Federal.',
            'Depois, acompanhe a confecção da CRNM e agende a retirada quando o sistema liberar.',
          ],
          es: [
            'Confirma si tu autorizacion de residencia ya fue concedida o publicada.',
            'Abre el servicio oficial de registro de extranjero en Brasil.',
            'Completa el pedido de registro, agenda la cita y comparece en la unidad de la Policia Federal.',
            'Despues, sigue la confeccion de la CRNM y agenda el retiro cuando el sistema lo habilite.',
          ],
          en: [
            'Confirm that your residence authorization has already been granted or published.',
            'Open the official foreign registration service in Brazil.',
            'Submit the registration request, book the appointment, and attend the Federal Police unit.',
            'Then track CRNM production and book the pickup once the system allows it.',
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
            'O serviço oficial informa que o registro gera coleta biométrica, número RNM e depois a emissão da CRNM.',
            'Quando a autorização é deferida no Brasil, o registro costuma ter prazo próprio de 30 dias.',
            'A consulta de status da carteira acontece no sistema da PF antes da retirada.',
          ],
          es: [
            'El servicio oficial informa que el registro incluye biometria, numero RNM y luego la emision de la CRNM.',
            'Cuando la autorizacion se concede en Brasil, el registro suele tener un plazo propio de 30 dias.',
            'La consulta del estado de la tarjeta ocurre en el sistema de la PF antes del retiro.',
          ],
          en: [
            'The official service states that registration includes biometrics, the RNM number, and then CRNM issuance.',
            'When authorization is granted in Brazil, registration usually has its own 30-day deadline.',
            'Card status is checked in the PF system before pickup.',
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
          pt: 'Essa etapa só começa depois do deferimento da residência. Se a PF abrir a janela do registro, faça isso dentro do prazo.',
          es: 'Este paso solo empieza despues de la concesion de la residencia. Si la PF abre la ventana del registro, hazlo dentro del plazo.',
          en: 'This step only starts after residence is granted. If PF opens your registration window, complete it within the deadline.',
        ),
      ),
      GuideActionItem(
        id: 'item_4_3_permanencia',
        title: _t(
          locale,
          pt: 'Se sua rota for temporária, revise o vencimento',
          es: 'Si tu ruta es temporaria, revisa el vencimiento',
          en: 'If your route is temporary, review its expiry',
        ),
        shortDescription: _t(
          locale,
          pt: 'Esta etapa não se aplica a quem obteve residência permanente direta pelo acordo Brasil–Argentina.',
          es: 'Este paso no se aplica a quien obtuvo residencia permanente directa por el acuerdo Brasil–Argentina.',
          en: 'This step does not apply to people who obtained direct permanent residence under the Brazil–Argentina agreement.',
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
          pt: 'Só mantenha esta etapa no plano se o seu documento realmente indicar residência temporária. A regra e a transformação dependem da base legal usada.',
          es: 'Mantén este paso solo si tu documento realmente indica residencia temporaria. La regla y la transformación dependen de la base legal utilizada.',
          en: 'Keep this step only if your document actually states temporary residence. Rules and conversion depend on the legal basis used.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Tratar todas as residências como temporárias cria uma tarefa errada; ignorar o vencimento de um documento temporário também gera risco.',
          es: 'Tratar todas las residencias como temporarias crea una tarea incorrecta; ignorar el vencimiento de un documento temporario también genera riesgo.',
          en: 'Treating every residence as temporary creates a wrong task, while ignoring a real temporary expiry also creates risk.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Abrir serviço oficial',
          es: 'Abrir servicio oficial',
          en: 'Open official service',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks
            .argentinaResidenceAgreement
            .toString(),
        steps: _list(
          locale,
          pt: [
            'Verifique a data de vencimento da sua residência temporária.',
            'Abra o serviço oficial da PF e confirme a rota de residência por prazo indeterminado aplicável ao seu caso.',
            'Reúna os documentos exigidos, incluindo comprovante de endereço e documentos migratórios atualizados.',
            'Emita a GRU quando o serviço exigir, faça o agendamento e protocole o pedido dentro da janela oficial.',
            'Acompanhe o requerimento no sistema da PF e não deixe a residência temporária vencer antes de regularizar essa etapa.',
          ],
          es: [
            'Verifica la fecha de vencimiento de tu residencia temporaria.',
            'Abre el servicio oficial de la PF y confirma la ruta de residencia por plazo indeterminado aplicable a tu caso.',
            'Reune los documentos requeridos, incluyendo comprobante de domicilio y documentos migratorios actualizados.',
            'Emite la GRU cuando el servicio lo exija, agenda la cita y presenta la solicitud dentro de la ventana oficial.',
            'Sigue el requerimiento en el sistema de la PF y no dejes vencer la residencia temporaria antes de regularizar esta etapa.',
          ],
          en: [
            'Check the expiration date of your temporary residence.',
            'Open the official PF service and confirm the indefinite-term residence route that applies to your case.',
            'Gather the required documents, including proof of address and updated migration documents.',
            'Issue the GRU when the service requires it, book the appointment, and file within the official window.',
            'Track the request in the PF system and do not let the temporary residence expire before regularizing this step.',
          ],
        ),
        requirements: _list(
          locale,
          pt: [
            'CPF',
            'Residência temporária válida ou protocolo',
            'Comprovante de endereço atualizado',
            'Documentos migratórios atualizados',
            'GRU emitida e paga quando exigida pela PF',
          ],
          es: [
            'CPF',
            'Residencia temporaria valida o protocolo',
            'Comprobante de domicilio actualizado',
            'Documentos migratorios actualizados',
            'GRU emitida y pagada cuando la PF la exija',
          ],
          en: [
            'CPF',
            'Valid temporary residence or protocol',
            'Updated proof of address',
            'Updated migration documents',
            'GRU issued and paid when required by PF',
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
            'A rota e os documentos podem mudar conforme a base legal da sua residência. Confirme sempre no serviço oficial antes de protocolar.',
            'Acompanhe o protocolo pelo sistema da PF para não perder prazos.',
          ],
          es: [
            'Empieza a reunir documentos al menos 3 meses antes del vencimiento.',
            'La ruta y los documentos pueden cambiar segun la base legal de tu residencia. Confirma siempre en el servicio oficial antes de presentar la solicitud.',
            'Sigue el protocolo por el sistema de la PF para no perder plazos.',
          ],
          en: [
            'Start gathering documents at least 3 months before expiration.',
            'The route and required documents can change depending on the legal basis of your residence. Always confirm in the official service before filing.',
            'Track the protocol in the PF system to avoid missing deadlines.',
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
          pt: 'Prazo variável',
          es: 'Plazo variable',
          en: 'Timing varies',
        ),
        tier: GuideItemTier.optional,
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Polícia Federal · Imigração',
          sourceUrl: PreparationResourceLinks.federalPoliceMigration.toString(),
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'Dispense esta etapa se sua CRNM já indicar prazo indeterminado.',
            es: 'Descarta este paso si tu CRNM ya indica plazo indeterminado.',
            en: 'Dismiss this step if your CRNM already indicates an indefinite term.',
          ),
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
          pt: 'Verifique se MEI é permitido e adequado para sua atividade e situação fiscal.',
          es: 'Verifica si MEI está permitido y es adecuado para tu actividad y situación fiscal.',
          en: 'Check whether MEI is permitted and suitable for your activity and tax situation.',
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
          pt: 'MEI é apenas uma das formas de atuação. Atividade permitida, limite vigente, residência fiscal e renda do exterior mudam a decisão.',
          es: 'MEI es solo una forma de trabajar. La actividad permitida, el límite vigente, la residencia fiscal y los ingresos del exterior cambian la decisión.',
          en: 'MEI is only one work structure. Eligible activity, current limits, tax residence, and foreign income change the decision.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Abrir uma estrutura inadequada pode gerar declarações, impostos ou obrigações incorretas.',
          es: 'Abrir una estructura inadecuada puede generar declaraciones, impuestos u obligaciones incorrectas.',
          en: 'Opening the wrong structure can create incorrect filings, taxes, or obligations.',
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
          pt: 'Prazo variável',
          es: 'Plazo variable',
          en: 'Timing varies',
        ),
        communityTips: _list(
          locale,
          pt: [
            'Confirme no Portal do Empreendedor se sua atividade consta na lista vigente.',
            'O limite de receita e as obrigações podem mudar; não use um valor antigo como regra.',
            'Renda recebida da Argentina exige análise fiscal própria e não é automaticamente resolvida pela abertura de MEI.',
          ],
          es: [
            'Confirma en el Portal do Empreendedor si tu actividad está en la lista vigente.',
            'El límite de ingresos y las obligaciones pueden cambiar; no uses un valor antiguo como regla.',
            'Los ingresos desde Argentina requieren análisis fiscal propio y no se resuelven automáticamente abriendo MEI.',
          ],
          en: [
            'Confirm on the Entrepreneur Portal whether your activity is currently eligible.',
            'Revenue limits and obligations can change; do not treat an old value as a rule.',
            'Income received from Argentina needs its own tax analysis and is not automatically solved by opening MEI.',
          ],
        ),
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Portal do Empreendedor · MEI',
          sourceUrl:
              'https://www.gov.br/empresas-e-negocios/pt-br/empreendedor',
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'Movaro não calcula enquadramento ou tributos. Em caso de renda exterior, procure orientação contábil.',
            es: 'Movaro no calcula encuadre ni impuestos. Con ingresos del exterior, busca orientación contable.',
            en: 'Movaro does not calculate tax classification or liabilities. Seek accounting guidance for foreign income.',
          ),
        ),
      ),
      GuideActionItem(
        id: 'item_0_6_medicamentos',
        title: _t(
          locale,
          pt: 'Planeje medicamentos e receitas',
          es: 'Planifica medicamentos y recetas',
          en: 'Plan medicines and prescriptions',
        ),
        shortDescription: _t(
          locale,
          pt: 'Confirme as regras da Anvisa antes de viajar, principalmente para medicamentos controlados.',
          es: 'Confirma las reglas de Anvisa antes de viajar, especialmente para medicamentos controlados.',
          en: 'Confirm Anvisa rules before travel, especially for controlled medicines.',
        ),
        type: GuideActionType.external,
        phase: GuidePhase.preparation,
        orderIndex: 6,
        isCompleted: false,
        icon: Icons.medication_outlined,
        primaryActionLabel: _t(
          locale,
          pt: 'Ver regras da Anvisa',
          es: 'Ver reglas de Anvisa',
          en: 'See Anvisa rules',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.medicationTravelGuide
            .toString(),
        steps: _list(
          locale,
          pt: [
            'Liste os medicamentos de uso contínuo e confira se algum é controlado.',
            'Leve receita e documentação médica compatíveis com a quantidade transportada.',
            'Para controlados, abra também a orientação específica da Anvisa antes da compra da passagem.',
          ],
          es: [
            'Lista los medicamentos de uso continuo y verifica si alguno es controlado.',
            'Lleva receta y documentación médica compatible con la cantidad transportada.',
            'Para controlados, abre también la orientación específica de Anvisa antes de comprar el pasaje.',
          ],
          en: [
            'List ongoing medicines and check whether any are controlled.',
            'Carry a prescription and medical documentation matching the quantity transported.',
            'For controlled medicines, open Anvisa’s specific guidance before buying travel.',
          ],
        ),
        supportLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Medicamentos controlados',
              es: 'Medicamentos controlados',
              en: 'Controlled medicines',
            ),
            url: PreparationResourceLinks.controlledMedicationGuide.toString(),
          ),
        ],
        doneCriteria: _t(
          locale,
          pt: 'Você confirmou as regras e separou receita, laudo e quantidade compatível.',
          es: 'Confirmaste las reglas y separaste receta, informe y cantidad compatible.',
          en: 'You confirmed the rules and prepared prescriptions, reports, and an appropriate quantity.',
        ),
        preArrivalRequired: true,
        tier: GuideItemTier.recommended,
        applicabilityConditions: const <String>['continuous_medication'],
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Anvisa · Regras de bagagem',
          sourceUrl: PreparationResourceLinks.medicationTravelGuide.toString(),
          lastVerified: DateTime(2026, 7, 26),
        ),
      ),
      GuideActionItem(
        id: 'item_1_5_animais',
        title: _t(
          locale,
          pt: 'Se viajar com pet, prepare a entrada',
          es: 'Si viajas con mascota, prepara el ingreso',
          en: 'If traveling with a pet, prepare entry',
        ),
        shortDescription: _t(
          locale,
          pt: 'Cães e gatos precisam cumprir requisitos sanitários antes do embarque.',
          es: 'Perros y gatos deben cumplir requisitos sanitarios antes de embarcar.',
          en: 'Dogs and cats must meet health requirements before boarding.',
        ),
        type: GuideActionType.external,
        phase: GuidePhase.preparation,
        orderIndex: 7,
        isCompleted: false,
        icon: Icons.pets_outlined,
        primaryActionLabel: _t(
          locale,
          pt: 'Ver exigências oficiais',
          es: 'Ver requisitos oficiales',
          en: 'See official requirements',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.petEntryGuide.toString(),
        steps: _list(
          locale,
          pt: [
            'Confirme vacina, tratamento antiparasitário e certificado exigidos para a data da viagem.',
            'Valide também as regras da companhia aérea e do aeroporto.',
            'Não embarque usando somente exigências antigas salvas em redes sociais.',
          ],
          es: [
            'Confirma vacuna, tratamiento antiparasitario y certificado exigidos para la fecha del viaje.',
            'Valida también las reglas de la aerolínea y del aeropuerto.',
            'No viajes usando solo requisitos antiguos guardados de redes sociales.',
          ],
          en: [
            'Confirm vaccination, parasite treatment, and certificate requirements for your travel date.',
            'Also check airline and airport rules.',
            'Do not travel relying only on old social-media checklists.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Documentos sanitários e aceite da transportadora estão confirmados.',
          es: 'La documentación sanitaria y la aceptación del transportista están confirmadas.',
          en: 'Health documents and carrier acceptance are confirmed.',
        ),
        preArrivalRequired: true,
        tier: GuideItemTier.optional,
        applicabilityConditions: const <String>['traveling_with_pet'],
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Ministério da Agricultura · Entrada de cães e gatos',
          sourceUrl: PreparationResourceLinks.petEntryGuide.toString(),
          lastVerified: DateTime(2026, 7, 26),
        ),
      ),
      GuideActionItem(
        id: 'item_2_6_impostos_exterior',
        title: _t(
          locale,
          pt: 'Entenda residência fiscal e renda do exterior',
          es: 'Entiende residencia fiscal e ingresos del exterior',
          en: 'Understand tax residence and foreign income',
        ),
        shortDescription: _t(
          locale,
          pt: 'Mudar de país e continuar recebendo da Argentina pode criar obrigações tributárias próprias.',
          es: 'Mudarte de país y seguir cobrando desde Argentina puede crear obligaciones fiscales propias.',
          en: 'Moving countries while receiving income from Argentina can create specific tax obligations.',
        ),
        type: GuideActionType.external,
        phase: GuidePhase.documents,
        orderIndex: 11,
        isCompleted: false,
        icon: Icons.receipt_long_outlined,
        primaryActionLabel: _t(
          locale,
          pt: 'Ver orientação da Receita',
          es: 'Ver orientación de Receita',
          en: 'See Receita guidance',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.foreignIncomeTaxGuide
            .toString(),
        whyItMatters: _t(
          locale,
          pt: 'MEI, conta brasileira ou nota fiscal não resolvem automaticamente a tributação de renda recebida no exterior.',
          es: 'MEI, una cuenta brasileña o una factura no resuelven automáticamente la tributación de ingresos del exterior.',
          en: 'MEI, a Brazilian account, or an invoice does not automatically settle taxation of foreign income.',
        ),
        steps: _list(
          locale,
          pt: [
            'Anote data de chegada, fontes de renda e países pagadores.',
            'Leia as regras oficiais de rendimentos recebidos do exterior.',
            'Se houver renda, patrimônio ou empresa nos dois países, procure contador com experiência internacional.',
          ],
          es: [
            'Anota fecha de llegada, fuentes de ingreso y países pagadores.',
            'Lee las reglas oficiales sobre ingresos recibidos del exterior.',
            'Si tienes ingresos, patrimonio o empresa en ambos países, busca un contador con experiencia internacional.',
          ],
          en: [
            'Record arrival date, income sources, and paying countries.',
            'Read the official rules for income received from abroad.',
            'If you have income, assets, or businesses in both countries, seek cross-border accounting advice.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você registrou sua situação e sabe se precisa de análise contábil individual.',
          es: 'Registraste tu situación y sabes si necesitas análisis contable individual.',
          en: 'You documented your situation and know whether individual accounting analysis is needed.',
        ),
        tier: GuideItemTier.recommended,
        applicabilityConditions: const <String>['foreign_income'],
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Receita Federal · Rendimentos do exterior',
          sourceUrl: PreparationResourceLinks.foreignIncomeTaxGuide.toString(),
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'Conteúdo educativo; não é cálculo nem consultoria tributária.',
            es: 'Contenido educativo; no es cálculo ni asesoría tributaria.',
            en: 'Educational content; not a tax calculation or tax advice.',
          ),
        ),
      ),
      GuideActionItem(
        id: 'item_3_6_familia_escola',
        title: _t(
          locale,
          pt: 'Organize matrícula e rotina das crianças',
          es: 'Organiza matrícula y rutina de los niños',
          en: 'Organize children’s enrollment and routine',
        ),
        shortDescription: _t(
          locale,
          pt: 'Crianças e adolescentes migrantes têm direito à matrícula; confira a rede local e os documentos disponíveis.',
          es: 'Niños y adolescentes migrantes tienen derecho a matrícula; revisa la red local y los documentos disponibles.',
          en: 'Migrant children and adolescents have a right to enrollment; check the local network and available documents.',
        ),
        type: GuideActionType.external,
        phase: GuidePhase.arrival,
        orderIndex: 19,
        isCompleted: false,
        icon: Icons.school_outlined,
        primaryActionLabel: _t(
          locale,
          pt: 'Ver orientação oficial',
          es: 'Ver orientación oficial',
          en: 'See official guidance',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.familySchoolGuide
            .toString(),
        steps: _list(
          locale,
          pt: [
            'Localize a Secretaria de Educação do município escolhido.',
            'Separe identidade, histórico escolar e comprovante de endereço que você tiver.',
            'Se faltar documento, peça à rede orientação formal em vez de desistir da matrícula.',
          ],
          es: [
            'Ubica la Secretaría de Educación del municipio elegido.',
            'Separa identidad, historial escolar y comprobante de domicilio que tengas.',
            'Si falta un documento, pide orientación formal a la red en vez de abandonar la matrícula.',
          ],
          en: [
            'Find the chosen municipality’s Education Department.',
            'Prepare identity, school records, and any proof of address you have.',
            'If a document is missing, request formal guidance instead of abandoning enrollment.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'A rede de ensino e o caminho de matrícula estão identificados.',
          es: 'La red educativa y el camino de matrícula están identificados.',
          en: 'The education network and enrollment path are identified.',
        ),
        costInfo: _t(
          locale,
          pt: 'Rede pública: sem mensalidade. Escola particular, uniforme, material e transporte: valores variáveis.',
          es: 'Red pública: sin mensualidad. Escuela privada, uniforme, materiales y transporte: valores variables.',
          en: 'Public network: no tuition. Private school, uniforms, supplies, and transport: variable.',
        ),
        tier: GuideItemTier.recommended,
        applicabilityConditions: const <String>['family_with_kids'],
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Conselho Nacional de Educação · Matrícula de migrantes',
          sourceUrl: PreparationResourceLinks.familySchoolGuide.toString(),
          lastVerified: DateTime(2026, 7, 26),
        ),
      ),
      GuideActionItem(
        id: 'item_4_7_seguranca_emergencia',
        title: _t(
          locale,
          pt: 'Salve contatos de emergência e apoio',
          es: 'Guarda contactos de emergencia y apoyo',
          en: 'Save emergency and support contacts',
        ),
        shortDescription: _t(
          locale,
          pt: 'Tenha polícia, saúde, bombeiros e consulado acessíveis offline.',
          es: 'Ten policía, salud, bomberos y consulado disponibles sin conexión.',
          en: 'Keep police, health, fire, and consular contacts available offline.',
        ),
        type: GuideActionType.checklist,
        phase: GuidePhase.arrival,
        orderIndex: 20,
        isCompleted: false,
        icon: Icons.health_and_safety_outlined,
        dependencies: const <String>['item_1_1_chip'],
        checklistItems: [
          ChecklistSubItem(
            id: 'emergency_190',
            title: _t(
              locale,
              pt: 'Polícia: 190',
              es: 'Policía: 190',
              en: 'Police: 190',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'emergency_192',
            title: _t(
              locale,
              pt: 'SAMU: 192',
              es: 'SAMU: 192',
              en: 'Ambulance (SAMU): 192',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'emergency_193',
            title: _t(
              locale,
              pt: 'Bombeiros: 193',
              es: 'Bomberos: 193',
              en: 'Fire service: 193',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'emergency_consulate',
            title: _t(
              locale,
              pt: 'Consulado argentino mais próximo salvo',
              es: 'Consulado argentino más cercano guardado',
              en: 'Nearest Argentine consulate saved',
            ),
            isCompleted: false,
          ),
        ],
        supportLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Consulados argentinos no Brasil',
              es: 'Consulados argentinos en Brasil',
              en: 'Argentine consulates in Brazil',
            ),
            url: PreparationResourceLinks.argentinaConsulatesBrazil.toString(),
          ),
        ],
        doneCriteria: _t(
          locale,
          pt: 'Os contatos estão salvos no aparelho e disponíveis sem internet.',
          es: 'Los contactos están guardados en el teléfono y disponibles sin internet.',
          en: 'Contacts are saved on the device and available offline.',
        ),
        tier: GuideItemTier.recommended,
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Governo do Brasil e Consulado da Argentina',
          sourceUrl: PreparationResourceLinks.argentinaConsulatesBrazil
              .toString(),
          lastVerified: DateTime(2026, 7, 26),
        ),
      ),
    ];

    if (plan.goal == 'study') {
      items.addAll([
        GuideActionItem(
          id: 'item_0_7_ingresso_ensino_superior',
          title: _t(
            locale,
            pt: 'Defina sua rota de ingresso na universidade',
            es: 'Define tu vía de ingreso a la universidad',
            en: 'Choose your university admission route',
          ),
          shortDescription: _t(
            locale,
            pt: 'Compare Enem/Sisu, vestibular próprio, transferência e programas internacionais antes de organizar a mudança.',
            es: 'Compara Enem/Sisu, examen propio, transferencia y programas internacionales antes de organizar la mudanza.',
            en: 'Compare Enem/Sisu, institution exams, transfer, and international programs before organizing the move.',
          ),
          type: GuideActionType.external,
          phase: GuidePhase.preparation,
          orderIndex: 7,
          isCompleted: false,
          icon: Icons.account_balance_outlined,
          primaryActionLabel: _t(
            locale,
            pt: 'Consultar o Sisu',
            es: 'Consultar Sisu',
            en: 'Check Sisu',
          ),
          primaryActionType: GuidePrimaryActionType.external,
          primaryActionTarget: PreparationResourceLinks.sisuGuide.toString(),
          steps: _list(
            locale,
            pt: [
              'Escolha curso, nível e instituições possíveis.',
              'Confira se o ingresso é por Enem/Sisu, vestibular, transferência ou edital internacional.',
              'Se considerar o PEC-G, valide país elegível, calendário, proficiência e comprovação financeira no edital vigente.',
              'Compare mensalidade zero ou privada com moradia, alimentação, transporte e material.',
            ],
            es: [
              'Elige carrera, nivel e instituciones posibles.',
              'Confirma si el ingreso es por Enem/Sisu, examen, transferencia o convocatoria internacional.',
              'Si consideras PEC-G, valida país elegible, calendario, idioma y respaldo financiero en la convocatoria vigente.',
              'Compara matrícula gratuita o privada con vivienda, comida, transporte y materiales.',
            ],
            en: [
              'Choose the course, level, and possible institutions.',
              'Check whether admission uses Enem/Sisu, an exam, transfer, or an international call.',
              'If considering PEC-G, verify eligible country, schedule, language, and financial proof in the current call.',
              'Compare tuition-free or private study with housing, food, transport, and supplies.',
            ],
          ),
          doneCriteria: _t(
            locale,
            pt: 'Você escolheu uma rota de ingresso e registrou os prazos oficiais.',
            es: 'Elegiste una vía de ingreso y registraste los plazos oficiales.',
            en: 'You selected an admission route and recorded official deadlines.',
          ),
          costInfo: _t(
            locale,
            pt: 'Instituição pública: sem mensalidade. Instituição privada e despesas de permanência: valores variáveis.',
            es: 'Institución pública: sin mensualidad. Institución privada y gastos de vida: valores variables.',
            en: 'Public institution: no tuition. Private institution and living costs: variable.',
          ),
          supportLinks: [
            GuideSupportLink(
              label: 'PEC-G',
              url: PreparationResourceLinks.pecGGuide.toString(),
            ),
            GuideSupportLink(
              label: 'e-MEC',
              url: PreparationResourceLinks.publicUniversitiesCatalog
                  .toString(),
            ),
          ],
          tier: GuideItemTier.critical,
          preArrivalRequired: true,
          applicabilityConditions: const <String>['study_goal'],
          evidence: GuideEvidence(
            type: GuideEvidenceType.official,
            sourceLabel: 'MEC · Sisu',
            sourceUrl: PreparationResourceLinks.sisuGuide.toString(),
            lastVerified: DateTime(2026, 7, 28),
            scopeNote: _t(
              locale,
              pt: 'Cada edição e instituição pode ter calendário e documentos próprios.',
              es: 'Cada edición e institución puede tener calendario y documentos propios.',
              en: 'Each edition and institution may set its own schedule and documents.',
            ),
          ),
        ),
        GuideActionItem(
          id: 'item_2_7_documentos_academicos',
          title: _t(
            locale,
            pt: 'Prepare a documentação acadêmica para matrícula',
            es: 'Prepara la documentación académica para matricularte',
            en: 'Prepare academic enrollment documents',
          ),
          shortDescription: _t(
            locale,
            pt: 'O edital pode exigir conclusão do ensino médio, histórico, identificação, tradução, apostila e proficiência.',
            es: 'La convocatoria puede exigir título secundario, historial, identificación, traducción, apostilla e idioma.',
            en: 'Admission rules may require secondary completion, transcripts, identity, translations, apostilles, and language proficiency.',
          ),
          type: GuideActionType.checklist,
          phase: GuidePhase.documents,
          orderIndex: 12,
          isCompleted: false,
          icon: Icons.history_edu_outlined,
          checklistItems: [
            ChecklistSubItem(
              id: 'study_secondary_certificate',
              title: _t(
                locale,
                pt: 'Certificado de conclusão do ensino médio',
                es: 'Certificado de finalización de la secundaria',
                en: 'Secondary-school completion certificate',
              ),
              isCompleted: false,
            ),
            ChecklistSubItem(
              id: 'study_transcript',
              title: _t(
                locale,
                pt: 'Histórico escolar ou acadêmico',
                es: 'Historial escolar o académico',
                en: 'School or academic transcript',
              ),
              isCompleted: false,
            ),
            ChecklistSubItem(
              id: 'study_notice_requirements',
              title: _t(
                locale,
                pt: 'Exigências de tradução, apostila e proficiência conferidas no edital',
                es: 'Requisitos de traducción, apostilla e idioma revisados en la convocatoria',
                en: 'Translation, apostille, and language rules checked in the official call',
              ),
              isCompleted: false,
            ),
          ],
          primaryActionLabel: _t(
            locale,
            pt: 'Ver opções para estrangeiros',
            es: 'Ver opciones para extranjeros',
            en: 'See options for foreign students',
          ),
          primaryActionType: GuidePrimaryActionType.external,
          primaryActionTarget: PreparationResourceLinks.foreignStudentGuide
              .toString(),
          doneCriteria: _t(
            locale,
            pt: 'A lista da instituição foi conferida e os documentos necessários estão preparados ou solicitados.',
            es: 'Revisaste la lista de la institución y preparaste o solicitaste los documentos necesarios.',
            en: 'You checked the institution’s list and prepared or requested the required documents.',
          ),
          tier: GuideItemTier.critical,
          preArrivalRequired: true,
          applicabilityConditions: const <String>['study_goal'],
          evidence: GuideEvidence(
            type: GuideEvidenceType.official,
            sourceLabel: 'Governo do Brasil · Estudar no ensino superior',
            sourceUrl: PreparationResourceLinks.foreignStudentGuide.toString(),
            lastVerified: DateTime(2026, 7, 28),
          ),
        ),
      ]);
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

    items.addAll(_reviewAdditions(locale));
    items.addAll(_settlingAdditions(locale));

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
        .map((item) => _applySafetyReview(item, locale))
        .map(_applyExecutionSchedule)
        .toList(growable: false);
  }

  static List<GuideActionItem> _reviewAdditions(String locale) {
    return [
      GuideActionItem(
        id: 'item_0_2_document_folder',
        title: _t(
          locale,
          pt: 'Monte sua pasta migratória',
          es: 'Arma tu carpeta migratoria',
          en: 'Build your migration document folder',
        ),
        shortDescription: _t(
          locale,
          pt: 'Reúna a documentação civil e confira as regras antes de viajar.',
          es: 'Reúne la documentación civil y revisa las reglas antes de viajar.',
          en: 'Gather civil records and confirm the rules before traveling.',
        ),
        type: GuideActionType.external,
        phase: GuidePhase.preparation,
        orderIndex: 1,
        isCompleted: false,
        icon: Icons.folder_copy_outlined,
        primaryActionLabel: _t(
          locale,
          pt: 'Ver documentos oficiais',
          es: 'Ver documentos oficiales',
          en: 'See official documents',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks
            .argentinaResidenceAgreement
            .toString(),
        context: _t(
          locale,
          pt: 'O acordo Brasil–Argentina tem uma lista própria. Não use uma checklist genérica de redes sociais.',
          es: 'El acuerdo Brasil–Argentina tiene una lista propia. No uses una lista genérica de redes sociales.',
          en: 'The Brazil–Argentina agreement has its own list. Do not rely on a generic social-media checklist.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Filiação ausente no documento, certidões de outros países ou formalidades documentais podem deixar o pedido incompleto.',
          es: 'La falta de filiación, certificados de otros países o formalidades documentales pueden dejar la solicitud incompleta.',
          en: 'Missing parentage, certificates from other countries, or document formalities can leave the application incomplete.',
        ),
        steps: _list(
          locale,
          pt: [
            'Abra a lista vigente do acordo Brasil–Argentina.',
            'Confira se seu DNI ou passaporte mostra filiação; se não mostrar, separe certidão de nascimento, casamento ou certidão consular.',
            'Liste todos os países onde viveu nos cinco anos anteriores para identificar os antecedentes exigidos.',
            'Separe o comprovante de entrada, a declaração pessoal exigida e os comprovantes de taxas quando aplicáveis.',
            'Confirme apostilamento, legalização e tradução para o uso específico do documento; a dispensa migratória de tradução não vale automaticamente para outros usos.',
          ],
          es: [
            'Abre la lista vigente del acuerdo Brasil–Argentina.',
            'Revisa si tu DNI o pasaporte muestra filiación; si no, separa partida de nacimiento, matrimonio o certificado consular.',
            'Lista todos los países donde viviste en los cinco años anteriores para identificar los antecedentes exigidos.',
            'Separa el comprobante de entrada, la declaración personal exigida y los comprobantes de tasas cuando correspondan.',
            'Confirma apostilla, legalización y traducción para el uso específico; la exención migratoria de traducción no se extiende automáticamente a otros usos.',
          ],
          en: [
            'Open the current Brazil–Argentina agreement checklist.',
            'Check whether your ID or passport shows parentage; otherwise prepare a birth, marriage, or consular certificate.',
            'List every country where you lived in the previous five years to identify required criminal records.',
            'Prepare entry proof, the required personal declaration, and fee receipts when applicable.',
            'Confirm apostille, legalization, and translation for the document’s specific use; the migration translation waiver does not automatically extend to other uses.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Sua pasta corresponde à lista oficial vigente e cobre todos os países onde você viveu nos últimos cinco anos.',
          es: 'Tu carpeta coincide con la lista oficial vigente y cubre todos los países donde viviste en los últimos cinco años.',
          en: 'Your folder matches the current official list and covers every country where you lived in the last five years.',
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'folder_identity_parentage',
            title: _t(
              locale,
              pt: 'Identidade e comprovação de filiação conferidas',
              es: 'Identidad y comprobación de filiación revisadas',
              en: 'Identity and parentage evidence checked',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'folder_countries',
            title: _t(
              locale,
              pt: 'Países de residência dos últimos cinco anos listados',
              es: 'Países de residencia de los últimos cinco años listados',
              en: 'Countries of residence from the last five years listed',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'folder_formalities',
            title: _t(
              locale,
              pt: 'Regras de legalização e tradução confirmadas',
              es: 'Reglas de legalización y traducción confirmadas',
              en: 'Legalization and translation rules confirmed',
            ),
            isCompleted: false,
          ),
        ],
        preArrivalRequired: true,
        urgencyLevel: GuideUrgencyLevel.critical,
        tier: GuideItemTier.critical,
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Polícia Federal · Acordo Brasil–Argentina',
          sourceUrl: PreparationResourceLinks.argentinaResidenceAgreement
              .toString(),
          lastVerified: DateTime(2026, 7, 26),
        ),
        externalOfficialLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Lista do acordo Brasil–Argentina',
              es: 'Lista del acuerdo Brasil–Argentina',
              en: 'Brazil–Argentina agreement checklist',
            ),
            url: PreparationResourceLinks.argentinaResidenceAgreement
                .toString(),
          ),
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Legalização e tradução',
              es: 'Legalización y traducción',
              en: 'Legalization and translation',
            ),
            url: PreparationResourceLinks.migrationDocumentRules.toString(),
          ),
        ],
      ),
      GuideActionItem(
        id: 'item_1_0_entry_proof',
        title: _t(
          locale,
          pt: 'Guarde a prova da sua entrada no Brasil',
          es: 'Guarda la prueba de tu entrada a Brasil',
          en: 'Keep proof of your entry into Brazil',
        ),
        shortDescription: _t(
          locale,
          pt: 'A data de entrada é usada em etapas migratórias e de trânsito.',
          es: 'La fecha de entrada se usa en trámites migratorios y de tránsito.',
          en: 'Your entry date is used in migration and driving procedures.',
        ),
        type: GuideActionType.checklist,
        phase: GuidePhase.arrival,
        orderIndex: 8,
        isCompleted: false,
        icon: Icons.login_rounded,
        steps: _list(
          locale,
          pt: [
            'Guarde o comprovante migratório recebido na entrada, quando houver.',
            'Registre a data exata de entrada e mantenha cópia offline.',
            'Guarde também passagem, cartão de embarque ou outro documento que ajude a comprovar a data.',
          ],
          es: [
            'Guarda el comprobante migratorio recibido al ingresar, cuando exista.',
            'Registra la fecha exacta de entrada y conserva una copia sin conexión.',
            'Guarda también pasaje, tarjeta de embarque u otro documento que ayude a probar la fecha.',
          ],
          en: [
            'Keep the immigration receipt received at entry, when available.',
            'Record the exact entry date and keep an offline copy.',
            'Also keep the ticket, boarding pass, or another document that helps prove the date.',
          ],
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'entry_date',
            title: _t(
              locale,
              pt: 'Data de entrada registrada',
              es: 'Fecha de entrada registrada',
              en: 'Entry date recorded',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'entry_copy',
            title: _t(
              locale,
              pt: 'Comprovante salvo offline',
              es: 'Comprobante guardado sin conexión',
              en: 'Proof saved offline',
            ),
            isCompleted: false,
          ),
        ],
        urgencyLevel: GuideUrgencyLevel.urgent,
        tier: GuideItemTier.critical,
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Polícia Federal · Acordo Brasil–Argentina',
          sourceUrl: PreparationResourceLinks.argentinaResidenceAgreement
              .toString(),
          lastVerified: DateTime(2026, 7, 26),
        ),
      ),
      GuideActionItem(
        id: 'item_2_1_govbr',
        title: _t(
          locale,
          pt: 'Crie e proteja sua conta Gov.br',
          es: 'Crea y protege tu cuenta Gov.br',
          en: 'Create and secure your Gov.br account',
        ),
        shortDescription: _t(
          locale,
          pt: 'Depois do CPF, esse login abre os principais serviços digitais.',
          es: 'Después del CPF, este acceso abre los principales servicios digitales.',
          en: 'After CPF, this login unlocks key digital public services.',
        ),
        type: GuideActionType.external,
        phase: GuidePhase.documents,
        orderIndex: 10,
        isCompleted: false,
        icon: Icons.verified_user_outlined,
        dependencies: const <String>['item_2_1_cpf'],
        primaryActionLabel: _t(
          locale,
          pt: 'Criar conta Gov.br',
          es: 'Crear cuenta Gov.br',
          en: 'Create Gov.br account',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.govBrAccountGuide
            .toString(),
        steps: _list(
          locale,
          pt: [
            'Crie a conta usando seu CPF.',
            'Confirme e-mail e telefone aos quais você continuará tendo acesso.',
            'Ative a verificação em duas etapas e guarde os meios de recuperação.',
            'Aumente o nível da conta apenas quando o serviço que você precisa exigir.',
          ],
          es: [
            'Crea la cuenta usando tu CPF.',
            'Confirma correo y teléfono a los que seguirás teniendo acceso.',
            'Activa la verificación en dos pasos y guarda los medios de recuperación.',
            'Aumenta el nivel de la cuenta solo cuando el servicio que necesitas lo exija.',
          ],
          en: [
            'Create the account using your CPF.',
            'Confirm an email and phone number you will continue to access.',
            'Enable two-step verification and keep recovery methods.',
            'Increase the account level only when a service you need requires it.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você entra na conta com segurança e consegue recuperar o acesso.',
          es: 'Puedes entrar de forma segura y recuperar el acceso.',
          en: 'You can sign in securely and recover access.',
        ),
        tier: GuideItemTier.recommended,
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Gov.br · Criar sua conta',
          sourceUrl: PreparationResourceLinks.govBrAccountGuide.toString(),
          lastVerified: DateTime(2026, 7, 26),
        ),
      ),
      GuideActionItem(
        id: 'item_3_4_work_rights',
        title: _t(
          locale,
          pt: 'Conheça seus direitos e evite vagas falsas',
          es: 'Conoce tus derechos y evita ofertas falsas',
          en: 'Know your rights and avoid fake jobs',
        ),
        shortDescription: _t(
          locale,
          pt: 'Use canais oficiais e reconheça cobranças ou propostas abusivas.',
          es: 'Usa canales oficiales y reconoce cobros o propuestas abusivas.',
          en: 'Use official channels and recognize abusive fees or offers.',
        ),
        type: GuideActionType.external,
        phase: GuidePhase.work,
        orderIndex: 18,
        isCompleted: false,
        icon: Icons.shield_outlined,
        applicabilityConditions: const <String>['income_strategy_goal'],
        primaryActionLabel: _t(
          locale,
          pt: 'Abrir serviços do trabalhador',
          es: 'Abrir servicios del trabajador',
          en: 'Open worker services',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.migrantWorkerGuide
            .toString(),
        steps: _list(
          locale,
          pt: [
            'Use Carteira de Trabalho Digital, Emprega Brasil ou SINE para consultar vagas públicas.',
            'Não pague para participar de seleção ou receber promessa de contratação.',
            'Não entregue senha, código de autenticação nem documento original para retenção.',
            'Antes de aceitar trabalho informal, entenda remuneração, jornada, local e responsável.',
          ],
          es: [
            'Usa Carteira de Trabalho Digital, Emprega Brasil o SINE para consultar vacantes públicas.',
            'No pagues para participar de una selección ni por una promesa de contratación.',
            'No entregues contraseña, código de autenticación ni documento original para retención.',
            'Antes de aceptar trabajo informal, entiende pago, jornada, lugar y responsable.',
          ],
          en: [
            'Use Digital Work Card, Emprega Brasil, or SINE to browse public listings.',
            'Do not pay to join a selection process or receive a job promise.',
            'Do not hand over passwords, authentication codes, or original documents for retention.',
            'Before accepting informal work, understand pay, hours, location, and the responsible party.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você conhece um canal oficial de vagas e os principais sinais de fraude.',
          es: 'Conoces un canal oficial de empleo y las principales señales de fraude.',
          en: 'You know an official job channel and the main fraud warning signs.',
        ),
        tier: GuideItemTier.recommended,
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Ministério do Trabalho e Emprego',
          sourceUrl: PreparationResourceLinks.migrantWorkerGuide.toString(),
          lastVerified: DateTime(2026, 7, 26),
        ),
      ),
      GuideActionItem(
        id: 'item_3_4_formal_work_ready',
        title: _t(
          locale,
          pt: 'Confirme que você pode iniciar o trabalho formal',
          es: 'Confirma que puedes iniciar el trabajo formal',
          en: 'Confirm you can start formal work',
        ),
        shortDescription: _t(
          locale,
          pt: 'Antes da contratação, confira situação migratória, CPF e acesso aos registros trabalhistas.',
          es: 'Antes de la contratación, revisa situación migratoria, CPF y acceso a los registros laborales.',
          en: 'Before hiring, confirm migration status, CPF, and access to employment records.',
        ),
        type: GuideActionType.checklist,
        phase: GuidePhase.work,
        orderIndex: 19,
        isCompleted: false,
        icon: Icons.fact_check_outlined,
        dependencies: const <String>['item_2_1_cpf', 'item_2_2_residencia'],
        applicabilityConditions: const <String>['formal_work_goal'],
        steps: _list(
          locale,
          pt: [
            'Confirme que sua autorização ou situação migratória permite exercer atividade remunerada.',
            'Confirme que o CPF está regular.',
            'Acesse a CTPS Digital pelo Gov.br e confira seus dados.',
            'Antes de começar, confirme empregador, função, remuneração, jornada e local por escrito.',
            'Depois da contratação, acompanhe o vínculo registrado pelo empregador.',
          ],
          es: [
            'Confirma que tu autorización o situación migratoria permite actividad remunerada.',
            'Confirma que el CPF está regular.',
            'Accede a la CTPS Digital con Gov.br y revisa tus datos.',
            'Antes de empezar, confirma empleador, función, remuneración, jornada y lugar por escrito.',
            'Después de la contratación, controla el vínculo registrado por el empleador.',
          ],
          en: [
            'Confirm your authorization or migration status permits paid work.',
            'Confirm your CPF is regular.',
            'Access the Digital Work Card through Gov.br and check your data.',
            'Before starting, confirm the employer, role, pay, hours, and workplace in writing.',
            'After hiring, monitor the employment relationship registered by the employer.',
          ],
        ),
        requirements: _list(
          locale,
          pt: [
            'Situação migratória que permita trabalho',
            'CPF regular',
            'Acesso ao Gov.br e à CTPS Digital',
          ],
          es: [
            'Situación migratoria que permita trabajar',
            'CPF regular',
            'Acceso a Gov.br y CTPS Digital',
          ],
          en: [
            'Migration status that permits work',
            'Regular CPF',
            'Access to Gov.br and the Digital Work Card',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você confirmou os requisitos, entende as condições da vaga e consegue acompanhar o registro do vínculo.',
          es: 'Confirmaste los requisitos, entiendes las condiciones de la vacante y puedes controlar el registro laboral.',
          en: 'You confirmed the requirements, understand the job terms, and can monitor the employment registration.',
        ),
        blockingReason: _t(
          locale,
          pt: 'Para liberar esta etapa, conclua CPF e residência. A pesquisa de vagas e a preparação do currículo continuam disponíveis antes disso.',
          es: 'Para liberar este paso, completa CPF y residencia. La búsqueda de vacantes y la preparación del CV siguen disponibles antes.',
          en: 'To unlock this step, complete CPF and residence. Job research and CV preparation remain available beforehand.',
        ),
        tier: GuideItemTier.critical,
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Ministério do Trabalho e Emprego · Migrantes',
          sourceUrl: PreparationResourceLinks.migrantWorkerGuide.toString(),
          lastVerified: DateTime(2026, 7, 29),
        ),
      ),
      GuideActionItem(
        id: 'item_0_7_family_documents',
        title: _t(
          locale,
          pt: 'Prepare os documentos da mudança com crianças',
          es: 'Prepara los documentos de la mudanza con niños',
          en: 'Prepare documents for moving with children',
        ),
        shortDescription: _t(
          locale,
          pt: 'Organize viagem, filiação, guarda, saúde e histórico escolar antes do embarque.',
          es: 'Organiza viaje, filiación, custodia, salud e historial escolar antes de viajar.',
          en: 'Organize travel, parentage, custody, health, and school records before departure.',
        ),
        type: GuideActionType.checklist,
        phase: GuidePhase.preparation,
        orderIndex: 7,
        isCompleted: false,
        icon: Icons.family_restroom_outlined,
        applicabilityConditions: const <String>['family_with_kids'],
        steps: _list(
          locale,
          pt: [
            'Confira as autorizações de viagem e residência exigidas para cada criança e responsável.',
            'Separe certidão de nascimento, documentos dos responsáveis e decisões de guarda quando existirem.',
            'Leve histórico escolar e carteira de vacinação disponíveis.',
            'Guarde contatos e autorizações em versão física e offline.',
          ],
          es: [
            'Revisa las autorizaciones de viaje y residencia exigidas para cada niño y responsable.',
            'Separa partida de nacimiento, documentos de responsables y decisiones de custodia cuando existan.',
            'Lleva historial escolar y carnet de vacunación disponibles.',
            'Guarda contactos y autorizaciones en versión física y sin conexión.',
          ],
          en: [
            'Check travel and residence authorizations required for each child and guardian.',
            'Prepare birth certificates, guardian documents, and custody decisions when applicable.',
            'Bring available school and vaccination records.',
            'Keep contacts and authorizations in physical and offline form.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'A documentação de cada criança e responsável foi conferida para viagem e chegada.',
          es: 'La documentación de cada niño y responsable fue revisada para el viaje y la llegada.',
          en: 'Documents for each child and guardian have been checked for travel and arrival.',
        ),
        preArrivalRequired: true,
        tier: GuideItemTier.critical,
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Conselho Nacional de Educação · Migrantes',
          sourceUrl: PreparationResourceLinks.familySchoolGuide.toString(),
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'Autorizações de viagem e guarda dependem da composição familiar; confirme também com a autoridade argentina competente.',
            es: 'Las autorizaciones de viaje y custodia dependen de la composición familiar; confirma también con la autoridad argentina competente.',
            en: 'Travel and custody authorizations depend on family circumstances; also confirm with the relevant Argentine authority.',
          ),
        ),
      ),
    ];
  }

  static List<GuideActionItem> _settlingAdditions(String locale) {
    return [
      GuideActionItem(
        id: 'item_4_8_revisao_custo_real',
        title: _t(
          locale,
          pt: 'Compare seu custo real após 30 dias',
          es: 'Compara tu costo real después de 30 días',
          en: 'Compare your real cost after 30 days',
        ),
        shortDescription: _t(
          locale,
          pt: 'Troque estimativas por seus gastos reais antes de assumir um aluguel ou compromisso maior.',
          es: 'Reemplazá estimaciones por tus gastos reales antes de asumir un alquiler o compromiso mayor.',
          en: 'Replace estimates with your real spending before taking on a larger lease or commitment.',
        ),
        type: GuideActionType.tool,
        toolType: GuideToolType.budget,
        phase: GuidePhase.arrival,
        orderIndex: 90,
        isCompleted: false,
        icon: Icons.receipt_long_outlined,
        primaryActionLabel: _t(
          locale,
          pt: 'Revisar meu orçamento',
          es: 'Revisar mi presupuesto',
          en: 'Review my budget',
        ),
        primaryActionType: GuidePrimaryActionType.tool,
        doneCriteria: _t(
          locale,
          pt: 'Você registrou moradia, alimentação, transporte, saúde e câmbio reais e ajustou sua faixa de orçamento.',
          es: 'Registraste vivienda, comida, transporte, salud y cambio reales, y ajustaste tu rango de presupuesto.',
          en: 'You recorded real housing, food, transport, health, and exchange costs and adjusted your budget range.',
        ),
        estimatedEffort: GuideEstimatedEffort.fast,
        tier: GuideItemTier.recommended,
        evidence: GuideEvidence(
          type: GuideEvidenceType.movaroGuidance,
          sourceLabel: 'Movaro · Revisão do próprio orçamento',
          sourceUrl: PreparationResourceLinks.consumerFinancialEducation
              .toString(),
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'A comparação usa os valores inseridos por você; não é uma previsão financeira.',
            es: 'La comparación usa los valores ingresados por vos; no es una previsión financiera.',
            en: 'The comparison uses values entered by you; it is not a financial forecast.',
          ),
        ),
      ),
      GuideActionItem(
        id: 'item_4_9_reavaliar_bairro',
        title: _t(
          locale,
          pt: 'Reavalie o bairro com sua rotina real',
          es: 'Reevaluá el barrio con tu rutina real',
          en: 'Reassess the neighborhood using your real routine',
        ),
        shortDescription: _t(
          locale,
          pt: 'Antes de renovar contrato, compare deslocamento, aluguel, serviços e como você se sente na região.',
          es: 'Antes de renovar contrato, compará traslado, alquiler, servicios y cómo te sentís en la zona.',
          en: 'Before renewing a lease, compare commute, rent, services, and how the area works for you.',
        ),
        type: GuideActionType.tool,
        toolType: GuideToolType.housing,
        phase: GuidePhase.arrival,
        orderIndex: 91,
        isCompleted: false,
        icon: Icons.location_city_outlined,
        primaryActionLabel: _t(
          locale,
          pt: 'Comparar opções de moradia',
          es: 'Comparar opciones de vivienda',
          en: 'Compare housing options',
        ),
        primaryActionType: GuidePrimaryActionType.tool,
        checklistItems: [
          ChecklistSubItem(
            id: 'settling_commute',
            title: _t(
              locale,
              pt: 'Tempo e custo do deslocamento conferidos',
              es: 'Tiempo y costo de traslado revisados',
              en: 'Commute time and cost checked',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'settling_services',
            title: _t(
              locale,
              pt: 'Saúde, mercado e transporte próximos conferidos',
              es: 'Salud, mercado y transporte cercanos revisados',
              en: 'Nearby health, groceries, and transport checked',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'settling_contract',
            title: _t(
              locale,
              pt: 'Custo total do próximo contrato comparado',
              es: 'Costo total del próximo contrato comparado',
              en: 'Total cost of the next lease compared',
            ),
            isCompleted: false,
          ),
        ],
        tier: GuideItemTier.optional,
      ),
      GuideActionItem(
        id: 'item_4_10_revisao_documental',
        title: _t(
          locale,
          pt: 'Crie sua revisão anual de documentos',
          es: 'Creá tu revisión anual de documentos',
          en: 'Create your annual document review',
        ),
        shortDescription: _t(
          locale,
          pt: 'Registre vencimentos e confira na fonte oficial o que realmente precisa ser renovado.',
          es: 'Registrá vencimientos y confirmá en la fuente oficial qué realmente necesita renovación.',
          en: 'Record expiry dates and confirm at the official source what actually needs renewal.',
        ),
        type: GuideActionType.external,
        phase: GuidePhase.arrival,
        orderIndex: 92,
        isCompleted: false,
        icon: Icons.event_repeat_rounded,
        primaryActionLabel: _t(
          locale,
          pt: 'Revisar serviços da Polícia Federal',
          es: 'Revisar servicios de Policía Federal',
          en: 'Review Federal Police services',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.rnMRegistrationGuide
            .toString(),
        doneCriteria: _t(
          locale,
          pt: 'As datas relevantes estão registradas e os lembretes foram criados sem presumir um prazo universal.',
          es: 'Las fechas relevantes están registradas y los recordatorios fueron creados sin asumir un plazo universal.',
          en: 'Relevant dates are recorded and reminders were created without assuming one universal deadline.',
        ),
        tier: GuideItemTier.recommended,
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Polícia Federal · Serviços migratórios',
          sourceUrl: PreparationResourceLinks.rnMRegistrationGuide.toString(),
          lastVerified: DateTime(2026, 7, 26),
        ),
      ),
    ];
  }

  static List<String> _priorityOrder(String goal) {
    final goalSpecific = switch (goal) {
      'work' || 'find_job_br' => const [
        'item_0_5_mercado_trabalho',
        'item_2_3_ctps',
        'item_3_4_work_rights',
        'item_3_4_formal_work_ready',
        'item_3_4_trabalho',
      ],
      'remote_income' || 'remote_work' || 'entrepreneur' => const [
        'item_2_6_impostos_exterior',
        'item_3_4_trabalho',
        'item_4_4_mei',
        'item_3_4_work_rights',
      ],
      'study' => const [
        'item_0_7_ingresso_ensino_superior',
        'item_2_7_documentos_academicos',
        'item_3_5_revalidacao_estudos',
      ],
      _ => const <String>[],
    };

    return [
      'item_0_1_rule_90_days',
      'item_0_2_document_folder',
      'item_0_2_antecedentes',
      'item_0_6_saude_entender',
      'item_0_6_medicamentos',
      ...goalSpecific,
      'item_2_1_cpf',
      'item_2_1_govbr',
      'item_0_3_budget',
      'item_1_3_money',
      'item_3_3_pix',
      'item_0_7_family_documents',
      'item_1_5_animais',
      'item_0_4_flight',
      'item_1_2_housing_temporary',
      // Arrival day: prove entry, secure connectivity, then save local help.
      'item_1_0_entry_proof',
      'item_1_1_chip',
      'item_4_7_seguranca_emergencia',
      // First week: health, regularization and work activation.
      'item_4_2_saude',
      'item_2_2_residencia',
      'item_2_3_ctps',
      'item_3_4_formal_work_ready',
      'item_3_1_conta_bancaria',
      // First month and consolidation.
      'item_4_5_registro_rnm',
      'item_3_2_aluguel_fixo',
      'item_3_6_familia_escola',
      'item_4_1_cnh',
      'item_4_3_permanencia',
    ];
  }

  static GuideActionItem _applyExecutionSchedule(GuideActionItem item) {
    const beforeTravel = <String>{
      'item_0_1_rule_90_days',
      'item_0_2_document_folder',
      'item_0_2_antecedentes',
      'item_0_3_budget',
      'item_0_4_flight',
      'item_0_5_mercado_trabalho',
      'item_0_6_saude_entender',
      'item_0_6_medicamentos',
      'item_0_7_family_documents',
      'item_0_7_ingresso_ensino_superior',
      'item_1_2_housing_temporary',
      'item_1_3_money',
      'item_1_5_animais',
      'item_2_1_cpf',
      'item_2_1_govbr',
      'item_2_6_impostos_exterior',
      'item_2_7_documentos_academicos',
      'item_3_3_pix',
      'item_3_4_trabalho',
      'item_3_4_work_rights',
    };
    const arrivalDay = <String>{
      'item_1_0_entry_proof',
      'item_1_1_chip',
      'item_4_7_seguranca_emergencia',
    };
    const firstWeek = <String>{
      'item_2_2_residencia',
      'item_2_3_ctps',
      'item_3_1_conta_bancaria',
      'item_3_4_formal_work_ready',
      'item_4_2_saude',
    };
    const firstMonth = <String>{
      'item_3_2_aluguel_fixo',
      'item_3_5_revalidacao_estudos',
      'item_3_6_familia_escola',
      'item_4_1_cnh',
      'item_4_4_mei',
      'item_4_5_registro_rnm',
    };

    final window = beforeTravel.contains(item.id)
        ? GuideExecutionWindow.beforeTravel
        : arrivalDay.contains(item.id)
        ? GuideExecutionWindow.arrivalDay
        : firstWeek.contains(item.id)
        ? GuideExecutionWindow.firstWeek
        : firstMonth.contains(item.id)
        ? GuideExecutionWindow.firstMonth
        : GuideExecutionWindow.later;

    if (item.id == 'item_4_7_seguranca_emergencia') {
      return item.copyWith(
        executionWindow: window,
        preArrivalRequired: false,
        tier: GuideItemTier.recommended,
        urgencyLevel: GuideUrgencyLevel.urgent,
      );
    }
    if (item.id == 'item_1_1_chip') {
      return item.copyWith(
        executionWindow: window,
        tier: GuideItemTier.critical,
        urgencyLevel: GuideUrgencyLevel.urgent,
      );
    }
    if (item.id == 'item_4_2_saude') {
      return item.copyWith(
        executionWindow: window,
        tier: GuideItemTier.critical,
      );
    }
    return item.copyWith(executionWindow: window);
  }

  static GuideActionItem _contextualizeItem(
    GuideActionItem item,
    MigrationPlan plan,
    LocationData? currentLocation,
    String locale,
  ) {
    final contextualized = switch (item.id) {
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
          pt: 'Prazo variável por instituição',
          es: 'Plazo variable según la institución',
          en: 'Timing varies by institution',
        ),
        executionModes: const [
          GuideExecutionMode.online,
          GuideExecutionMode.inPerson,
        ],
        locationAwareOptions: _bankOptions(plan, currentLocation, locale),
        externalOfficialLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Banco Central · Encontre uma instituição',
              es: 'Banco Central · Encontrá una institución',
              en: 'Central Bank · Find an institution',
            ),
            url: 'https://www.bcb.gov.br/meubc/encontreinstituicao',
          ),
        ],
      ),
      'item_2_3_ctps' => item.copyWith(
        applicabilityConditions: const <String>['formal_work_goal'],
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
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'Global66',
            url: 'https://www.global66.com/ar/',
          ),
          GuideSupportLink(
            label: 'Western Union',
            url: 'https://www.westernunion.com/ar/es/home.html',
          ),
          GuideSupportLink(label: 'Wise', url: 'https://wise.com/'),
        ],
      ),
      'item_1_1_chip' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Varia por operadora, plano, canal de venda e cidade. Confirme o preço total antes de ativar.',
          es: 'Varía según operadora, plan, canal de venta y ciudad. Confirma el precio total antes de activar.',
          en: 'Varies by carrier, plan, sales channel, and city. Confirm the total price before activation.',
        ),
        executionModes: const [GuideExecutionMode.inPerson],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'Claro · Planos pré-pagos',
            url: PreparationResourceLinks.claroPrepaidPlans.toString(),
          ),
          GuideSupportLink(
            label: 'Vivo · Planos pré-pagos',
            url: PreparationResourceLinks.vivoPrepaidPlans.toString(),
          ),
          GuideSupportLink(
            label: 'TIM · Planos pré-pagos',
            url: PreparationResourceLinks.timPrepaidPlans.toString(),
          ),
          GuideSupportLink(
            label: 'TIM · Ativação para estrangeiros',
            url: PreparationResourceLinks.timForeignVisitors.toString(),
          ),
          GuideSupportLink(
            label: 'Anatel · Mapas de cobertura',
            url: PreparationResourceLinks.anatelMobileCoverage.toString(),
          ),
          GuideSupportLink(
            label: 'Anatel · Cadastro pré-pago',
            url: PreparationResourceLinks.anatelPrepaidRegistration.toString(),
          ),
        ],
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
        primaryActionTarget: plan.currentPlanCity != null
            ? PreparationResourceLinks.buildDetranMapSearch(
                plan.currentPlanCity!,
              ).toString()
            : null,
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
            mapUrl: plan.currentPlanCity != null
                ? PreparationResourceLinks.buildDetranMapSearch(
                    plan.currentPlanCity!,
                  ).toString()
                : null,
          ),
        ],
        externalOfficialLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Abrir DETRAN no mapa',
              es: 'Abrir DETRAN en el mapa',
              en: 'Open DETRAN on the map',
            ),
            url: plan.currentPlanCity != null
                ? PreparationResourceLinks.buildDetranMapSearch(
                    plan.currentPlanCity!,
                  ).toString()
                : 'https://www.google.com/maps/search/DETRAN+Brasil',
          ),
        ],
      ),
      'item_3_2_aluguel_fixo' => item.copyWith(
        externalOfficialLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Lei do Inquilinato',
              es: 'Ley de alquileres de Brasil',
              en: 'Brazilian Tenancy Law',
            ),
            url: PreparationResourceLinks.rentalLawGuide.toString(),
          ),
        ],
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Lei nº 8.245/1991 · Lei do Inquilinato',
          sourceUrl: PreparationResourceLinks.rentalLawGuide.toString(),
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'Condições comerciais variam; a lei define limites e garantias permitidas.',
            es: 'Las condiciones comerciales varían; la ley define límites y garantías permitidas.',
            en: 'Commercial conditions vary; the law defines limits and permitted guarantees.',
          ),
        ),
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
            mapUrl: plan.currentPlanCity != null
                ? PreparationResourceLinks.buildUpaMapSearch(
                    plan.currentPlanCity!,
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
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Ministério da Saúde · Saúde de migrantes',
          sourceUrl: PreparationResourceLinks.migrantHealthGuide.toString(),
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'Fluxo e documentos de acompanhamento podem variar por município; urgência não deve esperar cadastro.',
            es: 'El flujo y los documentos pueden variar por municipio; una urgencia no debe esperar el registro.',
            en: 'Ongoing-care flow and documents may vary by municipality; urgent care should not wait for registration.',
          ),
        ),
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
        locationAwareOptions: _residencyOptions(plan, currentLocation, locale),
        mapLinks: _residencyMapLinks(plan, currentLocation, locale),
        externalOfficialLinks: _pfOfficialSupportLinks(
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
          pt: ['Conta bancária ativa', 'App do banco', 'Acesso ao celular'],
          es: ['Cuenta activa', 'App del banco', 'Acceso al celular'],
          en: ['Active bank account', 'Bank app', 'Phone access'],
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
        applicabilityConditions: const <String>['income_strategy_goal'],
        primaryActionLabel: _t(
          locale,
          pt: 'Escolher minha rota de renda',
          es: 'Elegir mi ruta de ingresos',
          en: 'Choose my income path',
        ),
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
              pt: 'Buscar emprego formal (CLT)',
              es: 'Buscar empleo formal (CLT)',
              en: 'Find formal employment (CLT)',
            ),
            url: PreparationResourceLinks.officialJobsPortal.toString(),
          ),
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Entender atividade própria e MEI',
              es: 'Entender trabajo independiente y MEI',
              en: 'Understand self-employment and MEI',
            ),
            url: PreparationResourceLinks.meiGuide.toString(),
          ),
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Revisar renda remota ou do exterior',
              es: 'Revisar ingresos remotos o del exterior',
              en: 'Review remote or foreign income',
            ),
            url: PreparationResourceLinks.foreignIncomeTaxGuide.toString(),
          ),
        ],
      ),
      'item_4_4_mei' => item.copyWith(
        applicabilityConditions: const <String>['self_employed_goal'],
        costInfo: _t(
          locale,
          pt: 'Abertura pelo portal oficial é gratuita; contribuição e limites variam conforme regra vigente.',
          es: 'La apertura por el portal oficial es gratuita; aporte y límites cambian según la regla vigente.',
          en: 'Opening through the official portal is free; contributions and limits vary under current rules.',
        ),
        executionModes: const [GuideExecutionMode.online],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'Portal do Empreendedor',
            url: 'https://www.gov.br/empresas-e-negocios/pt-br/empreendedor',
          ),
        ],
      ),
      'item_3_5_revalidacao_estudos' => item.copyWith(
        applicabilityConditions: const <String>['study_goal'],
      ),
      'item_0_5_mercado_trabalho' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Gratuito — apenas tempo de pesquisa.',
          es: 'Gratis — solo tiempo de investigacion.',
          en: 'Free — research time only.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Escolher plataforma de vagas',
          es: 'Elegir plataforma de vacantes',
          en: 'Choose a job platform',
        ),
        primaryActionTarget: null,
        executionModes: const [GuideExecutionMode.online],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'LinkedIn Brasil',
            url: 'https://www.linkedin.com/jobs',
          ),
          GuideSupportLink(label: 'Catho', url: 'https://www.catho.com.br'),
          GuideSupportLink(
            label: 'VAGAS.com',
            url: PreparationResourceLinks.vagasJobsPortal.toString(),
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

    return _sanitizeCostInfo(contextualized, locale);
  }

  static GuideActionItem _applySafetyReview(
    GuideActionItem item,
    String locale,
  ) {
    return switch (item.id) {
      'item_0_2_antecedentes' => item.copyWith(
        shortDescription: _t(
          locale,
          pt: 'Peça os certificados dos países onde viveu nos cinco anos anteriores, conforme a lista vigente da Polícia Federal.',
          es: 'Pide los certificados de los países donde viviste en los cinco años anteriores, según la lista vigente de la Policía Federal.',
          en: 'Request certificates from countries where you lived in the previous five years, following the current Federal Police list.',
        ),
        dependencies: const <String>['item_0_2_document_folder'],
        requirements: _list(
          locale,
          pt: [
            'Faixa etária para confirmar se há dispensa',
            'DNI argentino para definir a rota online ou presencial',
            'Lista dos países onde viveu nos últimos cinco anos',
            'E-mail acessível e meio de autenticação/pagamento',
            'Previsão de quando fará o protocolo na Polícia Federal',
          ],
          es: [
            'Rango de edad para confirmar si existe exención',
            'DNI argentino para definir la vía en línea o presencial',
            'Lista de países donde viviste durante los últimos cinco años',
            'Correo accesible y medio de autenticación/pago',
            'Previsión de cuándo presentarás la solicitud ante la Policía Federal',
          ],
          en: [
            'Age range to confirm whether an exemption applies',
            'Argentine DNI to select the online or in-person route',
            'Countries where you lived during the previous five years',
            'Accessible email and an authentication/payment method',
            'Expected Federal Police filing window',
          ],
        ),
        executionModes: const [
          GuideExecutionMode.online,
          GuideExecutionMode.inPerson,
        ],
        estimatedTimeLabel: _t(
          locale,
          pt: '1 hora a 5 dias úteis após o pagamento',
          es: '1 hora a 5 días hábiles desde el pago',
          en: '1 hour to 5 business days after payment',
        ),
        context: _t(
          locale,
          pt: 'O certificado argentino cobre a Argentina. Se você viveu em outro país nos últimos cinco anos, confira também a exigência daquele país.',
          es: 'El certificado argentino cubre Argentina. Si viviste en otro país durante los últimos cinco años, revisa también ese requisito.',
          en: 'The Argentine certificate covers Argentina. If you lived elsewhere in the last five years, check that country’s requirement too.',
        ),
        steps: _list(
          locale,
          pt: [
            'Liste todos os países onde você viveu nos cinco anos anteriores ao pedido.',
            'Para a Argentina, use o Registro Nacional de Reincidencia e escolha uma modalidade disponível.',
            'Para outros países, abra a autoridade oficial correspondente e confirme emissão e formalidades.',
            'Baixe o PDF, verifique a assinatura digital e mantenha cópia offline.',
            'Planeje a emissão perto do protocolo e confirme a aceitação atual com a Polícia Federal.',
          ],
          es: [
            'Lista todos los países donde viviste en los cinco años anteriores a la solicitud.',
            'Para Argentina, usa el Registro Nacional de Reincidencia y elige una modalidad disponible.',
            'Para otros países, abre la autoridad oficial correspondiente y confirma emisión y formalidades.',
            'Descarga el PDF, revisa la firma digital y conserva una copia sin conexión.',
            'Planifica la emisión cerca de la presentación y confirma la aceptación vigente con la Policía Federal.',
          ],
          en: [
            'List every country where you lived in the five years before applying.',
            'For Argentina, use the National Recidivism Registry and choose an available service speed.',
            'For other countries, use the relevant official authority and confirm issuance and formalities.',
            'Download the PDF, verify its digital signature, and keep an offline copy.',
            'Time issuance close to filing and confirm current acceptance with Federal Police.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você possui os certificados aplicáveis e confirmou que estarão adequados na data do protocolo.',
          es: 'Tienes los certificados aplicables y confirmaste que estarán adecuados al presentar.',
          en: 'You have the applicable certificates and confirmed they will be suitable when filing.',
        ),
        tips: _list(
          locale,
          pt: [
            'O RNR permite baixar o certificado durante 90 dias; isso não deve ser apresentado como uma validade universal definida pelo órgão argentino.',
            'A Polícia Federal usa 90 dias como referência e informa que a aceitação de certidão fora desse período fica a critério da autoridade.',
          ],
          es: [
            'El RNR permite descargar el certificado durante 90 días; eso no debe presentarse como una vigencia universal definida por el organismo argentino.',
            'La Policía Federal usa 90 días como referencia e informa que aceptar un certificado fuera de ese período queda a criterio de la autoridad.',
          ],
          en: [
            'RNR lets you download the certificate for 90 days; that should not be presented as a universal validity period defined by Argentina.',
            'Federal Police uses 90 days as a reference and states that accepting an older certificate is at the authority’s discretion.',
          ],
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Não peça apenas o certificado argentino se viveu em outro país nos últimos cinco anos.',
            'Não confunda o período de download do RNR com garantia de aceitação pela Polícia Federal.',
          ],
          es: [
            'No pidas solo el certificado argentino si viviste en otro país durante los últimos cinco años.',
            'No confundas el período de descarga del RNR con una garantía de aceptación de la Policía Federal.',
          ],
          en: [
            'Do not request only the Argentine certificate if you lived in another country during the last five years.',
            'Do not confuse the RNR download period with guaranteed Federal Police acceptance.',
          ],
        ),
        costInfo: _t(
          locale,
          pt: 'O RNR oferece modalidades e preços próprios. Confira o valor vigente no momento da solicitação.',
          es: 'El RNR ofrece modalidades y precios propios. Revisa el valor vigente al solicitar.',
          en: 'RNR offers different service speeds and prices. Check the current amount when requesting.',
        ),
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'RNR Argentina e Polícia Federal',
          sourceUrl:
              'https://www.argentina.gob.ar/justicia/reincidencia/antecedentespenales/preguntas-frecuentes',
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'A decisão final sobre aceitação documental pertence à Polícia Federal.',
            es: 'La decisión final sobre aceptación documental corresponde a la Policía Federal.',
            en: 'Federal Police makes the final document-acceptance decision.',
          ),
        ),
      ),
      'item_1_2_housing_temporary' => item.copyWith(
        tier: GuideItemTier.critical,
        preArrivalRequired: true,
        urgencyLevel: GuideUrgencyLevel.urgent,
        blockingReason: _t(
          locale,
          pt: 'Chegar sem uma hospedagem inicial segura aumenta risco, custo e pressão para aceitar contratos ruins.',
          es: 'Llegar sin alojamiento inicial seguro aumenta riesgo, costo y presión para aceptar contratos desfavorables.',
          en: 'Arriving without safe initial accommodation increases risk, cost, and pressure to accept poor contracts.',
        ),
      ),
      'item_2_2_residencia' => item.copyWith(
        dependencies: const <String>[
          'item_0_2_document_folder',
          'item_0_2_antecedentes',
          'item_1_0_entry_proof',
        ],
        requirements: _list(
          locale,
          pt: [
            'Passaporte ou documento de identidade válido para ingresso',
            'Certidão civil ou consular quando o documento não mostrar filiação',
            'Antecedentes dos países onde residiu nos cinco anos anteriores, quando aplicável',
            'Declaração pessoal de ausência de antecedentes nos cinco anos anteriores',
            'Comprovante de ingresso no Brasil',
            'Comprovantes das taxas oficiais, quando aplicáveis',
          ],
          es: [
            'Pasaporte o documento de identidad válido para ingresar',
            'Partida civil o certificado consular cuando el documento no muestre filiación',
            'Antecedentes de los países donde residiste en los cinco años anteriores, cuando corresponda',
            'Declaración personal de ausencia de antecedentes en los cinco años anteriores',
            'Comprobante de ingreso a Brasil',
            'Comprobantes de tasas oficiales, cuando correspondan',
          ],
          en: [
            'Passport or identity document valid for entry',
            'Civil or consular certificate when the ID does not show parentage',
            'Criminal records from countries of residence in the previous five years, when applicable',
            'Personal declaration of no criminal record in the previous five years',
            'Proof of entry into Brazil',
            'Official fee receipts, when applicable',
          ],
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'res_route',
            title: _t(
              locale,
              pt: 'Base legal Brasil–Argentina confirmada',
              es: 'Base legal Brasil–Argentina confirmada',
              en: 'Brazil–Argentina legal basis confirmed',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'res_documents',
            title: _t(
              locale,
              pt: 'Lista oficial vigente conferida item por item',
              es: 'Lista oficial vigente revisada punto por punto',
              en: 'Current official list checked item by item',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'res_form',
            title: _t(
              locale,
              pt: 'Formulário, taxas aplicáveis e agendamento concluídos',
              es: 'Formulario, tasas aplicables y turno completados',
              en: 'Form, applicable fees, and appointment completed',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'res_protocol',
            title: _t(
              locale,
              pt: 'Protocolo recebido e salvo',
              es: 'Protocolo recibido y guardado',
              en: 'Protocol received and saved',
            ),
            isCompleted: false,
          ),
        ],
        blockingReason: _t(
          locale,
          pt: 'A regularização migratória é a base para viver e trabalhar no Brasil com segurança jurídica; cada serviço posterior mantém requisitos próprios.',
          es: 'La regularización migratoria es la base para vivir y trabajar en Brasil con seguridad jurídica; cada servicio posterior mantiene requisitos propios.',
          en: 'Migration regularization is the foundation for living and working in Brazil lawfully; later services keep their own requirements.',
        ),
        communityTips: const <String>[],
      ),
      'item_2_3_ctps' => item.copyWith(
        title: _t(
          locale,
          pt: 'Acesse e valide sua Carteira de Trabalho Digital',
          es: 'Accede y valida tu Carteira de Trabalho Digital',
          en: 'Access and validate your Digital Work Card',
        ),
        shortDescription: _t(
          locale,
          pt: 'A CTPS Digital é identificada pelo CPF; acesse pelo Gov.br e confira seus dados.',
          es: 'La CTPS Digital se identifica por el CPF; accede con Gov.br y revisa tus datos.',
          en: 'The Digital Work Card is identified by CPF; access it through Gov.br and check your data.',
        ),
        dependencies: const <String>['item_2_1_govbr'],
        context: _t(
          locale,
          pt: 'A CTPS Digital é emitida automaticamente para inscritos no CPF. O passo prático é habilitar o acesso e validar os dados.',
          es: 'La CTPS Digital se emite automáticamente para personas inscritas en el CPF. El paso práctico es habilitar el acceso y validar los datos.',
          en: 'The Digital Work Card is automatically issued to CPF holders. The practical step is enabling access and validating data.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Ela permite acompanhar vínculos e informações trabalhistas registradas pelo empregador.',
          es: 'Permite seguir los vínculos y datos laborales registrados por el empleador.',
          en: 'It lets you track employment relationships and information registered by employers.',
        ),
        steps: _list(
          locale,
          pt: [
            'Confirme que seu CPF está regular e acesse sua conta Gov.br.',
            'Abra a Carteira de Trabalho Digital pelo aplicativo ou pela web.',
            'Confira nome, CPF e qualificação civil.',
            'Se houver divergência, use o canal oficial indicado antes da contratação.',
          ],
          es: [
            'Confirma que tu CPF está regular y accede a tu cuenta Gov.br.',
            'Abre la Carteira de Trabalho Digital en la app o web.',
            'Revisa nombre, CPF y datos civiles.',
            'Si hay divergencias, usa el canal oficial indicado antes de la contratación.',
          ],
          en: [
            'Confirm your CPF is regular and access your Gov.br account.',
            'Open the Digital Work Card in the app or on the web.',
            'Check your name, CPF, and civil information.',
            'If data differs, use the official correction channel before hiring.',
          ],
        ),
        requirements: _list(
          locale,
          pt: ['CPF regular', 'Conta Gov.br'],
          es: ['CPF regular', 'Cuenta Gov.br'],
          en: ['Regular CPF', 'Gov.br account'],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você consegue acessar a CTPS Digital e seus dados estão corretos.',
          es: 'Puedes acceder a la CTPS Digital y tus datos están correctos.',
          en: 'You can access the Digital Work Card and your data is correct.',
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'ctps_access',
            title: _t(
              locale,
              pt: 'Acesso à CTPS Digital confirmado',
              es: 'Acceso a la CTPS Digital confirmado',
              en: 'Digital Work Card access confirmed',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'ctps_data',
            title: _t(
              locale,
              pt: 'Dados civis conferidos',
              es: 'Datos civiles revisados',
              en: 'Civil data checked',
            ),
            isCompleted: false,
          ),
        ],
        tips: const <String>[],
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Ministério do Trabalho · CTPS Digital',
          sourceUrl:
              'https://www.gov.br/trabalho-e-emprego/pt-br/servicos/trabalhador/carteira-de-trabalho/carteira-de-trabalho-e-previdencia-social-ctps-1',
          lastVerified: DateTime(2026, 7, 26),
        ),
      ),
      'item_0_5_mercado_trabalho' => item.copyWith(
        preArrivalRequired: true,
        tier: GuideItemTier.recommended,
        applicabilityConditions: const <String>['job_search_goal'],
        primaryActionLabel: _t(
          locale,
          pt: 'Consultar Emprega Brasil e SINE',
          es: 'Consultar Emprega Brasil y SINE',
          en: 'Check Emprega Brasil and SINE',
        ),
        primaryActionTarget: PreparationResourceLinks.officialJobsPortal
            .toString(),
        steps: _list(
          locale,
          pt: [
            'Pesquise vagas comparáveis por cidade, senioridade e tipo de contrato.',
            'Diferencie salário bruto, descontos e benefícios antes de estimar o líquido.',
            'Compare a renda líquida estimada com uma faixa de custo de vida da cidade.',
            'Use Emprega Brasil/SINE e plataformas privadas de vagas como fontes distintas.',
          ],
          es: [
            'Busca vacantes comparables por ciudad, experiencia y tipo de contrato.',
            'Diferencia salario bruto, descuentos y beneficios antes de estimar el neto.',
            'Compara el ingreso neto estimado con un rango de costo de vida de la ciudad.',
            'Usa Emprega Brasil/SINE y plataformas privadas de vacantes como fuentes distintas.',
          ],
          en: [
            'Research comparable openings by city, seniority, and contract type.',
            'Separate gross salary, deductions, and benefits before estimating take-home pay.',
            'Compare estimated take-home pay with a city cost-of-living range.',
            'Use Emprega Brasil/SINE and private job platforms as distinct sources.',
          ],
        ),
        tips: _list(
          locale,
          pt: [
            'Salário anunciado costuma ser bruto, salvo indicação expressa em contrário.',
            'MEI, PJ e CLT têm obrigações e proteções diferentes; não compare apenas o valor mensal.',
          ],
          es: [
            'El salario anunciado suele ser bruto, salvo indicación expresa en contrario.',
            'MEI, PJ y CLT tienen obligaciones y protecciones diferentes; no compares solo el valor mensual.',
          ],
          en: [
            'Advertised salary is usually gross unless expressly stated otherwise.',
            'MEI, contractor, and formal employment have different obligations and protections; do not compare only monthly amounts.',
          ],
        ),
        communityTips: const <String>[],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'Emprega Brasil / SINE',
            url: PreparationResourceLinks.officialJobsPortal.toString(),
          ),
        ],
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Ministério do Trabalho · Emprega Brasil/SINE',
          sourceUrl: PreparationResourceLinks.officialJobsPortal.toString(),
          lastVerified: DateTime(2026, 7, 26),
        ),
      ),
      'item_3_4_trabalho' => item.copyWith(
        dependencies: const <String>[],
        requirements: _list(
          locale,
          pt: [
            'Caminho de renda escolhido',
            'Documentos exigidos para esse caminho',
            'Análise tributária quando houver renda exterior ou atividade própria',
          ],
          es: [
            'Camino de ingresos elegido',
            'Documentos exigidos para ese camino',
            'Análisis fiscal cuando haya ingresos del exterior o actividad propia',
          ],
          en: [
            'Chosen income path',
            'Documents required for that path',
            'Tax review for foreign income or self-employment',
          ],
        ),
        tips: _list(
          locale,
          pt: [
            'Para CLT, priorize CPF, Gov.br, CTPS Digital e regularização migratória.',
            'Para atividade própria, confirme se a ocupação pode ser MEI e como a renda exterior será tratada.',
          ],
          es: [
            'Para empleo formal, prioriza CPF, Gov.br, CTPS Digital y regularización migratoria.',
            'Para actividad propia, confirma si la ocupación puede ser MEI y cómo se tratarán los ingresos del exterior.',
          ],
          en: [
            'For formal work, prioritize CPF, Gov.br, Digital Work Card, and migration regularization.',
            'For self-employment, confirm MEI eligibility and how foreign income will be treated.',
          ],
        ),
        communityTips: const <String>[],
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Ministério do Trabalho e Receita Federal',
          sourceUrl: PreparationResourceLinks.officialJobsPortal.toString(),
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'A escolha do regime e a tributação são individuais; o app não calcula enquadramento.',
            es: 'La elección del régimen y la tributación son individuales; la app no calcula el encuadre.',
            en: 'Work structure and taxation are individual; the app does not calculate classification.',
          ),
        ),
      ),
      'item_3_2_aluguel_fixo' => item.copyWith(
        whyItMatters: _t(
          locale,
          pt: 'Uma moradia estável facilita a rotina, mas não é requisito universal para matrícula escolar ou contratação.',
          es: 'Una vivienda estable facilita la rutina, pero no es requisito universal para matrícula escolar o contratación.',
          en: 'Stable housing helps daily life but is not a universal requirement for school enrollment or hiring.',
        ),
        requirements: _list(
          locale,
          pt: [
            'Documento e CPF conforme a análise do locador',
            'Comprovação de renda, quando solicitada',
            'Uma modalidade de garantia prevista no contrato',
          ],
          es: [
            'Documento y CPF según el análisis del locador',
            'Comprobante de ingresos, cuando se solicite',
            'Una modalidad de garantía prevista en el contrato',
          ],
          en: [
            'ID and CPF according to the landlord’s review',
            'Proof of income when requested',
            'One guarantee type stated in the contract',
          ],
        ),
        warningFlags: _list(
          locale,
          pt: [
            'A Lei do Inquilinato proíbe mais de uma modalidade de garantia no mesmo contrato.',
            'Caução em dinheiro não pode superar três meses de aluguel e deve seguir a forma prevista em lei.',
            'Não pague depósito antes de verificar imóvel, responsável e contrato.',
            'Tradução automática ajuda a compreender, mas não valida cláusulas jurídicas.',
          ],
          es: [
            'La ley brasileña prohíbe más de una modalidad de garantía en el mismo contrato.',
            'La garantía en dinero no puede superar tres meses de alquiler y debe seguir la forma legal.',
            'No pagues depósito antes de verificar inmueble, responsable y contrato.',
            'La traducción automática ayuda a comprender, pero no valida cláusulas jurídicas.',
          ],
          en: [
            'Brazilian tenancy law prohibits more than one guarantee type in the same lease.',
            'Cash security may not exceed three months’ rent and must follow the legal form.',
            'Do not pay a deposit before verifying the property, responsible party, and contract.',
            'Machine translation can aid understanding but does not validate legal clauses.',
          ],
        ),
        communityTips: const <String>[],
      ),
      'item_0_6_saude_entender' => item.copyWith(
        preArrivalRequired: false,
        tier: GuideItemTier.recommended,
        context: _t(
          locale,
          pt: 'O SUS é público, gratuito e atende todas as pessoas que estão no Brasil, inclusive migrantes sem CPF ou Cartão SUS. O atendimento existe em rede: a UBS acompanha a saúde; UPA, SAMU e hospital atendem situações de maior gravidade.',
          es: 'El SUS es público, gratuito y atiende a todas las personas que están en Brasil, incluso migrantes sin CPF o Tarjeta SUS. La atención funciona en red: la UBS acompaña la salud; UPA, SAMU y hospital atienden situaciones de mayor gravedad.',
          en: 'SUS is public, free, and serves everyone in Brazil, including migrants without a CPF or SUS card. Care works as a network: UBS provides ongoing care, while UPA, SAMU, and hospitals handle more serious situations.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Escolher a porta correta reduz demora e evita depender do pronto-socorro para cuidados que a UBS resolve. A rede é ampla, mas oferta, filas e tempo de espera variam entre municípios e por tipo de atendimento.',
          es: 'Elegir la puerta correcta reduce demoras y evita depender de emergencias para cuidados que resuelve la UBS. La red es amplia, pero la oferta, las filas y los tiempos varían entre municipios y según el tipo de atención.',
          en: 'Choosing the right entry point reduces delays and avoids relying on emergency services for care a UBS can provide. The network is broad, but availability and wait times vary by municipality and type of care.',
        ),
        steps: _list(
          locale,
          pt: [
            'Direito de acesso: o SUS atende gratuitamente quem está no país, sem discriminação por nacionalidade ou situação migratória.',
            'UBS: use para vacinação, pré-natal, receitas, consultas, saúde bucal, prevenção e acompanhamento de doenças crônicas; ela coordena encaminhamentos para especialistas.',
            'UPA 24h: procure quando o problema precisa de avaliação rápida, como falta de ar, febre alta, dor intensa, crise convulsiva, fratura ou sangramento sem controle. A classificação de risco prioriza a gravidade, não a ordem de chegada.',
            'SAMU 192 ou hospital: acione o SAMU quando houver risco imediato e a pessoa não puder ir com segurança; hospitais recebem emergências, internações e casos de maior complexidade.',
            'Documentos: passaporte ou identidade do país de origem podem identificar você. CPF, CNS/Cartão SUS e comprovante de residência facilitam cadastro e continuidade, mas a falta deles não deve impedir atendimento.',
            'Antes de viajar, localize uma UBS, uma UPA e um hospital próximos da futura casa e salve o 192.',
            'Confira sua carteira de vacinação e as recomendações vigentes para viajantes, incluindo febre amarela conforme o destino.',
            'Avalie seguro de viagem ou assistência para o trajeto e o período inicial; é uma cobertura adicional, não substitui o direito ao SUS.',
            'Se quiser plano privado, consulte a ANS e peça cotação para sua idade, cidade, cobertura, carência e coparticipação.',
            'Se usa medicamento contínuo, confira a regra da Anvisa e leve receita e documentação compatíveis com a quantidade.',
          ],
          es: [
            'Derecho de acceso: el SUS atiende gratuitamente a quien está en el país, sin discriminación por nacionalidad o situación migratoria.',
            'UBS: úsala para vacunación, prenatal, recetas, consultas, salud bucal, prevención y seguimiento de enfermedades crónicas; coordina derivaciones a especialistas.',
            'UPA 24h: acude cuando el problema necesita evaluación rápida, como falta de aire, fiebre alta, dolor intenso, convulsión, fractura o sangrado sin control. La prioridad depende de la gravedad, no del orden de llegada.',
            'SAMU 192 u hospital: llama al SAMU si hay riesgo inmediato y la persona no puede trasladarse con seguridad; los hospitales reciben emergencias, internaciones y casos complejos.',
            'Documentos: el pasaporte o la identidad del país de origen pueden identificarte. CPF, CNS/Tarjeta SUS y comprobante de domicilio facilitan el registro y la continuidad, pero su ausencia no debe impedir la atención.',
            'Antes de viajar, ubica una UBS, una UPA y un hospital cerca de tu futura casa y guarda el 192.',
            'Revisa tu carnet de vacunación y las recomendaciones vigentes para viajeros, incluida fiebre amarilla según el destino.',
            'Evalúa un seguro o asistencia para el viaje y el período inicial; es una cobertura adicional y no sustituye tu derecho al SUS.',
            'Si quieres plan privado, consulta ANS y pide cotización para tu edad, ciudad, cobertura, carencia y copago.',
            'Si usas medicación continua, revisa la regla de Anvisa y lleva receta y documentación compatibles con la cantidad.',
          ],
          en: [
            'Access right: SUS provides free care to anyone in the country, without discrimination based on nationality or migration status.',
            'UBS: use it for vaccination, prenatal care, prescriptions, appointments, oral health, prevention, and chronic-condition follow-up; it coordinates specialist referrals.',
            '24h UPA: go when a problem needs prompt assessment, such as shortness of breath, high fever, severe pain, seizure, fracture, or uncontrolled bleeding. Priority is based on severity, not arrival order.',
            'SAMU 192 or hospital: call SAMU when there is immediate risk and the person cannot travel safely; hospitals handle emergencies, admissions, and more complex cases.',
            'Documents: a passport or home-country ID can identify you. A CPF, CNS/SUS card, and proof of address make registration and continuity easier, but lacking them should not prevent care.',
            'Before traveling, find a UBS, UPA, and hospital near your future home and save 192.',
            'Review your vaccination record and current traveler recommendations, including yellow fever where relevant to the destination.',
            'Consider insurance or assistance for the journey and initial period; it is additional coverage and does not replace your right to SUS care.',
            'If considering private insurance, check ANS and request a quote for your age, city, coverage, waiting periods, and copay.',
            'For ongoing medication, check Anvisa rules and carry prescriptions and records matching the quantity.',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você sabe qual serviço procurar, salvou o 192, localizou a rede próxima e entendeu que documento facilita o cadastro, mas não cria o direito ao atendimento.',
          es: 'Sabes qué servicio buscar, guardaste el 192, ubicaste la red cercana y entendiste que la documentación facilita el registro, pero no crea el derecho a la atención.',
          en: 'You know which service to use, saved 192, found the nearby network, and understand that documents make registration easier but do not create the right to care.',
        ),
        tips: _list(
          locale,
          pt: [
            'O SUS também oferece medicamentos, exames e atendimento especializado, conforme protocolos e disponibilidade local; normalmente o percurso começa na UBS.',
            'Oferta, qualidade percebida e tempo de espera variam por cidade, unidade, demanda e complexidade; não conte com prazo garantido.',
            'Preço, rede, carência e inclusão de dependentes variam por plano e contrato.',
          ],
          es: [
            'El SUS también ofrece medicamentos, estudios y atención especializada según protocolos y disponibilidad local; normalmente el recorrido comienza en la UBS.',
            'La oferta, la calidad percibida y los tiempos de espera varían según ciudad, unidad, demanda y complejidad; no cuentes con un plazo garantizado.',
            'Precio, red, carencia e inclusión de dependientes varían por plan y contrato.',
          ],
          en: [
            'SUS also provides medicines, tests, and specialist care according to protocols and local availability; the usual pathway starts at a UBS.',
            'Availability, perceived quality, and wait times vary by city, facility, demand, and complexity; do not rely on a guaranteed timeframe.',
            'Price, network, waiting periods, and dependent coverage vary by plan and contract.',
          ],
        ),
        decisionOptions: [
          GuideDecisionOption(
            title: 'UBS',
            description: _t(
              locale,
              pt: 'Cuidado do dia a dia, prevenção e acompanhamento. É a principal porta de entrada.',
              es: 'Cuidado cotidiano, prevención y seguimiento. Es la principal puerta de entrada.',
              en: 'Everyday care, prevention, and follow-up. It is the main entry point.',
            ),
          ),
          GuideDecisionOption(
            title: 'UPA 24h',
            description: _t(
              locale,
              pt: 'Urgência que precisa de avaliação rápida, com atendimento por classificação de risco.',
              es: 'Urgencia que necesita evaluación rápida, con atención por clasificación de riesgo.',
              en: 'Urgent problems needing prompt assessment, prioritized through risk classification.',
            ),
          ),
          GuideDecisionOption(
            title: 'SAMU 192',
            description: _t(
              locale,
              pt: 'Risco imediato ou transporte inseguro; a equipe orienta e envia socorro quando indicado.',
              es: 'Riesgo inmediato o traslado inseguro; el equipo orienta y envía ayuda cuando corresponde.',
              en: 'Immediate risk or unsafe transport; the team advises and dispatches help when indicated.',
            ),
          ),
          GuideDecisionOption(
            title: _t(locale, pt: 'Hospital', es: 'Hospital', en: 'Hospital'),
            description: _t(
              locale,
              pt: 'Emergências, internação, cirurgia e casos encaminhados de maior complexidade.',
              es: 'Emergencias, internación, cirugía y casos complejos derivados.',
              en: 'Emergencies, admission, surgery, and referred higher-complexity cases.',
            ),
          ),
        ],
        requirements: _list(
          locale,
          pt: [
            'Passaporte ou identidade do país de origem, se disponível',
            'CPF, CNS/Cartão SUS e comprovante de residência, se já tiver',
            'Receitas, nomes genéricos dos medicamentos e histórico clínico relevante',
          ],
          es: [
            'Pasaporte o identidad del país de origen, si está disponible',
            'CPF, CNS/Tarjeta SUS y comprobante de domicilio, si ya los tienes',
            'Recetas, nombres genéricos de medicamentos e historia clínica relevante',
          ],
          en: [
            'Passport or home-country ID, if available',
            'CPF, CNS/SUS card, and proof of address, if already available',
            'Prescriptions, generic medication names, and relevant medical history',
          ],
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Não adie urgência ou emergência por falta de CPF, CNS, comprovante de residência ou documento brasileiro.',
            'Qualidade e tempo de espera variam por cidade, demanda e complexidade; “universal” não significa atendimento imediato para casos sem risco.',
          ],
          es: [
            'No postergues una urgencia o emergencia por falta de CPF, CNS, comprobante de domicilio o documento brasileño.',
            'La calidad y el tiempo de espera varían según ciudad, demanda y complejidad; “universal” no significa atención inmediata para casos sin riesgo.',
          ],
          en: [
            'Do not delay urgent or emergency care because you lack a CPF, CNS, proof of address, or Brazilian document.',
            'Quality and wait times vary by city, demand, and complexity; “universal” does not mean immediate care for non-risk cases.',
          ],
        ),
        communityTips: const <String>[],
        supportLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Direitos de migrantes no SUS',
              es: 'Derechos de migrantes en el SUS',
              en: 'Migrants’ rights in SUS',
            ),
            url: PreparationResourceLinks.migrantSusRightsGuide.toString(),
          ),
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Quando usar UBS, UPA, SAMU ou hospital',
              es: 'Cuándo usar UBS, UPA, SAMU u hospital',
              en: 'When to use UBS, UPA, SAMU, or hospital',
            ),
            url: PreparationResourceLinks.susCareNetworkGuide.toString(),
          ),
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Atendimento para turistas estrangeiros',
              es: 'Atención para turistas extranjeros',
              en: 'Care for foreign tourists',
            ),
            url: PreparationResourceLinks.travelerHealthDuringStay.toString(),
          ),
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Vacinação de viajantes',
              es: 'Vacunación para viajeros',
              en: 'Traveler vaccination',
            ),
            url: PreparationResourceLinks.travelerVaccinationGuide.toString(),
          ),
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Recomendações Argentina–Brasil',
              es: 'Recomendaciones Argentina–Brasil',
              en: 'Argentina–Brazil recommendations',
            ),
            url: PreparationResourceLinks.argentinaBrazilTravelRecommendations
                .toString(),
          ),
        ],
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Ministério da Saúde · Direitos de migrantes no SUS',
          sourceUrl: PreparationResourceLinks.migrantSusRightsGuide.toString(),
          lastVerified: DateTime(2026, 7, 29),
          scopeNote: _t(
            locale,
            pt: 'Direitos e organização são nacionais; disponibilidade, fluxos e espera devem ser confirmados na rede municipal.',
            es: 'Los derechos y la organización son nacionales; la disponibilidad, los circuitos y las esperas deben confirmarse en la red municipal.',
            en: 'Rights and system organization are national; availability, local pathways, and wait times must be confirmed with the municipal network.',
          ),
        ),
      ),
      'item_4_2_saude' => item.copyWith(
        title: _t(
          locale,
          pt: 'Localize sua UBS e organize o Cartão SUS',
          es: 'Ubica tu UBS y organiza la Tarjeta SUS',
          en: 'Find your UBS and organize your SUS card',
        ),
        shortDescription: _t(
          locale,
          pt: 'Na primeira semana, encontre sua UBS, cadastre-se com o documento disponível e salve as referências de urgência.',
          es: 'En la primera semana, encuentra tu UBS, regístrate con el documento disponible y guarda las referencias de urgencia.',
          en: 'In your first week, find your UBS, register with the document you have, and save your urgent-care references.',
        ),
        context: _t(
          locale,
          pt: 'A UBS é sua referência para cuidado contínuo. O CNS/Cartão SUS identifica seu cadastro e vincula atendimentos, mas não é condição para ter direito ao SUS.',
          es: 'La UBS es tu referencia para el cuidado continuo. El CNS/Tarjeta SUS identifica tu registro y vincula atenciones, pero no es condición para tener derecho al SUS.',
          en: 'A UBS is your reference for ongoing care. The CNS/SUS card identifies your registration and links care records, but it is not a condition for the right to SUS care.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Ter a UBS de referência e o cadastro organizado facilita vacinação, receitas, acompanhamento e encaminhamentos. Em urgência, procure atendimento mesmo que o cadastro ainda não esteja pronto.',
          es: 'Tener una UBS de referencia y el registro organizado facilita vacunación, recetas, seguimiento y derivaciones. En una urgencia, busca atención aunque el registro todavía no esté listo.',
          en: 'Having a reference UBS and organized registration makes vaccination, prescriptions, follow-up, and referrals easier. In urgent situations, seek care even if registration is not ready.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Entender o Cartão Nacional de Saúde',
          es: 'Entender la Tarjeta Nacional de Salud',
          en: 'Understand the National Health Card',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: PreparationResourceLinks.susPortal.toString(),
        steps: _list(
          locale,
          pt: [
            'Localize a UBS que atende seu endereço e confirme horário, território e forma de cadastro com a secretaria municipal.',
            'Vá presencialmente com passaporte ou identidade argentina. Leve CPF, CNS e comprovante de endereço se já tiver; a cartilha oficial informa que o comprovante facilita, mas não é obrigatório.',
            'Peça o cadastro no SUS e a emissão ou localização do número do CNS. Um novo CNS não é emitido pelo Meu SUS Digital: cadastro e alterações são presenciais em estabelecimento de saúde.',
            'Informe medicamentos contínuos, alergias, vacinas e condições que precisam de acompanhamento; leve receitas e histórico relevante.',
            'Salve a UPA 24h e o hospital de referência. Em risco imediato, ligue SAMU 192; não espere CPF, CNS ou documento brasileiro.',
            'Se considerar plano privado, compare somente como complemento: registro na ANS, rede na cidade, carências, coparticipação e dependentes.',
          ],
          es: [
            'Ubica la UBS que atiende tu domicilio y confirma horario, territorio y forma de registro con la secretaría municipal.',
            'Ve presencialmente con pasaporte o identidad argentina. Lleva CPF, CNS y comprobante de domicilio si ya los tienes; la cartilla oficial indica que el comprobante facilita, pero no es obligatorio.',
            'Pide el registro en el SUS y la emisión o localización del número CNS. Meu SUS Digital no emite un CNS nuevo: el alta y los cambios son presenciales en un establecimiento de salud.',
            'Informa medicamentos continuos, alergias, vacunas y condiciones que requieren seguimiento; lleva recetas e historia relevante.',
            'Guarda la UPA 24h y el hospital de referencia. Ante riesgo inmediato, llama al SAMU 192; no esperes CPF, CNS o documento brasileño.',
            'Si consideras un plan privado, compáralo solo como complemento: registro en ANS, red en la ciudad, carencias, copago y dependientes.',
          ],
          en: [
            'Find the UBS serving your address and confirm its hours, catchment area, and registration process with the municipal health authority.',
            'Go in person with a passport or Argentine ID. Bring a CPF, CNS, and proof of address if available; the official booklet says proof of address helps but is not mandatory.',
            'Request SUS registration and issuance or lookup of your CNS number. Meu SUS Digital cannot issue a new CNS: registration and changes are handled in person at a health facility.',
            'Report ongoing medication, allergies, vaccines, and conditions needing follow-up; bring prescriptions and relevant health records.',
            'Save the reference 24-hour UPA and hospital. For immediate risk, call SAMU 192; do not wait for a CPF, CNS, or Brazilian document.',
            'If considering private cover, compare it only as a supplement: ANS registration, local network, waiting periods, copays, and dependents.',
          ],
        ),
        requirements: _list(
          locale,
          pt: [
            'Passaporte ou identidade argentina disponível',
            'Comprovante de endereço, CPF e CNS, se já tiver',
            'Receitas, nomes genéricos dos medicamentos, carteira de vacinação e histórico relevante',
          ],
          es: [
            'Pasaporte o identidad argentina disponible',
            'Comprobante de domicilio, CPF y CNS, si ya los tienes',
            'Recetas, nombres genéricos, carnet de vacunación e historia clínica relevante',
          ],
          en: [
            'Available passport or Argentine ID',
            'Proof of address, CPF, and CNS, if already available',
            'Prescriptions, generic medication names, vaccination record, and relevant health history',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você identificou sua UBS, confirmou como fazer o cadastro/CNS, salvou UPA, hospital e SAMU 192 e sabe que falta de CPF/CNS não deve adiar atendimento.',
          es: 'Identificaste tu UBS, confirmaste cómo hacer el registro/CNS, guardaste UPA, hospital y SAMU 192 y sabes que la falta de CPF/CNS no debe retrasar la atención.',
          en: 'You identified your UBS, confirmed how to register/get a CNS, saved UPA, hospital, and SAMU 192, and know that lacking CPF/CNS should not delay care.',
        ),
        tips: _list(
          locale,
          pt: [
            'Municípios organizam território, agenda e documentos operacionais de formas diferentes; confirme diretamente na rede local.',
            'O Meu SUS Digital mostra o CNS existente e alguns serviços habilitados pelo município, mas não emite um novo número.',
            'A rede pública é ampla, porém oferta e espera variam por cidade, unidade, demanda, gravidade e especialidade; não há prazo uniforme garantido.',
          ],
          es: [
            'Los municipios organizan territorio, agenda y documentos operativos de formas distintas; confirma directamente en la red local.',
            'Meu SUS Digital muestra el CNS existente y algunos servicios habilitados por el municipio, pero no emite un número nuevo.',
            'La red pública es amplia, pero la oferta y la espera varían según ciudad, unidad, demanda, gravedad y especialidad; no hay un plazo uniforme garantizado.',
          ],
          en: [
            'Municipalities organize catchment areas, scheduling, and operational documents differently; confirm directly with the local network.',
            'Meu SUS Digital displays an existing CNS and some municipality-enabled services but does not issue a new number.',
            'The public network is broad, but availability and waits vary by city, facility, demand, severity, and specialty; there is no guaranteed uniform timeframe.',
          ],
        ),
        decisionOptions: [
          GuideDecisionOption(
            title: 'SUS',
            description: _t(
              locale,
              pt: 'Sistema público disponível a todas as pessoas no país; organize a UBS de referência para acompanhamento.',
              es: 'Sistema público disponible para todas las personas en el país; organiza la UBS de referencia para seguimiento.',
              en: 'Public system available to everyone in the country; identify your reference UBS for ongoing care.',
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'SUS + cobertura privada',
              es: 'SUS + cobertura privada',
              en: 'SUS + private coverage',
            ),
            description: _t(
              locale,
              pt: 'Compare operadoras registradas na ANS, rede, carências, coparticipação e dependentes.',
              es: 'Compara operadoras registradas en ANS, red, carencias, copago y dependientes.',
              en: 'Compare ANS-registered providers, networks, waiting periods, copays, and dependents.',
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Benefício do empregador',
              es: 'Beneficio del empleador',
              en: 'Employer benefit',
            ),
            description: _t(
              locale,
              pt: 'Confirme custo, coparticipação, carência, rede e regras para dependentes diretamente com o empregador.',
              es: 'Confirma costo, copago, carencia, red y reglas para dependientes directamente con el empleador.',
              en: 'Confirm cost, copay, waiting periods, network, and dependent rules with the employer.',
            ),
          ),
        ],
        communityTips: const <String>[],
        supportLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Como obter e usar o CNS',
              es: 'Cómo obtener y usar el CNS',
              en: 'How to obtain and use the CNS',
            ),
            url: PreparationResourceLinks.mySusDigitalCnsGuide.toString(),
          ),
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Direitos de migrantes no SUS',
              es: 'Derechos de migrantes en el SUS',
              en: 'Migrants’ rights in SUS',
            ),
            url: PreparationResourceLinks.migrantSusRightsGuide.toString(),
          ),
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Quando usar UBS, UPA, SAMU ou hospital',
              es: 'Cuándo usar UBS, UPA, SAMU u hospital',
              en: 'When to use UBS, UPA, SAMU, or hospital',
            ),
            url: PreparationResourceLinks.susCareNetworkGuide.toString(),
          ),
        ],
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Ministério da Saúde · Cartão Nacional de Saúde',
          sourceUrl: PreparationResourceLinks.mySusDigitalCnsGuide.toString(),
          lastVerified: DateTime(2026, 7, 29),
          scopeNote: _t(
            locale,
            pt: 'Cadastro e documentos operacionais podem variar por município; o CNS facilita o registro, mas não condiciona o direito ao atendimento.',
            es: 'El registro y los documentos operativos pueden variar por municipio; el CNS facilita el registro, pero no condiciona el derecho a la atención.',
            en: 'Registration and operational documents may vary by municipality; the CNS facilitates records but does not condition the right to care.',
          ),
        ),
      ),
      'item_4_1_cnh' => item.copyWith(
        shortDescription: _t(
          locale,
          pt: 'A regra nacional permite dirigir por até 180 dias nas condições oficiais; depois, confirme o processo no DETRAN.',
          es: 'La regla nacional permite conducir hasta 180 días bajo las condiciones oficiales; después, confirma el proceso en DETRAN.',
          en: 'The national rule allows driving for up to 180 days under official conditions; then confirm the DETRAN process.',
        ),
        dependencies: const <String>['item_1_0_entry_proof'],
        tier: GuideItemTier.optional,
        context: _t(
          locale,
          pt: 'Este passo só importa para quem pretende dirigir. A Resolução CONTRAN nº 1.020/2025 é a referência nacional, e a documentação operacional é confirmada no DETRAN estadual.',
          es: 'Este paso solo importa a quien pretende conducir. La Resolución CONTRAN 1.020/2025 es la referencia nacional y la documentación operativa se confirma en DETRAN.',
          en: 'This step only matters if you plan to drive. CONTRAN Resolution 1,020/2025 is the national reference, while operational documents are confirmed with the state DETRAN.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Ver regra nacional atual',
          es: 'Ver regla nacional actual',
          en: 'See current national rule',
        ),
        primaryActionTarget: PreparationResourceLinks.foreignDrivingGuide
            .toString(),
        steps: _list(
          locale,
          pt: [
            'Antes de dirigir, confirme que a habilitação argentina está válida.',
            'Porte a habilitação, a PID quando aplicável, documento de identificação e prova da data de entrada.',
            'Conte o prazo de 180 dias a partir da entrada no Brasil.',
            'Se pretende continuar dirigindo, consulte o DETRAN do seu domicílio antes do fim do prazo.',
            'Use a lista do DETRAN para confirmar documentos, traduções, exames, taxas e agendamento.',
          ],
          es: [
            'Antes de conducir, confirma que la licencia argentina está vigente.',
            'Lleva licencia, PID cuando corresponda, documento de identidad y prueba de la fecha de entrada.',
            'Cuenta el plazo de 180 días desde el ingreso a Brasil.',
            'Si quieres seguir conduciendo, consulta DETRAN de tu domicilio antes del final del plazo.',
            'Usa la lista de DETRAN para confirmar documentos, traducciones, exámenes, tasas y turno.',
          ],
          en: [
            'Before driving, confirm the Argentine license is valid.',
            'Carry the license, an IDP when applicable, identification, and proof of entry date.',
            'Count the 180-day period from entry into Brazil.',
            'If you plan to keep driving, check your local DETRAN before the period ends.',
            'Use the DETRAN list to confirm documents, translations, exams, fees, and booking.',
          ],
        ),
        requirements: _list(
          locale,
          pt: [
            'Habilitação estrangeira válida',
            'PID quando aplicável',
            'Documento de identificação',
            'Comprovante da data de entrada',
            'Exigências do DETRAN estadual para obtenção da CNH após o prazo',
          ],
          es: [
            'Licencia extranjera vigente',
            'PID cuando corresponda',
            'Documento de identidad',
            'Comprobante de la fecha de entrada',
            'Requisitos de DETRAN estatal para obtener CNH después del plazo',
          ],
          en: [
            'Valid foreign license',
            'IDP when applicable',
            'Identification document',
            'Proof of entry date',
            'State DETRAN requirements for obtaining a CNH after the period',
          ],
        ),
        tips: const <String>[],
        decisionOptions: const <GuideDecisionOption>[],
        communityTips: const <String>[],
        costInfo: _t(
          locale,
          pt: 'Taxas, exames e documentos variam por estado; consulte o DETRAN do seu domicílio.',
          es: 'Tasas, exámenes y documentos varían por estado; consulta DETRAN de tu domicilio.',
          en: 'Fees, exams, and documents vary by state; check your local DETRAN.',
        ),
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'Senatran · Habilitação estrangeira',
            url: PreparationResourceLinks.foreignDrivingGuide.toString(),
          ),
        ],
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Senatran · Resolução CONTRAN nº 1.020/2025',
          sourceUrl: PreparationResourceLinks.foreignDrivingGuide.toString(),
          lastVerified: DateTime(2026, 7, 26),
        ),
      ),
      'item_4_5_registro_rnm' => item.copyWith(
        whyItMatters: _t(
          locale,
          pt: 'O registro gera o RNM e a CRNM depois da autorização ou do visto aplicável, inclusive em rotas permanentes.',
          es: 'El registro genera RNM y CRNM después de la autorización o visa aplicable, incluso en rutas permanentes.',
          en: 'Registration creates the RNM and CRNM after the applicable authorization or visa, including permanent routes.',
        ),
        requirements: _list(
          locale,
          pt: [
            'Visto temporário ou autorização de residência aprovada, conforme o caso',
            'Documentação indicada no serviço oficial para a modalidade',
            'Formulário e agendamento da Polícia Federal',
            'Taxa de emissão da CRNM quando aplicável',
          ],
          es: [
            'Visa temporaria o autorización de residencia aprobada, según el caso',
            'Documentación indicada en el servicio oficial para la modalidad',
            'Formulario y turno de la Policía Federal',
            'Tasa de emisión de CRNM cuando corresponda',
          ],
          en: [
            'Temporary visa or approved residence authorization, as applicable',
            'Documents listed by the official service for the route',
            'Federal Police form and appointment',
            'CRNM issuance fee when applicable',
          ],
        ),
        tips: _list(
          locale,
          pt: [
            'Visto temporário: o serviço oficial informa prazo de 90 dias após a entrada.',
            'Autorização de residência publicada: o serviço oficial informa prazo de 30 dias após a publicação no DOU.',
            'Acompanhe a confecção e só agende a retirada quando o sistema indicar que a carteira está pronta.',
          ],
          es: [
            'Visa temporaria: el servicio oficial informa 90 días después del ingreso.',
            'Autorización de residencia publicada: el servicio oficial informa 30 días después de la publicación en DOU.',
            'Sigue la fabricación y agenda el retiro solo cuando el sistema indique que la tarjeta está lista.',
          ],
          en: [
            'Temporary visa: the official service states 90 days after entry.',
            'Published residence authorization: the official service states 30 days after DOU publication.',
            'Track production and book pickup only when the system shows the card is ready.',
          ],
        ),
        urgencySignal: _t(
          locale,
          pt: 'Use o prazo correspondente ao seu caso: 90 dias após a entrada com visto temporário ou 30 dias após a publicação da autorização.',
          es: 'Usa el plazo de tu caso: 90 días después del ingreso con visa temporaria o 30 días después de la publicación de la autorización.',
          en: 'Use the deadline for your case: 90 days after entry with a temporary visa or 30 days after authorization publication.',
        ),
        costInfo: _t(
          locale,
          pt: 'A emissão da CRNM possui taxa oficial quando aplicável; confirme o valor vigente no serviço antes de gerar a GRU.',
          es: 'La emisión de CRNM tiene tasa oficial cuando corresponde; confirma el valor vigente antes de generar la GRU.',
          en: 'CRNM issuance has an official fee when applicable; confirm the current amount before generating the GRU.',
        ),
        evidence: GuideEvidence(
          type: GuideEvidenceType.official,
          sourceLabel: 'Polícia Federal · Registro e CRNM',
          sourceUrl: PreparationResourceLinks.rnMRegistrationGuide.toString(),
          lastVerified: DateTime(2026, 7, 26),
        ),
      ),
      'item_4_3_permanencia' => item.copyWith(
        applicabilityConditions: const <String>['temporary_residence_route'],
        tier: GuideItemTier.optional,
      ),
      'item_4_4_mei' => item.copyWith(
        dependencies: const <String>['item_2_1_govbr'],
        steps: _list(
          locale,
          pt: [
            'Confirme se sua atividade consta na lista vigente do MEI e se você atende aos demais requisitos.',
            'Confira se CPF e dados civis estão corretos antes da formalização.',
            'Acesse somente o Portal do Empreendedor e revise declarações e obrigações.',
            'Antes de faturar renda da Argentina ou de outro país, entenda o tratamento tributário dessa renda.',
          ],
          es: [
            'Confirma si tu actividad está en la lista vigente del MEI y si cumples los demás requisitos.',
            'Revisa que CPF y datos civiles estén correctos antes de formalizar.',
            'Accede solo al Portal do Empreendedor y revisa declaraciones y obligaciones.',
            'Antes de facturar ingresos de Argentina u otro país, entiende el tratamiento fiscal.',
          ],
          en: [
            'Confirm your activity is on the current MEI list and that you meet the other requirements.',
            'Check CPF and civil data before formalizing.',
            'Use only the Entrepreneur Portal and review declarations and obligations.',
            'Before invoicing Argentine or other foreign income, understand its tax treatment.',
          ],
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Abrir MEI não resolve automaticamente residência fiscal, renda exterior ou dupla tributação.',
            'A formalização oficial é gratuita; desconfie de boletos e sites que imitam o governo.',
          ],
          es: [
            'Abrir MEI no resuelve automáticamente residencia fiscal, ingresos del exterior ni doble tributación.',
            'La formalización oficial es gratuita; desconfía de facturas y sitios que imitan al gobierno.',
          ],
          en: [
            'Opening a MEI does not automatically resolve tax residence, foreign income, or double taxation.',
            'Official registration is free; beware of invoices and websites imitating the government.',
          ],
        ),
        communityTips: const <String>[],
      ),
      'item_1_3_money' => item.copyWith(
        shortDescription: _t(
          locale,
          pt: 'Você pode chegar com Pix para pagamentos, mesmo antes de abrir uma conta brasileira.',
          es: 'Puedes llegar con Pix para pagos, incluso antes de abrir una cuenta brasileña.',
          en: 'You can arrive ready to pay with Pix, even before opening a Brazilian account.',
        ),
        context: _t(
          locale,
          pt: 'Algumas carteiras disponíveis na Argentina já pagam Pix a comerciantes no Brasil por QR ou chave. Isso resolve pagamentos, mas não cria uma conta nem uma chave Pix brasileira.',
          es: 'Algunas billeteras disponibles en Argentina ya pagan Pix a comercios en Brasil por QR o clave. Esto resuelve pagos, pero no crea una cuenta ni una clave Pix brasileña.',
          en: 'Some wallets available in Argentina can already pay Brazilian merchants through Pix QR codes or keys. This enables payments but does not create a Brazilian Pix account or key.',
        ),
        steps: _list(
          locale,
          pt: [
            'Veja se a função de pagar Pix no Brasil está disponível na sua carteira; Mercado Pago, Prex e Belo são exemplos documentados, não recomendações.',
            'Compare o total debitado em pesos, dólares ou outro saldo, o valor recebido em reais, a cotação, tarifas, impostos, limites e suporte a estorno.',
            'Ative e valide a carteira antes da viagem; se fizer um teste, use um destinatário ou comércio confiável e um valor pequeno.',
            'Mantenha um cartão internacional ou outra forma independente de pagamento como contingência.',
          ],
          es: [
            'Revisa si la función para pagar Pix en Brasil está disponible en tu billetera; Mercado Pago, Prex y Belo son ejemplos documentados, no recomendaciones.',
            'Compara el total debitado en pesos, dólares u otro saldo, el importe recibido en reales, el tipo de cambio, comisiones, impuestos, límites y soporte para devoluciones.',
            'Activa y valida la billetera antes del viaje; si haces una prueba, usa un destinatario o comercio confiable y un importe pequeño.',
            'Mantén una tarjeta internacional u otro medio de pago independiente como respaldo.',
          ],
          en: [
            'Check whether Pix payments in Brazil are available in your wallet; Mercado Pago, Prex, and Belo are documented examples, not endorsements.',
            'Compare the total charged in pesos, dollars, or another balance, the BRL received, exchange rate, fees, taxes, limits, and refund support.',
            'Enable and verify the wallet before travelling; if you test it, use a trusted recipient or merchant and a small amount.',
            'Keep an international card or another independent payment method as backup.',
          ],
        ),
        requirements: _list(
          locale,
          pt: [
            'Carteira compatível ou cartão habilitado para uso internacional',
            'Conta verificada e saldo compatível com a forma escolhida',
            'Segundo meio de pagamento independente',
          ],
          es: [
            'Billetera compatible o tarjeta habilitada para uso internacional',
            'Cuenta verificada y saldo compatible con la opción elegida',
            'Segundo medio de pago independiente',
          ],
          en: [
            'Compatible wallet or international-enabled card',
            'Verified account and a balance supported by the chosen option',
            'A second independent payment method',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você confirmou uma forma de pagar Pix no Brasil ou outra opção principal e mantém um segundo meio independente.',
          es: 'Confirmaste una forma de pagar Pix en Brasil u otra opción principal y mantienes un segundo medio independiente.',
          en: 'You confirmed a way to pay with Pix in Brazil or another primary option and retain a second independent method.',
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'money_pix_wallet',
            title: _t(
              locale,
              pt: 'Disponibilidade, saldo, câmbio e limites conferidos',
              es: 'Disponibilidad, saldo, cambio y límites revisados',
              en: 'Availability, balance, exchange rate, and limits checked',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'money_recipient_check',
            title: _t(
              locale,
              pt: 'Fluxo de conferência do destinatário entendido',
              es: 'Flujo para revisar al destinatario entendido',
              en: 'Recipient-check flow understood',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'money_backup',
            title: _t(
              locale,
              pt: 'Segundo meio de pagamento preparado',
              es: 'Segundo medio de pago preparado',
              en: 'Second payment method prepared',
            ),
            isCompleted: false,
          ),
        ],
        decisionOptions: [
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Carteira argentina com Pix no Brasil',
              es: 'Billetera argentina con Pix en Brasil',
              en: 'Argentina-based wallet with Pix in Brazil',
            ),
            description: _t(
              locale,
              pt: 'Pague QR ou chave Pix com o saldo aceito pela carteira, sem esperar a abertura de conta brasileira.',
              es: 'Paga un QR o una clave Pix con el saldo admitido por la billetera, sin esperar a abrir una cuenta brasileña.',
              en: 'Pay a Pix QR code or key with a wallet-supported balance without waiting for a Brazilian account.',
            ),
            pros: _list(
              locale,
              pt: [
                'Pode funcionar antes da viagem',
                'Aceito onde o comércio recebe Pix',
              ],
              es: [
                'Puede funcionar antes del viaje',
                'Sirve donde el comercio recibe Pix',
              ],
              en: [
                'May work before travel',
                'Works where the merchant receives Pix',
              ],
            ),
            cons: _list(
              locale,
              pt: [
                'Não equivale a uma conta Pix brasileira',
                'Câmbio, limites e disponibilidade variam',
              ],
              es: [
                'No equivale a una cuenta Pix brasileña',
                'Cambio, límites y disponibilidad varían',
              ],
              en: [
                'Not equivalent to a Brazilian Pix account',
                'Rates, limits, and availability vary',
              ],
            ),
            recommended: true,
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Cartão habilitado para uso internacional',
              es: 'Tarjeta habilitada para uso internacional',
              en: 'International-enabled card',
            ),
            description: _t(
              locale,
              pt: 'Confirme câmbio, impostos, saque, limites e bloqueios com o emissor.',
              es: 'Confirma cambio, impuestos, retiro, límites y bloqueos con el emisor.',
              en: 'Confirm exchange, taxes, withdrawals, limits, and blocks with the issuer.',
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Serviço regulado de remessa ou câmbio',
              es: 'Servicio regulado de remesa o cambio',
              en: 'Regulated transfer or FX service',
            ),
            description: _t(
              locale,
              pt: 'Compare valor final em reais, tarifa, prazo, limite e forma de retirada.',
              es: 'Compara valor final en reales, tarifa, plazo, límite y forma de retiro.',
              en: 'Compare final BRL amount, fee, timing, limit, and pickup method.',
            ),
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Reserva pequena em espécie',
              es: 'Reserva pequeña en efectivo',
              en: 'Small cash reserve',
            ),
            description: _t(
              locale,
              pt: 'Serve como contingência, com atenção a segurança e regras aduaneiras.',
              es: 'Sirve como contingencia, con atención a seguridad y reglas aduaneras.',
              en: 'A contingency option, subject to safety and customs rules.',
            ),
          ),
        ],
        tips: _list(
          locale,
          pt: [
            'No comércio, você pode dizer que pagará com Pix mesmo usando uma carteira estrangeira.',
            'Antes de confirmar, confira nome do destinatário, valor em reais e total que será debitado.',
            'Compare pelo valor líquido que chega em reais, não apenas pela cotação anunciada.',
            'Tenha duas formas independentes de pagamento e confirme as condições novamente perto da viagem.',
          ],
          es: [
            'En el comercio, puedes decir que pagarás con Pix aunque uses una billetera extranjera.',
            'Antes de confirmar, revisa el nombre del destinatario, el importe en reales y el total que se debitará.',
            'Compara por el valor neto que llega en reales, no solo por la cotización anunciada.',
            'Ten dos medios de pago independientes y confirma las condiciones cerca del viaje.',
          ],
          en: [
            'At the merchant, you can say you will pay with Pix even when using a foreign wallet.',
            'Before confirming, check the recipient name, BRL amount, and total to be charged.',
            'Compare the net BRL received, not only the advertised exchange rate.',
            'Keep two independent payment methods and reconfirm conditions close to travel.',
          ],
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Tarifas, câmbio, limites e disponibilidade podem mudar; a liberação de algumas funções pode ser gradual.',
            'Pix costuma ser imediato e pode não permitir cancelamento depois da confirmação.',
            'Não dependa de uma única empresa, cartão ou conta.',
          ],
          es: [
            'Comisiones, cambio, límites y disponibilidad pueden cambiar; la habilitación de algunas funciones puede ser gradual.',
            'Pix suele ser inmediato y puede no permitir cancelación después de confirmar.',
            'No dependas de una sola empresa, tarjeta o cuenta.',
          ],
          en: [
            'Fees, rates, limits, and availability can change; some features may roll out gradually.',
            'Pix is usually immediate and may not be cancellable after confirmation.',
            'Do not rely on one company, card, or account.',
          ],
        ),
        supportLinks: [
          GuideSupportLink(
            label: 'Mercado Pago · termos sobre Pix internacional',
            url: PreparationResourceLinks.mercadoPagoPixArgentina.toString(),
          ),
          GuideSupportLink(
            label: 'Prex · Pix Brasil',
            url: PreparationResourceLinks.prexPixBrazil.toString(),
          ),
          GuideSupportLink(
            label: 'Belo · pagamentos Pix no Brasil',
            url: PreparationResourceLinks.beloPixBrazil.toString(),
          ),
        ],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'Mercado Pago · Pix internacional',
            url: PreparationResourceLinks.mercadoPagoPixArgentina.toString(),
          ),
          GuideSupportLink(
            label: 'Prex · Pix Brasil',
            url: PreparationResourceLinks.prexPixBrazil.toString(),
          ),
          GuideSupportLink(
            label: 'Belo · Pix no Brasil',
            url: PreparationResourceLinks.beloPixBrazil.toString(),
          ),
        ],
        primaryActionType: GuidePrimaryActionType.none,
        costInfo: _t(
          locale,
          pt: 'Sem valor fixo: confira no app a cotação, as tarifas, os impostos e o total debitado antes de confirmar.',
          es: 'Sin valor fijo: revisa en la app el cambio, las comisiones, los impuestos y el total debitado antes de confirmar.',
          en: 'No fixed amount: check the rate, fees, taxes, and total charge in the app before confirming.',
        ),
        communityTips: const <String>[],
        evidence: GuideEvidence(
          type: GuideEvidenceType.marketReference,
          sourceLabel: 'Documentação dos produtos · verificação cruzada',
          sourceUrl: PreparationResourceLinks.mercadoPagoPixArgentina
              .toString(),
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'As marcas são exemplos de funções documentadas, não recomendações. Compare disponibilidade e condições atuais na sua própria conta.',
            es: 'Las marcas son ejemplos de funciones documentadas, no recomendaciones. Compara disponibilidad y condiciones vigentes en tu propia cuenta.',
            en: 'Brands are examples of documented features, not endorsements. Compare current availability and terms in your own account.',
          ),
        ),
      ),
      'item_3_1_conta_bancaria' => item.copyWith(
        requirements: _list(
          locale,
          pt: [
            'CPF',
            'Documento de identificação aceito pela instituição',
            'Dados de contato e outras comprovações solicitadas na análise individual',
          ],
          es: [
            'CPF',
            'Documento de identidad aceptado por la institución',
            'Datos de contacto y otros comprobantes solicitados en el análisis individual',
          ],
          en: [
            'CPF',
            'Identification accepted by the institution',
            'Contact details and other evidence requested in the individual review',
          ],
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'bank_compare',
            title: _t(
              locale,
              pt: 'Instituição confirmada no Banco Central',
              es: 'Institución confirmada en Banco Central',
              en: 'Institution confirmed with Central Bank',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'bank_requirements',
            title: _t(
              locale,
              pt: 'Documentos e tarifas confirmados diretamente',
              es: 'Documentos y tarifas confirmados directamente',
              en: 'Documents and fees confirmed directly',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'bank_access',
            title: _t(
              locale,
              pt: 'Conta aprovada e acesso protegido',
              es: 'Cuenta aprobada y acceso protegido',
              en: 'Account approved and access secured',
            ),
            isCompleted: false,
          ),
        ],
        communityTips: const <String>[],
      ),
      'item_3_3_pix' => item.copyWith(
        title: _t(
          locale,
          pt: 'Configure o Pix antes de chegar',
          es: 'Configura Pix antes de llegar',
          en: 'Set up Pix before you arrive',
        ),
        shortDescription: _t(
          locale,
          pt: 'Escolha entre pagar Pix por uma carteira estrangeira agora e ativar o Pix completo numa conta brasileira depois.',
          es: 'Elige entre pagar Pix con una billetera extranjera ahora y activar Pix completo en una cuenta brasileña después.',
          en: 'Choose between paying Pix through a foreign wallet now and enabling full Pix through a Brazilian account later.',
        ),
        phase: GuidePhase.preparation,
        dependencies: const <String>['item_1_3_money'],
        context: _t(
          locale,
          pt: 'Existem duas rotas diferentes: a carteira estrangeira pode pagar um Pix brasileiro por QR ou chave; uma conta brasileira permite, conforme a instituição, enviar, receber, cadastrar chave e pagar boletos.',
          es: 'Hay dos rutas distintas: una billetera extranjera puede pagar un Pix brasileño por QR o clave; una cuenta brasileña permite, según la institución, enviar, recibir, registrar una clave y pagar boletos.',
          en: 'There are two different routes: a foreign wallet can pay a Brazilian Pix QR code or key; a Brazilian account may let you send, receive, register a key, and pay boletos, depending on the institution.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Você pode pagar como um morador desde o primeiro dia sem confundir essa conveniência com ter uma conta bancária brasileira completa.',
          es: 'Puedes pagar como un residente desde el primer día sin confundir esa comodidad con tener una cuenta bancaria brasileña completa.',
          en: 'You can pay like a local from day one without confusing that convenience with a full Brazilian bank account.',
        ),
        steps: _list(
          locale,
          pt: [
            'Escolha a rota inicial: carteira estrangeira para pagar Pix ou conta brasileira para a experiência completa.',
            'Na carteira estrangeira, confirme disponibilidade, saldo aceito, câmbio, tarifas, impostos e limites.',
            'Ao escanear um QR ou informar uma chave, confira nome do beneficiário e valor em reais antes de confirmar.',
            'Depois de abrir uma conta brasileira, ative o Pix local e cadastre uma chave apenas se isso for útil para receber.',
          ],
          es: [
            'Elige la ruta inicial: billetera extranjera para pagar Pix o cuenta brasileña para la experiencia completa.',
            'En la billetera extranjera, confirma disponibilidad, saldo admitido, cambio, comisiones, impuestos y límites.',
            'Al escanear un QR o ingresar una clave, revisa el nombre del beneficiario y el importe en reales antes de confirmar.',
            'Después de abrir una cuenta brasileña, activa Pix local y registra una clave solo si te sirve para recibir.',
          ],
          en: [
            'Choose your starting route: a foreign wallet for Pix payments or a Brazilian account for the full experience.',
            'In the foreign wallet, confirm availability, supported balance, rate, fees, taxes, and limits.',
            'When scanning a QR code or entering a key, check the beneficiary name and BRL amount before confirming.',
            'After opening a Brazilian account, enable local Pix and register a key only if receiving through one is useful.',
          ],
        ),
        requirements: _list(
          locale,
          pt: [
            'Para pagar antes: carteira habilitada, conta verificada e saldo aceito',
            'Para Pix completo: conta brasileira aprovada e acesso seguro ao aplicativo',
          ],
          es: [
            'Para pagar antes: billetera habilitada, cuenta verificada y saldo admitido',
            'Para Pix completo: cuenta brasileña aprobada y acceso seguro a la app',
          ],
          en: [
            'For early payments: enabled wallet, verified account, and supported balance',
            'For full Pix: approved Brazilian account and secure app access',
          ],
        ),
        doneCriteria: _t(
          locale,
          pt: 'Você tem uma forma inicial de pagar Pix preparada e sabe se ela é somente para pagamentos ou se oferece a experiência completa de uma conta brasileira.',
          es: 'Tienes una forma inicial de pagar Pix preparada y sabes si sirve solo para pagos o si ofrece la experiencia completa de una cuenta brasileña.',
          en: 'You have an initial Pix payment method ready and know whether it is payment-only or provides the full Brazilian-account experience.',
        ),
        checklistItems: [
          ChecklistSubItem(
            id: 'pix_route',
            title: _t(
              locale,
              pt: 'Rota de Pix escolhida',
              es: 'Ruta de Pix elegida',
              en: 'Pix route selected',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'pix_costs',
            title: _t(
              locale,
              pt: 'Câmbio, tarifas, impostos e limites conferidos',
              es: 'Cambio, comisiones, impuestos y límites revisados',
              en: 'Rate, fees, taxes, and limits checked',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'pix_recipient',
            title: _t(
              locale,
              pt: 'Conferência do destinatário entendida',
              es: 'Verificación del destinatario entendida',
              en: 'Recipient verification understood',
            ),
            isCompleted: false,
          ),
        ],
        decisionOptions: [
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Pagar Pix por carteira estrangeira',
              es: 'Pagar Pix con billetera extranjera',
              en: 'Pay Pix through a foreign wallet',
            ),
            description: _t(
              locale,
              pt: 'Boa ponte para chegada: paga QR ou chave, mas normalmente não cria chave Pix brasileira nem habilita recebimentos.',
              es: 'Buen puente para la llegada: paga QR o clave, pero normalmente no crea una clave Pix brasileña ni habilita cobros.',
              en: 'A useful arrival bridge: it pays QR codes or keys but normally does not create a Brazilian Pix key or enable receiving.',
            ),
            recommended: true,
          ),
          GuideDecisionOption(
            title: _t(
              locale,
              pt: 'Pix completo em conta brasileira',
              es: 'Pix completo en cuenta brasileña',
              en: 'Full Pix through a Brazilian account',
            ),
            description: _t(
              locale,
              pt: 'Depois da aprovação da conta, use os recursos oferecidos pela instituição para enviar, receber e cadastrar chave.',
              es: 'Después de aprobar la cuenta, usa las funciones de la institución para enviar, recibir y registrar una clave.',
              en: 'After account approval, use the institution’s features to send, receive, and register a key.',
            ),
          ),
        ],
        tips: _list(
          locale,
          pt: [
            'Mercado Pago, Prex e Belo são exemplos documentados; não existe uma opção universalmente melhor.',
            'O recebedor vê um Pix em reais; o seu app mostra de qual saldo sairá o pagamento e a conversão aplicável.',
          ],
          es: [
            'Mercado Pago, Prex y Belo son ejemplos documentados; no existe una opción universalmente mejor.',
            'El destinatario recibe un Pix en reales; tu app muestra de qué saldo saldrá el pago y la conversión aplicable.',
          ],
          en: [
            'Mercado Pago, Prex, and Belo are documented examples; no option is universally best.',
            'The recipient receives BRL through Pix; your app shows the funding balance and applicable conversion.',
          ],
        ),
        warningFlags: _list(
          locale,
          pt: [
            'Uma carteira estrangeira para pagar Pix não cria uma conta ou chave Pix brasileira e pode não permitir receber Pix.',
            'Confira destinatário e valor antes de confirmar: pagamentos Pix costumam ser imediatos e podem não ser canceláveis.',
            'Disponibilidade, moedas aceitas, câmbio, tarifas e limites mudam; valide tudo no app no dia do uso.',
          ],
          es: [
            'Una billetera extranjera para pagar Pix no crea una cuenta o clave Pix brasileña y puede no permitir recibir Pix.',
            'Revisa destinatario e importe antes de confirmar: los pagos Pix suelen ser inmediatos y pueden no poder cancelarse.',
            'Disponibilidad, monedas admitidas, cambio, comisiones y límites cambian; valida todo en la app el día de uso.',
          ],
          en: [
            'A foreign wallet for Pix payments does not create a Brazilian Pix account or key and may not support receiving Pix.',
            'Check the recipient and amount before confirming: Pix payments are usually immediate and may not be cancellable.',
            'Availability, supported currencies, rates, fees, and limits change; verify them in-app on the day of use.',
          ],
        ),
        supportLinks: [
          GuideSupportLink(
            label: 'Mercado Pago · termos sobre Pix internacional',
            url: PreparationResourceLinks.mercadoPagoPixArgentina.toString(),
          ),
          GuideSupportLink(
            label: 'Prex · Pix Brasil',
            url: PreparationResourceLinks.prexPixBrazil.toString(),
          ),
          GuideSupportLink(
            label: 'Belo · pagamentos Pix no Brasil',
            url: PreparationResourceLinks.beloPixBrazil.toString(),
          ),
        ],
        costInfo: _t(
          locale,
          pt: 'Sem preço universal: o aplicativo deve mostrar a conversão e o total antes da confirmação.',
          es: 'Sin precio universal: la app debe mostrar la conversión y el total antes de confirmar.',
          en: 'No universal price: the app should show the conversion and total before confirmation.',
        ),
        estimatedTime: _t(
          locale,
          pt: '10–15 minutos',
          es: '10–15 minutos',
          en: '10–15 minutes',
        ),
        executionModes: const [GuideExecutionMode.online],
        tier: GuideItemTier.recommended,
        preArrivalRequired: false,
        communityTips: const <String>[],
        evidence: GuideEvidence(
          type: GuideEvidenceType.marketReference,
          sourceLabel: 'Mercado Pago, Prex e Belo · documentação dos produtos',
          sourceUrl: PreparationResourceLinks.mercadoPagoPixArgentina
              .toString(),
          lastVerified: DateTime(2026, 7, 26),
          scopeNote: _t(
            locale,
            pt: 'Referências comerciais demonstram a função disponível; não substituem a conferência das condições atuais da sua conta.',
            es: 'Las referencias comerciales demuestran la función disponible; no reemplazan revisar las condiciones vigentes de tu cuenta.',
            en: 'Commercial references demonstrate the available feature; they do not replace checking the current terms of your account.',
          ),
        ),
      ),
      'item_0_3_budget' => item.copyWith(
        preArrivalRequired: false,
        tier: GuideItemTier.recommended,
        primaryActionLabel: _t(
          locale,
          pt: 'Calcular reserva de chegada',
          es: 'Calcular reserva de llegada',
          en: 'Calculate landing budget',
        ),
      ),
      'item_0_6_medicamentos' => item.copyWith(
        warningFlags: _list(
          locale,
          pt: [
            'Não use uma quantidade fixa como regra; leve volume compatível com receita, laudo e normas da Anvisa.',
            'Medicamentos controlados podem exigir documentação ou procedimento específico.',
          ],
          es: [
            'No uses una cantidad fija como regla; lleva volumen compatible con receta, informe y normas de Anvisa.',
            'Los medicamentos controlados pueden exigir documentación o procedimiento específico.',
          ],
          en: [
            'Do not use a fixed quantity as a rule; carry an amount supported by prescriptions, records, and Anvisa rules.',
            'Controlled medicines may require specific documents or procedures.',
          ],
        ),
      ),
      'item_2_6_impostos_exterior' => item.copyWith(
        phase: GuidePhase.preparation,
        dependencies: const <String>[],
        preArrivalRequired: false,
        tier: GuideItemTier.recommended,
        warningFlags: _list(
          locale,
          pt: [
            'MEI, conta brasileira ou nota fiscal não resolvem automaticamente renda recebida do exterior.',
            'A data em que você passa a ser residente fiscal altera o tratamento dos rendimentos.',
          ],
          es: [
            'MEI, cuenta brasileña o factura no resuelven automáticamente ingresos del exterior.',
            'La fecha en que pasas a ser residente fiscal cambia el tratamiento de los ingresos.',
          ],
          en: [
            'MEI, a Brazilian account, or an invoice does not automatically resolve foreign income.',
            'The date you become tax resident changes the treatment of income.',
          ],
        ),
      ),
      'item_4_7_seguranca_emergencia' => item.copyWith(
        urgencyLevel: GuideUrgencyLevel.urgent,
        tier: GuideItemTier.recommended,
      ),
      _ => item,
    };
  }

  static GuideActionItem _sanitizeCostInfo(
    GuideActionItem item,
    String locale,
  ) {
    final costInfo = item.costInfo;
    if (costInfo == null || costInfo.trim().isEmpty) {
      return item;
    }

    if (!_looksLikeUnverifiedPrice(costInfo)) {
      return item;
    }

    final hasOfficialReference =
        (item.externalOfficialLinks?.isNotEmpty ?? false) ||
        (item.primaryActionTarget?.trim().isNotEmpty ?? false) ||
        (item.externalUrl?.trim().isNotEmpty ?? false);

    return item.copyWith(
      costInfo: hasOfficialReference
          ? _t(
              locale,
              pt: 'Consulte taxas e valores atualizados no canal oficial antes de avançar.',
              es: 'Consulta tasas y valores actualizados en el canal oficial antes de avanzar.',
              en: 'Check current fees and prices in the official channel before moving forward.',
            )
          : _t(
              locale,
              pt: 'Os custos podem mudar. Confirme o valor atualizado antes de seguir.',
              es: 'Los costos pueden cambiar. Confirma el valor actualizado antes de seguir.',
              en: 'Costs can change. Confirm the current amount before proceeding.',
            ),
    );
  }

  static bool _looksLikeUnverifiedPrice(String text) {
    final normalized = text.toLowerCase();
    final hasNumericPrice = RegExp(
      r'(\br\$ ?\d|\b\d+[.,]?\d* ?(ars|brl|usd|pesos?|reais?|dolares?))|(\b\d{2,}\b)',
    ).hasMatch(normalized);
    final hasFreeOrFeeClaim = RegExp(
      r'\b(gratuito|gratis|free|taxa baixa|small fee|tasa baja|sem mensalidade)\b',
    ).hasMatch(normalized);

    return hasNumericPrice || hasFreeOrFeeClaim;
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
          pt: 'Ver acordo oficial Brasil–Argentina',
          es: 'Ver acuerdo oficial Brasil–Argentina',
          en: 'See the official Brazil–Argentina agreement',
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
          pt: 'Acompanhar requerimento',
          es: 'Seguir requerimiento',
          en: 'Track request',
        ),
        subtitle: _t(
          locale,
          pt: 'Use isso para consultar o andamento depois do protocolo',
          es: 'Usa esto para consultar el avance despues del protocolo',
          en: 'Use this to check progress after your protocol is issued',
        ),
        officialUrl: PreparationResourceLinks.pfRequestTracking.toString(),
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
    final city = plan.currentPlanCity;
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
    final city = plan.currentPlanCity;
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
          pt: 'Consultar requerimento',
          es: 'Consultar requerimiento',
          en: 'Track request',
        ),
        url: PreparationResourceLinks.pfRequestTracking.toString(),
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
          pt: 'Comparar bancos digitais no celular',
          es: 'Comparar bancos digitales en el celular',
          en: 'Compare digital banks on your phone',
        ),
        subtitle: _t(
          locale,
          pt: 'Compare tarifas, documentos, Pix e suporte',
          es: 'Compará tarifas, documentos, Pix y soporte',
          en: 'Compare fees, documents, Pix, and support',
        ),
        officialUrl: 'https://www.bcb.gov.br/meubc/encontreinstituicao',
        officialLabel: 'Banco Central',
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
    final city = plan.currentPlanCity == null
        ? _t(
            locale,
            pt: 'sua cidade de destino',
            es: 'tu ciudad de destino',
            en: 'your destination city',
          )
        : '${plan.currentPlanCity!.name}, ${plan.currentPlanCity!.stateName}';
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
    final destinationCity = plan.currentPlanCity;
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
    final destinationCity = plan.currentPlanCity;
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
