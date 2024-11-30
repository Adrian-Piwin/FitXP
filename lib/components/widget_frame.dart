import 'package:flutter/material.dart';
import '../constants/sizes.constants.dart';
import '../constants/colors.constants.dart';

class WidgetFrame extends StatelessWidget {
  final Widget child;

  const WidgetFrame({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WidgetColors.primaryColor,
        borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
      ),
      padding: const EdgeInsets.all(PaddingSizes.large),
      child: child,
    );
  }
}
