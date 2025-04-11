import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/pages/onboarding/onboarding_base_page.dart';
import 'package:healthcore/services/user_service.dart';

class ActivityLevelPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function(ActivityLevel) onSelectionChanged;
  final ActivityLevel? selectedLevel;
  final bool isLastPage;

  const ActivityLevelPage({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onSelectionChanged,
    this.selectedLevel,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingBasePage(
      title: 'How active are you weekly?',
      subtitle: 'We sync with your fitness data to provide better understanding of your activity level',
      onNext: selectedLevel != null ? onNext : () {}, // Only enable if a selection is made
      onSkip: onSkip,
      isLastPage: isLastPage,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // None (0 hours)
          _buildActivityCard(
            context: context,
            icon: Icons.weekend,
            title: 'Not Active',
            subtitle: '0 hours per week',
            isSelected: selectedLevel == ActivityLevel.none,
            onTap: () => onSelectionChanged(ActivityLevel.none),
          ),
          
          const SizedBox(height: PaddingSizes.large),
          
          // Light (1-2 hours)
          _buildActivityCard(
            context: context,
            icon: Icons.directions_walk,
            title: 'Light Activity',
            subtitle: '1-2 hours per week',
            isSelected: selectedLevel == ActivityLevel.light,
            onTap: () => onSelectionChanged(ActivityLevel.light),
          ),
          
          const SizedBox(height: PaddingSizes.large),
          
          // Moderate (3-4 hours)
          _buildActivityCard(
            context: context,
            icon: Icons.hiking,
            title: 'Moderate Activity',
            subtitle: '3-4 hours per week',
            isSelected: selectedLevel == ActivityLevel.moderate,
            onTap: () => onSelectionChanged(ActivityLevel.moderate),
          ),
          
          const SizedBox(height: PaddingSizes.large),
          
          // Active (5-6 hours)
          _buildActivityCard(
            context: context,
            icon: Icons.directions_run,
            title: 'Active',
            subtitle: '5-6 hours per week',
            isSelected: selectedLevel == ActivityLevel.active,
            onTap: () => onSelectionChanged(ActivityLevel.active),
          ),
          
          const SizedBox(height: PaddingSizes.large),
          
          // Very Active (7+ hours)
          _buildActivityCard(
            context: context,
            icon: Icons.fitness_center,
            title: 'Very Active',
            subtitle: '7+ hours per week',
            isSelected: selectedLevel == ActivityLevel.veryActive,
            onTap: () => onSelectionChanged(ActivityLevel.veryActive),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityCard({
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
