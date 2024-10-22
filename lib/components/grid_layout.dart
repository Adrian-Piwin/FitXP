import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GridLayout extends StatelessWidget {
  final List<Map<String, dynamic>> widgets;

  const GridLayout({
    Key? key,
    required this.widgets,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StaggeredGrid.count(
        crossAxisCount: 2, // 2 columns
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: widgets.map((widgetInfo) {
          final size = widgetInfo['size'] as int;
          final widget = widgetInfo['widget'] as Widget;
      
          // Set desired heights
          final double height = size == 2 ? 150 : 150; // Same height for both
      
          return StaggeredGridTile.extent(
            crossAxisCellCount: size == 2 ? 2 : 1, // Spans 2 columns if size == 2
            mainAxisExtent: height, // Fixed height
            child: widget,
          );
        }).toList(),
      ),
    );
  }
}
