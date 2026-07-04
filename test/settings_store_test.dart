import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miterpal/services/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to system when nothing is stored', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    expect(await SettingsStore().loadThemeMode(), ThemeMode.system);
  });

  test('round-trips each theme mode', () async {
    for (final ThemeMode mode in ThemeMode.values) {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SettingsStore store = SettingsStore();
      await store.saveThemeMode(mode);
      expect(await store.loadThemeMode(), mode);
    }
  });
}
