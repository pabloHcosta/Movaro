import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/currency/currency_controller.dart';
import 'package:movaro_app/app/currency/currency_scope.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/features/cities/domain/entities/city_budget_snapshot.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

void main() {
  test('rejects stale exchange snapshots', () {
    final now = DateTime(2026, 7, 26, 12);
    final fresh = _rates(
      fetchedAt: now.subtract(const Duration(hours: 12)).toIso8601String(),
      referenceDate: '2026-07-25',
    );
    final stale = _rates(
      fetchedAt: now.subtract(const Duration(days: 7)).toIso8601String(),
      referenceDate: '2026-07-18',
    );

    expect(fresh.isFresh(now: now), isTrue);
    expect(stale.isFresh(now: now), isFalse);
  });

  test('protects planning range from an implausibly low rent observation', () {
    const budget = CityBudgetSnapshot(
      cityLabel: 'Example',
      singlePersonExcludingRent: 1800,
      oneBedroomOutsideCentre: 285,
      oneBedroomCityCentre: 2100,
      averageMonthlyNetSalary: 2800,
      monthlyTransportPass: 300,
      utilities: 200,
      updatedAt: '2026-03-11',
      sourceLabel: 'Derived source',
      sourceUrl: 'https://example.com',
      sourceType: 'derived',
    );

    expect(budget.hasSuspiciousRentSpread, isTrue);
    expect(budget.planningRentLow, 1365);
    expect(budget.fairLivingTotal, 3165);
  });

  testWidgets('does not invent an ARS conversion when rates are unavailable', (
    tester,
  ) async {
    final currencyController = CurrencyController()
      ..setDetectedCurrencyFromCountry('AR');

    await tester.pumpWidget(
      CurrencyScope(
        controller: currencyController,
        child: const MaterialApp(
          locale: Locale('pt', 'BR'),
          home: Scaffold(
            body: MultiCurrencyAmount(
              amountInBrl: 3123,
              exchangeRates: null,
              preferredCountryId: 'argentina',
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('≈ R\$'), findsOneWidget);
    expect(find.textContaining('3123'), findsNothing);
    expect(find.textContaining('AR\$'), findsNothing);
  });
}

CopilotExchangeRates _rates({
  required String fetchedAt,
  required String referenceDate,
}) {
  return CopilotExchangeRates(
    usdToBrl: 5,
    brlToUsd: 0.2,
    brlToArs: 300,
    arsToBrl: 1 / 300,
    usdToArs: 1500,
    arsToUsd: 1 / 1500,
    brlToEur: 0.17,
    brlToClp: 185,
    brlToUyu: 8,
    brlToCop: 820,
    brlToPen: 0.72,
    brlToPyg: 1500,
    brlToBob: 1.35,
    fetchedAt: fetchedAt,
    source: 'official',
    sources: const ['BCB', 'BCRA'],
    referenceDate: referenceDate,
  );
}
