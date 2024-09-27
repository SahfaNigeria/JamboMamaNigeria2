import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PatientResponsesScreen extends StatelessWidget {
  final String providerId;
  final String patientId;

  const PatientResponsesScreen({
    Key? key,
    required this.providerId,
    required this.patientId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Responses'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('health_provider_data')
            .doc(providerId)
            .collection('patience_responses')
            .doc(patientId)
            .collection('responses')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No responses available'));
          }

          var responsesDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: responsesDocs.length,
            itemBuilder: (context, index) {
              var response = responsesDocs[index];
              List<dynamic> questions = response['questions'];
              List<dynamic> answers = response['responses'];

              return Card(
                margin: const EdgeInsets.all(10.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: ${response['date']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (int i = 0; i < questions.length; i++) ...[
                        Text(
                          'Q: ${questions[i]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text('A: ${answers[i]}'),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
