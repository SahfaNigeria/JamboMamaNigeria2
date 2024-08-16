import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/controllers/chat_service.dart';

class AllowedToChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Query the allowed_to_chat collection based on user role
    // In the pregnant woman app, filter by recipientId
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected Health Provider(s)'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('allowed_to_chat')
            .where('requesterId', isEqualTo: userId) // Filter by requesterId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users to chat with'));
          }

          final allowedChats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: allowedChats.length,
            itemBuilder: (context, index) {
              final chatData =
                  allowedChats[index].data() as Map<String, dynamic>;
              final requesterId = chatData['recipientId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection(
                        'Health Professionals') // Query Health Provider collection
                    .doc(requesterId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return ListTile(title: Text('User not found'));
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final userName = userData['fullName'] ??
                      'No name'; // Ensure field name matches

                  return ListTile(
                    title: Text(userName),
                    onTap: () {
                      startChat(context, requesterId); // Pass the context here
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
