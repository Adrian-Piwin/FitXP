import 'package:fitxp/components/timeframe_tabbar.dart';
import 'package:fitxp/constants/sizes.constants.dart';
import 'package:fitxp/pages/home/basic_widget_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/bottom_nav_bar.dart';
import 'header_widget_item.dart';
import '../../components/grid_layout.dart';
import 'home_controller.dart';
import '../../components/date_selector.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const routeName = "/home";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
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
                {
                  "size": 1,
                  "widget": BasicWidgetItem(
                    title: AppLocalizations.of(context)!.proteinWidgetTitle,
                    value: "${controller.protein.toStringAsFixed(0)}g",
                  ),
                },
                {
                  "size": 1,
                  "widget": BasicWidgetItem(
                    title: AppLocalizations.of(context)!
                        .exerciseMinutesWidgetTitle,
                    value:
                        "${controller.exerciseMinutes.toStringAsFixed(0)}min",
                  ),
                },
                {
                  "size": 1,
                  "widget": BasicWidgetItem(
                    title: AppLocalizations.of(context)!.stepsWidgetTitle,
                    value: controller.exerciseMinutes.toStringAsFixed(0),
                  ),
                },
                {
                  "size": 1,
                  "widget": BasicWidgetItem(
                    title: "Strength Training Minutes",
                    value:
                        controller.strengthTrainingMinutes.toStringAsFixed(0),
                  ),
                },
                {
                  "size": 1,
                  "widget": BasicWidgetItem(
                    title: "Cardio Minutes",
                    value: controller.cardioMinutes.toStringAsFixed(0),
                  ),
                },
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
                              activeCalories: controller.activeCalories,
                              restingCalories: controller.restingCalories,
                              dietaryCalories: controller.dietaryCalories,
                              steps: controller.steps,
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
