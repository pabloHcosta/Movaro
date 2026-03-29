import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:movaro_app/core/storage/versioned_json_file_store.dart';

typedef CityFavoritesDirectoryProvider = Future<Directory> Function();

class CityFavoritesStore {
  CityFavoritesStore({CityFavoritesDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final CityFavoritesDirectoryProvider _directoryProvider;

  Future<List<String>> read() async {
    try {
      final file = await _file();
      final decoded = await VersionedJsonFileStore.read(file);
      if (decoded is! List) {
        return const [];
      }

      return decoded.whereType<String>().toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> write(List<String> cityIds) async {
    final file = await _file();
    await VersionedJsonFileStore.write(file, cityIds);
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_favorite_cities.json');
  }
}
