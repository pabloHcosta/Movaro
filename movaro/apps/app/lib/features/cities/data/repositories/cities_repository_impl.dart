import 'package:movaro_app/features/cities/data/datasources/cities_remote_data_source.dart';
import 'package:movaro_app/features/cities/data/models/city_detail_payloads_model.dart';
import 'package:movaro_app/features/cities/data/models/city_highlights_model.dart';
import 'package:movaro_app/features/cities/data/models/city_methodology_model.dart';
import 'package:movaro_app/features/cities/data/models/city_model.dart';
import 'package:movaro_app/features/cities/data/models/city_recommendation_model.dart';
import 'package:movaro_app/features/cities/data/models/travel_route_insight_model.dart';
import 'package:movaro_app/features/cities/data/models/city_weather_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_recommendation.dart';
import 'package:movaro_app/features/cities/domain/entities/city_detail_payloads.dart';
import 'package:movaro_app/features/cities/domain/entities/city_highlights.dart';
import 'package:movaro_app/features/cities/domain/entities/city_methodology.dart';
import 'package:movaro_app/features/cities/domain/entities/travel_route_insight.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';

class CitiesRepositoryImpl implements CitiesRepository {
  const CitiesRepositoryImpl({required CitiesRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final CitiesRemoteDataSource _remoteDataSource;

  @override
  Future<CityRecommendationResult> recommendCities(
    CityRecommendationProfile profile,
  ) async {
    final response = await _remoteDataSource
        .postJsonMap('/api/v1/cities/recommendations', <String, dynamic>{
          'destinationCountryCode': profile.destinationCountryCode,
          'intent': profile.intent,
          'funding': profile.funding,
          'workArrangement': profile.workArrangement,
          'travelGroup': profile.travelGroup,
          if (profile.childrenCount != null)
            'childrenCount': profile.childrenCount,
          'availableCapital': profile.availableCapital,
          'priorities': profile.priorities,
          'constraints': profile.constraints,
          'supportNeeds': profile.supportNeeds,
          if (profile.originLatitude != null)
            'originLatitude': _roundedCoordinate(profile.originLatitude!),
          if (profile.originLongitude != null)
            'originLongitude': _roundedCoordinate(profile.originLongitude!),
        });
    return CityRecommendationModel.fromJson(response);
  }

  // City-level precision is sufficient for distance ordering and avoids
  // transmitting device-grade location precision to the recommendation API.
  static double _roundedCoordinate(double value) =>
      (value * 100).roundToDouble() / 100;

  @override
  Future<City> getCityById(String id) async {
    final response = await _remoteDataSource.getJsonMap('/api/v1/cities/$id');
    return CityModel.fromJson(response).toEntity();
  }

  @override
  Future<List<City>> getCities({
    String? category,
    String? search,
    String? countryCode,
  }) async {
    final query = <String, String>{};

    if (category != null && category.isNotEmpty) {
      query['category'] = category;
    }
    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }
    if (countryCode != null && countryCode.isNotEmpty) {
      query['countryCode'] = countryCode;
    }

    final path = query.isEmpty
        ? '/api/v1/cities'
        : '/api/v1/cities?${Uri(queryParameters: query).query}';
    final response = await _remoteDataSource.getJsonList(path);

    return response
        .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
        .map((item) => item.toEntity())
        .toList();
  }

  @override
  Future<CityHighlights> getHighlights() async {
    final response = await _remoteDataSource.getJsonMap(
      '/api/v1/cities/highlights',
    );
    return CityHighlightsModel.fromJson(response).toEntity();
  }

  @override
  Future<CityMethodology> getMethodology() async {
    final response = await _remoteDataSource.getJsonMap(
      '/api/v1/cities/metadata/methodology',
    );
    return CityMethodologyModel.fromJson(response).toEntity();
  }

  @override
  Future<CityWeather> getCityWeather(String cityId) async {
    final response = await _remoteDataSource.getJsonMap(
      '/api/v1/cities/$cityId/weather',
    );
    return CityWeatherModel.fromJson(response).toEntity();
  }

  @override
  Future<TravelRouteInsight?> getCityTravelInsight(
    String cityId, {
    String? originIata,
    String? destIata,
  }) async {
    final query = <String, String>{};
    if (originIata != null && originIata.isNotEmpty) {
      query['originIata'] = originIata;
    }
    if (destIata != null && destIata.isNotEmpty) {
      query['destIata'] = destIata;
    }
    final path = query.isEmpty
        ? '/api/v1/cities/$cityId/travel-insight'
        : '/api/v1/cities/$cityId/travel-insight?${Uri(queryParameters: query).query}';
    final response = await _remoteDataSource.getJsonMap(path);
    if (response.isEmpty) {
      return null;
    }
    return TravelRouteInsightModel.fromJson(response).toEntity();
  }

  @override
  Future<CityDetailSocialProof> getCityDetailSocialProof(
    String cityId, {
    String? locale,
    String? goal,
    String? timeline,
  }) async {
    final query = <String, String>{};
    if (locale != null && locale.isNotEmpty) query['locale'] = locale;
    if (goal != null && goal.isNotEmpty) query['goal'] = goal;
    if (timeline != null && timeline.isNotEmpty) query['timeline'] = timeline;
    final path = query.isEmpty
        ? '/api/v1/city-detail/$cityId/social-proof'
        : '/api/v1/city-detail/$cityId/social-proof?${Uri(queryParameters: query).query}';
    final response = await _remoteDataSource.getJsonMap(path);
    return CityDetailPayloadsModel.socialProofFromJson(response);
  }

  @override
  Future<CityDetailClimateSummary> getCityDetailClimateSummary(
    String cityId, {
    String? locale,
  }) async {
    final path = locale == null || locale.isEmpty
        ? '/api/v1/city-detail/$cityId/climate-summary'
        : '/api/v1/city-detail/$cityId/climate-summary?${Uri(queryParameters: {'locale': locale}).query}';
    final response = await _remoteDataSource.getJsonMap(path);
    return CityDetailPayloadsModel.climateSummaryFromJson(response);
  }

  @override
  Future<CityDetailArrivalStory> getCityDetailArrivalStory(
    String cityId, {
    String? locale,
    String? goal,
    String? timeline,
  }) async {
    final query = <String, String>{};
    if (locale != null && locale.isNotEmpty) query['locale'] = locale;
    if (goal != null && goal.isNotEmpty) query['goal'] = goal;
    if (timeline != null && timeline.isNotEmpty) query['timeline'] = timeline;
    final path = query.isEmpty
        ? '/api/v1/city-detail/$cityId/arrival-story'
        : '/api/v1/city-detail/$cityId/arrival-story?${Uri(queryParameters: query).query}';
    final response = await _remoteDataSource.getJsonMap(path);
    return CityDetailPayloadsModel.arrivalStoryFromJson(response);
  }

  @override
  Future<CityDetailComparison> getCityDetailComparison(
    String cityId, {
    required List<String> compareTo,
    String? locale,
  }) async {
    final query = <String, String>{
      'compareTo': compareTo.join(','),
      if (locale != null && locale.isNotEmpty) 'locale': locale,
    };
    final response = await _remoteDataSource.getJsonMap(
      '/api/v1/city-detail/$cityId/comparison?${Uri(queryParameters: query).query}',
    );
    return CityDetailPayloadsModel.comparisonFromJson(response);
  }

  @override
  Future<List<City>> searchCities(String query) async {
    final response = await _remoteDataSource.getJsonList(
      '/api/v1/cities/search?q=${Uri.encodeQueryComponent(query)}',
    );
    return response
        .map((item) => CityModel.fromJson(item as Map<String, dynamic>))
        .map((item) => item.toEntity())
        .toList();
  }
}
