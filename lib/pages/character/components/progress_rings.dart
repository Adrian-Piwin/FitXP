import 'package:flutter/material.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/components/three_d_circular_progress.dart';

class ProgressRings extends StatelessWidget {
  final double xpRankProgressPercent;
  final double xpLevelProgressPercent;

  const ProgressRings({
    super.key,
    required this.xpRankProgressPercent,
    required this.xpLevelProgressPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ThreeDCircularProgress(
          progress: xpRankProgressPercent * 100,
          radius: 100,
          color: CoreColors.coreGold,
          backgroundColor: CoreColors.coreGold.withOpacity(0.3),
          strokeWidth: 14,
        ),
        ThreeDCircularProgress(
          progress: xpLevelProgressPercent * 100,
          radius: 120,
          color: CoreColors.coreBlue,
          backgroundColor: CoreColors.coreBlue.withOpacity(0.3),
          strokeWidth: 14,
        ),
      ],
    );
  }
} 
