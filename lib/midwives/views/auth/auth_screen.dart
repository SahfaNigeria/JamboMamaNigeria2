import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/midwives/views/auth/mid_wive_sign_in_page.dart';
import 'package:jambomama_nigeria/midwives/views/auth/mid_wive_sign_up_page.dart';
import 'package:jambomama_nigeria/midwives/views/screens/landing_screen.dart';

class MidwiveAuthScreen extends StatefulWidget {
  const MidwiveAuthScreen({super.key});

  @override
  State<MidwiveAuthScreen> createState() => _MidwiveAuthScreenState();
}

class _MidwiveAuthScreenState extends State<MidwiveAuthScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _checkUserTypeAndNavigate(User user) async {
    DocumentSnapshot newMotherDoc =
        await _firestore.collection('New Mothers').doc(user.uid).get();
    DocumentSnapshot healthProfessionalDoc =
        await _firestore.collection('Health Professionals').doc(user.uid).get();

    if (newMotherDoc.exists) {
      Navigator.pushReplacementNamed(context, '/HomePage');
    } else if (healthProfessionalDoc.exists) {
      bool isApproved = healthProfessionalDoc.get('approved') ?? false;
      if (isApproved) {
        Navigator.pushReplacementNamed(context, '/MidWifeHomePage');
      } else {
        print("Health Professional not approved");
        // Handle unapproved health professionals (e.g., show a message or redirect)
      }
    } else {
      print("User not found in either collection");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LandingScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Display the built-in Firebase registration screen
          return MidWiveSignUpPage();
        }

        User? user = snapshot.data;
        if (user != null) {
          // Check user type and navigate
          _checkUserTypeAndNavigate(user);
          return Center(
              child:
                  CircularProgressIndicator()); // Show a loading indicator while checking
        }

        // Fallback in case user data is null
        return MidWiveSignUpPage();
      },
    );
  }
}
