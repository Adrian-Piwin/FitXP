import 'package:flutter/material.dart';
import '../constants/sizes.constants.dart';
import '../constants/colors.constants.dart';

abstract class WidgetFrame extends StatelessWidget {
  final int size;
  final double height;

  const WidgetFrame({
    super.key,
    required this.size,
    required this.height,
  });

  // Abstract child widget to be implemented by subclasses
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // Ensure gestures pass through
      child: Container(
        decoration: BoxDecoration(
          color: WidgetColors.primaryColor,
          borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
        ),
        padding: const EdgeInsets.all(PaddingSizes.large),
        child: buildContent(context), // Render content from subclasses
      ),
    );
  }
}
