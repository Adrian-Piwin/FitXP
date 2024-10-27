import 'package:flutter/material.dart';
import '../enums/timeframe.enum.dart';

class TimeFrameDropdown extends StatelessWidget {
  final TimeFrame selectedTimeFrame;
  final ValueChanged<TimeFrame> onChanged;

  const TimeFrameDropdown({
    super.key,
    required this.selectedTimeFrame,
    required this.onChanged,
  });

  // Build the dropdown menu items
  List<DropdownMenuItem<TimeFrame>> _buildDropdownMenuItems(BuildContext context) {
    return TimeFrame.values.map((TimeFrame timeFrame) {
      return DropdownMenuItem<TimeFrame>(
        value: timeFrame,
        child: Text(timeFrameToString(context, timeFrame)),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<TimeFrame>(
      value: selectedTimeFrame,
      items: _buildDropdownMenuItems(context),
      onChanged: (TimeFrame? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
    );
  }
}
