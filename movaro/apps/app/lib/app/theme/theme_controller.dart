import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movaro_app/app/theme/theme_preferences_store.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({ThemePreferencesStore? store})
    : _store = store ?? ThemePreferencesStore(),
      _themeMode = ThemeMode.dark;

  final ThemePreferencesStore _store;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> initialize() async {
    final saved = await _store.readThemeMode();
    if (saved != null) {
      _themeMode = saved;
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    unawaited(_store.saveThemeMode(mode));
    notifyListeners();
  }
}
