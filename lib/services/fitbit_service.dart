import 'package:fitbitter/fitbitter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:health/health.dart';
import 'package:healthxp/models/data_point.model.dart';
import 'package:healthxp/services/error_logger.service.dart';

class FitbitService {
  static final FitbitService _instance = FitbitService._internal();
  factory FitbitService() => _instance;

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  FitbitActivityTimeseriesDataManager? _fitbitDataManager;
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

    if (accessToken != null && userId != null && refreshToken != null) {
      _fitbitDataManager = FitbitActivityTimeseriesDataManager(
        clientID: dotenv.env['FITBIT_CLIENTID'] ?? '',
        clientSecret: dotenv.env['FITBIT_SECRET'] ?? '',
      );

      _fitbitCredentials = FitbitCredentials(
        fitbitAccessToken: accessToken,
        fitbitRefreshToken: refreshToken,
        userID: userId,
      );
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

  Future<Map<HealthDataType, List<DataPoint>>> fetchBatchData(
    Set<HealthDataType> items,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (_fitbitDataManager == null || _fitbitCredentials == null) {
      await _loadCredentials();
      if (_fitbitDataManager == null || _fitbitCredentials == null) {
        throw Exception('Not connected to Fitbit');
      }
    }

    Map<HealthDataType, List<DataPoint>> batchData = {};

    // Process each health type
    for (var healthType in items) {
      final resources = mapHealthItemTypeToFitbitEndpoint(healthType);
      if (resources != null) {
        List<DataPoint> combinedData = [];
        
        // Fetch data for each resource
        for (var resource in resources) {
          try {
            await ErrorLogger.logError('fetching fitbit data for $resource');
            final fitbitData = await _getFitbitDataInternal(startDate, endDate, resource);
            
            // Convert and add to combined data
            combinedData.addAll(fitbitData.map((f) {
              return DataPoint(
                value: f.value?.toDouble() ?? 0,
                dateFrom: f.dateOfMonitoring ?? DateTime.now(),
                dateTo: f.dateOfMonitoring ?? DateTime.now(),
              );
            }));
          } catch (e) {
            await ErrorLogger.logError('Error fetching Fitbit data for $resource: $e');
            rethrow;
          }
        }
        
        batchData[healthType] = combinedData;
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
