import 'package:movaro_app/features/cities/domain/entities/city.dart';

enum CityLifestyleKind { coastal, metropolis, border, inland }

class CityCoastalProfile {
  const CityCoastalProfile._();

  static const coastalCityIds = <String>{
    'florianopolis',
    'rio-de-janeiro',
    'armacao-dos-buzios',
    'arraial-do-cabo',
    'cabo-frio',
    'niteroi',
    'balneario-camboriu',
    'bombinhas',
    'maceio',
    'maragogi',
    'joao-pessoa',
    'recife',
    'natal',
    'aracaju',
    'salvador',
    'porto-seguro',
    'santos',
    'ubatuba',
    'paraty',
    'tibau-do-sul',
    'jijoca-de-jericoacoara',
    'ilhabela',
    'guaruja',
    'garopaba',
    'imbituba',
    'itacare',
    'sao-miguel-do-gostoso',
    'cairu',
    'itajai',
  };
  static const borderCityIds = <String>{'foz-do-iguacu'};
  static const metropolisCityIds = <String>{
    'sao-paulo',
    'rio-de-janeiro',
    'recife',
    'salvador',
  };

  static bool isCoastal(City city) => coastalCityIds.contains(_baseId(city.id));

  static CityLifestyleKind lifestyleKind(City city) {
    if (isCoastal(city)) {
      return CityLifestyleKind.coastal;
    }
    if (borderCityIds.contains(_baseId(city.id))) {
      return CityLifestyleKind.border;
    }
    if (metropolisCityIds.contains(_baseId(city.id)) || city.population >= 1000000) {
      return CityLifestyleKind.metropolis;
    }
    return CityLifestyleKind.inland;
  }

  static String _baseId(String id) {
    return id.replaceFirst(RegExp(r'-[a-z]{2}$'), '');
  }

  static List<City> rankCoastal(List<City> cities) {
    final coastal = cities.where(isCoastal).toList()
      ..sort((left, right) => score(right).compareTo(score(left)));
    return coastal;
  }

  static List<City> rankCoastalSoftLanding(List<City> cities) {
    final coastal = cities.where(isCoastal).toList()
      ..sort(
        (left, right) => softLandingScore(right).compareTo(
          softLandingScore(left),
        ),
      );
    return coastal;
  }

  static List<City> rankCoastalBalanced(List<City> cities) {
    final coastal = cities.where(isCoastal).toList()
      ..sort(
        (left, right) => balancedScore(right).compareTo(
          balancedScore(left),
        ),
      );
    return coastal;
  }

  static int score(City city) {
    return (city.safetyScore * 30) +
        (city.rentScore * 20) +
        (city.spanishSupportScore * 15) +
        (city.argentinaPopularityScore * 15) +
        (city.movaroScores.overall * 20);
  }

  static int softLandingScore(City city) {
    return (city.rentScore * 35) +
        (city.spanishSupportScore * 25) +
        (city.safetyScore * 20) +
        (city.argentinaPopularityScore * 10) +
        (city.movaroScores.overall * 10);
  }

  static int balancedScore(City city) {
    return (city.safetyScore * 30) +
        (city.rentScore * 20) +
        (city.jobMarketScore * 15) +
        (city.costOfLivingScore * 15) +
        (city.movaroScores.overall * 20);
  }
}
