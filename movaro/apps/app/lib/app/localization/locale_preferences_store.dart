import 'package:shared_preferences/shared_preferences.dart';

class LocalePreferencesStore {
  LocalePreferencesStore();

  static const _localeKey = 'app_locale_override';

  Future<String?> readLocaleCode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_localeKey);
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> saveLocaleCode(String? localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (localeCode == null || localeCode.trim().isEmpty) {
      await prefs.remove(_localeKey);
      return;
    }
    await prefs.setString(_localeKey, localeCode);
  }
}
