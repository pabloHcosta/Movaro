import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/argentina_brazil_guide_datasource.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

class PlanNotificationService {
  PlanNotificationService._();

  static final PlanNotificationService instance = PlanNotificationService._();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'plan_reminders',
    'Lembretes do plano',
    description: 'Lembretes contextuais sobre seu plano de mudança',
    importance: Importance.defaultImportance,
  );

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    await _notifications.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();
    final iosGranted = await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final androidGranted = await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    return (iosGranted ?? true) && (androidGranted ?? true);
  }

  Future<void> scheduleOnboardingSequence(MigrationPlan plan) async {
    await initialize();
    await cancelPlanReminders();

    final cityName =
        plan.recommendedCity?.name ??
        _text(pt: 'sua cidade', es: 'tu ciudad', en: 'your city');
    final nextItem = _getNextPendingItemTitle(plan);

    await _scheduleNotification(
      id: 1001,
      title: _text(
        pt: 'Seu plano de $cityName está pronto',
        es: 'Tu plan para $cityName ya está listo',
        en: 'Your $cityName plan is ready',
      ),
      body: nextItem != null
          ? _text(
              pt: 'Próximo passo: $nextItem. Leva menos de 5 minutos.',
              es: 'Próximo paso: $nextItem. Te lleva menos de 5 minutos.',
              en: 'Next step: $nextItem. It takes less than 5 minutes.',
            )
          : _text(
              pt: 'Continue de onde parou no guia de mudança.',
              es: 'Seguı́ desde donde dejaste la guía de mudanza.',
              en: 'Continue where you left off in the moving guide.',
            ),
      scheduledDate: DateTime.now().add(const Duration(hours: 24)),
    );

    await _scheduleNotification(
      id: 1002,
      title: _text(
        pt: 'Seu plano ainda está te esperando',
        es: 'Tu plan todavía te está esperando',
        en: 'Your plan is still waiting for you',
      ),
      body: nextItem != null
          ? _text(
              pt: 'Você ainda não concluiu: $nextItem. 5 minutos e está feito.',
              es: 'Todavía no completaste: $nextItem. En 5 minutos queda hecho.',
              en: 'You still have not finished: $nextItem. Five minutes and it is done.',
            )
          : _text(
              pt: 'Volte ao guia e marque o próximo passo do seu plano.',
              es: 'Volvé a la guía y marcá el próximo paso de tu plan.',
              en: 'Return to the guide and mark the next step in your plan.',
            ),
      scheduledDate: DateTime.now().add(const Duration(hours: 72)),
    );

    await _scheduleNotification(
      id: 1003,
      title: _text(
        pt: 'Sua mudança ainda é possível',
        es: 'Tu mudanza todavía es posible',
        en: 'Your move is still possible',
      ),
      body: _text(
        pt: 'Seu plano de $cityName está salvo e pronto. Cada passo pequeno conta.',
        es: 'Tu plan para $cityName está guardado y listo. Cada paso pequeño cuenta.',
        en: 'Your $cityName plan is saved and ready. Every small step counts.',
      ),
      scheduledDate: DateTime.now().add(const Duration(days: 7)),
    );
  }

  Future<void> cancelPlanReminders() async {
    await initialize();
    await _notifications.cancel(id: 1001);
    await _notifications.cancel(id: 1002);
    await _notifications.cancel(id: 1003);
  }

  /// Fires 1 day after plan creation to remind users to schedule their
  /// Polícia Federal appointment (queues of 60–90 days in SP and RJ).
  Future<void> schedulePFAppointmentReminder(MigrationPlan plan) async {
    await initialize();
    final cityName =
        plan.recommendedCity?.name ?? plan.preferredCity?.name ?? '';
    final hasMajorCity =
        cityName.contains('São Paulo') ||
        cityName.contains('Rio') ||
        cityName.contains('Florianópolis');

    await _scheduleNotification(
      id: 1201,
      title: _text(
        pt: 'Revise a etapa da Polícia Federal',
        es: 'Revisa la etapa de la Policía Federal',
        en: 'Review the Federal Police step',
      ),
      body: hasMajorCity
          ? _text(
              pt: 'Se $cityName estiver com fila longa, adiantar a agenda ajuda. O principal é não deixar o protocolo para a reta final dos 90 dias.',
              es: 'Si $cityName tiene cola larga, adelantar el turno ayuda. Lo principal es no dejar el tramite para la recta final de los 90 dias.',
              en: 'If $cityName has a long backlog, booking earlier helps. The key is not leaving the filing to the final stretch of the 90 days.',
            )
          : _text(
              pt: 'Checar cedo a agenda da PF ajuda a evitar corrida no fim do prazo.',
              es: 'Revisar temprano la agenda de la PF ayuda a evitar correr al final del plazo.',
              en: 'Checking the PF schedule early helps avoid a rush near the deadline.',
            ),
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
    );
  }

  /// Cancels the PF appointment reminder (call when item_2_2_residencia
  /// is marked as complete).
  Future<void> cancelPFReminder() async {
    await initialize();
    await _notifications.cancel(id: 1201);
  }

  /// Fires after 7 days of inactivity to re-engage the user.
  /// [lastActivityDate] is the date of the last recorded app interaction.
  Future<void> scheduleReEngagementReminder(DateTime lastActivityDate) async {
    await initialize();
    final scheduledDate = lastActivityDate.add(const Duration(days: 7));
    if (!scheduledDate.isAfter(DateTime.now())) return;

    await _scheduleNotification(
      id: 1202,
      title: _text(
        pt: 'Você está no caminho certo',
        es: 'Estás en el camino correcto',
        en: 'You are on the right path',
      ),
      body: _text(
        pt: 'Seu próximo passo te espera. Cada avanço pequeno muda tudo.',
        es: 'Tu próximo paso te espera. Cada pequeño avance cambia todo.',
        en: 'Your next step is waiting. Every small advance changes everything.',
      ),
      scheduledDate: scheduledDate,
    );
  }

  /// Schedules a weekly city content notification for active users.
  Future<void> scheduleCityContentReminder(String cityLabel) async {
    await initialize();
    await _notifications.cancel(id: 1203);

    await _scheduleNotification(
      id: 1203,
      title: _text(
        pt: 'Nova dica para $cityLabel',
        es: 'Nuevo consejo para $cityLabel',
        en: 'New tip for $cityLabel',
      ),
      body: _text(
        pt: 'Confira o que acontece na cidade que você escolheu.',
        es: 'Mira qué pasa en la ciudad que elegiste.',
        en: 'See what is happening in the city you chose.',
      ),
      scheduledDate: DateTime.now().add(const Duration(days: 7)),
    );
  }

  Future<void> scheduleResidenceDeadlineReminder({
    required DateTime deadlineDate,
    required DateTime scheduledDate,
  }) async {
    await initialize();
    await _notifications.cancel(id: 1103);
    if (!scheduledDate.isAfter(DateTime.now())) {
      return;
    }

    await _scheduleNotification(
      id: 1103,
      title: _text(
        pt: 'Prazo se aproximando',
        es: 'El plazo se acerca',
        en: 'Deadline is getting close',
      ),
      body: _text(
        pt: 'Sua residência temporária vence em 30 dias. Solicite a permanente antes.',
        es: 'Tu residencia temporaria vence en 30 días. Solicitá la permanente antes.',
        en: 'Your temporary residence expires in 30 days. Apply for permanent residence first.',
      ),
      scheduledDate: scheduledDate,
    );
  }

  Future<void> scheduleGuideEventReminders({
    required String reminderKey,
    required String title,
    required String body,
    required DateTime eventDate,
    required List<Duration> offsets,
  }) async {
    await initialize();
    for (final offset in offsets) {
      final scheduledDate = eventDate.subtract(offset);
      if (!scheduledDate.isAfter(DateTime.now())) {
        continue;
      }
      await _scheduleNotification(
        id: _guideReminderId(reminderKey, offset),
        title: title,
        body: body,
        scheduledDate: scheduledDate,
      );
    }
  }

  Future<void> cancelGuideEventReminders({
    required String reminderKey,
    required List<Duration> offsets,
  }) async {
    await initialize();
    for (final offset in offsets) {
      await _notifications.cancel(id: _guideReminderId(reminderKey, offset));
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  String? _getNextPendingItemTitle(MigrationPlan plan) {
    if (ArgentinaBrazilGuideDataSource.isArgentinaToBrazil(
      plan.originCountry,
      plan.destinationCountry,
    )) {
      if (plan.goal == 'find_job_br') {
        return _text(
          pt: 'tirar seu CPF',
          es: 'sacar tu CPF',
          en: 'get your CPF',
        );
      }
      return _text(
        pt: 'ver seus documentos para o Brasil',
        es: 'ver tus documentos para Brasil',
        en: 'review your documents for Brazil',
      );
    }
    return _text(
      pt: 'abrir seu guia de mudança',
      es: 'abrir tu guía de mudanza',
      en: 'open your moving guide',
    );
  }

  String _text({required String pt, required String es, required String en}) {
    final code = PlatformDispatcher.instance.locale.languageCode;
    return switch (code) {
      'pt' => pt,
      'es' => es,
      _ => en,
    };
  }

  int _guideReminderId(String reminderKey, Duration offset) {
    return Object.hash(reminderKey, offset.inMinutes) & 0x7fffffff;
  }
}
