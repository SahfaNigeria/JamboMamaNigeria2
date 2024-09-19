import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PregnantWomanForm extends StatefulWidget {
  final String requesterId;
  const PregnantWomanForm({Key? key, required this.requesterId})
      : super(key: key);

  @override
  _PregnantWomanFormState createState() => _PregnantWomanFormState();
}

class _PregnantWomanFormState extends State<PregnantWomanForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _fullNameController = TextEditingController();
  TextEditingController _dateOfBirthController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _emergencyContactController = TextEditingController();
  String _bloodType = '';
  List<String> _medicalConditions = [];
  List<String> _allergies = [];
  TextEditingController _currentMedicationsController = TextEditingController();
  TextEditingController _previousPregnanciesController =
      TextEditingController();
  TextEditingController _familyHistoryController = TextEditingController();
  TextEditingController _lifestyleHabitsController = TextEditingController();

  Future<void> _saveVitalInfo() async {
    // Create a reference to Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    print('Clicked');

    // Create a data map
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
      'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
    };

    // Save to patient's `patient_vital_info` collection using requesterId as the document ID
    await firestore
        .collection('patient_vital_info')
        .doc(widget.requesterId)
        .set(vitalInfoData);

    // Save to doctor's collection using the doctor's UID
    final doctorId = FirebaseAuth.instance.currentUser!.uid;
    await firestore
        .collection('doctor_patient_vitals')
        .doc(doctorId)
        .collection('patients')
        .doc(widget.requesterId)
        .set(vitalInfoData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vital Information'),
      ),
      body: Padding(
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
                  decoration:
                      InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
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
                  decoration: InputDecoration(labelText: 'Emergency Contact'),
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
                  decoration: InputDecoration(labelText: 'Current Medications'),
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
                  decoration: InputDecoration(labelText: 'Family History'),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _lifestyleHabitsController,
                  decoration: InputDecoration(labelText: 'Lifestyle Habits'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _saveVitalInfo();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Vital info saved successfully!')),
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
