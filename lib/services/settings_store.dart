import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists lightweight app settings (currently just the theme mode).
class SettingsStore {
  static const String _themeKey = 'theme_mode';

  /// Loads the saved theme mode, defaulting to [ThemeMode.system].
  Future<ThemeMode> loadThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    switch (prefs.getString(_themeKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Saves the theme mode.
  Future<void> saveThemeMode(ThemeMode mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }
}
