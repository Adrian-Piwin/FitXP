import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/enums/health_category.enum.dart';

class HealthCategoryColors {
  static Color getColorForCategory(HealthCategory category) {
    switch (category) {
      case HealthCategory.movement:
        return CoreColors.coreOrange;
      case HealthCategory.energy:
        return CoreColors.coreOrange;
      case HealthCategory.exercise:
        return CoreColors.coreOrange;
      case HealthCategory.nutrition:
        return CoreColors.coreBlue;
      case HealthCategory.body:
        return CoreColors.coreLightGrey;
      case HealthCategory.health:
        return CoreColors.coreBrown;
      case HealthCategory.wellness:
        return CoreColors.coreLightOrange;
    }
  }

  static Color getOffColorForCategory(HealthCategory category) {
    switch (category) {
      case HealthCategory.movement:
        return CoreColors.coreOffOrange;
      case HealthCategory.energy:
        return CoreColors.coreOffOrange;
      case HealthCategory.exercise:
        return CoreColors.coreOffOrange;
      case HealthCategory.nutrition:
        return CoreColors.coreOffBlue;
      case HealthCategory.body:
        return CoreColors.coreOffLightGrey;
      case HealthCategory.health:
        return CoreColors.coreOffBrown;
      case HealthCategory.wellness:
        return CoreColors.coreOffLightOrange;
    }
  }
} 
