
import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

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
  bool _hasVerifiedProvider = false;
  String? _verifiedProviderId;
  String? _verifiedProviderName;
  Map<String, dynamic>? _vitalInfoData;
  Timer? _sessionTimer;
  final int _sessionTimeoutMinutes = 30; // Session timeout in minutes

  final patientId = FirebaseAuth.instance.currentUser!.uid;

  // Initialize your TextEditingControllers here
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _currentMedicationsController = TextEditingController();
  final TextEditingController _previousPregnanciesController = TextEditingController();
  final TextEditingController _familyHistoryController = TextEditingController();
  final TextEditingController _lifestyleHabitsController = TextEditingController();
  final TextEditingController _providerVerificationCodeController = TextEditingController();

  String _bloodType = '';
  List<String> _medicalConditions = [];
  List<String> _allergies = [];

  @override
  void initState() {
    super.initState();
    _checkIfFormSubmitted().then((_) {
      // Only check for health provider if form hasn't been submitted
      if (!_isSubmitted) {
        _checkIfHealthProvider();
      }
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _currentMedicationsController.dispose();
    _previousPregnanciesController.dispose();
    _familyHistoryController.dispose();
    _lifestyleHabitsController.dispose();
    _providerVerificationCodeController.dispose();
    super.dispose();
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

      // If the current user is a health provider, they can proceed
      if (_isHealthProvider) {
        setState(() {
          _hasVerifiedProvider = true;
          _verifiedProviderId = currentUser.uid;
        });
        
        // Get the provider's name
        if (userDoc.data() != null) {
          final providerData = userDoc.data() as Map<String, dynamic>;
          if (providerData.containsKey('fullName')) {
            setState(() {
              _verifiedProviderName = providerData['fullName'];
            });
          }
        }
        
        // Start session timer
        _startSessionTimer();
      } 
      // Only show warning dialog if:
      // 1. User is not a health provider AND
      // 2. Form has not been submitted yet
      else if (!_isSubmitted) {
        // Give a slight delay before showing dialog to ensure the page has loaded
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            _showRequireProviderDialog();
          }
        });
      }
    }
  }

  void _startSessionTimer() {
    // Cancel any existing timer
    _sessionTimer?.cancel();
    
    // Start a new timer
    _sessionTimer = Timer(Duration(minutes: _sessionTimeoutMinutes), () {
      // Session timeout - if the form is still open, show a warning and require re-verification
      if (mounted && !_isSubmitted && _hasVerifiedProvider) {
        setState(() {
          _hasVerifiedProvider = false;
        });
        _showSessionTimeoutDialog();
      }
    });
  }

  void _showSessionTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoText(
            'SESSION_TIMEOUT',
            style: TextStyle(color: Colors.orange),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.timer_off,
                color: Colors.orange,
                size: 40,
              ),
              SizedBox(height: 16),
              AutoText(
                'SESSION_HC',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              AutoText(
                'V_HEALTH_CARE',
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
              child: AutoText('GO_BACK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showProviderVerificationDialog();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: AutoText('R_VERIFY_PROVIDER'),
            ),
          ],
        );
      },
    );
  }

  void _showRequireProviderDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoText(
            'MEDICAL_ASSITANCE_REQUIRED',
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
              AutoText(
                'IMPORTANT_M_I',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              AutoText(
                'HEALTHCARE_PROVIDER',
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
              child:  AutoText('GO_BACK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showProviderVerificationDialog();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: AutoText('PROVIDER_PRESENT'),
            ),
          ],
        );
      },
    );
  }

  void _showProviderVerificationDialog() {
    _providerVerificationCodeController.clear();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoText('P_VERIFICATION'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoText(
                'ASK_VERIFICATION_CODE',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _providerVerificationCodeController,
                decoration: InputDecoration(
                  labelText: autoI8lnGen.translate("P_VERIFICATION_CODE"),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: AutoText('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                _verifyProviderCode(_providerVerificationCodeController.text);
                Navigator.of(context).pop();
              },
              child: AutoText('VERIFY'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _verifyProviderCode(String code) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // Query Firestore for provider with matching verification code
      QuerySnapshot providerSnapshot = await FirebaseFirestore.instance
          .collection('Health Providers')
          .where('verificationCode', isEqualTo: code)
          .limit(1)
          .get();

      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (providerSnapshot.docs.isNotEmpty) {
        // Provider found with matching code
        DocumentSnapshot providerDoc = providerSnapshot.docs.first;
        Map<String, dynamic> providerData = providerDoc.data() as Map<String, dynamic>;
        
        setState(() {
          _hasVerifiedProvider = true;
          _verifiedProviderId = providerDoc.id;
          _verifiedProviderName = providerData['fullName'] ?? autoI8lnGen.translate("H_C_P");
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AutoText('P_V $_verifiedProviderName'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Start session timer
        _startSessionTimer();
        
        // Log this verification in a separate collection for audit purposes
        await FirebaseFirestore.instance.collection('provider_verification_logs').add({
          'patientId': patientId,
          'providerId': _verifiedProviderId,
          'providerName': _verifiedProviderName,
          'timestamp': FieldValue.serverTimestamp(),
          'formType': 'PregnantWomanForm'
        });
      } else {
        // No provider found with matching code
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AutoText('INVALID_VERIFICATION_CODE'),
              backgroundColor: Colors.red,
            ),
          );
          
          // Show the verification dialog again
          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted) {
              _showProviderVerificationDialog();
            }
          });
        }
      }
    } catch (e) {
      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AutoText('FAILED_VERIFICATION_CODE'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

    if (!_hasVerifiedProvider) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AutoText('VERIFIED_PRESENT'),
          backgroundColor: Colors.red,
        ),
      );
      _showProviderVerificationDialog();
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
      'verifiedByProvider': true,
      'verifiedProviderId': _verifiedProviderId,
      'verifiedProviderName': _verifiedProviderName,
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

    // Also save to the verified provider's collection if different from connected provider
    if (_verifiedProviderId != null) {
      bool alreadySaved = false;
      
      // Check if we already saved to this provider's collection through the connected provider check
      if (querySnapshot.docs.isNotEmpty) {
        String connectedProviderId = querySnapshot.docs.first['recipientId'];
        alreadySaved = connectedProviderId == _verifiedProviderId;
      }
      
      if (!alreadySaved) {
        await firestore
            .collection('doctor_patient_vitals')
            .doc(_verifiedProviderId!)
            .collection('patients')
            .doc(patientId)
            .set(vitalInfoData);
      }
    }

    setState(() {
      _isSubmitted = true;
      _vitalInfoData = vitalInfoData;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AutoText('V_SAVED_S'),
        backgroundColor: Colors.green,
      ),
    );
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
        title: AutoText('V_I'),
        actions: [
          if (_hasVerifiedProvider && !_isSubmitted)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              margin: EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  AutoText(
                    'VERIFIED',
                    style: TextStyle(color: Colors.green[800], fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _isSubmitted
          ? _vitalInfoData != null
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Provider verification info
                      if (_vitalInfoData!.containsKey('verifiedProviderName'))
                        Card(
                          color: Colors.blue[50],
                          elevation: 2.0,
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(Icons.verified_user, color: Colors.blue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: AutoText(
                                    'THIS_INFORMATION_WAS_VERIFIED_BY ${_vitalInfoData!['verifiedProviderName']}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      Expanded(
                        child: ListView(
                          children: [
                            _buildInfoTile('VALIDATION_Q_10', _vitalInfoData!['fullName'],
                                Icons.person),
                            _buildInfoTile('DOB',
                                _vitalInfoData!['dateOfBirth'], Icons.cake_rounded),
                            _buildInfoTile('PHONE_NUMBER',
                                _vitalInfoData!['phoneNumber'], Icons.phone),
                            _buildInfoTile(
                                'Address', _vitalInfoData!['address'], Icons.home),
                            _buildInfoTile(
                                'EMERGENCY_CONTACT',
                                _vitalInfoData!['emergencyContact'],
                                Icons.contact_phone),
                            _buildInfoTile('B_T', _vitalInfoData!['bloodType'],
                                Icons.bloodtype),
                            _buildInfoTile(
                                'M_C',
                                _vitalInfoData!['medicalConditions'].join(', '),
                                Icons.medical_services),
                            _buildInfoTile(
                                'ALLERGIES',
                                _vitalInfoData!['allergies'].join(', '),
                                Icons.warning_amber_rounded),
                            _buildInfoTile(
                                'C_M',
                                _vitalInfoData!['currentMedications'],
                                Icons.medication),
                            _buildInfoTile(
                                'P_P',
                                _vitalInfoData!['previousPregnancies'],
                                Icons.pregnant_woman),
                            _buildInfoTile(
                                'F_H',
                                _vitalInfoData!['familyHistory'],
                                Icons.family_restroom),
                            _buildInfoTile(
                                'L_H',
                                _vitalInfoData!['lifestyleHabits'],
                                Icons.spa_outlined),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : Center(child: AutoText('ERROR_11'))
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Provider verification status
                  if (_hasVerifiedProvider)
                    Card(
                      color: Colors.green[50],
                      elevation: 2.0,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.verified_user, color: Colors.green),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoText(
                                    'H_P_V',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[800],
                                    ),
                                  ),
                                  AutoText(
                                    'PROVIDER_2 $_verifiedProviderName',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      color: Colors.red[50],
                      elevation: 2.0,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AutoText(
                                    'H_P_R',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[800],
                                    ),
                                  ),
                                  AutoText(
                                    'V_PROVIDER',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _showProviderVerificationDialog();
                              },
                              child: AutoText('VERIFY'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          TextFormField(
                            controller: _fullNameController,
                            decoration: InputDecoration(labelText: autoI8lnGen.translate("VALIDATION_Q_10")),
                            enabled: _hasVerifiedProvider,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return autoI8lnGen.translate("P_E_FULL_NAME");
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _dateOfBirthController,
                            decoration: InputDecoration(
                                labelText: 'E_DOB'),
                            enabled: _hasVerifiedProvider,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return autoI8lnGen.translate("P_E_DOB");
                              }
                              // You can add more validation for date format if needed
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneNumberController,
                            decoration: InputDecoration(labelText: autoI8lnGen.translate("PHONE_NUMBER")),
                            enabled: _hasVerifiedProvider,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return autoI8lnGen.translate("P_E_PH");
                              }
                              // You can add more validation for phone number format if needed
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(labelText: autoI8lnGen.translate("Address")),
                            enabled: _hasVerifiedProvider,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return autoI8lnGen.translate("P_E_AD");
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _emergencyContactController,
                            decoration:
                                InputDecoration(labelText: autoI8lnGen.translate("EMERGENCY_CONTACT")),
                            enabled: _hasVerifiedProvider,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return autoI8lnGen.translate("P_E_EC");
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _bloodType.isNotEmpty ? _bloodType : null,
                            decoration: InputDecoration(labelText: autoI8lnGen.translate("B_T")),
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
                            onChanged: _hasVerifiedProvider
                                ? (value) {
                                    setState(() {
                                      _bloodType = value!;
                                    });
                                  }
                                : null,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return autoI8lnGen.translate("P_S_BT");
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          CheckboxListTile(
                            title: AutoText('DIABETES'),
                            value: _medicalConditions.contains(autoI8lnGen.translate("DIABETES")),
                            onChanged: _hasVerifiedProvider
                                ? (bool? value) {
                                    setState(() {
                                      if (value != null && value) {
                                          _medicalConditions.add(autoI8lnGen.translate("DIABETES"));
                                      } else {
                                        _medicalConditions.remove(autoI8lnGen.translate("DIABETES"));
                                      }
                                    });
                                  }
                                : null,
                          ),
                          CheckboxListTile(
                            title: AutoText('M_A'),
                            value: _allergies.contains(autoI8lnGen.translate("M_D")),
                            onChanged: _hasVerifiedProvider
                                ? (bool? value) {
                                    setState(() {
                                      if (value != null && value) {
                                        _allergies.add(autoI8lnGen.translate("M_D"));
                                      } else {
                                        _allergies.remove(autoI8lnGen.translate("M_D"));
                                      }
                                    });
                                  }
                                : null,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _currentMedicationsController,
                            decoration:
                                InputDecoration(labelText: autoI8lnGen.translate("C_M")),
                            enabled: _hasVerifiedProvider,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _previousPregnanciesController,
                            decoration:
                                InputDecoration(labelText: autoI8lnGen.translate("P_P")),
                            enabled: _hasVerifiedProvider,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _familyHistoryController,
                            decoration:
                                InputDecoration(labelText: autoI8lnGen.translate("F_H")),
                            enabled: _hasVerifiedProvider,
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _lifestyleHabitsController,
                            decoration:
                                InputDecoration(labelText: autoI8lnGen.translate("L_H")),
                            enabled: _hasVerifiedProvider,
                          ),
                          SizedBox(height: 20),
                          
                          ElevatedButton(
                            onPressed: _hasVerifiedProvider
                                ? () async {
                                    if (_formKey.currentState!.validate()) {
                                      await _saveVitalInfo();
                                    }
                                  }
                                : null,
                            child: AutoText('SUBMIT'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}




// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class PregnantWomanForm extends StatefulWidget {
//   const PregnantWomanForm({
//     Key? key,
//   }) : super(key: key);

//   @override
//   _PregnantWomanFormState createState() => _PregnantWomanFormState();
// }

// class _PregnantWomanFormState extends State<PregnantWomanForm> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isSubmitted = false;
//   bool _isHealthProvider = false;
//   Map<String, dynamic>? _vitalInfoData;

//   final doctorId = FirebaseAuth.instance.currentUser!.uid;

//   // Initialize your TextEditingControllers here
//   TextEditingController _fullNameController = TextEditingController();
//   TextEditingController _dateOfBirthController = TextEditingController();
//   TextEditingController _phoneNumberController = TextEditingController();
//   TextEditingController _addressController = TextEditingController();
//   TextEditingController _emergencyContactController = TextEditingController();
//   TextEditingController _currentMedicationsController = TextEditingController();
//   TextEditingController _previousPregnanciesController =
//       TextEditingController();
//   TextEditingController _familyHistoryController = TextEditingController();
//   TextEditingController _lifestyleHabitsController = TextEditingController();

//   String _bloodType = '';
//   List<String> _medicalConditions = [];
//   List<String> _allergies = [];

//   @override
//   void initState() {
//     super.initState();
//     _checkIfFormSubmitted();
//     _checkIfHealthProvider();
//   }

//   Future<void> _checkIfHealthProvider() async {
//     final User? currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       final DocumentSnapshot userDoc = await FirebaseFirestore.instance
//           .collection("Health Providers")
//           .doc(currentUser.uid)
//           .get();

//       setState(() {
//         _isHealthProvider = userDoc.exists;
//       });

//       if (!_isHealthProvider) {
//         _showWarningDialog();
//       }
//     }
//   }

//   void _showWarningDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(
//             'Medical Assistance Required',
//             style: TextStyle(color: Colors.red),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Icon(
//                 Icons.medical_services,
//                 color: Colors.red,
//                 size: 40,
//               ),
//               SizedBox(height: 16),
//               Text(
//                 'This form contains important medical information that should only be filled out with the assistance of a qualified medical practitioner.',
//                 style: TextStyle(fontSize: 16),
//               ),
//               SizedBox(height: 8),
//               Text(
//                 'Please visit your healthcare provider to complete this information accurately.',
//                 style: TextStyle(fontSize: 16),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pop();
//               },
//               child: Text('Go Back'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               style: TextButton.styleFrom(
//                 foregroundColor: Colors.red,
//               ),
//               child: Text('I am with a Medical Practitioner'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _checkIfFormSubmitted() async {
//     // Get the current user (patient) ID
//     final String patientId = FirebaseAuth.instance.currentUser!.uid;

//     FirebaseFirestore firestore = FirebaseFirestore.instance;

//     // First check if the patient has already submitted their vital info
//     DocumentSnapshot patientVitalInfoSnapshot =
//         await firestore.collection('patient_vital_info').doc(patientId).get();

//     if (patientVitalInfoSnapshot.exists) {
//       setState(() {
//         _isSubmitted = true;
//         _vitalInfoData =
//             patientVitalInfoSnapshot.data() as Map<String, dynamic>;
//       });
//       return;
//     }

//     // If not found in patient's collection, try to find in any connected doctor's records
//     QuerySnapshot querySnapshot = await firestore
//         .collection('allowed_to_chat')
//         .where('requesterId', isEqualTo: patientId)
//         .get();

//     if (querySnapshot.docs.isNotEmpty) {
//       // Get the health provider that the patient is connected with
//       String healthProviderId = querySnapshot.docs.first['recipientId'];

//       // Check if the data exists in the doctor's collection
//       DocumentSnapshot doctorPatientSnapshot = await firestore
//           .collection('doctor_patient_vitals')
//           .doc(healthProviderId)
//           .collection('patients')
//           .doc(patientId)
//           .get();

//       if (doctorPatientSnapshot.exists) {
//         setState(() {
//           _isSubmitted = true;
//           _vitalInfoData = doctorPatientSnapshot.data() as Map<String, dynamic>;
//         });
//       }
//     }
//   }

//   Future<void> _saveVitalInfo() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     FirebaseFirestore firestore = FirebaseFirestore.instance;
//     String patientId = FirebaseAuth.instance.currentUser!.uid;

//     // Prepare the vital info data
//     Map<String, dynamic> vitalInfoData = {
//       'fullName': _fullNameController.text,
//       'dateOfBirth': _dateOfBirthController.text,
//       'phoneNumber': _phoneNumberController.text,
//       'address': _addressController.text,
//       'emergencyContact': _emergencyContactController.text,
//       'bloodType': _bloodType,
//       'medicalConditions': _medicalConditions,
//       'allergies': _allergies,
//       'currentMedications': _currentMedicationsController.text,
//       'previousPregnancies': _previousPregnanciesController.text,
//       'familyHistory': _familyHistoryController.text,
//       'lifestyleHabits': _lifestyleHabitsController.text,
//       'timestamp': FieldValue.serverTimestamp(),
//     };

//     // Save to the patient's vital info collection
//     await firestore
//         .collection('patient_vital_info')
//         .doc(patientId)
//         .set(vitalInfoData);

//     // Check if the patient is connected with any health provider
//     QuerySnapshot querySnapshot = await firestore
//         .collection('allowed_to_chat')
//         .where('requesterId', isEqualTo: patientId)
//         .get();

//     // If connected with a health provider, also save to their collection
//     if (querySnapshot.docs.isNotEmpty) {
//       String healthProviderId = querySnapshot.docs.first['recipientId'];
//       await firestore
//           .collection('doctor_patient_vitals')
//           .doc(healthProviderId)
//           .collection('patients')
//           .doc(patientId)
//           .set(vitalInfoData);
//     }

//     setState(() {
//       _isSubmitted = true;
//       _vitalInfoData = vitalInfoData;
//     });

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Vital info saved successfully!')),
//     );
//   }

//   Widget _buildInfoTile(String title, String value, IconData icon) {
//     return Card(
//       elevation: 4.0,
//       margin: const EdgeInsets.symmetric(vertical: 10.0),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.blueAccent),
//         title: Text(
//           title,
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         subtitle: Text(
//           value,
//           style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Vital Information'),
//       ),
//       body: _isSubmitted
//           ? _vitalInfoData != null
//               ? Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: ListView(
//                     children: [
//                       _buildInfoTile('Full Name', _vitalInfoData!['fullName'],
//                           Icons.person),
//                       _buildInfoTile('Date of Birth',
//                           _vitalInfoData!['dateOfBirth'], Icons.cake_rounded),
//                       _buildInfoTile('Phone Number',
//                           _vitalInfoData!['phoneNumber'], Icons.phone),
//                       _buildInfoTile(
//                           'Address', _vitalInfoData!['address'], Icons.home),
//                       _buildInfoTile(
//                           'Emergency Contact',
//                           _vitalInfoData!['emergencyContact'],
//                           Icons.contact_phone),
//                       _buildInfoTile('Blood Type', _vitalInfoData!['bloodType'],
//                           Icons.bloodtype),
//                       _buildInfoTile(
//                           'Medical Conditions',
//                           _vitalInfoData!['medicalConditions'].join(', '),
//                           Icons.medical_services),
//                       _buildInfoTile(
//                           'Allergies',
//                           _vitalInfoData!['allergies'].join(', '),
//                           Icons.warning_amber_rounded),
//                       _buildInfoTile(
//                           'Current Medications',
//                           _vitalInfoData!['currentMedications'],
//                           Icons.medication),
//                       _buildInfoTile(
//                           'Previous Pregnancies',
//                           _vitalInfoData!['previousPregnancies'],
//                           Icons.pregnant_woman),
//                       _buildInfoTile(
//                           'Family History',
//                           _vitalInfoData!['familyHistory'],
//                           Icons.family_restroom),
//                       _buildInfoTile(
//                           'Lifestyle Habits',
//                           _vitalInfoData!['lifestyleHabits'],
//                           Icons.spa_outlined),
//                     ],
//                   ),
//                 )
//               : Center(child: Text('No data available'))
//           : Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Form(
//                 key: _formKey,
//                 child: SingleChildScrollView(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       TextFormField(
//                         controller: _fullNameController,
//                         decoration: InputDecoration(labelText: 'Full Name'),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your full name';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       TextFormField(
//                         controller: _dateOfBirthController,
//                         decoration: InputDecoration(
//                             labelText: 'Date of Birth (YYYY-MM-DD)'),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your date of birth';
//                           }
//                           // You can add more validation for date format if needed
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       TextFormField(
//                         controller: _phoneNumberController,
//                         decoration: InputDecoration(labelText: 'Phone Number'),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter patients phone number';
//                           }
//                           // You can add more validation for phone number format if needed
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       TextFormField(
//                         controller: _addressController,
//                         decoration: InputDecoration(labelText: 'Address'),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your address';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       TextFormField(
//                         controller: _emergencyContactController,
//                         decoration:
//                             InputDecoration(labelText: 'Emergency Contact'),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your emergency contact';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       DropdownButtonFormField(
//                         value: _bloodType.isNotEmpty ? _bloodType : null,
//                         decoration: InputDecoration(labelText: 'Blood Type'),
//                         items: [
//                           DropdownMenuItem(value: 'A+', child: Text('A+')),
//                           DropdownMenuItem(value: 'B+', child: Text('B+')),
//                           DropdownMenuItem(value: 'AB+', child: Text('AB+')),
//                           DropdownMenuItem(value: 'O+', child: Text('O+')),
//                           DropdownMenuItem(value: 'A-', child: Text('A-')),
//                           DropdownMenuItem(value: 'B-', child: Text('B-')),
//                           DropdownMenuItem(value: 'AB-', child: Text('AB-')),
//                           DropdownMenuItem(value: 'O-', child: Text('O-')),
//                         ],
//                         onChanged: (value) {
//                           setState(() {
//                             _bloodType = value!;
//                           });
//                         },
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please select your blood type';
//                           }
//                           return null;
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       CheckboxListTile(
//                         title: Text('Pre-existing Medical Conditions'),
//                         value: _medicalConditions.contains('Diabetes'),
//                         onChanged: (bool? value) {
//                           setState(() {
//                             if (value != null && value) {
//                               _medicalConditions.add('Diabetes');
//                             } else {
//                               _medicalConditions.remove('Diabetes');
//                             }
//                           });
//                         },
//                       ),
//                       CheckboxListTile(
//                         title: Text('Allergies'),
//                         value: _allergies.contains('Medications'),
//                         onChanged: (bool? value) {
//                           setState(() {
//                             if (value != null && value) {
//                               _allergies.add('Medications');
//                             } else {
//                               _allergies.remove('Medications');
//                             }
//                           });
//                         },
//                       ),
//                       SizedBox(height: 16),
//                       TextFormField(
//                         controller: _currentMedicationsController,
//                         decoration:
//                             InputDecoration(labelText: 'Current Medications'),
//                       ),
//                       SizedBox(height: 16),
//                       TextFormField(
//                         controller: _previousPregnanciesController,
//                         decoration:
//                             InputDecoration(labelText: 'Previous Pregnancies'),
//                       ),
//                       SizedBox(height: 16),
//                       TextFormField(
//                         controller: _familyHistoryController,
//                         decoration:
//                             InputDecoration(labelText: 'Family History'),
//                       ),
//                       SizedBox(height: 16),
//                       TextFormField(
//                         controller: _lifestyleHabitsController,
//                         decoration:
//                             InputDecoration(labelText: 'Lifestyle Habits'),
//                       ),
//                       SizedBox(height: 20),
//                       // Other form fields go here
//                       ElevatedButton(
//                         onPressed: () async {
//                           if (_formKey.currentState!.validate()) {
//                             await _saveVitalInfo();

//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                   content:
//                                       Text('Vital info saved successfully!')),
//                             );

//                             _formKey.currentState!.reset();
//                           }
//                         },
//                         child: Text('Submit'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }
// }
