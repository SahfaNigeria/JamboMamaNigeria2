import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VitalInfoScreen extends StatefulWidget {
  final String patientId;

  const VitalInfoScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  _VitalInfoScreenState createState() => _VitalInfoScreenState();
}

class _VitalInfoScreenState extends State<VitalInfoScreen> {
  bool isLoading = true;
  Map<String, dynamic>? patientVitalInfo;

  @override
  void initState() {
    super.initState();
    _loadPatientVitalInfo();
  }

  Future<void> _loadPatientVitalInfo() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get the health provider's ID
      final String healthProviderId = FirebaseAuth.instance.currentUser!.uid;

      // Get the patient's vital information from the doctor's collection
      final DocumentSnapshot vitalInfoDoc = await FirebaseFirestore.instance
          .collection('doctor_patient_vitals')
          .doc(healthProviderId)
          .collection('patients')
          .doc(widget.patientId)
          .get();

      if (vitalInfoDoc.exists) {
        setState(() {
          patientVitalInfo = vitalInfoDoc.data() as Map<String, dynamic>;
          isLoading = false;
        });
      } else {
        // If not found in doctor's collection, try patient's own collection
        final DocumentSnapshot patientDoc = await FirebaseFirestore.instance
            .collection('patient_vital_info')
            .doc(widget.patientId)
            .get();

        if (patientDoc.exists) {
          setState(() {
            patientVitalInfo = patientDoc.data() as Map<String, dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (error) {
      print('Error loading patient vital info: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Vital Information'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPatientVitalInfo,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : patientVitalInfo == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 64, color: Colors.amber),
                      SizedBox(height: 16),
                      Text(
                        'No vital information available for this patient',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // You could add navigation to request info or another action
                          Navigator.pop(context);
                        },
                        child: Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      // Patient basic info card at the top
                      Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.only(bottom: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(
                              color: Colors.blue.shade300, width: 1.5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                patientVitalInfo!['fullName'] ??
                                    'Unknown Patient',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Date of Birth: ${patientVitalInfo!['dateOfBirth'] ?? 'Unknown'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Blood Type: ${patientVitalInfo!['bloodType'] ?? 'Unknown'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Section title for contact info
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),

                      // Contact info tiles
                      _buildInfoTile(
                        'Phone Number',
                        patientVitalInfo!['phoneNumber'] ?? 'Not provided',
                        Icons.phone,
                      ),
                      _buildInfoTile(
                        'Address',
                        patientVitalInfo!['address'] ?? 'Not provided',
                        Icons.home,
                      ),
                      _buildInfoTile(
                        'Emergency Contact',
                        patientVitalInfo!['emergencyContact'] ?? 'Not provided',
                        Icons.contact_phone,
                      ),

                      // Section title for medical info
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Medical Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),

                      // Medical info tiles
                      _buildInfoTile(
                        'Medical Conditions',
                        patientVitalInfo!['medicalConditions'] != null
                            ? (patientVitalInfo!['medicalConditions'] is List
                                ? (patientVitalInfo!['medicalConditions']
                                        as List)
                                    .join(', ')
                                : patientVitalInfo!['medicalConditions']
                                    .toString())
                            : 'None reported',
                        Icons.medical_services,
                      ),
                      _buildInfoTile(
                        'Allergies',
                        patientVitalInfo!['allergies'] != null
                            ? (patientVitalInfo!['allergies'] is List
                                ? (patientVitalInfo!['allergies'] as List)
                                    .join(', ')
                                : patientVitalInfo!['allergies'].toString())
                            : 'None reported',
                        Icons.warning_amber_rounded,
                      ),
                      _buildInfoTile(
                        'Current Medications',
                        patientVitalInfo!['currentMedications'] ??
                            'None reported',
                        Icons.medication,
                      ),

                      // Section title for pregnancy info
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Pregnancy Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),

                      // Pregnancy info tiles
                      _buildInfoTile(
                        'Previous Pregnancies',
                        patientVitalInfo!['previousPregnancies'] ??
                            'None reported',
                        Icons.pregnant_woman,
                      ),
                      _buildInfoTile(
                        'Family History',
                        patientVitalInfo!['familyHistory'] ?? 'None reported',
                        Icons.family_restroom,
                      ),
                      _buildInfoTile(
                        'Lifestyle Habits',
                        patientVitalInfo!['lifestyleHabits'] ?? 'None reported',
                        Icons.spa_outlined,
                      ),
                    ],
                  ),
                ),
    );
  }
}
