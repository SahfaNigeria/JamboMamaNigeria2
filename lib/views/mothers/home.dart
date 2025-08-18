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

  // Dynamic user data variables
  double? userInitialWeight;
  double? userCurrentWeight;
  double? userInitialBmi;
  int? currentWeek;
  String? expectedDeliveryDate;
  DateTime? lastMenstrualPeriod;

  @override
  void initState() {
    super.initState();
    getProfileData();
    getProviderId();
    getUserVitalData(); // Fetch user's vital data
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

  // New method to fetch user's vital and pregnancy data
  Future<void> getUserVitalData() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Get Expected Delivery Date
      final eddDoc =
          await _firestore.collection('save_mother_edd').doc(user.uid).get();

      if (eddDoc.exists && eddDoc.data() != null) {
        expectedDeliveryDate = eddDoc.data()!['expectedDeliveryDate'];

        // Calculate current week from EDD
        if (expectedDeliveryDate != null) {
          currentWeek = calculateCurrentWeek(expectedDeliveryDate!);
        }
      }

      // 2. Get Initial Weight and BMI from patient background
      final backgroundDoc = await _firestore
          .collection('patients')
          .doc(user.uid)
          .collection('background')
          .doc('patient_background')
          .get();

      if (backgroundDoc.exists && backgroundDoc.data() != null) {
        final data = backgroundDoc.data()!;

        // Get the correct field names from your _saveData function
        userInitialWeight =
            data['weight']?.toDouble(); // Initial weight from background
        userInitialBmi = data['bmi']?.toDouble(); // BMI from background

        // If BMI not stored but we have height and weight, calculate it
        if (userInitialBmi == null &&
            userInitialWeight != null &&
            data['height'] != null) {
          double heightInM = data['height'].toDouble() / 100; // Convert cm to m
          userInitialBmi = userInitialWeight! / (heightInM * heightInM);
        }

        print('📊 Background data found:');
        print('   Weight: ${data['weight']}');
        print('   Height: ${data['height']}');
        print('   BMI: ${data['bmi']}');
        print('   BMI Message: ${data['bmi_message']}');
      } else {
        print('⚠️ No patient background found for user: ${user.uid}');
      }

      // 3. Get latest weight from vital info (with error handling for missing index)
      try {
        final vitalInfoQuery = await _firestore
            .collection('vital_info')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (vitalInfoQuery.docs.isNotEmpty) {
          final latestVital = vitalInfoQuery.docs.first.data();
          userCurrentWeight = latestVital['weight']?.toDouble();
        }
      } catch (e) {
        print('⚠️ Could not fetch latest vital info (index missing): $e');

        // Fallback: Get all vital_info for user without ordering
        try {
          final fallbackQuery = await _firestore
              .collection('vital_info')
              .where('userId', isEqualTo: user.uid)
              .get();

          if (fallbackQuery.docs.isNotEmpty) {
            // Find the most recent one manually
            var mostRecent = fallbackQuery.docs.first;
            for (var doc in fallbackQuery.docs) {
              if (doc.data()['timestamp'] != null &&
                  mostRecent.data()['timestamp'] != null) {
                if ((doc.data()['timestamp'] as Timestamp).compareTo(
                        mostRecent.data()['timestamp'] as Timestamp) >
                    0) {
                  mostRecent = doc;
                }
              }
            }
            userCurrentWeight = mostRecent.data()['weight']?.toDouble();
          }
        } catch (fallbackError) {
          print('❌ Fallback vital info query also failed: $fallbackError');
        }
      }

      // 4. Fallback: Get data from user profile if available
      final userDoc =
          await _firestore.collection("New Mothers").doc(user.uid).get();

      if (userDoc.exists && userDoc.data() != null) {
        final userData = userDoc.data()!;

        // Use fallback values if not found elsewhere
        userInitialWeight ??=
            userData['weight']?.toDouble(); // Try 'weight' first
        userInitialWeight ??=
            userData['initialWeight']?.toDouble(); // Then 'initialWeight'
        userInitialBmi ??= userData['bmi']?.toDouble();
        expectedDeliveryDate ??= userData['expectedDeliveryDate'];

        // Calculate current week if we have EDD
        if (currentWeek == null && expectedDeliveryDate != null) {
          currentWeek = calculateCurrentWeek(expectedDeliveryDate!);
        }

        print('👤 User profile fallback data:');
        print('   Weight: ${userData['weight']}');
        print('   Initial Weight: ${userData['initialWeight']}');
        print('   BMI: ${userData['bmi']}');
        print('   EDD: ${userData['expectedDeliveryDate']}');
      }

      setState(() {
        // Update UI with fetched data
      });

      print('✅ User vital data loaded:');
      print('Current Week: $currentWeek');
      print('Initial Weight: $userInitialWeight');
      print('Current Weight: $userCurrentWeight');
      print('Initial BMI: $userInitialBmi');
      print('EDD: $expectedDeliveryDate');
    } catch (e) {
      print('❌ Error fetching user vital data: $e');
    }
  }

  // Helper method to calculate current pregnancy week
  int calculateCurrentWeek(String eddString) {
    try {
      DateTime edd;

      // Handle different date formats
      if (eddString.contains('-') && eddString.split('-').length == 3) {
        // Handle formats like "27-02-2026" or "2026-02-27"
        List<String> parts = eddString.split('-');
        if (parts[0].length == 4) {
          // Format: YYYY-MM-DD
          edd = DateTime.parse(eddString);
        } else {
          // Format: DD-MM-YYYY
          edd = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } else {
        // Try ISO format
        edd = DateTime.parse(eddString);
      }

      DateTime now = DateTime.now();

      // Calculate weeks from conception (EDD - 280 days = LMP)
      DateTime lmp = edd.subtract(Duration(days: 280));
      int daysSinceLmp = now.difference(lmp).inDays;
      int weeks = (daysSinceLmp / 7).floor();

      // Ensure week is within reasonable range (1-42)
      return weeks.clamp(1, 42);
    } catch (e) {
      print('Error calculating current week: $e');
      print('Date string: $eddString');
      return 20; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoText('HOME_2'),
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
                // Show current week if available
                if (currentWeek != null)
                  Expanded(
                    child: Text(
                      ' (Week $currentWeek)',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
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

                        // Use the already fetched EDD if available
                        String? savedEdd = expectedDeliveryDate;

                        // If not in memory, check Firebase
                        if (savedEdd == null || savedEdd.isEmpty) {
                          final userDoc = await FirebaseFirestore.instance
                              .collection('save_mother_edd')
                              .doc(userId)
                              .get();

                          if (userDoc.exists && userDoc.data() != null) {
                            savedEdd = userDoc.data()!['expectedDeliveryDate']
                                as String?;
                          }
                        }

                        if (savedEdd != null && savedEdd.isNotEmpty) {
                          // EDD already exists, go directly to feelings form
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PregnantFeelingsForm(
                                requesterId: providerId ?? '',
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

                          if (edd != null && edd.isNotEmpty) {
                            // Save the EDD to Firebase immediately
                            await FirebaseFirestore.instance
                                .collection('save_mother_edd')
                                .doc(userId)
                                .set({
                              'expectedDeliveryDate': edd,
                              'userId': userId,
                              'createdAt': FieldValue.serverTimestamp(),
                            }, SetOptions(merge: true));

                            // Update local state
                            setState(() {
                              expectedDeliveryDate = edd;
                              currentWeek = calculateCurrentWeek(edd);
                            });

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Due date saved successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Now navigate to feelings form
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
                              SnackBar(content: AutoText('EDD_NOT_SELECTED')),
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
                  onTap: () async {
                    final userId = _auth.currentUser!.uid;

                    final docRef = _firestore
                        .collection('patients')
                        .doc(userId)
                        .collection('background')
                        .doc('patient_background');

                    final docSnapshot = await docRef.get();

                    if (docSnapshot.exists) {
                      // Refresh user data before navigating
                      await getUserVitalData();

                      // Use dynamic values or provide reasonable defaults
                      int weekToUse = currentWeek ?? 20;
                      double initialWeightToUse = userInitialWeight ?? 60.0;
                      double bmiToUse = userInitialBmi ?? 22.0;

                      // Medical background exists — proceed to Vital Info screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VitalInfoUpdateScreen(
                            userId: userId,
                            currentWeek: weekToUse,
                            initialWeight: initialWeightToUse,
                            initialBmi: bmiToUse,
                          ),
                        ),
                      );
                    } else {
                      // Medical background not filled — show alert dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Medical History Required'),
                            content: const Text(
                                'Before updating your vital information, please go through the navbar to complete your medical background form.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Emergency Use Only'),
                            content: const Text(
                              '⚠️ This feature is intended for emergency situations only.\n\nDo you want to continue?',
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog
                                },
                              ),
                              ElevatedButton(
                                child: const Text('Proceed'),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog first
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          JamboMamaEmergencyScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please wait, loading user data..."),
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
