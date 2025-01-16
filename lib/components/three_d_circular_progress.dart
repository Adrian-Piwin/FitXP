import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ThreeDCircularProgress extends StatelessWidget {
  final double progress; // 0-100
  final double radius;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  const ThreeDCircularProgress({
    super.key,
    required this.progress,
    this.radius = 100.0,
    this.color = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.strokeWidth = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(2, 2, 0.0008)
        ..rotateX(1),
      alignment: Alignment.center,
      child: Container(
        width: radius * 2.2,
        height: radius * 2.2,
        color: Colors.transparent,
        child: CircularPercentIndicator(
          radius: radius,
          lineWidth: strokeWidth,
          percent: progress / 100,
          backgroundColor: backgroundColor,
          progressColor: color,
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 1000,
          center: Container(),
          startAngle: 135,
          arcType: ArcType.FULL_REVERSED,
          arcBackgroundColor: backgroundColor.withOpacity(0.3),
        ),
      ),
    );
  }
} 
