import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
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
    await scheduleContextualResumeReminder(plan: plan);
  }

  Future<void> cancelPlanReminders() async {
    await initialize();
    if (!_available) return;
    await _notifications.cancel(id: 1001);
    await _notifications.cancel(id: 1002);
    await _notifications.cancel(id: 1003);
    await _notifications.cancel(id: 1202);
    await _notifications.cancel(id: 1203);
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

  /// Keeps one relevant resume reminder instead of a daily streak or a generic
  /// multi-message campaign. No city, document or task title is placed on the
  /// lock screen.
  Future<void> scheduleContextualResumeReminder({
    required MigrationPlan plan,
    GuideActionItem? currentItem,
  }) async {
    await initialize();
    if (!_available) return;
    await _notifications.cancel(id: 1202);

    final delay = switch (currentItem?.urgencyLevel) {
      GuideUrgencyLevel.critical ||
      GuideUrgencyLevel.urgent => const Duration(days: 2),
      _ when plan.timeline == 'in_0_3m' => const Duration(days: 4),
      _ when plan.timeline == 'just_exploring' || plan.timeline == 'depends' =>
        const Duration(days: 14),
      _ => const Duration(days: 7),
    };

    await _scheduleNotification(
      id: 1202,
      title: _text(
        pt: 'Seu plano tem uma próxima ação',
        es: 'Tu plan tiene una próxima acción',
        en: 'Your plan has a next action',
      ),
      body: _text(
        pt: 'Abra para continuar exatamente de onde parou e revisar o que precisa de atenção.',
        es: 'Abrí para continuar exactamente desde donde quedaste y revisar qué necesita atención.',
        en: 'Open to continue exactly where you stopped and review what needs attention.',
      ),
      scheduledDate: DateTime.now().add(delay),
    );
  }

  @Deprecated('Use scheduleContextualResumeReminder')
  Future<void> scheduleReEngagementReminder(DateTime lastActivityDate) async {
    // Kept only for source compatibility with older callers.
  }

  /// City tips are no longer pushed on a timer. Content notifications must be
  /// tied to an actual source update before this method is re-enabled.
  @Deprecated('City content notifications require a real source update')
  Future<void> scheduleCityContentReminder(String cityLabel) async {
    await initialize();
    if (!_available) return;
    await _notifications.cancel(id: 1203);
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
