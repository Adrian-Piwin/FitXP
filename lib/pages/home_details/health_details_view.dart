import 'package:flutter/material.dart';
import 'package:healthxp/components/grid_layout.dart';
import 'package:healthxp/models/health_widget.model.dart';
import 'package:provider/provider.dart';
import '../../components/timeframe_tabbar.dart';
import '../../components/date_selector.dart';
import 'health_details_controller.dart';

class HealthDataDetailPage extends StatelessWidget {
  final HealthWidget widget;

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
                  return SingleChildScrollView(
                    child: GridLayout(widgets: controller.buildWidgets()),
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
