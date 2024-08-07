import 'package:flutter/material.dart';

class PregnantWomanForm extends StatefulWidget {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pregnant Woman Vital Information'),
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
                      return 'Please enter your phone number';
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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Process or send data to backend (Firestore, etc.)
                      // Example: print form data
                      print('Full Name: ${_fullNameController.text}');
                      print('Date of Birth: ${_dateOfBirthController.text}');
                      print('Phone Number: ${_phoneNumberController.text}');
                      print('Address: ${_addressController.text}');
                      print(
                          'Emergency Contact: ${_emergencyContactController.text}');
                      print('Blood Type: $_bloodType');
                      print('Medical Conditions: $_medicalConditions');
                      print('Allergies: $_allergies');
                      print(
                          'Current Medications: ${_currentMedicationsController.text}');
                      print(
                          'Previous Pregnancies: ${_previousPregnanciesController.text}');
                      print('Family History: ${_familyHistoryController.text}');
                      print(
                          'Lifestyle Habits: ${_lifestyleHabitsController.text}');
                      // Reset form after submission if needed
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
