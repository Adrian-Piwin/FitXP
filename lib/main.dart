import 'package:firebase_core/firebase_core.dart';
import 'package:healthxp/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'pages/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
   options: DefaultFirebaseOptions.currentPlatform,
 );

  Health().configure();

  runApp(const MyApp());
}
