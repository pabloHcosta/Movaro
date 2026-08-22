import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/info/application/quick_guide_preferences_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const store = QuickGuidePreferencesStore();

  setUp(() {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
  });

  test('recent questions stay local, deduplicate and can be erased', () async {
    await store.recordQuery('Como abro uma conta?', topic: 'finance');
    await store.recordQuery('Como consigo CPF?', topic: 'documents');
    await store.recordQuery('como abro uma conta?', topic: 'finance');

    expect(await store.loadRecentQuestions(), [
      'como abro uma conta?',
      'Como consigo CPF?',
    ]);

    await store.clearRecentQuestions();
    expect(await store.loadRecentQuestions(), isEmpty);
  });

  test(
    'metrics store only event and normalized dimension, never query text',
    () async {
      await store.recordQuery(
        'Meu CPF é 123 e esta pergunta fica apenas local',
        topic: 'Finance!',
      );

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('quick_guide_event_counts_v1')!;
      final metrics = jsonDecode(raw) as Map<String, dynamic>;
      expect(metrics, {'guideQuerySubmitted:finance': 1});
      expect(raw, isNot(contains('123')));
    },
  );

  test('feedback is persisted by reviewed entry id', () async {
    await store.saveFeedback('education-school', true);
    expect(await store.loadFeedback('education-school'), isTrue);
    expect(await store.loadFeedback('another-entry'), isNull);
  });

  test('negative feedback stores only a bounded reason code', () async {
    await store.saveFeedback(
      'housing-resolution',
      false,
      reason: 'Not_My_Case!!!',
    );

    expect(await store.loadFeedback('housing-resolution'), isFalse);
    expect(await store.loadFeedbackReason('housing-resolution'), 'not_my_case');
    final prefs = await SharedPreferences.getInstance();
    final metrics = prefs.getString('quick_guide_event_counts_v1')!;
    expect(metrics, contains('guideFeedbackReason:not_my_case'));
  });
}
