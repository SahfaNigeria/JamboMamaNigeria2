import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _navigateTo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("isHealthProffessional")) {
      if (prefs.getBool("isHealthProffessional") == true) {
        Navigator.pushReplacementNamed(context, '/MidWifeHomePage');
      } else {
        Navigator.pushReplacementNamed(context, '/HomePage');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login_register');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(
      const Duration(
        seconds: 2,
      ),
      () => _navigateTo(),
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
