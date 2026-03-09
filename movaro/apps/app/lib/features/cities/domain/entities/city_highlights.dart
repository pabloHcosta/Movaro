import 'package:movaro_app/features/cities/domain/entities/city.dart';

class CityHighlights {
  const CityHighlights({
    required this.mostChosenByArgentinians,
    required this.easiestForSpanishSpeakers,
    required this.mostEconomical,
    required this.bestForWork,
  });

  final List<City> mostChosenByArgentinians;
  final List<City> easiestForSpanishSpeakers;
  final List<City> mostEconomical;
  final List<City> bestForWork;
}
