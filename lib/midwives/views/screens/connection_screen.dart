import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jambomama_nigeria/providers/connection_provider.dart';
import 'package:jambomama_nigeria/providers/notification_model.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final connectionStateModel = Provider.of<ConnectionStateModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: AutoText('REQUESTS'),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: connectionStateModel.fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: AutoText('ERROR: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: AutoText('ERROR_4'));
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
    return Consumer<ConnectionStateModel>(
      builder: (context, model, _) {
        bool isLoading = model.isLoading(notification.id);

        return ListTile(
          title: Text(
            notification.requesterName ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: AutoText('REQUEST_1'),
          trailing: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => model.handleConnectionAction(
                          notification.id, 'accepted'),
                      child: AutoText('ACCEPT'),
                    ),
                    TextButton(
                      onPressed: () => model.handleConnectionAction(
                          notification.id, 'declined'),
                      child: AutoText('DECLINE'),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
