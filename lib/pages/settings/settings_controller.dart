import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthxp/enums/unit_system.enum.dart';
import 'package:healthxp/services/error_logger.service.dart';
import 'package:healthxp/services/health_data_cache_service.dart';
import 'package:healthxp/services/preferences_service.dart';
import 'package:healthxp/services/goals_service.dart';

class SettingsController with ChangeNotifier {
  late final GoalsService _goalsService;
  late final HealthDataCache _healthDataCache;
  UnitSystem _unitSystem = UnitSystem.metric;

  UnitSystem get unitSystem => _unitSystem;

  SettingsController() {
    _initialize();
  }

  Future<void> _initialize() async {
    _goalsService = await GoalsService.getInstance();
    _healthDataCache = await HealthDataCache.getInstance();
    await _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _unitSystem = await PreferencesService.getUnitSystem();
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
    try {
      await _goalsService.clearCache();
      await _healthDataCache.clearCache();
    } catch (e) {
      await ErrorLogger.logError('Error clearing cache: $e');
    }
  }

  Future<void> logout(BuildContext context) async {
    final navigator = Navigator.of(context);

    try {
      await clearPreferences();
      await _goalsService.dispose();
      await _healthDataCache.dispose();
      await FirebaseAuth.instance.signOut();

      navigator.pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      await ErrorLogger.logError('Error during logout: $e');
    }
  }

  @override
  void dispose() {
    _goalsService.dispose();
    _healthDataCache.dispose();
    super.dispose();
  }
}
