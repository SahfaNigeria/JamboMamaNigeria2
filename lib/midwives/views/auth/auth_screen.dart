import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';

import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/midwives/views/screens/landing_screen.dart';

class MidwiveAuthScreen extends StatefulWidget {
  const MidwiveAuthScreen({super.key});

  @override
  State<MidwiveAuthScreen> createState() => _MidwiveAuthScreenState();
}

class _MidwiveAuthScreenState extends State<MidwiveAuthScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        initialData: FirebaseAuth.instance.currentUser,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SignInScreen(
              providers: [EmailAuthProvider()],
            );
          }
          return LandingScreen();
        });
  }
}
