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
    this.id,
    this.createdAt,
    this.variant = QuestionnaireVariant.lean,
    this.funding = '',
    this.workArrangement = '',
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
    this.candidateCityDimensionScores = const {},
    this.candidateCityReasons = const {},
    this.cityRecommendationReasons = const [],
    this.recommendationId = '',
    this.recommendationMethodologyVersion = '',
    this.recommendationGeneratedAt = '',
    this.recommendationDataCoverage = 0,
    this.recommendationFreshnessStatus = 'unknown',
    this.recommendationWarnings = const [],
    this.recommendationSourceLabels = const [],
    this.recommendationStabilityBand = 'insufficient_data',
    this.recommendationReliabilityBand = 'limited',
    this.recommendationScoreSeparationBand = 'single_result',
    this.recommendationScenariosEvaluated = 0,
    this.isCityConfirmed = false,
  });

  final String originCountry;
  final String destinationCountry;
  final String goal;
  final String timeline;
  final List<MigrationStep> steps;
  final String? id;
  final DateTime? createdAt;
  final QuestionnaireVariant variant;
  final String funding;
  final String workArrangement;
  final String travelGroup;
  final int? childrenCount;
  final String availableCapital;
  final String? archetypeKey;

  /// Completeness of the answers used to build the shortlist.
  ///
  /// This is not a probability and must not be displayed as a city match.
  final double confidence;
  final List<String> selectedPriorities;
  final List<String> selectedConstraints;
  final City? highlightedCity;
  final City? preferredCity;
  final List<City> candidateCities;
  final Map<String, double> candidateCityMatchScores;
  final Map<String, Map<String, double>> candidateCityDimensionScores;
  final Map<String, List<String>> candidateCityReasons;
  final List<String> cityRecommendationReasons;
  final String recommendationId;
  final String recommendationMethodologyVersion;
  final String recommendationGeneratedAt;
  final double recommendationDataCoverage;
  final String recommendationFreshnessStatus;
  final List<String> recommendationWarnings;
  final List<String> recommendationSourceLabels;
  final String recommendationStabilityBand;
  final String recommendationReliabilityBand;
  final String recommendationScoreSeparationBand;
  final int recommendationScenariosEvaluated;
  final bool isCityConfirmed;

  City? get confirmedCity =>
      isCityConfirmed ? (preferredCity ?? highlightedCity) : null;

  City? get leadingCity =>
      preferredCity ??
      highlightedCity ??
      (candidateCities.isNotEmpty ? candidateCities.first : null);

  City? get currentPlanCity => confirmedCity ?? leadingCity;

  List<City> get reviewCities {
    final ordered = <City>[];
    final seenIds = <String>{};

    void addIfNeeded(City? city) {
      if (city == null || seenIds.contains(city.id)) {
        return;
      }
      seenIds.add(city.id);
      ordered.add(city);
    }

    addIfNeeded(preferredCity);
    addIfNeeded(highlightedCity);
    for (final city in candidateCities) {
      addIfNeeded(city);
    }

    return ordered;
  }

  MigrationPlan copyWith({
    String? id,
    DateTime? createdAt,
    String? originCountry,
    String? destinationCountry,
    String? goal,
    String? timeline,
    List<MigrationStep>? steps,
    QuestionnaireVariant? variant,
    String? funding,
    String? workArrangement,
    String? travelGroup,
    Object? childrenCount = _migrationPlanNoChange,
    String? availableCapital,
    String? archetypeKey,
    double? confidence,
    List<String>? selectedPriorities,
    List<String>? selectedConstraints,
    City? highlightedCity,
    Object? preferredCity = _migrationPlanNoChange,
    List<City>? candidateCities,
    Map<String, double>? candidateCityMatchScores,
    Map<String, Map<String, double>>? candidateCityDimensionScores,
    Map<String, List<String>>? candidateCityReasons,
    List<String>? cityRecommendationReasons,
    String? recommendationId,
    String? recommendationMethodologyVersion,
    String? recommendationGeneratedAt,
    double? recommendationDataCoverage,
    String? recommendationFreshnessStatus,
    List<String>? recommendationWarnings,
    List<String>? recommendationSourceLabels,
    String? recommendationStabilityBand,
    String? recommendationReliabilityBand,
    String? recommendationScoreSeparationBand,
    int? recommendationScenariosEvaluated,
    bool? isCityConfirmed,
  }) {
    return MigrationPlan(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      originCountry: originCountry ?? this.originCountry,
      destinationCountry: destinationCountry ?? this.destinationCountry,
      goal: goal ?? this.goal,
      timeline: timeline ?? this.timeline,
      steps: steps ?? this.steps,
      variant: variant ?? this.variant,
      funding: funding ?? this.funding,
      workArrangement: workArrangement ?? this.workArrangement,
      travelGroup: travelGroup ?? this.travelGroup,
      childrenCount: identical(childrenCount, _migrationPlanNoChange)
          ? this.childrenCount
          : childrenCount as int?,
      availableCapital: availableCapital ?? this.availableCapital,
      archetypeKey: archetypeKey ?? this.archetypeKey,
      confidence: confidence ?? this.confidence,
      selectedPriorities: selectedPriorities ?? this.selectedPriorities,
      selectedConstraints: selectedConstraints ?? this.selectedConstraints,
      highlightedCity: highlightedCity ?? this.highlightedCity,
      preferredCity: identical(preferredCity, _migrationPlanNoChange)
          ? this.preferredCity
          : preferredCity as City?,
      candidateCities: candidateCities ?? this.candidateCities,
      candidateCityMatchScores:
          candidateCityMatchScores ?? this.candidateCityMatchScores,
      candidateCityDimensionScores:
          candidateCityDimensionScores ?? this.candidateCityDimensionScores,
      candidateCityReasons: candidateCityReasons ?? this.candidateCityReasons,
      cityRecommendationReasons:
          cityRecommendationReasons ?? this.cityRecommendationReasons,
      recommendationId: recommendationId ?? this.recommendationId,
      recommendationMethodologyVersion:
          recommendationMethodologyVersion ??
          this.recommendationMethodologyVersion,
      recommendationGeneratedAt:
          recommendationGeneratedAt ?? this.recommendationGeneratedAt,
      recommendationDataCoverage:
          recommendationDataCoverage ?? this.recommendationDataCoverage,
      recommendationFreshnessStatus:
          recommendationFreshnessStatus ?? this.recommendationFreshnessStatus,
      recommendationWarnings:
          recommendationWarnings ?? this.recommendationWarnings,
      recommendationSourceLabels:
          recommendationSourceLabels ?? this.recommendationSourceLabels,
      recommendationStabilityBand:
          recommendationStabilityBand ?? this.recommendationStabilityBand,
      recommendationReliabilityBand:
          recommendationReliabilityBand ?? this.recommendationReliabilityBand,
      recommendationScoreSeparationBand:
          recommendationScoreSeparationBand ??
          this.recommendationScoreSeparationBand,
      recommendationScenariosEvaluated:
          recommendationScenariosEvaluated ??
          this.recommendationScenariosEvaluated,
      isCityConfirmed: isCityConfirmed ?? this.isCityConfirmed,
    );
  }
}

const Object _migrationPlanNoChange = Object();
