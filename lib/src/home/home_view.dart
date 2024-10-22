import "package:flutter/material.dart";
import "../../components/grid_layout.dart";
import "large_widget_item.dart";
import "small_widget_item.dart";

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const routeName = "/";

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> widgets = [
      {"size": 1, "widget": SmallWidgetItem(title: "Widget 1x1")},
      {"size": 1, "widget": SmallWidgetItem(title: "Widget 1x1")},
      {"size": 2, "widget": LargeWidgetItem(title: "Another 1x2 Widget")},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: GridLayout(widgets: widgets),
    );
  }
}
