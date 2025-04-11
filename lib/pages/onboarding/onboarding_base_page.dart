import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';

/// Base class for all onboarding pages with shared layout and styling
class OnboardingBasePage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLastPage;
  
  const OnboardingBasePage({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
    required this.onNext,
    required this.onSkip,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CoreColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(PaddingSizes.xlarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with spacing to allow for the skip button
                  const SizedBox(height: PaddingSizes.xlarge * 2),
                  
                  // Title and subtitle
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: CoreColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: PaddingSizes.medium),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 16,
                        color: CoreColors.textColor.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  const SizedBox(height: PaddingSizes.xxlarge),
                  
                  // Page-specific content
                  Expanded(
                    child: content,
                  ),
                  
                  // Next button
                  ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CoreColors.coreOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: PaddingSizes.large),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                      ),
                    ),
                    child: Text(
                      isLastPage ? 'Get Started' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: CoreColors.textColor,
                      ),
                    ),
                  ),

                  // Skip button
                  ElevatedButton(
                    onPressed: onSkip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CoreColors.accentAltColor,
                      foregroundColor: CoreColors.textColor,
                      padding: const EdgeInsets.symmetric(vertical: PaddingSizes.large),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
