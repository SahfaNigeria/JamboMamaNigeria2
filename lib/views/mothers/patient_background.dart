import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientBackgroundScreen extends StatefulWidget {
  final String patientId;

  const PatientBackgroundScreen({Key? key, required this.patientId})
      : super(key: key);

  @override
  _PatientBackgroundScreenState createState() =>
      _PatientBackgroundScreenState();
}

class _PatientBackgroundScreenState extends State<PatientBackgroundScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers for text fields
  final TextEditingController _schoolingController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _haemoglobinController = TextEditingController();
  final TextEditingController _albuminController = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _smokingDetailsController =
      TextEditingController();
  final TextEditingController _herbalMedicineController =
      TextEditingController();
  final TextEditingController _modernMedicineController =
      TextEditingController();
  final TextEditingController _artStartController = TextEditingController();
  final TextEditingController _syphilisTreatmentController =
      TextEditingController();
  final TextEditingController _tbVaccinationYearController =
      TextEditingController();
  final TextEditingController _tbTreatmentStartController =
      TextEditingController();
  final TextEditingController _tbTreatmentStopController =
      TextEditingController();
  final TextEditingController _malariaTestDateController =
      TextEditingController();
  final TextEditingController _antimalarialTreatmentController =
      TextEditingController();
  final TextEditingController _disabilityController = TextEditingController();
  final TextEditingController _lastMenstrualPeriodController =
      TextEditingController();
  final TextEditingController _miscarriagesController = TextEditingController();
  final TextEditingController _liveBirthsController = TextEditingController();
  final TextEditingController _previousPregnanciesController =
      TextEditingController();
  final TextEditingController _stillbornController = TextEditingController();
  final TextEditingController _cesareanCountController =
      TextEditingController();
  final TextEditingController _deliveryRemarksController =
      TextEditingController();

  // State variables
  String? _urinalysisResult;
  bool _smokesTobacco = false;
  String? _smokingFrequency;
  bool _drinksAlcohol = false;
  String? _alcoholType;
  String? _alcoholFrequency;
  bool _usesHerbalMedicine = false;
  String? _herbalFrequency;
  bool _usesModernMedicine = false;
  String? _modernMedicineType;
  String? _hivTestSelf;
  String? _hivTestPartner;
  bool _onART = false;
  String? _partnerARTStatus;
  String? _syphilisTest;
  String? _tbTest;
  String? _tbVaccination;
  bool _onTBTreatment = false;
  bool _currentlyOnTBTreatment = false;
  int _tetanusVaccinations = 0;
  String? _tetanusRecent;
  String? _malariaTest;
  bool _onAntimalarials = false;
  String? _antimalarialRecent;
  String? _wormTest;
  String? _wormMedicineRecent;
  bool _hasOtherIssues = false;
  bool _isFirstPregnancy = true;
  String? _lastPregnancyTiming;
  bool _hadCesarean = false;
  String? _hadForcepsVacuum;
  String? _hadHeavyBleeding;
  String? _hadTears;
  String? _tearsNeedStitching;
  String? _tearsHealedNaturally;
  String? _tearsStillBothering;

  double? _bmi;
  String _bmiMessage = '';
  String _bpMessage = '';
  String _haemoglobinMessage = '';
  String _albuminMessage = '';
  String _glucoseMessage = '';
  DateTime? _expectedDeliveryDate;
  List<String> _alerts = [];

  // UI State
  bool _isEditMode = false;
  Set<String> _expandedSections = {};

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('patients')
          .doc(widget.patientId)
          .collection('background')
          .doc('patient_background')
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        setState(() {
          // Populate controllers and state variables with existing data
          _schoolingController.text = data['schooling']?.toString() ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _heightController.text = data['height']?.toString() ?? '';
          _weightController.text = data['weight']?.toString() ?? '';
          _systolicController.text = data['systolic_bp']?.toString() ?? '';
          _diastolicController.text = data['diastolic_bp']?.toString() ?? '';
          _haemoglobinController.text = data['haemoglobin']?.toString() ?? '';
          _albuminController.text = data['albumin']?.toString() ?? '';
          _glucoseController.text = data['glucose']?.toString() ?? '';
          _urinalysisResult = data['urinalysis'];
          _smokesTobacco = data['smokes_tobacco'] ?? false;
          _smokingFrequency = data['smoking_frequency'];
          _drinksAlcohol = data['drinks_alcohol'] ?? false;
          _alcoholType = data['alcohol_type'];
          _alcoholFrequency = data['alcohol_frequency'];
          _usesHerbalMedicine = data['uses_herbal_medicine'] ?? false;
          _herbalFrequency = data['herbal_frequency'];
          _usesModernMedicine = data['uses_modern_medicine'] ?? false;
          _modernMedicineType = data['modern_medicine_type'];
          _hivTestSelf = data['hiv_test_self'];
          _hivTestPartner = data['hiv_test_partner'];
          _onART = data['on_art'] ?? false;
          _partnerARTStatus = data['partner_art_status'];
          _syphilisTest = data['syphilis_test'];
          _tbTest = data['tb_test'];
          _tbVaccination = data['tb_vaccination'];
          _onTBTreatment = data['on_tb_treatment'] ?? false;
          _currentlyOnTBTreatment = data['currently_on_tb_treatment'] ?? false;
          _tetanusVaccinations = data['tetanus_vaccinations'] ?? 0;
          _tetanusRecent = data['tetanus_recent'];
          _malariaTest = data['malaria_test'];
          _onAntimalarials = data['on_antimalarials'] ?? false;
          _antimalarialRecent = data['antimalarial_recent'];
          _wormTest = data['worm_test'];
          _wormMedicineRecent = data['worm_medicine_recent'];
          _hasOtherIssues = data['has_other_issues'] ?? false;
          _isFirstPregnancy = data['is_first_pregnancy'] ?? true;
          _lastPregnancyTiming = data['last_pregnancy_timing'];
          _hadCesarean = data['had_cesarean'] ?? false;
          _hadForcepsVacuum = data['had_forceps_vacuum'];
          _hadHeavyBleeding = data['had_heavy_bleeding'];
          _hadTears = data['had_tears'];
          _tearsNeedStitching = data['tears_need_stitching'];
          _tearsHealedNaturally = data['tears_healed_naturally'];
          _tearsStillBothering = data['tears_still_bothering'];

          // Calculate derived values
          _calculateBMI();
          _checkBloodPressure();
          _checkHaemoglobin();
          _checkAlbumin();
          _checkGlucose();
          _calculateExpectedDeliveryDate();
        });
      }
    } catch (e) {
      print('Error loading existing data: $e');
    }
  }

  // All calculation methods remain the same
  void _calculateBMI() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      final heightInMeters = height / 100;
      _bmi = weight / (heightInMeters * heightInMeters);

      setState(() {
        if (_bmi! < 18.5) {
          _bmiMessage = autoI8lnGen.translate("TOO_LOW");
        } else if (_bmi! >= 18.5 && _bmi! <= 24.9) {
          _bmiMessage = autoI8lnGen.translate("THUMB_UP");
        } else if (_bmi! >= 25 && _bmi! <= 29) {
          _bmiMessage = autoI8lnGen.translate("TOO_HIGH");
        } else {
          _bmiMessage = autoI8lnGen.translate("OBESE_DANGER");
          _addAlert(autoI8lnGen.translate("THIS_LEVEL_OBESE"));
        }
      });
    }
  }

  void _checkBloodPressure() {
    final systolic = int.tryParse(_systolicController.text);
    final diastolic = int.tryParse(_diastolicController.text);

    if (systolic != null && diastolic != null) {
      setState(() {
        if (systolic >= 90 &&
            systolic <= 120 &&
            diastolic >= 60 &&
            diastolic <= 80) {
          _bpMessage = autoI8lnGen.translate("THUMB_UP");
        } else if (systolic >= 121 &&
            systolic <= 129 &&
            diastolic >= 81 &&
            diastolic <= 89) {
          _bpMessage = autoI8lnGen.translate("E_C_D");
        } else if (systolic >= 130 && systolic <= 139 && diastolic >= 90) {
          _bpMessage =
              autoI8lnGen.translate("HEALTH_ISSUE_1");
        } else if (systolic >= 140 && diastolic >= 90) {
          _bpMessage =
              autoI8lnGen.translate("HEALTH_ISSUE_2");
        } else if (systolic >= 160 && diastolic >= 100) {
          _bpMessage =
              autoI8lnGen.translate("HEALTH_ISSUE_3");
          _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_4"));
        }
      });
    }
  }

  void _checkHaemoglobin() {
    final haemoglobin = double.tryParse(_haemoglobinController.text);
    if (haemoglobin != null) {
      setState(() {
        if (haemoglobin < 9.5) {
          _haemoglobinMessage = autoI8lnGen.translate("HEALTH_ISSUE_5");
        } else if (haemoglobin > 15) {
          _haemoglobinMessage = autoI8lnGen.translate("HEALTH_ISSUE_6");
        } else {
          _haemoglobinMessage = autoI8lnGen.translate("HEALTH_ISSUE_7");
        }
      });
    }
  }

  void _checkAlbumin() {
    final albumin = double.tryParse(_albuminController.text);
    if (albumin != null) {
      setState(() {
        if (albumin <= 150) {
          _albuminMessage = autoI8lnGen.translate("HEALTH_ISSUE_7");
        } else if (albumin > 150 && albumin <= 300) {
          _albuminMessage = autoI8lnGen.translate("HEALTH_ISSUE_8");
        } else {
          _albuminMessage = autoI8lnGen.translate("HEALTH_ISSUE_9");
          _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_10"));
        }
      });
    }
  }

  void _checkGlucose() {
    final glucose = double.tryParse(_glucoseController.text);
    if (glucose != null) {
      setState(() {
        if (glucose < 7.8) {
          _glucoseMessage = autoI8lnGen.translate("NORMAL");
        } else if (glucose >= 7.8 && glucose < 11.0) {
          _glucoseMessage = autoI8lnGen.translate("HEALTH_ISSUE_11");
        } else {
          _glucoseMessage =
              autoI8lnGen.translate("HEALTH_ISSUE_12");
          _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_13"));
        }
      });
    }
  }

  void _calculateExpectedDeliveryDate() {
    if (_lastMenstrualPeriodController.text.isNotEmpty) {
      try {
        List<String> dateParts = _lastMenstrualPeriodController.text.split('/');
        if (dateParts.length == 3) {
          int day = int.parse(dateParts[0]);
          int month = int.parse(dateParts[1]);
          int year = int.parse(dateParts[2]);
          DateTime lmp = DateTime(year, month, day);
          setState(() {
            _expectedDeliveryDate = lmp.add(Duration(days: 280));
          });
        }
      } catch (e) {
        print('Error calculating EDD: $e');
      }
    }
  }

  void _addAlert(String alert) {
    if (!_alerts.contains(alert)) {
      _alerts.add(alert);
    }
  }

  void _checkHighRiskFactors() {
    _alerts.clear();
    final age = int.tryParse(_ageController.text);
    if (age != null) {
      if (age < 20 || age > 39) {
        _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_14"));
      }
      if (_isFirstPregnancy && (age < 20 || age > 35)) {
        _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_15"));
      }
    }

    final miscarriages = int.tryParse(_miscarriagesController.text);
    if (miscarriages != null && miscarriages > 0) {
      _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_16"));
    }

    if (_lastPregnancyTiming == '>9 years') {
      _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_17"));
    }

    if (_hadCesarean) {
      _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_18"));
    }

    if (_hadHeavyBleeding == 'Yes') {
      _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_19"));
    }

    if (_onART) {
      _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_20"));
    }

    if (_currentlyOnTBTreatment) {
      _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_21"));
    }

    if (_hasOtherIssues) {
      _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_22"));
    }
  }

  int _getCompletionPercentage() {
    int totalFields = 20; // Approximate number of key fields
    int filledFields = 0;

    if (_ageController.text.isNotEmpty) filledFields++;
    if (_heightController.text.isNotEmpty) filledFields++;
    if (_weightController.text.isNotEmpty) filledFields++;
    if (_systolicController.text.isNotEmpty) filledFields++;
    if (_diastolicController.text.isNotEmpty) filledFields++;
    if (_haemoglobinController.text.isNotEmpty) filledFields++;
    if (_albuminController.text.isNotEmpty) filledFields++;
    if (_glucoseController.text.isNotEmpty) filledFields++;
    if (_urinalysisResult != null) filledFields++;
    if (_hivTestSelf != null) filledFields++;
    if (_syphilisTest != null) filledFields++;
    if (_tbTest != null) filledFields++;
    if (_malariaTest != null) filledFields++;
    if (_wormTest != null) filledFields++;
    if (_lastMenstrualPeriodController.text.isNotEmpty) filledFields++;
    if (_miscarriagesController.text.isNotEmpty) filledFields++;
    if (!_isFirstPregnancy && _liveBirthsController.text.isNotEmpty)
      filledFields++;
    if (!_isFirstPregnancy && _previousPregnanciesController.text.isNotEmpty)
      filledFields++;
    if (!_isFirstPregnancy && _lastPregnancyTiming != null) filledFields++;
    if (_tetanusVaccinations > 0) filledFields++;

    return ((filledFields / totalFields) * 100).round();
  }

  List<String> _getMissingFields() {
    List<String> missing = [];

    if (_ageController.text.isEmpty) missing.add(autoI8lnGen.translate("AGE"));
    if (_heightController.text.isEmpty) missing.add(autoI8lnGen.translate("H"));
    if (_weightController.text.isEmpty) missing.add(autoI8lnGen.translate("W"));
    if (_systolicController.text.isEmpty) missing.add(autoI8lnGen.translate("BLOOD_PRESSURE"));
    if (_haemoglobinController.text.isEmpty) missing.add(autoI8lnGen.translate("HEAMOGOBLIN_T"));
    if (_urinalysisResult == null) missing.add(autoI8lnGen.translate("URINEANALYSIS"));
    if (_hivTestSelf == null) missing.add(autoI8lnGen.translate("HI_T_S"));
    if (_syphilisTest == null) missing.add(autoI8lnGen.translate("S_T_E"));
    if (_tbTest == null) missing.add(autoI8lnGen.translate("TB_TEST"));
    if (_malariaTest == null) missing.add(autoI8lnGen.translate("M_T_E"));
    if (_lastMenstrualPeriodController.text.isEmpty)
      missing.add(autoI8lnGen.translate("L_M_P"));
    if (_tetanusVaccinations == 0) missing.add(autoI8lnGen.translate("T_V_A"));

    return missing;
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      _checkHighRiskFactors();

      String? providerId;
      try {
        final connectionQuery = await _firestore
            .collection('allowed_to_chat')
            .where('requesterId', isEqualTo: widget.patientId)
            .limit(1)
            .get();

        if (connectionQuery.docs.isEmpty) {
          throw Exception(
              'This patient is not connected to a health provider.');
        }

        providerId = connectionQuery.docs.first['recipientId'];
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoText('CONNECTION_REQUIRED $e')),
        );
        return;
      }

      Map<String, dynamic> data = {
        'schooling': int.tryParse(_schoolingController.text),
        'age': int.tryParse(_ageController.text),
        'height': double.tryParse(_heightController.text),
        'weight': double.tryParse(_weightController.text),
        'bmi': _bmi,
        'bmi_message': _bmiMessage,
        'systolic_bp': int.tryParse(_systolicController.text),
        'diastolic_bp': int.tryParse(_diastolicController.text),
        'bp_message': _bpMessage,
        'haemoglobin': double.tryParse(_haemoglobinController.text),
        'haemoglobin_message': _haemoglobinMessage,
        'albumin': double.tryParse(_albuminController.text),
        'albumin_message': _albuminMessage,
        'glucose': double.tryParse(_glucoseController.text),
        'glucose_message': _glucoseMessage,
        'urinalysis': _urinalysisResult,
        'smokes_tobacco': _smokesTobacco,
        'smoking_details': _smokingDetailsController.text,
        'smoking_frequency': _smokingFrequency,
        'drinks_alcohol': _drinksAlcohol,
        'alcohol_type': _alcoholType,
        'alcohol_frequency': _alcoholFrequency,
        'uses_herbal_medicine': _usesHerbalMedicine,
        'herbal_medicine_details': _herbalMedicineController.text,
        'herbal_frequency': _herbalFrequency,
        'uses_modern_medicine': _usesModernMedicine,
        'modern_medicine_type': _modernMedicineType,
        'hiv_test_self': _hivTestSelf,
        'hiv_test_partner': _hivTestPartner,
        'on_art': _onART,
        'art_start_date': _artStartController.text,
        'partner_art_status': _partnerARTStatus,
        'syphilis_test': _syphilisTest,
        'syphilis_treatment': _syphilisTreatmentController.text,
        'tb_test': _tbTest,
        'tb_vaccination': _tbVaccination,
        'tb_vaccination_year': _tbVaccinationYearController.text,
        'on_tb_treatment': _onTBTreatment,
        'tb_treatment_start': _tbTreatmentStartController.text,
        'tb_treatment_stop': _tbTreatmentStopController.text,
        'currently_on_tb_treatment': _currentlyOnTBTreatment,
        'tetanus_vaccinations': _tetanusVaccinations,
        'tetanus_recent': _tetanusRecent,
        'malaria_test': _malariaTest,
        'malaria_test_date': _malariaTestDateController.text,
        'on_antimalarials': _onAntimalarials,
        'antimalarial_treatment': _antimalarialTreatmentController.text,
        'antimalarial_recent': _antimalarialRecent,
        'worm_test': _wormTest,
        'worm_medicine_recent': _wormMedicineRecent,
        'has_other_issues': _hasOtherIssues,
        'disability_details': _disabilityController.text,
        'last_menstrual_period': _lastMenstrualPeriodController.text,
        'expected_delivery_date': _expectedDeliveryDate?.toIso8601String(),
        'is_first_pregnancy': _isFirstPregnancy,
        'miscarriages': int.tryParse(_miscarriagesController.text),
        'live_births': int.tryParse(_liveBirthsController.text),
        'previous_pregnancies':
            int.tryParse(_previousPregnanciesController.text),
        'last_pregnancy_timing': _lastPregnancyTiming,
        'stillborn': int.tryParse(_stillbornController.text),
        'had_cesarean': _hadCesarean,
        'cesarean_count': int.tryParse(_cesareanCountController.text),
        'had_forceps_vacuum': _hadForcepsVacuum,
        'had_heavy_bleeding': _hadHeavyBleeding,
        'had_tears': _hadTears,
        'tears_need_stitching': _tearsNeedStitching,
        'tears_healed_naturally': _tearsHealedNaturally,
        'tears_still_bothering': _tearsStillBothering,
        'delivery_remarks': _deliveryRemarksController.text,
        'alerts': _alerts,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'providerId': providerId,
        'patientId': widget.patientId,
      };

      try {
        await _firestore
            .collection('patients')
            .doc(widget.patientId)
            .collection('background')
            .doc('patient_background')
            .set(data, SetOptions(merge: true));

        await _firestore
            .collection('health_provider_data')
            .doc(providerId)
            .collection('patient_backgrounds')
            .doc(widget.patientId)
            .set(data, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient background saved successfully')),
        );

        setState(() {
          _isEditMode = false;
        });

        if (_alerts.isNotEmpty) {
          _showAlertsDialog();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoText('ERROR_S_D $e')),
        );
      }
    }
  }

  void _showAlertsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: AutoText('H_P_A'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoText('T_F_AG'),
              SizedBox(height: 10),
              ..._alerts.map((alert) => Text('• $alert')).toList(),
            ],
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

  Widget _buildOverviewCard() {
    final completionPercentage = _getCompletionPercentage();
    final missingFields = _getMissingFields();

    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoText(
                  'B_S_UM',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => setState(() => _isEditMode = !_isEditMode),
                  icon: Icon(_isEditMode ? Icons.visibility : Icons.edit),
                  tooltip: _isEditMode ? autoI8lnGen.translate("V_MODE") : autoI8lnGen.translate("E_MODE"),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Progress indicator
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: completionPercentage / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(completionPercentage >= 80
                            ? Colors.green
                            : completionPercentage >= 50
                                ? Colors.orange
                                : Colors.red),
                  ),
                ),
                SizedBox(width: 12),
                AutoText(
                  '$completionPercentage% COMPLETE',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            if (missingFields.isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[600]),
                        SizedBox(width: 8),
                        AutoText(
                          'STN (${missingFields.length} ITEMS):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: missingFields
                          .map((field) => Chip(
                                label:
                                    Text(field, style: TextStyle(fontSize: 12)),
                                backgroundColor: Colors.orange[100],
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],

            if (_alerts.isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[600]),
                        SizedBox(width: 8),
                        AutoText(
                          'H_AL (${_alerts.length}):',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700]),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ..._alerts
                        .map((alert) => Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text('• $alert',
                                  style: TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String sectionKey,
    required List<Widget> children,
    required int filledCount,
    required int totalCount,
  }) {
    final isExpanded = _expandedSections.contains(sectionKey);
    final isEmpty = filledCount == 0;
    final isComplete = filledCount == totalCount;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: AutoText(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isComplete
                        ? Colors.green[100]
                        : isEmpty
                            ? Colors.red[100]
                            : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AutoText(
                    '$filledCount/$totalCount',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isComplete
                          ? Colors.green[700]
                          : isEmpty
                              ? Colors.red[700]
                              : Colors.orange[700],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  isComplete
                      ? Icons.check_circle
                      : isEmpty
                          ? Icons.error
                          : Icons.warning,
                  color: isComplete
                      ? Colors.green[700]
                      : isEmpty
                          ? Colors.red[700]
                          : Colors.orange[700],
                ),
              ],
            ),
            trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedSections.remove(sectionKey);
                } else {
                  _expandedSections.add(sectionKey);
                }
              });
            },
          ),
          if (isExpanded) ...[
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(children: children),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    Widget? trailing,
    Color? statusColor,
    VoidCallback? onTap,
  }) {
    final isEmpty = value.isEmpty || value == autoI8lnGen.translate("NOT_SPECIFIED");

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isEmpty ? Colors.red[200]! : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isEmpty ? Colors.red[50] : Colors.grey[50],
      ),
      child: ListTile(
        dense: true,
        title: AutoText(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: AutoText(
          isEmpty ? 'T_A_P_ADD' : value,
          style: TextStyle(
            fontSize: 13,
            color: isEmpty ? Colors.red[600] : Colors.black87,
            fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
          ),
        ),
        trailing: trailing ??
            (isEmpty ? Icon(Icons.add, color: Colors.red[600]) : null),
        onTap: onTap ??
            (_isEditMode
                ? () {
                    // Auto-expand section and focus on relevant field
                    setState(() {
                      _expandedSections.add(_getSectionForField(label));
                    });
                  }
                : null),
      ),
    );
  }
///TODO: FIX THIS FUNCTION
  String _getSectionForField(String label) {
    if ([
      autoI8lnGen.translate("AGE"),
      autoI8lnGen.translate("H"),
      autoI8lnGen.translate("W"),
      autoI8lnGen.translate("BLOOD_PRESSURE"),
      autoI8lnGen.translate("HEAMOGOBLIN_T"),
      autoI8lnGen.translate("ALBUMIN"),
      autoI8lnGen.translate("GLUCOSE"),
      autoI8lnGen.translate("URINEANALYSIS"),
    ].contains(label)) {
      return autoI8lnGen.translate("GENERAL_2");
    } else if ([autoI8lnGen.translate("T_USE"), autoI8lnGen.translate("ALCOHOL_USE")].contains(label)) {
      return autoI8lnGen.translate("L_F_STYLE");
    } else if ([autoI8lnGen.translate("HIV_TEST"), autoI8lnGen.translate("TB_TEST"), autoI8lnGen.translate("M_T_E"), autoI8lnGen.translate("S_T_E")]
        .contains(label)) {
      return autoI8lnGen.translate("MDCL");
    } else {
      return autoI8lnGen.translate("P_2");
    }
  }

  String _getDisplayValue(dynamic value, String defaultText) {
    if (value == null || value.toString().isEmpty) {
      return defaultText;
    }
    return value.toString();
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: autoI8lnGen.translate(label),
          hintText: autoI8lnGen.translate(hint??""),
          border: OutlineInputBorder(),
          enabled: _isEditMode,
        ),
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        readOnly: !_isEditMode,
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: autoI8lnGen.translate(label),
          border: OutlineInputBorder(),
        ),
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: _isEditMode ? onChanged : null,
      ),
    );
  }

  Widget _buildButtonGroup({
    required String title,
    required String? value,
    required List<String> options,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoText(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 12),
        Row(
          children: options.map((option) {
            final isSelected = value == option;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: _isEditMode ? () => onChanged(option) : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[600] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getIconForOption(option),
                          color: isSelected ? Colors.white : Colors.grey[600],
                          size: 28,
                        ),
                        SizedBox(height: 8),
                        AutoText(
                          option,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  IconData _getIconForOption(String option) {
    String lowerOption = option.toLowerCase();
    String yesMessage = autoI8lnGen.translate("YES_MESSAGE").toLowerCase();

    if (lowerOption == yesMessage) {
      return Icons.check_circle;
    } else if (lowerOption ==  autoI8lnGen.translate("NO_MESSAGE")) {
      return Icons.cancel;
    } else if (lowerOption == autoI8lnGen.translate("DONT_KNOW_2") || lowerOption == autoI8lnGen.translate("DONT_REMMEBR")) {
      return Icons.help;
    } else if (lowerOption ==  autoI8lnGen.translate("DAILY")) {
      return Icons.today;
    } else if (lowerOption ==  autoI8lnGen.translate("WEEKLY")) {
      return Icons.calendar_view_week;
    } else if (lowerOption == autoI8lnGen.translate("LESS_OFTEN")) {
      return Icons.calendar_month;
    } else if (lowerOption == autoI8lnGen.translate("BEER")) {
      return Icons.local_bar;
    } else if (lowerOption == autoI8lnGen.translate("LIQUOR")) {
      return Icons.wine_bar;
    } else if (lowerOption == autoI8lnGen.translate("BOTH")) {
      return Icons.restaurant;
    } else {
      return Icons.circle;
    }
  }


  Widget _buildYesNoButton({
    required String title,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoText(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _isEditMode ? () => onChanged(true) : null,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: value ? Colors.green[600] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: value ? Colors.green[600]! : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: value ? Colors.white : Colors.grey[600],
                        size: 28,
                      ),
                      SizedBox(height: 8),
                      AutoText(
                        'YES_MESSAGE',
                        style: TextStyle(
                          color: value ? Colors.white : Colors.black87,
                          fontWeight:
                              value ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _isEditMode ? () => onChanged(false) : null,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: !value ? Colors.red[600] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: !value ? Colors.red[600]! : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cancel,
                        color: !value ? Colors.white : Colors.grey[600],
                        size: 28,
                      ),
                      SizedBox(height: 8),
                      AutoText(
                        'NO_MESSAGE',
                        style: TextStyle(
                          color: !value ? Colors.white : Colors.black87,
                          fontWeight:
                              !value ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHealthIndicator(
      String title, String value, String message, IconData icon, Color color) {
    if (value.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoText(
                  '$title: $value',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (message.isNotEmpty)
                  AutoText(
                    message,
                    style: TextStyle(fontSize: 12, color: color),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoText('P_T_B'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
            icon: Icon(_isEditMode ? Icons.visibility : Icons.edit),
            tooltip: _isEditMode ? autoI8lnGen.translate("V_MODE") : autoI8lnGen.translate("E_MODE"),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Overview Card
              _buildOverviewCard(),

              // Health Indicators Summary (always visible)
              if (_bmi != null ||
                  _bpMessage.isNotEmpty ||
                  _haemoglobinMessage.isNotEmpty)
                Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoText(
                          'HID',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        if (_bmi != null)
                          _buildHealthIndicator(
                            'BMI_2',
                            _bmi!.toStringAsFixed(1),
                            _bmiMessage,
                            Icons.monitor_weight,
                            _bmiMessage == autoI8lnGen.translate("THUMB_UP")
                                ? Colors.green
                                : Colors.orange,
                          ),
                        if (_bpMessage.isNotEmpty)
                          _buildHealthIndicator(
                            'B_P',
                            '${_systolicController.text}/${_diastolicController.text}',
                            _bpMessage,
                            Icons.favorite,
                            _bpMessage == autoI8lnGen.translate("THUMB_UP")
                                ? Colors.green
                                : Colors.red,
                          ),
                        if (_haemoglobinMessage.isNotEmpty)
                          _buildHealthIndicator(
                            'HAEMOGLO',
                            '${_haemoglobinController.text} g/dl',
                            _haemoglobinMessage,
                            Icons.water_drop,
                            _haemoglobinMessage == autoI8lnGen.translate("THUMB_UP")
                                ? Colors.green
                                : Colors.orange,
                          ),
                        if (_expectedDeliveryDate != null)
                          _buildHealthIndicator(
                            'E_D_E',
                            '${_expectedDeliveryDate!.day}/${_expectedDeliveryDate!.month}/${_expectedDeliveryDate!.year}',
                            '',
                            Icons.baby_changing_station,
                            Colors.pink,
                          ),
                      ],
                    ),
                  ),
                ),

              // Expandable Sections
              _buildExpandableSection(
                title: 'GIN',
                sectionKey: 'GENERAL_3',
                filledCount: [
                  _ageController.text,
                  _heightController.text,
                  _weightController.text,
                  _systolicController.text,
                  _haemoglobinController.text,
                  _urinalysisResult
                ].where((x) => x != null && x.toString().isNotEmpty).length,
                totalCount: 6,
                children: _isEditMode
                    ? [
                        _buildTextFormField(
                          controller: _schoolingController,
                          label: 'SCHO_YEARS',
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextFormField(
                          controller: _ageController,
                          label: 'G_Q_3',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateBMI(),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              int? age = int.tryParse(value);
                              if (age != null && (age < 11 || age > 60)) {
                                return autoI8lnGen.translate("A_11_60");
                              }
                            }
                            return null;
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                controller: _heightController,
                                label: 'G_Q_5',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _calculateBMI(),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _weightController,
                                label: 'WEIGHT_KG',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _calculateBMI(),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                controller: _systolicController,
                                label: 'G_Q_8',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _checkBloodPressure(),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _diastolicController,
                                label: 'G_Q_9',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _checkBloodPressure(),
                              ),
                            ),
                          ],
                        ),
                        _buildTextFormField(
                          controller: _haemoglobinController,
                          label: 'HEAMOGOBLIN',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _checkHaemoglobin(),
                        ),
                        _buildTextFormField(
                          controller: _albuminController,
                          label: 'ALBUMIN_URINE',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _checkAlbumin(),
                        ),
                        _buildTextFormField(
                          controller: _glucoseController,
                          label: 'GLUCOSE_URINE',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _checkGlucose(),
                        ),
                        _buildDropdownFormField(
                          label: 'URINEANALYSIS',
                          value: _urinalysisResult,
                          items: [ autoI8lnGen.translate("NORMAL"),
                            autoI8lnGen.translate("SO_SO"),
                            autoI8lnGen.translate("DANGER")],
                          onChanged: (value) =>
                              setState(() => _urinalysisResult = value),
                        ),
                      ]
                    : [
                        _buildSummaryItem(
                          label: 'AGE',
                          value: _getDisplayValue(
                              _ageController.text, autoI8lnGen.translate("NOT_SPECIFIED")),
                        ),
                        _buildSummaryItem(
                          label: 'H & W',
                          value: _heightController.text.isNotEmpty &&
                                  _weightController.text.isNotEmpty
                              ? '${_heightController.text} cm, ${_weightController.text} kg'
                              : autoI8lnGen.translate("NOT_SPECIFIED"),
                          trailing: _bmi != null
                              ? AutoText(
                                  'BMI ${_bmi!.toStringAsFixed(1)}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        _buildSummaryItem(
                          label: 'B_P',
                          value: _systolicController.text.isNotEmpty &&
                                  _diastolicController.text.isNotEmpty
                              ? '${_systolicController.text}/${_diastolicController.text}'
                              : autoI8lnGen.translate("NOT_SPECIFIED"),
                        ),
                        _buildSummaryItem(
                          label: 'HAEMOGLO',
                          value: _getDisplayValue(
                              _haemoglobinController.text, autoI8lnGen.translate("NOT_SPECIFIED")),
                        ),
                        _buildSummaryItem(
                          label: 'URINEANALYSIS',
                          value: _getDisplayValue(
                              _urinalysisResult, autoI8lnGen.translate("NOT_SPECIFIED")),
                        ),
                      ],
              ),

              _buildExpandableSection(
                title: 'LIFESTYLE',
                sectionKey: 'LIFESTYLE'.toLowerCase(),
                filledCount: [
                  _smokesTobacco ? autoI8lnGen.translate("YES_MESSAGE"): '',
                  _drinksAlcohol ? autoI8lnGen.translate("YES_MESSAGE") : '',
                ].where((x) => x.isNotEmpty).length,
                totalCount: 2,
                children: _isEditMode
                    ? [
                        _buildYesNoButton(
                          title: 'G_Q_11',
                          value: _smokesTobacco,
                          onChanged: (value) =>
                              setState(() => _smokesTobacco = value),
                        ),
                        if (_smokesTobacco) ...[
                          _buildTextFormField(
                            controller: _smokingDetailsController,
                            label: 'G_Q_12',
                          ),
                          _buildButtonGroup(
                            title: 'G_Q_13',
                            value: _smokingFrequency,
                            options: [autoI8lnGen.translate("DAILY_2"), autoI8lnGen.translate("WEEKLY_2"),  autoI8lnGen.translate("L_O"),],
                            onChanged: (value) =>
                                setState(() => _smokingFrequency = value!),
                          ),
                        ],
                        _buildYesNoButton(
                          title: 'D_Y_A',
                          value: _drinksAlcohol,
                          onChanged: (value) =>
                              setState(() => _drinksAlcohol = value),
                        ),
                        if (_drinksAlcohol) ...[
                          _buildButtonGroup(
                            title: 'Type of alcohol',
                            value: _alcoholType,
                            options: ['Beer', 'Liquor', 'Both'],
                            onChanged: (value) =>
                                setState(() => _alcoholType = value!),
                          ),
                          _buildButtonGroup(
                            title: 'How often?',
                            value: _alcoholFrequency,
                            options: [autoI8lnGen.translate("DAILY_2"), autoI8lnGen.translate("WEEKLY_2"),  autoI8lnGen.translate("L_O"),],
                            onChanged: (value) =>
                                setState(() => _alcoholFrequency = value!),
                          ),
                        ],
                      ]
                    : [
                        _buildSummaryItem(
                          label: 'T_USE',
                          value: _smokesTobacco
                              ? autoI8lnGen.translate('YES_MESSAGE${_smokingFrequency != null ? " - $_smokingFrequency" : ""}')
                              : 'NO_MESSAGE',
                        ),
                        _buildSummaryItem(
                          label: 'AL_USE',
                          value: _drinksAlcohol
                              ? 'YES_MESSAGE${_alcoholType != null ? " - $_alcoholType" : ""}${_alcoholFrequency != null ? " ($_alcoholFrequency)" : ""}'
                              : 'NO_MESSAGE',
                        ),
                      ],
              ),

              _buildExpandableSection(
                title: 'M_H',
                sectionKey: 'MDCL',
                filledCount: [
                  _hivTestSelf,
                  _syphilisTest,
                  _tbTest,
                  _malariaTest,
                  _wormTest,
                  _tetanusVaccinations > 0 ? autoI8lnGen.translate("YES_MESSAGE") : null,
                ].where((x) => x != null && x.toString().isNotEmpty).length,
                totalCount: 6,
                children: _isEditMode
                    ? [
                        _buildYesNoButton(
                          title: 'D_Y_HM',
                          value: _usesHerbalMedicine,
                          onChanged: (value) =>
                              setState(() => _usesHerbalMedicine = value),
                        ),
                        if (_usesHerbalMedicine) ...[
                          _buildTextFormField(
                            controller: _herbalMedicineController,
                            label: 'WHB',
                          ),
                          _buildButtonGroup(
                            title: 'G_Q_13',
                            value: _herbalFrequency,
                                                       options: [autoI8lnGen.translate("DAILY_2"), autoI8lnGen.translate("WEEKLY_2"),  autoI8lnGen.translate("L_O"),],
                            onChanged: (value) =>
                                setState(() => _herbalFrequency = value!),
                          ),
                        ],
                        _buildButtonGroup(
                          title: 'H_TV',
                          value: _hivTestSelf,
                          options: [autoI8lnGen.translate("YES_MESSAGE",), autoI8lnGen.translate("NO_MESSAGE",), autoI8lnGen.translate("D_ONT_KNOW",),],
                          onChanged: (value) =>
                              setState(() => _hivTestSelf = value!),
                        ),
                        _buildYesNoButton(
                          title: 'ARE_YOU_THERAPY',
                          value: _onART,
                          onChanged: (value) => setState(() => _onART = value),
                        ),
                        if (_onART) ...[
                          _buildTextFormField(
                            controller: _artStartController,
                            label: 'SINCE_WHEN',
                            hint: 'MM/YYYY',
                          ),
                        ],
                        _buildButtonGroup(
                          title:
                              'G_Q_14',
                          value: _syphilisTest,
                           options: [autoI8lnGen.translate("YES_MESSAGE",), autoI8lnGen.translate("NO_MESSAGE",), autoI8lnGen.translate("D_ONT_KNOW",),],
                          onChanged: (value) =>
                              setState(() => _syphilisTest = value!),
                        ),
                        _buildButtonGroup(
                          title: 'G_Q_16',
                          value: _tbTest,
                          options: [autoI8lnGen.translate("YES_MESSAGE",), autoI8lnGen.translate("NO_MESSAGE",), autoI8lnGen.translate("D_ONT_KNOW",),],
                          onChanged: (value) =>
                              setState(() => _tbTest = value!),
                        ),
                        _buildButtonGroup(
                          title: 'TESTED_MALARIA',
                          value: _malariaTest,
                           options: [autoI8lnGen.translate("YES_MESSAGE",), autoI8lnGen.translate("NO_MESSAGE",), autoI8lnGen.translate("D_ONT_KNOW",),],
                          onChanged: (value) =>
                              setState(() => _malariaTest = value!),
                        ),
                        _buildButtonGroup(
                          title: 'G_Q_32',
                          value: _wormTest,
                          options: [autoI8lnGen.translate("YES_MESSAGE",), autoI8lnGen.translate("NO_MESSAGE",), autoI8lnGen.translate("D_ONT_KNOW",),],
                          onChanged: (value) =>
                              setState(() => _wormTest = value!),
                        ),
                        _buildButtonGroup(
                          title: 'G_Q_23',
                          value: _tetanusVaccinations.toString(),
                          options: ['0', '1', '2', '3', '4'],
                          onChanged: (value) => setState(
                              () => _tetanusVaccinations = int.parse(value!)),
                        ),
                        _buildYesNoButton(
                          title:
                              'G_Q_37',
                          value: _hasOtherIssues,
                          onChanged: (value) =>
                              setState(() => _hasOtherIssues = value),
                        ),
                        if (_hasOtherIssues) ...[
                          _buildTextFormField(
                            controller: _disabilityController,
                            label: 'G_Q_38',
                            hint: 'G_Q_39',
                          ),
                        ],
                      ]
                    : [
                        _buildSummaryItem(
                          label: 'HIV Test Status',
                          value:
                              _getDisplayValue(_hivTestSelf, ''),
                        ),
                        if (_onART)
                          _buildSummaryItem(
                            label: 'ARRT',
                            value:
                                'O_T_S ${_artStartController.text}',
                            statusColor: Colors.blue,
                          ),
                        _buildSummaryItem(
                          label: 'S_T_E',
                          value:
                              _getDisplayValue(_syphilisTest, autoI8lnGen.translate("NOT_SPECIFIED")),
                        ),
                        _buildSummaryItem(
                          label: 'TB_TEST',
                          value: _getDisplayValue(_tbTest, autoI8lnGen.translate("NOT_SPECIFIED")),
                        ),
                        _buildSummaryItem(
                          label: 'M_T_E',
                          value:
                              _getDisplayValue(_malariaTest, autoI8lnGen.translate("NOT_SPECIFIED")),
                        ),
                        _buildSummaryItem(
                          label: 'T_V_A',
                          value: _tetanusVaccinations > 0
                              ? '$_tetanusVaccinations DOSES'
                              : 'NONE_REC',
                        ),
                        if (_hasOtherIssues)
                          _buildSummaryItem(
                            label: 'OHIS',
                            value: _disabilityController.text.isNotEmpty
                                ? _disabilityController.text
                                : 'YES_D_N_S',
                            statusColor: Colors.orange,
                          ),
                      ],
              ),

              _buildExpandableSection(
                title: 'P_I',
                sectionKey: 'P_2',
                filledCount: [
                  _lastMenstrualPeriodController.text,
                  _miscarriagesController.text,
                  _isFirstPregnancy ? autoI8lnGen.translate("F_WRD") : _liveBirthsController.text,
                ].where((x) => x.isNotEmpty).length,
                totalCount: 3,
                children: _isEditMode
                    ? [
                        _buildTextFormField(
                          controller: _lastMenstrualPeriodController,
                          label: 'G_Q_41',
                          hint: 'DD/MM/YYYY',
                          onChanged: (_) => _calculateExpectedDeliveryDate(),
                        ),
                        _buildYesNoButton(
                          title: 'G_Q_42',
                          value: _isFirstPregnancy,
                          onChanged: (value) =>
                              setState(() => _isFirstPregnancy = value),
                        ),
                        _buildTextFormField(
                          controller: _miscarriagesController,
                          label: 'G_Q_43',
                          keyboardType: TextInputType.number,
                          hint: 'G_Q_44',
                        ),
                        if (!_isFirstPregnancy) ...[
                          _buildTextFormField(
                            controller: _liveBirthsController,
                            label: 'G_Q_45',
                            keyboardType: TextInputType.number,
                            hint: 'G_Q_44',
                          ),
                          _buildTextFormField(
                            controller: _previousPregnanciesController,
                            label: 'G_Q_46',
                            keyboardType: TextInputType.number,
                            hint: 'G_Q_44',
                          ),
                          _buildButtonGroup(
                            title:
                                'G_Q_47',
                            value: _lastPregnancyTiming,
                            options: [
                              autoI8lnGen.translate("G_Q_48"),
                              autoI8lnGen.translate("G_Q_49"),
                              autoI8lnGen.translate("G_Q_50")
                            ],
                            onChanged: (value) =>
                                setState(() => _lastPregnancyTiming = value!),
                          ),
                          _buildYesNoButton(
                            title: 'G_Q_52',
                            value: _hadCesarean,
                            onChanged: (value) =>
                                setState(() => _hadCesarean = value),
                          ),
                          if (_hadCesarean) ...[
                            _buildTextFormField(
                              controller: _cesareanCountController,
                              label: 'G_Q_53',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ],
                      ]
                    : [
                        _buildSummaryItem(
                          label: 'L_M_P',
                          value: _getDisplayValue(
                              _lastMenstrualPeriodController.text,
                              autoI8lnGen.translate("NOT_SPECIFIED")),
                        ),
                        if (_expectedDeliveryDate != null)
                          _buildSummaryItem(
                            label: 'E_D_D',
                            value:
                                '${_expectedDeliveryDate!.day}/${_expectedDeliveryDate!.month}/${_expectedDeliveryDate!.year}',
                            statusColor: Colors.pink,
                          ),
                        _buildSummaryItem(
                          label: 'F_P_E',
                          value: _isFirstPregnancy ? 'YES_MESSAGE' : 'NO_MESSAGE',
                        ),
                        _buildSummaryItem(
                          label: 'Previous Miscarriages',
                          value: _miscarriagesController.text.isNotEmpty
                              ? _miscarriagesController.text
                              : autoI8lnGen.translate("NOT_SPECIFIED"),
                        ),
                        if (!_isFirstPregnancy) ...[
                          _buildSummaryItem(
                            label: 'P_LV_B',
                            value: _getDisplayValue(
                                _liveBirthsController.text, autoI8lnGen.translate("NOT_SPECIFIED")),
                          ),
                          _buildSummaryItem(
                            label: 'P_P',
                            value: _getDisplayValue(
                                _previousPregnanciesController.text,
                                autoI8lnGen.translate("NOT_SPECIFIED")),
                          ),
                          if (_lastPregnancyTiming != null)
                            _buildSummaryItem(
                              label: 'L_P_T',
                              value: _lastPregnancyTiming!,
                            ),
                          if (_hadCesarean)
                            _buildSummaryItem(
                              label: 'P_C_E',
                              value: _cesareanCountController.text.isNotEmpty
                                  ? '${_cesareanCountController.text} TIMES'
                                  : 'YES_MESSAGE',
                              statusColor: Colors.orange,
                            ),
                        ],
                      ],
              ),

              // Information Footer
              Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        SizedBox(width: 8),
                        AutoText(
                          'H_T_U_S',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    AutoText('TEIM'),
                    AutoText('TOST'),
                    AutoText('RINA'),
                    AutoText('OIPC'),
                    AutoText('GIAC'),
                    AutoText('Y_H_P_I'),
                  ],
                ),
              ),

              SizedBox(height: 80), // Space for floating button
            ],
          ),
        ),
      ),
      floatingActionButton: _isEditMode
          ? FloatingActionButton.extended(
              onPressed: _saveData,
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
              icon: Icon(Icons.save),
              label: AutoText('SAVE_CHANGES'),
            )
          : FloatingActionButton(
              onPressed: () => setState(() => _isEditMode = true),
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              child: Icon(Icons.edit),
              tooltip: autoI8lnGen.translate("E_I_F"),
            ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    _schoolingController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _haemoglobinController.dispose();
    _albuminController.dispose();
    _glucoseController.dispose();
    _smokingDetailsController.dispose();
    _herbalMedicineController.dispose();
    _modernMedicineController.dispose();
    _artStartController.dispose();
    _syphilisTreatmentController.dispose();
    _tbVaccinationYearController.dispose();
    _tbTreatmentStartController.dispose();
    _tbTreatmentStopController.dispose();
    _malariaTestDateController.dispose();
    _antimalarialTreatmentController.dispose();
    _disabilityController.dispose();
    _lastMenstrualPeriodController.dispose();
    _miscarriagesController.dispose();
    _liveBirthsController.dispose();
    _previousPregnanciesController.dispose();
    _stillbornController.dispose();
    _cesareanCountController.dispose();
    _deliveryRemarksController.dispose();
    super.dispose();
  }
}
