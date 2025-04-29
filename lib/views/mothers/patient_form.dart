import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PregnantWomanForm extends StatefulWidget {
  const PregnantWomanForm({
    Key? key,
  }) : super(key: key);

  @override
  _PregnantWomanFormState createState() => _PregnantWomanFormState();
}

class _PregnantWomanFormState extends State<PregnantWomanForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;
  bool _isHealthProvider = false;
  Map<String, dynamic>? _vitalInfoData;

  final doctorId = FirebaseAuth.instance.currentUser!.uid;

  // Initialize your TextEditingControllers here
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _dateOfBirthController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _emergencyContactController = TextEditingController();
  TextEditingController _currentMedicationsController = TextEditingController();
  TextEditingController _previousPregnanciesController =
      TextEditingController();
  TextEditingController _familyHistoryController = TextEditingController();
  TextEditingController _lifestyleHabitsController = TextEditingController();

  String _bloodType = '';
  List<String> _medicalConditions = [];
  List<String> _allergies = [];

  @override
  void initState() {
    super.initState();
    _checkIfFormSubmitted();
    _checkIfHealthProvider();
  }

  Future<void> _checkIfHealthProvider() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("Health Providers")
          .doc(currentUser.uid)
          .get();

      setState(() {
        _isHealthProvider = userDoc.exists;
      });

      if (!_isHealthProvider) {
        _showWarningDialog();
      }
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Medical Assistance Required',
            style: TextStyle(color: Colors.red),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.medical_services,
                color: Colors.red,
                size: 40,
              ),
              SizedBox(height: 16),
              Text(
                'This form contains important medical information that should only be filled out with the assistance of a qualified medical practitioner.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Please visit your healthcare provider to complete this information accurately.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Go Back'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: Text('I am with a Medical Practitioner'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkIfFormSubmitted() async {
    // Get the current user (patient) ID
    final String patientId = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // First check if the patient has already submitted their vital info
    DocumentSnapshot patientVitalInfoSnapshot =
        await firestore.collection('patient_vital_info').doc(patientId).get();

    if (patientVitalInfoSnapshot.exists) {
      setState(() {
        _isSubmitted = true;
        _vitalInfoData =
            patientVitalInfoSnapshot.data() as Map<String, dynamic>;
      });
      return;
    }

    // If not found in patient's collection, try to find in any connected doctor's records
    QuerySnapshot querySnapshot = await firestore
        .collection('allowed_to_chat')
        .where('requesterId', isEqualTo: patientId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Get the health provider that the patient is connected with
      String healthProviderId = querySnapshot.docs.first['recipientId'];

      // Check if the data exists in the doctor's collection
      DocumentSnapshot doctorPatientSnapshot = await firestore
          .collection('doctor_patient_vitals')
          .doc(healthProviderId)
          .collection('patients')
          .doc(patientId)
          .get();

      if (doctorPatientSnapshot.exists) {
        setState(() {
          _isSubmitted = true;
          _vitalInfoData = doctorPatientSnapshot.data() as Map<String, dynamic>;
        });
      }
    }
  }

  Future<void> _saveVitalInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String patientId = FirebaseAuth.instance.currentUser!.uid;

    // Prepare the vital info data
    Map<String, dynamic> vitalInfoData = {
      'fullName': _fullNameController.text,
      'dateOfBirth': _dateOfBirthController.text,
      'phoneNumber': _phoneNumberController.text,
      'address': _addressController.text,
      'emergencyContact': _emergencyContactController.text,
      'bloodType': _bloodType,
      'medicalConditions': _medicalConditions,
      'allergies': _allergies,
      'currentMedications': _currentMedicationsController.text,
      'previousPregnancies': _previousPregnanciesController.text,
      'familyHistory': _familyHistoryController.text,
      'lifestyleHabits': _lifestyleHabitsController.text,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Save to the patient's vital info collection
    await firestore
        .collection('patient_vital_info')
        .doc(patientId)
        .set(vitalInfoData);

    // Check if the patient is connected with any health provider
    QuerySnapshot querySnapshot = await firestore
        .collection('allowed_to_chat')
        .where('requesterId', isEqualTo: patientId)
        .get();

    // If connected with a health provider, also save to their collection
    if (querySnapshot.docs.isNotEmpty) {
      String healthProviderId = querySnapshot.docs.first['recipientId'];
      await firestore
          .collection('doctor_patient_vitals')
          .doc(healthProviderId)
          .collection('patients')
          .doc(patientId)
          .set(vitalInfoData);
    }

    setState(() {
      _isSubmitted = true;
      _vitalInfoData = vitalInfoData;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vital info saved successfully!')),
    );
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
        title: Text('Vital Information'),
      ),
      body: _isSubmitted
          ? _vitalInfoData != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      _buildInfoTile('Full Name', _vitalInfoData!['fullName'],
                          Icons.person),
                      _buildInfoTile('Date of Birth',
                          _vitalInfoData!['dateOfBirth'], Icons.cake_rounded),
                      _buildInfoTile('Phone Number',
                          _vitalInfoData!['phoneNumber'], Icons.phone),
                      _buildInfoTile(
                          'Address', _vitalInfoData!['address'], Icons.home),
                      _buildInfoTile(
                          'Emergency Contact',
                          _vitalInfoData!['emergencyContact'],
                          Icons.contact_phone),
                      _buildInfoTile('Blood Type', _vitalInfoData!['bloodType'],
                          Icons.bloodtype),
                      _buildInfoTile(
                          'Medical Conditions',
                          _vitalInfoData!['medicalConditions'].join(', '),
                          Icons.medical_services),
                      _buildInfoTile(
                          'Allergies',
                          _vitalInfoData!['allergies'].join(', '),
                          Icons.warning_amber_rounded),
                      _buildInfoTile(
                          'Current Medications',
                          _vitalInfoData!['currentMedications'],
                          Icons.medication),
                      _buildInfoTile(
                          'Previous Pregnancies',
                          _vitalInfoData!['previousPregnancies'],
                          Icons.pregnant_woman),
                      _buildInfoTile(
                          'Family History',
                          _vitalInfoData!['familyHistory'],
                          Icons.family_restroom),
                      _buildInfoTile(
                          'Lifestyle Habits',
                          _vitalInfoData!['lifestyleHabits'],
                          Icons.spa_outlined),
                    ],
                  ),
                )
              : Center(child: Text('No data available'))
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(labelText: 'Full Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _dateOfBirthController,
                        decoration: InputDecoration(
                            labelText: 'Date of Birth (YYYY-MM-DD)'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your date of birth';
                          }
                          // You can add more validation for date format if needed
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneNumberController,
                        decoration: InputDecoration(labelText: 'Phone Number'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter patients phone number';
                          }
                          // You can add more validation for phone number format if needed
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(labelText: 'Address'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emergencyContactController,
                        decoration:
                            InputDecoration(labelText: 'Emergency Contact'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your emergency contact';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField(
                        value: _bloodType.isNotEmpty ? _bloodType : null,
                        decoration: InputDecoration(labelText: 'Blood Type'),
                        items: [
                          DropdownMenuItem(value: 'A+', child: Text('A+')),
                          DropdownMenuItem(value: 'B+', child: Text('B+')),
                          DropdownMenuItem(value: 'AB+', child: Text('AB+')),
                          DropdownMenuItem(value: 'O+', child: Text('O+')),
                          DropdownMenuItem(value: 'A-', child: Text('A-')),
                          DropdownMenuItem(value: 'B-', child: Text('B-')),
                          DropdownMenuItem(value: 'AB-', child: Text('AB-')),
                          DropdownMenuItem(value: 'O-', child: Text('O-')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _bloodType = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your blood type';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      CheckboxListTile(
                        title: Text('Pre-existing Medical Conditions'),
                        value: _medicalConditions.contains('Diabetes'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null && value) {
                              _medicalConditions.add('Diabetes');
                            } else {
                              _medicalConditions.remove('Diabetes');
                            }
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text('Allergies'),
                        value: _allergies.contains('Medications'),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value != null && value) {
                              _allergies.add('Medications');
                            } else {
                              _allergies.remove('Medications');
                            }
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _currentMedicationsController,
                        decoration:
                            InputDecoration(labelText: 'Current Medications'),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _previousPregnanciesController,
                        decoration:
                            InputDecoration(labelText: 'Previous Pregnancies'),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _familyHistoryController,
                        decoration:
                            InputDecoration(labelText: 'Family History'),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _lifestyleHabitsController,
                        decoration:
                            InputDecoration(labelText: 'Lifestyle Habits'),
                      ),
                      SizedBox(height: 20),
                      // Other form fields go here
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _saveVitalInfo();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Vital info saved successfully!')),
                            );

                            _formKey.currentState!.reset();
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
