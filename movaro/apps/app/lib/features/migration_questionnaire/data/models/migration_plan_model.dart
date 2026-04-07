import 'package:movaro_app/features/cities/data/models/city_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/migration_step_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';

class MigrationPlanModel {
  const MigrationPlanModel({
    required this.originCountry,
    required this.destinationCountry,
    required this.goal,
    required this.timeline,
    required this.steps,
    this.variant = QuestionnaireVariant.lean,
    this.funding = '',
    this.travelGroup = '',
    this.childrenCount,
    this.availableCapital = '',
    this.archetypeKey,
    this.confidence = 0,
    this.selectedPriorities = const [],
    this.selectedConstraints = const [],
    this.highlightedCity,
    this.preferredCity,
    this.candidateCities = const [],
    this.candidateCityMatchScores = const {},
    this.cityRecommendationReasons = const [],
    this.isCityConfirmed = false,
  });

  factory MigrationPlanModel.fromJson(Map<String, dynamic> json) {
    return MigrationPlanModel(
      originCountry: json['originCountry'] as String,
      destinationCountry: json['destinationCountry'] as String,
      goal: json['goal'] as String,
      timeline: json['timeline'] as String,
      variant:
          QuestionnaireVariantX.fromId(json['variant'] as String?) ??
          QuestionnaireVariant.lean,
      funding: json['funding'] as String? ?? '',
      travelGroup: json['travelGroup'] as String? ?? '',
      childrenCount: (json['childrenCount'] as num?)?.toInt(),
      availableCapital: json['availableCapital'] as String? ?? '',
      archetypeKey: json['archetypeKey'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
      selectedPriorities:
          (json['selectedPriorities'] as List<dynamic>? ?? const [])
              .map((item) => item as String)
              .toList(),
      selectedConstraints:
          (json['selectedConstraints'] as List<dynamic>? ?? const [])
              .map((item) => item as String)
              .toList(),
      steps: (json['steps'] as List<dynamic>)
          .map(
            (item) => MigrationStepModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      highlightedCity:
          (json['highlightedCity'] ?? json['recommendedCity']) == null
          ? null
          : CityModel.fromJson(
              (json['highlightedCity'] ?? json['recommendedCity'])
                  as Map<String, dynamic>,
            ).toEntity(),
      preferredCity: json['preferredCity'] == null
          ? null
          : CityModel.fromJson(
              json['preferredCity'] as Map<String, dynamic>,
            ).toEntity(),
      candidateCities: (json['candidateCities'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                CityModel.fromJson(item as Map<String, dynamic>).toEntity(),
          )
          .toList(),
      candidateCityMatchScores:
          (json['candidateCityMatchScores'] as Map<String, dynamic>? ??
                  const <String, dynamic>{})
              .map(
                (key, value) => MapEntry(
                  key,
                  (value as num?)?.toDouble() ?? 0,
                ),
              ),
      cityRecommendationReasons:
          (json['cityRecommendationReasons'] as List<dynamic>? ?? const [])
              .map((item) => item as String)
              .toList(),
      isCityConfirmed: json['isCityConfirmed'] as bool? ?? false,
    );
  }

  factory MigrationPlanModel.fromEntity(MigrationPlan plan) {
    return MigrationPlanModel(
      originCountry: plan.originCountry,
      destinationCountry: plan.destinationCountry,
      goal: plan.goal,
      timeline: plan.timeline,
      variant: plan.variant,
      funding: plan.funding,
      travelGroup: plan.travelGroup,
      childrenCount: plan.childrenCount,
      availableCapital: plan.availableCapital,
      archetypeKey: plan.archetypeKey,
      confidence: plan.confidence,
      selectedPriorities: plan.selectedPriorities,
      selectedConstraints: plan.selectedConstraints,
      steps: plan.steps.map(MigrationStepModel.fromEntity).toList(),
      highlightedCity: plan.highlightedCity,
      preferredCity: plan.preferredCity,
      candidateCities: plan.candidateCities,
      candidateCityMatchScores: plan.candidateCityMatchScores,
      cityRecommendationReasons: plan.cityRecommendationReasons,
      isCityConfirmed: plan.isCityConfirmed,
    );
  }

  final String originCountry;
  final String destinationCountry;
  final String goal;
  final String timeline;
  final QuestionnaireVariant variant;
  final String funding;
  final String travelGroup;
  final int? childrenCount;
  final String availableCapital;
  final String? archetypeKey;
  final double confidence;
  final List<String> selectedPriorities;
  final List<String> selectedConstraints;
  final List<MigrationStepModel> steps;
  final City? highlightedCity;
  final City? preferredCity;
  final List<City> candidateCities;
  final Map<String, double> candidateCityMatchScores;
  final List<String> cityRecommendationReasons;
  final bool isCityConfirmed;

  Map<String, dynamic> toJson() => {
    'originCountry': originCountry,
    'destinationCountry': destinationCountry,
    'goal': goal,
    'timeline': timeline,
    'variant': variant.id,
    'funding': funding,
    'travelGroup': travelGroup,
    'childrenCount': childrenCount,
    'availableCapital': availableCapital,
    'archetypeKey': archetypeKey,
    'confidence': confidence,
    'selectedPriorities': selectedPriorities,
    'selectedConstraints': selectedConstraints,
    'steps': steps.map((step) => step.toJson()).toList(),
    'highlightedCity': highlightedCity == null
        ? null
        : CityModel.fromEntity(highlightedCity!).toJson(),
    'preferredCity': preferredCity == null
        ? null
        : CityModel.fromEntity(preferredCity!).toJson(),
    'candidateCities': candidateCities
        .map((city) => CityModel.fromEntity(city).toJson())
        .toList(),
    'candidateCityMatchScores': candidateCityMatchScores,
    'cityRecommendationReasons': cityRecommendationReasons,
    'isCityConfirmed': isCityConfirmed,
  };

  MigrationPlan toEntity() => MigrationPlan(
    originCountry: originCountry,
    destinationCountry: destinationCountry,
    goal: goal,
    timeline: timeline,
    variant: variant,
    funding: funding,
    travelGroup: travelGroup,
    childrenCount: childrenCount,
    availableCapital: availableCapital,
    archetypeKey: archetypeKey,
    confidence: confidence,
    selectedPriorities: selectedPriorities,
    selectedConstraints: selectedConstraints,
    steps: steps.map((step) => step.toEntity()).toList(),
    highlightedCity: highlightedCity,
    preferredCity: preferredCity,
    candidateCities: candidateCities,
    candidateCityMatchScores: candidateCityMatchScores,
    cityRecommendationReasons: cityRecommendationReasons,
    isCityConfirmed: isCityConfirmed,
  );
}
