import 'package:flutter/material.dart';
import '../enums/timeframe.enum.dart';

class TimeFrameTabBar extends StatefulWidget {
  final TimeFrame selectedTimeFrame;
  final ValueChanged<TimeFrame> onChanged;
  final List<TimeFrame>? timeFrameOptions;

  const TimeFrameTabBar({
    super.key,
    required this.selectedTimeFrame,
    required this.onChanged,
    this.timeFrameOptions,
  });

  @override
  TimeFrameTabBarState createState() => TimeFrameTabBarState();
}

class TimeFrameTabBarState extends State<TimeFrameTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<TimeFrame> _timeFrames;

  @override
  void initState() {
    super.initState();
    _timeFrames = widget.timeFrameOptions ?? TimeFrame.values;
    
    // Initialize the TabController based on the selected time frame.
    _tabController = TabController(
      length: _timeFrames.length,
      vsync: this,
      initialIndex: _timeFrames.indexOf(widget.selectedTimeFrame),
    );

    // Listen to changes and notify parent when a new tab is selected.
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        widget.onChanged(_timeFrames[_tabController.index]);
      }
    });
  }

  @override
  void didUpdateWidget(covariant TimeFrameTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update timeframes if options changed
    if (widget.timeFrameOptions != oldWidget.timeFrameOptions) {
      _timeFrames = widget.timeFrameOptions ?? TimeFrame.values;
      _tabController.dispose();
      _tabController = TabController(
        length: _timeFrames.length,
        vsync: this,
        initialIndex: _timeFrames.indexOf(widget.selectedTimeFrame),
      );
    }
    // Update the TabController index if the selectedTimeFrame changes externally.
    else if (widget.selectedTimeFrame != oldWidget.selectedTimeFrame) {
      _tabController.index = _timeFrames.indexOf(widget.selectedTimeFrame);
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
      tabs: _timeFrames.map((timeFrame) {
        return Tab(
          text: timeFrameToString(context, timeFrame),
        );
      }).toList(),
      indicatorSize: TabBarIndicatorSize.tab,
    );
  }
}
