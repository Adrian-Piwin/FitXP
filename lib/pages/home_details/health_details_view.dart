import 'package:flutter/material.dart';
import 'package:healthcore/components/grid_layout.dart';
import 'package:healthcore/components/info_bar.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
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

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(widget.healthItem.title),
          content: Text(widget.healthItem.longDescription),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
          actions: [
            if (widget.healthItem.longDescription.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showInfoDialog(context),
              ),
          ],
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
        body: Consumer<HealthDetailsController>(
          builder: (context, controller, _) {
            return DateSelector(
              selectedTimeFrame: controller.selectedTimeFrame,
              offset: controller.offset,
              onOffsetChanged: controller.updateOffset,
              child: Column(
                children: [
                  if (controller.widget.getGoalPercent != -1)
                    Padding(
                      padding: const EdgeInsets.all(GapSizes.large),
                      child: RepaintBoundary(
                        child: InfoBar(
                          title: controller.widget.healthItem.title,
                          value: controller.widget.total,
                          formatValue: controller.widget.formatValue,
                          formatValueWithUnit: controller.widget.formatValueWithUnit,
                          unit: controller.widget.healthItem.unit,
                          goal: controller.widget.goal,
                          percent: controller.widget.getGoalPercent,
                          color: controller.widget.healthItem.color,
                          textColor: controller.widget.healthItem.offColor,
                          animateChanges: true,
                        ),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: GridLayout(
                        widgets: controller.getDetailWidgets,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
