import 'package:flutter/material.dart';
import 'package:healthcore/components/widget_frame.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class SleepInfoWidget extends WidgetFrame {
  final Map<String, Map<String, dynamic>> sleepStages;

  const SleepInfoWidget({
    super.key,
    required this.sleepStages,
  }) : super(
          size: 4,
          height: WidgetSizes.mediumHeight,
          padding: GapSizes.small,
        );

  @override
  Widget buildContent(BuildContext context) {
    // Calculate stop positions for gradient
    final remPercent = sleepStages['rem']!['percentage'] / 100;
    final deepPercent = sleepStages['deep']!['percentage'] / 100;
    final lightPercent = sleepStages['light']!['percentage'] / 100;
    final awakePercent = sleepStages['awake']!['percentage'] / 100;
    
    final totalPercent = remPercent + deepPercent + lightPercent + awakePercent;
    final hasGap = totalPercent < 1.0;
    
    final remStop = remPercent;
    final deepStop = remStop + deepPercent;
    final lightStop = deepStop + lightPercent;
    final awakeStop = lightStop + awakePercent;

    return Column(
      children: [
        const SizedBox(height: GapSizes.large),
        Text(
          "Sleep Stages",
          style: const TextStyle(
            fontSize: FontSizes.large,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: GapSizes.large),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 8,
            percent: 1.0,
            backgroundColor: Colors.grey.withOpacity(0.3),
            linearGradient: LinearGradient(
              stops: [
                0.0,
                remStop,
                remStop,
                deepStop,
                deepStop,
                lightStop,
                lightStop,
                awakeStop,
                if (hasGap) awakeStop,
                if (hasGap) 1.0,
              ],
              colors: [
                RepresentationColors.sleepRemColor,
                RepresentationColors.sleepRemColor,
                RepresentationColors.sleepDeepColor,
                RepresentationColors.sleepDeepColor,
                RepresentationColors.sleepLightColor,
                RepresentationColors.sleepLightColor,
                RepresentationColors.sleepAwakeColor,
                RepresentationColors.sleepAwakeColor,
                if (hasGap) Colors.transparent,
                if (hasGap) Colors.transparent,
              ],
            ),
            barRadius: const Radius.circular(4),
          ),
        ),
        const SizedBox(height: GapSizes.large),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSleepStageInfo(
              'REM',
              sleepStages['rem']!['duration'],
              sleepStages['rem']!['percentage'],
              RepresentationColors.sleepRemColor,
            ),
            _buildSleepStageInfo(
              'Deep',
              sleepStages['deep']!['duration'],
              sleepStages['deep']!['percentage'],
              RepresentationColors.sleepDeepColor,
            ),
            _buildSleepStageInfo(
              'Core',
              sleepStages['light']!['duration'],
              sleepStages['light']!['percentage'],
              RepresentationColors.sleepLightColor,
            ),
            _buildSleepStageInfo(
              'Awake',
              sleepStages['awake']!['duration'],
              sleepStages['awake']!['percentage'],
              RepresentationColors.sleepAwakeColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSleepStageInfo(
    String label,
    String duration,
    double percentage,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: FontSizes.small,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          duration,
          style: const TextStyle(
            fontSize: FontSizes.small,
          ),
        ),
        Text(
          "${percentage.toStringAsFixed(0)}%",
          style: const TextStyle(
            fontSize: FontSizes.small,
          ),
        ),
      ],
    );
  }
} 
