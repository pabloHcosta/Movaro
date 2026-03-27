import 'package:movaro_app/features/city_insights/domain/entities/city_insight_entity.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_explore_place_entity.dart';

abstract class CityInsightRepository {
  Future<List<CityInsightEntity>> getCityInsights({
    required String cityId,
    String? goal,
    String? timeline,
    String locale = 'pt',
    bool forceRefresh = false,
  });

  Future<List<CityInsightExplorePlaceEntity>> getExplorePlaces({
    required String cityId,
    required CityInsightTheme theme,
    String locale = 'pt',
    String? seedPlace,
    bool forceRefresh = false,
  });
}
