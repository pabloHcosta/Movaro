import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/argentina_brazil_guide_datasource.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/guide_personalization_service.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

void main() {
  const plan = MigrationPlan(
    originCountry: 'argentina',
    destinationCountry: 'brasil',
    goal: 'remote_work',
    timeline: 'in_3_6m',
    steps: [],
    travelGroup: 'family_with_kids',
  );

  test('prioritizes the bilateral permanent-residence route', () {
    final items = ArgentinaBrazilGuideDataSource.build(plan, localeCode: 'pt');
    final residence = items.singleWhere(
      (item) => item.id == 'item_2_2_residencia',
    );

    expect(residence.title, contains('rota de residência'));
    expect(residence.shortDescription, contains('acordo bilateral'));
    expect(residence.shortDescription, contains('permanente'));
    expect(residence.shortDescription, isNot(contains('janela legal')));
    expect(residence.evidence?.sourceUrl, contains('brasil-e-argentina'));
  });

  test('ships reviewed practical coverage without generative AI', () {
    final ids = ArgentinaBrazilGuideDataSource.build(
      plan,
      localeCode: 'pt',
    ).map((item) => item.id).toSet();

    expect(
      ids,
      containsAll({
        'item_0_6_medicamentos',
        'item_1_5_animais',
        'item_2_6_impostos_exterior',
        'item_3_6_familia_escola',
        'item_4_7_seguranca_emergencia',
      }),
    );
  });

  test('shows conditional guidance only when the plan needs it', () {
    final items = ArgentinaBrazilGuideDataSource.build(plan, localeCode: 'pt');
    final personalized = GuidePersonalizationService.personalize(
      plan: plan,
      items: items,
      explicitCompletedIds: const {},
      explicitDismissedReasons: const {},
    );

    expect(
      personalized
          .singleWhere((item) => item.id == 'item_0_6_medicamentos')
          .isCompleted,
      isTrue,
    );
    expect(
      personalized
          .singleWhere((item) => item.id == 'item_1_5_animais')
          .isCompleted,
      isTrue,
    );
    expect(
      personalized
          .singleWhere((item) => item.id == 'item_2_6_impostos_exterior')
          .isCompleted,
      isFalse,
    );

    const planWithNeeds = MigrationPlan(
      originCountry: 'argentina',
      destinationCountry: 'brasil',
      goal: 'fresh_start',
      timeline: 'in_3_6m',
      steps: [],
      selectedConstraints: ['travel_with_pet', 'continuous_medication'],
    );
    final withNeeds = GuidePersonalizationService.personalize(
      plan: planWithNeeds,
      items: ArgentinaBrazilGuideDataSource.build(
        planWithNeeds,
        localeCode: 'pt',
      ),
      explicitCompletedIds: const {},
      explicitDismissedReasons: const {},
    );

    expect(
      withNeeds
          .singleWhere((item) => item.id == 'item_0_6_medicamentos')
          .isCompleted,
      isFalse,
    );
    expect(
      withNeeds
          .singleWhere((item) => item.id == 'item_1_5_animais')
          .isCompleted,
      isFalse,
    );
  });
}
