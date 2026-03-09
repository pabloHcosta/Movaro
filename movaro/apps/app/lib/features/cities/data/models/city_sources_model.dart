import 'package:movaro_app/features/cities/data/models/city_source_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city_sources.dart';

class CitySourcesModel {
  const CitySourcesModel({
    required this.territorialIdentity,
    required this.population,
    required this.humanDevelopment,
    required this.curatedMetrics,
    required this.ranking,
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
      curatedMetrics: CitySourceModel.fromJson(
        json['curatedMetrics'] as Map<String, dynamic>,
      ),
      ranking: CitySourceModel.fromJson(
        json['ranking'] as Map<String, dynamic>,
      ),
    );
  }

  final CitySourceModel territorialIdentity;
  final CitySourceModel population;
  final CitySourceModel humanDevelopment;
  final CitySourceModel curatedMetrics;
  final CitySourceModel ranking;

  factory CitySourcesModel.fromEntity(CitySources sources) {
    return CitySourcesModel(
      territorialIdentity: CitySourceModel.fromEntity(
        sources.territorialIdentity,
      ),
      population: CitySourceModel.fromEntity(sources.population),
      humanDevelopment: CitySourceModel.fromEntity(sources.humanDevelopment),
      curatedMetrics: CitySourceModel.fromEntity(sources.curatedMetrics),
      ranking: CitySourceModel.fromEntity(sources.ranking),
    );
  }

  Map<String, dynamic> toJson() => {
    'territorialIdentity': territorialIdentity.toJson(),
    'population': population.toJson(),
    'humanDevelopment': humanDevelopment.toJson(),
    'curatedMetrics': curatedMetrics.toJson(),
    'ranking': ranking.toJson(),
  };

  CitySources toEntity() => CitySources(
    territorialIdentity: territorialIdentity.toEntity(),
    population: population.toEntity(),
    humanDevelopment: humanDevelopment.toEntity(),
    curatedMetrics: curatedMetrics.toEntity(),
    ranking: ranking.toEntity(),
  );
}
