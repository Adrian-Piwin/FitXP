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

  static List<BarData> _groupByDay(List<DataPoint> data, TimeFrame timeFrame, int offset) {
    final dateRange = calculateDateRange(timeFrame, offset);
    final startDate = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
    final endDate = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);
    
    final Map<String, double> dailyTotals = {};
    
    for (var point in data) {
      final dayKey = '${point.dateFrom.year}-${point.dateFrom.month}-${point.dateFrom.day}';
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + point.value;
    }

    final List<BarData> result = [];
    var currentDate = startDate;
    var index = 0;
    
    while (!currentDate.isAfter(endDate)) {
      final dayKey = '${currentDate.year}-${currentDate.month}-${currentDate.day}';
      
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

  static List<BarData> _groupByMonth(List<DataPoint> data, TimeFrame timeFrame, int offset) {
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }

  static String getXAxisLabel(List<BarData> groupedData, TimeFrame timeFrame, double value) {
    if (value < 0 || value >= groupedData.length) return '';
    
    if (timeFrame == TimeFrame.year) {
      return groupedData[value.toInt()].label; // Month name
    } else if (timeFrame == TimeFrame.day) {
      return '${value.toInt()}:00';
    } else {
      return groupedData[value.toInt()].label; // MM/DD
    }
  }
} 
