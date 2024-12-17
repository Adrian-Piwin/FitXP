import 'package:fitbitter/fitbitter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health/health.dart';
import 'package:healthxp/enums/sleep_stages.enum.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/models/health_entities/health_entity.model.dart';
import 'package:healthxp/models/sleep_data_point.model.dart';
import 'package:healthxp/services/error_logger.service.dart';
import 'package:healthxp/utility/timeframe.utility.dart';

class FitbitService {
  static final FitbitService _instance = FitbitService._internal();
  factory FitbitService() => _instance;

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  FitbitActivityTimeseriesDataManager? _fitbitDataManager;
  FitbitSleepDataManager? _fitbitSleepDataManager;
  FitbitCredentials? _fitbitCredentials;

  bool get isConnected => _fitbitCredentials != null;

  FitbitService._internal() {
    initialize();
  }

  Future<void> initialize() async {
    await _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    await dotenv.load(fileName: ".env");
    final accessToken = await _secureStorage.read(key: 'accessToken');
    final userId = await _secureStorage.read(key: 'userID');
    final refreshToken = await _secureStorage.read(key: 'refreshToken');
    final lastTokenRefresh = await _secureStorage.read(key: 'lastTokenRefresh');
    final clientID = dotenv.env['FITBIT_CLIENTID'] ?? '';
    final clientSecret = dotenv.env['FITBIT_SECRET'] ?? '';

    if (accessToken != null && userId != null && refreshToken != null) {
      _fitbitDataManager = FitbitActivityTimeseriesDataManager(
        clientID: clientID,
        clientSecret: clientSecret,
      );

      _fitbitSleepDataManager = FitbitSleepDataManager(
        clientID: clientID,
        clientSecret: clientSecret,
      );

      _fitbitCredentials = FitbitCredentials(
        fitbitAccessToken: accessToken,
        fitbitRefreshToken: refreshToken,
        userID: userId,
      );

      if (lastTokenRefresh == null || 
        DateTime.now().difference(DateTime.parse(lastTokenRefresh)).inHours >= 24) {
        await _refreshToken();
      }
    }
  }

  Future<bool> connect() async {
    try {
      String clientID = dotenv.env['FITBIT_CLIENTID'] ?? '';
      String clientSecret = dotenv.env['FITBIT_SECRET'] ?? '';
      String redirectUri = dotenv.env['FITBIT_URI'] ?? '';
      String callbackUrlScheme = dotenv.env['FITBIT_URI_SCHEME'] ?? '';

      final credentials = await FitbitConnector.authorize(
        clientID: clientID,
        clientSecret: clientSecret,
        redirectUri: redirectUri,
        callbackUrlScheme: callbackUrlScheme,
      );

      if (credentials != null) {
        await _secureStorage.write(
            key: 'accessToken', value: credentials.fitbitAccessToken);
        await _secureStorage.write(
            key: 'refreshToken', value: credentials.fitbitRefreshToken);
        await _secureStorage.write(key: 'userID', value: credentials.userID);
        await _secureStorage.write(
          key: 'lastTokenRefresh', value: DateTime.now().toIso8601String());
        await _loadCredentials();
        return true;
      }
      return false;
    } catch (e) {
      await ErrorLogger.logError('Error connecting to Fitbit: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
    await _secureStorage.delete(key: 'userID');
    _fitbitCredentials = null;
    _fitbitDataManager = null;
  }

  Future<List<HealthDataType>> getSupportedHealthTypes(List<HealthDataType> healthTypes) async {
    if (!isConnected) return [];

    List<HealthDataType> supportedTypes = [];
    for (var healthType in healthTypes) {
      if (mapHealthItemTypeToFitbitEndpoint(healthType) != null) {
        supportedTypes.add(healthType);
      }
    }
    return supportedTypes;
  }

  bool isSleepSupported() {
    if (!isConnected) return false;
    return true;
  }

  Future<Map<HealthDataType, List<DataPoint>>> fetchBatchData(
    List<HealthEntity> entities,
  ) async {
    if (_fitbitDataManager == null || _fitbitCredentials == null) {
      await _loadCredentials();
      if (_fitbitDataManager == null || _fitbitCredentials == null) {
        throw Exception('Not connected to Fitbit');
      }
    }

    Map<HealthDataType, List<DataPoint>> batchData = {};

    // Group by health type
    for (var entity in entities) {
      for (var healthType in entity.healthItem.dataType) {
        final resources = mapHealthItemTypeToFitbitEndpoint(healthType);
        if (resources != null) {
          final dateRange = calculateDateRange(entity.timeframe, entity.offset);
          List<DataPoint> combinedData = [];
          
          for (var resource in resources) {
            try {
              final fitbitData = await _getFitbitDataInternal(
                dateRange.start,
                dateRange.end,
                resource
              );
              
              combinedData.addAll(fitbitData.map((f) => DataPoint(
                value: f.value?.toDouble() ?? 0,
                dateFrom: f.dateOfMonitoring ?? DateTime.now(),
                dateTo: f.dateOfMonitoring ?? DateTime.now(),
                dayOccurred: f.dateOfMonitoring ?? DateTime.now(),
              )));
            } catch (e) {
              await ErrorLogger.logError(
                'Error fetching Fitbit data for $resource: $e'
              );
              rethrow;
            }
          }
          
          if (!batchData.containsKey(healthType)) {
            batchData[healthType] = [];
          }
          batchData[healthType]!.addAll(combinedData);
        }
      }
    }

    return batchData;
  }

  Future<List<FitbitActivityTimeseriesData>> _getFitbitDataInternal(
      DateTime startDate, DateTime endDate, Resource resource) async {
    var url = FitbitActivityTimeseriesAPIURL.dateRangeWithResource(
      fitbitCredentials: _fitbitCredentials!,
      startDate: startDate,
      endDate: endDate,
      resource: resource,
    );

    List<FitbitData> data;
    try {
      data = await _fitbitDataManager!.fetch(url);
    } catch (e) {
      // Retry the request once after refreshing the token
      if (_isTokenExpiredError(e)) {
        await _refreshToken();
        data = await _fitbitDataManager!.fetch(url);
      } else {
        rethrow;
      }
    }
    
    return data as List<FitbitActivityTimeseriesData>;
  }

  Future<List<SleepDataPoint>> getFitbitSleepData(
      DateTime startDate, DateTime endDate) async {
    var url = endDate.difference(startDate).inDays == 1
        ? FitbitSleepAPIURL.day(
            fitbitCredentials: _fitbitCredentials!,
            date: startDate,
          )
        : FitbitSleepAPIURL.dateRange(
            fitbitCredentials: _fitbitCredentials!,
            startDate: startDate,
            endDate: endDate,
          );

    List<FitbitSleepData> data;
    try {
      data = await _fitbitSleepDataManager!.fetch(url) as List<FitbitSleepData>;
    } catch (e) {
      if (_isTokenExpiredError(e)) {
        await _refreshToken();
        data = await _fitbitSleepDataManager!.fetch(url) as List<FitbitSleepData>;
      } else {
        rethrow;
      }
    }

    // Sort data by entryDateTime
    data.sort((a, b) => (a.entryDateTime ?? DateTime.now())
        .compareTo(b.entryDateTime ?? DateTime.now()));

    // Process data into sleep points
    List<SleepDataPoint> sleepPoints = [];
    Map<String, Map<String, dynamic>> currentSession = {};  // Track each sleep session

    for (int i = 0; i < data.length; i++) {
      final point = data[i];
      final stage = _mapSleepStage(point.level);
      if (stage == SleepStage.unknown) continue;
      
      final entryTime = point.entryDateTime ?? DateTime.now();
      final sleepDate = point.dateOfSleep ?? entryTime;
      final sessionKey = '${sleepDate.year}-${sleepDate.month}-${sleepDate.day}';

      // Initialize or get current session data
      if (!currentSession.containsKey(sessionKey)) {
        currentSession[sessionKey] = {
          'currentStage': null,
          'stageStart': null,
        };
      }

      var session = currentSession[sessionKey]!;
      var currentStage = session['currentStage'] as SleepStage?;
      var stageStart = session['stageStart'] as DateTime?;

      // Handle first point of session
      if (currentStage == null) {
        currentStage = stage;
        stageStart = entryTime;
      }

      // If stage changes or last point of session
      bool isLastPointOfSession = i == data.length - 1 || 
          (i < data.length - 1 && (data[i + 1].dateOfSleep ?? data[i + 1].entryDateTime) != sleepDate);

      if (stage != currentStage || isLastPointOfSession) {
        final endTime = (isLastPointOfSession && stage == currentStage)
            ? entryTime.add(const Duration(seconds: 30))
            : entryTime;

        if (stageStart != null) {
          final duration = endTime.difference(stageStart).inSeconds / 60.0;
          
          sleepPoints.add(SleepDataPoint(
            value: duration,
            dateFrom: stageStart,
            dateTo: endTime,
            dayOccurred: sleepDate,
            sleepStage: currentStage,
          ));
        }

        // Start new stage
        currentStage = stage;
        stageStart = entryTime;
      }

      // Update session data
      session['currentStage'] = currentStage;
      session['stageStart'] = stageStart;
    }

    return sleepPoints;
  }

  SleepStage _mapSleepStage(String? level) {
    switch (level?.toLowerCase()) {
      case 'wake':
        return SleepStage.awake;
      case 'light':
        return SleepStage.light;
      case 'deep':
        return SleepStage.deep;
      case 'rem':
        return SleepStage.rem;
      default:
        return SleepStage.unknown;
    }
  }

  bool _isTokenExpiredError(dynamic error) {
    return error.toString().contains('token expired');
  }

  Future<void> _refreshToken() async {
    if (_fitbitCredentials?.fitbitRefreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final newCredentials = await FitbitConnector.refreshToken(
        clientID: dotenv.env['FITBIT_CLIENTID'] ?? '',
        clientSecret: dotenv.env['FITBIT_SECRET'] ?? '',
        fitbitCredentials: _fitbitCredentials!,
      );

      await _secureStorage.write(
          key: 'accessToken', value: newCredentials.fitbitAccessToken);
      await _secureStorage.write(
          key: 'refreshToken', value: newCredentials.fitbitRefreshToken);
      await _loadCredentials();
    } catch (e) {
      await ErrorLogger.logError('Error refreshing token: $e');
      await disconnect();
      throw Exception('Failed to refresh token, user needs to reconnect');
    }
  }

  List<Resource>? mapHealthItemTypeToFitbitEndpoint(HealthDataType item) {
    switch (item) {
      case HealthDataType.STEPS:
        return [Resource.steps];
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        return [Resource.activityCalories];
      case HealthDataType.BASAL_ENERGY_BURNED:
        return [Resource.caloriesBMR];
      case HealthDataType.EXERCISE_TIME:
        return [Resource.minutesFairlyActive, Resource.minutesVeryActive];
      default:
        return null;
    }
  }
}
