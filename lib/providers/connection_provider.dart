import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jambomama_nigeria/controllers/notifications.dart';
import 'package:jambomama_nigeria/providers/notification_model.dart';

class ConnectionStateModel with ChangeNotifier {
  Set<String> _requestedProfessionalIds = {};
  Set<String> _connectedProfessionalIds = {};

  bool hasRequestedConnectionFor(String professionalId) {
    return _requestedProfessionalIds.contains(professionalId);
  }

  bool isConnectedTo(String professionalId) {
    return _connectedProfessionalIds.contains(professionalId);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to store notifications
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  Future<void> sendConnectionRequest(
      String requesterId, String professionalId) async {
    try {
      // Fetch requester details
      final requesterDoc =
          await _firestore.collection('New Mothers').doc(requesterId).get();
      final requesterName = requesterDoc.data()?['full name'] ?? 'Unknown';

      // Create notification document regardless of token availability
      await _firestore.collection('notifications').add({
        'recipientId': professionalId,
        'requesterName': requesterName,
        'senderId': requesterId,
        'type': 'connection_request',
        'message': 'You have a new connection request',
        'read': false,
        'action': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      try {
        final professionalUserDoc =
            await _firestore.collection('users').doc(professionalId).get();
        final professionalToken = professionalUserDoc.data()?['fcmToken'];

        if (professionalToken != null) {
          // Send notification via API instead of direct push notification
          await NotificationService.instance.triggerNotificationViaApi(
            title: 'New Connection Request',
            message: '$requesterName sent you a connection request',
            userId: professionalId,
          );
          print(
              '🔔 API notification triggered for professionalId: $professionalId');
        } else {
          print(
              '⚠️ No FCM token available for professional, notification not sent');
        }
      } catch (e) {
        print('⚠️ Error triggering notification via API: $e');
      }

      // Mark as requested regardless of token availability
      _requestedProfessionalIds.add(professionalId);
      print('📩 Connection request created in database');
      notifyListeners();
    } catch (e) {
      print('❌ Error sending connection request: $e');
    }
  }

  Future<void> createConnectionRequest(
      String requesterId, String recipientId) async {
    if (requesterId.isEmpty || recipientId.isEmpty) {
      print('❌ requesterId or recipientId is empty.');
      return;
    }

    try {
      print('🔍 Fetching requester details for ID: $requesterId');
      final requesterDoc =
          await _firestore.collection('New Mothers').doc(requesterId).get();

      if (!requesterDoc.exists) {
        print('❌ Requester document does not exist.');
        return;
      }

      final requesterData = requesterDoc.data();
      if (requesterData == null) {
        print('❌ Requester data is null.');
        return;
      }

      final requesterName = requesterData['full name'] ?? 'Unknown';
      print('✅ Creating connection request for: $requesterName');

      final newNotification = {
        'type': 'connection_request',
        'requesterId': requesterId,
        'recipientId': recipientId,
        'senderId': requesterId,
        'requesterName': requesterName,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'read': false,
      };

      final docRef =
          await _firestore.collection('notifications').add(newNotification);
      print('📩 Connection request notification created with ID: ${docRef.id}');
    } catch (e, stackTrace) {
      print('❌ Exception occurred: $e');
      print('📌 Stack trace: $stackTrace');
    }
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      print('🔍 Fetching notifications...');

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      print('📡 Fetching notifications for user: $userId');

      var snapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      print('✅ Notifications fetched: ${snapshot.docs.length}');

      return snapshot.docs
          .map((doc) => NotificationModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> handleConnectionAction(
      String notificationId, String action) async {
    try {
      print('🔍 Handling connection action for notification: $notificationId');
      print('📢 Action: $action');

      // Fetch notification data to get sender and recipient info
      DocumentSnapshot notificationDoc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();

      Map<String, dynamic> notificationData =
          notificationDoc.data() as Map<String, dynamic>;

      String requesterId = notificationData['senderId'];
      String recipientId = notificationData['recipientId'];
      String requesterName = notificationData['requesterName'] ?? 'Unknown';
      String title = 'Connection Request Update';
      String message = '';

      // Handle different actions
      if (action == 'accepted') {
        print('✅ Connection accepted. Creating chat access...');

        // Create chat access
        await _firestore.collection('allowed_to_chat').add({
          'requesterId': requesterId,
          'recipientId': recipientId,
        });

        _connectedProfessionalIds.add(recipientId);
        print('✅ Connection established and chat allowed');

        message = 'Your connection request was accepted';

        // Create a new notification to inform the requester about acceptance
        await _firestore.collection('notifications').add({
          'type': 'connection_result',
          'status': 'accepted',
          'action': 'accepted',
          'senderId': recipientId,
          'recipientId': requesterId,
          'message': 'Your connection request to  was accepted',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
        print('📩 Created acceptance notification');

        // Delete the original notification
        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .delete();
        print('🗑️ Original notification deleted after acceptance');
      } else if (action == 'declined') {
        print('❌ Connection declined');
        message = 'Your connection request was declined';

        // Create a new notification to inform the requester about rejection
        await _firestore.collection('notifications').add({
          'type': 'connection_result',
          'status': 'declined',
          'action': 'declined',
          'senderId': recipientId,
          'recipientId': requesterId,
          'message': 'Your connection request to  was declined',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
        print('📩 Created rejection notification');

        // Delete the original notification
        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .delete();
        print('🗑️ Original notification deleted after decline');
      }

      // Send push notification to the requester
      await NotificationService.instance.triggerNotificationViaApi(
        title: title,
        message: message,
        userId: requesterId,
      );

      // Update local state to reflect the deletion
      _notifications
          .removeWhere((notification) => notification.id == notificationId);

      notifyListeners();
    } catch (e) {
      print('❌ Error handling connection action: $e');
    }
  }
}
