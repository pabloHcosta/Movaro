import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:movaro_app/features/location/argentina_locality.dart';

class ArgentinaLocalityCatalog {
  ArgentinaLocalityCatalog({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  static const assetPath = 'assets/seed/argentina_localities.json';

  final AssetBundle _bundle;
  List<ArgentinaLocality>? _cache;

  Future<List<ArgentinaLocality>> load() async {
    final cached = _cache;
    if (cached != null) {
      return cached;
    }

    final source = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(source) as Map<String, dynamic>;
    final records = decoded['localities'] as List<dynamic>? ?? const [];
    final localities =
        records
            .whereType<Map<String, dynamic>>()
            .map(ArgentinaLocality.fromJson)
            .where((locality) => locality.name.isNotEmpty)
            .toList(growable: false)
          ..sort((a, b) {
            final provinceOrder = a.province.compareTo(b.province);
            return provinceOrder != 0
                ? provinceOrder
                : a.name.compareTo(b.name);
          });

    _cache = localities;
    return localities;
  }

  List<ArgentinaLocality> search(
    List<ArgentinaLocality> localities,
    String query, {
    int limit = 80,
  }) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) {
      return localities.take(limit).toList(growable: false);
    }

    final matches = localities
        .where((locality) {
          return _normalize(
            '${locality.name} ${locality.province} ${locality.department}',
          ).contains(normalizedQuery);
        })
        .toList(growable: false);

    matches.sort((a, b) {
      final aName = _normalize(a.name);
      final bName = _normalize(b.name);
      final aStarts = aName.startsWith(normalizedQuery);
      final bStarts = bName.startsWith(normalizedQuery);
      if (aStarts != bStarts) {
        return aStarts ? -1 : 1;
      }
      return a.displayName.compareTo(b.displayName);
    });

    return matches.take(limit).toList(growable: false);
  }

  String _normalize(String value) {
    var normalized = value.trim().toLowerCase();
    const replacements = {
      'á': 'a',
      'à': 'a',
      'ä': 'a',
      'â': 'a',
      'é': 'e',
      'è': 'e',
      'ë': 'e',
      'ê': 'e',
      'í': 'i',
      'ì': 'i',
      'ï': 'i',
      'î': 'i',
      'ó': 'o',
      'ò': 'o',
      'ö': 'o',
      'ô': 'o',
      'ú': 'u',
      'ù': 'u',
      'ü': 'u',
      'û': 'u',
      'ñ': 'n',
    };
    for (final entry in replacements.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }
    return normalized;
  }
}
