import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jambomama_nigeria/controllers/auth_controller.dart';
import 'package:jambomama_nigeria/controllers/notifications.dart';
import 'package:jambomama_nigeria/midwives/views/screens/chat_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/connection_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/home.dart';
import 'package:jambomama_nigeria/providers/connection_provider.dart';
import 'package:jambomama_nigeria/views/mothers/auth/login_or_register.dart';
import 'package:jambomama_nigeria/views/mothers/auth/splash_screen.dart';
import 'package:jambomama_nigeria/views/mothers/birth_plan.dart';
import 'package:jambomama_nigeria/views/mothers/home.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'locale/localization_service.dart';
import 'midwives/views/auth/auth_screen.dart';
import 'midwives/views/auth/mid_wive_forgotten_password_page.dart';
import 'midwives/views/auth/mid_wive_sign_in_page.dart';
import 'midwives/views/auth/mid_wive_sign_up_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user != null) {
      AuthController().initTokenRefreshListener();
    }
  });
  await LocalizationService.init();

  await NotificationService.instance.init();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ConnectionStateModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      builder: EasyLoading.init(),
      routes: {
        '/': (context) => SplashScreen(),
        '/login_register': (context) => LoginOrRegister(),
        '/MidWifeHomePage': (context) => MidWifeHomePage(),
        '/mid_wife_reg_screen': (context) => MidwiveAuthScreen(),
        '/mid_wife_sign_in_screen': (context) => MidWiveSignInPage(),
        '/midwive_sign_up_page': (context) => MidWiveSignUpPage(),
        '/midwive_password_reset_page': (context) =>
            MidWiveForgottenPasswordPage(),
        '/HomePage': (context) => HomePage(isHealthProvider: false),
        '/ChatScreen': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ChatScreen(
            chatId: args['chatId'],
            senderCollection: args['senderCollection'],
            senderNameField: args['senderNameField'],
            receiverCollection: args['receiverCollection'],
            receiverNameField: args['receiverNameField'],
          );
        },
        '/ConnectionScreen': (context) => ConnectionScreen(),
        '/BirthPlanScreen': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return BirthPlanScreen(patientId: args['patientId']);
        },
      },
      theme: ThemeData(
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 14.0),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
