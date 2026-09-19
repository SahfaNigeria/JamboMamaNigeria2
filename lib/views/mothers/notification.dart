import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/midwives/views/screens/provider_warning_screen.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: AutoText('NOTIFICATIONS'),
        centerTitle: true,
      ),
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
              final status = data['status'];
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate();

              final formattedTime = timestamp != null
                  ? '${timestamp.day}-${timestamp.month}-${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'
                  : autoI8lnGen.translate("UNKNOWN_TIME");

              // Proper Localization Context
              String title = autoI8lnGen.translate("NEW_NOTIFICATION");
              // Check if message is a translation key or raw text
              String subtitle = data['message'] != null
                  ? (data['message'].toString().contains('_')
                      ? autoI8lnGen.translate(data['message'])
                      : data['message'])
                  : autoI8lnGen.translate("TAP_TO_VIEW");

              IconData icon = Icons.notifications_none;
              Color iconColor = Colors.grey;

              // 1. Connection Results (Read-only logic)
              if (type == 'message' || type == 'connection_result') {
                if (status == 'accepted') {
                  title = autoI8lnGen.translate("REQUEST_ACCEPTED");
                  icon = Icons.check_circle_outline;
                  iconColor = Colors.green;
                } else if (status == 'declined') {
                  title = autoI8lnGen.translate("REQUEST_DECLINED");
                  icon = Icons.cancel_outlined;
                  iconColor = Colors.red;
                } else {
                  // NEW: plain chat message, no status — show sender's name
                  title = data['senderName'] as String? ??
                      autoI8lnGen.translate("NEW_NOTIFICATION");
                  icon = Icons.message_outlined;
                  iconColor = Colors.blueAccent;
                }
              }
              // 2. Connection Requests (Midwife Side)
              else if (type == 'connection_request') {
                title = autoI8lnGen.translate("CONNECTION_REQUEST");
                subtitle =
                    '${data['requesterName'] ?? autoI8lnGen.translate('SOMEONE')} ${autoI8lnGen.translate('SENT_YOU_REQUEST')}';
                icon = Icons.person_add_outlined;
                iconColor = Colors.green;
              }
              // 3. Emergency Warnings
              else if (type == 'emergency_warning') {
                title = '${autoI8lnGen.translate("EMERGENCY_WARNING")}';
                icon = Icons.warning_amber_rounded;
                iconColor = Colors.red;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(icon, color: iconColor),
                  ),
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$subtitle\n$formattedTime'),
                  isThreeLine: true,
                  onTap: () => _handleTap(context, type, data, doc.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Handle Action and Cleanup
  void _handleTap(BuildContext context, String? type, Map<String, dynamic> data,
      String docId) async {
    // 1. Logic for Connection Requests (Navigation allowed for Medics to take action)
    if (type == 'connection_request') {
      Navigator.pushNamed(
        context,
        '/ConnectionScreen',
        arguments: {
          'requesterId': data['requesterId'],
          'requesterName': data['requesterName'],
          'notificationId':
              docId, // Pass ID so it can be deleted after accept/decline
        },
      );
    }
    // 2. Logic for Emergency Warnings (Critical Navigation)
    else if (type == 'emergency_warning') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HealthcareProfessionalAssessmentScreen(
            assessmentId: data['assessmentId'],
            patientId: data['patientId'],
          ),
        ),
      );
      // Optional: Delete emergency after opening, or keep until explicitly dismissed
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(docId)
          .delete();
    }
    // 3. Everything else (Status updates/Messages)
    else {
      // Show Info Dialog (No Chat Navigation)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(autoI8lnGen.translate("NOTIFICATION_DETAILS")),
          content: Text(
              data['message'] ?? autoI8lnGen.translate("NO_ADDITIONAL_INFO")),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // CLEAN UP: Delete after reading
                await FirebaseFirestore.instance
                    .collection('notifications')
                    .doc(docId)
                    .delete();
              },
              child: Text(autoI8lnGen.translate("CLOSE_AND_DELETE")),
            )
          ],
        ),
      );
    }
  }
}
