import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/pages/onboarding/onboarding_base_page.dart';
import 'package:healthcore/services/user_service.dart';

class FitnessGoalsPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function(FitnessGoal) onSelectionChanged;
  final FitnessGoal? selectedGoal;

  const FitnessGoalsPage({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onSelectionChanged,
    this.selectedGoal,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingBasePage(
      title: 'What is your fitness goal?',
      subtitle: 'The insights we provide will help reach your fitness goals',
      onNext: selectedGoal != null ? onNext : () {}, // Only enable if a selection is made
      onSkip: onSkip,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gain weight
          _buildGoalCard(
            context: context,
            icon: Icons.trending_up,
            title: 'Gain Weight',
            subtitle: 'Build muscle and increase body weight',
            isSelected: selectedGoal == FitnessGoal.gainWeight,
            onTap: () => onSelectionChanged(FitnessGoal.gainWeight),
          ),
          
          const SizedBox(height: PaddingSizes.large),
          
          // Maintain weight
          _buildGoalCard(
            context: context,
            icon: Icons.balance,
            title: 'Maintain Weight',
            subtitle: 'Keep your current weight and improve fitness',
            isSelected: selectedGoal == FitnessGoal.maintainWeight,
            onTap: () => onSelectionChanged(FitnessGoal.maintainWeight),
          ),
          
          const SizedBox(height: PaddingSizes.large),
          
          // Lose weight
          _buildGoalCard(
            context: context,
            icon: Icons.trending_down,
            title: 'Lose Weight',
            subtitle: 'Reduce body fat and improve body composition',
            isSelected: selectedGoal == FitnessGoal.loseWeight,
            onTap: () => onSelectionChanged(FitnessGoal.loseWeight),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGoalCard({
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
