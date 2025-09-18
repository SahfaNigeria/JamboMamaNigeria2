import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/banner_component.dart';
import 'package:jambomama_nigeria/components/home_components.dart';
import 'package:jambomama_nigeria/midwives/views/components/healthprovider%20drawer.dart';
import 'package:jambomama_nigeria/midwives/views/screens/availability_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/colleague_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/instruction_screen.dart';

import 'package:jambomama_nigeria/midwives/views/screens/patients.dart';

import 'package:jambomama_nigeria/views/mothers/notification.dart';

class MidWifeHomePage extends StatelessWidget {
  MidWifeHomePage({super.key});

  Future<Map<String, dynamic>> getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Health Professionals')
          .doc(user.uid)
          .get();

      return userDoc.data() as Map<String, dynamic>;
    } else {
      throw Exception('No user logged in');
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<int> getUnreadNotificationCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: getUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: AutoText('HOME_2'),
              centerTitle: true,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: AutoText('HOME_2'),
              centerTitle: true,
            ),
            body: Center(child: AutoText('ERROR: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: AutoText('HOME_2'),
              centerTitle: true,
            ),
            body: Center(child: AutoText('ERROR_9')),
          );
        }

        var userData = snapshot.data!;
        String title = userData['position'] ?? 'HEALTH_PROFESSIONAL';
        String name = userData['fullName'] ?? 'USER';
        String profilePictureUrl = userData['midWifeImage'] ?? '';

        // Extract user data for drawer
        String userName = userData['fullName'] ?? '';
        String email = userData['email'] ?? '';
        String address = userData['address'] ?? '';
        String cityValue = userData['city'] ?? '';
        String stateValue = userData['state'] ?? '';
        String villageTown = userData['villageTown'] ?? '';
        String hospital = userData['hospital'] ?? '';

        return Scaffold(
          appBar: AppBar(
            title: const AutoText('HOME_2'),
            centerTitle: true,
            actions: [
              StreamBuilder<int>(
                stream: getUnreadNotificationCount(),
                builder: (context, snapshot) {
                  int unreadCount = snapshot.data ?? 0;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_active),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsPage(),
                            ),
                          );
                        },
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 5,
                          top: 5,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              )
            ],
          ),
          drawer: HealthProviderHomeDrawer(
            userName: userName,
            email: email,
            address: address,
            cityValue: cityValue,
            stateValue: stateValue,
            villageTown: villageTown,
            hospital: hospital,
          ),
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
                        image: profilePictureUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(profilePictureUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: profilePictureUrl.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    AutoText(
                      'HELLO',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w400),
                    ),
                    Text(
                      '$title, $name.',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ],
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
                        text: "PATIENTS",
                        icon: 'assets/svgs/logo_Jambomama.svg',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Patients(),
                            ),
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
                        text: 'COLLEAGUES',
                        icon: 'assets/svgs/file_directory.svg',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ColleagueList(
                                location: 'Abuja',
                              ),
                            ),
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
                      text: 'LEARN',
                      icon: 'assets/svgs/learn_medicine.svg',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PractitionerContentScreen(),
                          ),
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
                      text: 'AVAILABILITY',
                      icon: 'assets/svgs/person_account.svg',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AvailabilitySchedulePage(),
                          ),
                        );
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
