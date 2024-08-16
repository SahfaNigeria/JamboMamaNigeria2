import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/drawer_tiles.dart';
import 'package:jambomama_nigeria/midwives/views/screens/allowed_to_chat.dart';
import 'package:jambomama_nigeria/midwives/views/screens/connection_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/chat_screen.dart';

class HealthProviderHomeDrawer extends StatelessWidget {
  HealthProviderHomeDrawer({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future logout() async {
    await _auth.signOut();
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
          FittedBox(
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset('assets/images/logo.png'),
            ),
            fit: BoxFit.fill,
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
            icon: Icons.pregnant_woman,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllowedToChatScreen(),
                ),
              );
            },
            text: "Patients",
          ),
          DrawerTiles(
            icon: Icons.connect_without_contact,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConnectionScreen()),
              );
            },
            text: "Connection",
          ),

          DrawerTiles(
            icon: Icons.settings,
            onTap: () {},
            text: "Settings",
          ),

          DrawerTiles(
            icon: Icons.logout,
            onTap: () {
              logout;
            },
            text: "Logout",
          ),
        ],
      ),
    );
  }
}
