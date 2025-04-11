import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/pages/onboarding/onboarding_base_page.dart';

class FoodLoggingPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final Function(bool) onSelectionChanged;
  final bool? selectedValue;

  const FoodLoggingPage({
    super.key,
    required this.onNext,
    required this.onSkip,
    required this.onSelectionChanged,
    this.selectedValue,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingBasePage(
      title: 'Do you use a food logging app?',
      subtitle: 'We can sync with your nutrition data to provide better insights',
      onNext: selectedValue != null ? onNext : () {}, // Only enable if a selection is made
      onSkip: onSkip,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Yes option
          _buildOptionCard(
            context: context,
            icon: Icons.check_circle_outline,
            title: 'Yes',
            isSelected: selectedValue == true,
            onTap: () => onSelectionChanged(true),
          ),
          
          const SizedBox(height: PaddingSizes.xlarge),
          
          // No option
          _buildOptionCard(
            context: context,
            icon: Icons.cancel_outlined,
            title: 'No',
            isSelected: selectedValue == false,
            onTap: () => onSelectionChanged(false),
          ),
          
          // Hint text for "Yes" selection
          if (selectedValue == true) ...[
            const SizedBox(height: PaddingSizes.xlarge),
            Container(
              padding: const EdgeInsets.all(PaddingSizes.large),
              decoration: BoxDecoration(
                color: CoreColors.coreOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                border: Border.all(
                  color: CoreColors.coreOrange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: CoreColors.coreOrange,
                    size: IconSizes.medium,
                  ),
                  const SizedBox(width: GapSizes.medium),
                  Expanded(
                    child: Text(
                      'Make sure your food logging app syncs with Apple Health to ensure your data will be shown.',
                      style: TextStyle(
                        color: CoreColors.textColor,
                        fontSize: FontSizes.small,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
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
            Icon(
              icon,
              color: isSelected ? CoreColors.coreOrange : CoreColors.textColor.withOpacity(0.6),
              size: IconSizes.large,
            ),
            const SizedBox(width: GapSizes.large),
            Text(
              title,
              style: TextStyle(
                color: CoreColors.textColor,
                fontSize: 18,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
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
