import 'package:movaro_app/features/cities/domain/entities/city_source.dart';

class CitySources {
  const CitySources({
    required this.territorialIdentity,
    required this.population,
    required this.humanDevelopment,
    this.employment,
    this.safety,
    required this.curatedMetrics,
    required this.ranking,
    this.publicReviews,
  });

  final CitySource territorialIdentity;
  final CitySource population;
  final CitySource humanDevelopment;
  final CitySource? employment;
  final CitySource? safety;
  final CitySource curatedMetrics;
  final CitySource ranking;
  final CitySource? publicReviews;

  List<CitySource> get all => [
    territorialIdentity,
    population,
    humanDevelopment,
    ?employment,
    ?safety,
    curatedMetrics,
    ranking,
    ?publicReviews,
  ];
}
