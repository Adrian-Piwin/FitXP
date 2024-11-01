import 'package:fitxp/constants/size.constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(20.0),
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
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.caloriesWidgetTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: FontSizes.widgetTitle,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    goalDietaryCalories.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FormatSizes.widgetGap),
              LinearPercentIndicator(
                lineHeight: 20.0,
                padding: EdgeInsets.zero,
                percent: percentTotalCalories,
                backgroundColor: Colors.grey,
                progressColor: Colors.blue,
                barRadius: const Radius.circular(10),
                animation: true,
                animationDuration: 500,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircularPercentIndicator(
                    radius: 35.0,
                    lineWidth: 5.0,
                    percent: percentDietaryCalories,
                    center:
                        FaIcon(FontAwesomeIcons.utensils, color: Colors.white),
                    progressColor: Colors.green,
                    backgroundColor: Colors.grey,
                    animation: true,
                    animationDuration: 500,
                    footer: Text(
                      dietaryCalories.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  CircularPercentIndicator(
                    radius: 35.0,
                    lineWidth: 5.0,
                    percent: percentNetCalories,
                    center: FaIcon(FontAwesomeIcons.scaleBalanced,
                        color: Colors.white),
                    progressColor: Colors.orange,
                    backgroundColor: Colors.grey,
                    animation: true,
                    animationDuration: 500,
                    footer: Text(
                      '${result.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  CircularPercentIndicator(
                    radius: 35.0,
                    lineWidth: 5.0,
                    percent: percentActiveCalories,
                    center: FaIcon(FontAwesomeIcons.personRunning,
                        color: Colors.white),
                    progressColor: Colors.red,
                    backgroundColor: Colors.grey,
                    animation: true,
                    animationDuration: 500,
                    footer: Text(
                      activeCalories.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
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
