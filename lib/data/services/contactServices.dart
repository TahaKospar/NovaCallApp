import 'package:cloud_firestore/cloud_firestore.dart';

class Contactservices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAllContacts() async {
    final snapshot = await _firestore.collection("users").get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("users").snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data() 
      ).toList()
    );
  }
}