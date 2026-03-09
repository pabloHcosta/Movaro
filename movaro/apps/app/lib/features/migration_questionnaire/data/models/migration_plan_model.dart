import 'package:movaro_app/features/cities/data/models/city_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/migration_questionnaire/data/models/migration_step_model.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_plan.dart';

class MigrationPlanModel {
  const MigrationPlanModel({
    required this.originCountry,
    required this.destinationCountry,
    required this.goal,
    required this.timeline,
    required this.steps,
    this.recommendedCity,
    this.candidateCities = const [],
    this.cityRecommendationReasons = const [],
    this.isCityConfirmed = false,
  });

  factory MigrationPlanModel.fromJson(Map<String, dynamic> json) {
    return MigrationPlanModel(
      originCountry: json['originCountry'] as String,
      destinationCountry: json['destinationCountry'] as String,
      goal: json['goal'] as String,
      timeline: json['timeline'] as String,
      steps: (json['steps'] as List<dynamic>)
          .map(
            (item) => MigrationStepModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      recommendedCity: json['recommendedCity'] == null
          ? null
          : CityModel.fromJson(json['recommendedCity'] as Map<String, dynamic>)
                .toEntity(),
      candidateCities: (json['candidateCities'] as List<dynamic>? ?? const [])
          .map(
            (item) => CityModel.fromJson(item as Map<String, dynamic>).toEntity(),
          )
          .toList(),
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
      steps: plan.steps.map(MigrationStepModel.fromEntity).toList(),
      recommendedCity: plan.recommendedCity,
      candidateCities: plan.candidateCities,
      cityRecommendationReasons: plan.cityRecommendationReasons,
      isCityConfirmed: plan.isCityConfirmed,
    );
  }

  final String originCountry;
  final String destinationCountry;
  final String goal;
  final String timeline;
  final List<MigrationStepModel> steps;
  final City? recommendedCity;
  final List<City> candidateCities;
  final List<String> cityRecommendationReasons;
  final bool isCityConfirmed;

  Map<String, dynamic> toJson() => {
    'originCountry': originCountry,
    'destinationCountry': destinationCountry,
    'goal': goal,
    'timeline': timeline,
    'steps': steps.map((step) => step.toJson()).toList(),
    'recommendedCity': recommendedCity == null
        ? null
        : CityModel.fromEntity(recommendedCity!).toJson(),
    'candidateCities': candidateCities
        .map((city) => CityModel.fromEntity(city).toJson())
        .toList(),
    'cityRecommendationReasons': cityRecommendationReasons,
    'isCityConfirmed': isCityConfirmed,
  };

  MigrationPlan toEntity() => MigrationPlan(
    originCountry: originCountry,
    destinationCountry: destinationCountry,
    goal: goal,
    timeline: timeline,
    steps: steps.map((step) => step.toEntity()).toList(),
    recommendedCity: recommendedCity,
    candidateCities: candidateCities,
    cityRecommendationReasons: cityRecommendationReasons,
    isCityConfirmed: isCityConfirmed,
  );
}
