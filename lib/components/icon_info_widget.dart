import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/sizes.constants.dart';

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
        );

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: FontSizes.large,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: GapSizes.large),
        FaIcon(
          icon,
          size: FontSizes.xxxxlarge,
          color: iconColor,
        ),
        const SizedBox(height: GapSizes.medium),
        Text(
          displayValue,
          style: const TextStyle(
            fontSize: FontSizes.medium,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
