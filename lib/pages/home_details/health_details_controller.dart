import 'package:flutter/material.dart';
import 'package:healthxp/components/info_widget.dart';
import 'package:healthxp/components/widget_frame.dart';
import 'package:healthxp/constants/sizes.constants.dart';
import 'package:healthxp/models/bar_data.model.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/health_widget.model.dart';
import 'package:healthxp/pages/home_details/health_details_barchart.dart';
import 'package:healthxp/services/error_logger.service.dart';
import '../../services/health_fetcher_service.dart';
import '../../enums/timeframe.enum.dart';
import '../../utility/chart.utility.dart';

class HealthDetailsController extends ChangeNotifier {
  final HealthWidget _widget;
  final HealthFetcherService _healthFetcherService = HealthFetcherService();

  bool _isLoading = false;
  TimeFrame _selectedTimeFrame;
  int _offset;
  List<DataPoint> _data = [];

  HealthDetailsController({
    required HealthWidget widget,
  }) : _widget = HealthWidget.from(widget),
       _selectedTimeFrame = widget.getTimeFrame,
       _offset = widget.getOffset{
        _fetchData();
       }

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
      await ErrorLogger.logError('Error fetching health data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> buildWidgets() {
    List<Map<String, dynamic>> widgets = [buildBarChartWidget()];
    
    for (Widget widget in _basicWidgets) {
      widgets.add(buildBasicWidget(widget));
    }
    
    return widgets;
  }

  // #region Basic widgets

  List<Widget> get _basicWidgets {
    return [
      InfoWidget(
        title: "Total",
        displayValue: _widget.getTotal.toStringAsFixed(0),
      ),
      InfoWidget(
        title: "Average",
        displayValue: _widget.getAverage.toStringAsFixed(0),
      ),
      InfoWidget(
        title: "Goal",
        displayValue: _widget.getGoal.toStringAsFixed(0),
      ),
      InfoWidget(
        title: "Goal Progress",
        displayValue: "${(_widget.getGoalAveragePercent * 100).toStringAsFixed(0)}%",
      ),
    ];
  }

  Map<String, dynamic> buildBasicWidget(Widget widget) {
    return {
      "size": 1,
      "height": WidgetSizes.smallHeight,
      "widget": widget
    };
  }

  // #endregion

  // #region Bar chart widget
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
    return ChartUtility.groupDataByTimeFrame(_data, _selectedTimeFrame, _offset);
  }

  String getXAxisLabel(double value) {
    return ChartUtility.getXAxisLabel(groupedData, _selectedTimeFrame, value);
  }
}
// #endregion
