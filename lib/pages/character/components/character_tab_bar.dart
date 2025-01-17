import 'package:flutter/material.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';

class CharacterTabBar extends StatelessWidget {
  final TabController controller;

  const CharacterTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CoreColors.coreGrey,
        borderRadius: BorderRadius.circular(BorderRadiusSizes.small),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: CoreColors.foregroundColor,
          borderRadius: BorderRadius.circular(BorderRadiusSizes.small),
        ),
        labelColor: CoreColors.textColor,
        unselectedLabelColor: CoreColors.textColor.withOpacity(0.5),
        indicatorPadding: const EdgeInsets.all(4),
        indicatorWeight: 0,
        indicatorColor: Colors.transparent,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(height: 35, text: 'Stats'),
          Tab(height: 35, text: 'Quests'),
          Tab(height: 35, text: 'Friends'),
        ],
      ),
    );
  }
} 
