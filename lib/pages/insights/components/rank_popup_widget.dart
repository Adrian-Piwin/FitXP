import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/rank_definitions.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/enums/rank.enum.dart';

class RankPopupWidget extends StatefulWidget {
  final Rank currentRank;

  const RankPopupWidget({
    super.key,
    required this.currentRank,
  });

  @override
  State<RankPopupWidget> createState() => _RankPopupWidgetState();
}

class _RankPopupWidgetState extends State<RankPopupWidget> {
  late Rank selectedRank;

  @override
  void initState() {
    super.initState();
    selectedRank = widget.currentRank;
  }

  @override
  Widget build(BuildContext context) {
    final selectedRankModel = RankDefinitions.ranks[selectedRank]!;

    return Dialog(
      backgroundColor: CoreColors.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(PaddingSizes.xlarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected Rank Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank Icon and Name
                Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: CoreColors.foregroundColor,
                        borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                      ),
                      child: Center(
                        child: FaIcon(
                          selectedRankModel.icon,
                          size: IconSizes.xlarge,
                          color: selectedRankModel.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: GapSizes.small),
                    Text(
                      selectedRank.displayName,
                      style: const TextStyle(
                        fontSize: FontSizes.medium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: GapSizes.large),
                // Rank Fact
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(PaddingSizes.medium),
                    decoration: BoxDecoration(
                      color: CoreColors.foregroundColor,
                      borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                    ),
                    child: Text(
                      selectedRankModel.fact,
                      style: const TextStyle(fontSize: FontSizes.medium),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GapSizes.xlarge),
            // All Ranks Display
            const Text(
              'Available Ranks',
              style: TextStyle(
                fontSize: FontSizes.large,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: GapSizes.xlarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Rank.values.map((rank) {
                final rankModel = RankDefinitions.ranks[rank]!;
                final isSelected = rank == selectedRank;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedRank = rank;
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: CoreColors.foregroundColor,
                          borderRadius: BorderRadius.circular(BorderRadiusSizes.medium),
                          border: isSelected ? Border.all(
                            color: rankModel.color,
                            width: 2,
                          ) : null,
                        ),
                        child: Center(
                          child: FaIcon(
                            rankModel.icon,
                            size: IconSizes.medium,
                            color: rankModel.color,
                          ),
                        ),
                      ),
                      const SizedBox(height: GapSizes.small),
                      Text(
                        rank.displayName,
                        style: TextStyle(
                          fontSize: FontSizes.small,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? rankModel.color : null,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
} 
