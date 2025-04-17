import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthcore/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:healthcore/pages/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  Superwall.configure(dotenv.env['PAYWALL_API_KEY']!);

  await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Health plugin
  Health().configure();

  runApp(const MyApp());
}
