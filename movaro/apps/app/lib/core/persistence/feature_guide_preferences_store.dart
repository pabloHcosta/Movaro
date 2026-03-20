import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

typedef FeatureGuideDirectoryProvider = Future<Directory> Function();

class FeatureGuidePreferencesStore {
  FeatureGuidePreferencesStore({
    FeatureGuideDirectoryProvider? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final FeatureGuideDirectoryProvider _directoryProvider;

  Future<bool> hasSeenIntro(String key) async {
    final current = await _read();
    final value = current[key];
    return value is Map<String, dynamic> && value['hasSeenIntro'] == true;
  }

  Future<void> markIntroSeen(String key) async {
    final current = await _read();
    final next = _entry(current, key);
    next['hasSeenIntro'] = true;
    await _write(current);
  }

  Future<bool> shouldShowGuide(String key) async {
    final current = await _read();
    final value = current[key];
    return value is! Map<String, dynamic> || value['hideGuide'] != true;
  }

  Future<void> setHideGuide(String key, bool hideGuide) async {
    final current = await _read();
    final next = _entry(current, key);
    next['hasSeenIntro'] = true;
    next['hideGuide'] = hideGuide;
    await _write(current);
  }

  Map<String, dynamic> _entry(Map<String, dynamic> current, String key) {
    final value = current[key];
    if (value is Map<String, dynamic>) {
      return value;
    }

    final next = <String, dynamic>{};
    current[key] = next;
    return next;
  }

  Future<Map<String, dynamic>> _read() async {
    try {
      final file = await _file();
      if (!file.existsSync()) {
        return <String, dynamic>{};
      }

      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return <String, dynamic>{};
      }

      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<void> _write(Map<String, dynamic> value) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(value));
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_feature_guides.json');
  }
}
