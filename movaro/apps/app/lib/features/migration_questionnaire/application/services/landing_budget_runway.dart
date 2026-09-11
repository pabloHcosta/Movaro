import 'dart:math' as math;

/// Conservative scenario: no income, setup paid once, emergency buffer kept.
class LandingBudgetRunway {
  LandingBudgetRunway({
    required int availableBrl,
    required int monthlyBrl,
    required int setupBrl,
    required int bufferBrl,
    required int months,
  }) {
    if (availableBrl < 0 ||
        monthlyBrl <= 0 ||
        setupBrl < 0 ||
        bufferBrl < 0 ||
        months <= 0) {
      throw ArgumentError('Invalid budget values');
    }
    requiredBrl = setupBrl + bufferBrl + monthlyBrl * months;
    shortfallBrl = math.max(0, requiredBrl - availableBrl);
    fullMonthsCovered =
        math.max(0, availableBrl - setupBrl - bufferBrl) ~/ monthlyBrl;
    setupShortfallBrl = math.max(0, setupBrl - availableBrl);
  }

  late final int requiredBrl;
  late final int shortfallBrl;
  late final int fullMonthsCovered;
  late final int setupShortfallBrl;
}
