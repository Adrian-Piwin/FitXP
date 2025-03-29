import 'package:healthcore/components/widget_frame.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class GridLayout extends StatelessWidget {
  final List<Widget> widgets;

  const GridLayout({
    super.key,
    required this.widgets,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GapSizes.large),
      child: StaggeredGrid.count(
        crossAxisCount: 6, // 6 columns
        mainAxisSpacing: GapSizes.medium,
        crossAxisSpacing: GapSizes.medium,
        children: widgets.map((widget) {
          final size = (widget as WidgetFrame).size;
          final height = (widget).height;
          return StaggeredGridTile.extent(
            crossAxisCellCount: size,
            mainAxisExtent: height, 
            child: widget
          );
        }).toList(),
      ),
    );
  }
}
