import 'package:xpfitness/components/timeframe_tabbar.dart';
import 'package:xpfitness/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/bottom_nav_bar.dart';
import 'header_widget_item.dart';
import '../../components/grid_layout.dart';
import 'home_controller.dart';
import '../../components/date_selector.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const routeName = "/home";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(context),
      child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Consumer<HomeController>(
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
          body: Consumer<HomeController>(
            builder: (context, controller, _) {
              return Column(
                children: [
                  DateSelector(
                    selectedTimeFrame: controller.selectedTimeFrame,
                    offset: controller.offset,
                    onOffsetChanged: (newOffset) {
                      controller.updateOffset(newOffset);
                    },
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.refresh,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (controller.headerWidgets.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(GapSizes.medium, GapSizes.medium, GapSizes.medium, 0),
                                child: HeaderWidgetItem(
                                  barWidgetConfig: controller.headerWidgets[0].getConfig,
                                  subWidgetFirstConfig: controller.headerWidgets[1].getConfig,
                                  subWidgetSecondConfig: controller.headerWidgets[2].getConfig,
                                  subWidgetThirdConfig: controller.headerWidgets[3].getConfig,
                                ),
                              ),
                            GridLayout(widgets: controller.displayWidgets.map((obj) => obj.generateWidget()).toList()),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
          bottomNavigationBar: const BottomNavBar(currentIndex: 0)),
    );
  }
}
