import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:novacall/data/model/call_model.dart';

class CallHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveCallToHistory({
    required String receiverId,
    required String receiverName,
    required bool isVideo,
    String? callID,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final callerName = userDoc.data()?['name'] ?? 'User';

      final id = callID ?? 'call_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('call_history').add({
        'callID': id,
        'callerId': currentUser.uid,
        'callerName': callerName,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'type': isVideo ? 'video' : 'audio',
        'status': 'outgoing',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'duration': 0,
      });

      debugPrint('✅ Call saved to history: $id');
    } catch (e) {
      debugPrint('❌ Error saving call: $e');
    }
  }

  Future<void> updateCallDuration({
    required String callID,
    required int durationInSeconds,
    required String status,
  }) async {
    try {
      final query = await _firestore
          .collection('call_history')
          .where('callID', isEqualTo: callID)
          .get();

      for (final doc in query.docs) {
        await doc.reference.update({
          'duration': durationInSeconds,
          'status': status,
        });
      }
      debugPrint('✅ Call duration updated: $durationInSeconds seconds');
    } catch (e) {
      debugPrint('❌ Error updating call duration: $e');
    }
  }

  Future<void> updateCallDurationFromFirestore(String callID) async {
    try {
      final query = await _firestore
          .collection('call_history')
          .where('callID', isEqualTo: callID)
          .get();

      for (final doc in query.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

        if (createdAt != null) {
          final duration = DateTime.now().difference(createdAt).inSeconds;
          final status = duration < 3 ? 'missed' : 'outgoing';

          await doc.reference.update({'duration': duration, 'status': status});
          debugPrint('✅ Duration updated: $duration seconds');
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating duration: $e');
    }
  }

  Future<void> updateLatestCallDuration() async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final query = await _firestore
          .collection('call_history')
          .where('callerId', isEqualTo: currentUserId)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      for (final doc in query.docs) {
        final data = doc.data();
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

        if (createdAt != null) {
          final duration = DateTime.now().difference(createdAt).inSeconds;
          final status = duration < 3 ? 'missed' : 'outgoing';

          await doc.reference.update({'duration': duration, 'status': status});
          debugPrint('✅ Duration updated: $duration seconds, status: $status');
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating duration: $e');
    }
  }

  Future<void> saveIncomingCall({
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required bool isVideo,
    required String callID,
  }) async {
    try {
      await _firestore.collection('call_history').add({
        'callID': callID,
        'callerId': callerId,
        'callerName': callerName,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'type': isVideo ? 'video' : 'audio',
        'status': 'incoming',
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'duration': 0,
      });
      debugPrint('✅ Incoming call saved: $callID');
    } catch (e) {
      debugPrint('❌ Error saving incoming call: $e');
    }
  }

  Future<void> saveCall(CallModel call) async {
    try {
      await _firestore.collection('call_history').add(call.toMap());
    } catch (e) {
      debugPrint('Error saving call: $e');
    }
  }

  Stream<List<CallModel>> getCallHistory() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    final outgoingStream = _firestore
        .collection('call_history')
        .where('callerId', isEqualTo: currentUserId)
        .snapshots();

    final incomingStream = _firestore
        .collection('call_history')
        .where('receiverId', isEqualTo: currentUserId)
        .snapshots();

    late StreamController<List<CallModel>> controller;
    StreamSubscription? outgoingSub;
    StreamSubscription? incomingSub;

    List<CallModel> outgoingCalls = [];
    List<CallModel> incomingCalls = [];

    void emitCombined() {
      final all = [...outgoingCalls, ...incomingCalls];
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(all);
    }

    controller = StreamController<List<CallModel>>.broadcast(
      onListen: () {
        outgoingSub = outgoingStream.listen((snapshot) {
          outgoingCalls = snapshot.docs
              .map((doc) => CallModel.fromMap(doc.data(), doc.id))
              .toList();
          emitCombined();
        });

        incomingSub = incomingStream.listen((snapshot) {
          incomingCalls = snapshot.docs
              .map((doc) => CallModel.fromMap(doc.data(), doc.id))
              .toList();
          emitCombined();
        });
      },
      onCancel: () {
        outgoingSub?.cancel();
        incomingSub?.cancel();
      },
    );

    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> getFrequentContacts() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return [];

    final outgoingSnapshot = await _firestore
        .collection('call_history')
        .where('callerId', isEqualTo: currentUserId)
        .get();

    final incomingSnapshot = await _firestore
        .collection('call_history')
        .where('receiverId', isEqualTo: currentUserId)
        .get();

    final allCalls = [
      ...outgoingSnapshot.docs.map((d) => d.data()),
      ...incomingSnapshot.docs.map((d) => d.data()),
    ];

    final Map<String, Map<String, dynamic>> contactCounts = {};

    for (final call in allCalls) {
      final callerId = call['callerId'] as String;
      final receiverId = call['receiverId'] as String;
      final callerName = call['callerName'] as String;
      final receiverName = call['receiverName'] as String;

      final otherId = callerId == currentUserId ? receiverId : callerId;
      final otherName = callerId == currentUserId ? receiverName : callerName;

      if (contactCounts.containsKey(otherId)) {
        contactCounts[otherId]!['count'] += 1;
      } else {
        contactCounts[otherId] = {'id': otherId, 'name': otherName, 'count': 1};
      }
    }

    final frequentList = contactCounts.values.toList();
    frequentList.sort(
      (a, b) => (b['count'] as int).compareTo(a['count'] as int),
    );

    return frequentList.take(5).toList();
  }

  Future<void> deleteCall(String callId) async {
    await _firestore.collection('call_history').doc(callId).delete();
  }

  Future<void> clearHistory() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    final snapshot = await _firestore
        .collection('call_history')
        .where('callerId', isEqualTo: currentUserId)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    final incomingSnapshot = await _firestore
        .collection('call_history')
        .where('receiverId', isEqualTo: currentUserId)
        .get();

    for (final doc in incomingSnapshot.docs) {
      await doc.reference.delete();
    }
  }
}
