import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/features/cities/data/models/city_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_metric_insight_sheet.dart';

void main() {
  testWidgets(
    'metric sheets explain evidence without exposing internal scores',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final city = _loadNatal();

      for (final topic in CityMetricInsightTopic.values) {
        await tester.pumpWidget(_Harness(city: city, topic: topic));
        await tester.tap(find.text('Abrir'));
        await _finishAnimation(tester);

        expect(find.textContaining('/100'), findsNothing);
        expect(find.textContaining('rentScore'), findsNothing);
        expect(find.textContaining('jobMarketScore'), findsNothing);
        expect(find.textContaining('economicActivityScore'), findsNothing);
        expect(find.textContaining('puntaje'), findsNothing);

        switch (topic) {
          case CityMetricInsightTopic.housing:
            expect(find.textContaining('Rutina mensual'), findsOneWidget);
            await _expandSources(tester);
            expect(find.textContaining('Livingcost'), findsWidgets);
            expect(find.textContaining('FipeZAP'), findsNothing);
          case CityMetricInsightTopic.safety:
            expect(find.textContaining('23,6'), findsWidgets);
            expect(find.text('Media'), findsWidgets);
            await _expandSources(tester);
            expect(find.textContaining('Atlas da Violência'), findsWidgets);
          case CityMetricInsightTopic.work:
            expect(find.text('Lectura preliminar'), findsOneWidget);
            expect(find.text('Todavía no integrado'), findsOneWidget);
            expect(find.textContaining('7.0%'), findsNothing);
            await _expandSources(tester);
            expect(find.text('Novo Caged'), findsOneWidget);
            expect(
              find.text('Censo 2022: Trabalho e Rendimento'),
              findsOneWidget,
            );
          case CityMetricInsightTopic.language:
            expect(find.text('Fácil'), findsWidgets);
            await _expandSources(tester);
            expect(find.text('Método interno'), findsOneWidget);
        }

        expect(find.textContaining('/100'), findsNothing);
        expect(find.textContaining('puntaje'), findsNothing);

        final closeButton = find.byIcon(Icons.close_rounded);
        await tester.ensureVisible(closeButton);
        await tester.tap(closeButton);
        await _finishAnimation(tester);
        expect(tester.takeException(), isNull);
      }
    },
  );
}

Future<void> _expandSources(WidgetTester tester) async {
  final title = find.text('Fuentes y límites');
  await tester.ensureVisible(title);
  await tester.tap(title);
  await _finishAnimation(tester);
}

Future<void> _finishAnimation(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

City _loadNatal() {
  final raw = File('assets/seed/snapshots/cities_br.json').readAsStringSync();
  final entries = jsonDecode(raw) as List<dynamic>;
  final json = entries.cast<Map<String, dynamic>>().firstWhere(
    (entry) => entry['name'] == 'Natal',
  );
  return CityModel.fromJson(json).toEntity();
}

class _Harness extends StatelessWidget {
  const _Harness({required this.city, required this.topic});

  final City city;
  final CityMetricInsightTopic topic;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('es'),
      supportedLocales: AppLocalization.supportedLocales,
      localizationsDelegates: AppLocalization.localizationsDelegates,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: FilledButton(
                onPressed: () => showCityMetricInsightSheet(
                  context,
                  city: city,
                  topic: topic,
                ),
                child: const Text('Abrir'),
              ),
            );
          },
        ),
      ),
    );
  }
}
