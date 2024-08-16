import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> sendMessage(String chatId, String text) async {
  try {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': FirebaseAuth.instance.currentUser!.uid,
      'text': text,
      'timestamp': Timestamp.now(),
    });
  } catch (e) {
    print('Error sending message: $e');
  }
}
