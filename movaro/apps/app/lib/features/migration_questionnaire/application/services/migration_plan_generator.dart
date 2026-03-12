import 'package:movaro_app/features/cities/application/services/city_coastal_profile.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/migration_plan_model.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/migration_step_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/answer.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';

class MigrationPlanGenerator {
  const MigrationPlanGenerator({required CitiesRepository citiesRepository})
    : _citiesRepository = citiesRepository;

  final CitiesRepository _citiesRepository;

  static const Map<String, String> _archetypeByIntent = {
    'find_job_br': 'job_hunter',
    'remote_income': 'remote_worker',
    'study': 'student',
    'family_partner': 'family_move',
    'fresh_start': 'fresh_start',
    'explore_unsure': 'explorer',
  };

  static const Map<String, Map<String, double>> _baseWeightsByArchetype = {
    'job_hunter': {
      'job_market': 0.32,
      'affordability': 0.16,
      'transit_infra': 0.16,
      'community': 0.14,
      'safety': 0.12,
      'proximity_argentina': 0.10,
    },
    'remote_worker': {
      'affordability': 0.24,
      'safety': 0.18,
      'community': 0.16,
      'nature': 0.16,
      'transit_infra': 0.14,
      'climate_warmth': 0.12,
    },
    'student': {
      'university': 0.28,
      'affordability': 0.18,
      'transit_infra': 0.18,
      'community': 0.14,
      'job_market': 0.12,
      'safety': 0.10,
    },
    'family_move': {
      'safety': 0.24,
      'community': 0.18,
      'affordability': 0.18,
      'transit_infra': 0.14,
      'proximity_argentina': 0.14,
      'nature': 0.12,
    },
    'fresh_start': {
      'safety': 0.22,
      'affordability': 0.20,
      'job_market': 0.18,
      'community': 0.14,
      'nature': 0.14,
      'transit_infra': 0.12,
    },
    'explorer': {
      'affordability': 0.16,
      'safety': 0.16,
      'job_market': 0.14,
      'nature': 0.14,
      'community': 0.14,
      'proximity_argentina': 0.14,
      'transit_infra': 0.12,
    },
    'job_hunter_with_offer': {
      'job_market': 0.28,
      'transit_infra': 0.18,
      'safety': 0.16,
      'community': 0.14,
      'affordability': 0.14,
      'proximity_argentina': 0.10,
    },
    'job_hunter_searching': {
      'job_market': 0.34,
      'affordability': 0.18,
      'transit_infra': 0.16,
      'community': 0.14,
      'safety': 0.10,
      'proximity_argentina': 0.08,
    },
    'remote_stable': {
      'affordability': 0.22,
      'safety': 0.20,
      'nature': 0.18,
      'community': 0.16,
      'transit_infra': 0.12,
      'climate_warmth': 0.12,
    },
  };

  static const Map<String, Map<String, double>> _priorityWeightMap = {
    'low_cost': {'affordability': 1},
    'job_opportunities': {'job_market': 1},
    'safety': {'safety': 1},
    'warm_climate_beach': {'climate_warmth': 0.7, 'nature': 0.3},
    'transit_infra': {'transit_infra': 1},
    'nature': {'nature': 1},
    'university': {'university': 1},
    'community': {'community': 1},
    'close_to_argentina': {'proximity_argentina': 1},
  };

  static const Map<String, double> _balancedPreset = {
    'affordability': 0.3,
    'job_market': 0.3,
    'safety': 0.3,
    'climate_warmth': 0.3,
    'transit_infra': 0.3,
    'nature': 0.3,
    'university': 0.3,
    'community': 0.3,
    'proximity_argentina': 0.3,
  };

  Future<MigrationPlan> generate({
    required List<Answer> answers,
    required QuestionnaireVariant variant,
  }) async {
    final answerMap = {
      for (final answer in answers) answer.questionId: answer.values,
    };

    final originCountry = _firstValue(answerMap['origin_country']);
    final destinationCountry = _firstValue(answerMap['destination_country']);
    final intent = _firstValue(answerMap['intent']);
    final funding = _firstValue(answerMap['funding']);
    final timeline = _firstValue(answerMap['timeline']);
    final priorities = answerMap['priorities'] ?? const <String>[];
    final constraints = answerMap['constraints'] ?? const <String>[];
    final archetypeKey = _resolveArchetype(intent: intent, funding: funding);

    final recommendation = await _recommendCities(
      destinationCountry: destinationCountry,
      archetypeKey: archetypeKey,
      funding: funding,
      priorities: priorities,
      constraints: constraints,
    );

    return MigrationPlanModel(
      originCountry: originCountry,
      destinationCountry: destinationCountry,
      goal: intent,
      timeline: timeline,
      variant: variant,
      funding: funding,
      archetypeKey: archetypeKey,
      confidence: recommendation.confidence,
      selectedPriorities: priorities,
      selectedConstraints: constraints,
      recommendedCity: recommendation.topCities.isEmpty
          ? null
          : recommendation.topCities.first.city,
      candidateCities: recommendation.topCities
          .map((item) => item.city)
          .toList(),
      cityRecommendationReasons: recommendation.reasons,
      isCityConfirmed: false,
      steps: _buildSteps(
        timeline: timeline,
        funding: funding,
        variant: variant,
      ),
    ).toEntity();
  }

  Future<
    ({List<_ScoredCity> topCities, List<String> reasons, double confidence})
  >
  _recommendCities({
    required String destinationCountry,
    required String archetypeKey,
    required String funding,
    required List<String> priorities,
    required List<String> constraints,
  }) async {
    if (!_isBrazilJourney(destinationCountry)) {
      return (
        topCities: const <_ScoredCity>[],
        reasons: const <String>[],
        confidence: 0.0,
      );
    }

    final cities = await _citiesRepository.getCities(countryCode: 'BR');
    if (cities.isEmpty) {
      return (
        topCities: const <_ScoredCity>[],
        reasons: const <String>[],
        confidence: 0.0,
      );
    }

    final weights = _buildWeights(
      priorities: priorities,
      archetypeKey: archetypeKey,
    );
    final conflictFlags = _resolveConflictFlags(constraints);

    final ranked =
        cities
            .map(
              (city) => _ScoredCity(
                city: city,
                score: _scoreCity(
                  city: city,
                  weights: weights,
                  constraints: constraints,
                ),
              ),
            )
            .toList()
          ..sort((a, b) => b.score.compareTo(a.score));

    final topCities = ranked.take(3).toList();
    final reasons = topCities.isEmpty
        ? const <String>[]
        : _buildReasons(
            city: topCities.first.city,
            weights: weights,
            constraints: constraints,
          );
    final confidence = _calcConfidence(
      funding: funding,
      priorities: priorities,
      constraints: constraints,
      topCities: topCities,
      conflictFlags: conflictFlags,
    );

    return (topCities: topCities, reasons: reasons, confidence: confidence);
  }

  String _resolveArchetype({required String intent, required String funding}) {
    if (intent == 'find_job_br' && funding == 'job_offer') {
      return 'job_hunter_with_offer';
    }
    if (intent == 'find_job_br' && funding == 'job_search') {
      return 'job_hunter_searching';
    }
    if (intent == 'remote_income' && funding == 'remote_income') {
      return 'remote_stable';
    }

    return _archetypeByIntent[intent] ?? 'explorer';
  }

  Map<String, double> _buildWeights({
    required List<String> priorities,
    required String archetypeKey,
  }) {
    final base = Map<String, double>.from(
      _baseWeightsByArchetype[archetypeKey] ??
          _baseWeightsByArchetype['explorer']!,
    );

    if (priorities.contains('balanced_unsure')) {
      return _normalizeWeights(_mergeWeights(base, _balancedPreset));
    }

    var merged = Map<String, double>.from(base);
    for (final priority in priorities) {
      final delta = _priorityWeightMap[priority];
      if (delta == null) {
        continue;
      }

      merged = _mergeWeights(merged, delta);
    }

    return _normalizeWeights(merged);
  }

  double _scoreCity({
    required City city,
    required Map<String, double> weights,
    required List<String> constraints,
  }) {
    final dims = _cityDimensions(city);
    var score = 0.0;

    for (final entry in weights.entries) {
      score += (dims[entry.key] ?? 0) * entry.value;
    }

    score *= _constraintMultiplier(
      city: city,
      dims: dims,
      constraints: constraints,
    );

    return score.clamp(0, 1).toDouble();
  }

  Map<String, double> _cityDimensions(City city) {
    final populationNormalized = (city.population / 2200000)
        .clamp(0, 1)
        .toDouble();
    final affordability = _normalizeScore(city.movaroScores.economical);
    final jobMarket =
        ((_normalizeScore(city.movaroScores.workOpportunity) +
                    _normalizeScore(city.jobMarketScore)) /
                2)
            .clamp(0, 1)
            .toDouble();
    final safety = _normalizeScore(city.safetyScore);
    final climateWarmth = (1 - (((city.latitude.abs() - 5) / 30).clamp(0, 1)))
        .clamp(0, 1)
        .toDouble();
    final transitInfra =
        ((populationNormalized * 0.55) +
                (_normalizeScore(city.jobMarketScore) * 0.45))
            .clamp(0, 1)
            .toDouble();
    final nature =
        (CityCoastalProfile.isCoastal(city)
                ? 0.92
                : (0.42 + (1 - populationNormalized) * 0.28))
            .clamp(0, 1)
            .toDouble();
    final university =
        ((populationNormalized * 0.65) +
                (_normalizeScore(city.idhmScore * 100) * 0.35))
            .clamp(0, 1)
            .toDouble();
    final community =
        ((_normalizeScore(city.movaroScores.popularForArgentinians) +
                    _normalizeScore(city.movaroScores.languageAdaptation)) /
                2)
            .clamp(0, 1)
            .toDouble();
    final proximityArgentina = _proximityToArgentina(city);

    return {
      'affordability': affordability,
      'job_market': jobMarket,
      'safety': safety,
      'climate_warmth': climateWarmth,
      'transit_infra': transitInfra,
      'nature': nature,
      'university': university,
      'community': community,
      'proximity_argentina': proximityArgentina,
    };
  }

  double _constraintMultiplier({
    required City city,
    required Map<String, double> dims,
    required List<String> constraints,
  }) {
    if (constraints.isEmpty || constraints.contains('no_constraints')) {
      return 1;
    }

    var multiplier = 1.0;
    final region = _regionFor(city);
    final size = _sizeFor(city);
    final climate = _climateFor(city);

    if (constraints.contains('want_coast') &&
        !CityCoastalProfile.isCoastal(city)) {
      multiplier *= 0.75;
    }
    if (constraints.contains('prefer_south') && region != 'south') {
      multiplier *= 0.80;
    }
    if (constraints.contains('need_big_city') && size != 'big') {
      multiplier *= 0.75;
    }
    if (constraints.contains('prefer_mid_city') && size == 'big') {
      multiplier *= 0.85;
    }
    if (constraints.contains('prefer_cooler') && climate == 'warmer') {
      multiplier *= 0.85;
    }
    if (constraints.contains('need_transit')) {
      multiplier *= 0.8 + (0.2 * (dims['transit_infra'] ?? 0));
    }
    if (constraints.contains('avoid_expensive')) {
      multiplier *= 0.8 + (0.2 * (dims['affordability'] ?? 0));
    }

    return multiplier;
  }

  List<String> _buildReasons({
    required City city,
    required Map<String, double> weights,
    required List<String> constraints,
  }) {
    final dims = _cityDimensions(city);
    final rankedReasons = <({String id, double score})>[];

    for (final entry in weights.entries) {
      rankedReasons.add((
        id: _reasonForDimension(entry.key, constraints),
        score: (dims[entry.key] ?? 0) * entry.value,
      ));
    }

    rankedReasons.sort((a, b) => b.score.compareTo(a.score));
    final unique = <String>[];

    for (final reason in rankedReasons) {
      if (!unique.contains(reason.id)) {
        unique.add(reason.id);
      }
      if (unique.length == 3) {
        break;
      }
    }

    if (unique.isEmpty) {
      unique.add('plan_reason_balanced_profile');
    }

    return unique;
  }

  String _reasonForDimension(String dimension, List<String> constraints) {
    switch (dimension) {
      case 'affordability':
        return 'plan_reason_budget_fit';
      case 'job_market':
        return 'plan_reason_job_mobility';
      case 'safety':
        return 'plan_reason_safety';
      case 'climate_warmth':
      case 'nature':
        return 'plan_reason_climate_nature';
      case 'transit_infra':
        return 'plan_reason_transit';
      case 'university':
        return 'plan_reason_university';
      case 'community':
        return 'plan_reason_community';
      case 'proximity_argentina':
        return constraints.contains('prefer_south') ||
                constraints.contains('close_to_argentina')
            ? 'plan_reason_proximity_argentina'
            : 'plan_reason_proximity_argentina';
      default:
        return 'plan_reason_balanced_profile';
    }
  }

  List<MigrationStepModel> _buildSteps({
    required String timeline,
    required String funding,
    required QuestionnaireVariant variant,
  }) {
    final urgency = switch (timeline) {
      'in_0_3m' => 'urgent',
      'just_exploring' || 'depends' => 'explore',
      _ => 'balanced',
    };
    final firstStepDescription =
        variant == QuestionnaireVariant.strategic && funding == 'job_offer'
        ? 'step_desc_choose_base_city_offer'
        : 'step_desc_choose_base_city_$urgency';
    final residenceDescription =
        variant == QuestionnaireVariant.strategic && funding == 'dont_know'
        ? 'step_desc_residence_path_funding_unknown'
        : 'step_desc_residence_path_$urgency';

    return [
      MigrationStepModel(
        title: 'step_choose_base_city',
        description: firstStepDescription,
        category: 'planning',
        estimatedDays: urgency == 'urgent' ? 2 : 7,
      ),
      MigrationStepModel(
        title: 'step_residence_path',
        description: residenceDescription,
        category: 'documentation',
        estimatedDays: urgency == 'urgent' ? 3 : 7,
      ),
      const MigrationStepModel(
        title: 'step_cpf_start',
        description: 'step_desc_cpf_start',
        category: 'documentation',
        estimatedDays: 2,
      ),
    ];
  }

  double _calcConfidence({
    required String funding,
    required List<String> priorities,
    required List<String> constraints,
    required List<_ScoredCity> topCities,
    required List<String> conflictFlags,
  }) {
    var penalty = 0.0;
    if (priorities.contains('balanced_unsure')) {
      penalty += 0.28;
    }
    if (constraints.isEmpty || constraints.contains('no_constraints')) {
      penalty += 0.10;
    }
    if (funding == 'dont_know') {
      penalty += 0.12;
    }

    final completeness = (1 - penalty).clamp(0.28, 1).toDouble();
    final delta = topCities.length < 2
        ? 0.08
        : topCities.first.score - topCities[1].score;
    final separation = (delta / 0.15).clamp(0, 1).toDouble();

    return (0.6 * completeness +
            0.4 * separation -
            (conflictFlags.isNotEmpty ? 0.1 : 0))
        .clamp(0, 1)
        .toDouble();
  }

  List<String> _resolveConflictFlags(List<String> constraints) {
    if (constraints.contains('need_big_city') &&
        constraints.contains('prefer_mid_city')) {
      return const ['size_conflict'];
    }

    return const [];
  }

  double _normalizeScore(num score) => (score / 100).clamp(0, 1).toDouble();

  double _proximityToArgentina(City city) {
    final region = _regionFor(city);
    if (region == 'south') {
      return 1;
    }
    if (region == 'southeast') {
      return 0.62;
    }
    return 0.28;
  }

  String _regionFor(City city) {
    const south = {'RS', 'SC', 'PR'};
    const southeast = {'SP', 'RJ', 'MG', 'ES'};

    if (south.contains(city.stateCode)) {
      return 'south';
    }
    if (southeast.contains(city.stateCode)) {
      return 'southeast';
    }
    return 'other';
  }

  String _sizeFor(City city) {
    if (city.population >= 900000) {
      return 'big';
    }
    if (city.population >= 250000) {
      return 'mid';
    }
    return 'small';
  }

  String _climateFor(City city) {
    return city.latitude.abs() >= 24 ? 'cooler' : 'warmer';
  }

  Map<String, double> _mergeWeights(
    Map<String, double> base,
    Map<String, double> extra,
  ) {
    final merged = Map<String, double>.from(base);
    for (final entry in extra.entries) {
      merged.update(
        entry.key,
        (value) => value + entry.value,
        ifAbsent: () => entry.value,
      );
    }
    return merged;
  }

  Map<String, double> _normalizeWeights(Map<String, double> weights) {
    final total = weights.values.fold<double>(0, (sum, value) => sum + value);
    if (total == 0) {
      return weights;
    }

    return {
      for (final entry in weights.entries) entry.key: entry.value / total,
    };
  }

  String _firstValue(List<String>? values) =>
      values == null || values.isEmpty ? '' : values.first;

  bool _isBrazilJourney(String destinationCountry) =>
      destinationCountry == 'brazil' || destinationCountry == 'brasil';
}

class _ScoredCity {
  const _ScoredCity({required this.city, required this.score});

  final City city;
  final double score;
}
