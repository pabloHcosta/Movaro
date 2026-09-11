import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/work_viability_assessment.dart';

void main() {
  test('does not call an incomplete profile viable', () {
    final result = WorkViabilityAssessor.assess(
      const WorkViabilityProfile(workArea: 'Design'),
    );

    expect(result.level, WorkViabilityLevel.incomplete);
    expect(result.actionKeys, contains('complete_profile'));
  });

  test('turns personal and financial gaps into concrete actions', () {
    final result = WorkViabilityAssessor.assess(
      const WorkViabilityProfile(
        workArea: 'Engenharia',
        experienceLevel: WorkExperienceLevel.experienced,
        portugueseLevel: PortugueseWorkLevel.starting,
        regulationStatus: ProfessionRegulationStatus.requiredPending,
        reviewedOpenings: 1,
        expectedMonthlyIncomeBrl: 4500,
        essentialMonthlyCostBrl: 6000,
      ),
    );

    expect(result.level, WorkViabilityLevel.attention);
    expect(result.monthlyGapBrl, 1500);
    expect(
      result.actionKeys,
      containsAll(<String>[
        'review_three_openings',
        'prepare_portuguese_profile',
        'confirm_profession_recognition',
        'close_income_gap',
      ]),
    );
  });

  test('requires real opening evidence before returning viable', () {
    const base = WorkViabilityProfile(
      workArea: 'Tecnologia',
      experienceLevel: WorkExperienceLevel.experienced,
      portugueseLevel: PortugueseWorkLevel.professional,
      regulationStatus: ProfessionRegulationStatus.no,
      expectedMonthlyIncomeBrl: 9000,
      essentialMonthlyCostBrl: 5500,
    );

    expect(
      WorkViabilityAssessor.assess(base).level,
      WorkViabilityLevel.attention,
    );
    final withEvidence = WorkViabilityProfile.fromJson({
      ...base.toJson(),
      'reviewedOpenings': 3,
    });
    expect(
      WorkViabilityAssessor.assess(withEvidence).level,
      WorkViabilityLevel.viable,
    );
  });

  test('recognized regulated profession can reach a viable result', () {
    final result = WorkViabilityAssessor.assess(
      const WorkViabilityProfile(
        workArea: 'Medicina',
        experienceLevel: WorkExperienceLevel.experienced,
        portugueseLevel: PortugueseWorkLevel.professional,
        regulationStatus: ProfessionRegulationStatus.requiredReady,
        reviewedOpenings: 3,
        expectedMonthlyIncomeBrl: 10000,
        essentialMonthlyCostBrl: 6000,
      ),
    );

    expect(result.level, WorkViabilityLevel.viable);
    expect(result.signalKeys, contains('recognition_ready'));
  });

  test('profile serialization ignores invalid persisted values', () {
    final profile = WorkViabilityProfile.fromJson(const {
      'workArea': 'Saúde',
      'experienceLevel': 'unknown',
      'portugueseLevel': 'functional',
      'regulationStatus': 'unsure',
      'reviewedOpenings': -4,
      'expectedMonthlyIncomeBrl': 0,
      'essentialMonthlyCostBrl': 5000,
    });

    expect(profile.experienceLevel, isNull);
    expect(profile.portugueseLevel, PortugueseWorkLevel.functional);
    expect(profile.reviewedOpenings, 0);
    expect(profile.expectedMonthlyIncomeBrl, isNull);
    expect(profile.essentialMonthlyCostBrl, 5000);
  });
}
