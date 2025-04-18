import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthcore/services/db_service.dart';
import 'package:healthcore/services/error_logger.service.dart';
import 'package:healthcore/enums/activity_level.enum.dart';

class UserService extends DBService {
  final String _userCollectionPath = 'users';
  final String _onboardingCompletedKey = 'onboarding_completed';

  Future<void> saveOnboardingData({
    bool? usesFoodLoggingApp,
    ActivityLevel? activityLevel,
    double? weight,
    int? age,
    bool? isMale,
    double? height,
    double? bodyFat,
  }) async {
    if (userId == null) throw Exception('User not logged in');

    try {
      // Save to Firestore
      final Map<String, dynamic> onboardingData = {
        'completedAt': DateTime.now().toIso8601String(),
        if (usesFoodLoggingApp != null) 'usesFoodLoggingApp': usesFoodLoggingApp,
        if (activityLevel != null) 'activityLevel': activityLevel.toString(),
        if (weight != null) 'weight': weight,
        if (age != null) 'age': age,
        if (isMale != null) 'isMale': isMale,
        if (height != null) 'height': height,
        if (bodyFat != null) 'bodyFat': bodyFat,
      };
      
      final userData = {
        'onboarding': onboardingData,
        'isOnboarded': true,
      };
      
      await createDocument(
        collectionPath: _userCollectionPath,
        documentId: userId!,
        data: {
          ...userData,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );
      
      // Save locally to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);
    } catch (e) {
      await ErrorLogger.logError('Error saving onboarding data: $e');
      rethrow;
    }
  }

  /// Checks if the user has completed onboarding (checks local storage first)
  Future<bool> hasCompletedOnboarding() async {
    // First check local storage for faster response
    final prefs = await SharedPreferences.getInstance();
    final localStatus = prefs.getBool(_onboardingCompletedKey);
    
    if (localStatus != null) {
      return localStatus;
    }
    
    // If not in local storage, check Firestore
    if (userId == null) {
      return false;
    }
    
    try {
      final userDoc = await readDocument(
        collectionPath: _userCollectionPath,
        documentId: userId!,
      );
      
      final isOnboarded = userDoc.data()?['isOnboarded'] ?? false;
      
      // Cache the result locally
      if (isOnboarded) {
        await prefs.setBool(_onboardingCompletedKey, true);
      }
      
      return isOnboarded;
    } catch (e) {
      // If there's an error (e.g., document doesn't exist), user isn't onboarded
      return false;
    }
  }
  
  /// Gets the user's onboarding data
  Future<Map<String, dynamic>?> getOnboardingData() async {
    if (userId == null) {
      return null;
    }
    
    try {
      final userDoc = await readDocument(
        collectionPath: _userCollectionPath,
        documentId: userId!,
      );
      
      return userDoc.data()?['onboarding'] as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
  
  /// Deletes all user data from Firestore
  Future<void> deleteUserData() async {
    if (userId == null) {
      throw Exception('User must be authenticated to delete data');
    }

    try {
      // Delete user document and all subcollections
      await deleteDocument(
        collectionPath: _userCollectionPath,
        documentId: userId!,
      );

      // Clear local preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompletedKey);
    } catch (e) {
      await ErrorLogger.logError('Error deleting user data: $e');
      rethrow;
    }
  }
} 
