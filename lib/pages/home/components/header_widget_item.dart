import 'package:healthxp/components/info_bar.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:flutter/material.dart';
import 'package:healthxp/pages/home/components/circular_health_widget.dart';

class HeaderWidgetItem extends WidgetFrame {
  final HealthEntity barWidget;
  final HealthEntity subWidgetFirst;
  final HealthEntity subWidgetSecond;
  final HealthEntity subWidgetThird;

  const HeaderWidgetItem({
    super.key,
    required this.barWidget, 
    required this.subWidgetFirst, 
    required this.subWidgetSecond, 
    required this.subWidgetThird,
  }): super(
          size: 6,
          height: WidgetSizes.largeHeight,
        );

  @override
  Widget buildContent(BuildContext context) {
    return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InfoBar(
                title: barWidget.healthItem.title,
                value: barWidget.getDisplayValue,
                goal: barWidget.getDisplayGoal,
                percent: barWidget.getGoalPercent,
                color: barWidget.healthItem.color,
                offColor: barWidget.healthItem.offColor,
              ),
              const SizedBox(height: GapSizes.xxlarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircularHealthWidget(widget: subWidgetFirst),
                  CircularHealthWidget(widget: subWidgetSecond),
                  CircularHealthWidget(widget: subWidgetThird),
                ],
              ),
            ],
          );
  }
}
