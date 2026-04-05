import 'package:shared_preferences/shared_preferences.dart';

class CurrencyPreferencesStore {
  static const _currencyKey = 'app_currency_override';

  Future<String?> readCurrencyCode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_currencyKey);
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> saveCurrencyCode(String? currencyCode) async {
    final prefs = await SharedPreferences.getInstance();
    if (currencyCode == null || currencyCode.trim().isEmpty) {
      await prefs.remove(_currencyKey);
      return;
    }
    await prefs.setString(_currencyKey, currencyCode);
  }
}
