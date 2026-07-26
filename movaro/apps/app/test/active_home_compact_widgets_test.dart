import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_theme.dart';
import 'package:movaro_app/features/home/presentation/widgets/city_feed_widget.dart';
import 'package:movaro_app/features/home/presentation/widgets/journey_stepper_widget.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/user_journey_stage.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/guide_action_item.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

void main() {
  const plan = MigrationPlan(
    originCountry: 'Argentina',
    destinationCountry: 'Brasil',
    goal: 'work',
    timeline: 'in_0_3m',
    steps: [],
  );

  const items = [
    GuideActionItem(
      id: 'prep_done',
      title: 'Definir documentos',
      shortDescription: 'Passo concluído',
      type: GuideActionType.checklist,
      phase: GuidePhase.preparation,
      orderIndex: 0,
      isCompleted: true,
    ),
    GuideActionItem(
      id: 'prep_now',
      title: 'Conferir a regra de entrada',
      shortDescription: 'Leia antes de viajar',
      type: GuideActionType.informative,
      phase: GuidePhase.preparation,
      orderIndex: 1,
      isCompleted: false,
    ),
    GuideActionItem(
      id: 'housing_next',
      title: 'Planejar os primeiros dias',
      shortDescription: 'Organize a chegada',
      type: GuideActionType.informative,
      phase: GuidePhase.housing,
      orderIndex: 2,
      isCompleted: false,
    ),
  ];

  testWidgets('journey summary prioritizes current and next phases', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        supportedLocales: AppLocalization.supportedLocales,
        localizationsDelegates: AppLocalization.localizationsDelegates,
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: JourneyStepperWidget(
              plan: plan,
              allItems: items,
              showTaskCard: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('AGORA'), findsOneWidget);
    expect(find.text('DEPOIS'), findsOneWidget);
    expect(find.text('Antes de viajar'), findsOneWidget);
    expect(find.text('Primeiros dias'), findsOneWidget);
    expect(find.text('1 de 3 feitos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('feed cards keep details behind an explicit action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        supportedLocales: AppLocalization.supportedLocales,
        localizationsDelegates: AppLocalization.localizationsDelegates,
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: CityFeedWidget(
            cityCode: null,
            stage: UserJourneyStage.executor,
            locale: 'pt',
          ),
        ),
      ),
    );

    expect(find.text('PARA VOCÊ'), findsOneWidget);
    expect(find.text('Ver dica'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
