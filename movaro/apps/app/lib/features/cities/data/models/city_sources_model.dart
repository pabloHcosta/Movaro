import 'package:movaro_app/features/cities/data/models/city_source_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city_sources.dart';

class CitySourcesModel {
  const CitySourcesModel({
    required this.territorialIdentity,
    required this.population,
    required this.humanDevelopment,
    this.employment,
    this.safety,
    required this.curatedMetrics,
    required this.ranking,
    this.publicReviews,
  });

  factory CitySourcesModel.fromJson(Map<String, dynamic> json) {
    return CitySourcesModel(
      territorialIdentity: CitySourceModel.fromJson(
        json['territorialIdentity'] as Map<String, dynamic>,
      ),
      population: CitySourceModel.fromJson(
        json['population'] as Map<String, dynamic>,
      ),
      humanDevelopment: CitySourceModel.fromJson(
        json['humanDevelopment'] as Map<String, dynamic>,
      ),
      employment: json['employment'] == null
          ? null
          : CitySourceModel.fromJson(
              json['employment'] as Map<String, dynamic>,
            ),
      safety: json['safety'] == null
          ? null
          : CitySourceModel.fromJson(json['safety'] as Map<String, dynamic>),
      curatedMetrics: CitySourceModel.fromJson(
        json['curatedMetrics'] as Map<String, dynamic>,
      ),
      ranking: CitySourceModel.fromJson(
        json['ranking'] as Map<String, dynamic>,
      ),
      publicReviews: json['publicReviews'] == null
          ? null
          : CitySourceModel.fromJson(
              json['publicReviews'] as Map<String, dynamic>,
            ),
    );
  }

  final CitySourceModel territorialIdentity;
  final CitySourceModel population;
  final CitySourceModel humanDevelopment;
  final CitySourceModel? employment;
  final CitySourceModel? safety;
  final CitySourceModel curatedMetrics;
  final CitySourceModel ranking;
  final CitySourceModel? publicReviews;

  factory CitySourcesModel.fromEntity(CitySources sources) {
    return CitySourcesModel(
      territorialIdentity: CitySourceModel.fromEntity(
        sources.territorialIdentity,
      ),
      population: CitySourceModel.fromEntity(sources.population),
      humanDevelopment: CitySourceModel.fromEntity(sources.humanDevelopment),
      employment: sources.employment == null
          ? null
          : CitySourceModel.fromEntity(sources.employment!),
      safety: sources.safety == null
          ? null
          : CitySourceModel.fromEntity(sources.safety!),
      curatedMetrics: CitySourceModel.fromEntity(sources.curatedMetrics),
      ranking: CitySourceModel.fromEntity(sources.ranking),
      publicReviews: sources.publicReviews == null
          ? null
          : CitySourceModel.fromEntity(sources.publicReviews!),
    );
  }

  Map<String, dynamic> toJson() => {
    'territorialIdentity': territorialIdentity.toJson(),
    'population': population.toJson(),
    'humanDevelopment': humanDevelopment.toJson(),
    'employment': employment?.toJson(),
    'safety': safety?.toJson(),
    'curatedMetrics': curatedMetrics.toJson(),
    'ranking': ranking.toJson(),
    'publicReviews': publicReviews?.toJson(),
  };

  CitySources toEntity() => CitySources(
    territorialIdentity: territorialIdentity.toEntity(),
    population: population.toEntity(),
    humanDevelopment: humanDevelopment.toEntity(),
    employment: employment?.toEntity(),
    safety: safety?.toEntity(),
    curatedMetrics: curatedMetrics.toEntity(),
    ranking: ranking.toEntity(),
    publicReviews: publicReviews?.toEntity(),
  );
}
