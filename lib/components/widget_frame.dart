import 'package:flutter/material.dart';
import '../constants/sizes.constants.dart';
import '../constants/colors.constants.dart';

abstract class WidgetFrame extends StatelessWidget {
  final int size;
  final double height;
  final Color? color;

  const WidgetFrame({
    super.key,
    required this.size,
    required this.height,
    this.color,
  });

  // Abstract child widget to be implemented by subclasses
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // Ensure gestures pass through
      child: Container(
        decoration: BoxDecoration(
          gradient: GradientColors.widgetBackgroundGradient,
          borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
          boxShadow: [
            BoxShadow(
              offset: const Offset(2, 2),  // x:2, y:2
              blurRadius: 4,               // blur: 4
              spreadRadius: 0,             // spread: 0
              color: Colors.black.withOpacity(0.1),  // black at 10% opacity
            ),
          ],
        ),
        padding: const EdgeInsets.all(PaddingSizes.large),
        child: buildContent(context), // Render content from subclasses
      ),
    );
  }
}
