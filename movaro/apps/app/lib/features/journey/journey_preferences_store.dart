import 'dart:io';

import 'package:mudavi_app/core/storage/persistent_json_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mudavi_app/features/migration_questionnaire/application/services/migration_state_sync_coordinator.dart';

typedef JourneyDirectoryProvider = Future<Directory> Function();

class JourneyPreferencesStore {
  static const _storageKey = 'mudavi_journey_context';

  JourneyPreferencesStore({JourneyDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final JourneyDirectoryProvider _directoryProvider;

  Future<Map<String, dynamic>> read() async {
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

  Future<void> write(Map<String, dynamic> value) async {
    await PersistentJsonStore.write(
      key: _storageKey,
      data: value,
      fileProvider: _file,
    );
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<void> clear() async {
    await PersistentJsonStore.delete(key: _storageKey, fileProvider: _file);
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<bool> hasLocalData() async {
    final value = await read();
    return value.isNotEmpty;
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/mudavi_journey_context.json');
  }
}
