import 'package:flutter/material.dart';
import 'package:healthxp/enums/health_item_type.enum.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/pages/home/components/basic_health_widget.dart';
import 'package:healthxp/pages/home/components/circular_health_widget.dart';
import 'package:healthxp/pages/home/components/header_widget_item.dart';
import 'package:healthxp/pages/insights/components/basic_weekly_health_widget.dart';
import 'package:healthxp/pages/insights/components/rank_widget.dart';

class WidgetConfigurationService {
  List<HealthEntity> healthEntities = [];

  WidgetConfigurationService(this.healthEntities);

  List<Widget> getWidgets() {
    var bodyWidgets = healthEntities.sublist(4).map((entity) => getWidget(entity)).toList();
    var headerWidgets = healthEntities.sublist(0, 4);
    return [HeaderWidgetItem(barWidget: headerWidgets[0], subWidgetFirst: headerWidgets[1], subWidgetSecond: headerWidgets[2], subWidgetThird: headerWidgets[3]), ...bodyWidgets];
  }

  Widget getWidget(HealthEntity healthEntity) {
    switch (healthEntity.healthItem.itemType) {
      case HealthItemType.dietaryCalories || HealthItemType.netCalories || HealthItemType.activeCalories:
        return CircularHealthWidget(widget: healthEntity);
      default:
        return BasicHealthWidget(widget: healthEntity);
    }
  }

  List<Widget> getWeeklyInsightWidgets() {
    return [RankWidget(), ...healthEntities.map((entity) => BasicWeeklyHealthWidget(widget: entity))];
  }
}
