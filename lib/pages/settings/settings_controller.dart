import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:healthxp/enums/unit_system.enum.dart';
import 'package:healthxp/services/health_data_cache_service.dart';
import 'package:healthxp/services/fitbit_service.dart';
import 'package:healthxp/services/preferences_service.dart';
import 'package:healthxp/pages/data_loading/data_loading_view.dart';

class SettingsController with ChangeNotifier {
  final FitbitService _fitbitService = FitbitService();

  UnitSystem _unitSystem = UnitSystem.metric;

  bool get isFitbitConnected => _fitbitService.isConnected;
  UnitSystem get unitSystem => _unitSystem;

  SettingsController() {
    _loadPreferences();
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
    await HealthDataCache().clearCache();
  }

  Future<void> getAllData(BuildContext context) async {
    Navigator.of(context).pushNamed(DataLoadingView.routeName);
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
