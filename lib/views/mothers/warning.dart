import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                  child: AutoText(
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
            AutoText(
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
            title: AutoText('YES_MESSAGE'),
            value: true,
            groupValue: value,
            onChanged: onChanged,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Expanded(
          child: RadioListTile<bool>(
            title: AutoText('NO_MESSAGE'),
            value: false,
            groupValue: value,
            onChanged: onChanged,
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
                title: AutoText(option),
                value: option,
                groupValue: value,
                onChanged: onChanged,
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
              AutoText('EMERGENCY', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: AutoText(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: AutoText('OK'),
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
            'VAGINAL_BLEEDING');
        return;
      }
    }

    if (hasFluidLoss == true && fluidAmount == 'A sudden puddle') {
      _showEmergencyAlert(
          'BABY_COMING');
      return;
    }

    if (hasContractions == true && contractionType == 'Very painful') {
      _showEmergencyAlert(
          'CONTRACTION_DETECTED');
      return;
    }

    if (babyStoppedMoving == true) {
      _showEmergencyAlert(
          'BABY_MOVEMENT');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: AutoText('JamboMama! EMERGENCY_ASSESSMENT'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
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
                AutoText(
                  'IMPORTANT_1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                AutoText(
                  'BLEEDING_1',
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
                  title: 'BLEEDING_3',
                  description:
                      'BLEEDING_DESCRIPTION_1',
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
                        AutoText('HOW_MUCH',
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
                  title: 'VAGINA_QUESTION_1',
                  description:
                      'VAGINA_DESCRIPTION_1',
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
                        AutoText('HOW_LONG_1',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildMultipleChoice(
                          value: dischargeDuration,
                          options: [autoI8lnGen.translate("LESS_THAN_A_WEEK"), autoI8lnGen.translate("MORE_THAN_A_WEEK")],
                          onChanged: (value) =>
                              setState(() => dischargeDuration = value),
                        ),
                      ],
                    ],
                  ),
                ),

                // Loss of fluid
                _buildQuestionCard(
                  title: 'VAGINA_QUESTION_2',
                  description:
                      'VAGINA_DESCRIPTION_2',
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
                        AutoText('HOW_MUCH',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _buildMultipleChoice(
                          value: fluidAmount,
                          options: [
                            autoI8lnGen.translate("A_FEW_DROPS"),
                            autoI8lnGen.translate("REGULAR_FLOW"),
                            autoI8lnGen.translate("SUDDEN_PUDDLE")
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
                  title: 'VAGINA_QUESTION_3',
                  description:
                      'VAGINA_DESCRIPTION_3',
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
                  title: 'VAGINA_QUESTION_4',
                  description:
                      'VAGINA_DESCRIPTION_4',
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
                                decoration: InputDecoration(
                                  labelText:  autoI8lnGen.translate("HOW_LONG_2"),
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
                                decoration: InputDecoration(
                                  labelText:  autoI8lnGen.translate("TIMES_PER_DAY"),
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
                  title: 'HEALTH_QUESTION_1',
                  description:
                      'HEALTH_DESCRIPTION_1',
                  icon: Icons.thermostat,
                  iconColor: Colors.red,
                  content: _buildYesNoQuestion(
                    value: hasFever,
                    onChanged: (value) => setState(() => hasFever = value),
                  ),
                ),

                // Cough
                _buildQuestionCard(
                  title: 'HEALTH_QUESTION_2',
                  description:
                      'HEALTH_DESCRIPTION_2',
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
                        AutoText('WHEN',
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
                          decoration: InputDecoration(
                            labelText: autoI8lnGen.translate("HOW_LONG_3"),
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
                  title: 'VAGINA_QUESTION_6',
                  description:
                      'VAGINA_DESCRIPTION_5',
                  icon: Icons.warning,
                  iconColor: Colors.red,
                  content: Column(
                    children: [
                      AutoText('HEALTH_QUESTION_3',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildYesNoQuestion(
                        value: hasSwollenLegs,
                        onChanged: (value) =>
                            setState(() => hasSwollenLegs = value),
                      ),
                      SizedBox(height: 12),
                      AutoText('HEALTH_QUESTION_4',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildYesNoQuestion(
                        value: hasNumbness,
                        onChanged: (value) =>
                            setState(() => hasNumbness = value),
                      ),
                      SizedBox(height: 12),
                      AutoText('HEALTH_QUESTION_5',
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
                        AutoText('HEALTH_QUESTION_6',
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
                        AutoText('WHAT_TYPE',
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
                  title: 'VAGINA_QUESTION_7',
                  description:
                      'VAGINA_DESCRIPTION_6',
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
                  title: 'VAGINA_QUESTION_8',
                  description:
                      'VAGINA_DESCRIPTION_7',
                  icon: Icons.message,
                  iconColor: Colors.blue,
                  content: TextField(
                    controller: _otherConcernsController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'ANY_OTHER_QUESTION_1',
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () async {
            try {
              _checkForEmergencies();
              // Save to Firestore
              await saveCurrentAssessment();

              // Clear the form after successful submission
              clearForm();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: AutoText('ASSESSMENT_COMPLETE'),
                    content: AutoText(
                        'THANK_YOU_1'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: AutoText('OK'),
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
                        AutoText('ERROR'),
                      ],
                    ),
                    content: AutoText(
                      'ASSESSMENT_FAILED',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: AutoText('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: AutoText(
            'SUBMIT_ASSESSMENT',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Future<void> saveEmergencyAssessmentToFirestore({
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
      // STEP 1: Look up connected provider
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

      // STEP 2: Prepare assessment data with ALL fields
      final assessmentData = {
        'userId': userId,
        'providerId': providerId,
        'timestamp': FieldValue.serverTimestamp(),

        // Vaginal bleeding
        'hasVaginalBleeding': hasVaginalBleeding,
        'bleedingAmount': bleedingAmount,

        // Vaginal discharge
        'hasVaginalDischarge': hasVaginalDischarge,
        'dischargeDuration': dischargeDuration,

        // Fluid loss
        'hasFluidLoss': hasFluidLoss,
        'fluidAmount': fluidAmount,

        // Urination
        'hasBurningUrination': hasBurningUrination,

        // Diarrhea
        'hasDiarrhea': hasDiarrhea,
        'diarrheadays': diarrheadays,
        'diarrheaFrequency': diarrheaFrequency,

        // Fever
        'hasFever': hasFever,

        // Cough
        'hasCough': hasCough,
        'coughTiming': coughTiming,
        'coughDays': coughDays,

        // Pre-eclampsia signs
        'hasSwollenLegs': hasSwollenLegs,
        'hasNumbness': hasNumbness,
        'hasHeadache': hasHeadache,
        'headacheSeverity': headacheSeverity,

        // Contractions
        'hasContractions': hasContractions,
        'contractionType': contractionType,

        // Baby movement
        'babyStoppedMoving': babyStoppedMoving,

        // Other concerns
        'otherConcerns': otherConcerns,

        // Emergency status
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

      // STEP 3: Save globally
      final globalRef = await FirebaseFirestore.instance
          .collection('emergency_assessments')
          .add(assessmentData);

      print('✅ Saved to global collection: ${globalRef.id}');

      // STEP 4: Save under provider's view
      await FirebaseFirestore.instance
          .collection('health_provider_data')
          .doc(providerId)
          .collection('emergency_cases')
          .add({
        ...assessmentData,
        'centralDocId': globalRef.id,
      });

      print('✅ Also saved to provider emergency_cases');
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
  Future<void> saveCurrentAssessment() async {
    // Call this method from your _JamboMamaEmergencyScreenState
    // You'll need to get the current user's ID from your authentication system

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
