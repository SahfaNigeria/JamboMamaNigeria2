import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:jambomama_nigeria/midwives/views/screens/home.dart';

import 'package:jambomama_nigeria/providers/connection_provider.dart';
import 'package:jambomama_nigeria/views/mothers/auth/login_or_register.dart';
import 'package:jambomama_nigeria/views/mothers/home.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: FirebaseOptions(
              apiKey: "AIzaSyA2WJFkv33A7eWnZYb_1_lxKKYCIXpmULE",
              appId: "1:501778526252:android:cb90b2ebb5d9756f4ea189",
              messagingSenderId: "501778526252",
              projectId: "jambo-mama-nigeria",
              storageBucket: "gs://jambo-mama-nigeria.appspot.com"),
        )
      : await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ConnectionStateModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => LoginOrRegister(),
        '/MidWifeHomePage': (context) => MidWifeHomePage(),
        '/HomePage': (context) => HomePage(
              isHealthProvider: false,
            ),
      },
      theme: ThemeData(
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 14.0),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
