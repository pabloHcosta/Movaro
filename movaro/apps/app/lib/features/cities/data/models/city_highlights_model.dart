import 'package:movaro_app/features/cities/data/models/city_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city_highlights.dart';

class CityHighlightsModel {
  const CityHighlightsModel({
    required this.mostChosenByArgentinians,
    required this.easiestForSpanishSpeakers,
    required this.mostEconomical,
    required this.bestForWork,
  });

  factory CityHighlightsModel.fromJson(Map<String, dynamic> json) {
    return CityHighlightsModel(
      mostChosenByArgentinians:
          (json['mostChosenByArgentinians'] as List<dynamic>)
              .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
              .toList(),
      easiestForSpanishSpeakers:
          (json['easiestForSpanishSpeakers'] as List<dynamic>)
              .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
              .toList(),
      mostEconomical: (json['mostEconomical'] as List<dynamic>)
          .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      bestForWork: (json['bestForWork'] as List<dynamic>)
          .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<CityModel> mostChosenByArgentinians;
  final List<CityModel> easiestForSpanishSpeakers;
  final List<CityModel> mostEconomical;
  final List<CityModel> bestForWork;

  CityHighlights toEntity() => CityHighlights(
    mostChosenByArgentinians: mostChosenByArgentinians
        .map((item) => item.toEntity())
        .toList(),
    easiestForSpanishSpeakers: easiestForSpanishSpeakers
        .map((item) => item.toEntity())
        .toList(),
    mostEconomical: mostEconomical.map((item) => item.toEntity()).toList(),
    bestForWork: bestForWork.map((item) => item.toEntity()).toList(),
  );
}
