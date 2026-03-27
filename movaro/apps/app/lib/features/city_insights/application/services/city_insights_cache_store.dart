import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:movaro_app/features/city_insights/data/models/city_insight_explore_place_model.dart';
import 'package:movaro_app/features/city_insights/data/models/city_insight_model.dart';

class CityInsightsCacheStore {
  CityInsightsCacheStore();

  static const _prefix = 'movaro.city_insights.';
  static const _ttl = Duration(hours: 12);

  Future<List<CityInsightModel>?> readFresh(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final savedAtRaw = decoded['savedAt'] as String?;
      final savedAt = savedAtRaw == null ? null : DateTime.tryParse(savedAtRaw);
      if (savedAt == null || DateTime.now().difference(savedAt) > _ttl) {
        return null;
      }

      final items = decoded['items'];
      if (items is! List) {
        return null;
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(CityInsightModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<List<CityInsightModel>?> readAny(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final items = decoded['items'];
      if (items is! List) {
        return null;
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(CityInsightModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> write(String key, List<CityInsightModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'savedAt': DateTime.now().toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(growable: false),
    });
    await prefs.setString('$_prefix$key', payload);
  }

  Future<List<CityInsightExplorePlaceModel>?> readExploreFresh(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix.explore.$key');
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final savedAtRaw = decoded['savedAt'] as String?;
      final savedAt = savedAtRaw == null ? null : DateTime.tryParse(savedAtRaw);
      if (savedAt == null || DateTime.now().difference(savedAt) > _ttl) {
        return null;
      }

      final items = decoded['items'];
      if (items is! List) {
        return null;
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(CityInsightExplorePlaceModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<List<CityInsightExplorePlaceModel>?> readExploreAny(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix.explore.$key');
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final items = decoded['items'];
      if (items is! List) {
        return null;
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(CityInsightExplorePlaceModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeExplore(
    String key,
    List<CityInsightExplorePlaceModel> items,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'savedAt': DateTime.now().toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(growable: false),
    });
    await prefs.setString('$_prefix.explore.$key', payload);
  }
}
