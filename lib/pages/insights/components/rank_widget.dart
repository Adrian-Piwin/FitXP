import 'package:flutter/material.dart';
import 'package:healthxp/components/info_bar.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'rank_widget_controller.dart';

class RankWidget extends WidgetFrame {
  const RankWidget({super.key}) : super(
    size: 6,
    height: WidgetSizes.mediumHeight,
    padding: 0,
    color: CoreColors.backgroundColor,
    showShadow: false,
  );

  @override
  Widget buildContent(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RankWidgetController(context),
      child: Consumer<RankWidgetController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Rank Progress Section
              GestureDetector(
                onTap: () => controller.showRankDetails(context),
                child: Row(
                  children: [
                    // Rank Icon Container
                    Container(
                      width: 50,
                      height: 53,
                      decoration: BoxDecoration(
                        color: CoreColors.foregroundColor,
                        borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                      ),
                      child: Center(
                        child: FaIcon(
                          controller.rankIcon,
                          size: IconSizes.large,
                          color: controller.rankColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: GapSizes.medium),
                    // XP Progress
                    Expanded(
                      child: InfoBar(
                        title: controller.rankName,
                        value: controller.currentXP.toString(),
                        goal: controller.requiredXP.toString(),
                        percent: controller.rankProgress,
                        color: controller.rankColor,
                        textColor: CoreColors.textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
