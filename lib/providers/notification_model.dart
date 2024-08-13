import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String requesterName;
  final String message;
  final DateTime timestamp;
  final String status;

  NotificationModel({
    required this.id,
    required this.requesterName,
    required this.message,
    required this.timestamp,
    required this.status,
  });

  factory NotificationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      requesterName: data['requesterName'] ?? 'Unknown',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }
}
