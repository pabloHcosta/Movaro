class CitySource {
  const CitySource({
    required this.id,
    required this.title,
    required this.provider,
    required this.description,
    required this.isOfficial,
    required this.url,
    required this.sourceType,
  });

  final String id;
  final String title;
  final String provider;
  final String description;
  final bool isOfficial;
  final String? url;
  final String sourceType;
}
