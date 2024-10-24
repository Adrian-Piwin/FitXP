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
      padding: const EdgeInsets.all(16.0), // Add padding for better layout
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content vertically
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Small font title loaded from localization
            Text(
              AppLocalizations.of(context)!.caloriesWidgetTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.0, // Small font size
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0), // Space between title and equation
            // Display the equation
            Text(
              '${activeCalories.toStringAsFixed(1)} + ${restingCalories.toStringAsFixed(1)} - ${dietaryCalories.toStringAsFixed(1)} = ${result.toStringAsFixed(1)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16.0, // Adjust font size as needed
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
