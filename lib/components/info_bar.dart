import 'package:flutter/material.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class InfoBar extends StatelessWidget {
  final String title;
  final String value;
  final String goal;
  final double percent;
  final Color color;
  final Color textColor;
  final bool animateChanges;

  const InfoBar({
    super.key,
    required this.title,
    required this.value,
    required this.goal,
    required this.percent,
    required this.color,
    required this.textColor,
    this.animateChanges = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: FontSizes.xlarge,
                    fontWeight: FontWeight.w700
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: const TextStyle(
                          fontSize: FontSizes.large,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      TextSpan(
                        text: '/$goal',
                        style: TextStyle(
                          fontSize: FontSizes.large,
                          color: textColor,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: GapSizes.medium),
            LinearPercentIndicator(
              padding: EdgeInsets.zero,
              lineHeight: PercentIndicatorSizes.lineHeightLarge,
              percent: percent.clamp(0.0, 1.0),
              backgroundColor: color.withOpacity(0.2),
              progressColor: color,
              barRadius: const Radius.circular(PercentIndicatorSizes.barRadius),
              animation: false,
              curve: Curves.easeInOut,
            )
          ],
      )
  );
  }
}
