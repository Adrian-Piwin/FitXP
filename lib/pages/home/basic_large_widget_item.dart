import 'package:fitxp/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import '../../constants/colors.constants.dart';

class BasicLargeWidgetItem extends StatelessWidget {
  final String title;
  final String subTitle;
  final String value;
  final IconData icon;
  final double? percent;
  final Color color;

  const BasicLargeWidgetItem({
    super.key,
    required this.title,
    required this.subTitle,
    required this.value,
    required this.icon,
    required this.color,
    this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WidgetColors.primaryColor,
        borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: FontSizes.medium,
                ),
                softWrap: true,
              ),
              const SizedBox(height: GapSizes.small),
              Text(
                value,
                style: TextStyle(
                  fontSize: FontSizes.xxlarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GapSizes.small),
              Text(
                subTitle,
                style: TextStyle(
                  fontSize: FontSizes.medium,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          percent != null
              ? SizedBox(
                  width: 100,
                  height: 100,
                  child: AnimatedRadialGauge(
                    duration: const Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    value: percent!,
                    axis: GaugeAxis(
                      min: 0,
                      max: 1,
                      degrees: 230,
                      pointer: null,
                      style: const GaugeAxisStyle(
                        thickness: 5,
                        background: PercentIndicatorColors.backgroundColor,
                      ),
                      progressBar: GaugeProgressBar.rounded(
                        color: color,
                      ),
                    ),
                    builder: (context, child, value) => Center(
                      child: Icon(
                        icon,
                        size: 24,
                        color: color,
                      ),
                    ),
                  ),
                )
              : Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
