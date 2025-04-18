import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/enums/gender.enum.dart';
import 'package:healthcore/pages/onboarding/onboarding_base_page.dart';

class BodyStatsPage extends StatefulWidget {
  final VoidCallback onNext;
  final Function(double? weight, int? age, Gender? gender, double? height, double? bodyFat) onSelectionChanged;
  final double? selectedWeight;
  final int? selectedAge;
  final Gender? selectedGender;
  final double? selectedHeight;
  final double? selectedBodyFat;

  const BodyStatsPage({
    super.key,
    required this.onNext,
    required this.onSelectionChanged,
    this.selectedWeight,
    this.selectedAge,
    this.selectedGender,
    this.selectedHeight,
    this.selectedBodyFat,
  });

  @override
  State<BodyStatsPage> createState() => _BodyStatsPageState();
}

class _BodyStatsPageState extends State<BodyStatsPage> {
  double? _weight;
  int? _age;
  Gender? _gender;
  double? _height;
  double? _bodyFat;
  bool _useMetricWeight = false;
  bool _useMetricHeight = false;
  int _currentStep = 0;

  // Controllers for each input to prevent reuse
  late TextEditingController _ageController;
  late TextEditingController _weightController;
  late TextEditingController _bodyFatController;
  late TextEditingController _heightController;
  late TextEditingController _heightInchesController;

  @override
  void initState() {
    super.initState();
    _weight = widget.selectedWeight;
    _age = widget.selectedAge;
    _gender = widget.selectedGender;
    _height = widget.selectedHeight;
    _bodyFat = widget.selectedBodyFat;
    _useMetricWeight = false; 
    _useMetricHeight = false;

    // Initialize controllers with empty text
    _ageController = TextEditingController();
    _weightController = TextEditingController();
    _bodyFatController = TextEditingController();
    _heightController = TextEditingController();
    _heightInchesController = TextEditingController();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _bodyFatController.dispose();
    _heightController.dispose();
    _heightInchesController.dispose();
    super.dispose();
  }

  void _updateStats() {
    widget.onSelectionChanged(_weight, _age, _gender, _height, _bodyFat);
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      widget.onNext();
    }
  }

  bool get _isValid {
    switch (_currentStep) {
      case 0:
        return _age != null && _gender != null;
      case 1:
        return _weight != null;
      case 2:
        return _height != null;
      default:
        return false;
    }
  }

  void _updateWeightUnit(bool useMetric) {
    setState(() {
      if (_weight != null) {
        // Convert the stored weight when switching units
        if (useMetric) {
          // Converting from lb to kg for display
          _weightController.text = (_weight! / 2.20462).toStringAsFixed(1);
        } else {
          // Converting from kg to lb for display
          _weightController.text = _weight!.toStringAsFixed(1);
        }
      }
      _useMetricWeight = useMetric;
      widget.onSelectionChanged(
        _weight,
        _age,
        _gender,
        _height,
        _bodyFat,
      );
    });
  }

  void _updateWeight(String value) {
    if (value.isEmpty) {
      setState(() {
        _weight = null;
        widget.onSelectionChanged(
          _weight,
          _age,
          _gender,
          _height,
          _bodyFat,
        );
      });
      return;
    }

    final parsedValue = double.tryParse(value);
    if (parsedValue != null) {
      setState(() {
        // Always store weight in pounds
        _weight = _useMetricWeight ? parsedValue * 2.20462 : parsedValue;
        widget.onSelectionChanged(
          _weight,
          _age,
          _gender,
          _height,
          _bodyFat,
        );
      });
    }
  }

  void _updateHeightUnit(bool useMetric) {
    setState(() {
      if (_height != null) {
        // Convert the stored height when switching units for display
        if (useMetric) {
          // Display in cm
          _heightController.text = _height!.toStringAsFixed(1);
        } else {
          // Convert cm to feet and inches for display
          final totalInches = _height! / 2.54;
          final feet = (totalInches / 12).floor();
          final inches = (totalInches % 12).round();
          _heightController.text = feet.toString();
          _heightInchesController.text = inches.toString();
        }
      }
      _useMetricHeight = useMetric;
      widget.onSelectionChanged(
        _weight,
        _age,
        _gender,
        _height,
        _bodyFat,
      );
    });
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
                  _buildInputCard(
                    'Age',
                    'years',
                    _ageController,
                    (value) {
                      setState(() {
                        _age = value;
                        _updateStats();
                      });
                    },
                  ),
                  const SizedBox(height: PaddingSizes.xxxlarge),
                  _buildGenderToggle(),
                ],
              ),
            1 => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildWeightInput(),
                  const SizedBox(height: PaddingSizes.xxxlarge),
                  _buildBodyFatInput(),
                ],
              ),
            2 => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeightInput(),
                ],
              ),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }

  Widget _buildInputCard(
    String title,
    String hint,
    TextEditingController controller,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CoreColors.textColor,
          ),
        ),
        const SizedBox(height: PaddingSizes.medium),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
            ),
          ),
          onChanged: (text) {
            final value = int.tryParse(text);
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildGenderToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CoreColors.textColor,
          ),
        ),
        const SizedBox(height: PaddingSizes.medium),
        Row(
          children: [
            Expanded(
              child: _buildGenderButton(
                'Male',
                Gender.male,
                _gender == Gender.male,
              ),
            ),
            const SizedBox(width: PaddingSizes.medium),
            Expanded(
              child: _buildGenderButton(
                'Female',
                Gender.female,
                _gender == Gender.female,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderButton(String label, Gender gender, bool isSelected) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _gender = gender;
          _updateStats();
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? CoreColors.coreOrange : CoreColors.backgroundColor,
        foregroundColor: isSelected ? CoreColors.textColor : CoreColors.textColor.withOpacity(0.7),
        padding: const EdgeInsets.symmetric(vertical: PaddingSizes.large),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
          side: BorderSide(
            color: CoreColors.textColor.withOpacity(0.1),
          ),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWeightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Weight',
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
              _updateWeightUnit,
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
          onChanged: _updateWeight,
        ),
      ],
    );
  }

  Widget _buildBodyFatInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Body Fat Percentage',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: CoreColors.textColor,
          ),
        ),
        const SizedBox(height: PaddingSizes.medium),
        TextField(
          controller: _bodyFatController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Optional',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
            ),
          ),
          onChanged: (text) {
            if (text.isEmpty) {
              setState(() {
                _bodyFat = null;
                _updateStats();
              });
            } else {
              final value = double.tryParse(text);
              if (value != null) {
                setState(() {
                  _bodyFat = value;
                  _updateStats();
                });
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildHeightInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Height',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CoreColors.textColor,
              ),
            ),
            _buildUnitToggle(
              'cm',
              'ft-in',
              _useMetricHeight,
              _updateHeightUnit,
            ),
          ],
        ),
        const SizedBox(height: PaddingSizes.medium),
        if (_useMetricHeight)
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'cm',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
              ),
            ),
            onChanged: (text) {
              if (text.isEmpty) {
                setState(() {
                  _height = null;
                  widget.onSelectionChanged(
                    _weight,
                    _age,
                    _gender,
                    _height,
                    _bodyFat,
                  );
                });
                return;
              }
              final value = double.tryParse(text);
              if (value != null) {
                setState(() {
                  _height = value; // Store directly in cm
                  widget.onSelectionChanged(
                    _weight,
                    _age,
                    _gender,
                    _height,
                    _bodyFat,
                  );
                });
              }
            },
          )
        else
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'ft',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                    ),
                  ),
                  onChanged: (text) {
                    if (text.isEmpty) {
                      setState(() {
                        _height = null;
                        widget.onSelectionChanged(
                          _weight,
                          _age,
                          _gender,
                          _height,
                          _bodyFat,
                        );
                      });
                      return;
                    }
                    final feet = double.tryParse(text);
                    final inches = double.tryParse(_heightInchesController.text);
                    if (feet != null && inches != null) {
                      setState(() {
                        // Convert feet and inches to cm
                        _height = (feet * 30.48) + (inches * 2.54);
                        widget.onSelectionChanged(
                          _weight,
                          _age,
                          _gender,
                          _height,
                          _bodyFat,
                        );
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: PaddingSizes.medium),
              Expanded(
                child: TextField(
                  controller: _heightInchesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'in',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                    ),
                  ),
                  onChanged: (text) {
                    if (text.isEmpty) {
                      setState(() {
                        _height = null;
                        widget.onSelectionChanged(
                          _weight,
                          _age,
                          _gender,
                          _height,
                          _bodyFat,
                        );
                      });
                      return;
                    }
                    final inches = double.tryParse(text);
                    final feet = double.tryParse(_heightController.text);
                    if (inches != null && feet != null) {
                      setState(() {
                        // Convert feet and inches to cm
                        _height = (feet * 30.48) + (inches * 2.54);
                        widget.onSelectionChanged(
                          _weight,
                          _age,
                          _gender,
                          _height,
                          _bodyFat,
                        );
                      });
                    }
                  },
                ),
              ),
            ],
          ),
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    return OnboardingBasePage(
      title: 'Your Body Stats',
      subtitle: _currentStep == 0
          ? 'We will use this to calculate your daily expended energy, so we can set your goals accordingly'
          : _currentStep == 1
              ? 'Set your weight and body fat percentage'
              : 'Set your height',
      content: SingleChildScrollView(
        child: _buildCurrentStep(),
      ),
      onNext: _nextStep,
      nextEnabled: _isValid,
    );
  }
} 
