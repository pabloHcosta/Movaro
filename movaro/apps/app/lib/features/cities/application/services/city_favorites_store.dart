import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

typedef CityFavoritesDirectoryProvider = Future<Directory> Function();

class CityFavoritesStore {
  CityFavoritesStore({CityFavoritesDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final CityFavoritesDirectoryProvider _directoryProvider;

  Future<List<String>> read() async {
    try {
      final file = await _file();
      if (!file.existsSync()) {
        return const [];
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(raw);
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
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(cityIds));
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_favorite_cities.json');
  }
}
