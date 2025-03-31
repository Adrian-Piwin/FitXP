import 'package:flutter/material.dart';
import 'package:healthcore/components/info_bar.dart';
import 'package:healthcore/components/loading_widget.dart';
import 'package:healthcore/components/widget_frame.dart';
import 'package:healthcore/constants/colors.constants.dart';
import 'package:healthcore/constants/sizes.constants.dart';
import 'package:healthcore/constants/xp.constants.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthcore/utility/general.utility.dart';
import 'package:provider/provider.dart';
import 'package:healthcore/services/xp_service.dart';
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
      child: Consumer2<RankWidgetController, XpService>(
        builder: (context, controller, xpService, _) {
          if (controller.isLoading) {
            return const LoadingWidget(
              size: 6,
              height: WidgetSizes.mediumHeight,
              color: CoreColors.backgroundColor,
              showShadow: false,
            );
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
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: FaIcon(
                            controller.rankIcon,
                            key: ValueKey(controller.currentAnimatedRank),
                            size: IconSizes.large,
                            color: controller.rankColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: GapSizes.medium),
                    // XP Progress
                    Expanded(
                      child: RepaintBoundary(
                        child: InfoBar(
                          title: controller.rankName,
                          formatValue: formatNumberSimple,
                          value: controller.currentAnimatedXP,
                          goal: rankUpXPAmt.toString(),
                          percent: controller.rankProgress,
                          color: controller.rankColor,
                          textColor: CoreColors.textColor,
                          animateChanges: true,
                        ),
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
