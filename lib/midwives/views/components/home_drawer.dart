import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/drawer_tiles.dart';

class HomeDrawer extends StatefulWidget {
  const HomeDrawer({super.key});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
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
            icon: Icons.local_hospital,
            onTap: () {},
            text: "Hospitals",
          ),

          DrawerTiles(
            icon: Icons.pregnant_woman,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => const ExpectedDeliveryScreen()),
              // );
            },
            text: "Your Patients",
          ),

          DrawerTiles(
            icon: Icons.chat,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => const MedicalBackgroundForm()),
              // );
            },
            text: "Chat",
          ),

          DrawerTiles(
            icon: Icons.car_rental,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => const MedicalBackgroundForm()),
              // );
            },
            text: "Transport",
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
