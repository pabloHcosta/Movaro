import 'package:shared_preferences/shared_preferences.dart';

class FeatureGuidePreferencesStore {
  FeatureGuidePreferencesStore();

  Future<bool> hasSeenIntro(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('help_seen_$key') ?? false;
  }

  Future<void> markIntroSeen(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('help_seen_$key', true);
  }

  Future<bool> shouldShowGuide(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('help_$key') ?? false);
  }

  Future<void> setHideGuide(String key, bool hideGuide) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('help_seen_$key', true);
    await prefs.setBool('help_$key', hideGuide);
  }
}
