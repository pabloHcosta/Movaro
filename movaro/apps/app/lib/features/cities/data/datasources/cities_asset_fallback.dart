import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Offline-first fallback that serves the city catalog from a snapshot bundled
/// with the app, so the core experience (explore, city lookup, search,
/// methodology) works with **zero backend** — even on a brand-new install with
/// no network and no persistent cache yet.
///
/// The snapshots are exact, enriched `/api/v1/cities*` responses captured from
/// the API, so they parse with the same `CityModel.fromJson` the live path
/// uses. This is consulted only after the network and the persistent cache
/// both miss; it never overrides fresh data.
class CitiesAssetFallback {
  CitiesAssetFallback();

  static const _citiesAsset = 'assets/seed/snapshots/cities_br.json';
  static const _highlightsAsset =
      'assets/seed/snapshots/cities_highlights.json';
  static const _methodologyAsset =
      'assets/seed/snapshots/cities_methodology.json';

  List<dynamic>? _cities;
  Map<String, dynamic>? _highlights;
  Map<String, dynamic>? _methodology;
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) {
      return;
    }
    _cities = await _loadList(_citiesAsset);
    _highlights = await _loadMap(_highlightsAsset);
    _methodology = await _loadMap(_methodologyAsset);
    _loaded = true;
  }

  Future<List<dynamic>?> _loadList(String asset) async {
    try {
      final decoded = jsonDecode(await rootBundle.loadString(asset));
      return decoded is List<dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _loadMap(String asset) async {
    try {
      final decoded = jsonDecode(await rootBundle.loadString(asset));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// Resolves a request [path] (e.g. `/api/v1/cities?countryCode=BR`) against
  /// the bundled snapshot. Returns a `List`/`Map` matching what the live
  /// endpoint would return, or `null` when there is no offline equivalent
  /// (e.g. weather, travel insight, AI chat — features that require the API).
  Future<Object?> resolve(String path) async {
    await _ensureLoaded();

    final Uri uri;
    try {
      uri = Uri.parse(path);
    } catch (_) {
      return null;
    }

    final segments = uri.pathSegments;
    // Only the cities catalog is mirrored offline: /api/v1/cities*
    final citiesIndex = segments.indexOf('cities');
    if (citiesIndex == -1) {
      return null;
    }

    final tail = segments.sublist(citiesIndex + 1);

    // /api/v1/cities  -> full catalog list
    if (tail.isEmpty) {
      return _cities;
    }

    // /api/v1/cities/highlights
    if (tail.length == 1 && tail[0] == 'highlights') {
      return _highlights;
    }

    // /api/v1/cities/metadata/methodology
    if (tail.length == 2 && tail[0] == 'metadata' && tail[1] == 'methodology') {
      return _methodology;
    }

    // /api/v1/cities/search?q=...
    if (tail.length == 1 && tail[0] == 'search') {
      final query = (uri.queryParameters['q'] ?? '').trim().toLowerCase();
      final cities = _cities;
      if (cities == null) {
        return null;
      }
      if (query.isEmpty) {
        return cities;
      }
      return cities.where((city) {
        if (city is! Map<String, dynamic>) {
          return false;
        }
        final name = (city['name'] as String? ?? '').toLowerCase();
        final stateName = (city['stateName'] as String? ?? '').toLowerCase();
        return name.contains(query) || stateName.contains(query);
      }).toList();
    }

    // /api/v1/cities/{id}  -> single city resolved from the bundled list.
    // (Deeper detail paths like /cities/{id}/weather have no offline mirror.)
    if (tail.length == 1) {
      final id = tail[0];
      final cities = _cities;
      if (cities == null) {
        return null;
      }
      for (final city in cities) {
        if (city is Map<String, dynamic> && city['id'] == id) {
          return city;
        }
      }
    }

    return null;
  }
}
