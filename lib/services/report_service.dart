import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcore/services/error_logger.service.dart';

enum ReportType {
  featureRequest,
  bugReport,
  helpRequest,
}

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const int _maxReportsPerDay = 10;

  Future<bool> canSubmitReport() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final reports = await _firestore
          .collection('user_reports')
          .where('userId', isEqualTo: user.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .get();

      return reports.docs.length < _maxReportsPerDay;
    } catch (e) {
      await ErrorLogger.logError('Error checking report limit: $e');
      return false;
    }
  }

  Future<void> submitReport({
    required ReportType type,
    required String message,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      if (!await canSubmitReport()) {
        throw Exception('Daily report limit reached');
      }

      await _firestore.collection('user_reports').add({
        'userId': user.uid,
        'type': type.toString(),
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'email': user.email,
      });
    } catch (e) {
      await ErrorLogger.logError('Error submitting report: $e');
      rethrow;
    }
  }

  String getReportTypeLabel(ReportType type) {
    switch (type) {
      case ReportType.featureRequest:
        return 'Feature Request';
      case ReportType.bugReport:
        return 'Bug Report';
      case ReportType.helpRequest:
        return 'Get Help';
    }
  }
} 
