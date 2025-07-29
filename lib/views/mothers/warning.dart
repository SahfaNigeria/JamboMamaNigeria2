import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jambomama_nigeria/providers/connection_provider.dart';

class JamboMamaEmergencyScreen extends StatefulWidget {
  @override
  _JamboMamaEmergencyScreenState createState() =>
      _JamboMamaEmergencyScreenState();
}

class _JamboMamaEmergencyScreenState extends State<JamboMamaEmergencyScreen> {
  // Form state variables
  bool? hasVaginalBleeding;
  String? bleedingAmount;
  bool? hasVaginalDischarge;
  String? dischargeDuration;
  bool? hasFluidLoss;
  String? fluidAmount;
  bool? hasBurningUrination;
  bool? hasDiarrhea;
  int? diarrheadays;
  int? diarrheaFrequency;
  bool? hasFever;
  bool? hasCough;
  String? coughTiming;
  int? coughDays;
  bool? hasSwollenLegs;
  bool? hasNumbness;
  bool? hasHeadache;
  String? headacheSeverity;
  bool? hasContractions;
  String? contractionType;
  bool? babyStoppedMoving;
  String? otherConcerns;

  // Loading state
  bool _isSubmitting = false;

  final TextEditingController _otherConcernsController =
      TextEditingController();
  final TextEditingController _diarrheaDaysController = TextEditingController();
  final TextEditingController _diarrheaFrequencyController =
      TextEditingController();
  final TextEditingController _coughDaysController = TextEditingController();

  @override
  void dispose() {
    _otherConcernsController.dispose();
    _diarrheaDaysController.dispose();
    _diarrheaFrequencyController.dispose();
    _coughDaysController.dispose();
    super.dispose();
  }

  Widget _buildQuestionCard({
    required String title,
    required String description,
    required Widget content,
    Color? iconColor,
    IconData? icon,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Icon(icon, color: iconColor ?? Colors.red[800], size: 24),
                if (icon != null) SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildYesNoQuestion({
    required bool? value,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<bool>(
            title: Text('Yes'),
            value: true,
            groupValue: value,
            onChanged:
                _isSubmitting ? null : onChanged, // Disable during submission
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Expanded(
          child: RadioListTile<bool>(
            title: Text('No'),
            value: false,
            groupValue: value,
            onChanged:
                _isSubmitting ? null : onChanged, // Disable during submission
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoice({
    required String? value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Column(
      children: options
          .map((option) => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: value,
                onChanged: _isSubmitting
                    ? null
                    : onChanged, // Disable during submission
                contentPadding: EdgeInsets.zero,
              ))
          .toList(),
    );
  }

  void _showEmergencyAlert(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('EMERGENCY', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _checkForEmergencies() {
    if (hasVaginalBleeding == true) {
      if (bleedingAmount == 'A cup full' ||
          bleedingAmount == 'More than a cup full') {
        _showEmergencyAlert(
            'Call ambulance immediately! Heavy vaginal bleeding requires immediate medical attention.');
        return;
      }
    }

    if (hasFluidLoss == true && fluidAmount == 'A sudden puddle') {
      _showEmergencyAlert(
          'Your baby may be coming! Call ambulance immediately.');
      return;
    }

    if (hasContractions == true && contractionType == 'Very painful') {
      _showEmergencyAlert(
          'Strong contractions detected. Call your health provider or prepare to go to hospital.');
      return;
    }

    if (babyStoppedMoving == true) {
      _showEmergencyAlert(
          'Baby movement concern detected. Call your health provider immediately and prepare to go to hospital.');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('JamboMama! Emergency Assessment'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Header warning
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                color: Colors.red[800],
                child: Column(
                  children: [
                    Icon(Icons.warning, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'IMPORTANT: Your life and your baby\'s life may depend on acting quickly!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'If you are bleeding heavily from your vagina, don\'t wait - call for an ambulance first!',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  children: [
                    SizedBox(height: 16),

                    // Vaginal Bleeding
                    _buildQuestionCard(
                      title: 'Bleeding from vagina?',
                      description:
                          'In early weeks, light bleeding might be normal, but heavy bleeding is always an emergency.',
                      icon: Icons.water_drop,
                      iconColor: Colors.red[800],
                      content: Column(
                        children: [
                          _buildYesNoQuestion(
                            value: hasVaginalBleeding,
                            onChanged: (value) {
                              setState(() {
                                hasVaginalBleeding = value;
                                if (value == false) bleedingAmount = null;
                              });
                            },
                          ),
                          if (hasVaginalBleeding == true) ...[
                            SizedBox(height: 8),
                            Text('How much?',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            _buildMultipleChoice(
                              value: bleedingAmount,
                              options: [
                                'A few drops',
                                'A cup full',
                                'More than a cup full'
                              ],
                              onChanged: (value) {
                                setState(() {
                                  bleedingAmount = value;
                                });
                                _checkForEmergencies();
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Vaginal Discharge
                    _buildQuestionCard(
                      title: 'Smelly, colored vaginal discharge?',
                      description:
                          'Smelly, yellowish discharge indicates infection that must be treated.',
                      icon: Icons.warning_amber,
                      iconColor: Colors.yellow[700],
                      content: Column(
                        children: [
                          _buildYesNoQuestion(
                            value: hasVaginalDischarge,
                            onChanged: (value) {
                              setState(() {
                                hasVaginalDischarge = value;
                                if (value == false) dischargeDuration = null;
                              });
                            },
                          ),
                          if (hasVaginalDischarge == true) ...[
                            SizedBox(height: 8),
                            Text('For how long?',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            _buildMultipleChoice(
                              value: dischargeDuration,
                              options: ['Less than a week', 'More than a week'],
                              onChanged: (value) =>
                                  setState(() => dischargeDuration = value),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Loss of fluid
                    _buildQuestionCard(
                      title: 'Loss of water-like fluid from vagina?',
                      description:
                          'This comes from the amniotic sac in which the baby lives.',
                      icon: Icons.opacity,
                      iconColor: Colors.blue[300],
                      content: Column(
                        children: [
                          _buildYesNoQuestion(
                            value: hasFluidLoss,
                            onChanged: (value) {
                              setState(() {
                                hasFluidLoss = value;
                                if (value == false) fluidAmount = null;
                              });
                            },
                          ),
                          if (hasFluidLoss == true) ...[
                            SizedBox(height: 8),
                            Text('How much?',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            _buildMultipleChoice(
                              value: fluidAmount,
                              options: [
                                'A few drops',
                                'Regular flow',
                                'A sudden puddle'
                              ],
                              onChanged: (value) {
                                setState(() {
                                  fluidAmount = value;
                                });
                                _checkForEmergencies();
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Burning urination
                    _buildQuestionCard(
                      title: 'It burns when urinating?',
                      description:
                          'Burning sensation during urination needs to be tested and treated.',
                      icon: Icons.local_fire_department,
                      iconColor: Colors.orange,
                      content: _buildYesNoQuestion(
                        value: hasBurningUrination,
                        onChanged: (value) =>
                            setState(() => hasBurningUrination = value),
                      ),
                    ),

                    // Diarrhea
                    _buildQuestionCard(
                      title: 'Diarrhea?',
                      description:
                          'Try to remember if you ate something that started it or were in contact with someone ill.',
                      icon: Icons.sick,
                      iconColor: Colors.brown,
                      content: Column(
                        children: [
                          _buildYesNoQuestion(
                            value: hasDiarrhea,
                            onChanged: (value) {
                              setState(() {
                                hasDiarrhea = value;
                                if (value == false) {
                                  diarrheadays = null;
                                  diarrheaFrequency = null;
                                  _diarrheaDaysController.clear();
                                  _diarrheaFrequencyController.clear();
                                }
                              });
                            },
                          ),
                          if (hasDiarrhea == true) ...[
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _diarrheaDaysController,
                                    enabled:
                                        !_isSubmitting, // Disable during submission
                                    decoration: InputDecoration(
                                      labelText: 'Since how many days?',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      diarrheadays = int.tryParse(value);
                                    },
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _diarrheaFrequencyController,
                                    enabled:
                                        !_isSubmitting, // Disable during submission
                                    decoration: InputDecoration(
                                      labelText: 'Times per day?',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      diarrheaFrequency = int.tryParse(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Fever
                    _buildQuestionCard(
                      title: 'Fever?',
                      description:
                          'When pregnant, any fever must be checked to ensure it won\'t harm your baby.',
                      icon: Icons.thermostat,
                      iconColor: Colors.red,
                      content: _buildYesNoQuestion(
                        value: hasFever,
                        onChanged: (value) => setState(() => hasFever = value),
                      ),
                    ),

                    // Cough
                    _buildQuestionCard(
                      title: 'Cough?',
                      description:
                          'Avoid dust and smoke. Cover mouth and nose with scarf outside.',
                      icon: Icons.coronavirus,
                      iconColor: Colors.grey[600],
                      content: Column(
                        children: [
                          _buildYesNoQuestion(
                            value: hasCough,
                            onChanged: (value) {
                              setState(() {
                                hasCough = value;
                                if (value == false) {
                                  coughTiming = null;
                                  coughDays = null;
                                  _coughDaysController.clear();
                                }
                              });
                            },
                          ),
                          if (hasCough == true) ...[
                            SizedBox(height: 8),
                            Text('When?',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            _buildMultipleChoice(
                              value: coughTiming,
                              options: [
                                'At night',
                                'During day',
                                'When doing something strenuous'
                              ],
                              onChanged: (value) =>
                                  setState(() => coughTiming = value),
                            ),
                            TextField(
                              controller: _coughDaysController,
                              enabled:
                                  !_isSubmitting, // Disable during submission
                              decoration: InputDecoration(
                                labelText: 'How many days?',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                coughDays = int.tryParse(value);
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Swollen legs/hands, Numbness, Headache (grouped for pre-eclampsia screening)
                    _buildQuestionCard(
                      title: 'Pre-eclampsia Warning Signs',
                      description:
                          'These symptoms together may indicate a serious condition.',
                      icon: Icons.warning,
                      iconColor: Colors.red,
                      content: Column(
                        children: [
                          Text('Swollen legs or hands?',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildYesNoQuestion(
                            value: hasSwollenLegs,
                            onChanged: (value) =>
                                setState(() => hasSwollenLegs = value),
                          ),
                          SizedBox(height: 12),
                          Text('Numbness in hands and feet?',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildYesNoQuestion(
                            value: hasNumbness,
                            onChanged: (value) =>
                                setState(() => hasNumbness = value),
                          ),
                          SizedBox(height: 12),
                          Text('Headache?',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildYesNoQuestion(
                            value: hasHeadache,
                            onChanged: (value) {
                              setState(() {
                                hasHeadache = value;
                                if (value == false) headacheSeverity = null;
                              });
                            },
                          ),
                          if (hasHeadache == true) ...[
                            Text('How does it hurt?',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            _buildMultipleChoice(
                              value: headacheSeverity,
                              options: [
                                'A little',
                                'On and off',
                                'Very much or the whole time'
                              ],
                              onChanged: (value) =>
                                  setState(() => headacheSeverity = value),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Contractions
                    _buildQuestionCard(
                      title: 'Do you have contractions?',
                      description:
                          'Light contractions before week 37 may stop by themselves. Strong contractions may indicate labor or complications.',
                      icon: Icons.pregnant_woman,
                      iconColor: Colors.purple,
                      content: Column(
                        children: [
                          _buildYesNoQuestion(
                            value: hasContractions,
                            onChanged: (value) {
                              setState(() {
                                hasContractions = value;
                                if (value == false) contractionType = null;
                              });
                            },
                          ),
                          if (hasContractions == true) ...[
                            SizedBox(height: 8),
                            Text('What type?',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            _buildMultipleChoice(
                              value: contractionType,
                              options: [
                                'Light and far apart',
                                'Strong and regular',
                                'Very painful'
                              ],
                              onChanged: (value) {
                                setState(() {
                                  contractionType = value;
                                });
                                _checkForEmergencies();
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Baby movement
                    _buildQuestionCard(
                      title: 'Has baby stopped moving?',
                      description:
                          'After 24 weeks, take a moment each day to feel if baby moves. After week 32, sudden quietness needs checking.',
                      icon: Icons.child_care,
                      iconColor: Colors.pink,
                      content: _buildYesNoQuestion(
                        value: babyStoppedMoving,
                        onChanged: (value) {
                          setState(() {
                            babyStoppedMoving = value;
                          });
                          _checkForEmergencies();
                        },
                      ),
                    ),

                    // Other concerns
                    _buildQuestionCard(
                      title: 'Any other question or worry?',
                      description:
                          'Tell a trusted person who can help enter the message if needed.',
                      icon: Icons.message,
                      iconColor: Colors.blue,
                      content: TextField(
                        controller: _otherConcernsController,
                        maxLines: 3,
                        enabled: !_isSubmitting, // Disable during submission
                        decoration: InputDecoration(
                          hintText: 'Describe any other concerns you have...',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => otherConcerns = value,
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),

          // Loading overlay
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Card(
                  margin: EdgeInsets.all(40),
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.red[800],
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Submitting Emergency Assessment...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please wait while we save your information',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  try {
                    setState(() {
                      _isSubmitting = true;
                    });

                    _checkForEmergencies();
                    // Save to Firestore
                    await saveCurrentAssessment(context);

                    // Clear the form after successful submission
                    clearForm();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              Icon(Icons.check_circle,
                                  color: Colors.green[800], size: 24),
                              SizedBox(width: 8),
                              Text('Complete'),
                            ],
                          ),
                          content: Text(
                              'Thank you Mom! Your RHP will read this and contact you if necessary. If symptoms worsen, call your health provider or the nearest health facility. The form has been cleared for your next use'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } catch (e) {
                    // Handle errors - don't clear form if save failed
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 24),
                              SizedBox(width: 8),
                              Text('Error'),
                            ],
                          ),
                          content: Text(
                            'Failed to save assessment. Please check your connection and try again. '
                            'Your answers have been preserved.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } finally {
                    setState(() {
                      _isSubmitting = false;
                    });
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: _isSubmitting ? Colors.grey : Colors.red[800],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isSubmitting
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'SUBMITTING...',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : Text(
                  'SUBMIT ASSESSMENT',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Future<void> saveEmergencyAssessmentToFirestore({
    required BuildContext context,
    required String userId,
    bool? hasVaginalBleeding,
    String? bleedingAmount,
    bool? hasVaginalDischarge,
    String? dischargeDuration,
    bool? hasFluidLoss,
    String? fluidAmount,
    bool? hasBurningUrination,
    bool? hasDiarrhea,
    int? diarrheadays,
    int? diarrheaFrequency,
    bool? hasFever,
    bool? hasCough,
    String? coughTiming,
    int? coughDays,
    bool? hasSwollenLegs,
    bool? hasNumbness,
    bool? hasHeadache,
    String? headacheSeverity,
    bool? hasContractions,
    String? contractionType,
    bool? babyStoppedMoving,
    String? otherConcerns,
  }) async {
    try {
      // STEP 1: Get user's name from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('New Mothers') // or 'patients'
          .doc(userId)
          .get();

      final patientName = userDoc.data()?['full name'] ?? 'Unknown Patient';
      print('✅ Patient name retrieved: $patientName');

      // STEP 2: Look up connected provider
      final query = await FirebaseFirestore.instance
          .collection('allowed_to_chat')
          .where('requesterId', isEqualTo: userId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception(
            'You must be connected to a health provider to submit this emergency report.');
      }

      final providerId = query.docs.first['recipientId'];
      print('✅ Connected provider ID: $providerId');

      // STEP 3: Prepare assessment data with patient name included
      final assessmentData = {
        'userId': userId,
        'patientName': patientName, // Added patient name to assessment data
        'providerId': providerId,
        'timestamp': FieldValue.serverTimestamp(),
        'hasVaginalBleeding': hasVaginalBleeding,
        'bleedingAmount': bleedingAmount,
        'hasVaginalDischarge': hasVaginalDischarge,
        'dischargeDuration': dischargeDuration,
        'hasFluidLoss': hasFluidLoss,
        'fluidAmount': fluidAmount,
        'hasBurningUrination': hasBurningUrination,
        'hasDiarrhea': hasDiarrhea,
        'diarrheadays': diarrheadays,
        'diarrheaFrequency': diarrheaFrequency,
        'hasFever': hasFever,
        'hasCough': hasCough,
        'coughTiming': coughTiming,
        'coughDays': coughDays,
        'hasSwollenLegs': hasSwollenLegs,
        'hasNumbness': hasNumbness,
        'hasHeadache': hasHeadache,
        'headacheSeverity': headacheSeverity,
        'hasContractions': hasContractions,
        'contractionType': contractionType,
        'babyStoppedMoving': babyStoppedMoving,
        'otherConcerns': otherConcerns,
        'isEmergency': _determineEmergencyStatus(
          hasVaginalBleeding,
          bleedingAmount,
          hasFluidLoss,
          fluidAmount,
          hasContractions,
          contractionType,
          babyStoppedMoving,
        ),
        'status': 'pending_review',
      };

      // STEP 4: Save globally
      final globalRef = await FirebaseFirestore.instance
          .collection('emergency_assessments')
          .add(assessmentData);

      print('✅ Saved to global collection: ${globalRef.id}');

      // STEP 5: Save under provider's emergency_cases
      await FirebaseFirestore.instance
          .collection('health_provider_data')
          .doc(providerId)
          .collection('emergency_cases')
          .add({
        ...assessmentData,
        'centralDocId': globalRef.id,
      });

      print('✅ Also saved to provider emergency_cases');

      // STEP 6: Send notification via helper method from ConnectionStateModel
      final connectionStateModel =
          Provider.of<ConnectionStateModel>(context, listen: false);

      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserId = currentUser?.uid;

      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      await connectionStateModel.notifyProviderOfEmergency(
        providerId: providerId,
        requesterId: currentUserId,
        requesterName: patientName, // Using the already fetched name
        assessmentId: globalRef.id,
      );

      print('📢 Notification sent successfully!');
      print('Patient: $patientName');
    } catch (e) {
      print('❌ Emergency save failed: $e');
      throw Exception('Failed to save emergency report: $e');
    }
  }

// Helper function to determine if this is an emergency case
  bool _determineEmergencyStatus(
      bool? hasVaginalBleeding,
      String? bleedingAmount,
      bool? hasFluidLoss,
      String? fluidAmount,
      bool? hasContractions,
      String? contractionType,
      bool? babyStoppedMoving) {
    // Heavy bleeding
    if (hasVaginalBleeding == true &&
        (bleedingAmount == 'A cup full' ||
            bleedingAmount == 'More than a cup full')) {
      return true;
    }

    // Water broke (sudden puddle)
    if (hasFluidLoss == true && fluidAmount == 'A sudden puddle') {
      return true;
    }

    // Very painful contractions
    if (hasContractions == true && contractionType == 'Very painful') {
      return true;
    }

    // Baby stopped moving
    if (babyStoppedMoving == true) {
      return true;
    }

    return false;
  }

// Alternative method to call from your screen
  Future<void> saveCurrentAssessment(BuildContext context) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

    await saveEmergencyAssessmentToFirestore(
      userId: currentUserId,
      hasVaginalBleeding: hasVaginalBleeding,
      bleedingAmount: bleedingAmount,
      hasVaginalDischarge: hasVaginalDischarge,
      dischargeDuration: dischargeDuration,
      hasFluidLoss: hasFluidLoss,
      fluidAmount: fluidAmount,
      hasBurningUrination: hasBurningUrination,
      hasDiarrhea: hasDiarrhea,
      diarrheadays: diarrheadays,
      diarrheaFrequency: diarrheaFrequency,
      hasFever: hasFever,
      hasCough: hasCough,
      coughTiming: coughTiming,
      coughDays: coughDays,
      hasSwollenLegs: hasSwollenLegs,
      hasNumbness: hasNumbness,
      hasHeadache: hasHeadache,
      headacheSeverity: headacheSeverity,
      hasContractions: hasContractions,
      contractionType: contractionType,
      babyStoppedMoving: babyStoppedMoving,
      otherConcerns: otherConcerns,
      context: context,
    );
  }

  void clearForm() {
    setState(() {
      // Reset all boolean variables
      hasVaginalBleeding = null;
      hasVaginalDischarge = null;
      hasFluidLoss = null;
      hasBurningUrination = null;
      hasDiarrhea = null;
      hasFever = null;
      hasCough = null;
      hasSwollenLegs = null;
      hasNumbness = null;
      hasHeadache = null;
      hasContractions = null;
      babyStoppedMoving = null;

      // Reset all string variables
      bleedingAmount = null;
      dischargeDuration = null;
      fluidAmount = null;
      coughTiming = null;
      headacheSeverity = null;
      contractionType = null;
      otherConcerns = null;

      // Reset all integer variables
      diarrheadays = null;
      diarrheaFrequency = null;
      coughDays = null;
    });

    // Clear all text controllers
    _otherConcernsController.clear();
    _diarrheaDaysController.clear();
    _diarrheaFrequencyController.clear();
    _coughDaysController.clear();
  }
}



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:jambomama_nigeria/providers/connection_provider.dart';

// class JamboMamaEmergencyScreen extends StatefulWidget {
//   @override
//   _JamboMamaEmergencyScreenState createState() =>
//       _JamboMamaEmergencyScreenState();
// }

// class _JamboMamaEmergencyScreenState extends State<JamboMamaEmergencyScreen> {

//   // Form state variables
//   bool? hasVaginalBleeding;
//   String? bleedingAmount;
//   bool? hasVaginalDischarge;
//   String? dischargeDuration;
//   bool? hasFluidLoss;
//   String? fluidAmount;
//   bool? hasBurningUrination;
//   bool? hasDiarrhea;
//   int? diarrheadays;
//   int? diarrheaFrequency;
//   bool? hasFever;
//   bool? hasCough;
//   String? coughTiming;
//   int? coughDays;
//   bool? hasSwollenLegs;
//   bool? hasNumbness;
//   bool? hasHeadache;
//   String? headacheSeverity;
//   bool? hasContractions;
//   String? contractionType;
//   bool? babyStoppedMoving;
//   String? otherConcerns;

//   final TextEditingController _otherConcernsController =
//       TextEditingController();
//   final TextEditingController _diarrheaDaysController = TextEditingController();
//   final TextEditingController _diarrheaFrequencyController =
//       TextEditingController();
//   final TextEditingController _coughDaysController = TextEditingController();

//   @override
//   void dispose() {
//     _otherConcernsController.dispose();
//     _diarrheaDaysController.dispose();
//     _diarrheaFrequencyController.dispose();
//     _coughDaysController.dispose();
//     super.dispose();
//   }

//   Widget _buildQuestionCard({
//     required String title,
//     required String description,
//     required Widget content,
//     Color? iconColor,
//     IconData? icon,
//   }) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       elevation: 2,
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 if (icon != null)
//                   Icon(icon, color: iconColor ?? Colors.red[800], size: 24),
//                 if (icon != null) SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red[800],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 8),
//             Text(
//               description,
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//             SizedBox(height: 12),
//             content,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildYesNoQuestion({
//     required bool? value,
//     required Function(bool?) onChanged,
//   }) {
//     return Row(
//       children: [
//         Expanded(
//           child: RadioListTile<bool>(
//             title: Text('Yes'),
//             value: true,
//             groupValue: value,
//             onChanged: onChanged,
//             contentPadding: EdgeInsets.zero,
//           ),
//         ),
//         Expanded(
//           child: RadioListTile<bool>(
//             title: Text('No'),
//             value: false,
//             groupValue: value,
//             onChanged: onChanged,
//             contentPadding: EdgeInsets.zero,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMultipleChoice({
//     required String? value,
//     required List<String> options,
//     required Function(String?) onChanged,
//   }) {
//     return Column(
//       children: options
//           .map((option) => RadioListTile<String>(
//                 title: Text(option),
//                 value: option,
//                 groupValue: value,
//                 onChanged: onChanged,
//                 contentPadding: EdgeInsets.zero,
//               ))
//           .toList(),
//     );
//   }

//   void _showEmergencyAlert(String message) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Row(
//             children: [
//               Icon(Icons.warning, color: Colors.red, size: 24),
//               SizedBox(width: 8),
//               Text('EMERGENCY', style: TextStyle(color: Colors.red)),
//             ],
//           ),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _checkForEmergencies() {
//     if (hasVaginalBleeding == true) {
//       if (bleedingAmount == 'A cup full' ||
//           bleedingAmount == 'More than a cup full') {
//         _showEmergencyAlert(
//             'Call ambulance immediately! Heavy vaginal bleeding requires immediate medical attention.');
//         return;
//       }
//     }

//     if (hasFluidLoss == true && fluidAmount == 'A sudden puddle') {
//       _showEmergencyAlert(
//           'Your baby may be coming! Call ambulance immediately.');
//       return;
//     }

//     if (hasContractions == true && contractionType == 'Very painful') {
//       _showEmergencyAlert(
//           'Strong contractions detected. Call your health provider or prepare to go to hospital.');
//       return;
//     }

//     if (babyStoppedMoving == true) {
//       _showEmergencyAlert(
//           'Baby movement concern detected. Call your health provider immediately and prepare to go to hospital.');
//       return;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: Text('JamboMama! Emergency Assessment'),
//         backgroundColor: Colors.red[800],
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           // Header warning
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(16),
//             color: Colors.red[800],
//             child: Column(
//               children: [
//                 Icon(Icons.warning, color: Colors.white, size: 32),
//                 SizedBox(height: 8),
//                 Text(
//                   'IMPORTANT: Your life and your baby\'s life may depend on acting quickly!',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   'If you are bleeding heavily from your vagina, don\'t wait - call for an ambulance first!',
//                   style: TextStyle(color: Colors.white, fontSize: 14),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           ),

//           Expanded(
//             child: ListView(
//               children: [
//                 SizedBox(height: 16),

//                 // Vaginal Bleeding
//                 _buildQuestionCard(
//                   title: 'Bleeding from vagina?',
//                   description:
//                       'In early weeks, light bleeding might be normal, but heavy bleeding is always an emergency.',
//                   icon: Icons.water_drop,
//                   iconColor: Colors.red[800],
//                   content: Column(
//                     children: [
//                       _buildYesNoQuestion(
//                         value: hasVaginalBleeding,
//                         onChanged: (value) {
//                           setState(() {
//                             hasVaginalBleeding = value;
//                             if (value == false) bleedingAmount = null;
//                           });
//                         },
//                       ),
//                       if (hasVaginalBleeding == true) ...[
//                         SizedBox(height: 8),
//                         Text('How much?',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         _buildMultipleChoice(
//                           value: bleedingAmount,
//                           options: [
//                             'A few drops',
//                             'A cup full',
//                             'More than a cup full'
//                           ],
//                           onChanged: (value) {
//                             setState(() {
//                               bleedingAmount = value;
//                             });
//                             _checkForEmergencies();
//                           },
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // Vaginal Discharge
//                 _buildQuestionCard(
//                   title: 'Smelly, colored vaginal discharge?',
//                   description:
//                       'Smelly, yellowish discharge indicates infection that must be treated.',
//                   icon: Icons.warning_amber,
//                   iconColor: Colors.yellow[700],
//                   content: Column(
//                     children: [
//                       _buildYesNoQuestion(
//                         value: hasVaginalDischarge,
//                         onChanged: (value) {
//                           setState(() {
//                             hasVaginalDischarge = value;
//                             if (value == false) dischargeDuration = null;
//                           });
//                         },
//                       ),
//                       if (hasVaginalDischarge == true) ...[
//                         SizedBox(height: 8),
//                         Text('For how long?',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         _buildMultipleChoice(
//                           value: dischargeDuration,
//                           options: ['Less than a week', 'More than a week'],
//                           onChanged: (value) =>
//                               setState(() => dischargeDuration = value),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // Loss of fluid
//                 _buildQuestionCard(
//                   title: 'Loss of water-like fluid from vagina?',
//                   description:
//                       'This comes from the amniotic sac in which the baby lives.',
//                   icon: Icons.opacity,
//                   iconColor: Colors.blue[300],
//                   content: Column(
//                     children: [
//                       _buildYesNoQuestion(
//                         value: hasFluidLoss,
//                         onChanged: (value) {
//                           setState(() {
//                             hasFluidLoss = value;
//                             if (value == false) fluidAmount = null;
//                           });
//                         },
//                       ),
//                       if (hasFluidLoss == true) ...[
//                         SizedBox(height: 8),
//                         Text('How much?',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         _buildMultipleChoice(
//                           value: fluidAmount,
//                           options: [
//                             'A few drops',
//                             'Regular flow',
//                             'A sudden puddle'
//                           ],
//                           onChanged: (value) {
//                             setState(() {
//                               fluidAmount = value;
//                             });
//                             _checkForEmergencies();
//                           },
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // Burning urination
//                 _buildQuestionCard(
//                   title: 'It burns when urinating?',
//                   description:
//                       'Burning sensation during urination needs to be tested and treated.',
//                   icon: Icons.local_fire_department,
//                   iconColor: Colors.orange,
//                   content: _buildYesNoQuestion(
//                     value: hasBurningUrination,
//                     onChanged: (value) =>
//                         setState(() => hasBurningUrination = value),
//                   ),
//                 ),

//                 // Diarrhea
//                 _buildQuestionCard(
//                   title: 'Diarrhea?',
//                   description:
//                       'Try to remember if you ate something that started it or were in contact with someone ill.',
//                   icon: Icons.sick,
//                   iconColor: Colors.brown,
//                   content: Column(
//                     children: [
//                       _buildYesNoQuestion(
//                         value: hasDiarrhea,
//                         onChanged: (value) {
//                           setState(() {
//                             hasDiarrhea = value;
//                             if (value == false) {
//                               diarrheadays = null;
//                               diarrheaFrequency = null;
//                               _diarrheaDaysController.clear();
//                               _diarrheaFrequencyController.clear();
//                             }
//                           });
//                         },
//                       ),
//                       if (hasDiarrhea == true) ...[
//                         SizedBox(height: 8),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 controller: _diarrheaDaysController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Since how many days?',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (value) {
//                                   diarrheadays = int.tryParse(value);
//                                 },
//                               ),
//                             ),
//                             SizedBox(width: 8),
//                             Expanded(
//                               child: TextField(
//                                 controller: _diarrheaFrequencyController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Times per day?',
//                                   border: OutlineInputBorder(),
//                                 ),
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (value) {
//                                   diarrheaFrequency = int.tryParse(value);
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // Fever
//                 _buildQuestionCard(
//                   title: 'Fever?',
//                   description:
//                       'When pregnant, any fever must be checked to ensure it won\'t harm your baby.',
//                   icon: Icons.thermostat,
//                   iconColor: Colors.red,
//                   content: _buildYesNoQuestion(
//                     value: hasFever,
//                     onChanged: (value) => setState(() => hasFever = value),
//                   ),
//                 ),

//                 // Cough
//                 _buildQuestionCard(
//                   title: 'Cough?',
//                   description:
//                       'Avoid dust and smoke. Cover mouth and nose with scarf outside.',
//                   icon: Icons.coronavirus,
//                   iconColor: Colors.grey[600],
//                   content: Column(
//                     children: [
//                       _buildYesNoQuestion(
//                         value: hasCough,
//                         onChanged: (value) {
//                           setState(() {
//                             hasCough = value;
//                             if (value == false) {
//                               coughTiming = null;
//                               coughDays = null;
//                               _coughDaysController.clear();
//                             }
//                           });
//                         },
//                       ),
//                       if (hasCough == true) ...[
//                         SizedBox(height: 8),
//                         Text('When?',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         _buildMultipleChoice(
//                           value: coughTiming,
//                           options: [
//                             'At night',
//                             'During day',
//                             'When doing something strenuous'
//                           ],
//                           onChanged: (value) =>
//                               setState(() => coughTiming = value),
//                         ),
//                         TextField(
//                           controller: _coughDaysController,
//                           decoration: InputDecoration(
//                             labelText: 'How many days?',
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.number,
//                           onChanged: (value) {
//                             coughDays = int.tryParse(value);
//                           },
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // Swollen legs/hands, Numbness, Headache (grouped for pre-eclampsia screening)
//                 _buildQuestionCard(
//                   title: 'Pre-eclampsia Warning Signs',
//                   description:
//                       'These symptoms together may indicate a serious condition.',
//                   icon: Icons.warning,
//                   iconColor: Colors.red,
//                   content: Column(
//                     children: [
//                       Text('Swollen legs or hands?',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       _buildYesNoQuestion(
//                         value: hasSwollenLegs,
//                         onChanged: (value) =>
//                             setState(() => hasSwollenLegs = value),
//                       ),
//                       SizedBox(height: 12),
//                       Text('Numbness in hands and feet?',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       _buildYesNoQuestion(
//                         value: hasNumbness,
//                         onChanged: (value) =>
//                             setState(() => hasNumbness = value),
//                       ),
//                       SizedBox(height: 12),
//                       Text('Headache?',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                       _buildYesNoQuestion(
//                         value: hasHeadache,
//                         onChanged: (value) {
//                           setState(() {
//                             hasHeadache = value;
//                             if (value == false) headacheSeverity = null;
//                           });
//                         },
//                       ),
//                       if (hasHeadache == true) ...[
//                         Text('How does it hurt?',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         _buildMultipleChoice(
//                           value: headacheSeverity,
//                           options: [
//                             'A little',
//                             'On and off',
//                             'Very much or the whole time'
//                           ],
//                           onChanged: (value) =>
//                               setState(() => headacheSeverity = value),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // Contractions
//                 _buildQuestionCard(
//                   title: 'Do you have contractions?',
//                   description:
//                       'Light contractions before week 37 may stop by themselves. Strong contractions may indicate labor or complications.',
//                   icon: Icons.pregnant_woman,
//                   iconColor: Colors.purple,
//                   content: Column(
//                     children: [
//                       _buildYesNoQuestion(
//                         value: hasContractions,
//                         onChanged: (value) {
//                           setState(() {
//                             hasContractions = value;
//                             if (value == false) contractionType = null;
//                           });
//                         },
//                       ),
//                       if (hasContractions == true) ...[
//                         SizedBox(height: 8),
//                         Text('What type?',
//                             style: TextStyle(fontWeight: FontWeight.bold)),
//                         _buildMultipleChoice(
//                           value: contractionType,
//                           options: [
//                             'Light and far apart',
//                             'Strong and regular',
//                             'Very painful'
//                           ],
//                           onChanged: (value) {
//                             setState(() {
//                               contractionType = value;
//                             });
//                             _checkForEmergencies();
//                           },
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 // Baby movement
//                 _buildQuestionCard(
//                   title: 'Has baby stopped moving?',
//                   description:
//                       'After 24 weeks, take a moment each day to feel if baby moves. After week 32, sudden quietness needs checking.',
//                   icon: Icons.child_care,
//                   iconColor: Colors.pink,
//                   content: _buildYesNoQuestion(
//                     value: babyStoppedMoving,
//                     onChanged: (value) {
//                       setState(() {
//                         babyStoppedMoving = value;
//                       });
//                       _checkForEmergencies();
//                     },
//                   ),
//                 ),

//                 // Other concerns
//                 _buildQuestionCard(
//                   title: 'Any other question or worry?',
//                   description:
//                       'Tell a trusted person who can help enter the message if needed.',
//                   icon: Icons.message,
//                   iconColor: Colors.blue,
//                   content: TextField(
//                     controller: _otherConcernsController,
//                     maxLines: 3,
//                     decoration: InputDecoration(
//                       hintText: 'Describe any other concerns you have...',
//                       border: OutlineInputBorder(),
//                     ),
//                     onChanged: (value) => otherConcerns = value,
//                   ),
//                 ),

//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         padding: EdgeInsets.all(16),
//         child: ElevatedButton(
//           onPressed: () async {
//             try {
//               _checkForEmergencies();
//               // Save to Firestore
//               await saveCurrentAssessment(context);

//               // Clear the form after successful submission
//               clearForm();
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: Text('Assessment Complete'),
//                     content: Text(
//                         'Thank you Mom! Your RHP will read this and contact you if necessary. If symptoms worsen, call your health provider or the nearest health facility. The form has been cleared for your next use'),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: Text('OK'),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             } catch (e) {
//               // Handle errors - don't clear form if save failed
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: Row(
//                       children: [
//                         Icon(Icons.error, color: Colors.red, size: 24),
//                         SizedBox(width: 8),
//                         Text('Error'),
//                       ],
//                     ),
//                     content: Text(
//                       'Failed to save assessment. Please check your connection and try again. '
//                       'Your answers have been preserved.',
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.of(context).pop(),
//                         child: Text('OK'),
//                       ),
//                     ],
//                   );
//                 },
//               );
//             }
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.red[800],
//             foregroundColor: Colors.white,
//             padding: EdgeInsets.symmetric(vertical: 16),
//           ),
//           child: Text(
//             'SUBMIT ASSESSMENT',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> saveEmergencyAssessmentToFirestore({
//     required BuildContext context,
//     required String userId,
//     bool? hasVaginalBleeding,
//     String? bleedingAmount,
//     bool? hasVaginalDischarge,
//     String? dischargeDuration,
//     bool? hasFluidLoss,
//     String? fluidAmount,
//     bool? hasBurningUrination,
//     bool? hasDiarrhea,
//     int? diarrheadays,
//     int? diarrheaFrequency,
//     bool? hasFever,
//     bool? hasCough,
//     String? coughTiming,
//     int? coughDays,
//     bool? hasSwollenLegs,
//     bool? hasNumbness,
//     bool? hasHeadache,
//     String? headacheSeverity,
//     bool? hasContractions,
//     String? contractionType,
//     bool? babyStoppedMoving,
//     String? otherConcerns,
//   }) async {
//     try {
//       // STEP 1: Look up connected provider
//       final query = await FirebaseFirestore.instance
//           .collection('allowed_to_chat')
//           .where('requesterId', isEqualTo: userId)
//           .limit(1)
//           .get();

//       if (query.docs.isEmpty) {
//         throw Exception(
//             'You must be connected to a health provider to submit this emergency report.');
//       }

//       final providerId = query.docs.first['recipientId'];
//       print('✅ Connected provider ID: $providerId');

//       // STEP 2: Prepare assessment data
//       final assessmentData = {
//         'userId': userId,
//         'providerId': providerId,
//         'timestamp': FieldValue.serverTimestamp(),
//         'hasVaginalBleeding': hasVaginalBleeding,
//         'bleedingAmount': bleedingAmount,
//         'hasVaginalDischarge': hasVaginalDischarge,
//         'dischargeDuration': dischargeDuration,
//         'hasFluidLoss': hasFluidLoss,
//         'fluidAmount': fluidAmount,
//         'hasBurningUrination': hasBurningUrination,
//         'hasDiarrhea': hasDiarrhea,
//         'diarrheadays': diarrheadays,
//         'diarrheaFrequency': diarrheaFrequency,
//         'hasFever': hasFever,
//         'hasCough': hasCough,
//         'coughTiming': coughTiming,
//         'coughDays': coughDays,
//         'hasSwollenLegs': hasSwollenLegs,
//         'hasNumbness': hasNumbness,
//         'hasHeadache': hasHeadache,
//         'headacheSeverity': headacheSeverity,
//         'hasContractions': hasContractions,
//         'contractionType': contractionType,
//         'babyStoppedMoving': babyStoppedMoving,
//         'otherConcerns': otherConcerns,
//         'isEmergency': _determineEmergencyStatus(
//           hasVaginalBleeding,
//           bleedingAmount,
//           hasFluidLoss,
//           fluidAmount,
//           hasContractions,
//           contractionType,
//           babyStoppedMoving,
//         ),
//         'status': 'pending_review',
//       };

//       // STEP 3: Save globally
//       final globalRef = await FirebaseFirestore.instance
//           .collection('emergency_assessments')
//           .add(assessmentData);

//       print('✅ Saved to global collection: ${globalRef.id}');

//       // STEP 4: Save under provider's emergency_cases
//       await FirebaseFirestore.instance
//           .collection('health_provider_data')
//           .doc(providerId)
//           .collection('emergency_cases')
//           .add({
//         ...assessmentData,
//         'centralDocId': globalRef.id,
//       });

//       print('✅ Also saved to provider emergency_cases');

//       // STEP 5: Send notification via helper method from ConnectionStateModel
//       final connectionStateModel =
//           Provider.of<ConnectionStateModel>(context, listen: false);

//       final currentUser = FirebaseAuth.instance.currentUser;
//       final currentUserId = currentUser?.uid;

//       if (currentUserId == null) {
//         throw Exception('User not logged in');
//       }

// // Get patient data from Firestore
//       final userDoc = await FirebaseFirestore.instance
//           .collection('New Mothers') // or 'patients'
//           .doc(currentUserId)
//           .get();

//       final patientName =
//           userDoc.data()?['full name'] ?? 'Unknown'; // adapt field name

//       await connectionStateModel.notifyProviderOfEmergency(
//         providerId: providerId,
//         requesterId: currentUserId,
//         requesterName: patientName,
//         assessmentId: globalRef.id,
//       );

//       print('📢 Notification sent successfully!');
//       print(patientName);
//     } catch (e) {
//       print('❌ Emergency save failed: $e');
//       throw Exception('Failed to save emergency report: $e');
//     }
//   }

// // Helper function to determine if this is an emergency case
//   bool _determineEmergencyStatus(
//       bool? hasVaginalBleeding,
//       String? bleedingAmount,
//       bool? hasFluidLoss,
//       String? fluidAmount,
//       bool? hasContractions,
//       String? contractionType,
//       bool? babyStoppedMoving) {
//     // Heavy bleeding
//     if (hasVaginalBleeding == true &&
//         (bleedingAmount == 'A cup full' ||
//             bleedingAmount == 'More than a cup full')) {
//       return true;
//     }

//     // Water broke (sudden puddle)
//     if (hasFluidLoss == true && fluidAmount == 'A sudden puddle') {
//       return true;
//     }

//     // Very painful contractions
//     if (hasContractions == true && contractionType == 'Very painful') {
//       return true;
//     }

//     // Baby stopped moving
//     if (babyStoppedMoving == true) {
//       return true;
//     }

//     return false;
//   }

// // Alternative method to call from your screen
//   Future<void> saveCurrentAssessment(BuildContext context) async {
//     // Call this method from your _JamboMamaEmergencyScreenState
//     // You'll need to get the current user's ID from your authentication system

//     String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

//     await saveEmergencyAssessmentToFirestore(
//       userId: currentUserId,
//       hasVaginalBleeding: hasVaginalBleeding,
//       bleedingAmount: bleedingAmount,
//       hasVaginalDischarge: hasVaginalDischarge,
//       dischargeDuration: dischargeDuration,
//       hasFluidLoss: hasFluidLoss,
//       fluidAmount: fluidAmount,
//       hasBurningUrination: hasBurningUrination,
//       hasDiarrhea: hasDiarrhea,
//       diarrheadays: diarrheadays,
//       diarrheaFrequency: diarrheaFrequency,
//       hasFever: hasFever,
//       hasCough: hasCough,
//       coughTiming: coughTiming,
//       coughDays: coughDays,
//       hasSwollenLegs: hasSwollenLegs,
//       hasNumbness: hasNumbness,
//       hasHeadache: hasHeadache,
//       headacheSeverity: headacheSeverity,
//       hasContractions: hasContractions,
//       contractionType: contractionType,
//       babyStoppedMoving: babyStoppedMoving,
//       otherConcerns: otherConcerns,
//       context: context,
//     );
//   }

//   void clearForm() {
//     setState(() {
//       // Reset all boolean variables
//       hasVaginalBleeding = null;
//       hasVaginalDischarge = null;
//       hasFluidLoss = null;
//       hasBurningUrination = null;
//       hasDiarrhea = null;
//       hasFever = null;
//       hasCough = null;
//       hasSwollenLegs = null;
//       hasNumbness = null;
//       hasHeadache = null;
//       hasContractions = null;
//       babyStoppedMoving = null;

//       // Reset all string variables
//       bleedingAmount = null;
//       dischargeDuration = null;
//       fluidAmount = null;
//       coughTiming = null;
//       headacheSeverity = null;
//       contractionType = null;
//       otherConcerns = null;

//       // Reset all integer variables
//       diarrheadays = null;
//       diarrheaFrequency = null;
//       coughDays = null;
//     });

//     // Clear all text controllers
//     _otherConcernsController.clear();
//     _diarrheaDaysController.clear();
//     _diarrheaFrequencyController.clear();
//     _coughDaysController.clear();
//   }
// }
