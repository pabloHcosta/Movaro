class CitySource {
  const CitySource({
    required this.id,
    required this.title,
    required this.provider,
    required this.description,
    required this.isOfficial,
    required this.url,
  });

  final String id;
  final String title;
  final String provider;
  final String description;
  final bool isOfficial;
  final String? url;
}
