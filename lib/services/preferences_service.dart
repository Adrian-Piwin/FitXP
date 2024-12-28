import 'package:healthxp/enums/unit_system.enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _unitSystemKey = 'unitSystem';

  static UnitSystem? _cachedUnitSystem;

  // Getters
  static Future<UnitSystem> getUnitSystem() async {
    if (_cachedUnitSystem != null) return _cachedUnitSystem!;
    
    final prefs = await SharedPreferences.getInstance();
    final unitSystemString = prefs.getString(_unitSystemKey) ?? 'metric';
    _cachedUnitSystem = UnitSystem.values.firstWhere(
      (e) => e.toString() == 'UnitSystem.$unitSystemString',
      orElse: () => UnitSystem.metric,
    );
    return _cachedUnitSystem!;
  }

  // Setters
  static Future<void> setUnitSystem(UnitSystem unitSystem) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitSystemKey, unitSystem.name);
    _cachedUnitSystem = unitSystem;
  }

  // Clear all preferences
  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _cachedUnitSystem = null;
  }
} 
