import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_step.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';

class MigrationPlan {
  const MigrationPlan({
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

  final String originCountry;
  final String destinationCountry;
  final String goal;
  final String timeline;
  final List<MigrationStep> steps;
  final City? recommendedCity;
  final List<City> candidateCities;
  final List<String> cityRecommendationReasons;
  final bool isCityConfirmed;

  MigrationPlan copyWith({
    String? originCountry,
    String? destinationCountry,
    String? goal,
    String? timeline,
    List<MigrationStep>? steps,
    City? recommendedCity,
    List<City>? candidateCities,
    List<String>? cityRecommendationReasons,
    bool? isCityConfirmed,
  }) {
    return MigrationPlan(
      originCountry: originCountry ?? this.originCountry,
      destinationCountry: destinationCountry ?? this.destinationCountry,
      goal: goal ?? this.goal,
      timeline: timeline ?? this.timeline,
      steps: steps ?? this.steps,
      recommendedCity: recommendedCity ?? this.recommendedCity,
      candidateCities: candidateCities ?? this.candidateCities,
      cityRecommendationReasons:
          cityRecommendationReasons ?? this.cityRecommendationReasons,
      isCityConfirmed: isCityConfirmed ?? this.isCityConfirmed,
    );
  }
}
