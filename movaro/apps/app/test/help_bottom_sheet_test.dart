import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/theme/app_colors.dart';
import 'package:movaro_app/core/widgets/help_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final brightness in Brightness.values) {
    testWidgets(
      'shared help sheet is readable in ${brightness.name} mode on a compact phone',
      (tester) async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: brightness,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: brightness,
              ),
            ),
            home: const Scaffold(
              body: HelpBottomSheet(
                contextLabel: 'Motor de cidades',
                contextIcon: Icons.route_outlined,
                title: 'Como a Movaro sugere cidades',
                description:
                    'Suas respostas viram critérios de comparação claros.',
                steps: [
                  HelpStep(
                    title: 'Você define o que importa',
                    body: 'Objetivo e prioridades ajustam a análise.',
                    icon: Icons.tune_rounded,
                  ),
                  HelpStep(
                    title: 'Dados identificados',
                    body: 'Dados sem base comparável ficam fora.',
                    icon: Icons.fact_check_outlined,
                  ),
                  HelpStep(
                    title: 'Não é um veredito',
                    body: 'É apoio educacional e comparativo.',
                    icon: Icons.balance_outlined,
                  ),
                ],
                preferenceKey: 'test',
                hideAgainLabel: 'Não mostrar novamente',
                confirmLabel: 'Entendi',
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Como a Movaro sugere cidades'), findsOneWidget);
        expect(find.byType(Checkbox), findsOneWidget);
        expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
        expect(find.text('Entendi'), findsOneWidget);
        expect(find.byTooltip('Close'), findsOneWidget);

        final title = tester.widget<Text>(
          find.text('Como a Movaro sugere cidades'),
        );
        final expectedColor = brightness == Brightness.dark
            ? const Color(0xFFF5F7FB)
            : AppColors.textPrimary;
        expect(title.style?.color, expectedColor);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
