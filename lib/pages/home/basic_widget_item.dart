import 'package:fitxp/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.constants.dart';

class BasicWidgetItem extends StatelessWidget {
  final String title;
  final String value;

  const BasicWidgetItem({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    // Width is set in the parent
    return Container(
      decoration: BoxDecoration(
        color: WidgetColors.primaryColor,
        borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: FontSizes.medium, 
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GapSizes.small),
            Text(
              value,
              style: const TextStyle(
                fontSize: FontSizes.large),
            ),
          ],
        )
      ),
    );
  }
}
