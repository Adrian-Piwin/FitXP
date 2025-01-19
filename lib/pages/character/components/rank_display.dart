import 'package:flutter/material.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/icons.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';

class RankDisplay extends StatelessWidget {
  final String rank;

  const RankDisplay({
    super.key,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          width: 20,
          child: Center(
            child: Icon(
              IconTypes.medalIcon,
              color: CoreColors.coreGold,
              size: 35,
            ),
          ),
        ),
        const SizedBox(width: 28),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rank,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: FontSizes.xlarge,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Rank',
              style: TextStyle(
                fontSize: FontSizes.medium,
                fontWeight: FontWeight.w400,
                color: CoreColors.textColor,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 
