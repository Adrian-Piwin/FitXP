import 'package:flutter/material.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/pages/home_details/health_details_view.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class BasicHealthWidget extends WidgetFrame {
  final HealthEntity widget;

  const BasicHealthWidget({
    super.key,
    required this.widget,
  }) : super(
          size: 3,
          height: WidgetSizes.mediumHeight,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.healthItem.title,
              style: const TextStyle(
                fontSize: FontSizes.medium,
              ),
            ),
            const SizedBox(height: GapSizes.medium),
            Row(
              children: [
                Transform.rotate(
                  angle: widget.healthItem.iconRotation,
                  child: Icon(
                    widget.healthItem.icon,
                    color: widget.healthItem.color,
                    size: widget.getIconSize(IconSizes.small),
                  ),
                ),
                const SizedBox(width: GapSizes.medium),
                Text(
                  widget.getDisplayValue,
                  style: const TextStyle(
                    fontSize: FontSizes.xlarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: GapSizes.medium),
            Text(
              widget.getDisplaySubtitle,
              style: const TextStyle(
                fontSize: FontSizes.medium,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: GapSizes.medium),
            widget.getGoalPercent != -1
                ? LinearPercentIndicator(
                    percent: widget.getGoalPercent,
                    lineHeight: PercentIndicatorSizes.lineHeightLarge,
                    backgroundColor: widget.healthItem.offColor,
                    progressColor: widget.healthItem.color,
                    barRadius: const Radius.circular(PercentIndicatorSizes.barRadius),
                    padding: EdgeInsets.zero,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
