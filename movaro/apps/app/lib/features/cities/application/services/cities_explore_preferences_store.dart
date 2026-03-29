import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:movaro_app/core/storage/versioned_json_file_store.dart';

typedef CitiesExploreDirectoryProvider = Future<Directory> Function();

class CitiesExplorePreferencesStore {
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
      final file = await _file();
      final decoded = await VersionedJsonFileStore.read(file);
      return decoded is Map<String, dynamic>
          ? decoded
          : const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  Future<void> _write(Map<String, dynamic> value) async {
    final file = await _file();
    await VersionedJsonFileStore.write(file, value);
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_cities_explore.json');
  }
}
