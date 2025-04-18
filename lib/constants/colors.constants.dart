import 'package:flutter/material.dart';

class CoreColors{
  static const Color backgroundColor = Color(0xFF2F2F2F);
  static const Color foregroundColor = Color(0xFF282828);
  static const Color accentColor = Color(0xFF787472);
  static const Color accentAltColor = Color(0x80787472);
  static const Color textColor = Color(0xFFeeebe9);
  static const Color navBarColor = Color(0xFF282828);
  static const Color coreGrey = Color(0x33dad3d0);
  static const Color coreLightGrey = Color(0xFFeeebe9);
  static const Color coreOffLightGrey = Color(0xFFbdbdbd);
  static const Color coreBlue = Color(0xFF26a7e3);
  static const Color coreOffBlue = Color(0xFF9ddefc);
  static const Color coreGreen = Color(0xFF4CAF50);
  static const Color coreOffGreen = Color(0xFFb2dfdb);
  static const Color coreOrange = Color(0xFFf96e2a);
  static const Color coreOffOrange = Color(0xFFfdd2bd);
  static const Color coreGold = Color(0xFFf1cc07);
  static const Color corePlatinum = Color(0xFFDBF8FF);
  static const Color coreDiamond = Color(0xFFb9f2ff);
  static const Color coreSilver = Color(0xFFc0c0c0);
  static const Color coreBronze = Color(0xFFcd853f);
  static const Color coreLightOrange = Color(0xFFfaea3f);
  static const Color coreOffLightOrange = Color(0xE9FAEA3F);
  static const Color coreBrown = Color.fromARGB(255, 205, 51, 13);
  static const Color coreOffBrown = Color(0xFFfdd2bd);
  static const Color errorColor = Color(0xFFFF3B30);
  static const Color successColor = Color(0xFF34C759);
  static const Color warningColor = Color(0xFFFF9500);
}

class RepresentationColors{
  static const Color sleepAwakeColor = Color.fromARGB(255, 255, 152, 0);
  static const Color sleepDeepColor = Color.fromARGB(255, 33, 150, 243);
  static const Color sleepRemColor = Color.fromARGB(255, 156, 39, 176);
  static const Color sleepLightColor = Color.fromARGB(255, 76, 175, 80);
}

class GradientColors {
  static const LinearGradient widgetBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF222222),  // Dark color at bottom right
      Color(0xFF282828),  // Second color stops at 50%
    ],
    stops: [0.5, 1.0],    // Second color stops at 50%
    begin: Alignment.bottomRight,
    end: Alignment.topLeft,
  );
}
