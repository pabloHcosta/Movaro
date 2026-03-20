import 'package:movaro_app/features/migration_questionnaire/domain/entities/migration_step.dart';
import 'package:movaro_app/features/migration_questionnaire/domain/entities/questionnaire_variant.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';

class MigrationPlan {
  const MigrationPlan({
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
  final QuestionnaireVariant variant;
  final String funding;
  final String travelGroup;
  final int? childrenCount;
  final String availableCapital;
  final String? archetypeKey;
  final double confidence;
  final List<String> selectedPriorities;
  final List<String> selectedConstraints;
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
    QuestionnaireVariant? variant,
    String? funding,
    String? travelGroup,
    Object? childrenCount = _migrationPlanNoChange,
    String? availableCapital,
    String? archetypeKey,
    double? confidence,
    List<String>? selectedPriorities,
    List<String>? selectedConstraints,
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
      variant: variant ?? this.variant,
      funding: funding ?? this.funding,
      travelGroup: travelGroup ?? this.travelGroup,
      childrenCount: identical(childrenCount, _migrationPlanNoChange)
          ? this.childrenCount
          : childrenCount as int?,
      availableCapital: availableCapital ?? this.availableCapital,
      archetypeKey: archetypeKey ?? this.archetypeKey,
      confidence: confidence ?? this.confidence,
      selectedPriorities: selectedPriorities ?? this.selectedPriorities,
      selectedConstraints: selectedConstraints ?? this.selectedConstraints,
      recommendedCity: recommendedCity ?? this.recommendedCity,
      candidateCities: candidateCities ?? this.candidateCities,
      cityRecommendationReasons:
          cityRecommendationReasons ?? this.cityRecommendationReasons,
      isCityConfirmed: isCityConfirmed ?? this.isCityConfirmed,
    );
  }
}

const Object _migrationPlanNoChange = Object();
