import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jambomama_nigeria/main.dart';
import 'dart:math';
import 'auth_controller.dart';
import 'package:http/http.dart' as http;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitialized = false;

  // API endpoint constants
  static const String baseUrl = "https://jumbo-mama-notify.onrender.com";
  static const String notificationEndpoint = "/api/notifications/push";

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await requestPermisson();
    await setupMessageHandlers();

    //get the token
    final token = await _messaging.getToken();
    print('fcm token: $token');

    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      print('FCM token refreshed: $token');
      AuthController().saveFcmToken(); // Save the new token
    });
  }

  // Method to trigger notification via API endpoint
  Future<Map<String, dynamic>> triggerNotificationViaApi({
    required String userId,
    required String title,
    required String message,
  }) async {
    final url = Uri.parse('$baseUrl$notificationEndpoint');

    try {
      print('🔔 Triggering notification via API');
      print('👤 User ID: $userId');
      print('📝 Title: $title');
      print('📝 Message: $message');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'message': message,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ API notification triggered successfully: $responseData');
        return responseData;
      } else {
        print(
            '❌ Failed to trigger API notification: ${response.statusCode}, ${response.body}');
        throw Exception(
            'Failed to trigger notification: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('❌ Error triggering API notification: $e');
      throw Exception('Error triggering notification: $e');
    }
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    if (token.isEmpty) {
      print('❌ Cannot send notification: Token is empty');
      return;
    }

    final int notificationId = Random().nextInt(2147483647);

    try {
      print('🔔 Sending notification to token: $token');
      print('📝 Title: $title');
      print('📝 Body: $body');
      print('📝 Data: $data');

      await _localNotifications.show(
        notificationId,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
            icon: '@mipmap/uc_launcher',
            enableLights: true,
            enableVibration: true,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(data),
      );

      print('✅ Notification sent successfully');
    } catch (e) {
      print('❌ Error showing notification: $e');
      print(e.toString()); // Log the full error
    }
  }

  Future<void> requestPermisson() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('Permission status: ${settings.authorizationStatus}');
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) {
      return;
    }

    //android setup
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    //android
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/uc_launcher');
    //ios
    final initializationSettingsDarwin = DarwinInitializationSettings(
      // onDidReceiveLocalNotification: (id, title, body, payload) async {
      //   print("Notification received on iOS: $title");
      // },
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: (details) {
        final payload = details.payload;
        if (payload != null) {
          final data = jsonDecode(payload);
          final targetScreen = data['screen'];
          final senderId = data['senderId'];

          if (targetScreen == 'ChatScreen' && senderId != null) {
            navigatorKey.currentState?.pushNamed('/chat', arguments: senderId);
          }
        }
      },
    );

    // await _localNotifications.initialize(
    //   initializationSettings,
    //   onDidReceiveBackgroundNotificationResponse: (details) {},
    // );
    _isFlutterLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    print('Attempting to show notification:');
    print('Notification: $notification');
    print('Android: $android');

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            ticker: 'ticker',
            icon: '@mipmap/uc_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    } else {
      print('Unable to show notification: notification or android is null');
    }
  }

  Future<void> setupMessageHandlers() async {
    //foreground
    FirebaseMessaging.onMessage.listen((message) async {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.toMap()}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      await showNotification(message);
    });

    //background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    //opened app
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
      // print('Handling a message that caused the application to open');
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    print('Handling a background message ${message.messageId}');
  }
}
