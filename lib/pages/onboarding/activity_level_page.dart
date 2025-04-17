import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/pages/onboarding/onboarding_base_page.dart';
import 'package:healthcore/enums/activity_level.enum.dart';

class ActivityLevelPage extends StatelessWidget {
  final VoidCallback onNext;
  final Function(ActivityLevel) onSelectionChanged;
  final ActivityLevel? selectedLevel;
  
  const ActivityLevelPage({
    super.key,
    required this.onNext,
    required this.onSelectionChanged,
    this.selectedLevel,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingBasePage(
      title: 'How active are you?',
      subtitle: 'This helps us calculate your daily calorie needs',
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PaddingSizes.xxxlarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sedentary
          _buildLevelCard(
            context: context,
            icon: Icons.chair,
            title: 'Sedentary',
            subtitle: 'Little or no exercise',
            isSelected: selectedLevel == ActivityLevel.sedentary,
            onTap: () => onSelectionChanged(ActivityLevel.sedentary),
          ),
          
          const SizedBox(height: PaddingSizes.large),
          
          // Lightly Active
          _buildLevelCard(
            context: context,
            icon: Icons.directions_walk,
            title: 'Lightly Active',
            subtitle: 'Light exercise/sports 1-3 days/week',
            isSelected: selectedLevel == ActivityLevel.lightlyActive,
            onTap: () => onSelectionChanged(ActivityLevel.lightlyActive),
          ),
          
          const SizedBox(height: PaddingSizes.large),
          
          // Moderately Active
          _buildLevelCard(
            context: context,
            icon: Icons.directions_run,
            title: 'Moderately Active',
            subtitle: 'Moderate exercise/sports 3-5 days/week',
            isSelected: selectedLevel == ActivityLevel.moderatelyActive,
            onTap: () => onSelectionChanged(ActivityLevel.moderatelyActive),
          ),
          
          const SizedBox(height: PaddingSizes.large),
          
          // Very Active
          _buildLevelCard(
            context: context,
            icon: Icons.fitness_center,
            title: 'Very Active',
            subtitle: 'Hard exercise/sports 6-7 days/week',
            isSelected: selectedLevel == ActivityLevel.veryActive,
            onTap: () => onSelectionChanged(ActivityLevel.veryActive),
          ),
          ],
        ),
      ),
      onNext: onNext,
      nextEnabled: selectedLevel != null,
    );
  }
  
  Widget _buildLevelCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PaddingSizes.large),
        decoration: BoxDecoration(
          color: isSelected ? CoreColors.coreOrange.withOpacity(0.1) : CoreColors.foregroundColor,
          borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
          border: Border.all(
            color: isSelected ? CoreColors.coreOrange : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: CoreColors.coreOrange.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(PaddingSizes.medium),
              decoration: BoxDecoration(
                color: isSelected 
                    ? CoreColors.coreOrange.withOpacity(0.2) 
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? CoreColors.coreOrange : CoreColors.textColor.withOpacity(0.6),
                size: IconSizes.medium,
              ),
            ),
            const SizedBox(width: GapSizes.large),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: CoreColors.textColor,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: GapSizes.small),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: CoreColors.textColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: CoreColors.coreOrange,
                size: IconSizes.medium,
              ),
          ],
        ),
      ),
    );
  }
} 
