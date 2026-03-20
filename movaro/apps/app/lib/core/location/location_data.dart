class LocationData {
  const LocationData({
    required this.cityName,
    required this.stateName,
    required this.countryName,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
  });

  final String cityName;
  final String stateName;
  final String countryName;
  final String countryCode;
  final double latitude;
  final double longitude;

  Map<String, dynamic> toJson() => {
    'cityName': cityName,
    'stateName': stateName,
    'countryName': countryName,
    'countryCode': countryCode,
    'latitude': latitude,
    'longitude': longitude,
  };

  factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
    cityName: json['cityName'] as String? ?? '',
    stateName: json['stateName'] as String? ?? '',
    countryName: json['countryName'] as String? ?? '',
    countryCode: json['countryCode'] as String? ?? '',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
  );
}
