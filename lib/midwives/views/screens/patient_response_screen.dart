import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProviderPatientResponsesScreen extends StatefulWidget {
  final String patientId;

  const ProviderPatientResponsesScreen({
    Key? key,
    required this.patientId,
  }) : super(key: key);

  @override
  _ProviderPatientResponsesScreenState createState() =>
      _ProviderPatientResponsesScreenState();
}

class _ProviderPatientResponsesScreenState
    extends State<ProviderPatientResponsesScreen> {
  bool _isLoading = true;
  String? _providerId;

  // Updated question labels to match the actual form questions
  final List<String> questionLabels = [
    autoI8lnGen.translate("HEALTH_QUESTION_7"),
    autoI8lnGen.translate("HEALTH_QUESTION_8"),
    autoI8lnGen.translate("HEALTH_QUESTION_9"),
    autoI8lnGen.translate("HEALTH_QUESTION_10"),
    autoI8lnGen.translate("HEALTH_QUESTION_11"),
    autoI8lnGen.translate("HEALTH_QUESTION_12"),
    autoI8lnGen.translate("HEALTH_QUESTION_13"),
    autoI8lnGen.translate("HEALTH_QUESTION_14"),
    autoI8lnGen.translate("HEALTH_QUESTION_15"),
    autoI8lnGen.translate("HEALTH_QUESTION_16"),
    autoI8lnGen.translate("HEALTH_QUESTION_17"),
    autoI8lnGen.translate("HEALTH_QUESTION_18"),
  ];

  @override
  void initState() {
    super.initState();
    _initializeProvider();
  }

  void _initializeProvider() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _providerId = user.uid;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: AutoText('PATIENT_RESPONSES'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: AutoText('PATIENT_RESPONSES'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('health_provider_data')
                  .doc(_providerId)
                  .collection('patience_responses')
                  .doc(widget.patientId)
                  .collection('responses')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: AutoText('ERROR: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final responses = snapshot.data?.docs ?? [];

                if (responses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        AutoText(
                          'ERROR_12',
                          style:
                              TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: responses.length,
                  itemBuilder: (context, index) {
                    final responseDoc = responses[index];
                    final data = responseDoc.data() as Map<String, dynamic>;
                    return _buildResponseCard(data, responseDoc.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseCard(Map<String, dynamic> data, String responseId) {
    final questions = data['questions'] as List<dynamic>? ?? [];
    final medicalResponses = data['medicalResponses'] as List<dynamic>? ?? [];
    final pregnancyWeek = data['pregnancyWeek'] ?? 0;
    final date = data['date'] ?? '';
    final otherWorries = data['otherWorries'] ?? '';
    final expectedDeliveryDate = data['expectedDeliveryDate'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoText(
                        'SUBMISSION_DATE $date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[700],
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      AutoText('P_W $pregnancyWeek'),
                      if (expectedDeliveryDate.isNotEmpty)
                        AutoText('E_D $expectedDeliveryDate'),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.teal[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AutoText(
                    'WEEK_2 $pregnancyWeek',
                    style: TextStyle(
                      color: Colors.teal[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Questions and Responses
            AutoText(
              'RESPONSES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),

            ...List.generate(questions.length, (index) {
              if (index >= questionLabels.length ||
                  questions[index].toString().isEmpty) {
                return SizedBox.shrink();
              }

              final medicalResponse = (index < medicalResponses.length)
                  ? medicalResponses[index].toString()
                  : '';

              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getResponseColor(questions[index].toString()),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      questionLabels[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      questions[index].toString(),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (medicalResponse.isNotEmpty &&
                        medicalResponse != '👍') ...[
                      SizedBox(height: 6),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getMedicalResponseColor(medicalResponse),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          medicalResponse,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                _getMedicalResponseTextColor(medicalResponse),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            if (otherWorries.isNotEmpty) ...[
              SizedBox(height: 12),
              AutoText(
                'ADDITIONAL_CONCERNS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Text(
                  otherWorries,
                  style: TextStyle(color: Colors.red[800]),
                ),
              ),
            ],

            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _markAsReviewed(responseId),
                  icon: Icon(Icons.check, size: 16),
                  label: AutoText('MARK_REVIEWED'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.teal,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _contactPatient(data),
                  icon: Icon(Icons.message, size: 16),
                  label: AutoText('CONTACT'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getResponseColor(String response) {
    if (response.toLowerCase().contains('yes') ||
        response.toLowerCase().contains('not well')) {
      return Colors.red;
    } else if (response.toLowerCase().contains('no') ||
        response.toLowerCase().contains('fine')) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  Color _getMedicalResponseColor(String response) {
    if (response.contains('Great!') || response.contains('👍')) {
      return Colors.green[100]!;
    } else if (response.contains('Contact') || response.contains('Call')) {
      return Colors.red[100]!;
    } else {
      return Colors.orange[100]!;
    }
  }

  Color _getMedicalResponseTextColor(String response) {
    if (response.contains('Great!') || response.contains('👍')) {
      return Colors.green[800]!;
    } else if (response.contains('Contact') || response.contains('Call')) {
      return Colors.red[800]!;
    } else {
      return Colors.orange[800]!;
    }
  }

  void _markAsReviewed(String responseId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoText('R_M_R'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _contactPatient(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AutoText('CONTACT_PATIENT'),
        content: AutoText('CONTACT_FUNC'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AutoText('CLOSE'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
