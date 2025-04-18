import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/enums/activity_level.enum.dart';
import 'package:healthcore/enums/health_item_type.enum.dart';
import 'package:healthcore/pages/onboarding/onboarding_base_page.dart';
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
  final bool useMetricWeight;
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
    required this.useMetricWeight,
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
  int _currentStep = 0;
  
  // Controllers for each input
  late TextEditingController _netCaloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _weightController;
  late TextEditingController _bodyFatController;

  @override
  void initState() {
    super.initState();
    _goals = {};
  
    // Calculate default protein goal (1g per lb of body weight)
    final defaultProteinGoal = widget.weight.round(); // weight is always in lbs
    
    // Initialize controllers with default values
    _netCaloriesController = TextEditingController(
      text: HealthItemDefinitions.netCalories.defaultGoal.toStringAsFixed(0),
    );
    _proteinController = TextEditingController(
      text: defaultProteinGoal.toStringAsFixed(0),
    );
    _weightController = TextEditingController();
    _bodyFatController = TextEditingController();

    // Initialize values without setState
    _calculateTDEE();
    _netCalories = HealthItemDefinitions.netCalories.defaultGoal;
    _proteinGoal = defaultProteinGoal.toDouble();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Schedule the initialization after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGoals();
    });
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
    // Calculate BMR using appropriate formula
    double bmr;
    if (widget.bodyFat != null) {
      // Use Katch-McArdle formula (with body fat)
      final weightInKg = widget.weight / 2.20462; // Convert lbs to kg
      final leanMassInKg = weightInKg * (1 - (widget.bodyFat! / 100));
      bmr = 370 + (21.6 * leanMassInKg);
    } else {
      // Use Mifflin-St Jeor formula (without body fat)
      if (widget.isMale) {
        bmr = 66 + (6.23 * widget.weight) + (12.7 * (widget.height / 2.54)) - (6.8 * widget.age);
      } else {
        bmr = 655 + (4.35 * widget.weight) + (4.7 * (widget.height / 2.54)) - (4.7 * widget.age);
      }
    }

    // Calculate TDEE by applying activity multiplier
    final activityMultiplier = _getActivityMultiplier(widget.activityLevel);
    final tdee = bmr * activityMultiplier;

    // Calculate active calories based on TDEE and net calories goal
    _activeCalories = tdee - bmr;
    _restingCalories = bmr;
  }

  void _initializeGoals() {
    // Initialize goals with default values
    _goals[HealthItemType.netCalories] = _netCalories;
    _goals[HealthItemType.proteinIntake] = _proteinGoal;
    
    // Calculate and set resting calories (BMR)
    _goals[HealthItemType.restingCalories] = _restingCalories;
    _goals[HealthItemType.activeCalories] = _activeCalories;
    _goals[HealthItemType.expendedEnergy] = _restingCalories + _activeCalories;

    // Notify parent without setState
    widget.onSelectionChanged(_goals);
  }

  void _updateGoals() {
    // Update net calories goal
    final netCalories = double.tryParse(_netCaloriesController.text);
    if (netCalories != null) {
      _goals[HealthItemType.netCalories] = netCalories;
      _netCalories = netCalories;
    }

    // Update protein goal
    final protein = double.tryParse(_proteinController.text);
    if (protein != null) {
      _goals[HealthItemType.proteinIntake] = protein;
      _proteinGoal = protein;
    }

    // Update weight goal
    final weight = double.tryParse(_weightController.text);
    if (weight != null) {
      // Always store weight in pounds
      _goals[HealthItemType.weight] = widget.useMetricWeight ? weight / 2.20462 : weight;
    } else {
      _goals.remove(HealthItemType.weight);
    }

    // Update body fat goal
    final bodyFat = double.tryParse(_bodyFatController.text);
    if (bodyFat != null) {
      _goals[HealthItemType.bodyFatPercentage] = bodyFat;
    }

    // Notify parent without setState
    widget.onSelectionChanged(_goals);
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
                  const SizedBox(height: PaddingSizes.xxxlarge),
                  _buildTDEESection(),
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
              'Basic Metabolic Rate',
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
          '${_restingCalories.round()} cal',
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
          '${_activeCalories.round()} cal',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CoreColors.coreOrange,
          ),
        ),
      ],
    );
  }

    Widget _buildTDEESection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Daily Energy Expenditure',
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
                    title: const Text('Total Daily Energy Expenditure'),
                    content: const Text(
                      'Your basic metabolic rate plus the calories you burn through physical activity.',
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
          '${(_restingCalories + _activeCalories).round()} cal',
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
                      'This is your daily calorie goal. A negative value means you want to lose weight, positive means gain weight, and 0 means maintain weight.',
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
            if (text.isEmpty) {
              setState(() {
                _goals[HealthItemType.netCalories] = 0.0;
                _netCalories = 0.0;
                _updateGoals();
              });
              return;
            }
            
            final value = int.tryParse(text);
            if (value != null) {
              setState(() {
                _goals[HealthItemType.netCalories] = value.toDouble();
                _netCalories = value.toDouble();
                _updateGoals();
              });
            }
          },
        ),
        const SizedBox(height: PaddingSizes.medium),
        _buildWeightChangeVisualization(),
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
        const SizedBox(height: PaddingSizes.small),
        const Text(
          'The recommended amount of daily protein is 1g per 1 lb of body weight',
          style: TextStyle(
            fontSize: 14,
            color: CoreColors.textColor,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildWeightGoalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weight Goal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CoreColors.textColor,
          ),
        ),
        const SizedBox(height: PaddingSizes.medium),
        TextField(
          controller: _weightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: widget.useMetricWeight ? 'kg' : 'lb',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
            ),
          ),
          onChanged: (text) {
            if (text.isEmpty) {
              setState(() {
                _goals.remove(HealthItemType.weight);
                widget.onSelectionChanged(_goals);
              });
              return;
            }
            final value = double.tryParse(text);
            if (value != null) {
              setState(() {
                // Always store weight in pounds
                _goals[HealthItemType.weight] = widget.useMetricWeight ? value * 2.20462 : value;
                widget.onSelectionChanged(_goals);
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
              ? 'Set your daily calorie surplus or deficit goal'
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

  Widget _buildWeightChangeVisualization() {
    final weeklyChange = (_netCalories * 7) / 3500; // 3500 calories = 1 lb
    final isGaining = weeklyChange > 0;
    final isMaintaining = weeklyChange == 0;
    final changeText = weeklyChange.abs().toStringAsFixed(1);
    
    // Map net calories (-1000 to 1000) to position (0 to 1)
    final position = _netCalories.clamp(-1000.0, 1000.0) / 2000.0 + 0.5;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: CoreColors.backgroundColor,
            borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
            border: Border.all(
              color: CoreColors.textColor.withOpacity(0.1),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final containerWidth = constraints.maxWidth;
              const indicatorWidth = 40.0;
              final availableWidth = containerWidth - indicatorWidth;
              final left = position * availableWidth;
              
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background gradient
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          isMaintaining 
                            ? CoreColors.coreOrange.withOpacity(0.2)
                            : (isGaining ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2)),
                          CoreColors.backgroundColor,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                    ),
                  ),
                  // Indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: left,
                    child: Container(
                      width: indicatorWidth,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isMaintaining 
                          ? CoreColors.coreOrange 
                          : (isGaining ? Colors.red : Colors.green),
                        borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                        boxShadow: [
                          BoxShadow(
                            color: CoreColors.textColor.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          isMaintaining 
                            ? Icons.horizontal_rule 
                            : (isGaining ? Icons.arrow_upward : Icons.arrow_downward),
                          color: CoreColors.textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: PaddingSizes.small),
        Text(
          isMaintaining 
            ? 'You will maintain your current weight'
            : 'You will ${isGaining ? 'gain' : 'lose'} $changeText lb per week',
          style: TextStyle(
            fontSize: 14,
            color: isMaintaining 
              ? CoreColors.coreOrange 
              : (isGaining ? Colors.red : Colors.green),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 
