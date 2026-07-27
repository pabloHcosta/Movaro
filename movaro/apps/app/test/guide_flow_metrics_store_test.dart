import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_flow_metrics_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores only bounded flow metadata without answer values', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final preferences = await SharedPreferences.getInstance();
    final store = GuideFlowMetricsStore(preferences: preferences);

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
}
