import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/features/safety_check/presentation/pages/proposal_safety_check_page.dart';

void main() {
  testWidgets('analyzes pasted content without leaving the page', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('pt'),
        supportedLocales: AppLocalization.supportedLocales,
        localizationsDelegates: AppLocalization.localizationsDelegates,
        home: ProposalSafetyCheckPage(cityName: 'Florianópolis'),
      ),
    );

    expect(find.text('Radar Movaro'), findsOneWidget);
    expect(find.textContaining('não é enviado nem salvo'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Faça um PIX antecipado antes da visita e decida agora.',
    );
    await tester.pump();
    tester.testTextInput.hide();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Analisar sinais'),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Pare e verifique'), findsOneWidget);
    expect(find.text('Pagamento antecipado'), findsOneWidget);
    expect(find.text('Pressão para decidir rápido'), findsOneWidget);
    expect(find.text('Próximo passo mais seguro'), findsOneWidget);
  });
}
