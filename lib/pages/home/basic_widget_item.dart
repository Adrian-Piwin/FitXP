import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/health_widget_config.model.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import '../../constants/colors.constants.dart';

class BasicWidgetItem extends StatelessWidget {
  final HealthWidgetConfig config;

  const BasicWidgetItem({
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
      child: Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(config.icon, size: 18),
                const SizedBox(width: GapSizes.small),
                Text(
                  config.title,
                  style: const TextStyle(
                    fontSize: FontSizes.medium,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: GapSizes.small),
          config.goalPercent != -1
            ? SizedBox(
                width: 70,
                height: 70,
                child: AnimatedRadialGauge(
                  duration: const Duration(seconds: 1),
                  curve: Curves.elasticOut,
                  value: config.goalPercent,
                  axis: GaugeAxis(
                    min: 0,
                    max: 1,
                    degrees: 280,
                    pointer: null,
                    style: const GaugeAxisStyle(
                      thickness: 5,
                      background: Color(0xFFDFE2EC),
                    ),
                  ),
                  builder: (context, child, value) => RadialGaugeLabel(
                              value: value,
                              style: const TextStyle(
                                fontSize: FontSizes.large,
                              ),
                            ),
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Center(
                  child: Icon(
                    config.icon,
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            const SizedBox(height: GapSizes.small),
            Text(
              config.subtitle,
              style: TextStyle(
                fontSize: FontSizes.small,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
