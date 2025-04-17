import 'package:flutter/material.dart';
import 'package:healthcore/models/health_entities/health_entity.model.dart';
import 'package:healthcore/services/error_logger.service.dart';
import '../../enums/timeframe.enum.dart';

class HealthDetailsController extends ChangeNotifier {
  final HealthEntity _widget;
  final List<TimeFrame> timeFrameOptions;

  bool _isLoading = false;
  TimeFrame _selectedTimeFrame;
  int _offset;

  HealthDetailsController({
    required HealthEntity widget,
  }) : _widget = widget.clone(),
       _selectedTimeFrame = widget.timeframe,
       _offset = widget.offset,
       timeFrameOptions = widget.supportedTimeFrames {
    _widget.addListener(_onWidgetChanged);
  }

  void _onWidgetChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _widget.removeListener(_onWidgetChanged);
    super.dispose();
  }

  bool get isLoading => _isLoading;
  TimeFrame get selectedTimeFrame => _selectedTimeFrame;
  int get offset => _offset;
  HealthEntity get widget => _widget;

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
    _widget.isLoading = true;
    notifyListeners();

    try {
      _widget.updateQuery(_selectedTimeFrame, _offset);
      await _widget.updateData();
    } catch (e) {
      GlobalUI.showError('Error fetching health data');
      await ErrorLogger.logError('Error fetching health data: $e');
    }

    _isLoading = false;
    _widget.isLoading = false;
    notifyListeners();
  }

  List<Widget> get getDetailWidgets => _widget.getDetailWidgets;
}
