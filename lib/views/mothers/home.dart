import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/banner_component.dart';
import 'package:jambomama_nigeria/components/drawer.dart';
import 'package:jambomama_nigeria/components/home_components.dart';
import 'package:jambomama_nigeria/views/mothers/deliverydate.dart';
import 'package:jambomama_nigeria/views/mothers/questionnaire.dart';
import 'package:jambomama_nigeria/views/mothers/warning.dart';
import 'package:jambomama_nigeria/views/mothers/you.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String img = '';

  getProfilePicture() async {
    QuerySnapshot profilePicture =
        await _firestore.collection("New Mothers").get();

    setState(() {
      img = profilePicture.docs[0]["profileImage"];
    });

    return profilePicture.docs;
  }

  void initState() {
    getProfilePicture();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      drawer: const HomeDrawer(),
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
                        image: NetworkImage(img), fit: BoxFit.cover),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Hello! ',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w400),
                ),
                Text(
                  'Martha👋',
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
                  text: 'Vital Infon Update',
                  icon: 'assets/svgs/doctor-svgrepo-com.svg',
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
