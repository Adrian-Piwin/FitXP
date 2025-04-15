import 'package:flutter/material.dart';
import 'package:healthcore/components/premium_indicator.dart';
import 'package:healthcore/utility/superwall.utility.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
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
  bool _isPremiumUser = false;

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

    // Listen to changes and handle tab selection, checking for premium access when needed
    _tabController.addListener(_handleTabChange);
    initAsync();
  }

  Future<void> initAsync() async {
    final premiumStatus = await checkPremiumStatus();
    if (mounted) {
      setState(() {
        _isPremiumUser = premiumStatus;
      });
    }
  }

  /// Returns whether the currently selected timeframe requires premium access
  bool get isPremiumTimeframe {
    final selectedTimeFrame = _timeFrames[_tabController.index];
    return selectedTimeFrame == TimeFrame.year;
  }
  
  /// Handles tab changes, showing paywall for premium timeframes if needed
  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;
    
    final selectedTimeFrame = _timeFrames[_tabController.index];
    
    if (isPremiumTimeframe && !_isPremiumUser) {
      // Show paywall for premium timeframe
      Superwall.shared.registerPlacement(
        'SelectPremiumTimeframe',
        feature: () {
          // User has premium access now, update the timeframe
          setState(() {
            _isPremiumUser = true;
          });
          
          // Proceed with the timeframe change
          widget.onChanged(selectedTimeFrame);
        },
      );

      if (!_isPremiumUser) {
        // Revert to previous tab
        _tabController.animateTo(_timeFrames.indexOf(widget.selectedTimeFrame));
      }
    } else {
      // Standard timeframe or user has premium, proceed with change
      widget.onChanged(selectedTimeFrame);
    }
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
      
      // Re-attach the listener
      _tabController.addListener(_handleTabChange);
    }
    // Update the TabController index if the selectedTimeFrame changes externally.
    else if (widget.selectedTimeFrame != oldWidget.selectedTimeFrame) {
      _tabController.index = _timeFrames.indexOf(widget.selectedTimeFrame);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: _tabController,
      tabs: _timeFrames.map((timeFrame) {        
        // Show indicator for premium timeframes if user is not premium
        final showPremiumIndicator = isPremiumTimeframe && !_isPremiumUser;
        
        return Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(timeFrameToString(context, timeFrame)),
              if (showPremiumIndicator) ...[
                const SizedBox(width: 4),
                const PremiumIndicator(mini: true),
              ],
            ],
          ),
        );
      }).toList(),
      indicatorSize: TabBarIndicatorSize.tab,
    );
  }
}
