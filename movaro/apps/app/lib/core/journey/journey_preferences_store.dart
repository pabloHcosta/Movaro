import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

typedef JourneyDirectoryProvider = Future<Directory> Function();

class JourneyPreferencesStore {
  JourneyPreferencesStore({
    JourneyDirectoryProvider? directoryProvider,
  }) : _directoryProvider =
           directoryProvider ?? getApplicationSupportDirectory;

  final JourneyDirectoryProvider _directoryProvider;

  Future<Map<String, dynamic>> read() async {
    try {
      final file = await _file();
      if (!file.existsSync()) {
        return const <String, dynamic>{};
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return const <String, dynamic>{};
      }

      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic>
          ? decoded
          : const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }

  Future<void> write(Map<String, dynamic> value) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(value));
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_journey_context.json');
  }
}
