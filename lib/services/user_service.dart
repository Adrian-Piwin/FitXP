import 'package:shared_preferences/shared_preferences.dart';
import 'package:healthcore/services/db_service.dart';
import 'package:healthcore/services/error_logger.service.dart';

enum FitnessGoal {
  gainWeight,
  maintainWeight,
  loseWeight,
}

enum ActivityLevel {
  none,     // 0 hours
  light,    // 1-2 hours
  moderate, // 3-4 hours
  active,   // 5-6 hours
  veryActive // 7+ hours
}

class UserService extends DBService {
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _userCollectionPath = 'users';
  
  // Singleton pattern
  static final UserService _instance = UserService._internal();
  
  factory UserService() {
    return _instance;
  }
  
  UserService._internal();
  
  /// Saves the user's onboarding data to Firestore and marks onboarding as completed locally
  Future<void> saveOnboardingData({
    bool? usesFoodLoggingApp,
    FitnessGoal? fitnessGoal,
    ActivityLevel? activityLevel,
  }) async {
    if (userId == null) {
      throw Exception('User must be authenticated to save onboarding data');
    }
    
    // Save to Firestore, only including data that was explicitly provided
    final Map<String, dynamic> onboardingData = {
      'completedAt': DateTime.now().toIso8601String(),
    };
    
    // Only add fields that the user actually provided
    if (usesFoodLoggingApp != null) {
      onboardingData['usesFoodLoggingApp'] = usesFoodLoggingApp;
    }
    
    if (fitnessGoal != null) {
      onboardingData['fitnessGoal'] = fitnessGoal.toString();
    }
    
    if (activityLevel != null) {
      onboardingData['activityLevel'] = activityLevel.toString();
    }
    
    await updateDocument(
      collectionPath: _userCollectionPath,
      documentId: userId!,
      data: {
        'onboarding': onboardingData,
        'isOnboarded': true,
      },
    );
    
    // Save locally to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
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
  
  /// Resets onboarding status (for testing purposes)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompletedKey);
    
    if (userId != null) {
      await updateDocument(
        collectionPath: _userCollectionPath,
        documentId: userId!,
        data: {'isOnboarded': false},
      );
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
