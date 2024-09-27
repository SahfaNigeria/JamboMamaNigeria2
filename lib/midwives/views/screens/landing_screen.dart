import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/midwives/models/midwife_user_models.dart';
import 'package:jambomama_nigeria/midwives/views/auth/midwive_registeration_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/home.dart';
import 'package:jambomama_nigeria/views/mothers/auth/login_or_register.dart';

class LandingScreen extends StatefulWidget {
  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final CollectionReference _midWifeStream =
      FirebaseFirestore.instance.collection('Health Professionals');

  Future logout() async {
    await _auth.signOut().then((value) => Navigator.of(context)
        .pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginOrRegister()),
            (route) => false));
  }

  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _midWifeStream.doc(_auth.currentUser?.uid).snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return MidwiveResgisteratioScreen();
        }

        // Ensure the data exists and is not null
        var data = snapshot.data!.data();
        if (data == null) {
          return Center(child: Text("No data available"));
        }

        MidWifeUserModels midWifeUserModels =
            MidWifeUserModels.fromJson(data as Map<String, dynamic>);

        if (midWifeUserModels.approved == true) {
          return MidWifeHomePage();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Welcome"),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.amber,
                    image: DecorationImage(
                      image: NetworkImage(
                        midWifeUserModels.midWifeImage.toString(),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome!',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(width: 5),
                    Text(
                      midWifeUserModels.position.toString(),
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(width: 5),
                    Text(
                      midWifeUserModels.fullName.toString(),
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Your application has been sent to our admin portal.\n We will get back to you as soon as possible.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    logout();
                  },
                  child: Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
