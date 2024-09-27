import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/controllers/chat_service_health.dart';
import 'package:jambomama_nigeria/midwives/views/components/midwife_home_drawer.dart';
import 'package:jambomama_nigeria/midwives/views/screens/patient_form.dart';
import 'package:jambomama_nigeria/midwives/views/screens/questionaire_screen.dart';

class Patients extends StatelessWidget {
  const Patients({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(60.0), // Adjust the height as needed
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: '  Search Patients...',
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
      drawer: HealthProviderHomeDrawer(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('allowed_to_chat')
            .where('recipientId', isEqualTo: userId) // Filter by recipientId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('You have no patients yet'));
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
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(title: Text('Loading...'));
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return ListTile(title: Text('User not found'));
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PregnantWomanForm(requesterId: requesterId),
                              ),
                            );
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
                            color: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientResponsesScreen(
                                  providerId: userId,
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
  }
}
