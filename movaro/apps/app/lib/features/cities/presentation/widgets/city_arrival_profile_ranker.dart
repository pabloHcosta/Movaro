import 'package:movaro_app/features/cities/domain/entities/city.dart';

enum CityArrivalProfile { softLanding, familyStability, incomeStart }

class CityArrivalProfileRanker {
  const CityArrivalProfileRanker._();

  static List<City> rank(
    List<City> cities, {
    required CityArrivalProfile profile,
  }) {
    final ranked = List<City>.from(cities)
      ..sort(
        (left, right) => score(
          right,
          profile: profile,
        ).compareTo(score(left, profile: profile)),
      );
    return ranked;
  }

  static int score(City city, {required CityArrivalProfile profile}) {
    switch (profile) {
      case CityArrivalProfile.softLanding:
        return (city.rentScore * 35) +
            (city.spanishSupportScore * 30) +
            (city.costOfLivingScore * 20) +
            (city.safetyScore * 15);
      case CityArrivalProfile.familyStability:
        return (city.safetyScore * 35) +
            (city.rentScore * 25) +
            (_idhmScore(city) * 25) +
            (city.spanishSupportScore * 15);
      case CityArrivalProfile.incomeStart:
        return (city.jobMarketScore * 40) +
            (city.economicActivityScore * 25) +
            (city.rentScore * 20) +
            (city.argentinaPopularityScore * 15);
    }
  }

  static int _idhmScore(City city) => (city.idhmScore * 100).round();
}
