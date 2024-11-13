import 'package:fitxp/constants/sizes.constants.dart';
import 'package:fitxp/models/health_widget_config.model.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import '../../constants/colors.constants.dart';

class BasicLargeWidgetItem extends StatelessWidget {
  final HealthWidgetConfig config;

  const BasicLargeWidgetItem({
    super.key,
    required this.config,
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
                config.title,
                style: const TextStyle(
                  fontSize: FontSizes.medium,
                ),
                softWrap: true,
              ),
              const SizedBox(height: GapSizes.small),
              Text(
                config.displayValue,
                style: TextStyle(
                  fontSize: FontSizes.xxlarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GapSizes.small),
              Text(
                config.subtitle,
                style: TextStyle(
                  fontSize: FontSizes.medium,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          config.goalPercent != -1
              ? SizedBox(
                  width: 100,
                  height: 100,
                  child: AnimatedRadialGauge(
                    duration: const Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    value: config.goalPercent!,
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
                        color: config.color,
                      ),
                    ),
                    builder: (context, child, value) => Center(
                      child: Icon(
                        config.icon,
                        size: 24,
                        color: config.color,
                      ),
                    ),
                  ),
                )
              : Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PercentIndicatorColors.backgroundColor,
                  ),
                  child: Center(
                    child: Icon(
                      config.icon,
                      size: 24,
                      color: config.color,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
