import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:healthxp/enums/health_item_type.enum.dart';
import 'package:healthxp/enums/xp_type.enum.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';

typedef WidgetFactory = HealthEntity Function(
    HealthItem item, int widgetSize);

class HealthItem {
  List<HealthDataType> dataType = [];
  late HealthItemType itemType;
  late String title;
  late String unit;
  late Color color;
  late Color offColor;
  late IconData icon;
  double iconSizeMultiplier = 1.0;
  double iconRotation = 0;
  XPType? xpType;
  bool doesGoalSupportDecimals = false;
  bool doesGoalSupportNegative = false;
  WidgetFactory widgetFactory =
      ((item, widgetSize) =>
          HealthEntity(item, widgetSize));
}
