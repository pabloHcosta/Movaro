import 'dart:io';

import 'package:movaro_app/core/storage/persistent_json_store.dart';
import 'package:path_provider/path_provider.dart';

typedef FavoritesGuideDirectoryProvider = Future<Directory> Function();

class FavoritesGuidePreferencesStore {
  static const _storageKey = 'movaro_favorites_guide';

  FavoritesGuidePreferencesStore({
    FavoritesGuideDirectoryProvider? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final FavoritesGuideDirectoryProvider _directoryProvider;

  Future<void> markIntroSeen() async {
    final current = await _read();
    await _write(<String, dynamic>{...current, 'hasSeenIntro': true});
  }

  Future<bool> shouldShowGuide() async {
    final value = await _read();
    return value['hideGuide'] != true;
  }

  Future<void> setHideGuide(bool hideGuide) async {
    final current = await _read();
    await _write(<String, dynamic>{
      ...current,
      'hasSeenIntro': true,
      'hideGuide': hideGuide,
    });
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
    return File('${directory.path}/movaro_favorites_guide.json');
  }
}
