import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/drawer_tiles.dart';
import 'package:jambomama_nigeria/views/mothers/auth/login.dart';
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

  Future logout() async {
    await _auth
        .signOut()
        .then((value) => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => LoginPage(
                      onTap: () {},
                    )),
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
              'assets/images/logo-jambo mama.jpg',
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
            icon: Icons.chat_sharp,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfessionalsList(
                          location: 'Onitcha Uku',
                        )),
              );
            },
            text: "Chats",
          ),

          DrawerTiles(
            icon: Icons.car_rental,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PregnantWomanForm()),
              );
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
