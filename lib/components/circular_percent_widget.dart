import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/sizes.constants.dart';
import '../constants/colors.constants.dart';
import '../constants/animations.constants.dart';
import '../models/circular_percent_config.model.dart';

class CircularPercentWidget extends StatelessWidget {
  final double percent;
  final String displayValue;
  final IconData icon;
  final Color color;
  final CircularPercentConfig config;

  const CircularPercentWidget({
    super.key,
    required this.percent,
    required this.displayValue,
    required this.icon,
    required this.color,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: config.radius,
      lineWidth: PercentIndicatorSizes.lineHeightSmall,
      percent: percent,
      center: FaIcon(
        icon,
        size: config.iconSize,
        color: color,
      ),
      progressColor: color,
      backgroundColor: PercentIndicatorColors.backgroundColor,
      animation: true,
      animationDuration: PercentIndicatorAnimations.duration,
      footer: Padding(
        padding: const EdgeInsets.only(top: PaddingSizes.small),
        child: Text(
          displayValue,
          style: TextStyle(
            fontSize: config.fontSize,
          ),
        ),
      ),
    );
  }
}
