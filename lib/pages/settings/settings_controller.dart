import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthxp/services/health_data_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthxp/services/fitbit_service.dart';
import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  final SettingsService _settingsService;
  final FitbitService _fitbitService = FitbitService();

  bool _syncFoodIntake = false;

  SettingsController(this._settingsService) {
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isFitbitConnected => _fitbitService.isConnected;
  bool get syncFoodIntake => _syncFoodIntake;
  late ThemeMode _themeMode;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();

    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();

    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> logout(BuildContext context) async {
    final navigator = Navigator.of(context);

    await clearPreferences();
    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> clearPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await HealthDataCache().clearCache();
  }

  Future<void> connectFitbit() async {
    final success = await _fitbitService.connect();
    if (success) {
      notifyListeners();
    }
  }

  Future<void> disconnectFitbit() async {
    await _fitbitService.disconnect();
    notifyListeners();
  }

  void setSyncFoodIntake(bool value) async {
    _syncFoodIntake = value;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('syncFoodIntake', value);
  }

  Future<void> _loadPreferences() async {
    if (!_fitbitService.isConnected) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _syncFoodIntake = prefs.getBool('syncFoodIntake') ?? false;
    notifyListeners();
  }
}
