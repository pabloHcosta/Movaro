import 'package:shared_preferences/shared_preferences.dart';

class DocumentationGuidePreferencesStore {
  DocumentationGuidePreferencesStore();

  static const _hideKey = 'help_documentation_guide';
  static const _seenKey = 'help_seen_documentation_guide';

  Future<bool> hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey) ?? false;
  }

  Future<void> markIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
  }

  Future<bool> shouldShowGuide() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_hideKey) ?? false);
  }

  Future<void> setHideGuide(bool hideGuide) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
    await prefs.setBool(_hideKey, hideGuide);
  }
}
