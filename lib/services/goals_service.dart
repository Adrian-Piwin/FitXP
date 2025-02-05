import 'package:hive_flutter/hive_flutter.dart';
import 'package:healthxp/services/error_logger.service.dart';
import 'db_service.dart';

class GoalsService extends DBService {
  final String collectionName = 'user_goals';
  final Map<String, double> _cachedGoals = {};
  static const String _boxName = 'goals_box';
  late Box<double> _goalsBox;
  bool _isInitialized = false;

  // Private constructor
  GoalsService._() : super();

  // Static instance
  static GoalsService? _instance;

  // Factory constructor
  static Future<GoalsService> getInstance() async {
    if (_instance == null) {
      _instance = GoalsService._();
      await _instance!._initHive();
    }
    return _instance!;
  }

  Future<void> _initHive() async {
    if (!_isInitialized) {
      await Hive.initFlutter();
      _goalsBox = await Hive.openBox<double>(_boxName);
      _isInitialized = true;
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _initHive();
    }
  }

  String _normalizeGoalKey(String goalKey) {
    final parts = goalKey.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : goalKey.toUpperCase();
  }

  Future<double> getGoal(String goalKey) async {
    await _ensureInitialized();
    String? userId = getUserId();
    if (userId == null) throw Exception('User not logged in');

    final normalizedKey = _normalizeGoalKey(goalKey);

    if (_cachedGoals.containsKey(goalKey)) return _cachedGoals[goalKey]!;

    final localGoal = _getGoalFromCache(userId, goalKey);
    if (localGoal != null) {
      _cachedGoals[goalKey] = localGoal;
      return localGoal;
    }

    try {
      final snapshot = await readDocument(
        collectionPath: collectionName,
        documentId: userId,
      );

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        if (data.containsKey(normalizedKey)) {
          final goalValue = _parseFirestoreValue(data[normalizedKey]);
          await _saveGoalToCache(userId, goalKey, goalValue);
          _cachedGoals[goalKey] = goalValue;
          return goalValue;
        }
      }
      return 0.0;
    } catch (e) {
      await ErrorLogger.logError('Error retrieving goal for $goalKey: $e');
      return 0.0;
    }
  }

  Future<void> saveGoal(String goalKey, double value) async {
    await _ensureInitialized();
    String? userId = getUserId();
    if (userId == null) throw Exception('User not logged in');

    final normalizedKey = _normalizeGoalKey(goalKey);
    try {
      await updateDocument(
        collectionPath: collectionName,
        documentId: userId,
        data: {normalizedKey: value},
      );
      await _saveGoalToCache(userId, goalKey, value);
      _cachedGoals[goalKey] = value;
    } catch (e) {
      await ErrorLogger.logError('Error saving goal for $goalKey: $e');
      rethrow;
    }
  }

  Future<void> _saveGoalToCache(String userId, String goalKey, double value) async {
    await _goalsBox.put('${userId}_$goalKey', value);
  }

  double? _getGoalFromCache(String userId, String goalKey) {
    return _goalsBox.get('${userId}_$goalKey');
  }

  Future<void> clearCache() async {
    try {
      await _ensureInitialized();
      String? userId = getUserId();
      if (userId == null) return;

      _cachedGoals.clear();
      await _goalsBox.clear();
      
      final snapshot = await readDocument(
        collectionPath: collectionName,
        documentId: userId,
      );

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        for (var entry in data.entries) {
          final value = _parseFirestoreValue(entry.value);
          await _saveGoalToCache(userId, entry.key, value);
          _cachedGoals['HealthItemType.${entry.key}'.toLowerCase()] = value;
        }
      }
    } catch (e) {
      await ErrorLogger.logError('Error clearing goals cache: $e');
      rethrow;
    }
  }

  double _parseFirestoreValue(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  Future<void> dispose() async {
    if (_isInitialized && _goalsBox.isOpen) {
      await _goalsBox.close();
      _isInitialized = false;
    }
  }
}
