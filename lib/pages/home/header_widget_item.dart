import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/health_widget.model.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/animations.constants.dart';

class HeaderWidgetItem extends StatelessWidget {
  final HealthWidget barWidget;
  final HealthWidget subWidgetFirst;
  final HealthWidget subWidgetSecond;
  final HealthWidget subWidgetThird;

  const HeaderWidgetItem({
    super.key,
    required this.barWidget, 
    required this.subWidgetFirst, 
    required this.subWidgetSecond, 
    required this.subWidgetThird,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: WidgetColors.primaryColor,
          borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
        ),
        padding: const EdgeInsets.all(PaddingSizes.large),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(barWidget.healthItem.icon,
                      size: IconSizes.medium,
                      color: barWidget.healthItem.color),
                  const SizedBox(width: GapSizes.medium),
                  Text(
                    barWidget.getDisplayValue,
                    style: const TextStyle(
                      fontSize: FontSizes.xlarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GapSizes.small),
              LinearPercentIndicator(
                lineHeight: PercentIndicatorSizes.lineHeightLarge,
                padding: EdgeInsets.zero,
                percent: barWidget.getGoalPercent,
                backgroundColor: PercentIndicatorColors.backgroundColor,
                progressColor: barWidget.healthItem.color,
                barRadius:
                    const Radius.circular(PercentIndicatorSizes.barRadius),
                animation: true,
                animationDuration: PercentIndicatorAnimations.duration,
              ),
              const SizedBox(height: GapSizes.xlarge),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircularPercentIndicator(
                    radius: PercentIndicatorSizes.circularRadiusMedium,
                    lineWidth: PercentIndicatorSizes.lineHeightSmall,
                    percent: subWidgetFirst.getGoalPercent,
                    center: FaIcon(subWidgetFirst.healthItem.icon,
                        size: IconSizes.small,
                        color: subWidgetFirst.healthItem.color),
                    progressColor: subWidgetFirst.healthItem.color,
                    backgroundColor: PercentIndicatorColors.backgroundColor,
                    animation: true,
                    animationDuration: PercentIndicatorAnimations.duration,
                    footer: Padding(
                      padding: const EdgeInsets.only(top: PaddingSizes.small),
                      child: Text(
                        subWidgetFirst.getDisplayValue,
                        style: const TextStyle(
                          fontSize: FontSizes.medium,
                        ),
                      ),
                    ),
                  ),
                  CircularPercentIndicator(
                    radius: PercentIndicatorSizes.circularRadiusMedium,
                    lineWidth: PercentIndicatorSizes.lineHeightSmall,
                    percent: subWidgetSecond.getGoalPercent,
                    center: FaIcon(subWidgetSecond.healthItem.icon,
                        size: IconSizes.small,
                        color: subWidgetSecond.healthItem.color),
                    progressColor: subWidgetSecond.healthItem.color,
                    backgroundColor: PercentIndicatorColors.backgroundColor,
                    animation: true,
                    animationDuration: PercentIndicatorAnimations.duration,
                    footer: Padding(
                      padding: const EdgeInsets.only(top: PaddingSizes.small),
                      child: Text(
                        subWidgetSecond.getDisplayValue,
                        style: const TextStyle(
                          fontSize: FontSizes.medium,
                        ),
                      ),
                    ),
                  ),
                  CircularPercentIndicator(
                    radius: PercentIndicatorSizes.circularRadiusMedium,
                    lineWidth: PercentIndicatorSizes.lineHeightSmall,
                    percent: subWidgetThird.getGoalPercent,
                    center: FaIcon(subWidgetThird.healthItem.icon,
                        size: IconSizes.small,
                        color: subWidgetThird.healthItem.color),
                    progressColor: subWidgetThird.healthItem.color,
                    backgroundColor: PercentIndicatorColors.backgroundColor,
                    animation: true,
                    animationDuration: PercentIndicatorAnimations.duration,
                    footer: Padding(
                      padding: const EdgeInsets.only(top: PaddingSizes.small),
                      child: Text(
                        subWidgetThird.getDisplayValue,
                        style: const TextStyle(
                          fontSize: FontSizes.medium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
