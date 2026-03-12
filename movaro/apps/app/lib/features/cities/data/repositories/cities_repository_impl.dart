import 'package:movaro_app/features/cities/data/datasources/cities_remote_data_source.dart';
import 'package:movaro_app/features/cities/data/models/city_highlights_model.dart';
import 'package:movaro_app/features/cities/data/models/city_methodology_model.dart';
import 'package:movaro_app/features/cities/data/models/city_model.dart';
import 'package:movaro_app/features/cities/data/models/city_weather_model.dart';
import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_highlights.dart';
import 'package:movaro_app/features/cities/domain/entities/city_methodology.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';
import 'package:movaro_app/features/cities/domain/repositories/cities_repository.dart';

class CitiesRepositoryImpl implements CitiesRepository {
  const CitiesRepositoryImpl({required CitiesRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final CitiesRemoteDataSource _remoteDataSource;

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
