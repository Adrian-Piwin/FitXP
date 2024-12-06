import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import '../../constants/colors.constants.dart';
import '../home_details/health_details_view.dart';

class BasicLargeWidgetItem extends WidgetFrame {
  final HealthEntity widget;

  const BasicLargeWidgetItem({
    super.key,
    required this.widget,
  }) : super(
          size: 2,
          height: WidgetSizes.smallHeight,
        );

  @override
  Widget buildContent(BuildContext context) {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.healthItem.title,
                  style: const TextStyle(
                    fontSize: FontSizes.medium,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: GapSizes.small),
                Text(
                  widget.getDisplayValue,
                  style: const TextStyle(
                    fontSize: FontSizes.xxlarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: GapSizes.small),
                Text(
                  widget.getDisplaySubtitle,
                  style: const TextStyle(
                    fontSize: FontSizes.medium,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            widget.getGoalPercent != -1
                ? SizedBox(
                    width: 100,
                    height: 100,
                    child: AnimatedRadialGauge(
                      duration: const Duration(seconds: 1),
                      curve: Curves.elasticOut,
                      value: widget.getGoalPercent,
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
                          color: widget.healthItem.color,
                        ),
                      ),
                      builder: (context, child, value) => Center(
                        child: Icon(
                          widget.healthItem.icon,
                          size: 24,
                          color: widget.healthItem.color,
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
                        widget.healthItem.icon,
                        size: 24,
                        color: widget.healthItem.color,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
