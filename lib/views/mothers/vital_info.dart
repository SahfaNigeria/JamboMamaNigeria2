import 'package:auto_i8ln/auto_i8ln.dart';
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
        title: AutoText(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: AutoText(
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
        title: AutoText('PATIENT_VITAL_INFORMATION'),
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
                      AutoText(
                        'N_V_I',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // You could add navigation to request info or another action
                          Navigator.pop(context);
                        },
                        child: AutoText('GO_BACK'),
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
                              AutoText(
                                patientVitalInfo!['fullName'] ??
                                    'U_P',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              AutoText(
                                'DOB: ${patientVitalInfo!['dateOfBirth'] ?? 'ERROR_8'}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              AutoText(
                                'B_T: ${patientVitalInfo!['bloodType'] ?? 'ERROR_8'}',
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
                        child: AutoText(
                          'C_IN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),

                      // Contact info tiles
                      _buildInfoTile(
                        'PHONE_NUMBER',
                        patientVitalInfo!['phoneNumber'] ?? 'N_P',
                        Icons.phone,
                      ),
                      _buildInfoTile(
                        'Address',
                        patientVitalInfo!['address'] ?? 'N_P',
                        Icons.home,
                      ),
                      _buildInfoTile(
                        'EMERGENCY_CONTACT',
                        patientVitalInfo!['emergencyContact'] ?? 'N_P',
                        Icons.contact_phone,
                      ),

                      // Section title for medical info
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: AutoText(
                          'MEDICAL_INFO',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),

                      // Medical info tiles
                      _buildInfoTile(
                        'M_C',
                        patientVitalInfo!['medicalConditions'] != null
                            ? (patientVitalInfo!['medicalConditions'] is List
                                ? (patientVitalInfo!['medicalConditions']
                                        as List)
                                    .join(', ')
                                : patientVitalInfo!['medicalConditions']
                                    .toString())
                            : 'N_R_P',
                        Icons.medical_services,
                      ),
                      _buildInfoTile(
                        'ALLERGIES',
                        patientVitalInfo!['allergies'] != null
                            ? (patientVitalInfo!['allergies'] is List
                                ? (patientVitalInfo!['allergies'] as List)
                                    .join(', ')
                                : patientVitalInfo!['allergies'].toString())
                            : 'N_R_P',
                        Icons.warning_amber_rounded,
                      ),
                      _buildInfoTile(
                        'C_M',
                        patientVitalInfo!['currentMedications'] ??
                            'N_R_P',
                        Icons.medication,
                      ),

                      // Section title for pregnancy info
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: AutoText(
                          'P_I',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),

                      // Pregnancy info tiles
                      _buildInfoTile(
                        'P_P',
                        patientVitalInfo!['previousPregnancies'] ??
                            'N_R_P',
                        Icons.pregnant_woman,
                      ),
                      _buildInfoTile(
                        'F_H',
                        patientVitalInfo!['familyHistory'] ?? 'N_R_P',
                        Icons.family_restroom,
                      ),
                      _buildInfoTile(
                        'L_H',
                        patientVitalInfo!['lifestyleHabits'] ?? 'N_R_P',
                        Icons.spa_outlined,
                      ),
                    ],
                  ),
                ),
    );
  }
}
