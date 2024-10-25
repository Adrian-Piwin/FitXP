import 'package:flutter/material.dart';
import '../enums/timeframe.enum.dart';
import '../utility/timeframe.utility.dart';

class TimeFrameTabBar extends StatefulWidget {
  final TimeFrame selectedTimeFrame;
  final ValueChanged<TimeFrame> onChanged;

  const TimeFrameTabBar({
    super.key,
    required this.selectedTimeFrame,
    required this.onChanged,
  });

  @override
  _TimeFrameTabBarState createState() => _TimeFrameTabBarState();
}

class _TimeFrameTabBarState extends State<TimeFrameTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController based on the selected time frame.
    _tabController = TabController(
      length: TimeFrame.values.length,
      vsync: this,
      initialIndex: TimeFrame.values.indexOf(widget.selectedTimeFrame),
    );

    // Listen to changes and notify parent when a new tab is selected.
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        widget.onChanged(TimeFrame.values[_tabController.index]);
      }
    });
  }

  @override
  void didUpdateWidget(covariant TimeFrameTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the TabController index if the selectedTimeFrame changes externally.
    if (widget.selectedTimeFrame != oldWidget.selectedTimeFrame) {
      _tabController.index = TimeFrame.values.indexOf(widget.selectedTimeFrame);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: _tabController,
      tabs: TimeFrame.values.map((timeFrame) {
        return Tab(
          text: timeFrameToString(context, timeFrame),
        );
      }).toList(),
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.black, // Selected tab text color.
      unselectedLabelColor: Colors.grey, // Unselected tab text color.
    );
  }
}
