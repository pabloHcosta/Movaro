import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:movaro_app/core/storage/versioned_json_file_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef PersistentJsonFileProvider = Future<File> Function();

/// Stores the same JSON payload on every supported platform.
///
/// Mobile and desktop keep the existing versioned file behavior. Flutter web
/// uses local storage through SharedPreferences because `path_provider` and
/// `dart:io` files are not available in a browser.
class PersistentJsonStore {
  const PersistentJsonStore._();

  static Future<Object?> read({
    required String key,
    required PersistentJsonFileProvider fileProvider,
  }) async {
    if (kIsWeb) {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(key);
      if (raw == null || raw.trim().isEmpty) {
        return null;
      }
      try {
        return _unwrap(jsonDecode(raw));
      } catch (_) {
        return null;
      }
    }

    return VersionedJsonFileStore.read(await fileProvider());
  }

  static Future<void> write({
    required String key,
    required Object data,
    required PersistentJsonFileProvider fileProvider,
  }) async {
    if (kIsWeb) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        key,
        jsonEncode(<String, dynamic>{
          'schemaVersion': VersionedJsonFileStore.currentSchemaVersion,
          'updatedAt': DateTime.now().toIso8601String(),
          'data': data,
        }),
      );
      return;
    }

    await VersionedJsonFileStore.write(await fileProvider(), data);
  }

  static Future<void> delete({
    required String key,
    required PersistentJsonFileProvider fileProvider,
  }) async {
    if (kIsWeb) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(key);
      return;
    }

    await VersionedJsonFileStore.delete(await fileProvider());
  }

  static Object? _unwrap(Object? value) {
    if (value is Map<String, dynamic> && value.containsKey('data')) {
      return value['data'];
    }
    return value;
  }
}
