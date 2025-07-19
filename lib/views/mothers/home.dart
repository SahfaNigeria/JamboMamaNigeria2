import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/banner_component.dart';
import 'package:jambomama_nigeria/components/drawer.dart';
import 'package:jambomama_nigeria/components/home_components.dart';
import 'package:jambomama_nigeria/midwives/views/components/healthprovider%20drawer.dart';
import 'package:jambomama_nigeria/views/mothers/notification.dart';
import 'package:jambomama_nigeria/views/mothers/deliverydate.dart';
import 'package:jambomama_nigeria/views/mothers/questionnaire.dart';
import 'package:jambomama_nigeria/views/mothers/vital_info_update_screen.dart';
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
  String address = '';
  String cityValue = '';
  String hospital = '';
  String stateValue = '';
  String villageTown = '';
  String email = '';

  @override
  void initState() {
    super.initState();
    getProfileData();
    getProviderId();
  }

  Stream<int> getUnreadNotificationCount() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('senderId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  String? providerId;

  Future<void> getProviderId() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final query = await FirebaseFirestore.instance
        .collection('allowed_to_chat')
        .where('requesterId', isEqualTo: userId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        providerId = query.docs.first['recipientId'];
      });
    } else {
      print('⚠️ No connection found for userId: $userId');
    }
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
          email = userDoc["email"];
          address = userDoc["address"];
          cityValue = userDoc["cityValue"];
          stateValue = userDoc["stateValue"];
          villageTown = userDoc["villageTown"];
          hospital = userDoc["hospital"];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  AutoText('HOME_2'),
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
      drawer: widget.isHealthProvider
          ? HealthProviderHomeDrawer(
              userName: userName,
              email: email,
              address: address,
              cityValue: cityValue,
              stateValue: stateValue,
              villageTown: villageTown,
              hospital: hospital,
            )
          : HomeDrawer(
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
                    image: DecorationImage(
                      image: AssetImage(img),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                AutoText(
                  'HELLO',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w400),
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
                    text: 'FOLLOW_YOUR_PREGNANCY',
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
                    text: 'QUESTIONS_TO_ANWSER',
                    icon: 'assets/svgs/perfusion-svgrepo-com.svg',
                    onTap: () async {
                      try {
                        final userId = _auth.currentUser!.uid;

                        // Check if user already has an EDD saved in Firebase
                        final userDoc = await FirebaseFirestore.instance
                            .collection('save_mother_edd')
                            .doc(userId)
                            .get();

                        String? savedEdd;
                        if (userDoc.exists &&
                            userDoc
                                .data()!
                                .containsKey('expectedDeliveryDate')) {
                          savedEdd = userDoc.data()!['expectedDeliveryDate']
                              as String?;
                        }

                        if (savedEdd != null && savedEdd.isNotEmpty) {
                          // EDD already exists, go directly to feelings form
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PregnantFeelingsForm(
                                requesterId:
                                    providerId ?? '', // Ensure non-null String
                                expectedDeliveryDate: savedEdd!,
                              ),
                            ),
                          );
                        } else {
                          // First time - show EDD calculator
                          final edd = await Navigator.push<String>(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ExpectedDeliveryScreen(),
                            ),
                          );

                          if (edd != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PregnantFeelingsForm(
                                  requesterId: providerId ?? '',
                                  expectedDeliveryDate: edd,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                                  content: AutoText('EDD_NOT_SELECTED')),
                            );
                          }
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: AutoText('ERROR: $e')),
                        );
                      }
                    },
                  ),
                ),
                // Container(
                //   width: 170,
                //   height: 220,
                //   decoration: BoxDecoration(
                //     color: Colors.purple,
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: HomeComponents(
                //     text: 'Questions to Answer',
                //     icon: 'assets/svgs/perfusion-svgrepo-com.svg',
                //     onTap: () async {
                //       //     Ask the user to select their last menstrual period
                //       final edd = await Navigator.push<String>(
                //         context,
                //         MaterialPageRoute(
                //             builder: (context) =>
                //                 const ExpectedDeliveryScreen()),
                //       );

                //       // If the user selected a date and an EDD was returned
                //       if (edd != null) {
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => PregnantFeelingsForm(
                //               requesterId: providerId ?? '',
                //               expectedDeliveryDate: edd,
                //             ),
                //           ),
                //         );
                //       } else {
                //         ScaffoldMessenger.of(context).showSnackBar(
                //           const SnackBar(
                //               content: Text('EDD was not selected.')),
                //         );
                //       }
                //     },
                //   ),
                // ),
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
                  text: 'VITAL_INFO_UPDATE',
                  icon: 'assets/svgs/doctor-svgrepo-com.svg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VitalInfoUpdateScreen(
                          userId: _auth.currentUser!.uid,
                          currentWeek: 24,
                          initialWeight: 65.0,
                          initialBmi: 22.5,
                        ),
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
                  text: 'SOMETHING_HAPPENED',
                  icon: 'assets/svgs/warning-sign-svgrepo-com.svg',
                  onTap: () {
                    if (userName.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JamboMamaEmergencyScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: AutoText("LOADING_USER_DATA"),
                        ),
                      );
                    }
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
