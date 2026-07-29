import 'dart:io';

import 'package:movaro_app/core/storage/persistent_json_store.dart';
import 'package:path_provider/path_provider.dart';

typedef CitiesExploreDirectoryProvider = Future<Directory> Function();

class CitiesExplorePreferencesStore {
  static const _storageKey = 'movaro_cities_explore';

  CitiesExplorePreferencesStore({
    CitiesExploreDirectoryProvider? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final CitiesExploreDirectoryProvider _directoryProvider;

  Future<bool> shouldShowGuide() async {
    final value = await _read();
    return value['hideGuide'] != true;
  }

  Future<void> setHideGuide(bool hideGuide) async {
    await _write(<String, dynamic>{'hideGuide': hideGuide});
  }

  Future<Map<String, dynamic>> _read() async {
    try {
      final decoded = await PersistentJsonStore.read(
        key: _storageKey,
        fileProvider: _file,
      );
      return decoded is Map<String, dynamic>
          ? decoded
          : const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  Future<void> _write(Map<String, dynamic> value) async {
    await PersistentJsonStore.write(
      key: _storageKey,
      data: value,
      fileProvider: _file,
    );
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_cities_explore.json');
  }
}
