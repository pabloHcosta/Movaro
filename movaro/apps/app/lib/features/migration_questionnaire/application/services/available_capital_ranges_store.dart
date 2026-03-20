import 'dart:convert';

import 'package:flutter/services.dart';

class AvailableCapitalRangeSet {
  const AvailableCapitalRangeSet({
    required this.currencyCode,
    required this.locale,
    required this.bands,
  });

  final String currencyCode;
  final String locale;
  final List<num> bands;

  factory AvailableCapitalRangeSet.fromJson(Map<String, dynamic> json) {
    return AvailableCapitalRangeSet(
      currencyCode: json['currencyCode'] as String,
      locale: json['locale'] as String,
      bands: (json['bands'] as List<dynamic>).whereType<num>().toList(
        growable: false,
      ),
    );
  }
}

class AvailableCapitalRangesStore {
  AvailableCapitalRangesStore._();

  static const assetPath = 'assets/seed/available_capital_ranges.json';
  static Map<String, AvailableCapitalRangeSet>? _cache;

  static Future<void> load() async {
    if (_cache != null) {
      return;
    }

    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _cache = decoded.map(
      (key, value) => MapEntry(
        key,
        AvailableCapitalRangeSet.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  static AvailableCapitalRangeSet rangesForOrigin(String? originCountry) {
    final cache = _cache;
    if (cache == null) {
      return _fallbackRanges;
    }

    final normalized = _normalizeOrigin(originCountry);
    return cache[normalized] ?? cache['default'] ?? _fallbackRanges;
  }

  static String _normalizeOrigin(String? originCountry) {
    switch (originCountry?.toLowerCase().trim()) {
      case 'argentina':
        return 'argentina';
      case 'chile':
        return 'chile';
      case 'uruguai':
      case 'uruguay':
        return 'uruguai';
      case 'brasil':
      case 'brazil':
        return 'brasil';
      default:
        return 'default';
    }
  }

  static const AvailableCapitalRangeSet _fallbackRanges =
      AvailableCapitalRangeSet(
        currencyCode: 'USD',
        locale: 'en_US',
        bands: [500, 2000, 5000],
      );
}
