import 'package:flutter/material.dart';
import 'package:healthcore/components/widget_frame.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/models/daily_goal_status.model.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BasicWeeklyHealthWidget extends WidgetFrame {
  final HealthEntity widget;

  const BasicWeeklyHealthWidget({
    super.key,
    required this.widget,
  }) : super(
          size: 6,
          height: WidgetSizes.mediumHeight,
        );

  @override
  Widget buildContent(BuildContext context) {
    final List<DailyGoalStatus> weeklyStatus = widget.getWeeklyGoalStatus();
    final int completedDays = weeklyStatus.where((day) => day.isCompleted).length;
    final subtitle = completedDays <= 2 
        ? "Just getting started"
        : completedDays <= 4 
            ? "On track" 
            : completedDays <= 6
                ? "Working hard"
                : "Perfectionist";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Stats
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                    widget.healthItem.title,
                    style: const TextStyle(
                      fontSize: FontSizes.medium,
                      color: CoreColors.textColor,
                    ),
                  ),
              const SizedBox(height: GapSizes.xlarge),
              Row(
                children: [
                  Transform.rotate(
                    angle: widget.healthItem.iconRotation,
                    child: FaIcon(
                      widget.healthItem.icon,
                      color: widget.healthItem.color,
                      size: IconSizes.small,
                    ),
                  ),
                  const SizedBox(width: GapSizes.large),
                  Text(
                    '$completedDays/7',
                    style: const TextStyle(
                      fontSize: FontSizes.xxlarge,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GapSizes.small),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: FontSizes.small,
                  color: CoreColors.coreOffLightGrey,
                ),
              ),
            ],
          ),
        ),
        // Right side - Daily pills
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: weeklyStatus.map((day) => _buildDayPill(day)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDayPill(DailyGoalStatus day) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 80,
              child: RotatedBox(
                quarterTurns: 3,
                child: LinearPercentIndicator(
                  percent: day.percentageTowardsGoal,
                  lineHeight: PercentIndicatorSizes.lineHeightLarge,
                  backgroundColor: CoreColors.coreGrey,
                  progressColor: widget.healthItem.color,
                  barRadius: const Radius.circular(12),
                  padding: EdgeInsets.zero,
                  animation: true,
                ),
              ),
            ),
            if (day.isCompleted)
              const Icon(
                Icons.check,
                color: Colors.black,
                size: IconSizes.xsmall,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          day.dayLetter,
          style: const TextStyle(
            fontSize: FontSizes.xsmall,
            color: CoreColors.coreOffLightGrey,
          ),
        ),
      ],
    );
  }
} 
