import 'package:flutter/material.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/services/error_logger.service.dart';
import '../../services/health_fetcher_service.dart';
import '../../enums/timeframe.enum.dart';

class HealthDetailsController extends ChangeNotifier {
  final HealthEntity _widget;
  final HealthFetcherService _healthFetcherService = HealthFetcherService();

  bool _isLoading = false;
  TimeFrame _selectedTimeFrame;
  int _offset;

  HealthDetailsController({
    required HealthEntity widget,
  }) : _widget = HealthEntity.from(widget),
       _selectedTimeFrame = widget.timeframe,
       _offset = widget.offset{
        _fetchData();
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
      _widget.updateData(await _healthFetcherService.fetchBatchData(
        [_widget],
      ));
    } catch (e) {
      await ErrorLogger.logError('Error fetching health data: $e');
    }

    _isLoading = false;
    _widget.isLoading = false;
    notifyListeners();
  }

  List<Widget> get getDetailWidgets => _widget.getDetailWidgets;
}
