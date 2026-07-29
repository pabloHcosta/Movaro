import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:movaro_app/app/currency/currency_preferences_store.dart';

/// Supported currencies for display throughout the app.
enum AppCurrency {
  usd('USD'),
  brl('BRL'),
  ars('ARS'),
  clp('CLP');

  const AppCurrency(this.code);
  final String code;

  static AppCurrency? fromCode(String code) {
    for (final c in AppCurrency.values) {
      if (c.code == code) return c;
    }
    return null;
  }
}

class CurrencyController extends ChangeNotifier {
  CurrencyController({CurrencyPreferencesStore? store})
    : _store = store ?? CurrencyPreferencesStore();

  final CurrencyPreferencesStore _store;

  static const defaultCurrencyCode = 'USD';

  /// Currency chosen by the user in Settings. USD is the app default.
  String _currencyCode = defaultCurrencyCode;

  String get currencyCode => _currencyCode;
  String get resolvedCurrencyCode => _currencyCode;

  Future<void> initialize() async {
    final storedCode = await _store.readCurrencyCode();
    _currencyCode =
        AppCurrency.fromCode(storedCode ?? '')?.code ?? defaultCurrencyCode;
    notifyListeners();
  }

  void setCurrency(String code) {
    final supported = AppCurrency.fromCode(code.toUpperCase());
    if (supported == null || _currencyCode == supported.code) return;
    _currencyCode = supported.code;
    unawaited(_store.saveCurrencyCode(supported.code));
    notifyListeners();
  }

  /// Resets the preference to the documented app default.
  void clearCurrency() {
    setCurrency(defaultCurrencyCode);
  }
}
