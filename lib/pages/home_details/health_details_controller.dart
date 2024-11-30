import 'package:flutter/material.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/health_widget.model.dart';
import 'package:healthxp/pages/home_details/health_details_barchart.dart';
import 'package:healthxp/utility/timeframe.utility.dart';
import '../../services/health_fetcher_service.dart';
import '../../enums/timeframe.enum.dart';

class HealthDetailsController extends ChangeNotifier {
  final HealthWidget _widget;
  final HealthFetcherService _healthFetcherService = HealthFetcherService();

  bool _isLoading = false;
  TimeFrame _selectedTimeFrame;
  int _offset;
  List<DataPoint> _data;

  HealthDetailsController({
    required HealthWidget widget,
  }) : _widget = HealthWidget.from(widget),
       _selectedTimeFrame = widget.getTimeFrame,
       _offset = widget.getOffset,
       _data = widget.getCombinedData;

  bool get isLoading => _isLoading;
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;
  List<DataPoint> get data => _data;

  Future<void> updateTimeFrame(TimeFrame newTimeFrame) async {
    _selectedTimeFrame = newTimeFrame;
    _offset = 0;
    await _fetchData();
  }

  Future<void> updateOffset(int newOffset) async {
    _offset = newOffset;
    await _fetchData();
  }

  Future<void> _fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _widget.updateData(await _healthFetcherService.fetchBatchData(
        _widget.healthItem.dataType,
        _selectedTimeFrame,
        _offset
      ));
      _data = _widget.getCombinedData;
    } catch (e) {
      _data = [];
      print('Error fetching health data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Map<String, dynamic> buildBarChartWidget() {
    return {
      "size": 2,
      "height": WidgetSizes.mediumHeight,
      "widget": WidgetFrame(child: groupedData.isEmpty 
        ? const Center(child: Text('No data available')) 
        : HealthDetailsBarChart(
          groupedData: groupedData,
          barColor: _widget.getConfig.color,
          getXAxisLabel: getXAxisLabel,
        )
      )
    };
  }

  List<BarData> get groupedData {
    if (_data.isEmpty) return [];

    switch (_selectedTimeFrame) {
      case TimeFrame.day:
        return _groupByHour();
      case TimeFrame.week:
      case TimeFrame.month:
        return _groupByDay();
      case TimeFrame.year:
        return _groupByMonth();
    }
  }

  List<BarData> _groupByHour() {
    Map<int, double> hourlyData = {};
    
    for (int i = 0; i < 24; i++) {
      hourlyData[i] = 0;
    }
    
    for (var point in _data) {
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

  List<BarData> _groupByDay() {
    // Get date range
    final dateRange = calculateDateRange(_selectedTimeFrame, _offset);
    final startDate = DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
    final endDate = DateTime(dateRange.end.year, dateRange.end.month, dateRange.end.day);
    
    // Create a map for summing values by day
    final Map<String, double> dailyTotals = {};
    
    // First, sum up all data points by day
    for (var point in _data) {
      final dayKey = '${point.dateFrom.year}-${point.dateFrom.month}-${point.dateFrom.day}';
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + point.value;
    }

    // Generate list of all days in range
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

  List<BarData> _groupByMonth() {
    Map<DateTime, double> monthlyData = {};
    
    // Determine year start and end
    final dateRange = calculateDateRange(_selectedTimeFrame, _offset);
    final DateTime startDate = dateRange.start;
    final DateTime endDate = dateRange.end;
    
    // Group existing data by month
    for (var point in _data) {
      final date = DateTime(point.dateFrom.year, point.dateFrom.month);
      monthlyData[date] = (monthlyData[date] ?? 0) + point.value;
    }

    // Create list of all months in the year
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

  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return monthNames[month - 1];
  }

  String getXAxisLabel(double value) {
    if (value < 0 || value >= groupedData.length) return '';
    
    if (_selectedTimeFrame == TimeFrame.year) {
      return groupedData[value.toInt()].label; // Month name
    } else if (_selectedTimeFrame == TimeFrame.day) {
      return '${value.toInt()}:00';
    } else {
      return groupedData[value.toInt()].label; // MM/DD
    }
  }
}

class BarData {
  final double x;
  final double y;
  final String label;

  BarData({required this.x, required this.y, required this.label});
}


