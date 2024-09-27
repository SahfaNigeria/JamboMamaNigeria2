import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/midwives/views/screens/chat_screen.dart';

Future<void> startChat(BuildContext context, String recipientId) async {
  try {
    // Create or fetch chat document
    String chatId = await _getOrCreateChatId(recipientId);
    // Navigate to chat screen
    print('Navigating to chat with ID: $chatId'); // Debugging line

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatId: chatId,
          senderCollection: 'New Mothers',
          senderNameField: 'full name',
          receiverCollection: 'Health Professionals',
          receiverNameField: 'fullName',
        ),
      ),
    );
  } catch (e) {
    print('Error starting chat: $e');
    // Handle error appropriately
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error starting chat')),
    );
  }
}

Future<String> _getOrCreateChatId(String recipientId) async {
  try {
    // Fetch all chat documents where the current user is a participant
    QuerySnapshot chatDocs = await FirebaseFirestore.instance
        .collection('chats')
        .where('participants',
            arrayContains: FirebaseAuth.instance.currentUser!.uid)
        .get();

    // Find a chat document that contains both the current user and the recipient
    DocumentSnapshot? chatDoc;
    for (var doc in chatDocs.docs) {
      List<dynamic> participants = doc['participants'];
      if (participants.contains(recipientId)) {
        chatDoc = doc;
        break;
      }
    }

    if (chatDoc == null) {
      // Create a new chat document if no existing chat is found
      DocumentReference chatRef =
          await FirebaseFirestore.instance.collection('chats').add({
        'participants': [FirebaseAuth.instance.currentUser!.uid, recipientId],
        'createdAt': Timestamp.now(),
      });
      return chatRef.id;
    } else {
      return chatDoc.id;
    }
  } catch (e) {
    print('Error fetching or creating chat: $e');
    throw e; // Re-throw to handle it in the calling function
  }
}


// Future<String> _getOrCreateChatId(String recipientId) async {
//   String chatId = '';
//   QuerySnapshot chatDocs = await FirebaseFirestore.instance
//       .collection('chats')
//       .where('participants',
//           arrayContains: FirebaseAuth.instance.currentUser!.uid)
//       .where('participants', arrayContains: recipientId)
//       .get();

//   if (chatDocs.docs.isEmpty) {
//     // Create a new chat document
//     DocumentReference chatRef =
//         await FirebaseFirestore.instance.collection('chats').add({
//       'participants': [FirebaseAuth.instance.currentUser!.uid, recipientId],
//       'createdAt': Timestamp.now(),
//     });
//     chatId = chatRef.id;
//   } else {
//     chatId = chatDocs.docs.first.id;
//   }

//   return chatId;
// }
