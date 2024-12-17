import 'package:flutter/material.dart';
import 'package:healthxp/enums/unit_system.enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeKey = 'theme';
  static const String _unitSystemKey = 'unitSystem';
  static const String _syncFoodIntakeKey = 'syncFoodIntake';

  static UnitSystem? _cachedUnitSystem;
  static ThemeMode? _cachedThemeMode;
  static bool? _cachedSyncFoodIntake;

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

  static Future<ThemeMode> getThemeMode() async {
    if (_cachedThemeMode != null) return _cachedThemeMode!;
    
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeKey) ?? 'system';
    _cachedThemeMode = ThemeMode.values.firstWhere(
      (e) => e.toString() == 'ThemeMode.$themeModeString',
      orElse: () => ThemeMode.system,
    );
    return _cachedThemeMode!;
  }

  static Future<bool> getSyncFoodIntake() async {
    if (_cachedSyncFoodIntake != null) return _cachedSyncFoodIntake!;
    
    final prefs = await SharedPreferences.getInstance();
    _cachedSyncFoodIntake = prefs.getBool(_syncFoodIntakeKey) ?? false;
    return _cachedSyncFoodIntake!;
  }

  // Setters
  static Future<void> setUnitSystem(UnitSystem unitSystem) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitSystemKey, unitSystem.name);
    _cachedUnitSystem = unitSystem;
  }

  static Future<void> setThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode.name);
    _cachedThemeMode = themeMode;
  }

  static Future<void> setSyncFoodIntake(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncFoodIntakeKey, value);
    _cachedSyncFoodIntake = value;
  }

  // Clear all preferences
  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _cachedUnitSystem = null;
    _cachedThemeMode = null;
    _cachedSyncFoodIntake = null;
  }
} 
