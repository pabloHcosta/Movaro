import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/cities/application/services/city_affordability_check.dart';
import 'package:movaro_app/features/cities/data/models/city_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<City> cities;

  setUpAll(() async {
    final raw = await rootBundle.loadString(
      'assets/seed/snapshots/cities_br.json',
    );
    cities = (jsonDecode(raw) as List<dynamic>)
        .map((e) => CityModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  });

  City cityWithBudget() => cities.firstWhere((c) => c.budgetSnapshot != null);

  test('returns null when the city has no budget data', () {
    final noBudget = cities.firstWhere((c) => c.budgetSnapshot == null);
    expect(CityAffordabilityCheck.isAvailable(noBudget), isFalse);
    expect(CityAffordabilityCheck.forLocalSalary(noBudget), isNull);
    expect(CityAffordabilityCheck.forIncome(noBudget, 5000), isNull);
  });

  test('local-salary verdict matches the budget math', () {
    final city = cityWithBudget();
    final budget = city.budgetSnapshot!;
    final result = CityAffordabilityCheck.forLocalSalary(city)!;

    expect(result.usesLocalAverageSalary, isTrue);
    expect(result.monthlyIncome, budget.averageMonthlyNetSalary);
    expect(result.monthlyCost, budget.fairLivingTotal);
    expect(result.gap, budget.averageMonthlyNetSalary - budget.fairLivingTotal);

    final expected = result.coverageRatio >= 1.25
        ? AffordabilityVerdict.comfortable
        : result.coverageRatio >= 1.0
        ? AffordabilityVerdict.tight
        : AffordabilityVerdict.insufficient;
    expect(result.verdict, expected);
  });

  test('custom income drives the verdict', () {
    final city = cityWithBudget();
    final cost = city.budgetSnapshot!.fairLivingTotal;

    final rich = CityAffordabilityCheck.forIncome(city, cost * 2)!;
    expect(rich.verdict, AffordabilityVerdict.comfortable);
    expect(rich.gap, greaterThan(0));
    expect(rich.usesLocalAverageSalary, isFalse);

    final poor = CityAffordabilityCheck.forIncome(city, (cost * 0.6).round())!;
    expect(poor.verdict, AffordabilityVerdict.insufficient);
    expect(poor.gap, lessThan(0));
  });
}
