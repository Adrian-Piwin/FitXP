import 'dart:async';
import 'package:xpfitness/constants/health_data_types.constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fitbitter/fitbitter.dart';
import 'package:health/health.dart';
import '../models/data_point.model.dart';
import '../enums/timeframe.enum.dart';
import '../utility/timeframe.utility.dart';

class HealthFetcherService {
  final Health _health = Health();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isAuthorized = false;

  HealthFetcherService() {
    _initialize();
  }

  Future<void> _initialize() async {
    _isAuthorized = await _health.hasPermissions(healthDataTypes) == true;
  }

  Future<bool> _canUseFitbit(List<HealthDataType> healthtypes) async {
    String? accessToken = await _secureStorage.read(key: 'accessToken');
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    for (var healthtype in healthtypes) {
      if (_mapHealthItemTypeToFitbitEndpoint(healthtype) == null) {
        return false;
      }
    }
    return true;
  }

  Future<bool> checkAndRequestPermissions() async {
    _isAuthorized = await _health.hasPermissions(healthDataTypes) == true;
    if (!_isAuthorized) {
      _isAuthorized = await _health.requestAuthorization(healthDataTypes);
    }
    return _isAuthorized;
  }

  Future<Map<HealthDataType, List<DataPoint>>> fetchData(
      List<HealthDataType> items, TimeFrame timeframe, int offset) async {
    if (await _canUseFitbit(items)) {
      return _fetchFitbitData(items, timeframe, offset);
    } else {
      return _fetchHealthData(items, timeframe, offset);
    }
  }

  Future<Map<HealthDataType, List<DataPoint>>> _fetchHealthData(
      List<HealthDataType> items, TimeFrame timeframe, int offset) async {
    final dateRange = calculateDateRange(timeframe, offset);

    Map<HealthDataType, List<DataPoint>> data = {};
    for (var item in items) {
      // Steps arent fetched properly unless we do this
      if (item == HealthDataType.STEPS){
        final dateRange = calculateDateRange(timeframe, offset);
        final steps = await _health.getTotalStepsInInterval(dateRange.start, dateRange.end) ?? 0;
        data[item] = [DataPoint(dateFrom: dateRange.start, dateTo: dateRange.end, value: steps.toDouble())];
        continue;
      }

      final points = await _health.getHealthDataFromTypes(
        types: [item],
        startTime: dateRange.start,
        endTime: dateRange.end,
      );
      data[item] = points.map((p) {
        return DataPoint(
          value: (p.value as NumericHealthValue).numericValue.toDouble(),
          dateFrom: p.dateFrom,
          dateTo: p.dateTo,
        );
      }).toList();
    }
    return data;
  }

  Future<Map<HealthDataType, List<DataPoint>>> _fetchFitbitData(
      List<HealthDataType> items, TimeFrame timeframe, int offset) async {
    final accessToken = await _secureStorage.read(key: 'accessToken');
    final dateRange = calculateDateRange(timeframe, offset);
    final userId = await _secureStorage.read(key: 'userID');
    final refreshToken = await _secureStorage.read(key: 'refreshToken');

    FitbitActivityTimeseriesDataManager fitbitActivityTimeseriesDataManager = FitbitActivityTimeseriesDataManager(
      clientID: dotenv.env['FITBIT_CLIENTID'] ?? '',
      clientSecret: dotenv.env['FITBIT_SECRET'] ?? '',
    );
    FitbitCredentials fitbitCredentials = FitbitCredentials(
      fitbitAccessToken: accessToken!,
      fitbitRefreshToken: refreshToken!,
      userID: userId!
    );

    Map<HealthDataType, List<DataPoint>> data = {};

    for (var item in items) {
      final endpoint = _mapHealthItemTypeToFitbitEndpoint(item);
      if (endpoint != null) {
        var fitbitActivityTimeseriesApiUrl = FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
          fitbitCredentials: fitbitCredentials, 
          startDate: dateRange.start, 
          endDate: dateRange.end,
          resource: endpoint, 
        );

        List<FitbitActivityTimeseriesData> fitbitData = await fitbitActivityTimeseriesDataManager.getResponse(fitbitActivityTimeseriesApiUrl);

        data[item] = fitbitData.map((f) {
          return DataPoint(
            value: f.value!,
            dateFrom: f.dateOfMonitoring!,
            dateTo: f.dateOfMonitoring!,
          );
        }).toList();
      }
    }

    return data;
  }

  Resource? _mapHealthItemTypeToFitbitEndpoint(HealthDataType item) {
    switch (item) {
      case HealthDataType.STEPS:
        return Resource.steps;
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return Resource.activityCalories;
      default:
        return null; // Not available in Fitbit API
    }
  }
}
