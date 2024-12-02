import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ErrorLogger {
  static const String _storageKey = 'error_logs';
  
  static Future<void> logError(String error, {StackTrace? stackTrace}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> logs = prefs.getStringList(_storageKey) ?? [];
      
      // Create error entry with timestamp
      final errorEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'error': error,
        'stackTrace': stackTrace?.toString(),
      };
      
      // Add new error to start of list (most recent first)
      logs.insert(0, jsonEncode(errorEntry));
      
      // Keep only last 100 errors to prevent excessive storage use
      if (logs.length > 100) {
        logs = logs.sublist(0, 100);
      }
      
      await prefs.setStringList(_storageKey, logs);
    } catch (e) {
      // Fail silently - we don't want error logging to cause more errors
      await ErrorLogger.logError('Error logging failed: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> logs = prefs.getStringList(_storageKey) ?? [];
      
      return logs.map((log) => jsonDecode(log) as Map<String, dynamic>).toList();
    } catch (e) {
      await ErrorLogger.logError('Error retrieving logs: $e');
      return [];
    }
  }

  static Future<void> clearLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      await ErrorLogger.logError('Error clearing logs: $e');
    }
  }
} 
