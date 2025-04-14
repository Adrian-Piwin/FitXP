import 'package:flutter/material.dart';
import 'package:healthcore/constants/colors.constants.dart';

/// A reusable widget to indicate premium features in the app
class PremiumIndicator extends StatelessWidget {
  final bool mini;
  
  /// Creates a premium indicator widget
  /// 
  /// [mini] controls whether to show a smaller, more compact version
  const PremiumIndicator({super.key, this.mini = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mini ? 2.0 : 6.0,
        vertical: mini ? 2.0 : 3.0,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFf1cc07), // Gold
            Color(0xFFf96e2a), // Orange
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(mini ? 4.0 : 8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: mini ? 10.0 : 14.0,
            color: CoreColors.textColor,
          ),
        ],
      ),
    );
  }
} 
