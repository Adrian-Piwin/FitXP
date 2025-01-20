import 'package:flutter/material.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/pages/character/components/character_stats_display.dart';
import 'package:healthxp/pages/character/components/character_tab_bar.dart';
import 'package:provider/provider.dart';
import 'package:healthxp/pages/character/character_controller.dart';
import 'package:healthxp/pages/character/components/character_model_viewer.dart';
import 'package:healthxp/components/animations/fade_transition_switcher.dart';
import 'package:healthxp/components/backgrounds/parallax_triangles_background.dart';
import 'package:healthxp/pages/character/components/progress_rings.dart';

class CharacterView extends StatefulWidget {
  CharacterView({super.key});

  @override
  State<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView> with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  final _modelViewerKey = GlobalKey<CharacterModelViewerState>();
  late final TabController _tabController;

  void _handleTabChange() {
    setState(() {});
    
    if (_tabController.index == 0) {
      _modelViewerKey.currentState?.animateToFrontView();
    } else {
      _modelViewerKey.currentState?.animateToSideView();
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ChangeNotifierProvider<CharacterController>(
      create: (context) => CharacterController(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<CharacterController>(
            builder: (context, controller, _) => Column(
              children: [
                const SizedBox(height: GapSizes.huge),
                
                SizedBox(
                  height: 500,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Background triangles
                      Positioned(
                        left: -MediaQuery.of(context).padding.left - 16,
                        right: -MediaQuery.of(context).padding.right - 16,
                        top: 0,
                        bottom: 0,
                        child: FadeTransitionSwitcher(
                          showChild: _tabController.index != 0,
                          fadeInDelay: Duration(milliseconds: 0),
                          fadeOutDelay: const Duration(milliseconds: 0),
                          fadeInSlideDistance: 0.25,
                          fadeOutSlideDistance: 0,
                          fadeInSlideDirection: SlideDirection.right,
                          fadeOutSlideDirection: SlideDirection.right,
                          child: const ParallaxTrianglesBackground(),
                        ),
                      ),
                      
                      // Progress Rings with fade transition
                      Positioned(
                        top: 0,
                        bottom: -280,
                        right: -5,
                        child: Center(
                          child: FadeTransitionSwitcher(
                            showChild: _tabController.index == 0,
                            fadeInDelay: Duration(milliseconds: 0),
                            fadeOutDelay: const Duration(milliseconds: 0),
                            child: ProgressRings(
                              xpRankProgressPercent: controller.xpRankProgressPercent,
                              xpLevelProgressPercent: controller.xpLevelProgressPercent,
                            ),
                          ),
                        ),
                      ),
                      
                      // Stats display with its own animations
                      Positioned.fill(
                        child: CharacterStatsDisplay(
                          showStats: _tabController.index == 0,
                          level: controller.level,
                          rank: controller.rank,
                        ),
                      ),
                      
                      // Character model
                      Positioned(
                        right: -50,
                        top: 0,
                        bottom: 50,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: CharacterModelViewer(key: _modelViewerKey),
                      ),
                    ],
                  ),
                ),
                
                CharacterTabBar(controller: _tabController),
                
                const SizedBox(height: 20),
                
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Column(
                        children: [
                          ElevatedButton(
                            onPressed: controller.refreshXP,
                            child: const Text('Refresh XP'),
                          ),
                        ],
                      ),
                      const Center(child: Text('Quests Coming Soon')),
                      const Center(child: Text('Friends Coming Soon')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
