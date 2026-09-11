import 'package:flutter_test/flutter_test.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/guide_flow_metrics_store.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/market_validation_check_in_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('offers check-in only when anonymous metrics are enabled', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final metrics = GuideFlowMetricsStore(preferences: preferences);
    final store = MarketValidationCheckInStore(
      preferences: preferences,
      metricsStore: metrics,
    );

    expect(await store.shouldOffer(phaseKey: 'housing'), isFalse);
    await metrics.setConsent(ProductAnalyticsConsent.granted);
    expect(await store.shouldOffer(phaseKey: 'housing'), isTrue);
  });

  test('submission records bounded signals once per phase', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final sink = _RecordingSink();
    final metrics = GuideFlowMetricsStore(preferences: preferences, sink: sink);
    await metrics.setConsent(ProductAnalyticsConsent.granted);
    final store = MarketValidationCheckInStore(
      preferences: preferences,
      metricsStore: metrics,
    );

    await store.submit(
      phaseKey: 'work',
      checkIn: const MarketValidationCheckIn(
        clarity: MarketValidationClarity.clear,
        progress: MarketValidationProgress.blocked,
        value: MarketValidationValue.moderate,
      ),
    );

    expect(await store.shouldOffer(phaseKey: 'work'), isFalse);
    expect(await store.shouldOffer(phaseKey: 'housing'), isTrue);
    final event = sink.events.single;
    expect(event.metric, GuideFlowMetric.pilotCheckInSubmitted);
    expect(event.validationClarityBand, 'clear');
    expect(event.validationProgressBand, 'blocked');
    expect(event.validationValueBand, 'moderate');
    expect(event.validationPhaseBand, 'work');
  });

  test('dismissal pauses every prompt for seven days', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final metrics = GuideFlowMetricsStore(preferences: preferences);
    await metrics.setConsent(ProductAnalyticsConsent.granted);
    var now = DateTime.utc(2026, 9, 11);
    final store = MarketValidationCheckInStore(
      preferences: preferences,
      metricsStore: metrics,
      now: () => now,
    );

    await store.dismiss(phaseKey: 'documents');
    expect(await store.shouldOffer(phaseKey: 'documents'), isFalse);
    now = now.add(const Duration(days: 7));
    expect(await store.shouldOffer(phaseKey: 'documents'), isTrue);
  });
}

class _RecordingSink implements GuideFlowMetricsSink {
  List<GuideFlowUploadEvent> events = const <GuideFlowUploadEvent>[];

  @override
  Future<Set<String>> upload({
    required String installationToken,
    required List<GuideFlowUploadEvent> events,
  }) async {
    this.events = events;
    return events.map((event) => event.eventId).toSet();
  }
}
