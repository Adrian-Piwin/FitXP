import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DBService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DBService();

  // Get current user ID
  String? getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Create or set a document
  Future<void> createDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(documentId).set(data);
    } catch (e) {
      print('Error creating document: $e');
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
      print('Error reading document: $e');
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
      print('Error updating document: $e');
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
      print('Error deleting document: $e');
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
      print('Error querying collection: $e');
      rethrow;
    }
  }
}
