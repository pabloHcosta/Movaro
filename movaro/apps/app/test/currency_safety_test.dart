import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/currency/currency_controller.dart';
import 'package:movaro_app/app/currency/currency_scope.dart';
import 'package:movaro_app/core/widgets/multi_currency_amount.dart';
import 'package:movaro_app/features/cities/domain/entities/city_budget_snapshot.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/copilot_exchange_rates.dart';

void main() {
  test('supports exactly the four configured display currencies', () {
    expect(AppCurrency.values.map((currency) => currency.code), [
      'USD',
      'BRL',
      'ARS',
      'CLP',
    ]);
    final controller = CurrencyController()..setCurrency('EUR');
    expect(controller.currencyCode, 'USD');
  });

  test('presentation code has no parallel currency formatter', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where((file) => !file.path.endsWith('multi_currency_amount.dart'));
    final violations = <String>[];
    for (final file in files) {
      final source = file.readAsStringSync();
      if (source.contains('NumberFormat.currency(') ||
          source.contains('CostEstimateFormatter.') ||
          source.contains("prefixText: 'R\\\$")) {
        violations.add(file.path);
      }
    }
    expect(violations, isEmpty);
  });

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

  testWidgets(
    'defaults to USD and does not invent a conversion without rates',
    (tester) async {
      final currencyController = CurrencyController();

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

      expect(currencyController.currencyCode, 'USD');
      expect(find.textContaining('— USD'), findsOneWidget);
      expect(find.textContaining('R\$'), findsNothing);
      expect(find.textContaining('AR\$'), findsNothing);
    },
  );

  testWidgets('uses the same selected currency for BRL and USD sources', (
    tester,
  ) async {
    final currencyController = CurrencyController()..setCurrency('ARS');
    final rates = _rates(
      fetchedAt: DateTime.now().toIso8601String(),
      referenceDate: DateTime.now().toIso8601String(),
    );

    await tester.pumpWidget(
      CurrencyScope(
        controller: currencyController,
        child: MaterialApp(
          locale: const Locale('pt', 'BR'),
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  MultiCurrencyAmount(amountInBrl: 10, exchangeRates: rates),
                  Text(
                    MultiCurrencyAmount.formatAmount(
                      context: context,
                      amount: 2,
                      sourceCurrencyCode: 'USD',
                      exchangeRates: rates,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.textContaining('AR\$'), findsNWidgets(2));
    expect(find.textContaining('US\$'), findsNothing);
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
