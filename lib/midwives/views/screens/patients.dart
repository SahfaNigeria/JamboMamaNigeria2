import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/controllers/chat_service_health.dart';
import 'package:jambomama_nigeria/midwives/views/components/healthprovider%20drawer.dart';
import 'package:jambomama_nigeria/midwives/views/screens/provider_vital_info_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/provider_warning_screen.dart';
import 'provider_patient_background.dart';
import 'patient_response_screen.dart';

class Patients extends StatefulWidget {
  const Patients({super.key});

  @override
  State<Patients> createState() => _PatientsState();
}

class _PatientsState extends State<Patients> {
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<Map<String, dynamic>>(
      future: getUserDetails(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar:
                AppBar(title: const AutoText('PATIENTS'), centerTitle: true),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (userSnapshot.hasError) {
          return Scaffold(
            appBar:
                AppBar(title: const AutoText('PATIENTS'), centerTitle: true),
            body: Center(child: AutoText('ERROR_14')),
          );
        }

        // Extract user data for drawer
        var userData = userSnapshot.data ?? {};
        String userName = userData['fullName'] ?? '';
        String email = userData['email'] ?? '';
        String address = userData['address'] ?? '';
        String cityValue = userData['city'] ?? '';
        String stateValue = userData['state'] ?? '';
        String villageTown = userData['villageTown'] ?? '';
        String hospital = userData['hospital'] ?? '';

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isWideScreen = constraints.maxWidth > 600;
            final bool isDesktop = constraints.maxWidth > 1200;

            return Scaffold(
              appBar: AppBar(
                title: const AutoText('PATIENTS'),
                centerTitle: true,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(isWideScreen ? 70.0 : 60.0),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWideScreen ? 24.0 : 8.0,
                      vertical: 8.0,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 800 : double.infinity,
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: autoI8lnGen.translate("SEARCH_PATIENTS"),
                          suffixIcon: const Icon(Icons.search),
                          prefixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = "";
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: isWideScreen ? 12.0 : 0.0,
                            horizontal: 16.0,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase().trim();
                          });
                        },
                      ),
                    ),
                  ),
                ),
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
              body: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('allowed_to_chat')
                    .where('recipientId', isEqualTo: userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: isWideScreen ? 120 : 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            AutoText(
                              'ERROR_15',
                              style: TextStyle(
                                fontSize: isWideScreen ? 18 : 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final allowedChats = snapshot.data!.docs;

                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1200 : double.infinity,
                      ),
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWideScreen ? 16.0 : 0.0,
                          vertical: 8.0,
                        ),
                        itemCount: allowedChats.length,
                        itemBuilder: (context, index) {
                          final chatData = allowedChats[index].data()
                              as Map<String, dynamic>;
                          final requesterId = chatData['requesterId'];

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('New Mothers')
                                .doc(requesterId)
                                .get(),
                            builder: (context, userSnapshot) {
                              if (userSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isWideScreen ? 16.0 : 8.0,
                                    vertical: 8.0,
                                  ),
                                  child: const ListTile(
                                    title: AutoText('LOADING_TEXT'),
                                  ),
                                );
                              }

                              if (!userSnapshot.hasData ||
                                  !userSnapshot.data!.exists) {
                                return const SizedBox.shrink();
                              }

                              final userData = userSnapshot.data!.data()
                                  as Map<String, dynamic>;
                              final patientName =
                                  (userData['full name'] ?? 'No name')
                                      .toString();

                              // Apply search filter
                              if (_searchQuery.isNotEmpty &&
                                  !patientName
                                      .toLowerCase()
                                      .contains(_searchQuery)) {
                                return const SizedBox.shrink();
                              }

                              return _buildPatientCard(
                                context,
                                patientName,
                                requesterId,
                                userId,
                                isWideScreen,
                                isDesktop,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPatientCard(
    BuildContext context,
    String patientName,
    String requesterId,
    String userId,
    bool isWideScreen,
    bool isDesktop,
  ) {
    final actions =
        _buildActionButtons(context, requesterId, userId, isWideScreen);

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isWideScreen ? 16.0 : 8.0,
        vertical: 6.0,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isWideScreen ? 16.0 : 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isWideScreen ? 28 : 24,
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    Icons.person,
                    size: isWideScreen ? 32 : 28,
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(width: isWideScreen ? 16 : 12),
                Expanded(
                  child: Text(
                    patientName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isWideScreen ? 18 : 16,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isWideScreen ? 16 : 12),
            isDesktop
                ? _buildDesktopActions(actions)
                : isWideScreen
                    ? _buildTabletActions(actions)
                    : _buildMobileActions(actions),
          ],
        ),
      ),
    );
  }

  List<_ActionButton> _buildActionButtons(
    BuildContext context,
    String requesterId,
    String userId,
    bool isWideScreen,
  ) {
    return [
      _ActionButton(
        icon: Icons.person,
        label: 'Profile',
        color: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderPatientBackgroundScreen(
                patientId: requesterId,
                providerId: userId,
              ),
            ),
          );
        },
      ),
      _ActionButton(
        icon: Icons.chat,
        label: 'Chat',
        color: Colors.blue,
        onPressed: () {
          startChat(context, requesterId);
        },
      ),
      _ActionButton(
        icon: Icons.medical_services,
        label: 'Medical',
        color: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProviderPatientResponsesScreen(
                patientId: requesterId,
              ),
            ),
          );
        },
      ),
      _ActionButton(
        icon: Icons.medical_information,
        label: 'Vitals',
        color: Colors.orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientVitalDisplayScreen(
                providerId: userId,
                patientId: requesterId,
              ),
            ),
          );
        },
      ),
      _ActionButton(
        icon: Icons.emergency,
        label: 'Emergency',
        color: Colors.red,
        onPressed: () async {
          final latestAssessment = await FirebaseFirestore.instance
              .collection('emergency_assessments')
              .where('userId', isEqualTo: requesterId)
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          if (latestAssessment.docs.isNotEmpty) {
            final assessmentId = latestAssessment.docs.first.id;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HealthcareProfessionalAssessmentScreen(
                  patientId: requesterId,
                  assessmentId: assessmentId,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No emergency assessment found'),
              ),
            );
          }
        },
      ),
    ];
  }

  Widget _buildDesktopActions(List<_ActionButton> actions) {
    return Row(
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton.icon(
              onPressed: action.onPressed,
              icon: Icon(action.icon, size: 20),
              label: Text(action.label),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: action.color,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTabletActions(List<_ActionButton> actions) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: actions.map((action) {
        return OutlinedButton.icon(
          onPressed: action.onPressed,
          icon: Icon(action.icon, size: 20),
          label: Text(action.label),
          style: OutlinedButton.styleFrom(
            foregroundColor: action.color,
            side: BorderSide(color: action.color),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileActions(List<_ActionButton> actions) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: actions.map((action) {
        return IconButton(
          icon: Icon(action.icon),
          color: action.color,
          iconSize: 24,
          tooltip: action.label,
          onPressed: action.onPressed,
        );
      }).toList(),
    );
  }
}

class _ActionButton {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });
}

// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:jambomama_nigeria/controllers/chat_service_health.dart';
// import 'package:jambomama_nigeria/midwives/views/components/healthprovider%20drawer.dart';
// import 'package:jambomama_nigeria/midwives/views/screens/provider_vital_info_screen.dart';
// import 'package:jambomama_nigeria/midwives/views/screens/provider_warning_screen.dart';
// import 'provider_patient_background.dart';

// import 'patient_response_screen.dart';

// class Patients extends StatefulWidget {
//   const Patients({super.key});

//   @override
//   State<Patients> createState() => _PatientsState();
// }

// class _PatientsState extends State<Patients> {
//   String _searchQuery = "";
//   final TextEditingController _searchController = TextEditingController();

//   Future<Map<String, dynamic>> getUserDetails() async {
//     User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection('Health Professionals')
//           .doc(user.uid)
//           .get();

//       return userDoc.data() as Map<String, dynamic>;
//     } else {
//       throw Exception('No user logged in');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userId = FirebaseAuth.instance.currentUser!.uid;

//     return FutureBuilder<Map<String, dynamic>>(
//       future: getUserDetails(),
//       builder: (context, userSnapshot) {
//         if (userSnapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             appBar: AppBar(title: AutoText('PATIENTS'), centerTitle: true),
//             body: const Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (userSnapshot.hasError) {
//           return Scaffold(
//             appBar:
//                 AppBar(title: const AutoText('PATIENTS'), centerTitle: true),
//             body: Center(child: AutoText('ERROR_14')),
//           );
//         }

//         // Extract user data for drawer
//         var userData = userSnapshot.data ?? {};
//         String userName = userData['fullName'] ?? '';
//         String email = userData['email'] ?? '';
//         String address = userData['address'] ?? '';
//         String cityValue = userData['city'] ?? '';
//         String stateValue = userData['state'] ?? '';
//         String villageTown = userData['villageTown'] ?? '';
//         String hospital = userData['hospital'] ?? '';

//         return Scaffold(
//           appBar: AppBar(
//             title: const AutoText('PATIENTS'),
//             centerTitle: true,
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(60.0),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: TextField(
//                   controller: _searchController,
//                   decoration: InputDecoration(
//                     hintText: autoI8lnGen.translate("SEARCH_PATIENTS"),
//                     suffixIcon: const Icon(Icons.search),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(30.0),
//                       borderSide: BorderSide.none,
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
//                   ),
//                   onChanged: (value) {
//                     setState(() {
//                       _searchQuery = value.toLowerCase().trim();
//                     });
//                   },
//                 ),
//               ),
//             ),
//           ),
//           drawer: HealthProviderHomeDrawer(
//             userName: userName,
//             email: email,
//             address: address,
//             cityValue: cityValue,
//             stateValue: stateValue,
//             villageTown: villageTown,
//             hospital: hospital,
//           ),
//           body: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('allowed_to_chat')
//                 .where('recipientId', isEqualTo: userId)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return Center(child: AutoText('ERROR_15'));
//               }

//               final allowedChats = snapshot.data!.docs;

//               return ListView.builder(
//                 itemCount: allowedChats.length,
//                 itemBuilder: (context, index) {
//                   final chatData =
//                       allowedChats[index].data() as Map<String, dynamic>;
//                   final requesterId = chatData['requesterId'];

//                   return FutureBuilder<DocumentSnapshot>(
//                     future: FirebaseFirestore.instance
//                         .collection('New Mothers')
//                         .doc(requesterId)
//                         .get(),
//                     builder: (context, userSnapshot) {
//                       if (userSnapshot.connectionState ==
//                           ConnectionState.waiting) {
//                         return const ListTile(title: AutoText('LOADING_TEXT'));
//                       }

//                       if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
//                         return const ListTile(
//                             title: AutoText('USER_NOT_FOUND'));
//                       }

//                       final userData =
//                           userSnapshot.data!.data() as Map<String, dynamic>;
//                       final patientName =
//                           (userData['full name'] ?? 'No name').toString();

//                       // 🔎 Apply search filter
//                       if (_searchQuery.isNotEmpty &&
//                           !patientName.toLowerCase().contains(_searchQuery)) {
//                         return const SizedBox.shrink(); // Hide non-matching
//                       }

//                       return ListTile(
//                         title: Text(
//                           patientName,
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         trailing: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             IconButton(
//                               icon:
//                                   const Icon(Icons.person, color: Colors.black),
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         ProviderPatientBackgroundScreen(
//                                       patientId: requesterId,
//                                       providerId: userId,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.chat, color: Colors.blue),
//                               onPressed: () {
//                                 startChat(context, requesterId);
//                               },
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.medical_services,
//                                   color: Colors.green),
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           ProviderPatientResponsesScreen(
//                                             patientId: requesterId,
//                                           )),
//                                 );
//                               },
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.medical_information,
//                                   color: Colors.yellow),
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         PatientVitalDisplayScreen(
//                                       providerId: userId,
//                                       patientId: requesterId,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.emergency,
//                                   color: Colors.red),
//                               onPressed: () async {
//                                 final latestAssessment = await FirebaseFirestore
//                                     .instance
//                                     .collection('emergency_assessments')
//                                     .where('userId', isEqualTo: requesterId)
//                                     .orderBy('timestamp', descending: true)
//                                     .limit(1)
//                                     .get();

//                                 if (latestAssessment.docs.isNotEmpty) {
//                                   final assessmentId =
//                                       latestAssessment.docs.first.id;

//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) =>
//                                           HealthcareProfessionalAssessmentScreen(
//                                         patientId: requesterId,
//                                         assessmentId: assessmentId,
//                                       ),
//                                     ),
//                                   );
//                                 } else {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                         content: Text(
//                                             'No emergency assessment found')),
//                                   );
//                                 }
//                               },
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   );
//                 },
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

// // class Patients extends StatefulWidget {
// //   const Patients({super.key});

// //   @override
// //   State<Patients> createState() => _PatientsState();
// // }

// // class _PatientsState extends State<Patients> {
// //   Future<Map<String, dynamic>> getUserDetails() async {
// //     User? user = FirebaseAuth.instance.currentUser;

// //     if (user != null) {
// //       DocumentSnapshot userDoc = await FirebaseFirestore.instance
// //           .collection('Health Professionals')
// //           .doc(user.uid)
// //           .get();

// //       return userDoc.data() as Map<String, dynamic>;
// //     } else {
// //       throw Exception('No user logged in');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final userId = FirebaseAuth.instance.currentUser!.uid;

// //     return FutureBuilder<Map<String, dynamic>>(
// //       future: getUserDetails(),
// //       builder: (context, userSnapshot) {
// //         if (userSnapshot.connectionState == ConnectionState.waiting) {
// //           return Scaffold(
// //             appBar: AppBar(
// //               title: AutoText('PATIENTS'),
// //               centerTitle: true,
// //             ),
// //             body: Center(child: CircularProgressIndicator()),
// //           );
// //         }

// //         if (userSnapshot.hasError) {
// //           return Scaffold(
// //             appBar: AppBar(
// //               title: const AutoText('PATIENTS'),
// //               centerTitle: true,
// //             ),
// //             body: Center(child: AutoText('ERROR_14')),
// //           );
// //         }

// //         // Extract user data for drawer
// //         var userData = userSnapshot.data ?? {};
// //         String userName = userData['fullName'] ?? '';
// //         String email = userData['email'] ?? '';
// //         String address = userData['address'] ?? '';
// //         String cityValue = userData['city'] ?? '';
// //         String stateValue = userData['state'] ?? '';
// //         String villageTown = userData['villageTown'] ?? '';
// //         String hospital = userData['hospital'] ?? '';

// //         return Scaffold(
// //           appBar: AppBar(
// //             title: const AutoText('PATIENTS'),
// //             centerTitle: true,
// //             bottom: PreferredSize(
// //               preferredSize:
// //                   const Size.fromHeight(60.0), // Adjust the height as needed
// //               child: Padding(
// //                 padding: const EdgeInsets.all(8.0),
// //                 child: TextField(
// //                   decoration: InputDecoration(
// //                     hintText: autoI8lnGen.translate("SEARCH_PATIENTS"),
// //                     suffixIcon: const Icon(Icons.search),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(30.0),
// //                       borderSide: BorderSide.none,
// //                     ),
// //                     filled: true,
// //                     fillColor: Colors.white,
// //                     contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
// //                   ),
// //                   onChanged: (value) {
// //                     // Implement search functionality here
// //                     print('Search query: $value');
// //                   },
// //                 ),
// //               ),
// //             ),
// //           ),
// //           drawer: HealthProviderHomeDrawer(
// //             userName: userName,
// //             email: email,
// //             address: address,
// //             cityValue: cityValue,
// //             stateValue: stateValue,
// //             villageTown: villageTown,
// //             hospital: hospital,
// //           ),
// //           body: StreamBuilder<QuerySnapshot>(
// //             stream: FirebaseFirestore.instance
// //                 .collection('allowed_to_chat')
// //                 .where('recipientId',
// //                     isEqualTo: userId) // Filter by recipientId
// //                 .snapshots(),
// //             builder: (context, snapshot) {
// //               if (snapshot.connectionState == ConnectionState.waiting) {
// //                 return Center(child: CircularProgressIndicator());
// //               }

// //               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //                 return Center(child: AutoText('ERROR_15'));
// //               }

// //               final allowedChats = snapshot.data!.docs;

// //               return ListView.builder(
// //                 itemCount: allowedChats.length,
// //                 itemBuilder: (context, index) {
// //                   final chatData =
// //                       allowedChats[index].data() as Map<String, dynamic>;
// //                   final requesterId = chatData['requesterId'];

// //                   return FutureBuilder<DocumentSnapshot>(
// //                     future: FirebaseFirestore.instance
// //                         .collection('New Mothers') // Query mothers' collection
// //                         .doc(requesterId)
// //                         .get(),
// //                     builder: (context, userSnapshot) {
// //                       if (userSnapshot.connectionState ==
// //                           ConnectionState.waiting) {
// //                         return ListTile(title: AutoText('LOADING_TEXT'));
// //                       }

// //                       if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
// //                         return ListTile(title: AutoText('USER_NOT_FOUND'));
// //                       }

// //                       final userData =
// //                           userSnapshot.data!.data() as Map<String, dynamic>;
// //                       final userName = userData['full name'] ??
// //                           'No name'; // Ensure field name matches

// //                       return ListTile(
// //                         title: Text(
// //                           userName,
// //                           style: TextStyle(fontWeight: FontWeight.bold),
// //                         ),
// //                         trailing: Row(
// //                           mainAxisSize: MainAxisSize.min,
// //                           children: [
// //                             IconButton(
// //                               icon: Icon(
// //                                 Icons.person,
// //                                 color: Colors.black,
// //                               ),
// //                               onPressed: () {
// //                                 Navigator.push(
// //                                   context,
// //                                   MaterialPageRoute(
// //                                     builder: (context) =>
// //                                         ProviderPatientBackgroundScreen(
// //                                       patientId: requesterId,
// //                                       providerId: userId,
// //                                     ),
// //                                   ),
// //                                 );
// //                               },
// //                             ),
// //                             IconButton(
// //                               icon: Icon(
// //                                 Icons.chat,
// //                                 color: Colors.blue,
// //                               ),
// //                               onPressed: () {
// //                                 startChat(context, requesterId);
// //                               },
// //                             ),
// //                             IconButton(
// //                               icon: Icon(
// //                                 Icons.medical_services,
// //                                 color: Colors.green,
// //                               ),
// //                               onPressed: () {
// //                                 Navigator.push(
// //                                   context,
// //                                   MaterialPageRoute(
// //                                       builder: (context) =>
// //                                           ProviderPatientResponsesScreen(
// //                                             patientId: requesterId,
// //                                           )),
// //                                 );
// //                               },
// //                             ),
// //                             IconButton(
// //                               icon: Icon(
// //                                 Icons.medical_information,
// //                                 color: Colors.yellow,
// //                               ),
// //                               onPressed: () {
// //                                 Navigator.push(
// //                                   context,
// //                                   MaterialPageRoute(
// //                                     builder: (context) =>
// //                                         PatientVitalDisplayScreen(
// //                                       providerId: userId,
// //                                       patientId: requesterId,
// //                                     ),
// //                                   ),
// //                                 );
// //                               },
// //                             ),
// //                             IconButton(
// //                                 icon: Icon(
// //                                   Icons.emergency,
// //                                   color: Colors.red,
// //                                 ),
// //                                 onPressed: () async {
// //                                   final latestAssessment =
// //                                       await FirebaseFirestore.instance
// //                                           .collection('emergency_assessments')
// //                                           .where('userId',
// //                                               isEqualTo: requesterId)
// //                                           .orderBy('timestamp',
// //                                               descending: true)
// //                                           .limit(1)
// //                                           .get();

// //                                   if (latestAssessment.docs.isNotEmpty) {
// //                                     final assessmentId =
// //                                         latestAssessment.docs.first.id;

// //                                     Navigator.push(
// //                                       context,
// //                                       MaterialPageRoute(
// //                                         builder: (context) =>
// //                                             HealthcareProfessionalAssessmentScreen(
// //                                           patientId: requesterId,
// //                                           assessmentId: assessmentId,
// //                                         ),
// //                                       ),
// //                                     );
// //                                   } else {
// //                                     ScaffoldMessenger.of(context).showSnackBar(
// //                                       SnackBar(
// //                                           content: Text(
// //                                               'No emergency assessment found')),
// //                                     );
// //                                   }
// //                                 }),
// //                           ],
// //                         ),
// //                       );
// //                     },
// //                   );
// //                 },
// //               );
// //             },
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
