import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthcore/constants/animations.constants.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
import 'package:healthcore/pages/home_details/health_details_view.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CircularHealthWidget extends StatelessWidget {
  final HealthEntity widget;

  const CircularHealthWidget({
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
        child: CircularPercentIndicator(
          radius: PercentIndicatorSizes.circularRadiusMedium,
          lineWidth: PercentIndicatorSizes.lineHeightSmall,
          percent: widget.getGoalPercent,
          center: Transform.rotate(
            angle: widget.healthItem.iconRotation,
            child: FaIcon(widget.healthItem.icon,
                        size: IconSizes.small,
                        color: widget.healthItem.color),
          ),
          progressColor: widget.healthItem.color,
          backgroundColor: CoreColors.coreGrey,
          animation: true,
          animationDuration: PercentIndicatorAnimations.duration,
          footer: Padding(
            padding: const EdgeInsets.only(top: PaddingSizes.small),
            child: Text(
              widget.getDisplayValue,
              style: const TextStyle(
                fontSize: FontSizes.large,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
