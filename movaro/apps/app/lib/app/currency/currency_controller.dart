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

  /// Currency explicitly chosen by the user in Settings. Persisted.
  String? _currencyCode;

  /// Currency inferred from the device's GPS location. Not persisted.
  String? _detectedCurrencyCode;

  /// The explicitly selected currency code, or null if not set.
  String? get currencyCode => _currencyCode;

  /// The GPS-inferred currency code, or null if location is unknown.
  String? get detectedCurrencyCode => _detectedCurrencyCode;

  /// Effective currency code: user-selected → GPS-detected → null (falls back to USD in widget).
  String? get resolvedCurrencyCode => _currencyCode ?? _detectedCurrencyCode;

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

  /// Called when the device GPS detects the user's current country.
  /// [countryId] may be an ISO-2 code (e.g. "AR") or a catalog country ID
  /// (e.g. "argentina"). Pass null to clear the detected currency.
  void setDetectedCurrencyFromCountry(String? countryId) {
    final code = _currencyCodeForCountry(countryId);
    if (_detectedCurrencyCode == code) return;
    _detectedCurrencyCode = code;
    notifyListeners();
  }

  /// Maps a country ID or ISO-2 code to the corresponding currency code.
  /// Returns null when the country is unknown (widget will fall back to USD).
  static String? _currencyCodeForCountry(String? countryId) {
    switch (countryId?.toLowerCase()) {
      case 'argentina':
      case 'ar':
        return 'ARS';
      case 'chile':
      case 'cl':
        return 'CLP';
      case 'uruguai':
      case 'uruguay':
      case 'uy':
        return 'UYU';
      case 'colombia':
      case 'co':
        return 'COP';
      case 'peru':
      case 'pe':
        return 'PEN';
      case 'paraguai':
      case 'paraguay':
      case 'py':
        return 'PYG';
      case 'bolivia':
      case 'bo':
        return 'BOB';
      case 'brasil':
      case 'brazil':
      case 'br':
        return 'BRL';
      case 'estados_unidos':
      case 'united_states':
      case 'usa':
      case 'us':
        return 'USD';
      default:
        return null;
    }
  }
}
