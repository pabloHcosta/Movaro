enum GuideEventType { appointment, deadline, reminder }

enum GuideEventReminderOption {
  none,
  twoHoursBefore,
  oneDayBefore,
  oneDayAndTwoHoursBefore,
}

class GuideEventSuggestion {
  const GuideEventSuggestion({
    required this.id,
    required this.sourceItemId,
    required this.type,
    required this.title,
    required this.description,
    required this.assistantCopy,
    required this.startAt,
    required this.endAt,
    required this.suggestedDurationMinutes,
    this.locationLabel,
    this.hardDeadline,
    this.defaultReminderOption = GuideEventReminderOption.none,
    this.isHighPriority = false,
  });

  final String id;
  final String sourceItemId;
  final GuideEventType type;
  final String title;
  final String description;
  final String assistantCopy;
  final DateTime startAt;
  final DateTime endAt;
  final int suggestedDurationMinutes;
  final String? locationLabel;
  final DateTime? hardDeadline;
  final GuideEventReminderOption defaultReminderOption;
  final bool isHighPriority;

  GuideEventSuggestion copyWith({
    String? id,
    String? sourceItemId,
    GuideEventType? type,
    String? title,
    String? description,
    String? assistantCopy,
    DateTime? startAt,
    DateTime? endAt,
    int? suggestedDurationMinutes,
    Object? locationLabel = _noChange,
    Object? hardDeadline = _noChange,
    GuideEventReminderOption? defaultReminderOption,
    bool? isHighPriority,
  }) {
    return GuideEventSuggestion(
      id: id ?? this.id,
      sourceItemId: sourceItemId ?? this.sourceItemId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      assistantCopy: assistantCopy ?? this.assistantCopy,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      suggestedDurationMinutes:
          suggestedDurationMinutes ?? this.suggestedDurationMinutes,
      locationLabel: identical(locationLabel, _noChange)
          ? this.locationLabel
          : locationLabel as String?,
      hardDeadline: identical(hardDeadline, _noChange)
          ? this.hardDeadline
          : hardDeadline as DateTime?,
      defaultReminderOption:
          defaultReminderOption ?? this.defaultReminderOption,
      isHighPriority: isHighPriority ?? this.isHighPriority,
    );
  }
}

const Object _noChange = Object();
