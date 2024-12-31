import 'package:healthxp/components/timeframe_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/bottom_nav_bar.dart';
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

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     _controller.refresh();
  //   }
  // }

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
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.displayWidgets.isEmpty) {
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
                        child: GridLayout(
                          widgets: controller.displayWidgets,
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
