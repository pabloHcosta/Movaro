import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum GuideFlowMetric {
  questionnaireStarted,
  questionAnswered,
  planGenerated,
  taskSelected,
  taskStarted,
  taskCompleted,
  fullPlanOpened,
}

class GuideFlowMetricEvent {
  const GuideFlowMetricEvent({
    required this.metric,
    required this.occurredAt,
    this.referenceId,
    this.stepIndex,
  });

  factory GuideFlowMetricEvent.fromJson(Map<String, dynamic> json) {
    return GuideFlowMetricEvent(
      metric: GuideFlowMetric.values.firstWhere(
        (metric) => metric.name == json['metric'],
      ),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      referenceId: json['referenceId'] as String?,
      stepIndex: json['stepIndex'] as int?,
    );
  }

  final GuideFlowMetric metric;
  final DateTime occurredAt;
  final String? referenceId;
  final int? stepIndex;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'metric': metric.name,
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    if (referenceId != null) 'referenceId': referenceId,
    if (stepIndex != null) 'stepIndex': stepIndex,
  };
}

/// Privacy-preserving product telemetry stored only on this installation.
///
/// No answer value, city, document, financial amount, or personal identifier is
/// persisted. The event trail is intentionally bounded and can later feed an
/// opt-in analytics adapter without changing product code.
class GuideFlowMetricsStore {
  GuideFlowMetricsStore({SharedPreferences? preferences})
    : _preferences = preferences;

  static final GuideFlowMetricsStore instance = GuideFlowMetricsStore();
  static const String storageKey = 'movaro.guide_flow_metrics.v1';
  static const int _maxEvents = 120;

  SharedPreferences? _preferences;

  Future<void> record(
    GuideFlowMetric metric, {
    String? referenceId,
    int? stepIndex,
  }) async {
    try {
      final preferences = _preferences ??=
          await SharedPreferences.getInstance();
      final events = await read();
      final next = <GuideFlowMetricEvent>[
        ...events,
        GuideFlowMetricEvent(
          metric: metric,
          occurredAt: DateTime.now(),
          referenceId: referenceId,
          stepIndex: stepIndex,
        ),
      ];
      final bounded = next.length <= _maxEvents
          ? next
          : next.sublist(next.length - _maxEvents);
      await preferences.setString(
        storageKey,
        jsonEncode(bounded.map((event) => event.toJson()).toList()),
      );
    } on Object {
      // Metrics must never interrupt the user flow.
    }
  }

  Future<List<GuideFlowMetricEvent>> read() async {
    final preferences = _preferences ??= await SharedPreferences.getInstance();
    final encoded = preferences.getString(storageKey);
    if (encoded == null || encoded.isEmpty) {
      return const <GuideFlowMetricEvent>[];
    }
    try {
      final decoded = jsonDecode(encoded) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(GuideFlowMetricEvent.fromJson)
          .toList(growable: false);
    } on Object {
      return const <GuideFlowMetricEvent>[];
    }
  }

  Future<void> clear() async {
    final preferences = _preferences ??= await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}
