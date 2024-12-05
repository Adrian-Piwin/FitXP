import 'package:flutter/material.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/components/circular_percent_widget.dart';
import 'package:healthxp/constants/sizes.constants.dart';

class InfoPercentWidget extends WidgetFrame {
  final String title;
  final double percent;
  final String displayValue;
  final IconData icon;
  final Color color;

  const InfoPercentWidget({
    super.key,
    required this.title,
    required this.percent,
    required this.displayValue,
    required this.icon,
    required this.color,
  }) : super(
          size: 1,
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
          CircularPercentWidget(
            percent: percent,
            displayValue: displayValue,
            icon: icon,
            color: color,
            config: CircularPercentWidgetSizes.medium,
          ),
          const Spacer(),
      ],
    );
  }
}
