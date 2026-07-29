import 'package:movaro_app/features/cities/domain/entities/city.dart';
import 'package:movaro_app/features/cities/domain/entities/city_recommendation.dart';
import 'package:movaro_app/features/cities/domain/entities/city_detail_payloads.dart';
import 'package:movaro_app/features/cities/domain/entities/city_highlights.dart';
import 'package:movaro_app/features/cities/domain/entities/city_methodology.dart';
import 'package:movaro_app/features/cities/domain/entities/travel_route_insight.dart';
import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';

abstract class CitiesRepository {
  Future<CityRecommendationResult> recommendCities(
    CityRecommendationProfile profile,
  );

  Future<CityHighlights> getHighlights();

  Future<List<City>> getCities({
    String? category,
    String? search,
    String? countryCode,
  });

  Future<List<City>> searchCities(String query);

  Future<City> getCityById(String id);

  Future<CityMethodology> getMethodology();

  Future<CityWeather> getCityWeather(String cityId);

  Future<TravelRouteInsight?> getCityTravelInsight(
    String cityId, {
    String? originIata,
    String? destIata,
  });

  Future<CityDetailSocialProof> getCityDetailSocialProof(
    String cityId, {
    String? locale,
    String? goal,
    String? timeline,
  });

  Future<CityDetailClimateSummary> getCityDetailClimateSummary(
    String cityId, {
    String? locale,
  });

  Future<CityDetailArrivalStory> getCityDetailArrivalStory(
    String cityId, {
    String? locale,
    String? goal,
    String? timeline,
  });

  Future<CityDetailComparison> getCityDetailComparison(
    String cityId, {
    required List<String> compareTo,
    String? locale,
  });
}
