import 'package:movaro_app/features/cities/domain/entities/city.dart';

/// Verdict for the "Dá pra viver aqui?" affordability insight.
enum AffordabilityVerdict {
  /// Income comfortably covers a fair monthly cost of living.
  comfortable,

  /// Income covers it, but with little margin.
  tight,

  /// Income does not cover a fair monthly cost of living.
  insufficient,
}

/// Result of comparing a monthly net income against a city's fair monthly cost
/// of living (a 1-bedroom rent + typical single-person expenses).
class CityAffordabilityResult {
  const CityAffordabilityResult({
    required this.monthlyIncome,
    required this.monthlyCost,
    required this.gap,
    required this.coverageRatio,
    required this.verdict,
    required this.usesLocalAverageSalary,
  });

  /// Monthly net income used for the comparison (BRL).
  final int monthlyIncome;

  /// Fair monthly cost of living used for the comparison (BRL).
  final int monthlyCost;

  /// `monthlyIncome - monthlyCost` (negative means a shortfall).
  final int gap;

  /// `monthlyIncome / monthlyCost`.
  final double coverageRatio;

  final AffordabilityVerdict verdict;

  /// True when the income is the city's local average net salary (no custom
  /// income was provided).
  final bool usesLocalAverageSalary;
}

/// "Dá pra viver aqui?" — turns a city's cost-of-living budget into a simple,
/// honest affordability verdict for the economic-migrant ICP.
///
/// Uses only real, sourced budget data ([City.budgetSnapshot]); returns `null`
/// when a city has no budget data yet, so the UI can show a neutral
/// "coming soon" state instead of guessing.
class CityAffordabilityCheck {
  const CityAffordabilityCheck._();

  /// Comfortable when income is at least 25% above a fair cost of living.
  static const double _comfortableRatio = 1.25;

  static bool isAvailable(City city) => city.budgetSnapshot != null;

  /// Affordability using the city's local average net salary as the income.
  static CityAffordabilityResult? forLocalSalary(City city) {
    final budget = city.budgetSnapshot;
    if (budget == null) {
      return null;
    }
    return _evaluate(
      income: budget.averageMonthlyNetSalary,
      cost: budget.fairLivingTotal,
      usesLocalAverageSalary: true,
    );
  }

  /// Affordability for a custom monthly net income (BRL).
  static CityAffordabilityResult? forIncome(City city, int monthlyIncome) {
    final budget = city.budgetSnapshot;
    if (budget == null) {
      return null;
    }
    return _evaluate(
      income: monthlyIncome,
      cost: budget.fairLivingTotal,
      usesLocalAverageSalary: false,
    );
  }

  static CityAffordabilityResult _evaluate({
    required int income,
    required int cost,
    required bool usesLocalAverageSalary,
  }) {
    final ratio = cost <= 0 ? 0.0 : income / cost;
    final verdict = ratio >= _comfortableRatio
        ? AffordabilityVerdict.comfortable
        : ratio >= 1.0
        ? AffordabilityVerdict.tight
        : AffordabilityVerdict.insufficient;
    return CityAffordabilityResult(
      monthlyIncome: income,
      monthlyCost: cost,
      gap: income - cost,
      coverageRatio: ratio,
      verdict: verdict,
      usesLocalAverageSalary: usesLocalAverageSalary,
    );
  }
}
