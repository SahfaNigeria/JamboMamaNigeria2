import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AlternativeProviderPatientResponsesScreen extends StatelessWidget {
  final String patientId;

  const AlternativeProviderPatientResponsesScreen(
      {super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  AutoText('P_RESPONSES_1'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('mother_pregnancy_data')
            .doc(patientId)
            .collection('mother_periodic_feeling_form')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: AutoText('ERROR_1'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: AutoText('ERROR_2'));
          }

          final responses = snapshot.data!.docs;

          return ListView.builder(
            itemCount: responses.length,
            itemBuilder: (context, index) {
              final data = responses[index].data() as Map<String, dynamic>;

              final questions = List<String>.from(data['questions'] ?? []);
              final medicalResponses =
                  List<String>.from(data['medicalResponses'] ?? []);
              final date = data['date'] ?? 'Unknown date';
              final otherWorries = data['otherWorries'] ?? '';
              final pregnancyWeek =
                  data['pregnancyWeek']?.toString() ?? 'Unknown';

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(
                      color: Colors.grey), // Use uniform border
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoText('DATE $date',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      AutoText('P_W $pregnancyWeek'),
                      const Divider(),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: questions.length,
                        itemBuilder: (context, i) {
                          final question = questions[i];
                          final response = i < medicalResponses.length
                              ? medicalResponses[i]
                              : '';
                          if (question.isEmpty && response.isEmpty)
                            return const SizedBox.shrink();

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (question.isNotEmpty)
                                  Text('❓ Q${i + 1}: $question',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                if (response.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: Text('💬 $response'),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (otherWorries.isNotEmpty) ...[
                        const Divider(),
                        AutoText('OTHER_WORRIES $otherWorries',
                            style: const TextStyle(color: Colors.red)),
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
