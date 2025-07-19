import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title:  AutoText('NOTIFICATIONS')),
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
            return const Center(child: AutoText('NO_NOTIFICATIONS'));
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
                  : autoI8lnGen.translate("UNKNOWN_TIME");

              String title =  autoI8lnGen.translate("NEW_NOTIFICATION");
              String subtitle =  autoI8lnGen.translate("TAP_TO_VIEW");

              if (type == 'message') {
                title = autoI8lnGen.translate("NEW_MESSAGE");
                subtitle = data['message'] ?? autoI8lnGen.translate("YOU_HAVE_A_NEW_MESSAGE");
              } else if (type == 'connection_request') {
                title = autoI8lnGen.translate("CONNECTION_REQUEST");
                subtitle =
                    autoI8lnGen.translate('${data['requesterName'] ?? 'SOMEONE'} SENT_YOU_REQUEST');
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
