import 'dart:async';
import 'dart:io';

import 'package:add_2_calendar_new/add_2_calendar_new.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/plan_notification_service.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_event_suggestion.dart';

class CalendarEventService {
  CalendarEventService({PlanNotificationService? notificationService})
    : _notificationService =
          notificationService ?? PlanNotificationService.instance;

  final PlanNotificationService _notificationService;

  Future<bool> addEvent({
    required GuideEventSuggestion suggestion,
    String? notes,
    GuideEventReminderOption? reminderOption,
  }) async {
    final selectedReminder = reminderOption ?? suggestion.defaultReminderOption;
    final description = [
      suggestion.description,
      if (suggestion.hardDeadline != null)
        'Deadline: ${suggestion.hardDeadline!.toIso8601String()}',
      if (notes != null && notes.trim().isNotEmpty) notes.trim(),
    ].join('\n\n');

    final event = Event(
      title: suggestion.title,
      description: description,
      location: suggestion.locationLabel,
      startDate: suggestion.startAt,
      endDate: suggestion.endAt,
      iosParams: IOSParams(reminder: _iosReminder(selectedReminder)),
    );

    final added = await _safeAddEvent(event);
    if (!added) {
      return false;
    }

    final offsets = _notificationOffsets(selectedReminder);
    if (offsets.isNotEmpty) {
      final granted = await _notificationService.requestPermissions();
      if (granted) {
        await _notificationService.scheduleGuideEventReminders(
          reminderKey: suggestion.id,
          title: suggestion.title,
          body: suggestion.description,
          eventDate: suggestion.startAt,
          offsets: offsets,
        );
      }
    }

    return true;
  }

  Future<bool> _safeAddEvent(Event event) async {
    try {
      final future = Add2Calendar.addEvent2Cal(event);
      if (Platform.isIOS) {
        return await future.timeout(
          const Duration(seconds: 4),
          onTimeout: () => true,
        );
      }
      return await future.timeout(
        const Duration(seconds: 12),
        onTimeout: () => false,
      );
    } catch (_) {
      return false;
    }
  }

  Duration? _iosReminder(GuideEventReminderOption option) {
    final offsets = _notificationOffsets(option);
    return offsets.isEmpty ? null : offsets.first;
  }

  List<Duration> _notificationOffsets(GuideEventReminderOption option) {
    return switch (option) {
      GuideEventReminderOption.none => const <Duration>[],
      GuideEventReminderOption.twoHoursBefore => const [Duration(hours: 2)],
      GuideEventReminderOption.oneDayBefore => const [Duration(days: 1)],
      GuideEventReminderOption.oneDayAndTwoHoursBefore => const [
        Duration(days: 1),
        Duration(hours: 2),
      ],
    };
  }
}
