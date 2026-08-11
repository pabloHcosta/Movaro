import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_event_suggestion_engine.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

void main() {
  const plan = MigrationPlan(
    originCountry: 'Argentina',
    destinationCountry: 'Brasil',
    goal: 'work',
    timeline: 'in_1_3m',
    steps: [],
  );
  const item = GuideActionItem(
    id: 'item_0_2_antecedentes',
    title: 'Antecedentes',
    shortDescription: 'Emitir certificado',
    type: GuideActionType.external,
    phase: GuidePhase.preparation,
    orderIndex: 0,
    isCompleted: false,
  );
  final engine = GuideEventSuggestionEngine(now: () => DateTime(2026, 8, 4, 9));

  test('usa o idioma do aplicativo para o lembrete em português', () {
    final suggestion = engine.buildForItem(
      plan: plan,
      item: item,
      completedAtById: const {},
      completedSteps: 0,
      totalSteps: 1,
      localeCode: 'pt',
    );

    expect(suggestion, isNotNull);
    expect(suggestion!.title, 'Pedir antecedentes na Argentina');
    expect(suggestion.assistantCopy, contains('agendar agora'));
  });

  test('mantém a tradução inglesa quando o aplicativo está em inglês', () {
    final suggestion = engine.buildForItem(
      plan: plan,
      item: item,
      completedAtById: const {},
      completedSteps: 0,
      totalSteps: 1,
      localeCode: 'en',
    );

    expect(suggestion, isNotNull);
    expect(suggestion!.title, 'Request criminal record certificate');
  });

  test('não transforma a revisão de entrada em prazo universal de 90 dias', () {
    const entryItem = GuideActionItem(
      id: 'item_0_1_rule_90_days',
      title: 'Entrada e regularização',
      shortDescription: 'Separar visitante e residência',
      type: GuideActionType.informative,
      phase: GuidePhase.preparation,
      orderIndex: 0,
      isCompleted: false,
    );

    final suggestion = engine.buildForItem(
      plan: plan,
      item: entryItem,
      completedAtById: const {},
      completedSteps: 0,
      totalSteps: 1,
      localeCode: 'pt',
    );

    expect(suggestion, isNotNull);
    expect(suggestion!.hardDeadline, isNull);
    expect(suggestion.assistantCopy, contains('sem transformar'));
  });
}
