import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/sizes.constants.dart';
import '../enums/timeframe.enum.dart';

class DateSelector extends StatefulWidget {
  final TimeFrame selectedTimeFrame;
  final int offset;
  final ValueChanged<int> onOffsetChanged;

  const DateSelector({
    super.key,
    required this.selectedTimeFrame,
    required this.offset,
    required this.onOffsetChanged,
  });

  @override
  DateSelectorState createState() => DateSelectorState();
}

class DateSelectorState extends State<DateSelector> with WidgetsBindingObserver {
  late DateTime now;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    now = DateTime.now();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkAndUpdateDate();
    }
  }

  void checkAndUpdateDate() {
    DateTime currentDate = DateTime.now();
    if (now.day != currentDate.day || now.month != currentDate.month || now.year != currentDate.year) {
      setState(() {
        now = currentDate;
      });
      widget.onOffsetChanged(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the displayed date based on selectedTimeFrame and offset
    DateTime displayedDate;

    switch (widget.selectedTimeFrame) {
      case TimeFrame.day:
        displayedDate = now.subtract(Duration(days: widget.offset * -1));
      case TimeFrame.week:
        displayedDate = now.subtract(Duration(days: widget.offset * -7));
      case TimeFrame.month:
        displayedDate = DateTime(now.year, now.month - widget.offset * -1, 1);
      case TimeFrame.year:
        displayedDate = DateTime(now.year - widget.offset * -1, 1, 1);
    }

    // Determine if right arrow should be disabled (can't go into the future)
    bool isRightArrowDisabled = widget.offset == 0;

    // Displayed date string
    String displayedDateString = '';

    switch (widget.selectedTimeFrame) {
      case TimeFrame.day:
        displayedDateString = DateFormat('MMMM d, yyyy').format(displayedDate);
      case TimeFrame.week:
        DateTime startOfWeek =
            displayedDate.subtract(Duration(days: displayedDate.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
        displayedDateString =
            '${DateFormat('MMM d').format(startOfWeek)} – ${DateFormat('MMM d, yyyy').format(endOfWeek)}';
      case TimeFrame.month:
        displayedDateString = DateFormat('MMMM yyyy').format(displayedDate);
      case TimeFrame.year:
        displayedDateString = DateFormat('yyyy').format(displayedDate);
    }

    // Arrow buttons
    Widget leftArrow = IconButton(
      icon: Icon(Icons.arrow_left),
      onPressed: () {
        widget.onOffsetChanged(widget.offset - 1);
      },
    );

    Widget rightArrow = IconButton(
      icon: Icon(Icons.arrow_right),
      onPressed: !isRightArrowDisabled
          ? () {
              widget.onOffsetChanged(widget.offset + 1);
            }
          : null,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        leftArrow,
        Text(
          displayedDateString,
          style: const TextStyle(fontSize: FontSizes.medium),
        ),
        rightArrow,
      ],
    );
  }
}
