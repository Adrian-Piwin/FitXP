import 'package:flutter/material.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';

class LabeledValueDisplay extends StatelessWidget {
  final String label;
  final String value;
  
  const LabeledValueDisplay({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: FontSizes.large,
            fontWeight: FontWeight.w400,
            color: CoreColors.textColor,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: FontSizes.huge,
            height: 0.9,
          ),
        ),
      ],
    );
  }
} 
