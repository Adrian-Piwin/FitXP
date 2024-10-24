import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'calorie_widget_item.dart';
import '../../components/grid_layout.dart';
import 'large_widget_item.dart';
import 'small_widget_item.dart';
import 'home_controller.dart'; 
import '../../components/timeframe_dropdown.dart'; 

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const routeName = "/home";

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Home")),
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
              {"size": 1, "widget": SmallWidgetItem(title: "Widget 1x1")},
              {"size": 1, "widget": SmallWidgetItem(title: "Widget 1x1")},
              {"size": 2, "widget": LargeWidgetItem(title: "Another 1x2 Widget")},
            ];

            return Column(
              children: [
                // TimeFrameDropdown component
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TimeFrameDropdown(
                    selectedTimeFrame: controller.selectedTimeFrame,
                    onChanged: (newTimeFrame) {
                      controller.updateTimeFrame(newTimeFrame);
                    },
                  ),
                ),
                // Expanded GridLayout
                Expanded(
                  child: GridLayout(widgets: widgets),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
