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

  // ── Shortlist balancing: familiar reference cities for Argentinian users ──
  //
  // We keep one familiar reference visible so the shortlist feels grounded,
  // without forcing a deterministic #1 result around it. The reference is
  // chosen by ICP: the PRIMARY profile is the economic migrant (work/cost
  // driven), so for those profiles we anchor to a familiar *job hub* (South,
  // interior or a major metro) — not a beach town. The SECONDARY lifestyle
  // profile anchors to familiar coastal/quality-of-life cities instead.
  static const _workAnchorCityIds = {
    'porto-alegre-rs',
    'curitiba-pr',
    'joinville-sc',
    'caxias-do-sul-rs',
    'campinas-sp',
    'sao-paulo-sp',
  };

  static const _lifestyleAnchorCityIds = {
    'florianopolis-sc',
    'rio-de-janeiro-rj',
    'balneario-camboriu-sc',
    'curitiba-pr',
  };

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

  // Work arrangement boosts applied on top of archetype base weights.
  // Remote workers need lifestyle cities; local job seekers need big markets.
  static const Map<String, Map<String, double>> _workArrangementBoosts = {
    'remote': {'nature': 0.4, 'climate_warmth': 0.3, 'community': 0.2},
    'local_job': {'job_market': 0.5, 'transit_infra': 0.3},
    'both_open': {},
  };

  // Province-of-origin boosts for Argentinian users.
  // Cordobeses and Mendocinos historically choose Santa Catarina coast.
  // Litoraleños are closer to Rio Grande do Sul.
  static const Map<String, Map<String, double>> _provinceBoosts = {
    'cordoba': {'proximity_argentina': 0.3, 'community': 0.2},
    'mendoza': {'proximity_argentina': 0.3, 'community': 0.2},
    'salta_jujuy': {'proximity_argentina': 0.4, 'community': 0.15},
    'litoral': {'proximity_argentina': 0.5},
    'rosario': {'job_market': 0.2, 'transit_infra': 0.2},
    'buenos_aires': {'job_market': 0.15},
  };

  // Low-signal default ("balanced_unsure"). Leans gently toward the PRIMARY
  // ICP (economic migrant): affordability, job market and proximity to
  // Argentina are weighted slightly above lifestyle dimensions, so an
  // undecided user is nudged toward practical, work-viable cities rather than
  // beach towns — without overriding any explicit preference they do give.
  static const Map<String, double> _balancedPreset = {
    'affordability': 0.34,
    'job_market': 0.34,
    'safety': 0.30,
    'climate_warmth': 0.28,
    'transit_infra': 0.30,
    'nature': 0.28,
    'university': 0.30,
    'community': 0.30,
    'proximity_argentina': 0.34,
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
    final travelGroup = _firstValue(answerMap['travel_group']);
    final childrenCount = _parseChildrenCount(
      _firstValue(answerMap['travel_group_children_count']),
    );
    final availableCapital = _firstValue(answerMap['available_capital']);
    final priorities = answerMap['priorities'] ?? const <String>[];
    final constraints = answerMap['constraints'] ?? const <String>[];
    final workArrangement = _firstValue(answerMap['work_arrangement']);
    final argentinaOrigin = _firstValue(answerMap['argentina_origin']);
    final archetypeKey = _resolveArchetype(
      intent: intent,
      funding: funding,
      workArrangement: workArrangement,
    );

    final recommendation = await _recommendCities(
      destinationCountry: destinationCountry,
      archetypeKey: archetypeKey,
      funding: funding,
      priorities: priorities,
      constraints: constraints,
      workArrangement: workArrangement,
      argentinaOrigin: argentinaOrigin,
    );

    return MigrationPlanModel(
      originCountry: originCountry,
      destinationCountry: destinationCountry,
      goal: intent,
      timeline: timeline,
      variant: variant,
      funding: funding,
      travelGroup: travelGroup,
      childrenCount: childrenCount,
      availableCapital: availableCapital,
      archetypeKey: archetypeKey,
      confidence: recommendation.confidence,
      selectedPriorities: priorities,
      selectedConstraints: constraints,
      highlightedCity: recommendation.topCities.isEmpty
          ? null
          : recommendation.topCities.first.city,
      candidateCities: recommendation.topCities
          .map((item) => item.city)
          .toList(),
      candidateCityMatchScores: {
        for (final item in recommendation.topCities)
          item.city.id: item.score,
      },
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
    required String workArrangement,
    required String argentinaOrigin,
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
      workArrangement: workArrangement,
      argentinaOrigin: argentinaOrigin,
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

    // Apply anti-deception rules to ensure emotionally-correct results.
    final topCities = _applyAntiDeceptionRules(
      ranked: ranked,
      archetypeKey: archetypeKey,
      priorities: priorities,
    );

    final reasons = _buildShortlistReasons(
      topCities: topCities,
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

  /// Balances the shortlist so it includes familiar comparison anchors without
  /// turning the first ranked city into a definitive answer.
  List<_ScoredCity> _applyAntiDeceptionRules({
    required List<_ScoredCity> ranked,
    required String archetypeKey,
    required List<String> priorities,
  }) {
    final shortlist = ranked.take(3).toList();

    // ── lifestyle/remote → consider Florianópolis ────────────────────────
    final isLifestyle =
        archetypeKey.contains('remote') ||
        priorities.any((p) => p == 'warm_climate_beach' || p == 'nature');
    if (isLifestyle) {
      final hasFloripa = shortlist.any((c) => c.city.id == 'florianopolis-sc');
      if (!hasFloripa) {
        final floripa = _findById(ranked, 'florianopolis-sc');
        if (floripa != null) _mergeShortlistCity(shortlist, floripa);
      }
    }

    // ── job/career → consider São Paulo ──────────────────────────────────
    final isCareer = archetypeKey.startsWith('job_hunter');
    if (isCareer) {
      final hasSp = shortlist.any((c) => c.city.id == 'sao-paulo-sp');
      if (!hasSp) {
        final sp = _findById(ranked, 'sao-paulo-sp');
        if (sp != null) _mergeShortlistCity(shortlist, sp);
      }
    }

    // ── Keep one familiar anchor, chosen by ICP ──────────────────────────
    // Primary ICP (economic migrant) anchors to a familiar job hub; the
    // secondary lifestyle profile anchors to a familiar coastal city. This
    // stops the engine from forcing a beach town into a work-seeker's result.
    final preferredAnchors = isLifestyle
        ? _lifestyleAnchorCityIds
        : _workAnchorCityIds;
    final hasAnchor = shortlist.any(
      (c) => preferredAnchors.contains(c.city.id),
    );
    if (!hasAnchor) {
      _ScoredCity? best;
      for (final candidate in ranked) {
        if (preferredAnchors.contains(candidate.city.id)) {
          best = candidate;
          break;
        }
      }
      if (best != null) _mergeShortlistCity(shortlist, best);
    }

    shortlist.sort((a, b) => b.score.compareTo(a.score));
    return shortlist.take(3).toList(growable: false);
  }

  _ScoredCity? _findById(List<_ScoredCity> ranked, String id) {
    for (final c in ranked) {
      if (c.city.id == id) return c;
    }
    return null;
  }

  void _mergeShortlistCity(List<_ScoredCity> shortlist, _ScoredCity city) {
    final alreadyPresent = shortlist.any((item) => item.city.id == city.city.id);
    if (alreadyPresent) {
      return;
    }

    if (shortlist.length < 3) {
      shortlist.add(city);
      return;
    }

    var weakestIndex = 0;
    for (var index = 1; index < shortlist.length; index++) {
      if (shortlist[index].score < shortlist[weakestIndex].score) {
        weakestIndex = index;
      }
    }
    shortlist[weakestIndex] = city;
  }

  /// Resolves archetype taking into account explicit work arrangement.
  ///
  /// A user who says "remote" but whose intent was `find_job_br` should be
  /// treated as remote_worker since the arrangement signal is more specific.
  String _resolveArchetype({
    required String intent,
    required String funding,
    required String workArrangement,
  }) {
    // Explicit remote-work arrangement overrides job-hunt intent
    if (workArrangement == 'remote' &&
        (funding == 'remote_income' || funding == 'savings')) {
      return 'remote_stable';
    }
    if (workArrangement == 'remote') return 'remote_worker';

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

  int? _parseChildrenCount(String value) {
    return switch (value) {
      '1' => 1,
      '2' => 2,
      '3+' => 3,
      _ => null,
    };
  }

  Map<String, double> _buildWeights({
    required List<String> priorities,
    required String archetypeKey,
    required String workArrangement,
    required String argentinaOrigin,
  }) {
    final base = Map<String, double>.from(
      _baseWeightsByArchetype[archetypeKey] ??
          _baseWeightsByArchetype['explorer']!,
    );

    if (priorities.contains('balanced_unsure')) {
      var merged = _mergeWeights(base, _balancedPreset);
      merged = _applyExtraBoosts(merged, workArrangement, argentinaOrigin);
      return _normalizeWeights(merged);
    }

    var merged = Map<String, double>.from(base);
    for (final priority in priorities) {
      final delta = _priorityWeightMap[priority];
      if (delta == null) continue;
      merged = _mergeWeights(merged, delta);
    }

    merged = _applyExtraBoosts(merged, workArrangement, argentinaOrigin);
    return _normalizeWeights(merged);
  }

  /// Applies work-arrangement and province-of-origin boosts to the weight map.
  Map<String, double> _applyExtraBoosts(
    Map<String, double> weights,
    String workArrangement,
    String argentinaOrigin,
  ) {
    var result = Map<String, double>.from(weights);

    final arrangementBoost = _workArrangementBoosts[workArrangement];
    if (arrangementBoost != null && arrangementBoost.isNotEmpty) {
      result = _mergeWeights(result, arrangementBoost);
    }

    final provinceBoost = _provinceBoosts[argentinaOrigin];
    if (provinceBoost != null && provinceBoost.isNotEmpty) {
      result = _mergeWeights(result, provinceBoost);
    }

    return result;
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

    // Research shows "popular with Argentinians" is a stronger predictor of
    // satisfaction than language adaptation alone (70/30 split).
    final community =
        ((_normalizeScore(city.movaroScores.popularForArgentinians) * 0.70 +
                _normalizeScore(city.movaroScores.languageAdaptation) * 0.30))
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

  List<String> _buildShortlistReasons({
    required List<_ScoredCity> topCities,
    required Map<String, double> weights,
    required List<String> constraints,
  }) {
    if (topCities.isEmpty) {
      return const <String>[];
    }

    final aggregated = <String, double>{};
    for (final item in topCities) {
      final dims = _cityDimensions(item.city);
      for (final entry in weights.entries) {
        final reasonId = _reasonForDimension(entry.key, constraints);
        final contribution =
            (dims[entry.key] ?? 0) * entry.value * item.score.clamp(0, 1);
        aggregated.update(
          reasonId,
          (value) => value + contribution,
          ifAbsent: () => contribution,
        );
      }
    }

    final rankedReasons = aggregated.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final reasons = rankedReasons
        .take(3)
        .map((entry) => entry.key)
        .toList(growable: false);

    return reasons.isEmpty
        ? const ['plan_reason_balanced_profile']
        : reasons;
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
        return 'plan_reason_proximity_argentina';
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
    final shortlistBase = topCities.isEmpty
        ? 0.18
        : (topCities
                    .map((city) => city.score)
                    .reduce((sum, value) => sum + value) /
                topCities.length)
            .clamp(0, 1)
            .toDouble();

    return (0.65 * completeness +
            0.35 * shortlistBase -
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

  /// Public access to the city dimension scores (0–1 per dimension).
  ///
  /// Used by the result reveal page to show a compatibility breakdown.
  static Map<String, double> cityDimensionsPublic(City city) {
    final populationNormalized = (city.population / 2200000)
        .clamp(0, 1)
        .toDouble();
    final affordability = _normalizeScoreStatic(city.movaroScores.economical);
    final jobMarket =
        ((_normalizeScoreStatic(city.movaroScores.workOpportunity) +
                    _normalizeScoreStatic(city.jobMarketScore)) /
                2)
            .clamp(0, 1)
            .toDouble();
    final safety = _normalizeScoreStatic(city.safetyScore);
    final climateWarmth = (1 - (((city.latitude.abs() - 5) / 30).clamp(0, 1)))
        .clamp(0, 1)
        .toDouble();
    final transitInfra =
        ((populationNormalized * 0.55) +
                (_normalizeScoreStatic(city.jobMarketScore) * 0.45))
            .clamp(0, 1)
            .toDouble();
    final nature =
        (CityCoastalProfile.isCoastal(city)
                ? 0.92
                : (0.42 + (1 - populationNormalized) * 0.28))
            .clamp(0, 1)
            .toDouble();
    final community =
        ((_normalizeScoreStatic(city.movaroScores.popularForArgentinians) *
                    0.70 +
                _normalizeScoreStatic(city.movaroScores.languageAdaptation) *
                    0.30))
            .clamp(0, 1)
            .toDouble();

    return {
      'affordability': affordability,
      'job_market': jobMarket,
      'safety': safety,
      'climate_warmth': climateWarmth,
      'transit_infra': transitInfra,
      'nature': nature,
      'community': community,
    };
  }

  static double _normalizeScoreStatic(num score) =>
      (score / 100).clamp(0, 1).toDouble();

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
