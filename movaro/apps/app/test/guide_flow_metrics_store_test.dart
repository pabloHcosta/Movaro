import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_flow_metrics_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores only bounded flow metadata without answer values', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final store = GuideFlowMetricsStore(preferences: preferences);
    await store.setConsent(ProductAnalyticsConsent.granted);

    await store.record(
      GuideFlowMetric.questionAnswered,
      referenceId: 'timeline',
      stepIndex: 2,
    );
    await store.record(
      GuideFlowMetric.taskCompleted,
      referenceId: 'item_2_1_cpf',
    );

    final events = await store.read();
    final raw = preferences.getString(GuideFlowMetricsStore.storageKey);

    expect(events.map((event) => event.metric), <GuideFlowMetric>[
      GuideFlowMetric.questionAnswered,
      GuideFlowMetric.taskCompleted,
    ]);
    expect(events.first.referenceId, 'timeline');
    expect(events.first.stepIndex, 2);
    expect(raw, isNot(contains('Argentina')));
    expect(raw, isNot(contains('answerValue')));
  });

  test('does not retain events when consent is denied', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final store = GuideFlowMetricsStore(preferences: preferences);

    await store.setConsent(ProductAnalyticsConsent.denied);
    await store.record(GuideFlowMetric.planGenerated);

    expect(await store.read(), isEmpty);
  });

  test('uploads only anonymous funnel metadata', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final sink = _RecordingSink();
    final store = GuideFlowMetricsStore(preferences: preferences, sink: sink);

    await store.setConsent(ProductAnalyticsConsent.granted);
    await store.record(
      GuideFlowMetric.taskStarted,
      referenceId: 'item_sensitive_document_name',
      stepIndex: 4,
    );

    expect(sink.events, hasLength(1));
    expect(sink.events.single.metric, GuideFlowMetric.taskStarted);
    expect(sink.installationToken, hasLength(48));
  });

  test(
    'uploads bounded recommendation quality bands without profile data',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final preferences = await SharedPreferences.getInstance();
      final sink = _RecordingSink();
      final store = GuideFlowMetricsStore(preferences: preferences, sink: sink);

      await store.setConsent(ProductAnalyticsConsent.granted);
      await store.record(
        GuideFlowMetric.recommendationAccepted,
        referenceId: 'private-recommendation-id',
        methodologyVersion: 'city-recommendation-v2.1.0',
        stabilityBand: 'robust',
        coverageBand: 'broad',
        rankPosition: 1,
      );

      final event = sink.events.single;
      expect(event.metric, GuideFlowMetric.recommendationAccepted);
      expect(event.methodologyVersion, 'city-recommendation-v2.1.0');
      expect(event.stabilityBand, 'robust');
      expect(event.coverageBand, 'broad');
      expect(event.rankPosition, 1);
      expect(
        preferences.getString(GuideFlowMetricsStore.storageKey),
        contains('private-recommendation-id'),
      );
    },
  );

  test('uploads adaptive gain diagnostics without answers or cities', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final sink = _RecordingSink();
    final store = GuideFlowMetricsStore(preferences: preferences, sink: sink);

    await store.setConsent(ProductAnalyticsConsent.granted);
    await store.record(
      GuideFlowMetric.refinementEvaluated,
      methodologyVersion: 'city-recommendation-v2.3.0',
      stabilityBand: 'sensitive',
      refinementStatus: 'ask',
      refinementQuestionId: 'work_arrangement',
      refinementGainBand: 'high',
      refinementScenariosEvaluated: 8,
    );

    final event = sink.events.single;
    expect(event.metric, GuideFlowMetric.refinementEvaluated);
    expect(event.methodologyVersion, 'city-recommendation-v2.3.0');
    expect(event.stabilityBand, 'sensitive');
    expect(event.refinementStatus, 'ask');
    expect(event.refinementQuestionId, 'work_arrangement');
    expect(event.refinementGainBand, 'high');
    expect(event.refinementScenariosEvaluated, 8);
    final raw = preferences.getString(GuideFlowMetricsStore.storageKey)!;
    expect(raw, isNot(contains('cityId')));
    expect(raw, isNot(contains('answers')));
  });
}

class _RecordingSink implements GuideFlowMetricsSink {
  String? installationToken;
  List<GuideFlowUploadEvent> events = const [];

  @override
  Future<Set<String>> upload({
    required String installationToken,
    required List<GuideFlowUploadEvent> events,
  }) async {
    this.installationToken = installationToken;
    this.events = events;
    return events.map((event) => event.eventId).toSet();
  }
}
