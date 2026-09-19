import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/midwives/views/auth/auth_screen.dart';
import 'package:jambomama_nigeria/utils/session_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _navigateTo() async {
    final isLoggedIn = await SessionManager.isLoggedIn();
    if (!mounted) return;

    if (!isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/login_register');
      return;
    }

    final isHealthProfessional = await SessionManager.isHealthProfessional();
    final profileComplete = await SessionManager.isProfileComplete();
    if (!mounted) return;

    if (!profileComplete && isHealthProfessional) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MidwiveAuthScreen()),
      );
    } else if (isHealthProfessional) {
      Navigator.pushReplacementNamed(context, '/MidWifeHomePage');
    } else {
      Navigator.pushReplacementNamed(context, '/HomePage');
    }
  }

  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(
        seconds: 2,
      ),
      () {
        if (mounted) _navigateTo();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 300,
          width: 300,
          child: Image.asset(
            'assets/images/logo.png',
          ),
        ),
      ],
    );
  }
}
