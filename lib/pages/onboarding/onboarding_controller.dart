import 'package:flutter/material.dart';
import 'package:healthcore/pages/onboarding/food_logging_page.dart';
import 'package:healthcore/pages/onboarding/fitness_goals_page.dart';
import 'package:healthcore/pages/onboarding/activity_level_page.dart';
import 'package:healthcore/pages/onboarding/body_stats_page.dart';
import 'package:healthcore/pages/permissions/permissions_view.dart';
import 'package:healthcore/services/user_service.dart';
import 'package:healthcore/services/goals_service.dart';
import 'package:healthcore/enums/health_item_type.enum.dart';
import 'package:healthcore/enums/activity_level.enum.dart';
import 'package:healthcore/enums/gender.enum.dart';
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
  late final GoalsService _goalsService;
  
  // Onboarding state
  bool? _usesFoodLoggingApp;
  ActivityLevel? _activityLevel;
  double? _weight;
  int? _age;
  bool? _isMale;
  double? _height;
  double? _bodyFat;
  bool _useMetricWeight = false;
  Map<HealthItemType, double> _goals = {};
  
  int _currentPage = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _goalsService = await GoalsService.getInstance();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }
  
  Future<void> _completeOnboarding() async {
    try {
      // Save onboarding data
      await _userService.saveOnboardingData(
        usesFoodLoggingApp: _usesFoodLoggingApp,
        activityLevel: _activityLevel,
        weight: _weight,
        age: _age,
        isMale: _isMale,
        height: _height,
        bodyFat: _bodyFat,
      );

      // Save all goals
      for (var entry in _goals.entries) {
        await _goalsService.saveGoal(entry.key.toString(), entry.value);
      }
      
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
  
  void _updateActivityLevel(ActivityLevel level) {
    setState(() {
      _activityLevel = level;
    });
  }

  void _updateBodyStats(double? weight, int? age, Gender? gender, double? height, double? bodyFat, bool useMetricWeight) {
    setState(() {
      _weight = weight;
      _age = age;
      _isMale = gender == Gender.male;
      _height = height;
      _bodyFat = bodyFat;
      _useMetricWeight = useMetricWeight;
    });
  }

  void _updateGoals(Map<HealthItemType, double> goals) {
    setState(() {
      _goals = goals;
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
            onSelectionChanged: _updateFoodLoggingSelection,
            selectedValue: _usesFoodLoggingApp,
          ),
          
          // Body Stats Page
          BodyStatsPage(
            onNext: _nextPage,
            onSelectionChanged: _updateBodyStats,
            selectedWeight: _weight,
            selectedAge: _age,
            selectedGender: _isMale == null ? null : (_isMale! ? Gender.male : Gender.female),
            selectedHeight: _height,
            selectedBodyFat: _bodyFat,
            selectedPreferredUnitSystem: _useMetricWeight,
          ),
          
          // Activity Level Page
          ActivityLevelPage(
            onNext: _nextPage,
            onSelectionChanged: _updateActivityLevel,
            selectedLevel: _activityLevel,
          ),
          
          // Fitness Goals Page
          FitnessGoalsPage(
            onNext: _nextPage,
            onSelectionChanged: _updateGoals,
            selectedGoals: _goals,
            weight: _weight ?? 0,
            age: _age ?? 0,
            isMale: _isMale ?? true,
            activityLevel: _activityLevel ?? ActivityLevel.moderatelyActive,
            height: _height ?? 0,
            bodyFat: _bodyFat,
            useMetricWeight: _useMetricWeight,
          ),
        ],
      ),
    );
  }
} 
