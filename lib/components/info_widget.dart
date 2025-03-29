import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthcore/components/widget_frame.dart';
import 'package:healthcore/constants/sizes.constants.dart';

class InfoWidget extends WidgetFrame {
  final String title;
  final String displayValue;
  final IconData? icon;

  const InfoWidget({
    super.key,
    required this.title,
    required this.displayValue,
    this.icon,
  }) : super(
          size: 2,
          height: WidgetSizes.smallHeight,
        );

  @override
  Widget buildContent(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: FontSizes.medium,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          if (icon != null)
            FaIcon(
              icon,
              size: FontSizes.xlarge,
            ),
          const Spacer(),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: FontSizes.medium,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
    );
  }
}
