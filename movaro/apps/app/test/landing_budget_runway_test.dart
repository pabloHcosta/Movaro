import 'package:flutter_test/flutter_test.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/landing_budget_runway.dart';

void main() {
  test('setup and emergency money are not counted as spendable months', () {
    final result = LandingBudgetRunway(
      availableBrl: 17000,
      monthlyBrl: 3000,
      setupBrl: 5000,
      bufferBrl: 3000,
      months: 3,
    );
    expect(result.fullMonthsCovered, 3);
    expect(result.requiredBrl, 17000);
    expect(result.shortfallBrl, 0);
  });
  test('partial months do not round up and six months exposes the gap', () {
    final result = LandingBudgetRunway(
      availableBrl: 16999,
      monthlyBrl: 3000,
      setupBrl: 5000,
      bufferBrl: 3000,
      months: 6,
    );
    expect(result.fullMonthsCovered, 2);
    expect(result.shortfallBrl, 9001);
  });
  test('zero savings exposes setup gap without negative coverage', () {
    final result = LandingBudgetRunway(
      availableBrl: 0,
      monthlyBrl: 3000,
      setupBrl: 5000,
      bufferBrl: 3000,
      months: 3,
    );
    expect(result.fullMonthsCovered, 0);
    expect(result.setupShortfallBrl, 5000);
    expect(result.shortfallBrl, 17000);
  });
  test('invalid expenses do not produce a reassuring result', () {
    expect(
      () => LandingBudgetRunway(
        availableBrl: 1000,
        monthlyBrl: 0,
        setupBrl: 0,
        bufferBrl: 0,
        months: 3,
      ),
      throwsArgumentError,
    );
  });
}
