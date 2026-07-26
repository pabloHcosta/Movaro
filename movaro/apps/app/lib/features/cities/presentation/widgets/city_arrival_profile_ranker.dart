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
        return _weighted([
          (city.rentScore, 35, true),
          (city.spanishSupportScore, 30, true),
          (city.costOfLivingScore, 20, true),
          (city.safetyScore, 15, city.sources.safety != null),
        ]);
      case CityArrivalProfile.familyStability:
        return _weighted([
          (city.safetyScore, 35, city.sources.safety != null),
          (city.rentScore, 25, true),
          (_idhmScore(city), 25, true),
          (city.spanishSupportScore, 15, true),
        ]);
      case CityArrivalProfile.incomeStart:
        return _weighted([
          (city.jobMarketScore, 40, city.sources.employment != null),
          (city.economicActivityScore, 25, city.sources.employment != null),
          (city.rentScore, 20, true),
          (city.argentinaPopularityScore, 15, true),
        ]);
    }
  }

  static int _idhmScore(City city) => (city.idhmScore * 100).round();

  static int _weighted(List<(int, int, bool)> signals) {
    var weightedScore = 0;
    var includedWeight = 0;
    for (final (value, weight, hasSource) in signals) {
      if (!hasSource) continue;
      weightedScore += value * weight;
      includedWeight += weight;
    }
    return includedWeight == 0
        ? 0
        : (weightedScore * 100 / includedWeight).round();
  }
}
