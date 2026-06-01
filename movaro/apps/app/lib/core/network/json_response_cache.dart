import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the last successful JSON payload per request path so read-only
/// data can survive transient API or connectivity failures.
///
/// This cache is used strictly as a *fallback*: callers always hit the network
/// first and only fall back to a stored payload when the network is
/// unreachable. That keeps the data fresh when online while preventing a
/// temporary backend outage from emptying core surfaces (city catalog,
/// explore, city detail) for users who have already loaded them once.
class JsonResponseCache {
  JsonResponseCache({String namespace = 'movaro.json_cache'})
    : _namespace = namespace;

  final String _namespace;
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  String _key(String path) => '$_namespace::$path';

  /// Stores [json] (any JSON-encodable value) for [path]. Best-effort: a cache
  /// write must never break the request that triggered it.
  Future<void> write(String path, Object? json) async {
    try {
      final prefs = await _instance;
      await prefs.setString(_key(path), jsonEncode(json));
    } catch (_) {
      // Intentionally ignored: caching is an optimization, not a guarantee.
    }
  }

  /// Returns the last stored payload for [path], or `null` if absent/corrupt.
  Future<Object?> read(String path) async {
    try {
      final prefs = await _instance;
      final raw = prefs.getString(_key(path));
      if (raw == null || raw.isEmpty) {
        return null;
      }
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }
}
