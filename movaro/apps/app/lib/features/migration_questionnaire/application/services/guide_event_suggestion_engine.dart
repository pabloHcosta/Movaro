import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_event_suggestion.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class GuideEventSuggestionEngine {
  GuideEventSuggestionEngine({DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  List<GuideEventSuggestion> buildAll({
    required MigrationPlan plan,
    required List<GuideActionItem> items,
    required Map<String, String> completedAtById,
    required String localeCode,
  }) {
    return items
        .map(
          (item) => buildForItem(
            plan: plan,
            item: item,
            completedAtById: completedAtById,
            completedSteps: completedAtById.length,
            totalSteps: items.length,
            localeCode: localeCode,
          ),
        )
        .whereType<GuideEventSuggestion>()
        .toList(growable: false);
  }

  GuideEventSuggestion? buildForItem({
    required MigrationPlan plan,
    required GuideActionItem item,
    required Map<String, String> completedAtById,
    required int completedSteps,
    required int totalSteps,
    required String localeCode,
  }) {
    // This stays local so suggestions use the app locale supplied by the UI.
    // ignore: no_leading_underscores_for_local_identifiers
    String _text({
      required String pt,
      required String es,
      required String en,
    }) => switch (localeCode) {
      'pt' => pt,
      'es' => es,
      _ => en,
    };

    final stage = UserJourneyStageDetector.detect(
      timeline: plan.timeline,
      completedSteps: completedSteps,
      totalSteps: totalSteps,
    );
    final arrivalDate = _estimateArrivalDate(stage, plan.timeline);

    switch (item.id) {
      case 'item_0_2_antecedentes':
        final start = _nextBusinessDayAt(
          arrivalDate.subtract(const Duration(days: 30)),
          hour: 10,
        );
        return GuideEventSuggestion(
          id: 'event_${item.id}',
          sourceItemId: item.id,
          type: GuideEventType.reminder,
          title: _text(
            pt: 'Pedir antecedentes na Argentina',
            es: 'Pedir antecedentes en Argentina',
            en: 'Request criminal record certificate',
          ),
          description: _text(
            pt: 'Separe um bloco curto para emitir o certificado e salvar o PDF enquanto ele ainda estará válido para a residência.',
            es: 'Reserva un bloque corto para emitir el certificado y guardar el PDF mientras todavía estará vigente para la residencia.',
            en: 'Block a short slot to request the certificate and save the PDF while it will still be valid for residency.',
          ),
          assistantCopy: _text(
            pt: 'Esse documento vence rápido. Vale agendar agora para não perder a janela certa.',
            es: 'Este documento vence rápido. Conviene agendarlo ahora para no perder la ventana correcta.',
            en: 'This document expires quickly. It is worth scheduling now so you do not miss the right window.',
          ),
          startAt: start,
          endAt: start.add(const Duration(minutes: 30)),
          suggestedDurationMinutes: 30,
          defaultReminderOption: GuideEventReminderOption.oneDayBefore,
          isHighPriority: true,
        );
      case 'item_0_4_flight':
        final start = _nextBusinessDayAt(
          arrivalDate.subtract(const Duration(days: 21)),
          hour: 19,
        );
        return GuideEventSuggestion(
          id: 'event_${item.id}',
          sourceItemId: item.id,
          type: GuideEventType.reminder,
          title: _text(
            pt: 'Fechar voo e chegada',
            es: 'Cerrar vuelo y llegada',
            en: 'Lock flight and arrival plan',
          ),
          description: _text(
            pt: 'Reserve um momento para confirmar voo, primeira hospedagem e saída do aeroporto sem improviso.',
            es: 'Reserva un momento para confirmar vuelo, primer alojamiento y salida del aeropuerto sin improvisar.',
            en: 'Reserve time to confirm your flight, first stay, and airport exit plan without improvising.',
          ),
          assistantCopy: _text(
            pt: 'Quando isso entra no calendário, o resto da chegada começa a ficar concreto.',
            es: 'Cuando esto entra en tu calendario, el resto de la llegada empieza a volverse concreto.',
            en: 'Once this is on your calendar, the rest of the arrival becomes more concrete.',
          ),
          startAt: start,
          endAt: start.add(const Duration(minutes: 45)),
          suggestedDurationMinutes: 45,
          defaultReminderOption: GuideEventReminderOption.none,
        );
      case 'item_1_2_housing_temporary':
        final start = _nextBusinessDayAt(
          arrivalDate.subtract(const Duration(days: 10)),
          hour: 18,
        );
        return GuideEventSuggestion(
          id: 'event_${item.id}',
          sourceItemId: item.id,
          type: GuideEventType.reminder,
          title: _text(
            pt: 'Reservar moradia temporária',
            es: 'Reservar vivienda temporal',
            en: 'Book temporary housing',
          ),
          description: _text(
            pt: 'Agende um bloco para fechar sua primeira base com comprovante de endereço e boa localização.',
            es: 'Agenda un bloque para cerrar tu primera base con comprobante de domicilio y buena ubicación.',
            en: 'Schedule a block to secure your first base with proof of address and good location.',
          ),
          assistantCopy: _text(
            pt: 'Você não precisa decidir tudo agora. Só precisa sair desta etapa com uma base segura para os primeiros dias.',
            es: 'No necesitas decidirlo todo ahora. Solo necesitas salir de esta etapa con una base segura para los primeros días.',
            en: 'You do not need to solve everything now. You just need a safe base for your first days.',
          ),
          startAt: start,
          endAt: start.add(const Duration(minutes: 45)),
          suggestedDurationMinutes: 45,
          defaultReminderOption: GuideEventReminderOption.oneDayBefore,
        );
      case 'item_2_1_cpf':
        final start = _nextBusinessDayAt(
          arrivalDate.add(const Duration(days: 2)),
          hour: 10,
        );
        return GuideEventSuggestion(
          id: 'event_${item.id}',
          sourceItemId: item.id,
          type: GuideEventType.appointment,
          title: _text(
            pt: 'Resolver CPF',
            es: 'Resolver CPF',
            en: 'Get your CPF',
          ),
          description: _text(
            pt: 'Bloqueie um horário logo no início da chegada para tirar o CPF e destravar banco, aluguel e cadastros.',
            es: 'Bloquea un horario apenas llegues para sacar el CPF y destrabar banco, alquiler y registros.',
            en: 'Block time early after arrival to get your CPF and unlock banking, rentals, and registrations.',
          ),
          assistantCopy: _text(
            pt: 'Esse é o tipo de tarefa que parece pequena, mas muda toda a velocidade da mudança.',
            es: 'Este es el tipo de tarea que parece pequeña, pero cambia toda la velocidad de la mudanza.',
            en: 'This is the kind of task that looks small but changes the pace of the entire move.',
          ),
          startAt: start,
          endAt: start.add(const Duration(minutes: 90)),
          suggestedDurationMinutes: 90,
          locationLabel: _text(
            pt: 'Receita Federal ou Correios',
            es: 'Receita Federal o Correios',
            en: 'Receita Federal or Correios',
          ),
          defaultReminderOption:
              GuideEventReminderOption.oneDayAndTwoHoursBefore,
          isHighPriority: true,
        );
      case 'item_2_2_residencia':
        final start = _nextBusinessDayAt(
          arrivalDate.add(const Duration(days: 5)),
          hour: 9,
        );
        final deadline = arrivalDate.add(const Duration(days: 90));
        return GuideEventSuggestion(
          id: 'event_${item.id}',
          sourceItemId: item.id,
          type: GuideEventType.appointment,
          title: _text(
            pt: 'Atendimento na Polícia Federal',
            es: 'Turno en la Policía Federal',
            en: 'Federal Police appointment',
          ),
          description: _text(
            pt: 'Crie um placeholder para a visita presencial e ajuste o horário quando conseguir o turno oficial.',
            es: 'Crea un placeholder para la visita presencial y ajusta la hora cuando consigas el turno oficial.',
            en: 'Create a placeholder for the in-person visit and adjust the time when you secure the official slot.',
          ),
          assistantCopy: _text(
            pt: 'Você não precisa ter o turno exato agora. Colocar um bloco no calendário ajuda a tratar isso como prioridade real.',
            es: 'No necesitas tener el turno exacto ahora. Poner un bloque en el calendario ayuda a tratarlo como una prioridad real.',
            en: 'You do not need the exact slot yet. Putting a block on the calendar helps treat it as a real priority.',
          ),
          startAt: start,
          endAt: start.add(const Duration(hours: 2)),
          suggestedDurationMinutes: 120,
          locationLabel: _text(
            pt: 'Polícia Federal',
            es: 'Policía Federal',
            en: 'Federal Police',
          ),
          hardDeadline: deadline,
          defaultReminderOption:
              GuideEventReminderOption.oneDayAndTwoHoursBefore,
          isHighPriority: true,
        );
      case 'item_4_5_registro_rnm':
        final start = _nextBusinessDayAt(
          arrivalDate.add(const Duration(days: 30)),
          hour: 10,
        );
        return GuideEventSuggestion(
          id: 'event_${item.id}',
          sourceItemId: item.id,
          type: GuideEventType.deadline,
          title: _text(
            pt: 'Revisar registro RNM / CRNM',
            es: 'Revisar registro RNM / CRNM',
            en: 'Review RNM / CRNM registration',
          ),
          description: _text(
            pt: 'Use este lembrete para checar se a autorização saiu e se já abriu a etapa oficial de registro migratório.',
            es: 'Usa este recordatorio para revisar si ya salio la autorizacion y si ya se abrio la etapa oficial del registro migratorio.',
            en: 'Use this reminder to check whether residence has been granted and whether the official migration registration step has opened.',
          ),
          assistantCopy: _text(
            pt: 'Aqui o mais importante é não confundir protocolo inicial com registro final. O lembrete ajuda a fechar essa segunda etapa no momento certo.',
            es: 'Aqui lo importante es no confundir el protocolo inicial con el registro final. El recordatorio ayuda a cerrar esa segunda etapa en el momento correcto.',
            en: 'The important part here is not confusing the initial protocol with the final registration. This reminder helps close that second step at the right time.',
          ),
          startAt: start,
          endAt: start.add(const Duration(minutes: 30)),
          suggestedDurationMinutes: 30,
          locationLabel: _text(
            pt: 'Portal da Polícia Federal',
            es: 'Portal de la Policía Federal',
            en: 'Federal Police portal',
          ),
          defaultReminderOption: GuideEventReminderOption.oneDayBefore,
          isHighPriority: true,
        );
      case 'item_3_2_aluguel_fixo':
        final start = _nextBusinessDayAt(
          arrivalDate.add(const Duration(days: 14)),
          hour: 15,
        );
        return GuideEventSuggestion(
          id: 'event_${item.id}',
          sourceItemId: item.id,
          type: GuideEventType.appointment,
          title: _text(
            pt: 'Visitar imóveis para aluguel fixo',
            es: 'Visitar alquileres fijos',
            en: 'Visit long-term rentals',
          ),
          description: _text(
            pt: 'Separe um bloco para ver opções com calma depois de resolver CPF e sentir melhor os bairros.',
            es: 'Separa un bloque para ver opciones con calma después de resolver el CPF y entender mejor los barrios.',
            en: 'Set aside a block to visit options after resolving CPF and getting a better feel for neighborhoods.',
          ),
          assistantCopy: _text(
            pt: 'Aqui o calendário ajuda mais a criar ritmo do que a fixar um prazo legal.',
            es: 'Aquí el calendario ayuda más a crear ritmo que a fijar un plazo legal.',
            en: 'Here the calendar helps create momentum more than lock a legal deadline.',
          ),
          startAt: start,
          endAt: start.add(const Duration(hours: 2)),
          suggestedDurationMinutes: 120,
          defaultReminderOption: GuideEventReminderOption.oneDayBefore,
        );
      case 'item_4_1_cnh':
        final start = _nextBusinessDayAt(
          arrivalDate.add(const Duration(days: 21)),
          hour: 10,
        );
        return GuideEventSuggestion(
          id: 'event_${item.id}',
          sourceItemId: item.id,
          type: GuideEventType.appointment,
          title: _text(
            pt: 'Agendamento no DETRAN',
            es: 'Turno en DETRAN',
            en: 'DETRAN appointment',
          ),
          description: _text(
            pt: 'Use um bloco para separar os documentos e comparecer ao atendimento de conversão da CNH, se isso fizer parte do seu plano.',
            es: 'Usa un bloque para separar los documentos y asistir al turno de conversión de licencia, si esto forma parte de tu plan.',
            en: 'Use a block to gather documents and attend the driver license conversion appointment if this is part of your plan.',
          ),
          assistantCopy: _text(
            pt: 'Esse é um passo opcional para muita gente, mas fica mais simples quando você o trata como compromisso.',
            es: 'Este es un paso opcional para mucha gente, pero se vuelve más simple cuando lo tratas como un compromiso.',
            en: 'This is optional for many people, but it becomes easier when treated as a commitment.',
          ),
          startAt: start,
          endAt: start.add(const Duration(hours: 2)),
          suggestedDurationMinutes: 120,
          locationLabel: 'DETRAN',
          defaultReminderOption: GuideEventReminderOption.oneDayBefore,
        );
      case 'item_4_3_permanencia':
        final residenceCompletedAt =
            completedAtById['item_4_5_registro_rnm'] ??
            completedAtById['item_2_2_residencia'];
        final residenceDate = DateTime.tryParse(residenceCompletedAt ?? '');
        if (residenceDate == null) {
          return null;
        }
        final hardDeadline = residenceDate.add(const Duration(days: 730 - 90));
        final start = _nextBusinessDayAt(hardDeadline, hour: 10);
        return GuideEventSuggestion(
          id: 'event_${item.id}',
          sourceItemId: item.id,
          type: GuideEventType.deadline,
          title: _text(
            pt: 'Pedir residência permanente',
            es: 'Pedir residencia permanente',
            en: 'Apply for permanent residence',
          ),
          description: _text(
            pt: 'Marque a janela segura para protocolar a mudança da residência temporária para a permanente.',
            es: 'Marca la ventana segura para presentar el cambio de residencia temporaria a permanente.',
            en: 'Mark the safe window to file the move from temporary to permanent residence.',
          ),
          assistantCopy: _text(
            pt: 'Esse é um bom tipo de lembrete de longo prazo: importante, mas sem te encher de notificações agora.',
            es: 'Este es un buen tipo de recordatorio de largo plazo: importante, pero sin llenarte de notificaciones ahora.',
            en: 'This is a good long-term reminder: important, but without spamming you right now.',
          ),
          startAt: start,
          endAt: start.add(const Duration(minutes: 45)),
          suggestedDurationMinutes: 45,
          locationLabel: _text(
            pt: 'Polícia Federal',
            es: 'Policía Federal',
            en: 'Federal Police',
          ),
          hardDeadline: hardDeadline,
          defaultReminderOption: GuideEventReminderOption.oneDayBefore,
          isHighPriority: true,
        );
      case 'item_0_1_rule_90_days':
        final reviewDate = arrivalDate.subtract(const Duration(days: 14));
        final start = _nextBusinessDayAt(
          reviewDate.isBefore(DateTime.now()) ? DateTime.now() : reviewDate,
          hour: 9,
        );
        return GuideEventSuggestion(
          id: 'event_${item.id}',
          sourceItemId: item.id,
          type: GuideEventType.deadline,
          title: _text(
            pt: 'Revisar entrada e rota de residência',
            es: 'Revisar ingreso y ruta de residencia',
            en: 'Review entry and residence route',
          ),
          description: _text(
            pt: 'Confirme documentos de entrada e a base legal aplicável na página atual da Polícia Federal.',
            es: 'Confirmá documentos de ingreso y la base legal aplicable en la página vigente de la Policía Federal.',
            en: 'Confirm entry documents and the applicable legal basis on the current Federal Police page.',
          ),
          assistantCopy: _text(
            pt: 'É uma revisão preventiva, sem transformar orientação prática em prazo legal.',
            es: 'Es una revisión preventiva, sin convertir una orientación práctica en plazo legal.',
            en: 'This is a preventive review without turning practical guidance into a legal deadline.',
          ),
          startAt: start,
          endAt: start.add(const Duration(minutes: 20)),
          suggestedDurationMinutes: 20,
          hardDeadline: arrivalDate.add(const Duration(days: 90)),
          defaultReminderOption: GuideEventReminderOption.oneDayBefore,
          isHighPriority: true,
        );
      default:
        return null;
    }
  }

  DateTime _estimateArrivalDate(UserJourneyStage stage, String timeline) {
    final now = _now();
    final days = switch (stage) {
      UserJourneyStage.executor => 14,
      UserJourneyStage.planner => timeline == 'in_6_12m' ? 150 : 60,
      UserJourneyStage.explorer => 240,
    };
    return now.add(Duration(days: days));
  }

  DateTime _nextBusinessDayAt(DateTime base, {required int hour}) {
    var date = DateTime(base.year, base.month, base.day, hour);
    while (date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday ||
        date.isBefore(_now())) {
      date = date.add(const Duration(days: 1));
      date = DateTime(date.year, date.month, date.day, hour);
    }
    return date;
  }
}
