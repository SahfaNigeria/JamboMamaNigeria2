import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/controllers/chat_service_health.dart';
import 'package:jambomama_nigeria/midwives/views/components/healthprovider%20drawer.dart';
import 'package:jambomama_nigeria/midwives/views/screens/provider_vital_info_screen.dart';
import 'package:jambomama_nigeria/midwives/views/screens/provider_warning_screen.dart';
import 'alternative_response.dart';

import 'patient_response_screen.dart';

class Patients extends StatefulWidget {
  const Patients({super.key});

  @override
  State<Patients> createState() => _PatientsState();
}

class _PatientsState extends State<Patients> {
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
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<Map<String, dynamic>>(
      future: getUserDetails(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title:  AutoText('PATIENTS'),
              centerTitle: true,
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const  AutoText('PATIENTS'),
              centerTitle: true,
            ),
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

        return Scaffold(
          appBar: AppBar(
            title: const  AutoText('PATIENTS'),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize:
                  const Size.fromHeight(60.0), // Adjust the height as needed
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: autoI8lnGen.translate("SEARCH_PATIENTS"),
                    suffixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
                  ),
                  onChanged: (value) {
                    // Implement search functionality here
                    print('Search query: $value');
                  },
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
                .where('recipientId',
                    isEqualTo: userId) // Filter by recipientId
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: AutoText('ERROR_15'));
              }

              final allowedChats = snapshot.data!.docs;

              return ListView.builder(
                itemCount: allowedChats.length,
                itemBuilder: (context, index) {
                  final chatData =
                      allowedChats[index].data() as Map<String, dynamic>;
                  final requesterId = chatData['requesterId'];

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('New Mothers') // Query mothers' collection
                        .doc(requesterId)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return ListTile(title: AutoText('LOADING_TEXT'));
                      }

                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return ListTile(title: AutoText('USER_NOT_FOUND'));
                      }

                      final userData =
                          userSnapshot.data!.data() as Map<String, dynamic>;
                      final userName = userData['full name'] ??
                          'No name'; // Ensure field name matches

                      return ListTile(
                        title: Text(
                          userName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.person,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                // // Navigate to the account page
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) =>
                                //         VitalInfoScreen(patientId: requesterId),
                                //   ),
                                // );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.chat,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                startChat(context, requesterId);
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.medical_services,
                                color: Colors.green,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ProviderPatientResponsesScreen(
                                            patientId: requesterId,
                                          )),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.medical_information,
                                color: Colors.yellow,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PatientVitalDisplayScreen(
                                      providerId: userId,
                                      patientId: requesterId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.emergency,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HealthcareProfessionalAssessmentScreen(
                                      patientId: requesterId,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
