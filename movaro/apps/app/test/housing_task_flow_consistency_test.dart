import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/core/widgets/app_glass_header.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_scores.dart';
import 'package:movaro_app/features/cities/domain/entities/city_source.dart';
import 'package:movaro_app/features/cities/domain/entities/city_sources.dart';
import 'package:movaro_app/features/migration_questionnaire/presentation/pages/housing_selection_screen.dart';

void main() {
  testWidgets('housing task screens keep the same chrome in light and dark', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        _app(
          brightness,
          TemporaryHousingScreen(city: _city, onHelp: () async {}),
        ),
      );
      await tester.pump();

      expect(find.byType(AppGlassHeader), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(3));
      expect(find.byType(FilledButton), findsWidgets);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        _app(
          brightness,
          LongTermHousingScreen(
            city: _city,
            onOpenRentalSearch: (_, _) async {},
            onHelp: () async {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AppGlassHeader), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(5));
      expect(tester.takeException(), isNull);
    }
  });
}

Widget _app(Brightness brightness, Widget home) {
  return MaterialApp(
    locale: const Locale('pt'),
    supportedLocales: AppLocalization.supportedLocales,
    localizationsDelegates: AppLocalization.localizationsDelegates,
    theme: ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0071E3),
        brightness: brightness,
      ),
    ),
    home: home,
  );
}

const _source = CitySource(
  id: 'official',
  title: 'Official',
  provider: 'Public authority',
  description: 'Traceable source',
  isOfficial: true,
  url: 'https://example.gov',
  sourceType: 'official',
);

const _city = City(
  id: 'curitiba',
  name: 'Curitiba',
  stateCode: 'PR',
  stateName: 'Paraná',
  countryCode: 'BR',
  ibgeCode: 4106902,
  latitude: -25.43,
  longitude: -49.27,
  population: 1770000,
  idhmScore: 0.82,
  idhmReferenceYear: 2021,
  costOfLivingScore: 65,
  rentScore: 62,
  safetyScore: 80,
  argentinaPopularityScore: 76,
  spanishSupportScore: 69,
  jobMarketScore: 72,
  unemploymentRate: 6,
  economicActivityScore: 74,
  topIndustries: ['Tecnologia', 'Serviços'],
  movaroScores: CityScores(
    economical: 65,
    popularForArgentinians: 76,
    languageAdaptation: 69,
    workOpportunity: 72,
    overall: 72,
  ),
  recommendationReasons: ['Boa estrutura urbana'],
  sources: CitySources(
    territorialIdentity: _source,
    population: _source,
    humanDevelopment: _source,
    employment: _source,
    safety: _source,
    curatedMetrics: _source,
    ranking: _source,
    publicReviews: _source,
  ),
  updatedAt: '2026-07-28',
  regionName: 'Sul',
);
