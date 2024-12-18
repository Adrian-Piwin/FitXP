import 'package:healthxp/components/timeframe_tabbar.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/bottom_nav_bar.dart';
import 'header_widget_item.dart';
import '../../components/grid_layout.dart';
import 'home_controller.dart';
import '../../components/date_selector.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  static const routeName = "/home";

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  late HomeController _controller;
  bool _showLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.refreshToday();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        _controller = HomeController(context);
        return _controller;
      },
      child: Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Consumer<HomeController>(
              builder: (context, controller, _) {
                return TimeFrameTabBar(
                  selectedTimeFrame: controller.selectedTimeFrame,
                  onChanged: (newTimeFrame) {
                    controller.updateTimeFrame(newTimeFrame);
                  },
                );
              },
            ),
          ),
          body: Consumer<HomeController>(
            builder: (context, controller, _) {
              if (controller.isLoading && !_showLoading) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted && controller.isLoading) {
                    setState(() => _showLoading = true);
                  }
                });
              } else if (!controller.isLoading && _showLoading) {
                _showLoading = false;
              }

              if (controller.headerWidgets.isEmpty ||
                  controller.displayWidgets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load widgets'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.refresh,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (_showLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Column(
                children: [
                  DateSelector(
                    selectedTimeFrame: controller.selectedTimeFrame,
                    offset: controller.offset,
                    onOffsetChanged: controller.updateOffset,
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.refresh,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  GapSizes.medium,
                                  GapSizes.medium,
                                  GapSizes.medium,
                                  0),
                              child: HeaderWidgetItem(
                                barWidget: controller.headerWidgets[0],
                                subWidgetFirst: controller.headerWidgets[1],
                                subWidgetSecond: controller.headerWidgets[2],
                                subWidgetThird: controller.headerWidgets[3],
                              ),
                            ),
                            GridLayout(
                                widgets: controller.displayWidgets
                                    .map((obj) => obj.generateWidget())
                                    .toList()),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
          bottomNavigationBar: const BottomNavBar(currentIndex: 0)),
    );
  }
}
