import 'package:flutter/material.dart';
import 'package:healthxp/components/grid_layout.dart';
import 'package:healthxp/components/info_bar.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/enums/timeframe.enum.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:provider/provider.dart';
import '../../components/timeframe_tabbar.dart';
import '../../components/date_selector.dart';
import 'health_details_controller.dart';

class HealthDataDetailPage extends StatelessWidget {
  final HealthEntity widget;

  const HealthDataDetailPage({
    super.key,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HealthDetailsController>(
      create: (context) => HealthDetailsController(
        widget: widget,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.healthItem.title),
          titleSpacing: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Consumer<HealthDetailsController>(
              builder: (context, controller, _) {
                return TimeFrameTabBar(
                  selectedTimeFrame: controller.selectedTimeFrame,
                  onChanged: (newTimeFrame) {
                    controller.updateTimeFrame(newTimeFrame);
                  },
                  timeFrameOptions: controller.timeFrameOptions,
                );
              },
            ),
          ),
        ),
        body: Column(
          children: [
            Consumer<HealthDetailsController>(
              builder: (context, controller, _) {
                return DateSelector(
                  selectedTimeFrame: controller.selectedTimeFrame,
                  offset: controller.offset,
                  onOffsetChanged: (newOffset) {
                    controller.updateOffset(newOffset);
                  },
                );
              },
            ),
            Expanded(
              child: Consumer<HealthDetailsController>(
                builder: (context, controller, _) {
                  return GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity == null) return;
                      
                      // Swiping right (positive velocity)
                      if (details.primaryVelocity! > 0) {
                        controller.updateOffset(controller.offset - 1);
                      }
                      // Swiping left (negative velocity)
                      else if (details.primaryVelocity! < 0) {
                        // Only allow going forward if not at current date
                        if (controller.offset != 0) {
                          controller.updateOffset(controller.offset + 1);
                        }
                      }
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (controller.widget.getGoalPercent != -1)
                            Padding(
                              padding: const EdgeInsets.all(GapSizes.large),
                              child: InfoBar(
                                title: controller.widget.healthItem.title,
                                value: controller.widget.timeframe == TimeFrame.day ? controller.widget.getDisplayValueWithUnit : controller.widget.getDisplayAverage,
                                goal: controller.widget.getDisplayGoalWithUnit,
                                percent: controller.widget.getGoalPercent,
                                color: controller.widget.healthItem.color,
                                textColor: controller.widget.healthItem.offColor,
                              ),
                            ),
                          GridLayout(widgets: controller.getDetailWidgets),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
