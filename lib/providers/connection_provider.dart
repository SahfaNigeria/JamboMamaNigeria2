import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jambomama_nigeria/providers/notification_model.dart';

class ConnectionStateModel with ChangeNotifier {
  // bool _hasRequestedConnection = false;

  Set<String> _requestedProfessionalIds = {};

  bool hasRequestedConnectionFor(String professionalId) {
    return _requestedProfessionalIds.contains(professionalId);
  }

  // bool get hasRequestedConnection => _hasRequestedConnection;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to store notifications
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  Future<void> sendConnectionRequest(
      String requesterId, String professionalId) async {
    final requesterDoc = await FirebaseFirestore.instance
        .collection('New Mothers')
        .doc(requesterId)
        .get();
    final requesterName = requesterDoc.data()?['full name'] ?? 'Unknown';

    await FirebaseFirestore.instance.collection('notifications').add({
      'recipientId': professionalId,
      'requesterName': requesterName,
      'senderId': requesterId,
      'type': 'connection_request',
      'message': 'You have a new connection request',
      'read': false,
      'action': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
    // _hasRequestedConnection = true;
    // Mark the professional as having received a request
    _requestedProfessionalIds.add(professionalId);
    notifyListeners();
  }

  Future<void> createConnectionRequest(
      String requesterId, String recipientId) async {
    // Fetch the requester's name from Firestore or other source
    final requesterDoc = await FirebaseFirestore.instance
        .collection('New Mothers')
        .doc(requesterId)
        .get();
    final requesterName = requesterDoc.data()?['full name'] ?? 'Unknown';

    await FirebaseFirestore.instance.collection('notifications').add({
      'requesterId': requesterId,
      'recipientId': recipientId,
      'requesterName': requesterName,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    // Get the current user ID from Firebase Authentication
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception('User not logged in');
    }

    var snapshot = await _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => NotificationModel.fromDocument(doc))
        .toList();
  }

  //handle connection action

  Future<void> handleConnectionAction(
      String notificationId, String action) async {
    try {
      // Update the action in the notification document
      await _firestore.collection('notifications').doc(notificationId).update({
        'action': action,
      });

      if (action == 'accepted') {
        // Fetch the notification details to get the sender and recipient IDs
        DocumentSnapshot notificationDoc = await _firestore
            .collection('notifications')
            .doc(notificationId)
            .get();
        Map<String, dynamic> notificationData =
            notificationDoc.data() as Map<String, dynamic>;

        String requesterId = notificationData['senderId'];

        String recipientId = notificationData['recipientId'];

        // Create a document in the 'allowed_to_chat' collection
        await _firestore.collection('allowed_to_chat').add({
          'requesterId': requesterId,
          'recipientId': recipientId,
        });

        // Optionally, you might want to notify both users of the successful connection
        // You can add notification creation code here if needed
        // Delete the connection request from the 'notifications' collection
        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .delete();
      } else if (action == 'declined') {
        // Delete the connection request from the 'notifications' collection
        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .delete();
      }

      // Notify listeners if necessary
      notifyListeners();
    } catch (e) {
      // Handle errors, e.g., show a message to the user
      print('Error handling connection action: $e');
    }
  }

  // Future<void> handleConnectionAction(
  //     String notificationId, String action) async {
  //   await _firestore.collection('notifications').doc(notificationId).update({
  //     'action': action,
  //   });

  //   // Optionally, you might want to refresh the notifications list
  //   // await fetchNotifications(); // Update with actual provider ID
  // }

  // void resetConnectionRequest() {
  //   _hasRequestedConnection = false;
  //   notifyListeners();
  // }

  // Future<void> handleConnectionAction(
  //     String notificationId, String action) async {
  //   // Update the action in the notification document
  //   await _firestore.collection('notifications').doc(notificationId).update({
  //     'action': action,
  //   });

  //   if (action == 'accepted') {
  //     // Code to establish the connection in your database
  //   } else if (action == 'declined') {
  //     // Code to handle a declined connection request
  //     //   }

  //     notifyListeners();
  //   }
  // }
}
