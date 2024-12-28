import 'package:flutter/material.dart';

class CoreColors{
  static const Color backgroundColor = Color(0xFF3e3e3e);
  static const Color accentColor = Color(0xFF787472);
  static const Color textColor = Color(0xFFeeebe9);
  static const Color navBarColor = Color(0xFF282828);
  static const Color coreGrey = Color(0x33dad3d0);
  static const Color coreBlue = Color(0xFF26a7e3);
  static const Color coreOffBlue = Color(0xFF9ddefc);
  static const Color coreOrange = Color(0xFFf96e2a);
  static const Color coreOffOrange = Color(0xFFfdd2bd);
  static const Color coreGold = Color(0xFFf1cc07);
  static const Color coreLightOrange = Color(0xFFfaea3f);
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
