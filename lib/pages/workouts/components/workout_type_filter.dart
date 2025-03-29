import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/constants/workout_definitions.constants.dart';

class WorkoutTypeFilter extends StatelessWidget {
  final Set<String> availableTypes;
  final Set<String> selectedTypes;
  final Function(String) onToggleType;

  const WorkoutTypeFilter({
    super.key,
    required this.availableTypes,
    required this.selectedTypes,
    required this.onToggleType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PaddingSizes.large,
        vertical: 0
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout type chips
            Wrap(
              spacing: GapSizes.medium,
              runSpacing: 0,
              children: availableTypes.map((type) {
                final isSelected = selectedTypes.contains(type);
                return FilterChip(
                  selected: isSelected,
                  label: Text(
                    WorkoutDefinitions.getWorkoutName(type),
                    style: TextStyle(
                      fontSize: FontSizes.small,
                      color: isSelected ? Colors.white : CoreColors.textColor,
                    ),
                  ),
                  avatar: FaIcon(
                    WorkoutDefinitions.getWorkoutIcon(type),
                    size: IconSizes.xsmall,
                    color: isSelected ? Colors.white : CoreColors.coreOrange,
                  ),
                  backgroundColor: CoreColors.backgroundColor,
                  selectedColor: CoreColors.coreOrange,
                  onSelected: (_) => onToggleType(type),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: PaddingSizes.small,
                    vertical: PaddingSizes.small,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 
