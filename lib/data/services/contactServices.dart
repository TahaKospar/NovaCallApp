import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Contactservices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAllContacts() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return [];

    final currentUserDoc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get();
    final blockedUsers = List<String>.from(
      currentUserDoc.data()?['blockedUsers'] ?? [],
    );

    final snapshot = await _firestore
        .collection("users")
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .get();

    return snapshot.docs
        .where((doc) => !blockedUsers.contains(doc.id))
        .map((doc) => doc.data())
        .toList();
  }

  Stream<List<Map<String, dynamic>>> getUserStream() async* {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      yield [];
      return;
    }

    final currentUserDoc = await _firestore
        .collection('users')
        .doc(currentUserId)
        .get();
    final blockedUsers = List<String>.from(
      currentUserDoc.data()?['blockedUsers'] ?? [],
    );

    yield* _firestore
        .collection("users")
        .where(FieldPath.documentId, isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) => !blockedUsers.contains(doc.id))
              .map((doc) => doc.data())
              .toList();
        });
  }

  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  Future<void> blockUser(String targetUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    await _firestore.collection('users').doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayUnion([targetUserId]),
    });
  }

  Future<void> unblockUser(String targetUserId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    await _firestore.collection('users').doc(currentUserId).update({
      'blockedUsers': FieldValue.arrayRemove([targetUserId]),
    });
  }

  Future<List<String>> getBlockedUsers() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return [];

    final doc = await _firestore.collection('users').doc(currentUserId).get();
    return List<String>.from(doc.data()?['blockedUsers'] ?? []);
  }
}
