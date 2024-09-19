import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/banner_component.dart';
import 'package:jambomama_nigeria/components/drawer.dart';
import 'package:jambomama_nigeria/components/home_components.dart';
import 'package:jambomama_nigeria/midwives/views/components/midwife_home_drawer.dart';
import 'package:jambomama_nigeria/views/mothers/deliverydate.dart';
import 'package:jambomama_nigeria/views/mothers/questionnaire.dart';
import 'package:jambomama_nigeria/views/mothers/vital_info.dart';
import 'package:jambomama_nigeria/views/mothers/warning.dart';
import 'package:jambomama_nigeria/views/mothers/you.dart';

class HomePage extends StatefulWidget {
  final bool isHealthProvider;
  HomePage({super.key, required this.isHealthProvider});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String img = '';
  String userName = '';

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  Future<void> getProfileData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc =
          await _firestore.collection("New Mothers").doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          img = userDoc["profileImage"];
          userName = userDoc["full name"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_active_outlined),
          )
        ],
      ),
      drawer:
          widget.isHealthProvider ? HealthProviderHomeDrawer() : HomeDrawer(),
      body: ListView(
        children: [
          FrontBanner(),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(30),
                    image: DecorationImage(
                      image: NetworkImage(img),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Hello! ',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '$userName👋',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                  child: GestureDetector(
                    onDoubleTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExpectedDeliveryScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Double Tap to check your pregnancy due date!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 170,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: HomeComponents(
                    text: 'Follow your pregnancy',
                    icon: 'assets/svgs/logo-Jambomama_svg-com.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const You()),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Container(
                  width: 170,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: HomeComponents(
                    text: 'Periodic Questionnaire',
                    icon: 'assets/svgs/perfusion-svgrepo-com.svg',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PregnantFeelingsForm()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 170,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: HomeComponents(
                  text: 'Vital Info. Update',
                  icon: 'assets/svgs/doctor-svgrepo-com.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VitalInfoDisplayScreen()),
                    );
                  },
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                width: 170,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: HomeComponents(
                  text: 'Something happened',
                  icon: 'assets/svgs/warning-sign-svgrepo-com.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Warning()),
                    );
                  },
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
