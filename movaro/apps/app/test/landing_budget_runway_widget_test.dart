import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mudavi_app/app/localization/app_localization.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/migration_copilot_progress_store.dart';
import 'package:mudavi_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:mudavi_app/features/migration_questionnaire/presentation/widgets/landing_budget_estimator_section.dart';
import 'package:mudavi_app/features/migration_questionnaire/presentation/widgets/landing_budget_runway_card.dart';

const plan = MigrationPlan(
  id: 'runway-test',
  originCountry: 'argentina',
  destinationCountry: 'brasil',
  goal: 'work',
  timeline: 'in_3_6m',
  steps: [],
);

class MemoryStore extends MigrationCopilotProgressStore {
  Map<String, int> saved = {};
  @override
  Future<MigrationCopilotProgressSnapshot> read(MigrationPlan plan) async =>
      MigrationCopilotProgressSnapshot(landingBudgetOverrides: saved);
  @override
  Future<void> writeLandingBudgetOverrides({
    required MigrationPlan plan,
    required Map<String, int> values,
  }) async {
    saved = Map.of(values);
  }
}

void main() {
  testWidgets(
    'Spanish budget accepts zero savings and restores the assessment',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStore();
      Widget app() => MaterialApp(
        locale: const Locale('es'),
        supportedLocales: AppLocalization.supportedLocales,
        localizationsDelegates: AppLocalization.localizationsDelegates,
        home: Scaffold(
          body: SingleChildScrollView(
            child: LandingBudgetEstimatorSection(
              plan: plan,
              progressStore: store,
            ),
          ),
        ),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final edit = find.widgetWithText(TextButton, 'Completar');
      await tester.ensureVisible(edit);
      await tester.tap(edit);
      await tester.pumpAndSettle();
      for (final entry in {
        'monthly': '3000',
        'setup': '5000',
        'buffer': '3000',
        'available': '0',
      }.entries) {
        final input = find.descendant(
          of: find.byKey(ValueKey('landing-budget-${entry.key}-input')),
          matching: find.byType(TextField),
        );
        await tester.ensureVisible(input);
        await tester.enterText(input, entry.value);
      }
      final save = find.text('Guardar presupuesto');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(store.saved['availableBrl'], 0);
      expect(store.saved['monthsWithoutIncome'], 3);
      expect(find.byType(LandingBudgetRunwayCard), findsOneWidget);
      expect(
        find.textContaining('0 meses completos sin ingresos'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(
        find.textContaining('0 meses completos sin ingresos'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('runway remains readable on small screens with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: const SingleChildScrollView(
              child: LandingBudgetRunwayCard(
                availableBrl: 1000,
                monthlyBrl: 3000,
                setupBrl: 5000,
                bufferBrl: 2000,
                months: 6,
              ),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
