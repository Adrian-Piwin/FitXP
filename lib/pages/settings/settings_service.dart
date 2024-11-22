import 'package:flutter/material.dart';

class SettingsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  Future<ThemeMode> themeMode() async => ThemeMode.system;

  Future<void> updateThemeMode(ThemeMode theme) async {
    // TODO: Store preferred ThemeMode using preferences.
  }
}
