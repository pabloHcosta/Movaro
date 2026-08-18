import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GuideFlowMetric {
  questionnaireStarted,
  questionAnswered,
  refinementEvaluated,
  planGenerated,
  recommendationViewed,
  primaryCityExplored,
  alternativeCityExplored,
  comparisonOpened,
  recommendationAccepted,
  recommendationFeedbackPositive,
  recommendationFeedbackNegative,
  taskSelected,
  taskSheetOpened,
  taskSheetClosedIncomplete,
  taskBlocked,
  taskStarted,
  taskWaiting,
  taskResumed,
  taskDismissed,
  taskCompleted,
  officialLinkOpened,
  officialLinkReturned,
  officialLinkFailed,
  detailsExpanded,
  fullPlanOpened,
}

enum ProductAnalyticsConsent { undecided, granted, denied }

abstract interface class GuideFlowMetricsSink {
  Future<Set<String>> upload({
    required String installationToken,
    required List<GuideFlowUploadEvent> events,
  });
}

class GuideFlowUploadEvent {
  const GuideFlowUploadEvent({
    required this.eventId,
    required this.metric,
    required this.occurredAt,
    this.stepIndex,
    this.methodologyVersion,
    this.stabilityBand,
    this.coverageBand,
    this.rankPosition,
    this.refinementStatus,
    this.refinementQuestionId,
    this.refinementGainBand,
    this.refinementScenariosEvaluated,
  });

  final String eventId;
  final GuideFlowMetric metric;
  final DateTime occurredAt;
  final int? stepIndex;
  final String? methodologyVersion;
  final String? stabilityBand;
  final String? coverageBand;
  final int? rankPosition;
  final String? refinementStatus;
  final String? refinementQuestionId;
  final String? refinementGainBand;
  final int? refinementScenariosEvaluated;
}

class GuideFlowMetricEvent {
  const GuideFlowMetricEvent({
    required this.eventId,
    required this.metric,
    required this.occurredAt,
    this.referenceId,
    this.stepIndex,
    this.methodologyVersion,
    this.stabilityBand,
    this.coverageBand,
    this.rankPosition,
    this.refinementStatus,
    this.refinementQuestionId,
    this.refinementGainBand,
    this.refinementScenariosEvaluated,
  });

  factory GuideFlowMetricEvent.fromJson(Map<String, dynamic> json) {
    return GuideFlowMetricEvent(
      eventId:
          json['eventId'] as String? ??
          'legacy-${json['occurredAt']}-${json['metric']}',
      metric: GuideFlowMetric.values.firstWhere(
        (metric) => metric.name == json['metric'],
      ),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      referenceId: json['referenceId'] as String?,
      stepIndex: json['stepIndex'] as int?,
      methodologyVersion: json['methodologyVersion'] as String?,
      stabilityBand: json['stabilityBand'] as String?,
      coverageBand: json['coverageBand'] as String?,
      rankPosition: json['rankPosition'] as int?,
      refinementStatus: json['refinementStatus'] as String?,
      refinementQuestionId: json['refinementQuestionId'] as String?,
      refinementGainBand: json['refinementGainBand'] as String?,
      refinementScenariosEvaluated:
          json['refinementScenariosEvaluated'] as int?,
    );
  }

  final String eventId;
  final GuideFlowMetric metric;
  final DateTime occurredAt;

  /// Stored on-device for diagnosing the funnel, but intentionally never sent
  /// to the aggregate endpoint because it can reveal a document or task.
  final String? referenceId;
  final int? stepIndex;
  final String? methodologyVersion;
  final String? stabilityBand;
  final String? coverageBand;
  final int? rankPosition;
  final String? refinementStatus;
  final String? refinementQuestionId;
  final String? refinementGainBand;
  final int? refinementScenariosEvaluated;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'eventId': eventId,
    'metric': metric.name,
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    if (referenceId != null) 'referenceId': referenceId,
    if (stepIndex != null) 'stepIndex': stepIndex,
    if (methodologyVersion != null) 'methodologyVersion': methodologyVersion,
    if (stabilityBand != null) 'stabilityBand': stabilityBand,
    if (coverageBand != null) 'coverageBand': coverageBand,
    if (rankPosition != null) 'rankPosition': rankPosition,
    if (refinementStatus != null) 'refinementStatus': refinementStatus,
    if (refinementQuestionId != null)
      'refinementQuestionId': refinementQuestionId,
    if (refinementGainBand != null) 'refinementGainBand': refinementGainBand,
    if (refinementScenariosEvaluated != null)
      'refinementScenariosEvaluated': refinementScenariosEvaluated,
  };
}

/// Consent-gated, privacy-preserving product telemetry.
///
/// Events contain funnel names, timestamps and bounded diagnostic bands.
/// Answer values, city, recommendation id, document, money, location, task
/// reference and account data are never uploaded. A random installation token
/// supports aggregate retention cohorts and is deleted with diagnostics.
class GuideFlowMetricsStore extends ChangeNotifier {
  GuideFlowMetricsStore({
    SharedPreferences? preferences,
    GuideFlowMetricsSink? sink,
  }) : _preferences = preferences,
       _sink = sink;

  static final GuideFlowMetricsStore instance = GuideFlowMetricsStore();
  static const String storageKey = 'movaro.guide_flow_metrics.v2';
  static const String _legacyStorageKey = 'movaro.guide_flow_metrics.v1';
  static const String _consentKey = 'movaro.product_analytics.consent.v1';
  static const String _installationTokenKey =
      'movaro.product_analytics.installation.v1';
  static const String _uploadedIdsKey =
      'movaro.product_analytics.uploaded_ids.v1';
  static const int _maxEvents = 160;

  SharedPreferences? _preferences;
  GuideFlowMetricsSink? _sink;
  ProductAnalyticsConsent _consent = ProductAnalyticsConsent.undecided;
  bool _initialized = false;
  bool _isUploading = false;

  ProductAnalyticsConsent get consent => _consent;
  bool get isEnabled => _consent == ProductAnalyticsConsent.granted;
  bool get isUploading => _isUploading;

  Future<void> initialize({GuideFlowMetricsSink? sink}) async {
    if (sink != null) {
      _sink = sink;
    }
    final preferences = _preferences ??= await SharedPreferences.getInstance();
    final stored = preferences.getString(_consentKey);
    _consent = ProductAnalyticsConsent.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => ProductAnalyticsConsent.undecided,
    );
    _initialized = true;
    if (isEnabled) {
      await flush();
    }
  }

  Future<void> setConsent(ProductAnalyticsConsent value) async {
    final preferences = _preferences ??= await SharedPreferences.getInstance();
    _consent = value;
    _initialized = true;
    await preferences.setString(_consentKey, value.name);
    if (value == ProductAnalyticsConsent.denied) {
      await _clearEventTrail(preferences);
    }
    notifyListeners();
    if (value == ProductAnalyticsConsent.granted) {
      await flush();
    }
  }

  Future<void> record(
    GuideFlowMetric metric, {
    String? referenceId,
    int? stepIndex,
    String? methodologyVersion,
    String? stabilityBand,
    String? coverageBand,
    int? rankPosition,
    String? refinementStatus,
    String? refinementQuestionId,
    String? refinementGainBand,
    int? refinementScenariosEvaluated,
  }) async {
    try {
      if (!_initialized) {
        await initialize();
      }
      if (!isEnabled) {
        return;
      }
      final preferences = _preferences ??=
          await SharedPreferences.getInstance();
      final events = await read();
      final now = DateTime.now();
      final next = <GuideFlowMetricEvent>[
        ...events,
        GuideFlowMetricEvent(
          eventId: _newEventId(now),
          metric: metric,
          occurredAt: now,
          referenceId: referenceId,
          stepIndex: stepIndex,
          methodologyVersion: methodologyVersion,
          stabilityBand: stabilityBand,
          coverageBand: coverageBand,
          rankPosition: rankPosition,
          refinementStatus: refinementStatus,
          refinementQuestionId: refinementQuestionId,
          refinementGainBand: refinementGainBand,
          refinementScenariosEvaluated: refinementScenariosEvaluated,
        ),
      ];
      final bounded = next.length <= _maxEvents
          ? next
          : next.sublist(next.length - _maxEvents);
      await preferences.setString(
        storageKey,
        jsonEncode(bounded.map((event) => event.toJson()).toList()),
      );
      await flush();
    } on Object {
      // Metrics must never interrupt the user flow.
    }
  }

  Future<List<GuideFlowMetricEvent>> read() async {
    final preferences = _preferences ??= await SharedPreferences.getInstance();
    final encoded =
        preferences.getString(storageKey) ??
        preferences.getString(_legacyStorageKey);
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

  Future<void> flush() async {
    if (!isEnabled || _sink == null || _isUploading) {
      return;
    }
    _isUploading = true;
    notifyListeners();
    try {
      final preferences = _preferences ??=
          await SharedPreferences.getInstance();
      final uploadedIds =
          preferences.getStringList(_uploadedIdsKey)?.toSet() ?? <String>{};
      final pending = (await read())
          .where((event) => !uploadedIds.contains(event.eventId))
          .take(40)
          .toList(growable: false);
      if (pending.isEmpty) {
        return;
      }
      final acceptedIds = await _sink!.upload(
        installationToken: await _installationToken(preferences),
        events: pending
            .map(
              (event) => GuideFlowUploadEvent(
                eventId: event.eventId,
                metric: event.metric,
                occurredAt: event.occurredAt,
                stepIndex: event.stepIndex,
                methodologyVersion: event.methodologyVersion,
                stabilityBand: event.stabilityBand,
                coverageBand: event.coverageBand,
                rankPosition: event.rankPosition,
                refinementStatus: event.refinementStatus,
                refinementQuestionId: event.refinementQuestionId,
                refinementGainBand: event.refinementGainBand,
                refinementScenariosEvaluated:
                    event.refinementScenariosEvaluated,
              ),
            )
            .toList(growable: false),
      );
      if (acceptedIds.isNotEmpty) {
        final bounded = <String>{...uploadedIds, ...acceptedIds}.toList();
        final start = max(0, bounded.length - _maxEvents);
        await preferences.setStringList(
          _uploadedIdsKey,
          bounded.sublist(start),
        );
      }
    } on Object {
      // Offline or backend-not-ready: keep the bounded queue for a later flush.
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    final preferences = _preferences ??= await SharedPreferences.getInstance();
    await _clearEventTrail(preferences);
    await preferences.remove(_installationTokenKey);
    notifyListeners();
  }

  Future<void> _clearEventTrail(SharedPreferences preferences) async {
    await preferences.remove(storageKey);
    await preferences.remove(_legacyStorageKey);
    await preferences.remove(_uploadedIdsKey);
  }

  Future<String> _installationToken(SharedPreferences preferences) async {
    final existing = preferences.getString(_installationTokenKey);
    if (existing != null && existing.length >= 24) {
      return existing;
    }
    final random = Random.secure();
    final token = List<int>.generate(
      24,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    await preferences.setString(_installationTokenKey, token);
    return token;
  }

  String _newEventId(DateTime now) {
    final suffix = Random.secure().nextInt(1 << 32).toRadixString(16);
    return '${now.microsecondsSinceEpoch}-$suffix';
  }
}
