import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
      const InitializationSettings(android: android, iOS: ios),
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await initialize();
    await _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
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
    await _notifications.cancel(1001);
    await _notifications.cancel(1002);
    await _notifications.cancel(1003);
  }

  Future<void> scheduleResidenceDeadlineReminder({
    required DateTime deadlineDate,
    required DateTime scheduledDate,
  }) async {
    await initialize();
    await _notifications.cancel(1103);
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

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  String? _getNextPendingItemTitle(MigrationPlan plan) {
    if (plan.destinationCountry.toUpperCase() == 'BR' &&
        plan.originCountry.toUpperCase() == 'AR') {
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
}
