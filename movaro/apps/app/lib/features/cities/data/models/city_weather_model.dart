import 'package:movaro_app/features/cities/domain/entities/city_weather.dart';

class CityWeatherModel {
  const CityWeatherModel({
    required this.temperatureCelsius,
    required this.weatherCode,
    required this.isDay,
    required this.windSpeedKmh,
    required this.fetchedAt,
  });

  factory CityWeatherModel.fromJson(Map<String, dynamic> json) {
    return CityWeatherModel(
      temperatureCelsius: (json['temperatureCelsius'] as num).toDouble(),
      weatherCode: json['weatherCode'] as int?,
      isDay: json['isDay'] as bool?,
      windSpeedKmh: (json['windSpeedKmh'] as num?)?.toDouble(),
      fetchedAt: json['fetchedAt'] as String,
    );
  }

  final double temperatureCelsius;
  final int? weatherCode;
  final bool? isDay;
  final double? windSpeedKmh;
  final String fetchedAt;

  CityWeather toEntity() => CityWeather(
    temperatureCelsius: temperatureCelsius,
    weatherCode: weatherCode,
    isDay: isDay,
    windSpeedKmh: windSpeedKmh,
    fetchedAt: fetchedAt,
  );
}
