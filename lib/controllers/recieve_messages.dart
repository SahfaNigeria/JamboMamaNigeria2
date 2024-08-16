import 'package:cloud_firestore/cloud_firestore.dart';

Stream<List<Message>> getMessagesStream(String chatId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Message(
        senderId: doc['senderId'],
        text: doc['text'],
        timestamp: doc['timestamp'].toDate(),
      );
    }).toList();
  });
}

class Message {
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });
}
