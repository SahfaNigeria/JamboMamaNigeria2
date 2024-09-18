import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/providers/connection_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfessionalsList extends StatelessWidget {
  final String location;

  ProfessionalsList({required this.location});

  Future<List<DocumentSnapshot>> fetchHealthcareProfessionals(
      String location) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Health Professionals')
        .where('professional', isEqualTo: 'professional')
        .where('cityValue', isEqualTo: location)
        // .where('approved', isEqualTo: true)
        .get();

    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Healthcare Professionals'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchHealthcareProfessionals(location),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No professionals found'));
          } else {
            List<DocumentSnapshot> professionals = snapshot.data!;
            return ListView.builder(
              itemCount: professionals.length,
              itemBuilder: (context, index) {
                var professional = professionals[index];
                String professionalId = professional['midWifeId'];
                return Consumer<ConnectionStateModel>(
                  builder: (context, connectionStateModel, child) {
                    bool requestSent = connectionStateModel
                        .hasRequestedConnectionFor(professionalId);

                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: professional['midWifeImage'] != null &&
                                      professional['midWifeImage'].isNotEmpty
                                  ? Image.network(
                                      professional['midWifeImage'],
                                      height: 50.0,
                                      width: 50.0,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Text(
                                      professional['fullName'],
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          professional['position'],
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                      Text(
                                        ',',
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          professional['healthFacility'],
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 183, 164, 164)),
                                          overflow: TextOverflow
                                              .ellipsis, // Add ellipsis to long text
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              width: 100,
                              child: TextButton(
                                onPressed: requestSent
                                    ? null
                                    : () async {
                                        // Use the model to send the connection request
                                        await connectionStateModel
                                            .sendConnectionRequest(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          professional['midWifeId'],
                                        );
                                      },
                                child: Text(
                                  requestSent ? 'Sent' : 'Connect',
                                  style: TextStyle(
                                      color: requestSent
                                          ? Colors.grey
                                          : Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
