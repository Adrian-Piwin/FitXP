import 'package:flutter/material.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/sizes.constants.dart';

class InfoWidget extends StatelessWidget {
  final String title;
  final String displayValue;

  const InfoWidget({
    super.key,
    required this.title,
    required this.displayValue,
  });

  @override
  Widget build(BuildContext context) {
    return WidgetFrame(
      child: Column(
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
              fontSize: FontSizes.xxlarge,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
