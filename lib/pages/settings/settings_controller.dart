import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthcore/enums/unit_system.enum.dart';
import 'package:healthcore/services/error_logger.service.dart';
import 'package:healthcore/services/health_data_cache_service.dart';
import 'package:healthcore/services/preferences_service.dart';
import 'package:healthcore/services/goals_service.dart';
import 'package:healthcore/services/xp_service.dart';
import 'package:healthcore/utility/global_ui.utility.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

class SettingsController with ChangeNotifier {
  late final GoalsService _goalsService;
  late final HealthDataCache _healthDataCache;
  late final XpService _xpService;
  UnitSystem _unitSystem = UnitSystem.metric;

  UnitSystem get unitSystem => _unitSystem;

  SettingsController();

  Future<void> initialize() async {
    await _initialize();
  }

  Future<void> _initialize() async {
    _goalsService = await GoalsService.getInstance();
    _healthDataCache = await HealthDataCache.getInstance();
    _xpService = await XpService.getInstance();
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
      await _xpService.clearCache();
    } catch (e) {
      GlobalUI.showError('Error clearing cache');
      await ErrorLogger.logError('Error clearing cache: $e');
    }
  }

  Future<void> logout(BuildContext context) async {
    final navigator = Navigator.of(context);

    try {
      await clearPreferences();
      await _goalsService.dispose();
      await _healthDataCache.dispose();
      await _xpService.dispose();
      await Superwall.shared.reset();
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
    _xpService.dispose();
    super.dispose();
  }
}
