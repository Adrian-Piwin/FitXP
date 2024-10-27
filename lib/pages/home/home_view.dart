import 'package:fitxp/components/timeframe_tabbar.dart';
import 'package:fitxp/pages/home/basic_widget_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/bottom_nav_bar.dart';
import 'calorie_widget_item.dart';
import '../../components/grid_layout.dart';
import 'large_widget_item.dart';
import 'small_widget_item.dart';
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
                "size": 2,
                "widget": controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CalorieWidgetItem(
                        activeCalories: controller.activeCalories,
                        restingCalories: controller.restingCalories,
                        dietaryCalories: controller.dietaryCalories,
                      ),
              },
              {
                "size": 1,
                "widget": BasicWidgetItem(
                  title: AppLocalizations.of(context)!.proteinWidgetTitle,
                  value: "${controller.protein.toStringAsFixed(0)}g",
                ),
              },
              {"size": 1, "widget": SmallWidgetItem(title: "Widget 1x1")},
              {
                "size": 2,
                "widget": LargeWidgetItem(title: "Another 1x2 Widget")
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
                  child: GridLayout(widgets: widgets),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0)
      ),
    );
  }
}
