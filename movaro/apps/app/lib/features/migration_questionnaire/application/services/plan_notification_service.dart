import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_guide_registry.dart';
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
  bool _available = true;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    try {
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
    } catch (_) {
      _available = false;
    } finally {
      _initialized = true;
    }
  }

  Future<bool> requestPermissions() async {
    await initialize();
    if (!_available) return false;
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
    if (!_available) return;
    await cancelPlanReminders();

    final cityName =
        plan.currentPlanCity?.name ??
        _text(pt: 'sua cidade', es: 'tu ciudad', en: 'your city');
    final nextItem = _getNextPendingItemTitle(plan);

    await _scheduleNotification(
      id: 1001,
      title: _text(
        pt: 'Seu plano de $cityName está pronto',
        es: 'Tu plan para $cityName ya está listo',
        en: 'Your $cityName guide is ready to review',
      ),
      body: nextItem != null
          ? _text(
              pt: 'Próximo passo: $nextItem. Leva menos de 5 minutos.',
              es: 'Próximo paso: $nextItem. Te lleva menos de 5 minutos.',
              en: 'One possible next item: $nextItem. It may take less than 5 minutes.',
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
        en: 'Your guide is still available',
      ),
      body: nextItem != null
          ? _text(
              pt: 'Você ainda não concluiu: $nextItem. 5 minutos e está feito.',
              es: 'Todavía no completaste: $nextItem. En 5 minutos queda hecho.',
              en: 'You still have this item open: $nextItem. It may take around five minutes.',
            )
          : _text(
              pt: 'Volte ao guia e marque o próximo passo do seu plano.',
              es: 'Volvé a la guía y marcá el próximo paso de tu plan.',
              en: 'Return to the guide and continue with the item that feels most relevant now.',
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
    if (!_available) return;
    await _notifications.cancel(id: 1001);
    await _notifications.cancel(id: 1002);
    await _notifications.cancel(id: 1003);
  }

  /// Fires 1 day after plan creation to remind users to confirm the correct
  /// legal basis and review the current Federal Police instructions.
  Future<void> schedulePFAppointmentReminder(MigrationPlan plan) async {
    await initialize();
    if (!_available) return;
    final cityName = plan.currentPlanCity?.name ?? '';
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
              pt: 'Confirme a rota bilateral Brasil–Argentina e veja a agenda atual da PF em $cityName. Agendar cedo é uma recomendação prática, não um prazo universal.',
              es: 'Confirmá la ruta bilateral Brasil–Argentina y revisá la agenda actual de PF en $cityName. Agendar temprano es una recomendación práctica, no un plazo universal.',
              en: 'Confirm the Brazil–Argentina bilateral route and review the current PF schedule in $cityName. Booking early is practical guidance, not a universal deadline.',
            )
          : _text(
              pt: 'Confirme sua base legal e os requisitos atuais na página da Polícia Federal.',
              es: 'Confirmá tu base legal y los requisitos actuales en la página de la Policía Federal.',
              en: 'Confirm your legal basis and current requirements on the Federal Police page.',
            ),
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
    );
  }

  /// Cancels the PF appointment reminder (call when item_2_2_residencia
  /// is marked as complete).
  Future<void> cancelPFReminder() async {
    await initialize();
    if (!_available) return;
    await _notifications.cancel(id: 1201);
  }

  /// Fires after 7 days of inactivity to re-engage the user.
  /// [lastActivityDate] is the date of the last recorded app interaction.
  Future<void> scheduleReEngagementReminder(DateTime lastActivityDate) async {
    await initialize();
    if (!_available) return;
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
    if (!_available) return;
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
    if (!_available) return;
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
        pt: 'Revise a data registrada e confirme na Polícia Federal qual providência se aplica ao seu caso.',
        es: 'Revisá la fecha registrada y confirmá en la Policía Federal qué trámite corresponde a tu caso.',
        en: 'Review the saved date and confirm with Federal Police which action applies to your case.',
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
    if (!_available) return;
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
    if (!_available) return;
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
    if (MigrationGuideRegistry.supportsCorridor(
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
