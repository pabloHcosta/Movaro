/// Represents a commercial airport that can be used as a flight origin or
/// destination within the Movaro flight-search tool.
class Airport {
  const Airport({
    required this.iataCode,
    required this.name,
    required this.city,
    required this.countryIso,
    required this.region,
    required this.latitude,
    required this.longitude,
    this.isMainHub = false,
  });

  /// Three-letter IATA airport code (e.g. 'EZE', 'GRU').
  final String iataCode;

  /// Official airport name (e.g. 'Ministro Pistarini').
  final String name;

  /// City the airport serves (e.g. 'Buenos Aires').
  final String city;

  /// ISO 3166-1 alpha-2 country code (e.g. 'AR', 'BR').
  final String countryIso;

  /// State / province the airport is in (e.g. 'Santa Catarina').
  final String region;

  final double latitude;
  final double longitude;

  /// True for the primary international hubs of each country.
  final bool isMainHub;

  /// Display label shown on selection chips: "EZE · Buenos Aires".
  String get chipLabel => '$iataCode · $city';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Airport &&
          runtimeType == other.runtimeType &&
          iataCode == other.iataCode;

  @override
  int get hashCode => iataCode.hashCode;

  @override
  String toString() => 'Airport($iataCode, $city)';
}
