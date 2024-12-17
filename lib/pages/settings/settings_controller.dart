import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthxp/enums/unit_system.enum.dart';
import 'package:healthxp/services/health_data_cache_service.dart';
import 'package:healthxp/services/fitbit_service.dart';
import 'settings_service.dart';
import 'package:healthxp/services/preferences_service.dart';

class SettingsController with ChangeNotifier {
  final SettingsService _settingsService;
  final FitbitService _fitbitService = FitbitService();

  bool _syncFoodIntake = false;
  UnitSystem _unitSystem = UnitSystem.metric;
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;
  bool get isFitbitConnected => _fitbitService.isConnected;
  bool get syncFoodIntake => _syncFoodIntake;
  UnitSystem get unitSystem => _unitSystem;

  SettingsController(this._settingsService) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _themeMode = await PreferencesService.getThemeMode();
    _syncFoodIntake = await PreferencesService.getSyncFoodIntake();
    _unitSystem = await PreferencesService.getUnitSystem();
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    await PreferencesService.setThemeMode(newThemeMode);
    notifyListeners();
  }

  Future<void> updateUnitSystem(UnitSystem newUnitSystem) async {
    if (newUnitSystem == _unitSystem) return;
    _unitSystem = newUnitSystem;
    await PreferencesService.setUnitSystem(newUnitSystem);
    notifyListeners();
  }

  Future<void> clearPreferences() async {
    await PreferencesService.clearPreferences();
    await _loadPreferences();
  }

  Future<void> clearCache() async {
    await HealthDataCache().clearCache();
  }

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();

    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    final navigator = Navigator.of(context);

    await clearPreferences();
    await FirebaseAuth.instance.signOut();

    navigator.pushNamedAndRemoveUntil('/', (route) => false);
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
}
