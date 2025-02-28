import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jambomama_nigeria/controllers/notifications.dart';

Future<void> sendMessage(String chatId, String text) async {
  try {
    print('🚀 Starting sendMessage function');

    // Add message to Firestore
    final messageRef = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': FirebaseAuth.instance.currentUser!.uid,
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

    // Get participants list
    final participants = chatDoc.data()?['participants'] as List<dynamic>?;

    if (participants == null || participants.isEmpty) {
      print('⚠️ No participants found for chat: $chatId');
      return;
    }

    // Identify recipient
    final recipientId = participants.firstWhere(
      (id) => id != FirebaseAuth.instance.currentUser!.uid,
      orElse: () => null, // Avoids crash if there's no recipient
    );

    if (recipientId == null) {
      print('⚠️ No recipient found (only one participant in chat)');
      return;
    }

    print('👤 Recipient ID: $recipientId');

    // Fetch recipient's FCM token
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
      return;
    }

    print('📲 Sending push notification to: $recipientToken');

    // Send push notification
    await NotificationService.instance.sendNotification(
      title: 'New Message',
      body: text.length > 30 ? '${text.substring(0, 30)}...' : text,
      data: {
        'chatId': chatId,
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'messageId': messageRef.id,
      },
      token: recipientToken,
    );

    print('✅ Notification sent successfully');
  } catch (e) {
    print('❌ Error sending message: $e');
  }
}
