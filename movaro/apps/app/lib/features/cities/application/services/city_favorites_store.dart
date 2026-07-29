import 'dart:io';

import 'package:movaro_app/core/storage/persistent_json_store.dart';
import 'package:path_provider/path_provider.dart';

typedef CityFavoritesDirectoryProvider = Future<Directory> Function();

class CityFavoritesStore {
  static const _storageKey = 'movaro_favorite_cities';

  CityFavoritesStore({CityFavoritesDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final CityFavoritesDirectoryProvider _directoryProvider;

  Future<List<String>> read() async {
    try {
      final decoded = await PersistentJsonStore.read(
        key: _storageKey,
        fileProvider: _file,
      );
      if (decoded is! List) {
        return const [];
      }

      return decoded.whereType<String>().toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> write(List<String> cityIds) async {
    await PersistentJsonStore.write(
      key: _storageKey,
      data: cityIds,
      fileProvider: _file,
    );
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_favorite_cities.json');
  }
}
