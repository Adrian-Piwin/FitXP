import 'package:flutter/material.dart';

class CoreColors{
  static const Color backgroundColor = Color(0xFF3e3e3e);
  static const Color accentColor = Color(0xFF787472);
  static const Color textColor = Color(0xFFeeebe9);
  static const Color navBarColor = Color(0xFF282828);
}

class WidgetColors{
  static const Color primaryColor = Color(0xFF222222);
}

class PercentIndicatorColors{
  static const Color backgroundColor = Color(0xFF7B7788);
  static const Color backgroundColor2 = Color.fromARGB(255, 66, 64, 73);
  static const Color progressColor = Color(0xFF3F51B5);
}

class RepresentationColors{
  static const Color activityColor = Color(0xFFf96e2a);
  static const Color activityOffColor = Color(0x33dad3d0);

  static const Color sleepColor = Color(0xFFfeaf3f);
  static const Color sleepOffColor = Color(0x33dad3d0);

  static const Color foodColor = Color(0xFF26a7e3);
  static const Color foodOffColor = Color(0x33dad3d0);

  static const Color trendColor = Color(0xFFdad3d0);
  static const Color trendOffColor = Color(0x33dad3d0);

  static const Color optionalColor = Color(0xFFcd4c0d);
  static const Color optionalOffColor = Color(0x33dad3d0);

  static const Color caloriesColor = Color(0xFFC1292E);
  static const Color activeCaloriesColor = Color(0xFFC03221);
  static const Color restingCaloriesColor = Color(0xFFC03221);
  static const Color stepsColor = Color(0xFF84C7D0);
  static const Color netCaloriesColor = Color(0xFFD4C5E2);
  static const Color dietaryCaloriesColor = Color(0xFFA1CCA5);
  static const Color proteinColor = Color.fromARGB(255, 198, 161, 204);
  static const Color healthItemColor = Color.fromARGB(255, 198, 161, 204);
  static const Color exerciseColor = Color.fromARGB(255, 161, 204, 187);
  static const Color sleepAwakeColor = Color.fromARGB(255, 255, 152, 0);
  static const Color sleepDeepColor = Color.fromARGB(255, 33, 150, 243);
  static const Color sleepRemColor = Color.fromARGB(255, 156, 39, 176);
  static const Color sleepLightColor = Color.fromARGB(255, 76, 175, 80);
  static const Color weightColor = Color.fromARGB(255, 161, 204, 201);
  static const Color bodyFatColor = Color.fromARGB(255, 161, 204, 201);
}

class CharacterColors {
  static const Color levelXPColor = Color(0xFF3F51B5);  // Blue
  static const Color levelXPBackgroundColor = Color(0xFFE3F2FD);  // Light Blue
  static const Color rankXPColor = Color(0xFFFFD700);  // Gold
  static const Color rankXPBackgroundColor = Color(0xFFFFF8E1);  // Light Gold
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
