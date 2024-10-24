import 'package:fitxp/constants/size.constants.dart';
import 'package:flutter/material.dart';

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
        color: Colors.blueAccent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: FontSizes.widgetTitle, 
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FormatSizes.widgetGap),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white, 
                fontSize: FontSizes.widgetValue),
            ),
          ],
        )
      ),
    );
  }
}
