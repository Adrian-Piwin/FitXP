import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcore/services/error_logger.service.dart';

class DBService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DBService();

  // Get current user ID
  String? get userId => _auth.currentUser?.uid;

  // Create or set a document
  Future<void> createDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).set(data);
    } catch (e) {
      await ErrorLogger.logError('Error creating document: $e');
      rethrow;
    }
  }

  // Read a document
  Future<DocumentSnapshot<Map<String, dynamic>>> readDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(collectionPath).doc(documentId).get();
      return snapshot;
    } catch (e) {
      await ErrorLogger.logError('Error reading document: $e');
      rethrow;
    }
  }

  // Update a document
  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).update(data);
    } catch (e) {
      await ErrorLogger.logError('Error updating document: $e');
      rethrow;
    }
  }

  // Upsert a document
  Future<void> upsertDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).set(data, SetOptions(merge: true));
    } catch (e) {
      await ErrorLogger.logError('Error upserting document: $e');
      rethrow;
    }
  }

  // Delete a document
  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).delete();
    } catch (e) {
      await ErrorLogger.logError('Error deleting document: $e');
      rethrow;
    }
  }

  // Query a collection (read multiple documents)
  Future<QuerySnapshot<Map<String, dynamic>>> queryCollection({
    required String collectionPath,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
        queryBuilder,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collection(collectionPath);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
      return snapshot;
    } catch (e) {
      await ErrorLogger.logError('Error querying collection: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getDocument(String collection, String documentId) async {
    if (userId == null) return null;
    
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection(collection)
        .doc(documentId);
    
    final doc = await docRef.get();
    return doc.data();
  }

  Future<void> setDocument(String collection, String documentId, Map<String, dynamic> data) async {
    if (userId == null) return;
    
    await _firestore
        .collection('users')
        .doc(userId)
        .collection(collection)
        .doc(documentId)
        .set(data);
  }
}
