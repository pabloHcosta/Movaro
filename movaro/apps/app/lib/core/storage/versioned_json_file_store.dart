import 'dart:convert';
import 'dart:io';

class VersionedJsonFileStore {
  const VersionedJsonFileStore._();

  static const int currentSchemaVersion = 1;

  static Future<Object?> read(File file) async {
    final primary = await _readRaw(file);
    if (primary != null) {
      return _unwrap(primary);
    }

    final backup = await _readRaw(_backupFile(file));
    if (backup != null) {
      return _unwrap(backup);
    }

    return null;
  }

  static Future<void> write(
    File file,
    Object data, {
    int schemaVersion = currentSchemaVersion,
  }) async {
    await file.parent.create(recursive: true);

    if (file.existsSync()) {
      try {
        await file.copy(_backupFile(file).path);
      } catch (_) {}
    }

    final tempFile = File('${file.path}.tmp');
    await tempFile.parent.create(recursive: true);
    final payload = jsonEncode(<String, dynamic>{
      'schemaVersion': schemaVersion,
      'updatedAt': DateTime.now().toIso8601String(),
      'data': data,
    });

    await tempFile.writeAsString(payload, flush: true);

    if (file.existsSync()) {
      try {
        await file.delete();
      } catch (_) {}
    }
    try {
      await tempFile.rename(file.path);
    } on FileSystemException {
      await file.parent.create(recursive: true);
      if (tempFile.existsSync()) {
        await tempFile.copy(file.path);
      } else {
        // iOS simulator can fail rename after consuming the temp file.
        await file.writeAsString(payload, flush: true);
      }
      if (tempFile.existsSync()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  static Future<void> delete(File file) async {
    if (file.existsSync()) {
      try {
        await file.delete();
      } catch (_) {}
    }
    final backup = _backupFile(file);
    if (backup.existsSync()) {
      try {
        await backup.delete();
      } catch (_) {}
    }
  }

  static Future<Object?> _readRaw(File file) async {
    try {
      if (!file.existsSync()) {
        return null;
      }
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return null;
      }
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static Object? _unwrap(Object? value) {
    if (value is Map<String, dynamic> && value.containsKey('data')) {
      return value['data'];
    }
    return value;
  }

  static File _backupFile(File file) => File('${file.path}.bak');
}
