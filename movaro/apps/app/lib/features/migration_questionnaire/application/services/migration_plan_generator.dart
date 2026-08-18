import 'package:movaro_app/features/cities/domain/entities/city_recommendation.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/migration_plan_model.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/migration_step_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/answer.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';

/// Builds a migration plan from the versioned recommendation returned by API.
///
/// Ranking, filtering, scoring, evidence and freshness are intentionally not
/// recomputed on-device. That keeps one methodology authoritative and avoids a
/// different result when the app or its bundled catalog is older than the API.
class MigrationPlanGenerator {
  const MigrationPlanGenerator({required CitiesRepository citiesRepository})
    : _citiesRepository = citiesRepository;

  final CitiesRepository _citiesRepository;

  Future<CityRecommendationResult?> evaluateRefinement({
    required List<Answer> answers,
  }) async {
    final answerMap = {
      for (final answer in answers) answer.questionId: answer.values,
    };
    final destinationCountry = _firstValue(answerMap['destination_country']);
    if (!_isBrazilJourney(destinationCountry)) return null;

    final result = await _citiesRepository.recommendCities(
      _recommendationProfile(answerMap),
    );
    return result;
  }

  Future<MigrationPlan> generate({
    required List<Answer> answers,
    required QuestionnaireVariant variant,
  }) async {
    final answerMap = {
      for (final answer in answers) answer.questionId: answer.values,
    };

    final originCountry = _firstValue(answerMap['origin_country']);
    final destinationCountry = _firstValue(answerMap['destination_country']);
    final rawIntent = _firstValue(answerMap['intent']);
    final intent = rawIntent.isEmpty ? 'explore_unsure' : rawIntent;
    final funding = _firstValue(answerMap['funding']);
    final rawTimeline = _firstValue(answerMap['timeline']);
    final timeline = rawTimeline.isEmpty ? 'depends' : rawTimeline;
    final travelGroup = _firstValue(answerMap['travel_group']);
    final childrenCount = _parseChildrenCount(
      _firstValue(answerMap['travel_group_children_count']),
    );
    final availableCapital = _firstValue(answerMap['available_capital']);
    final priorities = answerMap['priorities'] ?? const <String>[];
    final rankingConstraints = answerMap['constraints'] ?? const <String>[];
    final supportNeeds = answerMap['support_needs'] ?? const <String>[];
    final selectedConstraints = <String>[
      ...rankingConstraints,
      ...supportNeeds,
    ];
    final workArrangement = _firstValue(answerMap['work_arrangement']);
    final archetypeKey = _resolveArchetype(
      intent: intent,
      funding: funding,
      workArrangement: workArrangement,
    );

    final result = _isBrazilJourney(destinationCountry)
        ? await _citiesRepository.recommendCities(
            _recommendationProfile(answerMap),
          )
        : _emptyRecommendation();
    final recommendations = result.recommendations;
    final highlighted = recommendations.firstOrNull;

    return MigrationPlanModel(
      originCountry: originCountry,
      destinationCountry: destinationCountry,
      goal: intent,
      timeline: timeline,
      variant: variant,
      funding: funding,
      workArrangement: workArrangement,
      travelGroup: travelGroup,
      childrenCount: childrenCount,
      availableCapital: availableCapital,
      archetypeKey: archetypeKey,
      confidence: result.profileCompleteness,
      selectedPriorities: priorities,
      selectedConstraints: selectedConstraints,
      highlightedCity: highlighted?.city,
      candidateCities: recommendations
          .map((item) => item.city)
          .toList(growable: false),
      candidateCityMatchScores: {
        for (final item in recommendations) item.city.id: item.score,
      },
      candidateCityDimensionScores: {
        for (final item in recommendations) item.city.id: item.dimensions,
      },
      candidateCityReasons: {
        for (final item in recommendations) item.city.id: item.reasons,
      },
      cityRecommendationReasons: highlighted?.reasons ?? const [],
      recommendationId: result.recommendationId,
      recommendationMethodologyVersion: result.methodologyVersion,
      recommendationGeneratedAt: result.generatedAt,
      recommendationDataCoverage: result.dataCoverage,
      recommendationFreshnessStatus: _freshnessFor(recommendations),
      recommendationWarnings: result.warnings,
      recommendationSourceLabels: result.sourceSummary
          .map((item) => item.provider)
          .where((provider) => provider.isNotEmpty)
          .toSet()
          .toList(growable: false),
      recommendationStabilityBand: result.stabilityBand,
      recommendationReliabilityBand: result.reliabilityBand,
      recommendationScoreSeparationBand: result.scoreSeparationBand,
      recommendationScenariosEvaluated: result.scenariosEvaluated,
      isCityConfirmed: false,
      steps: _buildSteps(
        timeline: timeline,
        funding: funding,
        variant: variant,
        intent: intent,
        travelGroup: travelGroup,
        childrenCount: childrenCount,
      ),
    ).toEntity();
  }

  CityRecommendationProfile _recommendationProfile(
    Map<String, List<String>> answerMap,
  ) {
    final rawIntent = _firstValue(answerMap['intent']);
    return CityRecommendationProfile(
      destinationCountryCode: 'BR',
      intent: rawIntent.isEmpty ? 'explore_unsure' : rawIntent,
      funding: _firstValue(answerMap['funding']),
      workArrangement: _firstValue(answerMap['work_arrangement']),
      travelGroup: _firstValue(answerMap['travel_group']),
      childrenCount: _parseChildrenCount(
        _firstValue(answerMap['travel_group_children_count']),
      ),
      availableCapital: _firstValue(answerMap['available_capital']),
      priorities: answerMap['priorities'] ?? const <String>[],
      constraints: answerMap['constraints'] ?? const <String>[],
      supportNeeds: answerMap['support_needs'] ?? const <String>[],
      originLatitude: _parseDouble(_firstValue(answerMap['origin_latitude'])),
      originLongitude: _parseDouble(_firstValue(answerMap['origin_longitude'])),
    );
  }

  String _resolveArchetype({
    required String intent,
    required String funding,
    required String workArrangement,
  }) {
    if (workArrangement == 'remote' ||
        (intent == 'remote_income' && funding == 'remote_income')) {
      return funding == 'remote_income' ? 'remote_stable' : 'remote_worker';
    }
    if (intent == 'find_job_br' && funding == 'job_offer') {
      return 'job_hunter_with_offer';
    }
    if (intent == 'find_job_br' && funding == 'job_search') {
      return 'job_hunter_searching';
    }
    return switch (intent) {
      'find_job_br' => 'job_hunter',
      'remote_income' => 'remote_worker',
      'study' => 'student',
      'family_partner' => 'family_move',
      'fresh_start' => 'fresh_start',
      _ => 'explorer',
    };
  }

  List<MigrationStepModel> _buildSteps({
    required String timeline,
    required String funding,
    required QuestionnaireVariant variant,
    required String intent,
    required String travelGroup,
    required int? childrenCount,
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

    final steps = <MigrationStepModel>[
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

    if (intent == 'study') {
      steps.addAll(const [
        MigrationStepModel(
          title: 'step_education_admission_route',
          description: 'step_desc_education_admission_route',
          category: 'education',
          estimatedDays: 7,
        ),
        MigrationStepModel(
          title: 'step_education_documents',
          description: 'step_desc_education_documents',
          category: 'education',
          estimatedDays: 14,
        ),
      ]);
    }

    final hasChildren =
        travelGroup == 'family_kids' ||
        travelGroup == 'solo_parent' ||
        (childrenCount ?? 0) > 0;
    if (hasChildren) {
      steps.add(
        const MigrationStepModel(
          title: 'step_school_enrollment',
          description: 'step_desc_school_enrollment',
          category: 'education',
          estimatedDays: 7,
        ),
      );
    }
    return steps;
  }

  String _freshnessFor(List<RecommendedCity> recommendations) {
    if (recommendations.any((item) => item.freshnessStatus == 'stale')) {
      return 'stale';
    }
    if (recommendations.any((item) => item.freshnessStatus == 'unknown')) {
      return 'unknown';
    }
    return recommendations.isEmpty ? 'unknown' : 'fresh';
  }

  CityRecommendationResult _emptyRecommendation() {
    return const CityRecommendationResult(
      methodologyVersion: 'unsupported-route',
      generatedAt: '',
      catalogSize: 0,
      eligibleCityCount: 0,
      profileCompleteness: 0,
      dataCoverage: 0,
      appliedHardFilters: [],
      unavailableDimensions: [],
      warnings: ['recommendation_warning_unsupported_route'],
      recommendations: [],
      sourceSummary: [],
    );
  }

  bool _isBrazilJourney(String destinationCountry) {
    final normalized = destinationCountry.trim().toLowerCase();
    return normalized == 'brasil' || normalized == 'brazil';
  }

  int? _parseChildrenCount(String value) {
    return switch (value) {
      '1' => 1,
      '2' => 2,
      '3+' => 3,
      _ => null,
    };
  }

  double? _parseDouble(String value) => double.tryParse(value);

  String _firstValue(List<String>? values) {
    if (values == null || values.isEmpty) return '';
    return values.first;
  }
}
