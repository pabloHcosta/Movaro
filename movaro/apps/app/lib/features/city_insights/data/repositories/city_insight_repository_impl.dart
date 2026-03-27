import 'package:movaro_app/features/city_insights/application/services/city_insights_cache_store.dart';
import 'package:movaro_app/features/city_insights/data/datasources/city_insights_remote_data_source.dart';
import 'package:movaro_app/features/city_insights/data/models/city_insight_explore_place_model.dart';
import 'package:movaro_app/features/city_insights/data/models/city_insight_model.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_entity.dart';
import 'package:movaro_app/features/city_insights/domain/entities/city_insight_explore_place_entity.dart';
import 'package:movaro_app/features/city_insights/domain/repositories/city_insight_repository.dart';

class CityInsightRepositoryImpl implements CityInsightRepository {
  CityInsightRepositoryImpl({
    required CityInsightsRemoteDataSource remoteDataSource,
    CityInsightsCacheStore? cacheStore,
  }) : _remoteDataSource = remoteDataSource,
       _cacheStore = cacheStore ?? CityInsightsCacheStore();

  final CityInsightsRemoteDataSource _remoteDataSource;
  final CityInsightsCacheStore _cacheStore;

  @override
  Future<List<CityInsightEntity>> getCityInsights({
    required String cityId,
    String? goal,
    String? timeline,
    String locale = 'pt',
    bool forceRefresh = false,
  }) async {
    final cacheKey = _buildCacheKey(
      cityId: cityId,
      goal: goal,
      timeline: timeline,
      locale: locale,
    );

    if (!forceRefresh) {
      final cached = await _cacheStore.readFresh(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached.map((item) => item.toEntity()).toList(growable: false);
      }
    }

    try {
      final query = <String, String>{'cityId': cityId, 'locale': locale};
      if (goal != null && goal.isNotEmpty) {
        query['goal'] = goal;
      }
      if (timeline != null && timeline.isNotEmpty) {
        query['timeline'] = timeline;
      }

      final response = await _remoteDataSource.getJsonList(
        '/api/v1/city-insights?${Uri(queryParameters: query).query}',
      );
      final models = response
          .map(
            (item) => CityInsightModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false);
      await _cacheStore.write(cacheKey, models);
      return models.map((item) => item.toEntity()).toList(growable: false);
    } catch (_) {
      final stale = await _cacheStore.readAny(cacheKey);
      if (stale != null && stale.isNotEmpty) {
        return stale.map((item) => item.toEntity()).toList(growable: false);
      }
      rethrow;
    }
  }

  String _buildCacheKey({
    required String cityId,
    String? goal,
    String? timeline,
    required String locale,
  }) {
    return [
      cityId,
      goal ?? 'none',
      timeline ?? 'none',
      locale,
    ].join('::').toLowerCase();
  }

  @override
  Future<List<CityInsightExplorePlaceEntity>> getExplorePlaces({
    required String cityId,
    required CityInsightTheme theme,
    String locale = 'pt',
    String? seedPlace,
    bool forceRefresh = false,
  }) async {
    final cacheKey = [
      'v2',
      cityId,
      _themeToWire(theme),
      seedPlace ?? 'none',
      locale,
    ].join('::').toLowerCase();

    if (!forceRefresh) {
      final cached = await _cacheStore.readExploreFresh(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached.map((item) => item.toEntity()).toList(growable: false);
      }
    }

    try {
      final query = <String, String>{
        'cityId': cityId,
        'theme': _themeToWire(theme),
        'locale': locale,
      };
      if (seedPlace != null && seedPlace.isNotEmpty) {
        query['seedPlace'] = seedPlace;
      }

      final response = await _remoteDataSource.getJsonList(
        '/api/v1/city-insights/explore?${Uri(queryParameters: query).query}',
      );
      final models = response
          .map(
            (item) => CityInsightExplorePlaceModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false);
      await _cacheStore.writeExplore(cacheKey, models);
      return models.map((item) => item.toEntity()).toList(growable: false);
    } catch (_) {
      final stale = await _cacheStore.readExploreAny(cacheKey);
      if (stale != null && stale.isNotEmpty) {
        return stale.map((item) => item.toEntity()).toList(growable: false);
      }
      rethrow;
    }
  }
}

String _themeToWire(CityInsightTheme value) {
  switch (value) {
    case CityInsightTheme.neighborhoods:
      return 'neighborhoods';
    case CityInsightTheme.beaches:
      return 'beaches';
    case CityInsightTheme.parks:
      return 'parks';
    case CityInsightTheme.nightlife:
      return 'nightlife';
    case CityInsightTheme.foodAndCafes:
      return 'food_and_cafes';
    case CityInsightTheme.cultureAndEvents:
      return 'culture_and_events';
    case CityInsightTheme.viewpoints:
      return 'viewpoints';
    case CityInsightTheme.localRoutine:
      return 'local_routine';
  }
}
