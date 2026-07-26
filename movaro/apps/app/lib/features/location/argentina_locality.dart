class ArgentinaLocality {
  const ArgentinaLocality({
    required this.id,
    required this.name,
    required this.provinceId,
    required this.province,
    required this.department,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String provinceId;
  final String province;
  final String department;
  final double latitude;
  final double longitude;

  String get displayName => '$name, $province';

  factory ArgentinaLocality.fromJson(Map<String, dynamic> json) {
    return ArgentinaLocality(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      provinceId: json['provinceId'] as String? ?? '',
      province: json['province'] as String? ?? '',
      department: json['department'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}
