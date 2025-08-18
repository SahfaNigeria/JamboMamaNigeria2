import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/controllers/chat_service_mothers.dart';

class AllowedToChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Query the allowed_to_chat collection based on user role
    // In the pregnant woman app, filter by recipientId
    return Scaffold(
      appBar: AppBar(
        title: AutoText('HEALTH_PROVIDER'),
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
            return Center(
              child: AutoText(
                'ERROR_17',
              ),
            );
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
                    return ListTile(title: AutoText('LOADING_2'));
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return ListTile(title: AutoText('USER_NOT_FOUND'));
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final userName = userData['fullName'] ??
                      'NO_NAME'; // Ensure field name matches

                  return ListTile(
                    title: AutoText(
                      userName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      startChat(context, requesterId); // Pass the context here
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.chat,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            startChat(context, requesterId);
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.warning,
                            color: Colors.red,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
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
