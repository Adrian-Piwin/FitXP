import 'package:fitxp/constants/size.constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

class CalorieWidgetItem extends StatelessWidget {
  final double activeCalories;
  final double restingCalories;
  final double dietaryCalories;

  const CalorieWidgetItem({
    super.key,
    required this.activeCalories,
    required this.restingCalories,
    required this.dietaryCalories,
  });

  @override
  Widget build(BuildContext context) {
    final double result = activeCalories + restingCalories - dietaryCalories;

    return Container(
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.caloriesWidgetTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: FontSizes.widgetTitle, 
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FormatSizes.widgetGap),
            Text(
              '${activeCalories.toStringAsFixed(0)} + ${restingCalories.toStringAsFixed(0)} - ${dietaryCalories.toStringAsFixed(0)} = ${result.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0, 
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
