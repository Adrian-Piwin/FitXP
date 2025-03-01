import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/constants/workout_definitions.constants.dart';
import 'package:healthxp/models/data_points/workout_data_point.model.dart';
import 'package:healthxp/utility/general.utility.dart';
import 'package:intl/intl.dart';

class WorkoutListItem extends StatelessWidget {
  final WorkoutDataPoint workout;

  const WorkoutListItem({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PaddingSizes.medium),
      decoration: BoxDecoration(
        color: CoreColors.foregroundColor,
        borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
      ),
      child: Row(
        children: [
          // Workout Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CoreColors.backgroundColor,
              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
            ),
            child: Center(
              child: FaIcon(
                WorkoutDefinitions.getWorkoutIcon(workout.workoutType ?? ''),
                color: CoreColors.coreOrange,
                size: IconSizes.medium,
              ),
            ),
          ),
          const SizedBox(width: GapSizes.medium),
          // Workout Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WorkoutDefinitions.getWorkoutName(workout.workoutType ?? 'OTHER'),
                  style: const TextStyle(
                    fontSize: FontSizes.medium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: GapSizes.small),
                Row(
                  children: [
                    Text(
                      formatDuration(workout.value),
                      style: const TextStyle(
                        color: CoreColors.coreOffGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: GapSizes.medium),
                    Text(
                      '${workout.energyBurned?.round() ?? 0} cal',
                      style: const TextStyle(
                        color: CoreColors.coreOffOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Date and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('MMM d').format(workout.dateFrom),
                style: const TextStyle(
                  fontSize: FontSizes.small,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${DateFormat('h:mm a').format(workout.dateFrom)} - ${DateFormat('h:mm a').format(workout.dateTo)}',
                style: TextStyle(
                  fontSize: FontSizes.xsmall,
                  color: CoreColors.textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 
