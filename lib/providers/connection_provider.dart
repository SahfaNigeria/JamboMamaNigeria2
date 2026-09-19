import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  Future<void> sendConnectionRequest({
    required String requesterId,
    required String professionalId,
    required String requesterName, // Pass the name directly to avoid "Unknown"
  }) async {
    // 1. GUARD: Prevent duplicate clicks if already loading or already requested
    if (_loadingStates[professionalId] == true ||
        _requestedProfessionalIds.contains(professionalId)) {
      return;
    }

    try {
      // 2. LOCK: Set loading state immediately
      _loadingStates[professionalId] = true;
      notifyListeners();

      // 3. DATABASE WRITE: Use the name passed from the UI/Auth Provider
      await _firestore.collection('notifications').add({
        'recipientId': professionalId,
        'requesterName': requesterName,
        'senderId': requesterId,
        'type': 'connection_request',
        'message': autoI8lnGen.translate("NEW_CONNECTION_REQUEST_MSG"),
        'read': false,
        'action': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 4. TRIGGER PUSH (FCM)
      try {
        await NotificationService.instance.triggerNotificationViaApi(
          title: autoI8lnGen.translate("NEW_CONNECTION_REQUEST"),
          message: '$requesterName ${autoI8lnGen.translate("S_N_R")}',
          userId: professionalId,
          senderId: requesterId,
        );
      } catch (e) {
        debugPrint('⚠️ FCM Error: $e');
      }

      // 5. UPDATE LOCAL STATE
      _requestedProfessionalIds.add(professionalId);
    } catch (e) {
      debugPrint('❌ Error sending connection request: $e');
    } finally {
      // 6. UNLOCK: Always release the lock, even on error
      _loadingStates[professionalId] = false;
      notifyListeners();
    }
  }

  Future<void> createConnectionRequest(
      String requesterId, String recipientId) async {
    if (requesterId.isEmpty || recipientId.isEmpty) return;

    try {
      final requesterDoc =
          await _firestore.collection('New Mothers').doc(requesterId).get();
      if (!requesterDoc.exists) return;

      final requesterName = requesterDoc.data()?['full name'] ??
          autoI8lnGen.translate("UNKNOWN_USER");

      await _firestore.collection('notifications').add({
        'type': 'connection_request',
        'requesterId': requesterId,
        'recipientId': recipientId,
        'senderId': requesterId,
        'requesterName': requesterName,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'read': false,
      });
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }

  Future<void> loadConnectionStatus(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('allowed_to_chat')
          .where('requesterId', isEqualTo: userId)
          .get();

      final connectedIds =
          snapshot.docs.map((doc) => doc['recipientId'] as String).toSet();

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
      debugPrint('❌ Error loading connection status: $e');
    }
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

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
      debugPrint('❌ Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> handleConnectionAction(
      String notificationId, String action) async {
    try {
      _loadingStates[notificationId] = true;
      notifyListeners();

      // 1. Get the data first
      final notificationDoc = await _firestore
          .collection('notifications')
          .doc(notificationId)
          .get();
      if (!notificationDoc.exists) return;

      final notificationData = notificationDoc.data() as Map<String, dynamic>;
      final requesterId = notificationData['senderId'];
      final recipientId = notificationData['recipientId'];

      // 2. DELETE THE REQUEST IMMEDIATELY
      // This stops the loop. Even if the rest fails, the button disappears.
      await _firestore.collection('notifications').doc(notificationId).delete();
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();

      // 3. Fetch Provider Name
      final providerDoc = await _firestore
          .collection('Health Professionals')
          .doc(recipientId)
          .get();
      final providerName = providerDoc.data()?['fullName'] ??
          autoI8lnGen.translate("HEALTHCARE_PROVIDER");

      String title = autoI8lnGen.translate("C_R_U");
      String apiMessage = '';

      if (action == 'accepted') {
        await _firestore.collection('allowed_to_chat').add({
          'requesterId': requesterId,
          'recipientId': recipientId,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _connectedProfessionalIds.add(recipientId);
        apiMessage = '$providerName ${autoI8lnGen.translate("Y_R_A")}';

        // Internal notification for the mother
        await _firestore.collection('notifications').add({
          'type': 'message',
          'status': 'accepted',
          'senderId': recipientId,
          'senderName': providerName,
          'recipientId': requesterId,
          'chatId': '${requesterId}_$recipientId',
          'message':
              '$providerName ${autoI8lnGen.translate("ACCEPTED_AND_CHAT")}',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      } else if (action == 'declined') {
        apiMessage = '$providerName ${autoI8lnGen.translate("Y_R_D")}';

        await _firestore.collection('notifications').add({
          'type': 'message',
          'status': 'declined',
          'senderId': recipientId,
          'senderName': providerName,
          'recipientId': requesterId,
          'message':
              '$providerName ${autoI8lnGen.translate("UNABLE_TO_ACCEPT")}',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });
      }

      // 4. TRIGGER API NOTIFICATION (Safe Block)
      try {
        await NotificationService.instance.triggerNotificationViaApi(
          title: title,
          message: apiMessage,
          userId: requesterId,
          senderId:
              recipientId, // NEW — the provider is the one acting/sending this notification
        );
      } catch (apiError) {
        // This catches the "FormatException: Unexpected character"
        // but allows the function to finish successfully!
        debugPrint(
            '⚠️ Notification API reported success but had format error: $apiError');
      }
    } catch (e) {
      debugPrint('❌ Critical Error in handleConnectionAction: $e');
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
    try {
      // Localized Database Message
      String dbMessage =
          '${autoI8lnGen.translate("EMERGENCY")}: $requesterName ${autoI8lnGen.translate("NEEDS_ASSESSMENT")}';

      await _firestore.collection('notifications').add({
        'type': 'emergency_warning',
        'senderId': requesterId,
        'recipientId': providerId,
        'patientId': requesterId,
        'requesterName': requesterName,
        'assessmentId': assessmentId,
        'message': dbMessage,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      // Localized Push Notification
      await NotificationService.instance.triggerNotificationViaApi(
        title: autoI8lnGen.translate('🚨 E_WARN'),
        message: '$requesterName ${autoI8lnGen.translate('SAEW')}',
        userId: providerId,
        senderId: requesterId,
      );
    } catch (e) {
      debugPrint('❌ Error sending emergency notification: $e');
    }
  }

  //Ending Connection

  // Inside ConnectionStateModel
  Future<void> endConnection(
      {required String currentUserId, required String otherUserId}) async {
    try {
      // Look for the connection where I am requester OR recipient
      final asRequester = await _firestore
          .collection('allowed_to_chat')
          .where('requesterId', isEqualTo: currentUserId)
          .where('recipientId', isEqualTo: otherUserId)
          .get();

      final asRecipient = await _firestore
          .collection('allowed_to_chat')
          .where('recipientId', isEqualTo: currentUserId)
          .where('requesterId', isEqualTo: otherUserId)
          .get();

      // Delete found documents
      for (var doc in [...asRequester.docs, ...asRecipient.docs]) {
        await _firestore.collection('allowed_to_chat').doc(doc.id).delete();
      }

      _connectedProfessionalIds.remove(otherUserId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error: $e');
    }
  }
}
