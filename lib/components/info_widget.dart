import 'package:flutter/material.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/sizes.constants.dart';

class InfoWidget extends WidgetFrame {
  final String title;
  final String displayValue;

  const InfoWidget({
    super.key,
    required this.title,
    required this.displayValue,
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
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: FontSizes.large,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
    );
  }
}
