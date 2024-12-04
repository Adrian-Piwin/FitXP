import 'dart:ui';

import 'package:health/health.dart';

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
          '${point.dateFrom.year}-${point.dateFrom.month}-${point.dateFrom.day}';
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
      final date = DateTime(point.dateFrom.year, point.dateFrom.month);
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

  static List<BarData> getSleepBarData(Map<HealthDataType, List<DataPoint>> sleepData) {
    List<BarData> barDataList = [];
    
    // Define stage labels and colors
    const Map<HealthDataType, Map<String, dynamic>> stageInfo = {
      HealthDataType.SLEEP_AWAKE: {
        'label': 'Awake',
        'color': Color(0xFFFF9800),  // Orange
        'order': 0
      },
      HealthDataType.SLEEP_DEEP: {
        'label': 'Deep',
        'color': Color(0xFF2196F3),
        'order': 1
      },
      HealthDataType.SLEEP_REM: {
        'label': 'REM',
        'color': Color(0xFF9C27B0),
        'order': 2
      },
      HealthDataType.SLEEP_LIGHT: {
        'label': 'Core',
        'color': Color(0xFF4CAF50),
        'order': 3
      },
    };

    // Find overall sleep start and end times
    DateTime? earliestStart;
    DateTime? latestEnd;
    
    for (var dataPoints in sleepData.values) {
      for (var dp in dataPoints) {
        earliestStart = earliestStart == null || dp.dateFrom.isBefore(earliestStart) 
            ? dp.dateFrom 
            : earliestStart;
        latestEnd = latestEnd == null || dp.dateTo.isAfter(latestEnd) 
            ? dp.dateTo 
            : latestEnd;
      }
    }

    if (earliestStart == null || latestEnd == null) return [];
    
    final totalDuration = latestEnd.difference(earliestStart).inMinutes.toDouble();

    // Process each sleep stage
    for (var entry in sleepData.entries) {
      final type = entry.key;
      if (!stageInfo.containsKey(type)) continue;

      for (var dp in entry.value) {
        final startOffset = dp.dateFrom.difference(earliestStart).inMinutes.toDouble();
        final duration = dp.dateTo.difference(dp.dateFrom).inMinutes.toDouble();
        
        barDataList.add(BarData(
          x: startOffset,  // Start position relative to sleep start
          y: duration,     // Duration of this sleep stage segment
          label: stageInfo[type]!['label'] as String,
          color: stageInfo[type]!['color'] as Color,
          order: stageInfo[type]!['order'] as int,
          totalDuration: totalDuration,  // Add total duration for scaling
          timeLabel: '${dp.dateFrom.hour}:${dp.dateFrom.minute.toString().padLeft(2, '0')}',
        ));
      }
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
