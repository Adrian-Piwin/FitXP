import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class CharacterProgressBar extends StatelessWidget {
  final String leftText;
  final String rightText;
  final Color progressColor;
  final Color backgroundColor;
  final double progress;
  final double textSize;
  
  const CharacterProgressBar({
    required this.leftText,
    required this.rightText,
    required this.progressColor,
    required this.backgroundColor,
    required this.progress,
    this.textSize = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(leftText, style: TextStyle(fontSize: textSize)),
            Text(rightText, style: TextStyle(fontSize: textSize)),
          ],
        ),
        const SizedBox(height: 10),
        LinearPercentIndicator(
          lineHeight: 20.0,
          percent: progress,
          backgroundColor: backgroundColor,
          progressColor: progressColor,
          barRadius: const Radius.circular(10),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
} 
