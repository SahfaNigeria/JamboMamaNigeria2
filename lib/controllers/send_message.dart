import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jambomama_nigeria/controllers/notifications.dart';

Future<void> sendMessage(String chatId, String text) async {
  try {
    print('🚀 Starting sendMessage function');

    final currentUser = FirebaseAuth.instance.currentUser!;
    final senderId = currentUser.uid;

    // Add message to Firestore chat
    final messageRef = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.now(),
    });

    print('✅ Message sent successfully with ID: ${messageRef.id}');

    // Fetch chat document
    final chatDoc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

    if (!chatDoc.exists) {
      print('⚠️ Chat document does not exist: $chatId');
      return;
    }

    final participants = chatDoc.data()?['participants'] as List<dynamic>?;

    if (participants == null || participants.length < 2) {
      print('⚠️ Invalid participants list');
      return;
    }

    // Identify recipient
    final recipientId = participants.firstWhere(
      (id) => id != senderId,
      orElse: () => null,
    );

    if (recipientId == null) {
      print('⚠️ No recipient found (only one participant in chat)');
      return;
    }

    print('👤 Recipient ID: $recipientId');

    // Fetch recipient FCM token
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(recipientId)
        .get();

    if (!userDoc.exists) {
      print('⚠️ Recipient user document does not exist');
      return;
    }

    final recipientToken = userDoc.data()?['fcmToken'];

    if (recipientToken == null) {
      print('⚠️ Recipient does not have an FCM token');
    } else {
      try {
        // Send push notification
        await NotificationService.instance.triggerNotificationViaApi(
          userId: recipientId,
          title: autoI8lnGen.translate("NEW_MESSAGE"),
          message: text.length > 30 ? '${text.substring(0, 30)}...' : text,
        );
        print('✅ Push notification sent');
      } catch (notificationError) {
        print('⚠️ Error sending push notification: $notificationError');
        // Continue execution even if push notification fails
      }
    }

    try {
      // ✅ Save notification to Firestore for displaying in Notification screen
      final notificationRef =
          await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'message',
        'senderId': senderId,
        'recipientId': recipientId,
        'timestamp': Timestamp.now(),
        'message': text.length > 30 ? '${text.substring(0, 30)}...' : text,
        'chatId': chatId,
        'read': false,
      });

      print(
          '📌 Notification saved to Firestore with ID: ${notificationRef.id}');
    } catch (notificationSaveError) {
      print('❌ Error saving notification to Firestore: $notificationSaveError');
      // This isolates the notification saving error from the rest of the function
    }
  } catch (e) {
    print('❌ Error in sendMessage function: $e');
    print('❌ Error stack trace: ${StackTrace.current}');
  }
}




// // import 'package:cloud_firestore/cloud_firestore.dart';


// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:jambomama_nigeria/controllers/notifications.dart';

// // Future<void> sendMessage(
// //   String chatId,
// //   String text,
// // ) async {
// //   try {
// //     print('🚀 Starting sendMessage function');

// //     // Add message to Firestore
// //     final messageRef = await FirebaseFirestore.instance
// //         .collection('chats')
// //         .doc(chatId)
// //         .collection('messages')
// //         .add({
// //       'senderId': FirebaseAuth.instance.currentUser!.uid,
// //       'text': text,
// //       'timestamp': Timestamp.now(),
// //     });

// //     print('✅ Message sent successfully with ID: ${messageRef.id}');

// //     // Fetch chat document
// //     final chatDoc =
// //         await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

// //     if (!chatDoc.exists) {
// //       print('⚠️ Chat document does not exist: $chatId');
// //       return;
// //     }

// //     // Get participants list
// //     final participants = chatDoc.data()?['participants'] as List<dynamic>?;

// //     if (participants == null || participants.isEmpty) {
// //       print('⚠️ No participants found for chat: $chatId');
// //       return;
// //     }

// //     // Identify recipient
// //     final recipientId = participants.firstWhere(
// //       (id) => id != FirebaseAuth.instance.currentUser!.uid,
// //       orElse: () => null, // Avoids crash if there's no recipient
// //     );

// //     if (recipientId == null) {
// //       print('⚠️ No recipient found (only one participant in chat)');
// //       return;
// //     }

// //     print('👤 Recipient ID: $recipientId');

// //     // Fetch recipient's FCM token
// //     final userDoc = await FirebaseFirestore.instance
// //         .collection('users')
// //         .doc(recipientId)
// //         .get();

// //     if (!userDoc.exists) {
// //       print('⚠️ Recipient user document does not exist');
// //       return;
// //     }

// //     final recipientToken = userDoc.data()?['fcmToken'];

// //     if (recipientToken == null) {
// //       print('⚠️ Recipient does not have an FCM token');
// //       return;
// //     }

// //     print('📲 Sending push notification to: $recipientToken');

// //     // Send push notification
// //     // await NotificationService.instance.sendNotification(
// //     //   title: 'New Message',
// //     //   body: text.length > 30 ? '${text.substring(0, 30)}...' : text,
// //     //   data: {
// //     //     'chatId': chatId,
// //     //     'senderId': FirebaseAuth.instance.currentUser!.uid,
// //     //     'messageId': messageRef.id,
// //     //   },
// //     //   token: recipientToken,
// //     // );

// //     await NotificationService.instance.triggerNotificationViaApi(
// //       userId: recipientId,
// //       title: 'New Message',
// //       message: text.length > 30 ? '${text.substring(0, 30)}...' : text,
// //       //deeplink navigation
// //       //       data: {
// //       //   'screen': 'ChatScreen',
// //       //   'chatId': chatId,
// //       //   'senderCollection': 'users',
// //       //   'senderNameField': 'name',
// //       //   'receiverCollection': 'health_providers',
// //       //   'receiverNameField': 'full_name',
// //       // },
// //     );

// //     print('✅ Notification sent successfully');
// //   } catch (e) {
// //     print('❌ Error sending message: $e');
// //   }
// // }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:jambomama_nigeria/controllers/notifications.dart';

// Future<void> sendMessage(String chatId, String text) async {
//   try {
//     print('🚀 Starting sendMessage function');

//     final currentUser = FirebaseAuth.instance.currentUser!;
//     final senderId = currentUser.uid;

//     // Add message to Firestore chat
//     final messageRef = await FirebaseFirestore.instance
//         .collection('chats')
//         .doc(chatId)
//         .collection('messages')
//         .add({
//       'senderId': senderId,
//       'text': text,
//       'timestamp': Timestamp.now(),
//     });

//     print('✅ Message sent successfully with ID: ${messageRef.id}');

//     // Fetch chat document
//     final chatDoc =
//         await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

//     if (!chatDoc.exists) {
//       print('⚠️ Chat document does not exist: $chatId');
//       return;
//     }

//     final participants = chatDoc.data()?['participants'] as List<dynamic>?;

//     if (participants == null || participants.length < 2) {
//       print('⚠️ Invalid participants list');
//       return;
//     }

//     // Identify recipient
//     final recipientId = participants.firstWhere(
//       (id) => id != senderId,
//       orElse: () => null,
//     );

//     if (recipientId == null) {
//       print('⚠️ No recipient found (only one participant in chat)');
//       return;
//     }

//     print('👤 Recipient ID: $recipientId');

//     // Fetch recipient FCM token
//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(recipientId)
//         .get();

//     if (!userDoc.exists) {
//       print('⚠️ Recipient user document does not exist');
//       return;
//     }

//     final recipientToken = userDoc.data()?['fcmToken'];

//     if (recipientToken == null) {
//       print('⚠️ Recipient does not have an FCM token');
//     } else {
//       // Send push notification
//       await NotificationService.instance.triggerNotificationViaApi(
//         userId: recipientId,
//         title: 'New Message',
//         message: text.length > 30 ? '${text.substring(0, 30)}...' : text,
//       );

//       print('✅ Push notification sent');
//     }

//     // ✅ Save notification to Firestore for displaying in Notification screen
//     await FirebaseFirestore.instance.collection('notifications').add({
//       'type': 'message',
//       'senderId': senderId,
//       'recipientId': recipientId,
//       'timestamp': Timestamp.now(),
//       'message': text.length > 30 ? '${text.substring(0, 30)}...' : text,
//       'chatId': chatId,
//       'read': false,
//     });

//     print('📌 Notification saved to Firestore');
//   } catch (e) {
//     print('❌ Error sending message: $e');
//   }
// }
