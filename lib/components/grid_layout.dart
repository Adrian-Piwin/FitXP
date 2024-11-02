import 'package:fitxp/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GridLayout extends StatelessWidget {
  final List<Map<String, dynamic>> widgets;

  const GridLayout({
    super.key,
    required this.widgets,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StaggeredGrid.count(
        crossAxisCount: 2, // 2 columns
        mainAxisSpacing: GapSizes.medium,
        crossAxisSpacing: GapSizes.medium,
        children: widgets.map((widgetInfo) {
          final size = widgetInfo['size'] as int;
          final widget = widgetInfo['widget'] as Widget;
      
          return StaggeredGridTile.extent(
            crossAxisCellCount: size == 2 ? 2 : 1, // Spans 2 columns if size == 2
            mainAxisExtent: WidgetSizes.height, 
            child: widget,
          );
        }).toList(),
      ),
    );
  }
}
