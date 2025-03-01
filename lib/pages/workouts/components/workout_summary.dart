import 'package:flutter/material.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/utility/general.utility.dart';

class WorkoutSummary extends StatelessWidget {
  final int workoutCount;
  final double totalDuration;
  final double totalCalories;

  const WorkoutSummary({
    super.key,
    required this.workoutCount,
    required this.totalDuration,
    required this.totalCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PaddingSizes.large),
      decoration: BoxDecoration(
        color: CoreColors.foregroundColor,
        borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryItem(
            '${workoutCount}x',
            'Workouts',
            CoreColors.textColor,
          ),
          _buildSummaryItem(
            formatDuration(totalDuration),
            'Total Time',
            CoreColors.coreOffGreen,
          ),
          _buildSummaryItem(
            '${totalCalories.round()}',
            'Calories',
            CoreColors.coreOffOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: FontSizes.large,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: FontSizes.small,
            color: CoreColors.textColor,
          ),
        ),
      ],
    );
  }
} 
