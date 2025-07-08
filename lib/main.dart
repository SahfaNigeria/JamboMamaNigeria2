import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/controllers/notifications.dart';
import 'package:jambomama_nigeria/midwives/views/screens/chat_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/connection_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/home.dart';
import 'package:jambomama_nigeria/providers/connection_provider.dart';
import 'package:jambomama_nigeria/views/mothers/auth/login_or_register.dart';
import 'package:jambomama_nigeria/views/mothers/home.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: "AIzaSyA2WJFkv33A7eWnZYb_1_lxKKYCIXpmULE",
            appId: "1:501778526252:android:cb90b2ebb5d9756f4ea189",
            messagingSenderId: "501778526252",
            projectId: "jambo-mama-nigeria",
            storageBucket: "gs://jambo-mama-nigeria.appspot.com",
          ),
        )
      : await Firebase.initializeApp();

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
      navigatorKey: navigatorKey, // 👈 Added here
      routes: {
        '/': (context) => LoginOrRegister(),
        '/MidWifeHomePage': (context) => MidWifeHomePage(),
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



// import 'dart:io';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:jambomama_nigeria/controllers/notifications.dart';
// import 'package:jambomama_nigeria/midwives/views/screens/chat_screen.dart';

// import 'package:jambomama_nigeria/midwives/views/screens/home.dart';

// import 'package:jambomama_nigeria/providers/connection_provider.dart';
// import 'package:jambomama_nigeria/views/mothers/auth/login_or_register.dart';
// import 'package:jambomama_nigeria/views/mothers/home.dart';

// import 'package:provider/provider.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   Platform.isAndroid
//       ? await Firebase.initializeApp(
//           options: FirebaseOptions(
//               apiKey: "AIzaSyA2WJFkv33A7eWnZYb_1_lxKKYCIXpmULE",
//               appId: "1:501778526252:android:cb90b2ebb5d9756f4ea189",
//               messagingSenderId: "501778526252",
//               projectId: "jambo-mama-nigeria",
//               storageBucket: "gs://jambo-mama-nigeria.appspot.com"),
//         )
//       : await Firebase.initializeApp();
//   await NotificationService.instance.init();

//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => ConnectionStateModel(),
//       child: MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of this application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       routes: {
//         '/': (context) => LoginOrRegister(),
//         '/MidWifeHomePage': (context) => MidWifeHomePage(),
//         '/HomePage': (context) => HomePage(
//               isHealthProvider: false,
//             ),
//         '/ChatScreen': (context) {
//           final args = ModalRoute.of(context)!.settings.arguments
//               as Map<String, dynamic>;
//           return ChatScreen(
//             chatId: args['chatId'],
//             senderCollection: args['senderCollection'],
//             senderNameField: args['senderNameField'],
//             receiverCollection: args['receiverCollection'],
//             receiverNameField: args['receiverNameField'],
//           );
//         },
//       },
//       theme: ThemeData(
//         textTheme: TextTheme(
//           bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 14.0),
//         ),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.red,
//         ),
//         useMaterial3: true,
//       ),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
