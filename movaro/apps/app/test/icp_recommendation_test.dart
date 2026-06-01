import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movaro_app/features/cities/data/models/city_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_plan_generator.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/answer.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';

/// Minimal repository that only serves the bundled city catalog; the plan
/// generator only calls [getCities].
class _FakeCitiesRepository implements CitiesRepository {
  _FakeCitiesRepository(this._cities);

  final List<City> _cities;

  @override
  Future<List<City>> getCities({
    String? category,
    String? search,
    String? countryCode,
  }) async => _cities;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

// Clearly beach/tourism towns with weak job markets — a work-seeker should
// never be steered to these.
const _beachTowns = {
  'armacao-dos-buzios-rj',
  'arraial-do-cabo-rj',
  'maragogi-al',
  'jijoca-de-jericoacoara-ce',
  'tibau-do-sul-rn',
  'cairu-ba',
  'sao-miguel-do-gostoso-rn',
  'itacare-ba',
  'paraty-rj',
  'ubatuba-sp',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<City> cities;

  setUpAll(() async {
    final raw = await rootBundle.loadString(
      'assets/seed/snapshots/cities_br.json',
    );
    cities = (jsonDecode(raw) as List<dynamic>)
        .map((e) => CityModel.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  });

  test('ICP-A: job-seeker is steered to a work-viable city, not a beach', () async {
    final generator = MigrationPlanGenerator(
      citiesRepository: _FakeCitiesRepository(cities),
    );

    final plan = await generator.generate(
      answers: const [
        Answer(questionId: 'origin_country', values: ['argentina']),
        Answer(questionId: 'destination_country', values: ['brasil']),
        Answer(questionId: 'intent', values: ['find_job_br']),
        Answer(questionId: 'funding', values: ['job_search']),
        Answer(questionId: 'timeline', values: ['in_0_3m']),
        Answer(questionId: 'priorities', values: ['job_opportunities', 'low_cost']),
        Answer(questionId: 'argentina_origin', values: ['litoral']),
      ],
      variant: QuestionnaireVariant.lean,
    );

    expect(plan.highlightedCity, isNotNull);
    final top = plan.highlightedCity!;
    expect(
      top.jobMarketScore >= 65,
      isTrue,
      reason: 'top city ${top.id} has jobMarket=${top.jobMarketScore}',
    );

    final ids = plan.candidateCities.map((c) => c.id).toList();
    expect(
      ids.any(_beachTowns.contains),
      isFalse,
      reason: 'work-seeker shortlist should not contain beach towns: $ids',
    );
  });

  test('ICP-A: low-signal (balanced) user is nudged toward a practical city', () async {
    final generator = MigrationPlanGenerator(
      citiesRepository: _FakeCitiesRepository(cities),
    );

    final plan = await generator.generate(
      answers: const [
        Answer(questionId: 'origin_country', values: ['argentina']),
        Answer(questionId: 'destination_country', values: ['brasil']),
        Answer(questionId: 'intent', values: ['fresh_start']),
        Answer(questionId: 'timeline', values: ['just_exploring']),
        Answer(questionId: 'priorities', values: ['balanced_unsure']),
      ],
      variant: QuestionnaireVariant.lean,
    );

    expect(plan.highlightedCity, isNotNull);
    final top = plan.highlightedCity!;
    expect(
      top.jobMarketScore >= 55,
      isTrue,
      reason: 'balanced top city ${top.id} jobMarket=${top.jobMarketScore}',
    );
  });
}
