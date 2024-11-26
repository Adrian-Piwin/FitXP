import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/health_widget_config.model.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/animations.constants.dart';

class HeaderWidgetItem extends StatelessWidget {
  final HealthWidgetConfig barWidgetConfig;
  final HealthWidgetConfig subWidgetFirstConfig;
  final HealthWidgetConfig subWidgetSecondConfig;
  final HealthWidgetConfig subWidgetThirdConfig;

  const HeaderWidgetItem({
    super.key,
    required this.barWidgetConfig, 
    required this.subWidgetFirstConfig, 
    required this.subWidgetSecondConfig, 
    required this.subWidgetThirdConfig,
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
                  FaIcon(barWidgetConfig.icon,
                      size: IconSizes.medium,
                      color: barWidgetConfig.color),
                  const SizedBox(width: GapSizes.medium),
                  Text(
                    barWidgetConfig.displayValue,
                    style: const TextStyle(
                      fontSize: FontSizes.large,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GapSizes.small),
              LinearPercentIndicator(
                lineHeight: PercentIndicatorSizes.lineHeightLarge,
                padding: EdgeInsets.zero,
                percent: barWidgetConfig.goalPercent,
                backgroundColor: PercentIndicatorColors.backgroundColor,
                progressColor: barWidgetConfig.color,
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
                    percent: subWidgetFirstConfig.goalPercent,
                    center: FaIcon(subWidgetFirstConfig.icon,
                        size: IconSizes.small,
                        color: subWidgetFirstConfig.color),
                    progressColor: subWidgetFirstConfig.color,
                    backgroundColor: PercentIndicatorColors.backgroundColor,
                    animation: true,
                    animationDuration: PercentIndicatorAnimations.duration,
                    footer: Padding(
                      padding: const EdgeInsets.only(top: PaddingSizes.small),
                      child: Text(
                        subWidgetFirstConfig.displayValue,
                        style: const TextStyle(
                          fontSize: FontSizes.medium,
                        ),
                      ),
                    ),
                  ),
                  CircularPercentIndicator(
                    radius: PercentIndicatorSizes.circularRadiusMedium,
                    lineWidth: PercentIndicatorSizes.lineHeightSmall,
                    percent: subWidgetSecondConfig.goalPercent,
                    center: FaIcon(subWidgetSecondConfig.icon,
                        size: IconSizes.small,
                        color: subWidgetSecondConfig.color),
                    progressColor: subWidgetSecondConfig.color,
                    backgroundColor: PercentIndicatorColors.backgroundColor,
                    animation: true,
                    animationDuration: PercentIndicatorAnimations.duration,
                    footer: Padding(
                      padding: const EdgeInsets.only(top: PaddingSizes.small),
                      child: Text(
                        subWidgetSecondConfig.displayValue,
                        style: const TextStyle(
                          fontSize: FontSizes.medium,
                        ),
                      ),
                    ),
                  ),
                  CircularPercentIndicator(
                    radius: PercentIndicatorSizes.circularRadiusMedium,
                    lineWidth: PercentIndicatorSizes.lineHeightSmall,
                    percent: subWidgetThirdConfig.goalPercent,
                    center: FaIcon(subWidgetThirdConfig.icon,
                        size: IconSizes.small,
                        color: subWidgetThirdConfig.color),
                    progressColor: subWidgetThirdConfig.color,
                    backgroundColor: PercentIndicatorColors.backgroundColor,
                    animation: true,
                    animationDuration: PercentIndicatorAnimations.duration,
                    footer: Padding(
                      padding: const EdgeInsets.only(top: PaddingSizes.small),
                      child: Text(
                        subWidgetThirdConfig.displayValue,
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
