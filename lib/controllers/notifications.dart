import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jambomama_nigeria/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'auth_controller.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

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
  static String fcmToken = "";

  String get userFcmToken => fcmToken;

  Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await requestPermission();
    await setupFlutterNotifications();
    await setupMessageHandlers();

    // Get and store the current token
    final token = await _messaging.getToken();
    fcmToken = token ?? "";
    debugPrint('[FCM] Current token: $fcmToken');

    // NOTE: onTokenRefresh is intentionally NOT duplicated here.
    // Token refresh handling is owned by AuthController.initTokenRefreshListener()
    // which is called from main.dart via authStateChanges().
  }

  // --- API TRIGGER ---

  Future<Map<String, dynamic>> triggerNotificationViaApi({
    required String userId,
    required String title,
    required String message,
    required String
        senderId, // NEW: Divine's server uses this to look up and attach senderName
  }) async {
    final url = Uri.parse('$baseUrl$notificationEndpoint');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'message': message,
          'senderId': senderId, // NEW
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        debugPrint('[API] Failed: ${response.statusCode} ${response.body}');
        throw Exception(
            'Failed to trigger notification: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      debugPrint('[API] Error: $e');
      throw Exception('Error triggering notification: $e');
    }
  }

  // --- LOCAL NOTIFICATION DISPLAY ---

  Future<void> sendNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
    required String token,
  }) async {
    if (token.isEmpty) {
      debugPrint('[FCM] sendNotification called with empty token — skipped');
      return;
    }

    // NEW: prefer senderName from data if present, same rule as showNotification below
    final String displayTitle = (data['senderName'] as String?) ?? title;

    final int notificationId = Random().nextInt(2147483647);

    try {
      await _localNotifications.show(
        notificationId,
        displayTitle,
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
        // FIX 5: Use jsonEncode so payload is valid JSON, not .toString()
        payload: jsonEncode(data),
      );
    } catch (e) {
      debugPrint('[FCM] sendNotification display error: $e');
    }
  }

  // --- PERMISSIONS ---

  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    debugPrint('[FCM] Permission status: ${settings.authorizationStatus}');
  }

  // --- FLUTTER LOCAL NOTIFICATIONS SETUP ---

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitialized) return;

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

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/uc_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        _handleNotificationTap(details.payload);
      },
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTap,
    );

    _isFlutterLocalNotificationsInitialized = true;
  }

  // Must be top-level or static for background isolate
  static void _onBackgroundNotificationTap(NotificationResponse details) {
    _routeFromPayload(details.payload);
  }

  void _handleNotificationTap(String? payload) {
    _routeFromPayload(payload);
  }

  // FIX 4: Actually handle routing when notification is tapped
  static void _routeFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final targetScreen = data['screen'];
      final senderId = data['senderId'];
      final chatId = data['chatId'];

      if (targetScreen == 'ChatScreen' && chatId != null) {
        navigatorKey.currentState?.pushNamed(
          '/ChatScreen',
          arguments: {
            'chatId': chatId,
            'senderId': senderId,
          },
        );
      }
      // Add more screen routes here as needed
    } catch (e) {
      debugPrint('[FCM] Payload routing error: $e');
    }
  }

  // --- SHOW NOTIFICATION ---

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // NEW: prefer sender's name from data payload; fall back to whatever title FCM sent
      final String displayTitle =
          (message.data['senderName'] as String?) ?? notification.title ?? '';

      await _localNotifications.show(
        notification.hashCode,
        displayTitle,
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
        // FIX 5: jsonEncode instead of .toString()
        payload: jsonEncode(message.data),
      );
    } else {
      debugPrint('[FCM] showNotification: notification or android was null');
    }
  }

  // --- MESSAGE HANDLERS ---

  Future<void> setupMessageHandlers() async {
    // Foreground
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint('[FCM] Foreground message: ${message.messageId}');
      await showNotification(message);
    });

    // Background → app opened via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // App launched from terminated state via notification tap
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[FCM] App launched from notification');
      _handleBackgroundMessage(initialMessage);
    }
  }

  // FIX 4: Route user to correct screen when tapping background notification
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Background message opened: ${message.messageId}');

    final targetScreen = message.data['screen'];
    final chatId = message.data['chatId'];
    final senderId = message.data['senderId'];

    if (targetScreen == 'ChatScreen' && chatId != null) {
      navigatorKey.currentState?.pushNamed(
        '/ChatScreen',
        arguments: {
          'chatId': chatId,
          'senderId': senderId,
          'senderCollection': message.data['senderCollection'],
          'senderNameField': message.data['senderNameField'],
          'receiverCollection': message.data['receiverCollection'],
          'receiverNameField': message.data['receiverNameField'],
        },
      );
    }
    // Add more screen routes here as needed
  }
}
