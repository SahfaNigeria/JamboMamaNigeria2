import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/controllers/auth_controller.dart';
import 'package:jambomama_nigeria/controllers/notifications.dart';

Future<void> sendMessage(String chatId, String text) async {
  try {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final senderId = currentUser.uid;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.now(),
    });

    final chatDoc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      return;
    }

    final chatData = chatDoc.data();
    final participants = chatData?['participants'] as List<dynamic>?;

    if (participants == null || participants.length < 2) {
      return;
    }

    final recipientId = participants.firstWhere(
      (id) => id != senderId,
      orElse: () => null,
    );

    if (recipientId == null) {
      return;
    }

    // --- Resolve recipient's collection ---
    final participantRoles =
        chatData?['participantRoles'] as Map<String, dynamic>?;
    String? recipientCollection = participantRoles?[recipientId] as String?;

    DocumentSnapshot<Map<String, dynamic>>? userDoc;

    if (recipientCollection != null) {
      final doc = await FirebaseFirestore.instance
          .collection(recipientCollection)
          .doc(recipientId)
          .get();
      if (doc.exists) {
        userDoc = doc;
      }
    }

    if (userDoc == null) {
      final motherDoc = await FirebaseFirestore.instance
          .collection('New Mothers')
          .doc(recipientId)
          .get();

      if (motherDoc.exists) {
        userDoc = motherDoc;
        recipientCollection = 'New Mothers';
      } else {
        final providerDoc = await FirebaseFirestore.instance
            .collection('Health Professionals')
            .doc(recipientId)
            .get();
        if (providerDoc.exists) {
          userDoc = providerDoc;
          recipientCollection = 'Health Professionals';
        }
      }
    }

    if (userDoc == null) {
      return;
    }

    final recipientToken = userDoc.data()?['fcmToken'];

    // --- Resolve sender's own name ---
    String? senderCollection = participantRoles?[senderId] as String?;
    DocumentSnapshot<Map<String, dynamic>>? senderDoc;

    if (senderCollection != null) {
      final doc = await FirebaseFirestore.instance
          .collection(senderCollection)
          .doc(senderId)
          .get();
      if (doc.exists) {
        senderDoc = doc;
      }
    }

    if (senderDoc == null) {
      final motherDoc = await FirebaseFirestore.instance
          .collection('New Mothers')
          .doc(senderId)
          .get();

      if (motherDoc.exists) {
        senderDoc = motherDoc;
        senderCollection = 'New Mothers';
      } else {
        final providerDoc = await FirebaseFirestore.instance
            .collection('Health Professionals')
            .doc(senderId)
            .get();
        if (providerDoc.exists) {
          senderDoc = providerDoc;
          senderCollection = 'Health Professionals';
        }
      }
    }

    // Field name differs by collection: 'full name' (New Mothers) vs 'fullName' (Health Professionals)
    final senderName = senderCollection == 'New Mothers'
        ? (senderDoc?.data()?['full name'] as String? ?? 'Someone')
        : (senderDoc?.data()?['fullName'] as String? ?? 'Someone');

    if (recipientToken != null) {
      try {
        await NotificationService.instance.triggerNotificationViaApi(
          userId: recipientId,
          title: autoI8lnGen.translate("NEW_MESSAGE"),
          message: text.length > 30 ? '${text.substring(0, 30)}...' : text,
          senderId: senderId,
        );
        debugPrint('✅ Message delivered and notification sent to recipient');
      } catch (notificationError) {
        if (notificationError.toString().contains('404')) {
          await AuthController()
              .clearFcmToken(recipientCollection!, recipientId);
        }
      }
    }

    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'message',
        'senderId': senderId,
        'senderName': senderName,
        'recipientId': recipientId,
        'timestamp': Timestamp.now(),
        'message': text.length > 30 ? '${text.substring(0, 30)}...' : text,
        'chatId': chatId,
        'read': false,
      });
    } catch (_) {}
  } catch (_) {}
}


// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:jambomama_nigeria/controllers/auth_controller.dart';
// import 'package:jambomama_nigeria/controllers/notifications.dart';

// Future<void> sendMessage(String chatId, String text) async {
//   try {
//     final currentUser = FirebaseAuth.instance.currentUser!;
//     final senderId = currentUser.uid;

//     await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add({
//       'senderId': senderId,
//       'text': text,
//       'timestamp': Timestamp.now(),
//     });

//     final chatDoc =
//         await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

//     if (!chatDoc.exists) {
//       return;
//     }

//     final chatData = chatDoc.data();
//     final participants = chatData?['participants'] as List<dynamic>?;

//     if (participants == null || participants.length < 2) {
//       return;
//     }

//     final recipientId = participants.firstWhere(
//       (id) => id != senderId,
//       orElse: () => null,
//     );

//     if (recipientId == null) {
//       return;
//     }

//     // --- Resolve recipient's collection ---
//     // Option B: use participantRoles map on the chat doc if present
//     final participantRoles =
//         chatData?['participantRoles'] as Map<String, dynamic>?;
//     String? recipientCollection = participantRoles?[recipientId] as String?;

//     DocumentSnapshot<Map<String, dynamic>>? userDoc;

//     if (recipientCollection != null) {
//       final doc = await FirebaseFirestore.instance
//           .collection(recipientCollection)
//           .doc(recipientId)
//           .get();
//       if (doc.exists) {
//         userDoc = doc;
//       }
//     }

//     // Fallback: participantRoles missing or stale -> check both collections
//     if (userDoc == null) {
//       final motherDoc = await FirebaseFirestore.instance
//           .collection('New Mothers')
//           .doc(recipientId)
//           .get();

//       if (motherDoc.exists) {
//         userDoc = motherDoc;
//         recipientCollection = 'New Mothers';
//       } else {
//         final providerDoc = await FirebaseFirestore.instance
//             .collection('Health Professionals')
//             .doc(recipientId)
//             .get();
//         if (providerDoc.exists) {
//           userDoc = providerDoc;
//           recipientCollection = 'Health Professionals';
//         }
//       }
//     }

//     if (userDoc == null) {
//       return;
//     }

//     final recipientToken = userDoc.data()?['fcmToken'];

//     if (recipientToken != null) {
//       try {
//         await NotificationService.instance.triggerNotificationViaApi(
//           userId: recipientId,
//           title: autoI8lnGen.translate("NEW_MESSAGE"),
//           message: text.length > 30 ? '${text.substring(0, 30)}...' : text,
//           senderId:
//               senderId, // NEW: lets Divine's server resolve and attach the sender's name
//         );
//         debugPrint('✅ Message delivered and notification sent to recipient');
//       } catch (notificationError) {
//         // Stale/invalid token -> clear it so we stop retrying against it
//         if (notificationError.toString().contains('404')) {
//           await AuthController()
//               .clearFcmToken(recipientCollection!, recipientId);
//         }
//         // Notification send failed; message was still delivered to Firestore.
//       }
//     }

//     try {
//       await FirebaseFirestore.instance.collection('notifications').add({
//         'type': 'message',
//         'senderId': senderId,
//         'recipientId': recipientId,
//         'timestamp': Timestamp.now(),
//         'message': text.length > 30 ? '${text.substring(0, 30)}...' : text,
//         'chatId': chatId,
//         'read': false,
//       });
//     } catch (_) {
//       // Notification record save failed; non-critical.
//     }
//   } catch (_) {
//     // sendMessage failed silently; consider surfacing this to the caller/UI.
//   }
// }


