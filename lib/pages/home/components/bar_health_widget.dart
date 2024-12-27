import 'package:flutter/material.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/pages/home_details/health_details_view.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../constants/colors.constants.dart';

class BarHealthWidget extends StatelessWidget {
  final HealthEntity widget;

  const BarHealthWidget({
    super.key,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HealthDataDetailPage(widget: widget),
          ),
        );
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.healthItem.title,
                  style: const TextStyle(
                    fontSize: FontSizes.large,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.getDisplayValue,
                        style: const TextStyle(
                          fontSize: FontSizes.medium,
                        ),
                      ),
                      TextSpan(
                        text: '/${widget.getDisplayGoal}',
                        style: TextStyle(
                          fontSize: FontSizes.medium,
                          color: widget.healthItem.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: GapSizes.medium),
            LinearPercentIndicator(
              percent: widget.getGoalPercent,
              lineHeight: PercentIndicatorSizes.lineHeightLarge,
              backgroundColor: widget.healthItem.offColor,
              progressColor: widget.healthItem.color,
              barRadius: const Radius.circular(PercentIndicatorSizes.barRadius),
              padding: EdgeInsets.zero,
            )
          ],
        ),
      ),
    );
  }
}
