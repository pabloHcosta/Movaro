class CityWeather {
  const CityWeather({
    required this.temperatureCelsius,
    required this.weatherCode,
    required this.isDay,
    required this.windSpeedKmh,
    required this.fetchedAt,
  });

  final double temperatureCelsius;
  final int? weatherCode;
  final bool? isDay;
  final double? windSpeedKmh;
  final String fetchedAt;
}
