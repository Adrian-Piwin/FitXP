import 'package:healthcore/components/info_bar.dart';
import 'package:healthcore/components/widget_frame.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
import 'package:flutter/material.dart';
import 'package:healthcore/pages/home/components/circular_health_widget.dart';
import 'package:healthcore/pages/home_details/health_details_view.dart';

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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HealthDataDetailPage(widget: barWidget),
                    ),
                  );
                },
                child: RepaintBoundary(
                  child: InfoBar(
                    title: barWidget.healthItem.title,
                    formatValue: barWidget.formatValue,
                    value: barWidget.total,
                    unit: barWidget.healthItem.unit,
                    goal: barWidget.getDisplayGoal,
                    percent: barWidget.getGoalPercent,
                    color: barWidget.healthItem.color,
                    textColor: barWidget.healthItem.offColor,
                    animateChanges: true,
                  ),
                ),
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
