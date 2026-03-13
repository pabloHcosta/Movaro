import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

typedef QuestionnaireGuideDirectoryProvider = Future<Directory> Function();

class QuestionnaireGuidePreferencesStore {
  QuestionnaireGuidePreferencesStore({
    QuestionnaireGuideDirectoryProvider? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final QuestionnaireGuideDirectoryProvider _directoryProvider;

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

  Future<void> _write(Map<String, dynamic> value) async {
    final file = await _file();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(value));
  }

  Future<File> _file() async {
    final directory = await _directoryProvider();
    return File('${directory.path}/movaro_questionnaire_guide.json');
  }
}
