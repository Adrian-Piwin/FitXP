import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:healthxp/models/health_widget.model.dart';
import '../../constants/colors.constants.dart';
import '../home_details/health_details_view.dart';

class BasicLargeWidgetItem extends StatelessWidget {
  final HealthWidget widget;

  const BasicLargeWidgetItem({
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
      child: WidgetFrame(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.getConfig.title,
                  style: const TextStyle(
                    fontSize: FontSizes.medium,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: GapSizes.small),
                Text(
                  widget.getConfig.displayValue,
                  style: const TextStyle(
                    fontSize: FontSizes.xxlarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: GapSizes.small),
                Text(
                  widget.getConfig.subtitle,
                  style: const TextStyle(
                    fontSize: FontSizes.medium,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            widget.getConfig.goalPercent != -1
                ? SizedBox(
                    width: 100,
                    height: 100,
                    child: AnimatedRadialGauge(
                      duration: const Duration(seconds: 1),
                      curve: Curves.elasticOut,
                      value: widget.getConfig.goalPercent,
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
                          color: widget.getConfig.color,
                        ),
                      ),
                      builder: (context, child, value) => Center(
                        child: Icon(
                          widget.getConfig.icon,
                          size: 24,
                          color: widget.getConfig.color,
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
                        widget.getConfig.icon,
                        size: 24,
                        color: widget.getConfig.color,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
