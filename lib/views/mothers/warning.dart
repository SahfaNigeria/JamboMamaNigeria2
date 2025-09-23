import 'package:auto_i8ln/auto_i8ln.dart';
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
            onChanged:
                _isSubmitting ? null : onChanged, // Disable during submission
            contentPadding: EdgeInsets.zero,
          ),
        ),
        Expanded(
          child: RadioListTile<bool>(
            title: AutoText('NO_MESSAGE'),
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
                title: AutoText(option),
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
      if (bleedingAmount == autoI8lnGen.translate("A_CUP_FULL") ||
          bleedingAmount == autoI8lnGen.translate("MORE_THAN_A_CUP_FULL")) {
        _showEmergencyAlert('VAGINAL_BLEEDING');
        return;
      }
    }

    if (hasFluidLoss == true &&
        fluidAmount == autoI8lnGen.translate("A_S_PU")) {
      _showEmergencyAlert('BABY_COMING');
      return;
    }

    if (hasContractions == true &&
        contractionType == autoI8lnGen.translate("V_PAINFUL")) {
      _showEmergencyAlert('CONTRACTION_DETECTED');
      return;
    }

    if (babyStoppedMoving == true) {
      _showEmergencyAlert('BABY_MOVEMENT');
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
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
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
                        'L_B',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      AutoText(
                        'IBEV',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Vaginal Bleeding
                _buildQuestionCard(
                  title: 'BLEEDING_3',
                  description:
                      "BLEEDING_DESCRIPTION_1",
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
                            autoI8lnGen.translate("A_FEW_DROPS"),
                            autoI8lnGen.translate("CUP_FULL"),
                            autoI8lnGen.translate("MORE_THAN_A_CUP_FULL"),
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
                      'B_S_U',
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
                                  labelText: autoI8lnGen.translate("HOW_LONG_2"),
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
                                  labelText: autoI8lnGen.translate("TIMES_PER_DAY"),
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
                      'F_L_C_C',
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
                      'VAGINA_DESCRIPTION_3',
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
                            autoI8lnGen.translate("AT_NIGHT"),
                            autoI8lnGen.translate("DURING_DAY"),
                            autoI8lnGen.translate("W_D_S_S")
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
                            autoI8lnGen.translate("A_LITTlE"),
                            autoI8lnGen.translate("ON_OFF"),
                            autoI8lnGen.translate("V_M_W_T"),
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
                  title: 'D_Y_H_C',
                  description:
                      'L_C_C',
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
                            autoI8lnGen.translate("L_F_A"),
                            autoI8lnGen.translate("S_A_REG"),
                            autoI8lnGen.translate("V_PAINFUL"),
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
                      hintText: autoI8lnGen.translate("ANY_OTHER_QUESTION_1"),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => otherConcerns = value,
                  ),
                ),

                // Submit button moved here - inside the scrollable area
                Container(
                  width: double.infinity,
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
                                    title: AutoText('ASSESSMENT_COMPLETE'),
                                    content: AutoText(
                                        'THANK_YOU_1'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
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
                                        Icon(Icons.error,
                                            color: Colors.red, size: 24),
                                        SizedBox(width: 8),
                                        AutoText('ERROR'),
                                      ],
                                    ),
                                    content: AutoText(
                                      'ASSESSMENT_FAILED'
                                      'Y_A_P',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: AutoText('OK'),
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
                      backgroundColor:
                          _isSubmitting ? Colors.grey : Colors.red[800],
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
                              AutoText(
                                'SUBMITTING',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        : AutoText(
                            'SUBMIT_ASSESSMENT_2',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                // Bottom padding for better scrolling
                SizedBox(height: 20),
              ],
            ),
          ),

          // Loading overlay - simplified and moved to proper position
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.3),
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
                        AutoText(
                          'S_E_A_SS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        AutoText(
                          'P_W_I',
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
        throw Exception(autoI8lnGen.translate("U_L_I"));
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
      throw Exception(autoI8lnGen.translate('F_S_E_R $e'));
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
        (bleedingAmount == autoI8lnGen.translate("A_CUP_FULL") ||
            bleedingAmount == autoI8lnGen.translate("MORE_THAN_A_CUP_FULL"))) {
      return true;
    }

    // Water broke (sudden puddle)
    if (hasFluidLoss == true &&
        fluidAmount == autoI8lnGen.translate("A_S_PU")) {
      return true;
    }

    // Very painful contractions
    if (hasContractions == true &&
        contractionType == autoI8lnGen.translate("V_PAINFUL")) {
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
