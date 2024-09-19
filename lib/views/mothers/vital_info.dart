import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VitalInfoDisplayScreen extends StatefulWidget {
  const VitalInfoDisplayScreen({Key? key}) : super(key: key);

  @override
  _VitalInfoDisplayScreenState createState() => _VitalInfoDisplayScreenState();
}

class _VitalInfoDisplayScreenState extends State<VitalInfoDisplayScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Function to retrieve the patient's data from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> _getVitalInfo() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    return await firestore.collection('patient_vital_info').doc(userId).get();
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
        title: Text(' Your Vital Information'),
        backgroundColor: Colors.greenAccent,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getVitalInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('No vital information found.'));
          }

          final data = snapshot.data!.data()!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Displaying each piece of data with an icon and a card
                _buildInfoTile('Full Name', data['fullName'], Icons.person),
                _buildInfoTile(
                    'Date of Birth', data['dateOfBirth'], Icons.cake_rounded),
                _buildInfoTile(
                    'Phone Number', data['phoneNumber'], Icons.phone),
                _buildInfoTile('Address', data['address'], Icons.home),
                _buildInfoTile('Emergency Contact', data['emergencyContact'],
                    Icons.contact_phone),
                _buildInfoTile(
                    'Blood Type', data['bloodType'], Icons.bloodtype),
                _buildInfoTile(
                    'Medical Conditions',
                    data['medicalConditions'].join(', '),
                    Icons.medical_services),
                _buildInfoTile('Allergies', data['allergies'].join(', '),
                    Icons.warning_amber_rounded),
                _buildInfoTile('Current Medications',
                    data['currentMedications'], Icons.medication),
                _buildInfoTile('Previous Pregnancies',
                    data['previousPregnancies'], Icons.pregnant_woman),
                _buildInfoTile('Family History', data['familyHistory'],
                    Icons.family_restroom),
                _buildInfoTile('Lifestyle Habits', data['lifestyleHabits'],
                    Icons.spa_outlined),

                SizedBox(height: 20),
                // ElevatedButton.icon(
                //   onPressed: () {
                //     // You can add an action here
                //   },
                //   icon: Icon(Icons.edit, color: Colors.white),
                //   label: Text('Edit Information'),
                //   style: ElevatedButton.styleFrom(
                //     primary: Colors.blueAccent,
                //     padding: EdgeInsets.symmetric(vertical: 15.0),
                //     textStyle: TextStyle(
                //       fontSize: 16,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
