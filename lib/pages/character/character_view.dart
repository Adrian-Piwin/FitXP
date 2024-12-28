import 'package:flutter/material.dart';
import 'package:healthxp/components/bottom_nav_bar.dart';
import 'package:healthxp/components/info_bar.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:provider/provider.dart';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/pages/character/character_controller.dart';
import 'package:healthxp/pages/character/components/character_progress_bar.dart';

class CharacterView extends StatelessWidget {
  const CharacterView({super.key});

  static const routeName = '/character';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CharacterController>(
      create: (context) => CharacterController(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<CharacterController>(
            builder: (context, controller, _) => Column(
              children: [
                const SizedBox(height: GapSizes.xxxlarge),

                InfoBar(
                  title: 'Level ${controller.level}',
                  value: controller.xpLevelProgress,
                  goal: controller.xpLevelRequired,
                  percent: controller.xpLevelProgressPercent,
                  color: CoreColors.coreBlue,
                  textColor: CoreColors.coreOffBlue,
                ),
                
                const SizedBox(height: 20),
                
                // Placeholder for main character image
                Container(
                  height: 300,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(child: Text('Character Image')),
                ),
                
                const SizedBox(height: 20),
                
                // Rank section
                Row(
                  children: [
                    // Small placeholder image with rounded corners
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Rank progress bar
                    Expanded(
                      child: InfoBar(
                        title: '${controller.rank} Rank',
                        value: controller.xpRankProgress,
                        goal: controller.xpRankRequired,
                        percent: controller.xpRankProgressPercent,
                        color: CoreColors.coreGold,
                        textColor: CoreColors.coreGold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: controller.refreshXP,
                  child: const Text('Refresh XP'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 1),
      ),
    );
  }
}
