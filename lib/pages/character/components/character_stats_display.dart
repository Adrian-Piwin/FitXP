import 'package:flutter/material.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/icons.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/components/three_d_circular_progress.dart';

class CharacterStatsDisplay extends StatelessWidget {
  final double xpRankProgressPercent;
  final double xpLevelProgressPercent;
  final String level;
  final String rank;

  const CharacterStatsDisplay({
    super.key,
    required this.xpRankProgressPercent,
    required this.xpLevelProgressPercent,
    required this.level,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Progress rings layer
        Positioned(
          top: 0,
          bottom: -280,
          left: 110,
          child: Center(
            child: Stack(
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
            ),
          ),
        ),
        
        // Text overlay layer
        Positioned(
          left: 0,
          top: 20,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LEVEL',
                  style: TextStyle(
                    fontSize: FontSizes.large,
                    fontWeight: FontWeight.w400,
                    color: CoreColors.textColor,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  level,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: FontSizes.huge,
                    height: 0.9,
                  ),
                ),
                const SizedBox(height: 40),
                _buildRankSection(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRankSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          width: 20,
          child: Center(
            child: Icon(
              IconTypes.medalIcon,
              color: CoreColors.coreGold,
              size: 35,
            ),
          ),
        ),
        const SizedBox(width: 28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rank,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: FontSizes.xlarge,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Rank',
              style: TextStyle(
                fontSize: FontSizes.medium,
                fontWeight: FontWeight.w400,
                color: CoreColors.textColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 
