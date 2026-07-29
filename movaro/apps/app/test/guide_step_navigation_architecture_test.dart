import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/migration_questionnaire/presentation/pages/'
    'migration_plan_copilot_page.dart',
  ).readAsStringSync();

  String methodBody(String start, String end) {
    final startIndex = source.indexOf(start);
    final endIndex = source.indexOf(end, startIndex + start.length);
    expect(startIndex, isNonNegative, reason: '$start must exist');
    expect(
      endIndex,
      greaterThan(startIndex),
      reason: '$end must follow $start',
    );
    return source.substring(startIndex, endIndex);
  }

  test('step executor is a page and cannot stack a modal task surface', () {
    final executor = methodBody(
      'Future<void> _showExecutionPage(',
      'Future<void> _completeGuideItem(',
    );

    expect(executor, contains('Navigator.of(context).push<void>'));
    expect(executor, contains("'/plan/step/\${item.id}'"));
    expect(executor, isNot(contains('showModalBottomSheet')));
  });

  test('step outcomes use guided progression instead of checkbox rows', () {
    final executor = methodBody(
      'Future<void> _showExecutionPage(',
      'Future<void> _completeGuideItem(',
    );

    expect(executor, contains('_GuideOutcomeProgress('));
    expect(executor, isNot(contains('CheckboxListTile')));
  });

  test('CPF route choice filters the instructions in the same page', () {
    final executor = methodBody(
      'Future<void> _showExecutionPage(',
      'Future<void> _completeGuideItem(',
    );

    expect(executor, contains('selectedCpfRouteIndex'));
    expect(executor, contains('_CpfDecisionContent('));
    expect(executor, contains('selectedIndex:'));
  });

  test('embedded flight and budget tools open as full pages', () {
    final toolPage = methodBody(
      'Future<void> _showPreparationSheet(',
      'class _GuidePageHeader',
    );

    expect(toolPage, contains('MaterialPageRoute<void>'));
    expect(toolPage, isNot(contains('showModalBottomSheet')));
  });
}
