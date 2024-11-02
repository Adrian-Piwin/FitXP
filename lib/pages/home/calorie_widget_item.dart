import 'package:fitxp/constants/icons.constants.dart';
import 'package:fitxp/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/animations.constants.dart';

class CalorieWidgetItem extends StatelessWidget {
  final double activeCalories;
  final double restingCalories;
  final double dietaryCalories;
  final int goalDietaryCalories;
  final int goalActiveCalories;
  final int goalNetCalories;

  const CalorieWidgetItem({
    super.key,
    required this.activeCalories,
    required this.restingCalories,
    required this.dietaryCalories,
    required this.goalDietaryCalories,
    required this.goalActiveCalories,
    required this.goalNetCalories,
  });

  @override
  Widget build(BuildContext context) {
    final double result = activeCalories + restingCalories - dietaryCalories;
    final double totalCalories = activeCalories + restingCalories;
    final double percentTotalCalories = totalCalories / goalDietaryCalories;
    final double percentDietaryCalories = dietaryCalories / goalDietaryCalories;
    final double percentNetCalories = result / goalNetCalories;
    final double percentActiveCalories = activeCalories / goalActiveCalories;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal,
          borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
        ),
        padding: const EdgeInsets.all(PaddingSizes.large),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    totalCalories.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: FontSizes.medium,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.caloriesWidgetTitle,
                    style: const TextStyle(
                      fontSize: FontSizes.medium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    goalDietaryCalories.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: FontSizes.medium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GapSizes.small),
              LinearPercentIndicator(
                lineHeight: PercentIndicatorSizes.lineHeightLarge,
                padding: EdgeInsets.zero,
                percent: percentTotalCalories,
                backgroundColor: Colors.grey,
                progressColor: Colors.blue,
                barRadius: const Radius.circular(PercentIndicatorSizes.barRadius),
                animation: true,
                animationDuration: PercentIndicatorAnimations.duration,
              ),
              const SizedBox(height: GapSizes.large),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircularPercentIndicator(
                    radius: PercentIndicatorSizes.circularRadiusMedium,
                    lineWidth: PercentIndicatorSizes.lineHeightSmall,
                    percent: percentDietaryCalories,
                    center:
                        FaIcon(IconTypes.dietaryIcon, size: IconSizes.small),
                    progressColor: Colors.green,
                    backgroundColor: Colors.grey,
                    animation: true,
                    animationDuration: PercentIndicatorAnimations.duration,
                    footer: Text(
                      dietaryCalories.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: FontSizes.medium,
                      ),
                    ),
                  ),
                  CircularPercentIndicator(
                    radius: PercentIndicatorSizes.circularRadiusMedium,
                    lineWidth: PercentIndicatorSizes.lineHeightSmall,
                    percent: percentNetCalories,
                    center: FaIcon(IconTypes.netCaloriesIcon, size: IconSizes.small),
                    progressColor: Colors.orange,
                    backgroundColor: Colors.grey,
                    animation: true,
                    animationDuration: PercentIndicatorAnimations.duration,
                    footer: Text(
                      result.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: FontSizes.medium,
                      ),
                    ),
                  ),
                  CircularPercentIndicator(
                    radius: PercentIndicatorSizes.circularRadiusMedium,
                    lineWidth: PercentIndicatorSizes.lineHeightSmall,
                    percent: percentActiveCalories,
                    center: FaIcon(IconTypes.activeCaloriesIcon, size: IconSizes.small),
                    progressColor: Colors.red,
                    backgroundColor: Colors.grey,
                    animation: true,
                    animationDuration: PercentIndicatorAnimations.duration,
                    footer: Text(
                      activeCalories.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: FontSizes.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
