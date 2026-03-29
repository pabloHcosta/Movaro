class MigrationStateSyncCoordinator {
  const MigrationStateSyncCoordinator._();

  static MigrationSyncScheduler? _scheduler;
  static int _suppressionDepth = 0;

  static void register(MigrationSyncScheduler scheduler) {
    _scheduler = scheduler;
  }

  static void scheduleSync() {
    if (_suppressionDepth > 0) {
      return;
    }
    _scheduler?.scheduleSync();
  }

  static Future<T> suspend<T>(Future<T> Function() action) async {
    _suppressionDepth += 1;
    try {
      return await action();
    } finally {
      _suppressionDepth -= 1;
    }
  }
}

abstract class MigrationSyncScheduler {
  void scheduleSync();
}
