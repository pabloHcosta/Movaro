import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:movaro_app/app/currency/currency_preferences_store.dart';

/// Supported currencies for display throughout the app.
enum AppCurrency {
  usd('USD'),
  eur('EUR'),
  brl('BRL'),
  ars('ARS'),
  clp('CLP'),
  uyu('UYU'),
  cop('COP'),
  pen('PEN'),
  pyg('PYG'),
  bob('BOB');

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
  String? _currencyCode;

  /// The explicitly selected currency code, or null if not set (app infers from country).
  String? get currencyCode => _currencyCode;

  Future<void> initialize() async {
    _currencyCode = await _store.readCurrencyCode();
    notifyListeners();
  }

  void setCurrency(String code) {
    if (_currencyCode == code) return;
    _currencyCode = code;
    unawaited(_store.saveCurrencyCode(code));
    notifyListeners();
  }

  void clearCurrency() {
    if (_currencyCode == null) return;
    _currencyCode = null;
    unawaited(_store.saveCurrencyCode(null));
    notifyListeners();
  }
}
