import 'dart:ui';
import 'package:healthxp/constants/colors.constants.dart';
import 'package:healthxp/enums/sleep_stages.enum.dart';
import 'package:healthxp/models/sleep_data_point.model.dart';

import '../models/bar_data.model.dart';
import '../models/data_point.model.dart';
import '../enums/timeframe.enum.dart';
import '../utility/timeframe.utility.dart';

class ChartUtility {
  static List<BarData> groupDataByTimeFrame(
    List<DataPoint> data,
    TimeFrame timeFrame,
    int offset,
  ) {
    switch (timeFrame) {
      case TimeFrame.day:
        return _groupByHour(data);
      case TimeFrame.week:
      case TimeFrame.month:
        return _groupByDay(data, timeFrame, offset);
      case TimeFrame.year:
        return _groupByMonth(data, timeFrame, offset);
    }
  }

  static List<BarData> _groupByHour(List<DataPoint> data) {
    Map<int, double> hourlyData = {};

    for (int i = 0; i < 24; i++) {
      hourlyData[i] = 0;
    }

    for (var point in data) {
      final hour = point.dateFrom.hour;
      hourlyData[hour] = (hourlyData[hour] ?? 0) + point.value;
    }

    return List.generate(24, (hour) {
      return BarData(
        x: hour.toDouble(),
        y: hourlyData[hour] ?? 0,
        label: '${hour.toString().padLeft(2, '0')}:00',
      );
    });
  }

  static List<BarData> _groupByDay(
      List<DataPoint> data, TimeFrame timeFrame, int offset) {
    final dateRange = calculateDateRange(timeFrame, offset);
    final startDate = DateTime(
        dateRange.start.year, dateRange.start.month, dateRange.start.day);
    final endDate =
        DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);

    final Map<String, double> dailyTotals = {};

    for (var point in data) {
      final dayKey =
          '${point.dayOccurred.year}-${point.dayOccurred.month}-${point.dayOccurred.day}';
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + point.value;
    }

    final List<BarData> result = [];
    var currentDate = startDate;
    var index = 0;

    while (!currentDate.isAfter(endDate)) {
      final dayKey =
          '${currentDate.year}-${currentDate.month}-${currentDate.day}';

      result.add(BarData(
        x: index.toDouble(),
        y: dailyTotals[dayKey] ?? 0,
        label: '${currentDate.month}/${currentDate.day}',
      ));

      currentDate = currentDate.add(const Duration(days: 1));
      index++;
    }

    return result;
  }

  static List<BarData> _groupByMonth(
      List<DataPoint> data, TimeFrame timeFrame, int offset) {
    final dateRange = calculateDateRange(timeFrame, offset);
    final startDate = dateRange.start;
    final endDate = dateRange.end;

    Map<DateTime, double> monthlyData = {};

    for (var point in data) {
      final date = DateTime(point.dayOccurred.year, point.dayOccurred.month);
      monthlyData[date] = (monthlyData[date] ?? 0) + point.value;
    }

    List<DateTime> allMonths = [];
    var currentDate = startDate;

    while (!currentDate.isAfter(endDate)) {
      allMonths.add(DateTime(currentDate.year, currentDate.month));
      currentDate = DateTime(currentDate.year, currentDate.month + 1);
    }

    return List.generate(12, (index) {
      final date = allMonths[index];
      return BarData(
        x: index.toDouble(),
        y: monthlyData[date] ?? 0,
        label: _getMonthName(date.month),
      );
    });
  }

  static String _getMonthName(int month) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }

  static String getXAxisLabel(
      List<BarData> groupedData, TimeFrame timeFrame, double value) {
    if (value < 0 || value >= groupedData.length) return '';

    if (timeFrame == TimeFrame.year) {
      return groupedData[value.toInt()].label; // Month name
    } else if (timeFrame == TimeFrame.day) {
      return '${value.toInt()}:00';
    } else {
      return groupedData[value.toInt()].label; // MM/DD
    }
  }

  static List<BarData> getSleepBarData(List<SleepDataPoint> sleepData) {
    List<BarData> barDataList = [];
    
    // Define stage labels and colors
    const Map<SleepStage, Map<String, dynamic>> stageInfo = {
      SleepStage.awake: {
        'label': 'Awake',
        'color': RepresentationColors.sleepAwakeColor,
        'order': 0
      },
      SleepStage.deep: {
        'label': 'Deep', 
        'color': RepresentationColors.sleepDeepColor,
        'order': 1
      },
      SleepStage.rem: {
        'label': 'REM',
        'color': RepresentationColors.sleepRemColor,
        'order': 2
      },
      SleepStage.light: {
        'label': 'Core',
        'color': RepresentationColors.sleepLightColor,
        'order': 3
      },
    };

    // Find overall sleep start and end times
    DateTime? earliestStart;
    DateTime? latestEnd;
    
    for (var dp in sleepData) {
      earliestStart = earliestStart == null || dp.dateFrom.isBefore(earliestStart)
          ? dp.dateFrom
          : earliestStart;
      latestEnd = latestEnd == null || dp.dateTo.isAfter(latestEnd)
          ? dp.dateTo
          : latestEnd;
    }

    if (earliestStart == null || latestEnd == null) return [];
    
    final totalDuration = latestEnd.difference(earliestStart).inMinutes.toDouble();

    // Process each sleep data point
    for (var dp in sleepData) {
      if (!stageInfo.containsKey(dp.sleepStage)) continue;

      final startOffset = dp.dateFrom.difference(earliestStart).inMinutes.toDouble();
      final duration = dp.dateTo.difference(dp.dateFrom).inMinutes.toDouble();
      
      barDataList.add(BarData(
        x: startOffset,  // Start position relative to sleep start
        y: duration,     // Duration of this sleep stage segment
        label: stageInfo[dp.sleepStage]!['label'] as String,
        color: stageInfo[dp.sleepStage]!['color'] as Color,
        order: stageInfo[dp.sleepStage]!['order'] as int,
        totalDuration: totalDuration,  // Add total duration for scaling
        timeLabel: '${dp.dateFrom.hour}:${dp.dateFrom.minute.toString().padLeft(2, '0')}',
      ));
    }

    // Sort by timestamp and stage order
    barDataList.sort((a, b) {
      int timeCompare = a.x.compareTo(b.x);
      if (timeCompare == 0) {
        return (a.order ?? 0).compareTo(b.order ?? 0);
      }
      return timeCompare;
    });

    return barDataList;
  }
}
