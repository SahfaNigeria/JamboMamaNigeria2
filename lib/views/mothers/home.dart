import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/components/drawer.dart';
import 'package:jambomama_nigeria/components/home_components.dart';
import 'package:jambomama_nigeria/midwives/views/components/healthprovider%20drawer.dart';
import 'package:jambomama_nigeria/views/mothers/notification.dart';
import 'package:jambomama_nigeria/views/mothers/deliverydate.dart';
import 'package:jambomama_nigeria/views/mothers/questionnaire.dart';
import 'package:jambomama_nigeria/views/mothers/vital_info_update_screen.dart';
import 'package:jambomama_nigeria/views/mothers/warning.dart';
import 'package:jambomama_nigeria/views/mothers/you.dart';
import 'package:intl/intl.dart';

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

  double? userInitialWeight;
  double? userCurrentWeight;
  double? userInitialBmi;
  int? currentWeek;
  String? expectedDeliveryDate;
  DateTime? lastMenstrualPeriod;

  // ── NEW delivery-status fields ─────────────────────────────────────────────
  bool isPastDue = false;
  bool? hasDelivered; // null = unknown, true = delivered, false = not yet

  @override
  void initState() {
    super.initState();
    getProfileData();
    getProviderId();
    getUserVitalData();
  }

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
    }
  }

  /// Returns true if [path] looks like a remote URL (http/https),
  /// false if it looks like a local asset path or is empty/invalid.
  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  /// Builds the correct ImageProvider for whatever is stored in [img].
  /// Handles three cases: a real network URL, a bundled asset path
  /// (e.g. "assets/images/headscarf.jpg"), or empty/unknown -> null.
  ImageProvider? _resolveAvatarImage(String path) {
    if (path.isEmpty) return null;

    if (_isNetworkImage(path)) {
      return NetworkImage(path);
    }

    // Treat anything else as a bundled asset path.
    // Strip a stray leading slash if present (e.g. "/assets/..").
    final assetPath = path.startsWith('/') ? path.substring(1) : path;
    return AssetImage(assetPath);
  }

  Future<void> getProfileData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc =
          await _firestore.collection("New Mothers").doc(user.uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        setState(() {
          img = data?["profileImage"] ?? '';
          userName = data?["full name"] ?? '';
          email = data?["email"] ?? '';
          address = data?["address"] ?? '';
          cityValue = data?["cityValue"] ?? '';
          stateValue = data?["stateValue"] ?? '';
          villageTown = data?["villageTown"] ?? '';
          hospital = data?["hospital"] ?? '';
        });
      }
    }
  }

  Future<void> getUserVitalData() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // 1. Get EDD from users collection
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['expectedDeliveryDate'] != null) {
            final eddStr = (data['expectedDeliveryDate'] as Timestamp)
                .toDate()
                .toIso8601String();
            _applyEdd(eddStr);
          }
        }
      } catch (e) {}

      // 2. Initial weight + BMI from patient background
      final backgroundDoc = await _firestore
          .collection('patients')
          .doc(user.uid)
          .collection('background')
          .doc('patient_background')
          .get();

      if (backgroundDoc.exists && backgroundDoc.data() != null) {
        final data = backgroundDoc.data()!;
        userInitialWeight = data['weight']?.toDouble();
        userInitialBmi = data['bmi']?.toDouble();

        if (userInitialBmi == null &&
            userInitialWeight != null &&
            data['height'] != null) {
          double heightInM = data['height'].toDouble() / 100;
          userInitialBmi = userInitialWeight! / (heightInM * heightInM);
        }
      }

      // 3. Latest weight from vital_info
      try {
        final vitalInfoQuery = await _firestore
            .collection('vital_info')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (vitalInfoQuery.docs.isNotEmpty) {
          userCurrentWeight =
              vitalInfoQuery.docs.first.data()['weight']?.toDouble();
        }
      } catch (e) {
        print('⚠️ Could not fetch latest vital info: $e');
      }

      // 4. Fallback: New Mothers profile
      final userDocFallback =
          await _firestore.collection("New Mothers").doc(user.uid).get();

      if (userDocFallback.exists && userDocFallback.data() != null) {
        final userData = userDocFallback.data()!;
        userInitialWeight ??= userData['weight']?.toDouble();
        userInitialWeight ??= userData['initialWeight']?.toDouble();
        userInitialBmi ??= userData['bmi']?.toDouble();

        if (expectedDeliveryDate == null || expectedDeliveryDate!.isEmpty) {
          final edd = userData['expectedDeliveryDate'] as String?;
          if (edd != null) _applyEdd(edd);
        }
      }

      // 5. save_mother_edd collection (highest priority for EDD)
      try {
        final eddDoc =
            await _firestore.collection('save_mother_edd').doc(user.uid).get();

        if (eddDoc.exists && eddDoc.data() != null) {
          final eddFromSave = eddDoc.data()!['expectedDeliveryDate'] as String?;
          if (eddFromSave != null && eddFromSave.isNotEmpty) {
            _applyEdd(eddFromSave);
          }
        }
      } catch (e) {
        print('⚠️ Could not fetch EDD from save_mother_edd: $e');
      }

      // 6. NEW — Read delivery status from mother_pregnancy_data
      //    (written by the feelings form when mother confirms delivery)
      try {
        final pregnancyDoc = await _firestore
            .collection('mother_pregnancy_data')
            .doc(user.uid)
            .get();

        if (pregnancyDoc.exists && pregnancyDoc.data() != null) {
          final data = pregnancyDoc.data()!;
          final delivered = data['hasDelivered'];
          if (delivered != null) {
            setState(() {
              hasDelivered = delivered as bool;
            });
          }
        }
      } catch (e) {
        print('⚠️ Could not fetch delivery status: $e');
      }
    } catch (e) {}
  }

  /// Central method: parse EDD string, compute week, set isPastDue.
  void _applyEdd(String eddString) {
    final result = _calculateWeekAndStatus(eddString);
    setState(() {
      expectedDeliveryDate = eddString;
      currentWeek = result.week;
      isPastDue = result.pastDue;
    });
  }

  // Return type for the calculation
  ({int week, bool pastDue}) _calculateWeekAndStatus(String eddString) {
    try {
      DateTime edd;

      if (eddString.contains('-') && eddString.split('-').length == 3) {
        final parts = eddString.split('-');
        edd = parts[0].length == 4
            ? DateTime.parse(eddString)
            : DateFormat('dd-MM-yyyy').parse(eddString);
      } else {
        edd = DateTime.parse(eddString);
      }

      final now = DateTime.now();
      final daysFromEdd = now.difference(edd).inDays;

      if (daysFromEdd >= 0) {
        // EDD has passed
        return (week: 40, pastDue: true);
      } else {
        final weeksRemaining = edd.difference(now).inDays ~/ 7;
        final week = (40 - weeksRemaining).clamp(1, 40);
        return (week: week, pastDue: false);
      }
    } catch (e) {
      print('Error calculating week: $e — string: $eddString');
      return (week: 20, pastDue: false);
    }
  }

  // ── Week/status label shown in the greeting row ───────────────────────────
  Widget _buildWeekBadge() {
    if (currentWeek == null) return const SizedBox.shrink();

    if (isPastDue) {
      if (hasDelivered == true) {
        // Mother confirmed delivery
        return Row(
          children: [
            Icon(Icons.favorite, color: Colors.pink[400], size: 14),
            const SizedBox(width: 4),
            AutoText(
              'CONGRATULATIONS_SHORT', // e.g. "Congratulations, new mama! 🎉"
              style: TextStyle(
                color: Colors.pink[500],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        );
      } else {
        // Past due, delivery not yet confirmed
        return Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange[700], size: 14),
            const SizedBox(width: 4),
            AutoText(
              'PAST_DUE_BADGE', // e.g. "Past Due Date"
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        );
      }
    }

    // Normal pregnancy week
    return Text(
      '${autoI8lnGen.translate("WEEK")} $currentWeek',
      style: TextStyle(
        color: Colors.blue,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.22;

    final avatarImage = _resolveAvatarImage(img);

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
                alignment: Alignment.center,
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
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 9 ? '9+' : '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          children: [
            // ── Greeting row ──────────────────────────────────────────────
            Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(30),
                    image: avatarImage != null
                        ? DecorationImage(
                            image: avatarImage,
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              // Swallow bad/missing image errors so the
                              // avatar just falls back to the plain
                              // colored circle instead of crashing.
                              debugPrint(
                                  '⚠️ Avatar image failed to load: $exception');
                            },
                          )
                        : null,
                  ),
                  child: avatarImage == null
                      ? Icon(Icons.person, color: Colors.red.shade300, size: 28)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AutoText(
                            'HELLO',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '$userName👋',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // ── Replaced hardcoded week text with smart badge ──
                      _buildWeekBadge(),
                    ],
                  ),
                ),
              ],
            ),

            // ── Past-due banner (shown below greeting when applicable) ────
            if (isPastDue && hasDelivered != true) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.child_friendly,
                        color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AutoText(
                        // "Your due date has passed. Please open the check-in
                        //  form to confirm if you have delivered."
                        'HOME_PAST_DUE_BANNER',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Congratulations banner (shown after confirmed delivery) ────
            if (isPastDue && hasDelivered == true) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.pink[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.pink[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.pink[400], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AutoText(
                        // "Congratulations! 🎉 Remember to attend your
                        //  postnatal check-up with your health provider."
                        'HOME_DELIVERED_BANNER',
                        style: TextStyle(
                          color: Colors.pink[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 15),

            // ── First row of cards ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: cardHeight,
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
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: cardHeight,
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
                          String? savedEdd = expectedDeliveryDate;

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
                            // After returning from the feelings form,
                            // refresh delivery status in case she just confirmed
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PregnantFeelingsForm(
                                  requesterId: providerId ?? '',
                                  expectedDeliveryDate: savedEdd!,
                                ),
                              ),
                            );
                            // Refresh home state on return
                            await getUserVitalData();
                          } else {
                            final edd = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ExpectedDeliveryScreen(),
                              ),
                            );

                            if (edd != null && edd.isNotEmpty) {
                              await FirebaseFirestore.instance
                                  .collection('save_mother_edd')
                                  .doc(userId)
                                  .set({
                                'expectedDeliveryDate': edd,
                                'userId': userId,
                                'createdAt': FieldValue.serverTimestamp(),
                              }, SetOptions(merge: true));

                              setState(() {
                                expectedDeliveryDate = edd;
                              });
                              _applyEdd(edd);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Due date saved successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PregnantFeelingsForm(
                                    requesterId: providerId ?? '',
                                    expectedDeliveryDate: edd,
                                  ),
                                ),
                              );
                              // Refresh home state on return
                              await getUserVitalData();
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
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ── Second row of cards ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: cardHeight,
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
                          await getUserVitalData();

                          int weekToUse = currentWeek ?? 20;
                          double initialWeightToUse = userInitialWeight ?? 60.0;
                          double bmiToUse = userInitialBmi ?? 22.0;

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
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const AutoText('MHR'),
                                content: const AutoText('BFVI'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const AutoText('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: cardHeight,
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
                                title: const AutoText('⚠️ EMUO'),
                                content: const AutoText('E_S_0'),
                                actions: [
                                  TextButton(
                                    child: const AutoText('CANCEL'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  ElevatedButton(
                                    child: const AutoText('PROCEED'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
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
                              content: AutoText("P_U_A_D"),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:jambomama_nigeria/components/drawer.dart';
// import 'package:jambomama_nigeria/components/home_components.dart';
// import 'package:jambomama_nigeria/midwives/views/components/healthprovider%20drawer.dart';
// import 'package:jambomama_nigeria/views/mothers/notification.dart';
// import 'package:jambomama_nigeria/views/mothers/deliverydate.dart';
// import 'package:jambomama_nigeria/views/mothers/questionnaire.dart';
// import 'package:jambomama_nigeria/views/mothers/vital_info_update_screen.dart';
// import 'package:jambomama_nigeria/views/mothers/warning.dart';
// import 'package:jambomama_nigeria/views/mothers/you.dart';
// import 'package:intl/intl.dart';

// class HomePage extends StatefulWidget {
//   final bool isHealthProvider;
//   HomePage({super.key, required this.isHealthProvider});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   String img = '';
//   String userName = '';
//   String address = '';
//   String cityValue = '';
//   String hospital = '';
//   String stateValue = '';
//   String villageTown = '';
//   String email = '';

//   double? userInitialWeight;
//   double? userCurrentWeight;
//   double? userInitialBmi;
//   int? currentWeek;
//   String? expectedDeliveryDate;
//   DateTime? lastMenstrualPeriod;

//   // ── NEW delivery-status fields ─────────────────────────────────────────────
//   bool isPastDue = false;
//   bool? hasDelivered; // null = unknown, true = delivered, false = not yet

//   @override
//   void initState() {
//     super.initState();
//     getProfileData();
//     getProviderId();
//     getUserVitalData();
//   }

//   Stream<int> getUnreadNotificationCount() {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) return Stream.value(0);

//     return _firestore
//         .collection('notifications')
//         .where('receiverId', isEqualTo: userId)
//         .where('read', isEqualTo: false)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.length);
//   }

//   String? providerId;

//   Future<void> getProviderId() async {
//     final userId = _auth.currentUser?.uid;
//     if (userId == null) return;

//     final query = await FirebaseFirestore.instance
//         .collection('allowed_to_chat')
//         .where('requesterId', isEqualTo: userId)
//         .limit(1)
//         .get();

//     if (query.docs.isNotEmpty) {
//       setState(() {
//         providerId = query.docs.first['recipientId'];
//       });
//     }
//   }

//   Future<void> getProfileData() async {
//     final User? user = _auth.currentUser;
//     if (user != null) {
//       final DocumentSnapshot userDoc =
//           await _firestore.collection("New Mothers").doc(user.uid).get();

//       if (userDoc.exists) {
//         setState(() {
//           img = userDoc["profileImage"];
//           userName = userDoc["full name"];
//           email = userDoc["email"];
//           address = userDoc["address"];
//           cityValue = userDoc["cityValue"];
//           stateValue = userDoc["stateValue"];
//           villageTown = userDoc["villageTown"];
//           hospital = userDoc["hospital"];
//         });
//       }
//     }
//   }

//   Future<void> getUserVitalData() async {
//     final User? user = _auth.currentUser;
//     if (user == null) return;

//     try {
//       // 1. Get EDD from users collection
//       try {
//         final userDoc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();

//         if (userDoc.exists) {
//           final data = userDoc.data();
//           if (data != null && data['expectedDeliveryDate'] != null) {
//             final eddStr = (data['expectedDeliveryDate'] as Timestamp)
//                 .toDate()
//                 .toIso8601String();
//             _applyEdd(eddStr);
//           }
//         }
//       } catch (e) {}

//       // 2. Initial weight + BMI from patient background
//       final backgroundDoc = await _firestore
//           .collection('patients')
//           .doc(user.uid)
//           .collection('background')
//           .doc('patient_background')
//           .get();

//       if (backgroundDoc.exists && backgroundDoc.data() != null) {
//         final data = backgroundDoc.data()!;
//         userInitialWeight = data['weight']?.toDouble();
//         userInitialBmi = data['bmi']?.toDouble();

//         if (userInitialBmi == null &&
//             userInitialWeight != null &&
//             data['height'] != null) {
//           double heightInM = data['height'].toDouble() / 100;
//           userInitialBmi = userInitialWeight! / (heightInM * heightInM);
//         }
//       }

//       // 3. Latest weight from vital_info
//       try {
//         final vitalInfoQuery = await _firestore
//             .collection('vital_info')
//             .where('userId', isEqualTo: user.uid)
//             .orderBy('timestamp', descending: true)
//             .limit(1)
//             .get();

//         if (vitalInfoQuery.docs.isNotEmpty) {
//           userCurrentWeight =
//               vitalInfoQuery.docs.first.data()['weight']?.toDouble();
//         }
//       } catch (e) {
//         print('⚠️ Could not fetch latest vital info: $e');
//       }

//       // 4. Fallback: New Mothers profile
//       final userDocFallback =
//           await _firestore.collection("New Mothers").doc(user.uid).get();

//       if (userDocFallback.exists && userDocFallback.data() != null) {
//         final userData = userDocFallback.data()!;
//         userInitialWeight ??= userData['weight']?.toDouble();
//         userInitialWeight ??= userData['initialWeight']?.toDouble();
//         userInitialBmi ??= userData['bmi']?.toDouble();

//         if (expectedDeliveryDate == null || expectedDeliveryDate!.isEmpty) {
//           final edd = userData['expectedDeliveryDate'] as String?;
//           if (edd != null) _applyEdd(edd);
//         }
//       }

//       // 5. save_mother_edd collection (highest priority for EDD)
//       try {
//         final eddDoc =
//             await _firestore.collection('save_mother_edd').doc(user.uid).get();

//         if (eddDoc.exists && eddDoc.data() != null) {
//           final eddFromSave = eddDoc.data()!['expectedDeliveryDate'] as String?;
//           if (eddFromSave != null && eddFromSave.isNotEmpty) {
//             _applyEdd(eddFromSave);
//           }
//         }
//       } catch (e) {
//         print('⚠️ Could not fetch EDD from save_mother_edd: $e');
//       }

//       // 6. NEW — Read delivery status from mother_pregnancy_data
//       //    (written by the feelings form when mother confirms delivery)
//       try {
//         final pregnancyDoc = await _firestore
//             .collection('mother_pregnancy_data')
//             .doc(user.uid)
//             .get();

//         if (pregnancyDoc.exists && pregnancyDoc.data() != null) {
//           final data = pregnancyDoc.data()!;
//           final delivered = data['hasDelivered'];
//           if (delivered != null) {
//             setState(() {
//               hasDelivered = delivered as bool;
//             });
//           }
//         }
//       } catch (e) {
//         print('⚠️ Could not fetch delivery status: $e');
//       }
//     } catch (e) {}
//   }

//   /// Central method: parse EDD string, compute week, set isPastDue.
//   void _applyEdd(String eddString) {
//     final result = _calculateWeekAndStatus(eddString);
//     setState(() {
//       expectedDeliveryDate = eddString;
//       currentWeek = result.week;
//       isPastDue = result.pastDue;
//     });
//   }

//   // Return type for the calculation
//   ({int week, bool pastDue}) _calculateWeekAndStatus(String eddString) {
//     try {
//       DateTime edd;

//       if (eddString.contains('-') && eddString.split('-').length == 3) {
//         final parts = eddString.split('-');
//         edd = parts[0].length == 4
//             ? DateTime.parse(eddString)
//             : DateFormat('dd-MM-yyyy').parse(eddString);
//       } else {
//         edd = DateTime.parse(eddString);
//       }

//       final now = DateTime.now();
//       final daysFromEdd = now.difference(edd).inDays;

//       if (daysFromEdd >= 0) {
//         // EDD has passed
//         return (week: 40, pastDue: true);
//       } else {
//         final weeksRemaining = edd.difference(now).inDays ~/ 7;
//         final week = (40 - weeksRemaining).clamp(1, 40);
//         return (week: week, pastDue: false);
//       }
//     } catch (e) {
//       print('Error calculating week: $e — string: $eddString');
//       return (week: 20, pastDue: false);
//     }
//   }

//   // ── Week/status label shown in the greeting row ───────────────────────────
//   Widget _buildWeekBadge() {
//     if (currentWeek == null) return const SizedBox.shrink();

//     if (isPastDue) {
//       if (hasDelivered == true) {
//         // Mother confirmed delivery
//         return Row(
//           children: [
//             Icon(Icons.favorite, color: Colors.pink[400], size: 14),
//             const SizedBox(width: 4),
//             AutoText(
//               'CONGRATULATIONS_SHORT', // e.g. "Congratulations, new mama! 🎉"
//               style: TextStyle(
//                 color: Colors.pink[500],
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         );
//       } else {
//         // Past due, delivery not yet confirmed
//         return Row(
//           children: [
//             Icon(Icons.warning_amber_rounded,
//                 color: Colors.orange[700], size: 14),
//             const SizedBox(width: 4),
//             AutoText(
//               'PAST_DUE_BADGE', // e.g. "Past Due Date"
//               style: TextStyle(
//                 color: Colors.orange[700],
//                 fontWeight: FontWeight.w600,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         );
//       }
//     }

//     // Normal pregnancy week
//     return Text(
//       '${autoI8lnGen.translate("WEEK")} $currentWeek',
//       style: TextStyle(
//         color: Colors.blue,
//         fontWeight: FontWeight.w500,
//         fontSize: 12,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final cardHeight = screenHeight * 0.22;

//     return Scaffold(
//       appBar: AppBar(
//         title: AutoText('HOME_2'),
//         centerTitle: true,
//         actions: [
//           StreamBuilder<int>(
//             stream: getUnreadNotificationCount(),
//             builder: (context, snapshot) {
//               int unreadCount = snapshot.data ?? 0;
//               return Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.notifications_active),
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => const NotificationsPage(),
//                         ),
//                       );
//                     },
//                   ),
//                   if (unreadCount > 0)
//                     Positioned(
//                       right: 8,
//                       top: 8,
//                       child: Container(
//                         padding: const EdgeInsets.all(2),
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           borderRadius: BorderRadius.circular(10),
//                           border: Border.all(color: Colors.white, width: 1.5),
//                         ),
//                         constraints: const BoxConstraints(
//                           minWidth: 16,
//                           minHeight: 16,
//                         ),
//                         child: Center(
//                           child: Text(
//                             unreadCount > 9 ? '9+' : '$unreadCount',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               );
//             },
//           )
//         ],
//       ),
//       drawer: widget.isHealthProvider
//           ? HealthProviderHomeDrawer(
//               userName: userName,
//               email: email,
//               address: address,
//               cityValue: cityValue,
//               stateValue: stateValue,
//               villageTown: villageTown,
//               hospital: hospital,
//             )
//           : HomeDrawer(
//               userName: userName,
//               email: email,
//               address: address,
//               cityValue: cityValue,
//               stateValue: stateValue,
//               villageTown: villageTown,
//               hospital: hospital,
//             ),
//       body: SafeArea(
//         child: ListView(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//           children: [
//             // ── Greeting row ──────────────────────────────────────────────
//             Row(
//               children: [
//                 Container(
//                   height: 50,
//                   width: 50,
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade100,
//                     borderRadius: BorderRadius.circular(30),
//                     image: img.isNotEmpty
//                         ? DecorationImage(
//                             image: NetworkImage(img),
//                             fit: BoxFit.cover,
//                           )
//                         : null,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           AutoText(
//                             'HELLO',
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontWeight: FontWeight.w400,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           Flexible(
//                             child: Text(
//                               '$userName👋',
//                               style: const TextStyle(
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 14,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                       // ── Replaced hardcoded week text with smart badge ──
//                       _buildWeekBadge(),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             // ── Past-due banner (shown below greeting when applicable) ────
//             if (isPastDue && hasDelivered != true) ...[
//               const SizedBox(height: 10),
//               Container(
//                 width: double.infinity,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.orange[50],
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.orange[300]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.child_friendly,
//                         color: Colors.orange[700], size: 20),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: AutoText(
//                         // "Your due date has passed. Please open the check-in
//                         //  form to confirm if you have delivered."
//                         'HOME_PAST_DUE_BANNER',
//                         style: TextStyle(
//                           color: Colors.orange[800],
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],

//             // ── Congratulations banner (shown after confirmed delivery) ────
//             if (isPastDue && hasDelivered == true) ...[
//               const SizedBox(height: 10),
//               Container(
//                 width: double.infinity,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.pink[50],
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.pink[200]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.favorite, color: Colors.pink[400], size: 20),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: AutoText(
//                         // "Congratulations! 🎉 Remember to attend your
//                         //  postnatal check-up with your health provider."
//                         'HOME_DELIVERED_BANNER',
//                         style: TextStyle(
//                           color: Colors.pink[700],
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],

//             const SizedBox(height: 15),

//             // ── First row of cards ────────────────────────────────────────
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: Container(
//                     height: cardHeight,
//                     decoration: BoxDecoration(
//                       color: Colors.blueAccent,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: HomeComponents(
//                       text: 'FOLLOW_YOUR_PREGNANCY',
//                       icon: 'assets/svgs/logo-Jambomama_svg-com.svg',
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => const You()),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Container(
//                     height: cardHeight,
//                     decoration: BoxDecoration(
//                       color: Colors.purple,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: HomeComponents(
//                       text: 'QUESTIONS_TO_ANWSER',
//                       icon: 'assets/svgs/perfusion-svgrepo-com.svg',
//                       onTap: () async {
//                         try {
//                           final userId = _auth.currentUser!.uid;
//                           String? savedEdd = expectedDeliveryDate;

//                           if (savedEdd == null || savedEdd.isEmpty) {
//                             final userDoc = await FirebaseFirestore.instance
//                                 .collection('save_mother_edd')
//                                 .doc(userId)
//                                 .get();

//                             if (userDoc.exists && userDoc.data() != null) {
//                               savedEdd = userDoc.data()!['expectedDeliveryDate']
//                                   as String?;
//                             }
//                           }

//                           if (savedEdd != null && savedEdd.isNotEmpty) {
//                             // After returning from the feelings form,
//                             // refresh delivery status in case she just confirmed
//                             await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => PregnantFeelingsForm(
//                                   requesterId: providerId ?? '',
//                                   expectedDeliveryDate: savedEdd!,
//                                 ),
//                               ),
//                             );
//                             // Refresh home state on return
//                             await getUserVitalData();
//                           } else {
//                             final edd = await Navigator.push<String>(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     const ExpectedDeliveryScreen(),
//                               ),
//                             );

//                             if (edd != null && edd.isNotEmpty) {
//                               await FirebaseFirestore.instance
//                                   .collection('save_mother_edd')
//                                   .doc(userId)
//                                   .set({
//                                 'expectedDeliveryDate': edd,
//                                 'userId': userId,
//                                 'createdAt': FieldValue.serverTimestamp(),
//                               }, SetOptions(merge: true));

//                               setState(() {
//                                 expectedDeliveryDate = edd;
//                               });
//                               _applyEdd(edd);

//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('Due date saved successfully!'),
//                                   backgroundColor: Colors.green,
//                                 ),
//                               );

//                               await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => PregnantFeelingsForm(
//                                     requesterId: providerId ?? '',
//                                     expectedDeliveryDate: edd,
//                                   ),
//                                 ),
//                               );
//                               // Refresh home state on return
//                               await getUserVitalData();
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: AutoText('EDD_NOT_SELECTED')),
//                               );
//                             }
//                           }
//                         } catch (e) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: AutoText('ERROR: $e')),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),

//             // ── Second row of cards ───────────────────────────────────────
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Expanded(
//                   child: Container(
//                     height: cardHeight,
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: HomeComponents(
//                       text: 'VITAL_INFO_UPDATE',
//                       icon: 'assets/svgs/doctor-svgrepo-com.svg',
//                       onTap: () async {
//                         final userId = _auth.currentUser!.uid;

//                         final docRef = _firestore
//                             .collection('patients')
//                             .doc(userId)
//                             .collection('background')
//                             .doc('patient_background');

//                         final docSnapshot = await docRef.get();

//                         if (docSnapshot.exists) {
//                           await getUserVitalData();

//                           int weekToUse = currentWeek ?? 20;
//                           double initialWeightToUse = userInitialWeight ?? 60.0;
//                           double bmiToUse = userInitialBmi ?? 22.0;

//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => VitalInfoUpdateScreen(
//                                 userId: userId,
//                                 currentWeek: weekToUse,
//                                 initialWeight: initialWeightToUse,
//                                 initialBmi: bmiToUse,
//                               ),
//                             ),
//                           );
//                         } else {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const AutoText('MHR'),
//                                 content: const AutoText('BFVI'),
//                                 actions: [
//                                   TextButton(
//                                     onPressed: () =>
//                                         Navigator.of(context).pop(),
//                                     child: const AutoText('OK'),
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: Container(
//                     height: cardHeight,
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade500,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: HomeComponents(
//                       text: 'SOMETHING_HAPPENED',
//                       icon: 'assets/svgs/warning-sign-svgrepo-com.svg',
//                       onTap: () {
//                         if (userName.isNotEmpty) {
//                           showDialog(
//                             context: context,
//                             builder: (BuildContext context) {
//                               return AlertDialog(
//                                 title: const AutoText('⚠️ EMUO'),
//                                 content: const AutoText('E_S_0'),
//                                 actions: [
//                                   TextButton(
//                                     child: const AutoText('CANCEL'),
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                     },
//                                   ),
//                                   ElevatedButton(
//                                     child: const AutoText('PROCEED'),
//                                     onPressed: () {
//                                       Navigator.of(context).pop();
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               JamboMamaEmergencyScreen(),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               );
//                             },
//                           );
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: AutoText("P_U_A_D"),
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'package:auto_i8ln/auto_i8ln.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:jambomama_nigeria/components/drawer.dart';
// // import 'package:jambomama_nigeria/components/home_components.dart';
// // import 'package:jambomama_nigeria/midwives/views/components/healthprovider%20drawer.dart';
// // import 'package:jambomama_nigeria/views/mothers/notification.dart';
// // import 'package:jambomama_nigeria/views/mothers/deliverydate.dart';
// // import 'package:jambomama_nigeria/views/mothers/questionnaire.dart';
// // import 'package:jambomama_nigeria/views/mothers/vital_info_update_screen.dart';
// // import 'package:jambomama_nigeria/views/mothers/warning.dart';
// // import 'package:jambomama_nigeria/views/mothers/you.dart';
// // import 'package:intl/intl.dart';

// // class HomePage extends StatefulWidget {
// //   final bool isHealthProvider;
// //   HomePage({super.key, required this.isHealthProvider});

// //   @override
// //   State<HomePage> createState() => _HomePageState();
// // }

// // class _HomePageState extends State<HomePage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final FirebaseAuth _auth = FirebaseAuth.instance;

// //   String img = '';
// //   String userName = '';
// //   String address = '';
// //   String cityValue = '';
// //   String hospital = '';
// //   String stateValue = '';
// //   String villageTown = '';
// //   String email = '';

// //   // Dynamic user data variables
// //   double? userInitialWeight;
// //   double? userCurrentWeight;
// //   double? userInitialBmi;
// //   int? currentWeek;
// //   String? expectedDeliveryDate;
// //   DateTime? lastMenstrualPeriod;

// //   @override
// //   void initState() {
// //     super.initState();
// //     getProfileData();
// //     getProviderId();
// //     getUserVitalData();
// //   }

// //   Stream<int> getUnreadNotificationCount() {
// //     final userId = _auth.currentUser?.uid;
// //     if (userId == null) return Stream.value(0);

// //     return _firestore
// //         .collection('notifications')
// //         .where('receiverId', isEqualTo: userId)
// //         .where('read', isEqualTo: false)
// //         .snapshots()
// //         .map((snapshot) => snapshot.docs.length);
// //   }

// //   String? providerId;

// //   Future<void> getProviderId() async {
// //     final userId = _auth.currentUser?.uid;
// //     if (userId == null) return;

// //     final query = await FirebaseFirestore.instance
// //         .collection('allowed_to_chat')
// //         .where('requesterId', isEqualTo: userId)
// //         .limit(1)
// //         .get();

// //     if (query.docs.isNotEmpty) {
// //       setState(() {
// //         providerId = query.docs.first['recipientId'];
// //       });
// //     } else {}
// //   }

// //   Future<void> getProfileData() async {
// //     final User? user = _auth.currentUser;
// //     if (user != null) {
// //       final DocumentSnapshot userDoc =
// //           await _firestore.collection("New Mothers").doc(user.uid).get();

// //       if (userDoc.exists) {
// //         setState(() {
// //           img = userDoc["profileImage"];
// //           userName = userDoc["full name"];
// //           email = userDoc["email"];
// //           address = userDoc["address"];
// //           cityValue = userDoc["cityValue"];
// //           stateValue = userDoc["stateValue"];
// //           villageTown = userDoc["villageTown"];
// //           hospital = userDoc["hospital"];
// //         });
// //       }
// //     }
// //   }

// //   Future<void> getUserVitalData() async {
// //     final User? user = _auth.currentUser;
// //     if (user == null) return;

// //     try {
// //       // 🔹 1. Get Expected Delivery Date
// //       try {
// //         final userDoc = await FirebaseFirestore.instance
// //             .collection('users')
// //             .doc(user.uid)
// //             .get();

// //         if (userDoc.exists) {
// //           final data = userDoc.data();
// //           if (data != null && data['expectedDeliveryDate'] != null) {
// //             setState(() {
// //               expectedDeliveryDate = (data['expectedDeliveryDate'] as Timestamp)
// //                   .toDate()
// //                   .toIso8601String();

// //               if (expectedDeliveryDate != null) {
// //                 currentWeek = calculateCurrentWeek(expectedDeliveryDate!);
// //               }
// //             });
// //           }
// //         }
// //       } catch (e) {}
// //       ;

// //       // 🔹 2. Get Initial Weight and BMI from patient background
// //       final backgroundDoc = await _firestore
// //           .collection('patients')
// //           .doc(user.uid)
// //           .collection('background')
// //           .doc('patient_background')
// //           .get();

// //       if (backgroundDoc.exists && backgroundDoc.data() != null) {
// //         final data = backgroundDoc.data()!;
// //         userInitialWeight = data['weight']?.toDouble();
// //         userInitialBmi = data['bmi']?.toDouble();

// //         if (userInitialBmi == null &&
// //             userInitialWeight != null &&
// //             data['height'] != null) {
// //           double heightInM = data['height'].toDouble() / 100;
// //           userInitialBmi = userInitialWeight! / (heightInM * heightInM);
// //         }
// //       }

// //       // 🔹 3. Get latest weight from vital info
// //       try {
// //         final vitalInfoQuery = await _firestore
// //             .collection('vital_info')
// //             .where('userId', isEqualTo: user.uid)
// //             .orderBy('timestamp', descending: true)
// //             .limit(1)
// //             .get();

// //         if (vitalInfoQuery.docs.isNotEmpty) {
// //           final latestVital = vitalInfoQuery.docs.first.data();
// //           userCurrentWeight = latestVital['weight']?.toDouble();
// //         }
// //       } catch (e) {
// //         print('⚠️ Could not fetch latest vital info: $e');
// //       }

// //       // 🔹 4. Fallback: Get data from "New Mothers" profile
// //       final userDocFallback =
// //           await _firestore.collection("New Mothers").doc(user.uid).get();

// //       if (userDocFallback.exists && userDocFallback.data() != null) {
// //         final userData = userDocFallback.data()!;
// //         userInitialWeight ??= userData['weight']?.toDouble();
// //         userInitialWeight ??= userData['initialWeight']?.toDouble();
// //         userInitialBmi ??= userData['bmi']?.toDouble();

// //         if (expectedDeliveryDate == null || expectedDeliveryDate!.isEmpty) {
// //           expectedDeliveryDate = userData['expectedDeliveryDate'];
// //           if (expectedDeliveryDate != null) {
// //             setState(() {
// //               currentWeek = calculateCurrentWeek(expectedDeliveryDate!);
// //             });
// //           }
// //         }
// //       }

// //       // 🔹 5. Also check save_mother_edd collection for consistency
// //       try {
// //         final eddDoc =
// //             await _firestore.collection('save_mother_edd').doc(user.uid).get();

// //         if (eddDoc.exists && eddDoc.data() != null) {
// //           final eddFromSave = eddDoc.data()!['expectedDeliveryDate'] as String?;
// //           if (eddFromSave != null && eddFromSave.isNotEmpty) {
// //             setState(() {
// //               expectedDeliveryDate = eddFromSave;
// //               currentWeek = calculateCurrentWeek(eddFromSave);
// //             });
// //           }
// //         }
// //       } catch (e) {
// //         print('⚠️ Could not fetch EDD from save_mother_edd: $e');
// //       }
// //     } catch (e) {}
// //   }

// //   int calculateCurrentWeek(String eddString) {
// //     try {
// //       DateTime edd;

// //       if (eddString.contains('-') && eddString.split('-').length == 3) {
// //         List<String> parts = eddString.split('-');
// //         if (parts[0].length == 4) {
// //           edd = DateTime.parse(eddString);
// //         } else {
// //           edd = DateFormat('dd-MM-yyyy').parse(eddString);
// //         }
// //       } else {
// //         edd = DateTime.parse(eddString);
// //       }

// //       DateTime now = DateTime.now();
// //       int pregnancyWeek = 40 - edd.difference(now).inDays ~/ 7;

// //       return pregnancyWeek.clamp(1, 42);
// //     } catch (e) {
// //       print('Error calculating current week: $e');
// //       print('Date string: $eddString');
// //       return 20;
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Get screen dimensions for responsive sizing
// //     final screenWidth = MediaQuery.of(context).size.width;
// //     final screenHeight = MediaQuery.of(context).size.height;

// //     // Calculate responsive card dimensions
// //     final cardWidth = (screenWidth - 30) / 2;
// //     final cardHeight = screenHeight * 0.22;

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: AutoText('HOME_2'),
// //         centerTitle: true,
// //         actions: [
// //           StreamBuilder<int>(
// //             stream: getUnreadNotificationCount(),
// //             builder: (context, snapshot) {
// //               int unreadCount = snapshot.data ?? 0;
// //               return Stack(
// //                 alignment: Alignment.center,
// //                 children: [
// //                   IconButton(
// //                     icon: const Icon(Icons.notifications_active),
// //                     onPressed: () {
// //                       Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (_) => const NotificationsPage(),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                   if (unreadCount > 0)
// //                     Positioned(
// //                       right: 8,
// //                       top: 8,
// //                       child: Container(
// //                         padding: const EdgeInsets.all(2),
// //                         decoration: BoxDecoration(
// //                           color: Colors.red,
// //                           borderRadius: BorderRadius.circular(10),
// //                           border: Border.all(
// //                               color: Colors.white, width: 1.5), // Makes it pop
// //                         ),
// //                         constraints: const BoxConstraints(
// //                           minWidth: 16,
// //                           minHeight: 16,
// //                         ),
// //                         child: Center(
// //                           child: Text(
// //                             unreadCount > 9
// //                                 ? '9+'
// //                                 : '$unreadCount', // '9+' is cleaner for small badges
// //                             style: const TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 10,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                             textAlign: TextAlign.center,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                 ],
// //               );
// //             },
// //           )
// //         ],
// //       ),
// //       drawer: widget.isHealthProvider
// //           ? HealthProviderHomeDrawer(
// //               userName: userName,
// //               email: email,
// //               address: address,
// //               cityValue: cityValue,
// //               stateValue: stateValue,
// //               villageTown: villageTown,
// //               hospital: hospital,
// //             )
// //           : HomeDrawer(
// //               userName: userName,
// //               email: email,
// //               address: address,
// //               cityValue: cityValue,
// //               stateValue: stateValue,
// //               villageTown: villageTown,
// //               hospital: hospital,
// //             ),
// //       body: SafeArea(
// //         child: ListView(
// //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
// //           children: [
// //             // User greeting section
// //             Row(
// //               children: [
// //                 Container(
// //                   height: 50,
// //                   width: 50,
// //                   decoration: BoxDecoration(
// //                     color: Colors.red.shade100,
// //                     borderRadius: BorderRadius.circular(30),
// //                     image: img.isNotEmpty
// //                         ? DecorationImage(
// //                             image: NetworkImage(img),
// //                             fit: BoxFit.cover,
// //                           )
// //                         : null,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 10),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           AutoText(
// //                             'HELLO',
// //                             style: TextStyle(
// //                               color: Colors.grey,
// //                               fontWeight: FontWeight.w400,
// //                               fontSize: 14,
// //                             ),
// //                           ),
// //                           const SizedBox(width: 4),
// //                           Flexible(
// //                             child: Text(
// //                               '$userName👋',
// //                               style: const TextStyle(
// //                                 color: Colors.black,
// //                                 fontWeight: FontWeight.w600,
// //                                 fontSize: 14,
// //                               ),
// //                               overflow: TextOverflow.ellipsis,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       if (currentWeek != null)
// //                         Text(
// //                           '${autoI8lnGen.translate("WEEK")} $currentWeek',
// //                           style: TextStyle(
// //                             color: Colors.blue,
// //                             fontWeight: FontWeight.w500,
// //                             fontSize: 12,
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 15),

// //             // First row of cards
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Expanded(
// //                   child: Container(
// //                     height: cardHeight,
// //                     decoration: BoxDecoration(
// //                       color: Colors.blueAccent,
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: HomeComponents(
// //                       text: 'FOLLOW_YOUR_PREGNANCY',
// //                       icon: 'assets/svgs/logo-Jambomama_svg-com.svg',
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(builder: (context) => const You()),
// //                         );
// //                       },
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 10),
// //                 Expanded(
// //                   child: Container(
// //                     height: cardHeight,
// //                     decoration: BoxDecoration(
// //                       color: Colors.purple,
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: HomeComponents(
// //                       text: 'QUESTIONS_TO_ANWSER',
// //                       icon: 'assets/svgs/perfusion-svgrepo-com.svg',
// //                       onTap: () async {
// //                         try {
// //                           final userId = _auth.currentUser!.uid;
// //                           String? savedEdd = expectedDeliveryDate;

// //                           if (savedEdd == null || savedEdd.isEmpty) {
// //                             final userDoc = await FirebaseFirestore.instance
// //                                 .collection('save_mother_edd')
// //                                 .doc(userId)
// //                                 .get();

// //                             if (userDoc.exists && userDoc.data() != null) {
// //                               savedEdd = userDoc.data()!['expectedDeliveryDate']
// //                                   as String?;
// //                             }
// //                           }

// //                           if (savedEdd != null && savedEdd.isNotEmpty) {
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (context) => PregnantFeelingsForm(
// //                                   requesterId: providerId ?? '',
// //                                   expectedDeliveryDate: savedEdd!,
// //                                 ),
// //                               ),
// //                             );
// //                           } else {
// //                             final edd = await Navigator.push<String>(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (context) =>
// //                                     const ExpectedDeliveryScreen(),
// //                               ),
// //                             );

// //                             if (edd != null && edd.isNotEmpty) {
// //                               await FirebaseFirestore.instance
// //                                   .collection('save_mother_edd')
// //                                   .doc(userId)
// //                                   .set({
// //                                 'expectedDeliveryDate': edd,
// //                                 'userId': userId,
// //                                 'createdAt': FieldValue.serverTimestamp(),
// //                               }, SetOptions(merge: true));

// //                               setState(() {
// //                                 expectedDeliveryDate = edd;
// //                                 currentWeek = calculateCurrentWeek(edd);
// //                               });

// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 const SnackBar(
// //                                   content: Text('Due date saved successfully!'),
// //                                   backgroundColor: Colors.green,
// //                                 ),
// //                               );

// //                               Navigator.push(
// //                                 context,
// //                                 MaterialPageRoute(
// //                                   builder: (context) => PregnantFeelingsForm(
// //                                     requesterId: providerId ?? '',
// //                                     expectedDeliveryDate: edd,
// //                                   ),
// //                                 ),
// //                               );
// //                             } else {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 SnackBar(content: AutoText('EDD_NOT_SELECTED')),
// //                               );
// //                             }
// //                           }
// //                         } catch (e) {
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             SnackBar(content: AutoText('ERROR: $e')),
// //                           );
// //                         }
// //                       },
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 10),

// //             // Second row of cards
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Expanded(
// //                   child: Container(
// //                     height: cardHeight,
// //                     decoration: BoxDecoration(
// //                       color: Colors.green,
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: HomeComponents(
// //                       text: 'VITAL_INFO_UPDATE',
// //                       icon: 'assets/svgs/doctor-svgrepo-com.svg',
// //                       onTap: () async {
// //                         final userId = _auth.currentUser!.uid;

// //                         final docRef = _firestore
// //                             .collection('patients')
// //                             .doc(userId)
// //                             .collection('background')
// //                             .doc('patient_background');

// //                         final docSnapshot = await docRef.get();

// //                         if (docSnapshot.exists) {
// //                           await getUserVitalData();

// //                           int weekToUse = currentWeek ?? 20;
// //                           double initialWeightToUse = userInitialWeight ?? 60.0;
// //                           double bmiToUse = userInitialBmi ?? 22.0;

// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (context) => VitalInfoUpdateScreen(
// //                                 userId: userId,
// //                                 currentWeek: weekToUse,
// //                                 initialWeight: initialWeightToUse,
// //                                 initialBmi: bmiToUse,
// //                               ),
// //                             ),
// //                           );
// //                         } else {
// //                           showDialog(
// //                             context: context,
// //                             builder: (BuildContext context) {
// //                               return AlertDialog(
// //                                 title: const AutoText('MHR'),
// //                                 content: const AutoText('BFVI'),
// //                                 actions: [
// //                                   TextButton(
// //                                     onPressed: () =>
// //                                         Navigator.of(context).pop(),
// //                                     child: const AutoText('OK'),
// //                                   ),
// //                                 ],
// //                               );
// //                             },
// //                           );
// //                         }
// //                       },
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 10),
// //                 Expanded(
// //                   child: Container(
// //                     height: cardHeight,
// //                     decoration: BoxDecoration(
// //                       color: Colors.red.shade500,
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: HomeComponents(
// //                       text: 'SOMETHING_HAPPENED',
// //                       icon: 'assets/svgs/warning-sign-svgrepo-com.svg',
// //                       onTap: () {
// //                         if (userName.isNotEmpty) {
// //                           showDialog(
// //                             context: context,
// //                             builder: (BuildContext context) {
// //                               return AlertDialog(
// //                                 title: const AutoText('⚠️ EMUO'),
// //                                 content: const AutoText('E_S_0'),
// //                                 actions: [
// //                                   TextButton(
// //                                     child: const AutoText('CANCEL'),
// //                                     onPressed: () {
// //                                       Navigator.of(context).pop();
// //                                     },
// //                                   ),
// //                                   ElevatedButton(
// //                                     child: const AutoText('PROCEED'),
// //                                     onPressed: () {
// //                                       Navigator.of(context).pop();
// //                                       Navigator.push(
// //                                         context,
// //                                         MaterialPageRoute(
// //                                           builder: (context) =>
// //                                               JamboMamaEmergencyScreen(),
// //                                         ),
// //                                       );
// //                                     },
// //                                   ),
// //                                 ],
// //                               );
// //                             },
// //                           );
// //                         } else {
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             const SnackBar(
// //                               content: AutoText("P_U_A_D"),
// //                             ),
// //                           );
// //                         }
// //                       },
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
