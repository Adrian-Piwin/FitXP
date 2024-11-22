import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitbitter/fitbitter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_service.dart';

class SettingsController with ChangeNotifier {
  final SettingsService _settingsService;
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  bool _isFitbitConnected = false;
  bool _syncFoodIntake = false;

  SettingsController(this._settingsService) {
    _loadPreferences();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isFitbitConnected => _isFitbitConnected;
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
  }

  Future<void> connectFitbit() async {
    FitbitCredentials? fitbitCredentials =
        await FitbitConnector.authorize(
            clientID: dotenv.env['FITBIT_CLIENTID'] ?? '',
            clientSecret: dotenv.env['FITBIT_SECRET'] ?? '',
            redirectUri: dotenv.env['FITBIT_URI'] ?? '',
            callbackUrlScheme: dotenv.env['FITBIT_URI_SCHEME'] ?? ''
        );

    if (fitbitCredentials != null) {
      _isFitbitConnected = true;
      await secureStorage.write(key: 'accessToken', value: fitbitCredentials.fitbitAccessToken);
      await secureStorage.write(key: 'refreshToken', value: fitbitCredentials.fitbitRefreshToken);
      await secureStorage.write(key: 'userID', value: fitbitCredentials.userID);
    }
  }

  void setSyncFoodIntake(bool value) async {
    _syncFoodIntake = value;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('syncFoodIntake', value);
  }

  Future<void> _loadPreferences() async {
    String? accessToken = await secureStorage.read(key: 'accessToken');
    if (accessToken != null) {
      _isFitbitConnected = true;
    }else {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _syncFoodIntake = prefs.getBool('syncFoodIntake') ?? false;
    notifyListeners();
  }
}
