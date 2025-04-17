import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/enums/activity_level.enum.dart';
import 'package:healthcore/enums/health_item_type.enum.dart';
import 'package:healthcore/pages/onboarding/onboarding_base_page.dart';
import 'package:healthcore/services/goals_service.dart';
import 'package:healthcore/constants/health_item_definitions.constants.dart';

class FitnessGoalsPage extends StatefulWidget {
  final VoidCallback onNext;
  final Function(Map<HealthItemType, double> goals) onSelectionChanged;
  final Map<HealthItemType, double>? selectedGoals;
  final double weight;
  final int age;
  final bool isMale;
  final ActivityLevel activityLevel;
  final double height; // Height in cm
  final double? bodyFat; // Optional body fat percentage

  const FitnessGoalsPage({
    super.key,
    required this.onNext,
    required this.onSelectionChanged,
    required this.weight,
    required this.age,
    required this.isMale,
    required this.activityLevel,
    required this.height,
    this.bodyFat,
    this.selectedGoals,
  });

  @override
  State<FitnessGoalsPage> createState() => _FitnessGoalsPageState();
}

class _FitnessGoalsPageState extends State<FitnessGoalsPage> {
  late Map<HealthItemType, double> _goals;
  late double _restingCalories;
  late double _activeCalories;
  late double _netCalories;
  late double _proteinGoal;
  late double _weightGoal;
  late double _bodyFatGoal;
  bool _useMetricWeight = false;
  int _currentStep = 0;
  
  // Controllers for each input
  late TextEditingController _netCaloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _weightController;
  late TextEditingController _bodyFatController;

  @override
  void initState() {
    super.initState();
    _goals = Map<HealthItemType, double>.from(widget.selectedGoals ?? {});
    _useMetricWeight = _goals[HealthItemType.weight] != null && _goals[HealthItemType.weight]! < 200;
    
    // Initialize controllers with current values
    _netCaloriesController = TextEditingController(
      text: _goals[HealthItemType.netCalories]?.toStringAsFixed(0) ?? '',
    );
    _proteinController = TextEditingController(
      text: _goals[HealthItemType.proteinIntake]?.toStringAsFixed(0) ?? '',
    );
    _weightController = TextEditingController(
      text: _goals[HealthItemType.weight]?.toStringAsFixed(1) ?? '',
    );
    _bodyFatController = TextEditingController(
      text: _goals[HealthItemType.bodyFatPercentage]?.toStringAsFixed(1) ?? '',
    );

    _calculateTDEE();
    _initializeGoals();
  }

  @override
  void dispose() {
    _netCaloriesController.dispose();
    _proteinController.dispose();
    _weightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  void _calculateTDEE() {
    // Mifflin-St Jeor Equation for BMR
    final bmr = widget.isMale
        ? 10 * widget.weight + 6.25 * widget.height - 5 * widget.age + 5
        : 10 * widget.weight + 6.25 * widget.height - 5 * widget.age - 161;

    // Activity level multipliers
    final activityMultiplier = _getActivityMultiplier(widget.activityLevel);

    _restingCalories = _goals[HealthItemType.restingCalories] ?? bmr;
    _activeCalories = _goals[HealthItemType.activeCalories] ?? (bmr * activityMultiplier - bmr);
  }

  void _initializeGoals() {
    _netCalories = _goals[HealthItemType.netCalories] ?? HealthItemDefinitions.netCalories.defaultGoal;
    _proteinGoal = _goals[HealthItemType.proteinIntake] ?? widget.weight;
    _weightGoal = _goals[HealthItemType.weight] ?? widget.weight;
    _bodyFatGoal = _goals[HealthItemType.bodyFatPercentage] ?? widget.bodyFat ?? HealthItemDefinitions.bodyFat.defaultGoal;
  }

  void _updateGoal(HealthItemType type, double value) {
    setState(() {
      _goals[type] = value;
      switch (type) {
        case HealthItemType.restingCalories:
          _restingCalories = value;
          break;
        case HealthItemType.activeCalories:
          _activeCalories = value;
          break;
        case HealthItemType.netCalories:
          _netCalories = value;
          break;
        case HealthItemType.proteinIntake:
          _proteinGoal = value;
          break;
        case HealthItemType.weight:
          _weightGoal = value;
          break;
        case HealthItemType.bodyFatPercentage:
          _bodyFatGoal = value;
          break;
        default:
          break;
      }
    });
    widget.onSelectionChanged(_goals);
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getWeightChangeText() {
    if (_netCalories == 0) return "You will maintain your current weight";
    final weeklyChange = (_netCalories * 7) / 3500; // 3500 calories = 1 lb
    return "You will ${weeklyChange > 0 ? 'gain' : 'lose'} ${weeklyChange.abs().toStringAsFixed(1)} lb of fat per week";
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onNext();
    }
  }

  Widget _buildCurrentStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PaddingSizes.xxlarge * 2),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: PaddingSizes.xxxlarge * 2),
          child: switch (_currentStep) {
            0 => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCaloriesSection(),
                  const SizedBox(height: PaddingSizes.xxxlarge),
                  _buildActiveCaloriesSection(),
                ],
              ),
            1 => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNetCaloriesSection(),
                ],
              ),
            2 => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildProteinSection(),
                ],
              ),
            3 => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWeightGoalSection(),
                  const SizedBox(height: PaddingSizes.xxxlarge),
                  _buildBodyFatGoalSection(),
                ],
              ),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }

  Widget _buildCaloriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Resting Calories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CoreColors.textColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Resting Calories'),
                    content: const Text(
                      'This is the number of calories your body burns at rest to maintain basic life functions.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        Text(
          '${_calculateRestingCalories().round()} cal',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CoreColors.coreOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveCaloriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Calories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CoreColors.textColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Active Calories'),
                    content: const Text(
                      'This is the number of calories you burn through physical activity.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        Text(
          '${_calculateActiveCalories().round()} cal',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CoreColors.coreOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildNetCaloriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Net Calories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CoreColors.textColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Net Calories'),
                    content: const Text(
                      'This is your daily calorie goal. A negative value means you want to lose weight.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: PaddingSizes.medium),
        TextField(
          controller: _netCaloriesController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'cal',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
            ),
          ),
          onChanged: (text) {
            final value = int.tryParse(text);
            if (value != null) {
              setState(() {
                _goals[HealthItemType.netCalories] = value.toDouble();
                _updateGoals();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildProteinSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Protein Intake',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CoreColors.textColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Protein Intake'),
                    content: const Text(
                      'This is your daily protein goal in grams.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: PaddingSizes.medium),
        TextField(
          controller: _proteinController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'g',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
            ),
          ),
          onChanged: (text) {
            final value = int.tryParse(text);
            if (value != null) {
              setState(() {
                _goals[HealthItemType.proteinIntake] = value.toDouble();
                _updateGoals();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildWeightGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weight Goal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CoreColors.textColor,
              ),
            ),
            _buildUnitToggle(
              'kg',
              'lb',
              _useMetricWeight,
              (value) {
                setState(() {
                  _useMetricWeight = value;
                  if (value) {
                    _goals[HealthItemType.weight] = _goals[HealthItemType.weight]! / 2.20462;
                  } else {
                    _goals[HealthItemType.weight] = _goals[HealthItemType.weight]! * 2.20462;
                  }
                  _updateGoals();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: PaddingSizes.medium),
        TextField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: _useMetricWeight ? 'kg' : 'lb',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
            ),
          ),
          onChanged: (text) {
            final value = double.tryParse(text);
            if (value != null) {
              setState(() {
                _goals[HealthItemType.weight] = value;
                _updateGoals();
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildBodyFatGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Body Fat Goal',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CoreColors.textColor,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Body Fat Goal'),
                    content: const Text(
                      'This is your target body fat percentage.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: PaddingSizes.medium),
        TextField(
          controller: _bodyFatController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '%',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
            ),
          ),
          onChanged: (text) {
            final value = double.tryParse(text);
            if (value != null) {
              setState(() {
                _goals[HealthItemType.bodyFatPercentage] = value;
                _updateGoals();
              });
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingBasePage(
      title: 'Set Your Goals',
      subtitle: _currentStep == 0
          ? 'Based on your information, we calculated your daily resting and active calories. '
          : _currentStep == 1
              ? 'Set your net calorie goal'
              : _currentStep == 2
                  ? 'Set your protein intake goal'
                  : 'Set your body composition goals',
      content: SingleChildScrollView(
        child: _buildCurrentStep(),
      ),
      onNext: _nextStep,
      nextEnabled: true,
    );
  }

  Widget _buildGoalCard(
    String title,
    String value,
    Function(double)? onChanged, {
    bool isEditable = true,
    bool infoIcon = false,
    VoidCallback? onInfoPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CoreColors.textColor,
              ),
            ),
            if (infoIcon)
              IconButton(
                icon: const Icon(
                  Icons.info_outline,
                  size: 20,
                ),
                onPressed: onInfoPressed,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        const SizedBox(height: PaddingSizes.medium),
        if (isEditable)
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: value,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
              ),
            ),
            onChanged: (text) {
              final value = double.tryParse(text);
              if (value != null && onChanged != null) {
                onChanged(value);
              }
            },
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: CoreColors.textColor,
            ),
          ),
      ],
    );
  }

  double _calculateRestingCalories() {
    // Mifflin-St Jeor Equation
    final weight = widget.weight;
    final height = widget.height;
    final age = widget.age;
    final isMale = widget.isMale;
    
    final bmr = (10 * weight) + (6.25 * height) - (5 * age) + (isMale ? 5 : -161);
    return bmr;
  }

  double _calculateActiveCalories() {
    final restingCalories = _calculateRestingCalories();
    final activityMultiplier = _getActivityMultiplier(widget.activityLevel);
    return (restingCalories * activityMultiplier) - restingCalories;
  }

  double _getActivityMultiplier(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 1.2;
      case ActivityLevel.lightlyActive:
        return 1.375;
      case ActivityLevel.moderatelyActive:
        return 1.55;
      case ActivityLevel.veryActive:
        return 1.725;
      case ActivityLevel.extraActive:
        return 1.9;
    }
  }

  void _updateGoals() {
    widget.onSelectionChanged(_goals);
  }

  Widget _buildUnitToggle(
    String metricLabel,
    String imperialLabel,
    bool isMetric,
    Function(bool) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: CoreColors.backgroundColor,
        borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
        border: Border.all(
          color: CoreColors.textColor.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(metricLabel, isMetric, () => onChanged(true)),
          _buildToggleButton(imperialLabel, !isMetric, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PaddingSizes.large,
          vertical: PaddingSizes.medium,
        ),
        decoration: BoxDecoration(
          color: isSelected ? CoreColors.coreOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? CoreColors.textColor : CoreColors.textColor.withOpacity(0.7),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
} 
