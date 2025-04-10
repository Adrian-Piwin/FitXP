import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:healthcore/enums/health_item_type.enum.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
import 'package:healthcore/services/health_fetcher_service.dart';
import 'package:healthcore/enums/health_category.enum.dart';

typedef WidgetFactory = HealthEntity Function(
    HealthItem item, int widgetSize, HealthFetcherService healthFetcherService);

class HealthItem {
  List<HealthDataType> dataType = [];
  late HealthItemType itemType;
  late String title;
  late String unit;
  late Color color;
  late Color offColor;
  late IconData icon;
  late HealthCategory category;  // Category of the health item
  late double defaultGoal;
  double iconRotation = 0;
  bool doesGoalSupportStreaks = true;
  bool doesGoalSupportDecimals = false;
  bool doesGoalSupportNegative = false;
  bool doesGoalSupportTimeInput = false;
  late String shortDescription;  // Brief description for widget configuration page
  late String longDescription;   // Detailed description for info popup
  WidgetFactory widgetFactory =
      ((item, widgetSize, healthFetcherService) =>
          HealthEntity(item, widgetSize, healthFetcherService));
}
