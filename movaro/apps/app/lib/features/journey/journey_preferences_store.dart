import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:movaro_app/core/storage/versioned_json_file_store.dart';
import 'package:movaro_app/features/migration_questionnaire/application/services/migration_state_sync_coordinator.dart';

typedef JourneyDirectoryProvider = Future<Directory> Function();

class JourneyPreferencesStore {
  JourneyPreferencesStore({JourneyDirectoryProvider? directoryProvider})
    : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final JourneyDirectoryProvider _directoryProvider;

  Future<Map<String, dynamic>> read() async {
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

  Future<void> write(Map<String, dynamic> value) async {
    final file = await _file();
    await VersionedJsonFileStore.write(file, value);
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<void> clear() async {
    final file = await _file();
    await VersionedJsonFileStore.delete(file);
    MigrationStateSyncCoordinator.scheduleSync();
  }

  Future<bool> hasLocalData() async {
    final value = await read();
    return value.isNotEmpty;
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_journey_context.json');
  }
}
