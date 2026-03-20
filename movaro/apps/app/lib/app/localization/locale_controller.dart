import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:movaro_app/app/localization/app_localization.dart';
import 'package:movaro_app/app/localization/locale_preferences_store.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({
    Locale? initialLocale,
    LocalePreferencesStore? store,
  })
    : _store = store ?? LocalePreferencesStore(),
      _localeOverride = initialLocale == null
          ? null
          : AppLocalization.resolveLocale(initialLocale);

  final LocalePreferencesStore _store;
  Locale? _localeOverride;
  bool _isInitialized = false;

  Locale? get locale => _localeOverride;
  bool get isInitialized => _isInitialized;

  Locale get effectiveLocale => AppLocalization.resolveLocale(
    _localeOverride ?? PlatformDispatcher.instance.locale,
  );

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    final localeCode = await _store.readLocaleCode();
    if (localeCode != null) {
      _localeOverride = AppLocalization.resolveLocale(Locale(localeCode));
    }
    _isInitialized = true;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    final resolvedLocale = AppLocalization.resolveLocale(locale);

    if (_localeOverride == resolvedLocale) {
      return;
    }

    _localeOverride = resolvedLocale;
    unawaited(_store.saveLocaleCode(resolvedLocale.languageCode));
    notifyListeners();
  }

  void useSystemLocale() {
    if (_localeOverride == null) {
      return;
    }

    _localeOverride = null;
    unawaited(_store.saveLocaleCode(null));
    notifyListeners();
  }
}
