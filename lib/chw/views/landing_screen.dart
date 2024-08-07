import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/chw/models/cwh_models.dart';
import 'package:jambomama_nigeria/chw/views/auth/c_w_h_registeration_screen.dart';
import 'package:jambomama_nigeria/chw/views/home_screen.dart';

class LandingScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _cwhStream =
      FirebaseFirestore.instance.collection('Community Health Workers');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _cwhStream.doc(_auth.currentUser!.uid).snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (!snapshot.data!.exists) {
          return C_W_H_Registration_Screen();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        CwhModels cwhUserModels =
            CwhModels.fromJson(snapshot.data!.data()! as Map<String, dynamic>);

        if (cwhUserModels.approved == true) {
          return CHWHomePage();
        }
        return Center(
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
                        cwhUserModels.cwhImage.toString(),
                      ),
                      fit: BoxFit.cover),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome!',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    cwhUserModels.position.toString(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    cwhUserModels.fullName.toString(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                'Your application has been sent to our admin portal.\n We will get back to you as soon as possible. ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              TextButton(
                  onPressed: () async {
                    _auth.signOut();
                  },
                  child: Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ))
            ],
          ),
        );
      },
    );
  }
}
