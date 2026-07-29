import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/migration_questionnaire/presentation/pages/question_page.dart',
  ).readAsStringSync();

  test('every multi-chip question uses the multi-select renderer', () {
    expect(
      source,
      contains(
        "if (question.type == 'multi_chip') {\n"
        '      return _buildMultiSelectList(context, question);',
      ),
    );
  });

  test('multi-select rows read all values and toggle without auto-advance', () {
    final start = source.indexOf('Widget _buildMultiSelectList(');
    final end = source.indexOf('// ── Horizontal compact list', start);
    expect(start, isNonNegative);
    expect(end, greaterThan(start));
    final renderer = source.substring(start, end);

    expect(renderer, contains('answerValuesFor(question.id).toSet()'));
    expect(renderer, contains('_handleMultiSelect(question, option)'));
    expect(renderer, isNot(contains('_handleSingleSelect')));
  });
}
