import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthcore/components/widget_frame.dart';
import 'package:healthcore/constants/sizes.constants.dart';

class IconInfoWidget extends WidgetFrame {
  final String title;
  final String displayValue;
  final IconData icon;
  final Color iconColor;

  const IconInfoWidget({
    super.key,
    required this.title,
    required this.displayValue,
    required this.icon,
    required this.iconColor,
  }) : super(
          size: 2,
          height: WidgetSizes.mediumHeight,
          padding: GapSizes.small,
        );

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: GapSizes.large),
        Text(
          title,
          style: const TextStyle(
            fontSize: FontSizes.large,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: GapSizes.large),
        FaIcon(
          icon,
          size: FontSizes.xxxlarge,
          color: iconColor,
        ),
        const SizedBox(height: GapSizes.large),
        Text(
          displayValue,
          style: const TextStyle(
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
