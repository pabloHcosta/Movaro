class DetectedLocation {
  const DetectedLocation({
    required this.countryName,
    this.countryId,
    this.city,
    this.region,
    this.latitude,
    this.longitude,
    this.detectedAt,
  });

  final String? countryId;
  final String countryName;
  final String? city;
  final String? region;
  final double? latitude;
  final double? longitude;
  final DateTime? detectedAt;

  bool get hasMatchedCountry => countryId != null;

  Map<String, dynamic> toJson() => {
    'countryId': countryId,
    'countryName': countryName,
    'city': city,
    'region': region,
    'latitude': latitude,
    'longitude': longitude,
    'detectedAt': detectedAt?.toIso8601String(),
  };

  factory DetectedLocation.fromJson(Map<String, dynamic> json) {
    return DetectedLocation(
      countryId: json['countryId'] as String?,
      countryName: json['countryName'] as String? ?? '',
      city: json['city'] as String?,
      region: json['region'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      detectedAt: json['detectedAt'] is String
          ? DateTime.tryParse(json['detectedAt'] as String)
          : null,
    );
  }
}

enum DetectedLocationRequestState {
  idle,
  requesting,
  available,
  denied,
  deniedForever,
  unavailable,
  failed,
}
