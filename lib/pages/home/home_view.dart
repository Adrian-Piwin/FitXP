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

  DateTime? _lastResumeTime;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final now = DateTime.now();
      if (_lastResumeTime == null || 
          now.difference(_lastResumeTime!).inMinutes >= 10) {
        _controller.refreshToday();
        _lastResumeTime = now;
      }
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
              return Column(
                children: [
                  DateSelector(
                    selectedTimeFrame: controller.selectedTimeFrame,
                    offset: controller.offset,
                    onOffsetChanged: (newOffset) {
                      controller.updateOffset(newOffset);
                    },
                  ),
                  if (controller.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: GapSizes.xlarge),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.refresh,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            if (controller.headerWidgets.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(GapSizes.medium, GapSizes.medium, GapSizes.medium, 0),
                                child: HeaderWidgetItem(
                                  barWidgetConfig: controller.headerWidgets[0].getConfig,
                                  subWidgetFirstConfig: controller.headerWidgets[1].getConfig,
                                  subWidgetSecondConfig: controller.headerWidgets[2].getConfig,
                                  subWidgetThirdConfig: controller.headerWidgets[3].getConfig,
                                ),
                              ),
                            GridLayout(widgets: controller.displayWidgets.map((obj) => obj.generateWidget()).toList()),
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
