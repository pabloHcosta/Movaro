import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/theme/app_theme.dart';
import 'package:movaro_app/features/home/presentation/home_visual_layout.dart';

void main() {
  testWidgets('compact home shows complete copy without layout exceptions', (
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
        home: Scaffold(
          body: HomeVisualLayout(
            onDiscoverDirectionTap: () {},
            onKnownCityTap: () {},
            onExploreCitiesTap: () {},
            onOpenCostsTap: () {},
            onOpenDocumentsTap: () {},
            onLearnPortugueseTap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Receba uma direção inicial em poucos minutos ou valide uma cidade que você já está considerando antes de entrar no modo execução.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Responda poucas perguntas e receba uma direção inicial com encaixes de cidade, alternativas e possíveis próximos passos.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Busque a cidade, compare alternativas e valide custo, encaixe e próximos passos antes de assumir um plano completo.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('Atalhos úteis'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Atalhos úteis'), findsOneWidget);
    expect(find.text('Explorar cidades'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
