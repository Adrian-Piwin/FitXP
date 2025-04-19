import 'package:flutter/material.dart';
import 'package:healthcore/components/widget_frame.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class NetCaloriesProgressWidget extends WidgetFrame {
  final double currentNetCalories;
  final double projectedNetCalories;
  final String? unit;

  const NetCaloriesProgressWidget({
    super.key,
    required this.currentNetCalories,
    required this.projectedNetCalories,
    this.unit = 'cal',
  }) : super(
          size: 6,
          height: 130,
        );

  @override
  Widget buildContent(BuildContext context) {
    // Calculate progress percentage (clamped between 0 and 1)
    final progress = currentNetCalories / projectedNetCalories;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(PaddingSizes.medium, PaddingSizes.medium, PaddingSizes.medium, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current value with icon
              _buildStatRow(
                'Current',
                currentNetCalories.toInt(),
                projectedNetCalories < 0 ? FontAwesomeIcons.arrowTrendDown : FontAwesomeIcons.arrowTrendUp,
              ),
              const SizedBox(height: GapSizes.medium),
              
              // Projected value with icon
              _buildStatRow(
                'Projected',
                projectedNetCalories.toInt(),
                projectedNetCalories < 0 ? FontAwesomeIcons.fire : FontAwesomeIcons.utensils,
              ),
              const SizedBox(height: GapSizes.xlarge),
              
              // Progress bar
              LinearPercentIndicator(
                padding: EdgeInsets.zero,
                lineHeight: PercentIndicatorSizes.lineHeightMedium2,
                percent: clampedProgress,
                backgroundColor: CoreColors.coreOffLightGrey,
                progressColor: CoreColors.coreLightGrey,
                barRadius: const Radius.circular(BorderRadiusSizes.small),
                animation: true,
                animationDuration: 1000,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value, IconData icon) {
    return Row(
      children: [
        SizedBox(
          width: 20, // Fixed width for icons to ensure alignment
          child: FaIcon(
            icon,
            size: 16,
            color: CoreColors.textColor,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: FontSizes.medium,
            color: CoreColors.textColor,
          ),
        ),
        Text(
          '$value${unit ?? ''}',
          style: const TextStyle(
            fontSize: FontSizes.medium,
            fontWeight: FontWeight.bold,
            color: CoreColors.textColor,
          ),
        ),
      ],
    );
  }
} 
