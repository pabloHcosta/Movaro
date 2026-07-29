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

  test('every step uses the same visible three-part execution hierarchy', () {
    final executor = methodBody(
      'Future<void> _showExecutionPage(',
      'Future<void> _completeGuideItem(',
    );

    expect('_GuideWorkflowSection('.allMatches(executor), hasLength(3));
    expect(executor, contains("pt: 'Prepare o necessário'"));
    expect(executor, contains("pt: 'Execute a etapa'"));
    expect(executor, contains("pt: 'Confirme o resultado'"));
    expect(executor, contains("'guide-confirmation-checklist'"));
    expect(executor, isNot(contains('shouldDeferChecklist')));
  });

  test(
    'completion criteria and checklist are not hidden in expandable cards',
    () {
      final executor = methodBody(
        'Future<void> _showExecutionPage(',
        'Future<void> _completeGuideItem(',
      );
      final confirmationStart = executor.indexOf("pt: 'Confirme o resultado'");
      final detailsStart = executor.indexOf('_GuideSupplementaryDetails(');
      final confirmation = executor.substring(confirmationStart, detailsStart);

      expect(confirmation, contains('_GuideDoneCriteriaContent('));
      expect(confirmation, contains('_GuideOutcomeProgress('));
      expect(confirmation, isNot(contains('_GuideExpandableSection(')));
    },
  );

  test('core workflow cards and preparation content cannot be collapsed', () {
    final workflowSection = methodBody(
      'class _GuideWorkflowSection',
      'class _GuideExpandableSection',
    );
    final quickReference = methodBody(
      'class _QuickReferenceCard',
      'class _RefRow',
    );

    expect(workflowSection, isNot(contains('ExpansionTile')));
    expect(quickReference, isNot(contains('GestureDetector')));
    expect(quickReference, isNot(contains('ExpansionTile')));
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
