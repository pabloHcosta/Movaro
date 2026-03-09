import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:movaro_app/app/localization/app_localization.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({Locale? initialLocale})
    : _localeOverride = initialLocale == null
          ? null
          : AppLocalization.resolveLocale(initialLocale);

  Locale? _localeOverride;

  Locale? get locale => _localeOverride;

  Locale get effectiveLocale => AppLocalization.resolveLocale(
    _localeOverride ?? PlatformDispatcher.instance.locale,
  );

  void setLocale(Locale locale) {
    final resolvedLocale = AppLocalization.resolveLocale(locale);

    if (_localeOverride == resolvedLocale) {
      return;
    }

    _localeOverride = resolvedLocale;
    notifyListeners();
  }

  void useSystemLocale() {
    if (_localeOverride == null) {
      return;
    }

    _localeOverride = null;
    notifyListeners();
  }
}
