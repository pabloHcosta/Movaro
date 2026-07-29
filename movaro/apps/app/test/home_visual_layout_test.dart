import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_theme.dart';
import 'package:movaro_app/features/home/presentation/home_visual_layout.dart';

void main() {
  testWidgets(
    'initial home keeps primary paths and shortcuts in first viewport',
    (tester) async {
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
          home: Scaffold(
            body: HomeVisualLayout(
              onDiscoverDirectionTap: () {},
              onKnownCityTap: () {},
              onOpenCostsTap: () {},
              onOpenDocumentsTap: () {},
              onOpenHousingTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Encontre cidades que combinam com seu plano'),
        findsOneWidget,
      );
      expect(find.text('Descobrir cidades para mim'), findsOneWidget);
      expect(find.text('Já tenho uma cidade para avaliar'), findsOneWidget);
      expect(find.text('Resolver uma dúvida agora'), findsOneWidget);
      expect(find.text('Custos iniciais'), findsOneWidget);
      expect(find.text('Documentos'), findsOneWidget);
      expect(find.text('Moradia'), findsOneWidget);
      expect(find.text('Explorar cidades'), findsNothing);
      expect(tester.takeException(), isNull);

      final shortcutsBottom = tester.getBottomRight(
        find.byKey(const ValueKey('home-shortcut-housing')),
      );
      expect(shortcutsBottom.dy, lessThan(844));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('initial home exposes clear actions and invokes each route', (
    tester,
  ) async {
    var primaryTaps = 0;
    var knownCityTaps = 0;
    var costsTaps = 0;
    var documentsTaps = 0;
    var housingTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        supportedLocales: AppLocalization.supportedLocales,
        localizationsDelegates: AppLocalization.localizationsDelegates,
        theme: AppTheme.light(),
        home: Scaffold(
          body: HomeVisualLayout(
            onDiscoverDirectionTap: () => primaryTaps++,
            onKnownCityTap: () => knownCityTaps++,
            onOpenCostsTap: () => costsTaps++,
            onOpenDocumentsTap: () => documentsTaps++,
            onOpenHousingTap: () => housingTaps++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Descobrir cidades para mim'));
    await tester.tap(find.text('Já tenho uma cidade para avaliar'));
    await tester.tap(find.text('Custos iniciais'));
    await tester.tap(find.text('Documentos'));
    await tester.tap(find.text('Moradia'));

    expect(primaryTaps, 1);
    expect(knownCityTaps, 1);
    expect(costsTaps, 1);
    expect(documentsTaps, 1);
    expect(housingTaps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('short viewport preserves both decision paths without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
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
        home: Scaffold(
          body: HomeVisualLayout(
            onDiscoverDirectionTap: () {},
            onKnownCityTap: () {},
            onOpenCostsTap: () {},
            onOpenDocumentsTap: () {},
            onOpenHousingTap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Descobrir cidades para mim'), findsOneWidget);
    expect(find.text('Já tenho uma cidade para avaliar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final locale in const [Locale('es'), Locale('en')]) {
    testWidgets(
      'compact home supports ${locale.languageCode} without overflow',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            supportedLocales: AppLocalization.supportedLocales,
            localizationsDelegates: AppLocalization.localizationsDelegates,
            theme: AppTheme.dark(),
            home: Scaffold(
              body: HomeVisualLayout(
                onDiscoverDirectionTap: () {},
                onKnownCityTap: () {},
                onOpenCostsTap: () {},
                onOpenDocumentsTap: () {},
                onOpenHousingTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(HomeVisualLayout), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('initial home remains usable with large accessibility text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        supportedLocales: AppLocalization.supportedLocales,
        localizationsDelegates: AppLocalization.localizationsDelegates,
        theme: AppTheme.light(),
        home: Scaffold(
          body: HomeVisualLayout(
            onDiscoverDirectionTap: () {},
            onKnownCityTap: () {},
            onOpenCostsTap: () {},
            onOpenDocumentsTap: () {},
            onOpenHousingTap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Descobrir cidades para mim'), findsOneWidget);
    expect(find.text('Já tenho uma cidade para avaliar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
