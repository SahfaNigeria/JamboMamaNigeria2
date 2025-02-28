import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VitalInfoScreen extends StatefulWidget {
  @override
  _VitalInfoScreenState createState() => _VitalInfoScreenState();
}

class _VitalInfoScreenState extends State<VitalInfoScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  Future<bool> isConnectedToPatient(String patientId) async {
    // Check if the logged-in health provider is connected to the patient
    var connection = await _firestore
        .collection('connections')
        .where('patientId', isEqualTo: patientId)
        .where('providerId', isEqualTo: _user?.uid)
        .get();

    return connection.docs.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getVitalInfo(String patientId) async {
    bool isConnected = await isConnectedToPatient(patientId);
    if (!isConnected) return null;

    var snapshot =
        await _firestore.collection('patient_vital_info').doc(patientId).get();

    return snapshot.exists ? snapshot.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vital Info')),
      body: FutureBuilder(
        future:
            getVitalInfo('PATIENT_ID_HERE'), // Replace with actual patient ID
        builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No access or no data available.'));
          }
          var vitalInfo = snapshot.data!;
          return ListView(
            children: [
              ListTile(title: Text('Full Name: ${vitalInfo['fullName']}')),
              ListTile(title: Text('Blood Type: ${vitalInfo['bloodType']}')),
              // Add more fields as necessary
            ],
          );
        },
      ),
    );
  }
}
