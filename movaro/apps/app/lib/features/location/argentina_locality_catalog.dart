import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:movaro_app/features/location/argentina_locality.dart';

class ArgentinaLocalityCatalog {
  ArgentinaLocalityCatalog({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  static const assetPath = 'assets/seed/argentina_localities.json';
  static const _cabaProvince = 'Ciudad Autónoma de Buenos Aires';

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
            .toList()
          ..addAll(_jurisdictionAliases(records))
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
          return _searchableText(locality).contains(normalizedQuery);
        })
        .toList(growable: false);

    matches.sort((a, b) {
      final aName = _normalize(a.name);
      final bName = _normalize(b.name);
      final aExact = aName == normalizedQuery;
      final bExact = bName == normalizedQuery;
      if (aExact != bExact) {
        return aExact ? -1 : 1;
      }
      final aStarts = aName.startsWith(normalizedQuery);
      final bStarts = bName.startsWith(normalizedQuery);
      if (aStarts != bStarts) {
        return aStarts ? -1 : 1;
      }
      return a.displayName.compareTo(b.displayName);
    });

    return matches.take(limit).toList(growable: false);
  }

  List<ArgentinaLocality> _jurisdictionAliases(List<dynamic> records) {
    final caba = records
        .whereType<Map<String, dynamic>>()
        .map(ArgentinaLocality.fromJson)
        .where((item) => item.province == _cabaProvince)
        .toList(growable: false);
    if (caba.isEmpty ||
        caba.any((item) => _normalize(item.name) == 'buenos aires')) {
      return const [];
    }

    final latitude =
        caba.fold<double>(0, (sum, item) => sum + item.latitude) / caba.length;
    final longitude =
        caba.fold<double>(0, (sum, item) => sum + item.longitude) / caba.length;
    return [
      ArgentinaLocality(
        id: '02-caba',
        name: 'Buenos Aires',
        provinceId: caba.first.provinceId,
        province: _cabaProvince,
        department: 'Capital',
        latitude: latitude,
        longitude: longitude,
      ),
    ];
  }

  String _searchableText(ArgentinaLocality locality) {
    final aliases = locality.province == _cabaProvince ? ' caba capital' : '';
    return _normalize(
      '${locality.name} ${locality.province} ${locality.department}$aliases',
    );
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
