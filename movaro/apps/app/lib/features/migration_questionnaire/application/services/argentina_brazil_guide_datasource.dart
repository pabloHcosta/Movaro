import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/preparation_resource_links.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/location/location_data.dart';

class ArgentinaBrazilGuideDataSource {
  const ArgentinaBrazilGuideDataSource._();

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
        phase: GuidePhase.housing,
        orderIndex: 5,
        isCompleted: false,
        icon: Icons.sim_card_outlined,
        context: _t(
          locale,
          pt: 'Um número brasileiro é necessário para SMS de bancos, apps de transporte e muitos cadastros.',
          es: 'Un numero brasileno es necesario para SMS de bancos, apps de transporte y muchos registros.',
          en: 'A Brazilian number is needed for bank SMS, transport apps, and many registrations.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Sem chip local, você não consegue ativar conta bancária, validar cadastros nem usar apps essenciais.',
          es: 'Sin chip local, no puedes activar cuenta bancaria, validar registros ni usar apps esenciales.',
          en: 'Without a local SIM, you cannot activate a bank account, validate registrations, or use essential apps.',
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
            'Compre um chip pré-pago no aeroporto ou loja de operadora.',
            'Ative com passaporte ou DNI no balcão.',
            'Registre o CPF assim que tiver para liberar mais serviços.',
          ],
          es: [
            'Compra un chip prepago en el aeropuerto o tienda de operadora.',
            'Activa con pasaporte o DNI en el mostrador.',
            'Registra el CPF apenas lo tengas para liberar mas servicios.',
          ],
          en: [
            'Buy a prepaid SIM at the airport or carrier store.',
            'Activate with your passport or national ID at the counter.',
            'Register your CPF as soon as you have it to unlock more services.',
          ],
        ),
        requirements: _list(
          locale,
          pt: ['Passaporte ou DNI', 'R\$ 20-50 para o chip e crédito inicial'],
          es: ['Pasaporte o DNI', 'R\$ 20-50 para el chip y credito inicial'],
          en: ['Passport or national ID', 'R\$ 20-50 for the SIM and initial credit'],
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
            'Guarde o número — ele será sua chave Pix depois.',
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
      ),
      GuideActionItem(
        id: 'item_2_1_cpf',
        title: _t(
          locale,
          pt: 'Tire seu CPF',
          es: 'Saca tu CPF',
          en: 'Get your CPF',
        ),
        shortDescription: _t(
          locale,
          pt: 'Esse é o primeiro documento que realmente destrava sua vida prática no Brasil.',
          es: 'Este es el primer documento que realmente destraba tu vida practica en Brasil.',
          en: 'This is the first document that truly unlocks practical life in Brazil.',
        ),
        fullContent: null,
        type: GuideActionType.informative,
        phase: GuidePhase.documents,
        orderIndex: 7,
        isCompleted: false,
        icon: Icons.badge_outlined,
        dependencies: <String>['item_1_1_chip'],
        context: _t(
          locale,
          pt: 'É o seu número fiscal no Brasil.',
          es: 'Es tu numero fiscal en Brasil.',
          en: 'It is your tax ID in Brazil.',
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
            'Veja se vai fazer na Receita Federal ou nos Correios.',
            'Separe DNI ou passaporte e um comprovante de endereço no Brasil.',
            'Faça o pedido e confirme o número emitido.',
          ],
          es: [
            'Mira si lo haras en Receita Federal o en Correios.',
            'Separa DNI o pasaporte y un comprobante de domicilio en Brasil.',
            'Haz el tramite y confirma el numero emitido.',
          ],
          en: [
            'Check whether you will do it at Receita Federal or Correios.',
            'Prepare your ID or passport and proof of address in Brazil.',
            'Submit the request and confirm the issued number.',
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
            'Não espere a residência sair. O CPF pode ser pedido antes.',
            'Se sua moradia for temporária, use um comprovante com seu nome e endereço.',
          ],
          es: [
            'No esperes a que salga la residencia. El CPF puede pedirse antes.',
            'Si tu vivienda es temporal, usa un comprobante con tu nombre y direccion.',
          ],
          en: [
            'Do not wait for residency to be approved. CPF can be requested before that.',
            'If your housing is temporary, use proof with your name and address.',
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
              pt: 'Reunir documentos (DNI + comprovante de endereço)',
              es: 'Reunir documentos (DNI + comprobante de domicilio)',
              en: 'Gather documents (ID + proof of address)',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'cpf_2',
            title: _t(
              locale,
              pt: 'Ir à Receita Federal ou Correios',
              es: 'Ir a Receita Federal o Correios',
              en: 'Go to Receita Federal or Correios',
            ),
            isCompleted: false,
          ),
          ChecklistSubItem(
            id: 'cpf_3',
            title: _t(
              locale,
              pt: 'Receber número do CPF',
              es: 'Recibir numero del CPF',
              en: 'Receive CPF number',
            ),
            isCompleted: false,
          ),
        ],
      ),
      GuideActionItem(
        id: 'item_2_2_residencia',
        title: _t(
          locale,
          pt: 'Solicite sua residência Mercosul',
          es: 'Solicita tu residencia Mercosur',
          en: 'Apply for your Mercosur residency',
        ),
        shortDescription: _t(
          locale,
          pt: 'Esse é o passo que regulariza sua permanência e dá base para trabalho e contratos.',
          es: 'Este es el paso que regulariza tu permanencia y da base para trabajo y contratos.',
          en: 'This is the step that regularizes your stay and supports work and contracts.',
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
          pt: 'Como argentino, você pode se regularizar no Brasil pela rota Mercosul.',
          es: 'Como argentino, puedes regularizarte en Brasil por la via Mercosur.',
          en: 'As an Argentine citizen, you can regularize in Brazil through the Mercosur path.',
        ),
        whyItMatters: _t(
          locale,
          pt: 'Isso evita ficar irregular após os 90 dias e libera etapas importantes de trabalho e estabilidade.',
          es: 'Esto evita quedar irregular despues de los 90 dias y libera etapas importantes de trabajo y estabilidad.',
          en: 'This keeps you from becoming irregular after 90 days and unlocks important work and stability steps.',
        ),
        primaryActionLabel: _t(
          locale,
          pt: 'Agendar na Polícia Federal',
          es: 'Pedir turno en la Policia Federal',
          en: 'Book Federal Police appointment',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: 'https://servicos.dpf.gov.br',
        steps: _list(
          locale,
          pt: [
            'Agende o atendimento o mais cedo possível.',
            'Monte a pasta com documentos, cópias, foto e comprovantes.',
            'Vá ao atendimento e guarde o protocolo recebido.',
          ],
          es: [
            'Saca el turno lo antes posible.',
            'Arma la carpeta con documentos, copias, foto y comprobantes.',
            'Asiste al turno y guarda el protocolo recibido.',
          ],
          en: [
            'Book the appointment as early as possible.',
            'Prepare the folder with documents, copies, photo, and proofs.',
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
            'Em muitas cidades, o gargalo é vaga. O ideal é agendar nos primeiros dias no Brasil.',
            'Leve originais e cópias para não perder a ida.',
          ],
          es: [
            'En muchas ciudades, el cuello de botella es el turno. Lo ideal es pedirlo en los primeros dias en Brasil.',
            'Lleva originales y copias para no perder la ida.',
          ],
          en: [
            'In many cities, the bottleneck is appointment availability. Ideally, book it in your first days in Brazil.',
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
              pt: 'Agendar no site da Polícia Federal',
              es: 'Pedir turno en el sitio de la Policia Federal',
              en: 'Book on the Federal Police website',
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
        dependencies: <String>['item_2_1_cpf'],
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
              pt: 'Banco digital',
              es: 'Banco digital',
              en: 'Digital bank',
            ),
            description: _t(
              locale,
              pt: 'Melhor caminho para abrir rápido usando CPF e app.',
              es: 'El mejor camino para abrir rapido usando CPF y app.',
              en: 'The best path to open fast using CPF and an app.',
            ),
            pros: _list(
              locale,
              pt: ['Processo simples', 'Baixo atrito inicial'],
              es: ['Proceso simple', 'Baja friccion inicial'],
              en: ['Simple process', 'Low initial friction'],
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
              pt: 'Escolher banco digital (Nubank, Inter ou C6)',
              es: 'Elegir banco digital (Nubank, Inter o C6)',
              en: 'Choose a digital bank (Nubank, Inter, or C6)',
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
        orderIndex: 11,
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
          es: ['CPF', 'Comprobante de ingresos o garante', 'Deposito de garantia'],
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
        orderIndex: 12,
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
        primaryActionTarget:
            PreparationResourceLinks.officialJobsPortal.toString(),
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
        orderIndex: 14,
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
          pt: 'Entenda sua cobertura de saúde no Brasil',
          es: 'Entiende tu cobertura de salud en Brasil',
          en: 'Understand your health coverage in Brazil',
        ),
        shortDescription: _t(
          locale,
          pt: 'Saúde não precisa esperar uma emergência. Defina cedo como você vai se atender.',
          es: 'La salud no tiene que esperar a una emergencia. Define temprano como te vas a atender.',
          en: 'Health should not wait for an emergency. Decide early how you will get care.',
        ),
        fullContent: null,
        type: GuideActionType.checklist,
        phase: GuidePhase.arrival,
        orderIndex: 15,
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
        primaryActionTarget:
            PreparationResourceLinks.susPortal.toString(),
        steps: _list(
          locale,
          pt: [
            'Veja se o SUS já cobre o que você precisa no começo.',
            'Se tiver CLT, confirme se o trabalho oferece plano.',
            'Se for autônomo, compare se vale contratar algo privado nos primeiros meses.',
            'Localize a UPA ou posto de saúde mais perto da sua casa.',
          ],
          es: [
            'Mira si el SUS ya cubre lo que necesitas al principio.',
            'Si tienes trabajo CLT, confirma si ofrece plan.',
            'Si eres autonomo, compara si vale contratar algo privado en los primeros meses.',
            'Localiza la UPA o puesto de salud mas cerca de tu casa.',
          ],
          en: [
            'Check whether SUS already covers what you need at the start.',
            'If you have CLT work, confirm whether it offers a health plan.',
            'If you are self-employed, compare whether private cover is worth it in the first months.',
            'Find the nearest UPA or health clinic to your home.',
          ],
        ),
        requirements: _list(
          locale,
          pt: ['CPF', 'Documento com foto'],
          es: ['CPF', 'Documento con foto'],
          en: ['CPF', 'Photo ID'],
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
            'O Cartão Nacional de Saúde (CNS) pode ser feito em qualquer UBS com CPF.',
          ],
          es: [
            'Incluso con plan, conviene saber que puesto o UPA atiende tu zona.',
            'El Cartao Nacional de Saude (CNS) se hace en cualquier UBS con CPF.',
          ],
          en: [
            'Even with a plan, it is worth knowing which clinic or UPA serves your area.',
            'The National Health Card (CNS) can be obtained at any UBS with your CPF.',
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
        orderIndex: 16,
        isCompleted: false,
        icon: Icons.event_available_outlined,
        dependencies: <String>['item_2_2_residencia'],
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
        primaryActionTarget:
            PreparationResourceLinks.pfPortal.toString(),
        steps: _list(
          locale,
          pt: [
            'Verifique a data de vencimento da sua residência temporária.',
            'Reúna os documentos exigidos (CPF, comprovante de endereço, antecedentes, protocolo de residência).',
            'Agende atendimento na Polícia Federal para solicitar a transformação.',
            'Compareça ao atendimento e acompanhe o andamento pelo portal.',
          ],
          es: [
            'Verifica la fecha de vencimiento de tu residencia temporaria.',
            'Reune los documentos requeridos (CPF, comprobante de domicilio, antecedentes, protocolo de residencia).',
            'Agenda turno en la Policia Federal para solicitar la transformacion.',
            'Asiste al turno y sigue el tramite por el portal.',
          ],
          en: [
            'Check the expiration date of your temporary residence.',
            'Gather required documents (CPF, proof of address, criminal record, residency protocol).',
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
        phase: GuidePhase.arrival,
        orderIndex: 17,
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
          primaryActionTarget:
              PreparationResourceLinks.diplomaValidationGuide.toString(),
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
        return const [
          'item_0_1_rule_90_days',
          'item_0_2_antecedentes',
          'item_0_3_budget',
          'item_1_3_money',
          'item_0_4_flight',
          'item_1_1_chip',
          'item_2_1_cpf',
          'item_2_2_residencia',
          'item_2_3_ctps',
          'item_3_1_conta_bancaria',
          'item_3_4_trabalho',
          'item_3_2_aluguel_fixo',
        ];
      case 'remote_income':
      case 'remote_work':
      case 'entrepreneur':
        return const [
          'item_0_1_rule_90_days',
          'item_0_2_antecedentes',
          'item_0_3_budget',
          'item_1_3_money',
          'item_0_4_flight',
          'item_1_1_chip',
          'item_2_1_cpf',
          'item_3_1_conta_bancaria',
          'item_4_4_mei',
          'item_3_4_trabalho',
          'item_3_2_aluguel_fixo',
        ];
      case 'study':
        return const [
          'item_0_1_rule_90_days',
          'item_0_2_antecedentes',
          'item_0_3_budget',
          'item_1_3_money',
          'item_0_4_flight',
          'item_1_1_chip',
          'item_2_1_cpf',
          'item_2_2_residencia',
          'item_3_1_conta_bancaria',
          'item_3_2_aluguel_fixo',
        ];
      case 'family_partner':
      case 'quality_of_life':
      case 'beach_life':
      case 'fresh_start':
        return const [
          'item_0_1_rule_90_days',
          'item_0_2_antecedentes',
          'item_0_3_budget',
          'item_1_3_money',
          'item_0_4_flight',
          'item_1_1_chip',
          'item_1_2_housing_temporary',
          'item_2_1_cpf',
          'item_2_2_residencia',
          'item_3_1_conta_bancaria',
          'item_3_2_aluguel_fixo',
          'item_4_2_saude',
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
          pt: 'Gratuito na Receita Federal. Pode haver taxa baixa se você usar atendimento parceiro.',
          es: 'Gratis en Receita Federal. Puede haber una tasa baja si usas un punto asociado.',
          en: 'Free at Receita Federal. There may be a small fee at partner service points.',
        ),
        requirements: _list(
          locale,
          pt: [
            'Documento de identidade',
            'Dados pessoais',
            'Comprovante de endereço quando solicitado',
          ],
          es: [
            'Documento de identidad',
            'Datos personales',
            'Comprobante de domicilio cuando se pida',
          ],
          en: [
            'Identity document',
            'Personal data',
            'Proof of address when requested',
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
              pt: 'Receita Federal',
              es: 'Receita Federal',
              en: 'Receita Federal',
            ),
            url: 'https://www.gov.br/pt-br/servicos/inscrever-no-cpf',
          ),
        ],
      ),
      'item_2_2_residencia' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Pode envolver taxas e custos de cópia, foto e deslocamento.',
          es: 'Puede incluir tasas y costos de copias, foto y traslado.',
          en: 'May involve fees plus copy, photo, and transport costs.',
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
        externalOfficialLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Polícia Federal',
              es: 'Policia Federal',
              en: 'Federal Police',
            ),
            url: 'https://www.gov.br/pf/pt-br/assuntos/imigracao',
          ),
        ],
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
        locationAwareOptions: _residencyOptions(plan, currentLocation, locale),
        mapLinks: _residencyMapLinks(plan, currentLocation, locale),
        externalOfficialLinks: [
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Polícia Federal - Imigração',
              es: 'Policia Federal - Inmigracion',
              en: 'Federal Police - Immigration',
            ),
            url: PreparationResourceLinks.pfPortal.toString(),
          ),
          GuideSupportLink(
            label: _t(
              locale,
              pt: 'Agendamento PF',
              es: 'Agendamiento PF',
              en: 'PF Scheduling',
            ),
            url: PreparationResourceLinks.pfScheduling.toString(),
          ),
        ],
      ),
      'item_0_2_antecedentes' => item.copyWith(
        costInfo: _t(
          locale,
          pt: 'Gratuito ou taxa baixa conforme o canal.',
          es: 'Gratis o tasa baja segun el canal.',
          en: 'Free or a small fee depending on channel.',
        ),
        primaryActionType: GuidePrimaryActionType.external,
        primaryActionTarget: 'https://www.argentina.gob.ar/justicia/reincidencia/antecedentespenales',
        executionModes: const [GuideExecutionMode.online],
        externalOfficialLinks: [
          GuideSupportLink(
            label: 'Registro Nacional de Reincidencia',
            url: 'https://www.argentina.gob.ar/justicia/reincidencia/antecedentespenales',
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
    return [
      GuideLocationAwareOption(
        title: _t(
          locale,
          pt: inDestination
              ? 'Atendimento presencial próximo'
              : 'Onde fazer ao chegar',
          es: inDestination
              ? 'Atencion presencial cercana'
              : 'Donde hacerlo al llegar',
          en: inDestination
              ? 'Nearby in-person option'
              : 'Where to do it when you arrive',
        ),
        subtitle: _t(
          locale,
          pt: inDestination
              ? 'Buscar Receita Federal ou parceiro autorizado'
              : 'Use $city como referência para planejar esse passo',
          es: inDestination
              ? 'Buscar Receita Federal o punto autorizado'
              : 'Usa $city como referencia para planear este paso',
          en: inDestination
              ? 'Search Receita Federal or an authorized point'
              : 'Use $city as the planning reference for this step',
        ),
        address: city,
        distanceKm: inDestination ? _distanceKm(plan, currentLocation) : null,
        mapUrl: _mapSearchUrl('Receita Federal $city'),
      ),
      GuideLocationAwareOption(
        title: _t(
          locale,
          pt: 'Ver instruções oficiais',
          es: 'Ver instrucciones oficiales',
          en: 'See official instructions',
        ),
        subtitle: _t(
          locale,
          pt: 'Passo a passo atualizado no portal oficial',
          es: 'Paso a paso actualizado en el portal oficial',
          en: 'Updated official step-by-step',
        ),
        officialUrl: 'https://www.gov.br/pt-br/servicos/inscrever-no-cpf',
        officialLabel: 'gov.br',
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
              : 'Use $city como referência para planejar o atendimento',
          es: inDestination
              ? 'Busca la unidad que atiende inmigracion'
              : 'Usa $city como referencia para planear la atencion',
          en: inDestination
              ? 'Search for the unit that handles immigration'
              : 'Use $city as your planning reference for the appointment',
        ),
        address: city,
        distanceKm: inDestination ? _distanceKm(plan, currentLocation) : null,
        mapUrl: _mapSearchUrl('Polícia Federal imigração $city'),
        officialUrl: 'https://servicos.dpf.gov.br',
        officialLabel: 'PF',
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
