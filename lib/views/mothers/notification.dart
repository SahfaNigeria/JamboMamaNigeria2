import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientId', isEqualTo: currentUserId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              final type = data['type'];
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
              final formattedTime = timestamp != null
                  ? '${timestamp.day}-${timestamp.month}-${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'
                  : 'Unknown time';

              String title = 'New Notification';
              String subtitle = 'Tap to view';

              if (type == 'message') {
                title = 'New Message';
                subtitle = data['message'] ?? 'You have a new message';
              } else if (type == 'connection_request') {
                title = 'Connection Request';
                subtitle =
                    '${data['requesterName'] ?? 'Someone'} sent you a connection request';
              }

              return ListTile(
                title: Text(title),
                subtitle: Text('$subtitle\n$formattedTime'),
                isThreeLine: true,
                onTap: () => _handleTap(context, type, data),
              );
            },
          );
        },
      ),
    );
  }

  void _handleTap(
      BuildContext context, String? type, Map<String, dynamic> data) {
    if (type == 'message') {
      Navigator.pushNamed(
        context,
        '/ChatScreen',
        arguments: {
          'chatId': data['chatId'],
          // If needed later, you can pass senderId or fetch more user data
          'senderCollection': 'users',
          'senderNameField': 'name',
          'receiverCollection': 'health_providers',
          'receiverNameField': 'full_name',
        },
      );
    } else if (type == 'connection_request') {
      Navigator.pushNamed(
        context,
        '/ConnectionScreen',
        arguments: {
          'requesterId': data['requesterId'],
          'requesterName': data['requesterName'],
        },
      );
    }
  }
}
