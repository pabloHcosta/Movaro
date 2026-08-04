import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/features/cities/application/cities_controller.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_budget_snapshot.dart';
import 'package:movaro_app/features/cities/domain/entities/city_scores.dart';
import 'package:movaro_app/features/cities/domain/entities/city_source.dart';
import 'package:movaro_app/features/cities/domain/entities/city_sources.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';
import 'package:movaro_app/features/cities/presentation/widgets/city_card.dart';

void main() {
  testWidgets('city card explains metrics without exposing internal scores', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = CitiesController(repository: _FakeCitiesRepository());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        supportedLocales: AppLocalization.supportedLocales,
        localizationsDelegates: AppLocalization.localizationsDelegates,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: CityCard(
              city: _city,
              onTap: () {},
              citiesController: controller,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Curitiba'), findsOneWidget);
    expect(find.text('Paraná · PR'), findsOneWidget);
    expect(find.text('Costo mensual'), findsOneWidget);
    expect(find.text('Alquiler'), findsOneWidget);
    expect(find.text('Economía'), findsOneWidget);
    expect(find.text('Base de datos amplia'), findsNothing);
    expect(find.text('Portugués'), findsNothing);
    expect(find.textContaining('/100'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _FakeCitiesRepository implements CitiesRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();

  @override
  Future<CityWeather> getCityWeather(String cityId) async {
    return const CityWeather(
      temperatureCelsius: 20,
      weatherCode: 1,
      isDay: true,
      windSpeedKmh: 8,
      fetchedAt: '2026-07-28T12:00:00Z',
    );
  }
}

const _source = CitySource(
  id: 'official-source',
  title: 'Official source',
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
  budgetSnapshot: CityBudgetSnapshot(
    cityLabel: 'Curitiba',
    singlePersonExcludingRent: 2438,
    oneBedroomOutsideCentre: 1304,
    oneBedroomCityCentre: 1992,
    averageMonthlyNetSalary: 2853,
    monthlyTransportPass: 577,
    utilities: 305,
    updatedAt: '2026-03-11',
    sourceLabel: 'Public cost reference',
    sourceUrl: 'https://example.gov/cost',
    sourceType: 'derived',
  ),
  updatedAt: '2026-07-28',
  regionName: 'Sul',
);
