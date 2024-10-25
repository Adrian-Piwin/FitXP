import 'package:firebase_core/firebase_core.dart';
import 'package:fitxp/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';

import 'pages/app.dart';
import 'pages/settings/settings_controller.dart';
import 'pages/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
 );

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  Health().configure();

  runApp(MyApp(settingsController: settingsController));
}
