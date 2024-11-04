import 'package:fitxp/constants/colors.constants.dart';
import 'package:fitxp/constants/icons.constants.dart';
import 'package:fitxp/constants/sizes.constants.dart';
import 'package:fitxp/enums/phasetype.enum.dart';
import 'package:fitxp/models/goal.model.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/animations.constants.dart';

class HeaderWidgetItem extends StatelessWidget {
  final double activeCalories;
  final double restingCalories;
  final double dietaryCalories;
  final double steps;
  final Goal goals;

  const HeaderWidgetItem({
    super.key,
    required this.activeCalories,
    required this.restingCalories,
    required this.dietaryCalories,
    required this.steps,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final double result = activeCalories + restingCalories - dietaryCalories;
    final double totalCalories = activeCalories + restingCalories;
    final double percentTotalCalories = (totalCalories / goals.caloriesOutGoal).clamp(0.0, 1.0);
    final double percentDietaryCalories = (dietaryCalories / goals.caloriesInGoal).clamp(0.0, 1.0);
    final double percentNetCalories = goals.phaseType == PhaseType.none ? 1 : (result / (goals.caloriesInGoal - goals.caloriesOutGoal).abs()).clamp(0.0, 1.0);
    final double percentSteps = (steps / goals.stepsGoal).clamp(0.0, 1.0);

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: WidgetColors.primaryColor,
          borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
        ),
        padding: const EdgeInsets.all(PaddingSizes.large),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(IconTypes.caloriesIcon,
                      size: IconSizes.medium,
                      color: RepresentationColors.caloriesColor),
                  const SizedBox(width: GapSizes.medium),
                  Text(
                    totalCalories.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: FontSizes.large,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GapSizes.small),
              LinearPercentIndicator(
                lineHeight: PercentIndicatorSizes.lineHeightLarge,
                padding: EdgeInsets.zero,
                percent: percentTotalCalories,
                backgroundColor: PercentIndicatorColors.backgroundColor,
                progressColor: RepresentationColors.caloriesColor,
                barRadius:
                    const Radius.circular(PercentIndicatorSizes.barRadius),
                animation: true,
                animationDuration: PercentIndicatorAnimations.duration,
              ),
              const SizedBox(height: GapSizes.xlarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircularPercentIndicator(
                    radius: PercentIndicatorSizes.circularRadiusMedium,
                    lineWidth: PercentIndicatorSizes.lineHeightSmall,
                    percent: percentDietaryCalories,
                    center: FaIcon(IconTypes.dietaryIcon,
                        size: IconSizes.small,
                        color: RepresentationColors.dietaryCaloriesColor),
                    progressColor: RepresentationColors.dietaryCaloriesColor,
                    backgroundColor: PercentIndicatorColors.backgroundColor,
                    animation: true,
                    animationDuration: PercentIndicatorAnimations.duration,
                    footer: Padding(
                      padding: const EdgeInsets.only(top: PaddingSizes.small),
                      child: Text(
                        dietaryCalories.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: FontSizes.medium,
                        ),
                      ),
                    ),
                  ),
                  CircularPercentIndicator(
                    radius: PercentIndicatorSizes.circularRadiusMedium,
                    lineWidth: PercentIndicatorSizes.lineHeightSmall,
                    percent: percentNetCalories,
                    center: FaIcon(IconTypes.netCaloriesIcon,
                        size: IconSizes.small,
                        color: RepresentationColors.netCaloriesColor),
                    progressColor: RepresentationColors.netCaloriesColor,
                    backgroundColor: PercentIndicatorColors.backgroundColor,
                    animation: true,
                    animationDuration: PercentIndicatorAnimations.duration,
                    footer: Padding(
                      padding: const EdgeInsets.only(top: PaddingSizes.small),
                      child: Text(
                        result.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: FontSizes.medium,
                        ),
                      ),
                    ),
                  ),
                  CircularPercentIndicator(
                    radius: PercentIndicatorSizes.circularRadiusMedium,
                    lineWidth: PercentIndicatorSizes.lineHeightSmall,
                    percent: percentSteps,
                    center: FaIcon(IconTypes.stepsIcon,
                        size: IconSizes.small,
                        color: RepresentationColors.stepsColor),
                    progressColor: RepresentationColors.stepsColor,
                    backgroundColor: PercentIndicatorColors.backgroundColor,
                    animation: true,
                    animationDuration: PercentIndicatorAnimations.duration,
                    footer: Padding(
                      padding: const EdgeInsets.only(top: PaddingSizes.small),
                      child: Text(
                        steps.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: FontSizes.medium,
                        ),
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
