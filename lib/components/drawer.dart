import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/drawer_tiles.dart';
import 'package:jambomama_nigeria/views/mothers/allowed_to_chat.dart';

import 'package:jambomama_nigeria/views/mothers/auth/login_or_register.dart';
import 'package:jambomama_nigeria/views/mothers/deliverydate.dart';
import 'package:jambomama_nigeria/views/mothers/match.dart';

import 'package:jambomama_nigeria/views/mothers/medical_background.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userLocation;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('New Mothers')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            userLocation = doc['cityValue'] ?? 'Unknown Location';
          });
        }
      }
    } catch (e) {
      print("Error fetching user location: $e");
    }
  }

  Future logout() async {
    await _auth.signOut().then((value) => Navigator.of(context)
        .pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginOrRegister()),
            (route) => false));
  }

  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      child: Column(
        children: [
          const SizedBox(
            height: 50,
            width: 50,
          ),

          //logo
          SizedBox(
            height: 100,
            width: 100,
            child: Image.asset(
              'assets/images/logo.png',
            ),
          ),

          // divides

          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Divider(),
          ),

          // Home {Tiles}

          DrawerTiles(
            icon: Icons.home,
            onTap: () {},
            text: "Home",
          ),

          DrawerTiles(
            icon: Icons.local_hospital,
            onTap: () {},
            text: "Hospitals",
          ),

          DrawerTiles(
            icon: Icons.search,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfessionalsList(location: userLocation ?? '')),
              );
            },
            text: "Health Providers",
          ),
          DrawerTiles(
            icon: Icons.medical_services_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllowedToChatScreen(),
                ),
              );
            },
            text: " Connections",
          ),

          DrawerTiles(
            icon: Icons.calendar_today,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ExpectedDeliveryScreen()),
              );
            },
            text: "Calculate Due Date",
          ),

          DrawerTiles(
            icon: Icons.app_registration,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => PregnantWomanForm()),
              // );
            },
            text: "Medical Background ",
          ),

          DrawerTiles(
            icon: Icons.settings,
            onTap: () {},
            text: "Settings",
          ),

          DrawerTiles(
            icon: Icons.logout,
            onTap: () {
              logout();
            },
            text: "Logout",
          ),
        ],
      ),
    );
  }
}
