import 'package:movaro_app/features/cities/domain/entities/city.dart';

/// "Jobs lens" for the explore surface — primary ICP (economic migrant).
///
/// Ranks cities by work opportunity and lets the user narrow by **work area**
/// (industry), e.g. "Tecnologia", "Agroindustria", "Saude". Pure logic so it
/// can be unit-tested independently of the UI.
class CityWorkAreaLens {
  const CityWorkAreaLens._();

  /// Distinct work areas present in [cities], ordered by how many cities offer
  /// them (most common first), then alphabetically. Capped at [max].
  static List<String> availableAreas(List<City> cities, {int max = 12}) {
    final counts = <String, int>{};
    final display = <String, String>{};

    for (final city in cities) {
      for (final raw in city.topIndustries) {
        final label = raw.trim();
        if (label.isEmpty) {
          continue;
        }
        final key = _normalize(label);
        counts[key] = (counts[key] ?? 0) + 1;
        display.putIfAbsent(key, () => label);
      }
    }

    final keys = counts.keys.toList()
      ..sort((a, b) {
        final byCount = counts[b]!.compareTo(counts[a]!);
        if (byCount != 0) {
          return byCount;
        }
        return display[a]!.toLowerCase().compareTo(display[b]!.toLowerCase());
      });

    return keys.take(max).map((key) => display[key]!).toList();
  }

  /// Applies the jobs lens: optionally filters to cities offering [area]
  /// (accent/case-insensitive), then ranks by work opportunity. Ties break on
  /// job-market score, then affordability — favouring practical, work-viable
  /// cities for the economic-migrant profile.
  static List<City> applyWorkLens(List<City> cities, {String? area}) {
    final filtered = (area == null || area.trim().isEmpty)
        ? List<City>.from(cities)
        : cities.where((city) => offersArea(city, area)).toList();

    filtered.sort((a, b) {
      final byWork = b.movaroScores.workOpportunity.compareTo(
        a.movaroScores.workOpportunity,
      );
      if (byWork != 0) {
        return byWork;
      }
      final byJob = b.jobMarketScore.compareTo(a.jobMarketScore);
      if (byJob != 0) {
        return byJob;
      }
      return b.movaroScores.economical.compareTo(a.movaroScores.economical);
    });

    return filtered;
  }

  /// Whether [city] lists [area] among its top industries
  /// (accent/case-insensitive exact match on the normalized label).
  static bool offersArea(City city, String area) {
    final target = _normalize(area);
    if (target.isEmpty) {
      return false;
    }
    return city.topIndustries.any((raw) => _normalize(raw) == target);
  }

  static String _normalize(String value) {
    const accents = {
      'á': 'a', 'à': 'a', 'ã': 'a', 'â': 'a', 'ä': 'a',
      'é': 'e', 'ê': 'e', 'è': 'e', 'ë': 'e',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ô': 'o', 'õ': 'o', 'ò': 'o', 'ö': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
      'ç': 'c', 'ñ': 'n',
    };
    final lower = value.trim().toLowerCase();
    final buffer = StringBuffer();
    for (final ch in lower.split('')) {
      buffer.write(accents[ch] ?? ch);
    }
    return buffer.toString();
  }
}
