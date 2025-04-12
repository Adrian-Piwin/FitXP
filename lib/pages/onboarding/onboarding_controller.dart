import 'package:flutter/material.dart';
import 'package:healthcore/pages/onboarding/food_logging_page.dart';
import 'package:healthcore/pages/onboarding/fitness_goals_page.dart';
import 'package:healthcore/pages/onboarding/activity_level_page.dart';
import 'package:healthcore/pages/permissions/permissions_view.dart';
import 'package:healthcore/services/user_service.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';

class OnboardingController extends StatefulWidget {
  const OnboardingController({super.key});

  static const routeName = '/onboarding';

  @override
  State<OnboardingController> createState() => _OnboardingControllerState();
}

class _OnboardingControllerState extends State<OnboardingController> {
  final PageController _pageController = PageController();
  final UserService _userService = UserService();
  
  // Onboarding state
  bool? _usesFoodLoggingApp;
  FitnessGoal? _fitnessGoal;
  ActivityLevel? _activityLevel;
  
  int _currentPage = 0;
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  // Skip current page and move to next page or complete onboarding
  void _skipCurrentPage() {
    if (_currentPage < 2) {
      // Skip to next page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // On last page, complete the onboarding with whatever data user has selected
      _completeOnboarding();
    }
  }
  
  Future<void> _completeOnboarding() async {
    try {
      // Only save selections that were explicitly made by the user
      await _userService.saveOnboardingData(
        usesFoodLoggingApp: _usesFoodLoggingApp,
        fitnessGoal: _fitnessGoal,
        activityLevel: _activityLevel,
      );
      
      if (mounted) {
        Superwall.shared.registerPlacement('CompleteOnboarding', feature: () {
            Navigator.of(context).pushReplacementNamed(PermissionsView.routeName);
        });
      }
    } catch (e) {
      // Show error dialog if saving fails
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to save your preferences. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
  
  void _updateFoodLoggingSelection(bool value) {
    setState(() {
      _usesFoodLoggingApp = value;
    });
  }
  
  void _updateFitnessGoal(FitnessGoal goal) {
    setState(() {
      _fitnessGoal = goal;
    });
  }
  
  void _updateActivityLevel(ActivityLevel level) {
    setState(() {
      _activityLevel = level;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevent swiping
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          // Food Logging Page
          FoodLoggingPage(
            onNext: _nextPage,
            onSkip: _skipCurrentPage,
            onSelectionChanged: _updateFoodLoggingSelection,
            selectedValue: _usesFoodLoggingApp,
          ),
          
          // Fitness Goals Page
          FitnessGoalsPage(
            onNext: _nextPage,
            onSkip: _skipCurrentPage,
            onSelectionChanged: _updateFitnessGoal,
            selectedGoal: _fitnessGoal,
          ),
          
          // Activity Level Page
          ActivityLevelPage(
            onNext: _nextPage,
            onSkip: _skipCurrentPage, // Now using _skipCurrentPage for the last page too
            onSelectionChanged: _updateActivityLevel,
            selectedLevel: _activityLevel,
            isLastPage: true,
          ),
        ],
      ),
    );
  }
} 
