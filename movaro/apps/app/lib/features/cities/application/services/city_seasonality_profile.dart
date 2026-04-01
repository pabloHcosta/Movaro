export 'package:movaro_app/features/cities/domain/entities/city_seasonality_snapshot.dart'
    show CitySeasonalitySnapshot, CitySeasonalitySeverity;

import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_seasonality_snapshot.dart';

typedef CitySeasonalityData = CitySeasonalitySnapshot;

class CitySeasonalityProfile {
  const CitySeasonalityProfile._();

  static CitySeasonalitySnapshot? of(City city) => city.seasonalitySnapshot;

  static bool hasSeason(City city) => city.seasonalitySnapshot != null;
}
