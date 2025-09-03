import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/drawer_tiles.dart';
import 'package:jambomama_nigeria/midwives/views/screens/connection_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/health_facilites.dart';
import 'package:jambomama_nigeria/midwives/views/screens/home.dart';
import 'package:jambomama_nigeria/midwives/views/screens/patients.dart';
import 'package:jambomama_nigeria/midwives/views/screens/settings_screens.dart';
import 'package:jambomama_nigeria/views/mothers/auth/login_or_register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthProviderHomeDrawer extends StatefulWidget {
  final String email;
  final String address;
  final String userName;
  final String cityValue;
  final String stateValue;
  final String villageTown;
  final String hospital;

  HealthProviderHomeDrawer({
    super.key,
    required this.email,
    required this.address,
    required this.userName,
    required this.cityValue,
    required this.stateValue,
    required this.villageTown,
    required this.hospital,
  });

  @override
  State<HealthProviderHomeDrawer> createState() =>
      _HealthProviderHomeDrawerState();
}

class _HealthProviderHomeDrawerState extends State<HealthProviderHomeDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future logout() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    sharedPreferences.clear();
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MidWifeHomePage(),
                ),
              );
            },
            text: autoI8lnGen.translate("HOME_2"),
          ),
          DrawerTiles(
            icon: Icons.local_hospital,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HospitalsScreen(),
                ),
              );
            },
            text: autoI8lnGen.translate("HOSPITALS_2"),
          ),

          DrawerTiles(
            icon: Icons.pregnant_woman,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Patients(),
                ),
              );
            },
            text: autoI8lnGen.translate("PATIENTS_2"),
          ),
          DrawerTiles(
            icon: Icons.connect_without_contact,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConnectionScreen()),
              );
            },
            text: autoI8lnGen.translate("CONNECTION"),
          ),

          DrawerTiles(
            icon: Icons.settings,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    email: widget.email,
                    address: widget.address,
                    userName: widget.userName,
                    cityValue: widget.cityValue,
                    stateValue: widget.stateValue,
                    villageTown: widget.villageTown,
                    hospital: widget.hospital,
                  ),
                ),
              );
            },
            text: autoI8lnGen.translate("SETTINGS"),
          ),

          DrawerTiles(
            icon: Icons.logout,
            onTap: () {
              logout();
            },
            text: autoI8lnGen.translate("LOGOUT"),
          ),
        ],
      ),
    );
  }
}
