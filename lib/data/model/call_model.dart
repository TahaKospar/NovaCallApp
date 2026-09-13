import 'package:cloud_firestore/cloud_firestore.dart';

enum CallType { audio, video }

enum CallStatus { missed, incoming, outgoing, rejected }

class CallModel {
  final String id;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final CallType type;
  final CallStatus status;
  final DateTime createdAt;
  final int durationInSeconds;

  CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.type,
    required this.status,
    required this.createdAt,
    this.durationInSeconds = 0,
  });

  factory CallModel.fromMap(Map<String, dynamic> map, String id) {
    return CallModel(
      id: id,
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      type: map['type'] == 'video' ? CallType.video : CallType.audio,
      status: _parseStatus(map['status']),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationInSeconds: map['duration'] ?? 0,
    );
  }

  static CallStatus _parseStatus(String? status) {
    switch (status) {
      case 'missed':
        return CallStatus.missed;
      case 'incoming':
        return CallStatus.incoming;
      case 'outgoing':
        return CallStatus.outgoing;
      case 'rejected':
        return CallStatus.rejected;
      default:
        return CallStatus.missed;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'type': type.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'duration': durationInSeconds,
    };
  }

  bool isForUser(String userId) {
    return callerId == userId || receiverId == userId;
  }

  bool isMissed() {
    return status == CallStatus.missed ||
        (status == CallStatus.outgoing && durationInSeconds == 0);
  }

  bool isOutgoing(String userId) => callerId == userId;

  bool isIncoming(String userId) => receiverId == userId;
}
