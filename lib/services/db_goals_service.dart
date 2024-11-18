import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_service.dart';
import '../models/goal.model.dart';

class DBGoalsService extends DBService {
  final String collectionName = 'user_goals';
  Goal? _cachedGoal;

  DBGoalsService() : super();

  // Save goals (create or overwrite)
  Future<void> saveGoals(Goal goal) async {
    String? userId = getUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      // Save to Firestore
      await createDocument(
        collectionPath: collectionName,
        documentId: userId,
        data: goal.toMap(),
      );
      // Save to local cache
      await _saveGoalToCache(userId, goal);
      // Update in-memory cache
      _cachedGoal = goal;
    } catch (e) {
      print('Error saving goals: $e');
      rethrow;
    }
  }

  // Get goals
  Future<Goal?> getGoals() async {
    String? userId = getUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }

    // Check in-memory cache
    if (_cachedGoal != null) {
      return _cachedGoal;
    }

    // Check local storage
    Goal? localGoal = await _getGoalFromCache(userId);
    if (localGoal != null) {
      _cachedGoal = localGoal;
      return localGoal;
    }

    try {
      // Fetch from Firestore
      var snapshot = await readDocument(
        collectionPath: collectionName,
        documentId: userId,
      );
      if (snapshot.exists && snapshot.data() != null) {
        Goal goal = Goal.fromMap(snapshot.data()!);
        // Save to local cache
        await _saveGoalToCache(userId, goal);
        // Update in-memory cache
        _cachedGoal = goal;
        return goal;
      } else {
        // Create a new empty Goal object with initialized values set to 0
        Goal newGoal = Goal();
        await saveGoals(newGoal);
        return newGoal;
      }
    } catch (e) {
      print('Error retrieving goals: $e');
      rethrow;
    }
  }

  // Private methods for caching
  Future<void> _saveGoalToCache(String userId, Goal goal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String goalJson = jsonEncode(goal.toMap());
    await prefs.setString('goal_$userId', goalJson);
  }

  Future<Goal?> _getGoalFromCache(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? goalJson = prefs.getString('goal_$userId');
    if (goalJson != null) {
      Map<String, dynamic> goalMap = jsonDecode(goalJson);
      return Goal.fromMap(goalMap);
    } else {
      return null;
    }
  }

  // Update goals (specific fields)
  Future<void> updateGoals(Map<String, dynamic> updatedData) async {
    String? userId = getUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      // Update in Firestore
      await updateDocument(
        collectionPath: collectionName,
        documentId: userId,
        data: updatedData,
      );
      // Update local cache
      Goal? currentGoal = _cachedGoal ?? await getGoals();
      if (currentGoal != null) {
        Map<String, dynamic> goalMap = currentGoal.toMap();
        goalMap.addAll(updatedData);
        Goal updatedGoal = Goal.fromMap(goalMap);
        await _saveGoalToCache(userId, updatedGoal);
        _cachedGoal = updatedGoal;
      }
    } catch (e) {
      print('Error updating goals: $e');
      rethrow;
    }
  }

  // Delete goals
  Future<void> deleteGoals() async {
    String? userId = getUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }

    try {
      await deleteDocument(
        collectionPath: collectionName,
        documentId: userId,
      );
      // Remove from local cache
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('goal_$userId');
      _cachedGoal = null;
    } catch (e) {
      print('Error deleting goals: $e');
      rethrow;
    }
  }
}
