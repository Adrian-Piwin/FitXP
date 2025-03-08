import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/constants/rank_definitions.constants.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/constants/xp.constants.dart';
import 'package:healthxp/enums/rank.enum.dart';
import 'package:healthxp/services/xp_service.dart';
import 'package:provider/provider.dart';
import '../insights_controller.dart';

class RankWidgetController extends ChangeNotifier {
  late final InsightsController _insightsController;
  late final XpService _xpService;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  String get rankName => _insightsController.rankName;
  int get currentXP => _insightsController.currentXP;
  int get requiredXP => rankUpXPAmt;
  double get rankProgress => currentXP / requiredXP;

  // Getters for rank styling
  IconData get rankIcon => RankDefinitions.ranks[_xpService.currentRank]!.icon;
  Color get rankColor => RankDefinitions.ranks[_xpService.currentRank]!.color;

  RankWidgetController(BuildContext context) {
    _insightsController = Provider.of<InsightsController>(context, listen: false);
    _initialize();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _xpService = await XpService.getInstance();
      _isLoading = false;
    } catch (e) {
      print('Error initializing RankWidgetController: $e');
      _isLoading = false;
    }
    notifyListeners();
  }

  void showRankDetails(BuildContext context) {
    // Initialize selected rank outside the builder
    late Rank selectedRank;

    showDialog(
      context: context,
      builder: (context) {
        // Initialize on first build
        selectedRank = _xpService.currentRank;

        return StatefulBuilder(
          builder: (context, setState) {
            final selectedRankModel = RankDefinitions.ranks[selectedRank]!;

            return AlertDialog(
              title: const Text('Rank Details', style: TextStyle(fontSize: FontSizes.xlarge, fontWeight: FontWeight.bold)),
              content: Column(
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
                  const SizedBox(height: GapSizes.xxxlarge),
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
                      final isCurrentRank = rank == _xpService.currentRank;
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
} 
