import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jambomama_nigeria/controllers/notifications.dart';
import 'package:jambomama_nigeria/providers/notification_model.dart';

class ConnectionStateModel with ChangeNotifier {
  Set<String> _requestedProfessionalIds = {};
  Set<String> _connectedProfessionalIds = {};

  // 🔄 Loading state per notification
  final Map<String, bool> _loadingStates = {};

  bool isLoading(String notificationId) =>
      _loadingStates[notificationId] ?? false;

  bool hasRequestedConnectionFor(String professionalId) {
    return _requestedProfessionalIds.contains(professionalId);
  }

  bool isConnectedTo(String professionalId) {
    return _connectedProfessionalIds.contains(professionalId);
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  Future<void> sendConnectionRequest(
      String requesterId, String professionalId) async {
    try {
      final requesterDoc =
          await _firestore.collection('New Mothers').doc(requesterId).get();
      final requesterName = requesterDoc.data()?['full name'] ?? 'Unknown';

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

  Future<void> loadConnectionStatus(String userId) async {
    try {
      // Fetch all accepted connections where the current user is the requester
      final snapshot = await _firestore
          .collection('allowed_to_chat')
          .where('requesterId', isEqualTo: userId)
          .get();

      final connectedIds =
          snapshot.docs.map((doc) => doc['recipientId'] as String).toSet();

      // Fetch all *pending* requests from this user
      final requestSnapshot = await _firestore
          .collection('notifications')
          .where('senderId', isEqualTo: userId)
          .where('type', isEqualTo: 'connection_request')
          .get();

      final requestedIds = requestSnapshot.docs
          .map((doc) => doc['recipientId'] as String)
          .toSet();

      _connectedProfessionalIds = connectedIds;
      _requestedProfessionalIds = requestedIds;

      notifyListeners();
    } catch (e) {
      print('❌ Error loading connection status: $e');
    }
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      var snapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromDocument(doc))
          .toList();

      return _notifications;
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> handleConnectionAction(
      String notificationId, String action) async {
    try {
      // Start loading
      _loadingStates[notificationId] = true;
      notifyListeners();

      final notificationDoc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();

      final notificationData = notificationDoc.data() as Map<String, dynamic>;

      final requesterId = notificationData['senderId'];
      final recipientId = notificationData['recipientId'];
      final requesterName = notificationData['requesterName'] ?? 'Unknown';
      String title = 'Connection Request Update';
      String message = '';

      if (action == 'accepted') {
        await _firestore.collection('allowed_to_chat').add({
          'requesterId': requesterId,
          'recipientId': recipientId,
        });

        _connectedProfessionalIds.add(recipientId);

        message = 'Your connection request was accepted';

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

        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .delete();
      } else if (action == 'declined') {
        message = 'Your connection request was declined';

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

        await _firestore
            .collection('notifications')
            .doc(notificationId)
            .delete();
      }

      await NotificationService.instance.triggerNotificationViaApi(
        title: title,
        message: message,
        userId: requesterId,
      );

      _notifications
          .removeWhere((notification) => notification.id == notificationId);
    } catch (e) {
      print('❌ Error handling connection action: $e');
    } finally {
      _loadingStates[notificationId] = false;
      notifyListeners();
    }
  }

  Future<void> notifyProviderOfEmergency({
    required String providerId,
    required String requesterId,
    required String requesterName,
    required String assessmentId,
  }) async {
    await _firestore.collection('notifications').add({
      'type': 'emergency_warning', // <- updated
      'senderId': requesterId,
      'recipientId': providerId,
      'patientId': requesterId, // <- added for clarity in navigation
      'patientName': requesterName,
      'assessmentId': assessmentId,
      'message': '$requesterName sent an emergency warning!',
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    try {
      await NotificationService.instance.triggerNotificationViaApi(
        title: '🚨 Emergency Warning',
        message: '$requesterName sent an emergency warning!',
        userId: providerId,
      );
      debugPrint('🔔 Push notification sent to provider $providerId');
    } catch (e) {
      debugPrint('⚠️ Could not send push: $e');
    }
  }
}
