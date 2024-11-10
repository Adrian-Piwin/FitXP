import 'package:fitxp/components/timeframe_tabbar.dart';
import 'package:fitxp/constants/sizes.constants.dart';
import 'package:fitxp/enums/health_item.enum.dart';
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
              // Build the list of widgets to pass to GridLayout
              final List<Map<String, dynamic>> widgets = [
                controller.healthWidgetBuilderService.generateWidget(controller.goals, controller.healthData, HealthItem.proteinIntake),
                controller.healthWidgetBuilderService.generateWidget(controller.goals, controller.healthData, HealthItem.exerciseTime),
                controller.healthWidgetBuilderService.generateWidget(controller.goals, controller.healthData, HealthItem.sleepDuration),
              ];

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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(GapSizes.medium, GapSizes.medium, GapSizes.medium, 0),
                            child: HeaderWidgetItem(
                              activeCalories: controller.healthData.getActiveCalories,
                              restingCalories: controller.healthData.getRestingCalories,
                              dietaryCalories: controller.healthData.getDietaryCalories,
                              steps: controller.healthData.getSteps,
                              goals: controller.goals,
                            ),
                          ),
                          GridLayout(widgets: widgets),
                        ],
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
