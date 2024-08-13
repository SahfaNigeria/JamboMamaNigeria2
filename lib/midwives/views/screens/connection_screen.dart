import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jambomama_nigeria/providers/connection_provider.dart';
import 'package:jambomama_nigeria/providers/notification_model.dart';

class ConnectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtain the provider ID from the model or authentication
    final connectionStateModel = Provider.of<ConnectionStateModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: connectionStateModel.fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications'));
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return buildNotificationItem(notification, context);
            },
          );
        },
      ),
    );
  }

  Widget buildNotificationItem(
      NotificationModel notification, BuildContext context) {
    final connectionStateModel =
        Provider.of<ConnectionStateModel>(context, listen: false);

    return ListTile(
      title: Text(
        '${notification.requesterName}',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('sent you a connection request'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => connectionStateModel.handleConnectionAction(
                notification.id, 'accepted'),
            child: Text('Accept'),
          ),
          TextButton(
            onPressed: () => connectionStateModel.handleConnectionAction(
                notification.id, 'declined'),
            child: Text('Decline'),
          ),
        ],
      ),
    );
  }
}
