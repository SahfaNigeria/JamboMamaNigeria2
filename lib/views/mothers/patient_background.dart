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
          _bmiMessage = 'Too low';
        } else if (_bmi! >= 18.5 && _bmi! <= 24.9) {
          _bmiMessage = 'Thumb up';
        } else if (_bmi! >= 25 && _bmi! <= 29) {
          _bmiMessage = 'Too high';
        } else {
          _bmiMessage = 'Obese: danger!';
          _addAlert('This BMI level indicates obesity');
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
          _bpMessage = 'Thumb up';
        } else if (systolic >= 121 &&
            systolic <= 129 &&
            diastolic >= 81 &&
            diastolic <= 89) {
          _bpMessage = 'ELEVATED – change diet';
        } else if (systolic >= 130 && systolic <= 139 && diastolic >= 90) {
          _bpMessage =
              'This level indicates Hypertension stage 1: diet change and treatment';
        } else if (systolic >= 140 && diastolic >= 90) {
          _bpMessage =
              'This level indicates Hypertension stage 2: needs monitoring and treatment';
        } else if (systolic >= 160 && diastolic >= 100) {
          _bpMessage =
              'This level indicates Hypertension emergency: immediate medical intervention needed';
          _addAlert('Hypertension emergency');
        }
      });
    }
  }

  void _checkHaemoglobin() {
    final haemoglobin = double.tryParse(_haemoglobinController.text);
    if (haemoglobin != null) {
      setState(() {
        if (haemoglobin < 9.5) {
          _haemoglobinMessage = 'Too low - nutrition change/treatment needed';
        } else if (haemoglobin > 15) {
          _haemoglobinMessage = 'Too high - treatment needed';
        } else {
          _haemoglobinMessage = 'Thumb up';
        }
      });
    }
  }

  void _checkAlbumin() {
    final albumin = double.tryParse(_albuminController.text);
    if (albumin != null) {
      setState(() {
        if (albumin <= 150) {
          _albuminMessage = 'Normal (Thumb up)';
        } else if (albumin > 150 && albumin <= 300) {
          _albuminMessage = 'So-so: needs treatment';
        } else {
          _albuminMessage = 'Needs doctor\'s advice';
          _addAlert('High albumin levels');
        }
      });
    }
  }

  void _checkGlucose() {
    final glucose = double.tryParse(_glucoseController.text);
    if (glucose != null) {
      setState(() {
        if (glucose < 7.8) {
          _glucoseMessage = 'Normal';
        } else if (glucose >= 7.8 && glucose < 11.0) {
          _glucoseMessage = '2nd test needed';
        } else {
          _glucoseMessage =
              'This level indicates gestational diabetes. Your RHP will advise you';
          _addAlert('Possible gestational diabetes');
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
        _addAlert('Age-related risk factor');
      }
      if (_isFirstPregnancy && (age < 20 || age > 35)) {
        _addAlert('First pregnancy with age risk');
      }
    }

    final miscarriages = int.tryParse(_miscarriagesController.text);
    if (miscarriages != null && miscarriages > 0) {
      _addAlert('Previous miscarriages');
    }

    if (_lastPregnancyTiming == '>9 years') {
      _addAlert('Long interval since last pregnancy');
    }

    if (_hadCesarean) {
      _addAlert('Previous cesarean section');
    }

    if (_hadHeavyBleeding == 'Yes') {
      _addAlert('Previous heavy bleeding');
    }

    if (_onART) {
      _addAlert('HIV positive on ART');
    }

    if (_currentlyOnTBTreatment) {
      _addAlert('Currently on TB treatment');
    }

    if (_hasOtherIssues) {
      _addAlert('Other chronic conditions');
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

    if (_ageController.text.isEmpty) missing.add('Age');
    if (_heightController.text.isEmpty) missing.add('Height');
    if (_weightController.text.isEmpty) missing.add('Weight');
    if (_systolicController.text.isEmpty) missing.add('Blood Pressure');
    if (_haemoglobinController.text.isEmpty) missing.add('Haemoglobin');
    if (_urinalysisResult == null) missing.add('Urinalysis');
    if (_hivTestSelf == null) missing.add('HIV Test Status');
    if (_syphilisTest == null) missing.add('Syphilis Test');
    if (_tbTest == null) missing.add('TB Test');
    if (_malariaTest == null) missing.add('Malaria Test');
    if (_lastMenstrualPeriodController.text.isEmpty)
      missing.add('Last Menstrual Period');
    if (_tetanusVaccinations == 0) missing.add('Tetanus Vaccinations');

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
          SnackBar(content: Text('❌ Connection required: $e')),
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
          SnackBar(content: Text('Error saving data: $e')),
        );
      }
    }
  }

  void _showAlertsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Health Provider Alerts'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('The following alerts have been generated:'),
              SizedBox(height: 10),
              ..._alerts.map((alert) => Text('• $alert')).toList(),
            ],
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
                Text(
                  'Background Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => setState(() => _isEditMode = !_isEditMode),
                  icon: Icon(_isEditMode ? Icons.visibility : Icons.edit),
                  tooltip: _isEditMode ? 'View Mode' : 'Edit Mode',
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
                Text(
                  '$completionPercentage% Complete',
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
                        Text(
                          'Still needed (${missingFields.length} items):',
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
                        Text(
                          'Health Alerts (${_alerts.length}):',
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
                  child: Text(
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
                  child: Text(
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
    final isEmpty = value.isEmpty || value == 'Not specified';

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
        title: Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          isEmpty ? 'Tap to add' : value,
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

  String _getSectionForField(String label) {
    if ([
      'Age',
      'Height',
      'Weight',
      'Blood Pressure',
      'Haemoglobin',
      'Albumin',
      'Glucose',
      'Urinalysis'
    ].contains(label)) {
      return 'general';
    } else if (['Tobacco Use', 'Alcohol Use'].contains(label)) {
      return 'lifestyle';
    } else if (['HIV Test', 'TB Test', 'Malaria Test', 'Syphilis Test']
        .contains(label)) {
      return 'medical';
    } else {
      return 'pregnancy';
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
          labelText: label,
          hintText: hint,
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
          labelText: label,
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
        Text(
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
                        Text(
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
    switch (option.toLowerCase()) {
      case 'yes':
        return Icons.check_circle;
      case 'no':
        return Icons.cancel;
      case "don't know":
      case "don't remember":
        return Icons.help;
      case 'daily':
        return Icons.today;
      case 'weekly':
        return Icons.calendar_view_week;
      case 'less often':
        return Icons.calendar_month;
      case 'beer':
        return Icons.local_bar;
      case 'liquor':
        return Icons.wine_bar;
      case 'both':
        return Icons.restaurant;
      default:
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
        Text(
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
                      Text(
                        'Yes',
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
                      Text(
                        'No',
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
                Text(
                  '$title: $value',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                if (message.isNotEmpty)
                  Text(
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
        title: Text('Patient Background'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            onPressed: () => setState(() => _isEditMode = !_isEditMode),
            icon: Icon(_isEditMode ? Icons.visibility : Icons.edit),
            tooltip: _isEditMode ? 'View Mode' : 'Edit Mode',
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
                        Text(
                          'Health Indicators',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 12),
                        if (_bmi != null)
                          _buildHealthIndicator(
                            'BMI',
                            _bmi!.toStringAsFixed(1),
                            _bmiMessage,
                            Icons.monitor_weight,
                            _bmiMessage == 'Thumb up'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        if (_bpMessage.isNotEmpty)
                          _buildHealthIndicator(
                            'Blood Pressure',
                            '${_systolicController.text}/${_diastolicController.text}',
                            _bpMessage,
                            Icons.favorite,
                            _bpMessage == 'Thumb up'
                                ? Colors.green
                                : Colors.red,
                          ),
                        if (_haemoglobinMessage.isNotEmpty)
                          _buildHealthIndicator(
                            'Haemoglobin',
                            '${_haemoglobinController.text} g/dl',
                            _haemoglobinMessage,
                            Icons.water_drop,
                            _haemoglobinMessage == 'Thumb up'
                                ? Colors.green
                                : Colors.orange,
                          ),
                        if (_expectedDeliveryDate != null)
                          _buildHealthIndicator(
                            'Expected Delivery',
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
                title: 'General Information',
                sectionKey: 'general',
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
                          label: 'Schooling (years)',
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextFormField(
                          controller: _ageController,
                          label: 'Age in years',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _calculateBMI(),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              int? age = int.tryParse(value);
                              if (age != null && (age < 11 || age > 60)) {
                                return 'Age must be between 11 and 60 years';
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
                                label: 'Height (cm)',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _calculateBMI(),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _weightController,
                                label: 'Weight (kg)',
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
                                label: 'Systolic BP',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _checkBloodPressure(),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: _buildTextFormField(
                                controller: _diastolicController,
                                label: 'Diastolic BP',
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _checkBloodPressure(),
                              ),
                            ),
                          ],
                        ),
                        _buildTextFormField(
                          controller: _haemoglobinController,
                          label: 'Haemoglobin (g/dl)',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _checkHaemoglobin(),
                        ),
                        _buildTextFormField(
                          controller: _albuminController,
                          label: 'Albumin in Urine (mg/L)',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _checkAlbumin(),
                        ),
                        _buildTextFormField(
                          controller: _glucoseController,
                          label: 'Glucose in Urine (mmol/L)',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _checkGlucose(),
                        ),
                        _buildDropdownFormField(
                          label: 'Urinalysis',
                          value: _urinalysisResult,
                          items: ['Normal', 'So-so', 'Danger'],
                          onChanged: (value) =>
                              setState(() => _urinalysisResult = value),
                        ),
                      ]
                    : [
                        _buildSummaryItem(
                          label: 'Age',
                          value: _getDisplayValue(
                              _ageController.text, 'Not specified'),
                        ),
                        _buildSummaryItem(
                          label: 'Height & Weight',
                          value: _heightController.text.isNotEmpty &&
                                  _weightController.text.isNotEmpty
                              ? '${_heightController.text} cm, ${_weightController.text} kg'
                              : 'Not specified',
                          trailing: _bmi != null
                              ? Text(
                                  'BMI: ${_bmi!.toStringAsFixed(1)}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        _buildSummaryItem(
                          label: 'Blood Pressure',
                          value: _systolicController.text.isNotEmpty &&
                                  _diastolicController.text.isNotEmpty
                              ? '${_systolicController.text}/${_diastolicController.text}'
                              : 'Not specified',
                        ),
                        _buildSummaryItem(
                          label: 'Haemoglobin',
                          value: _getDisplayValue(
                              _haemoglobinController.text, 'Not specified'),
                        ),
                        _buildSummaryItem(
                          label: 'Urinalysis',
                          value: _getDisplayValue(
                              _urinalysisResult, 'Not specified'),
                        ),
                      ],
              ),

              _buildExpandableSection(
                title: 'Lifestyle',
                sectionKey: 'lifestyle',
                filledCount: [
                  _smokesTobacco ? 'yes' : '',
                  _drinksAlcohol ? 'yes' : '',
                ].where((x) => x.isNotEmpty).length,
                totalCount: 2,
                children: _isEditMode
                    ? [
                        _buildYesNoButton(
                          title: 'Do you smoke or chew tobacco?',
                          value: _smokesTobacco,
                          onChanged: (value) =>
                              setState(() => _smokesTobacco = value),
                        ),
                        if (_smokesTobacco) ...[
                          _buildTextFormField(
                            controller: _smokingDetailsController,
                            label: 'Specify tobacco use',
                          ),
                          _buildButtonGroup(
                            title: 'How often?',
                            value: _smokingFrequency,
                            options: ['Daily', 'Weekly', 'Less often'],
                            onChanged: (value) =>
                                setState(() => _smokingFrequency = value!),
                          ),
                        ],
                        _buildYesNoButton(
                          title: 'Do you drink alcohol?',
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
                            options: ['Daily', 'Weekly', 'Less often'],
                            onChanged: (value) =>
                                setState(() => _alcoholFrequency = value!),
                          ),
                        ],
                      ]
                    : [
                        _buildSummaryItem(
                          label: 'Tobacco Use',
                          value: _smokesTobacco
                              ? 'Yes${_smokingFrequency != null ? " - $_smokingFrequency" : ""}'
                              : 'No',
                        ),
                        _buildSummaryItem(
                          label: 'Alcohol Use',
                          value: _drinksAlcohol
                              ? 'Yes${_alcoholType != null ? " - $_alcoholType" : ""}${_alcoholFrequency != null ? " ($_alcoholFrequency)" : ""}'
                              : 'No',
                        ),
                      ],
              ),

              _buildExpandableSection(
                title: 'Medical History',
                sectionKey: 'medical',
                filledCount: [
                  _hivTestSelf,
                  _syphilisTest,
                  _tbTest,
                  _malariaTest,
                  _wormTest,
                  _tetanusVaccinations > 0 ? 'yes' : null,
                ].where((x) => x != null && x.toString().isNotEmpty).length,
                totalCount: 6,
                children: _isEditMode
                    ? [
                        _buildYesNoButton(
                          title: 'Do you use herbal medicine?',
                          value: _usesHerbalMedicine,
                          onChanged: (value) =>
                              setState(() => _usesHerbalMedicine = value),
                        ),
                        if (_usesHerbalMedicine) ...[
                          _buildTextFormField(
                            controller: _herbalMedicineController,
                            label: 'Which herbs?',
                          ),
                          _buildButtonGroup(
                            title: 'How often?',
                            value: _herbalFrequency,
                            options: ['Daily', 'Weekly', 'Less often'],
                            onChanged: (value) =>
                                setState(() => _herbalFrequency = value!),
                          ),
                        ],
                        _buildButtonGroup(
                          title: 'Have you been tested for HIV/AIDS?',
                          value: _hivTestSelf,
                          options: ['Yes', 'No', 'Don\'t Know'],
                          onChanged: (value) =>
                              setState(() => _hivTestSelf = value!),
                        ),
                        _buildYesNoButton(
                          title: 'Are you on Antiretroviral Therapy (ART)?',
                          value: _onART,
                          onChanged: (value) => setState(() => _onART = value),
                        ),
                        if (_onART) ...[
                          _buildTextFormField(
                            controller: _artStartController,
                            label: 'Since when? (Month/Year)',
                            hint: 'MM/YYYY',
                          ),
                        ],
                        _buildButtonGroup(
                          title:
                              'Have you and your spouse been tested for Syphilis?',
                          value: _syphilisTest,
                          options: ['Yes', 'No', 'Don\'t know'],
                          onChanged: (value) =>
                              setState(() => _syphilisTest = value!),
                        ),
                        _buildButtonGroup(
                          title: 'Have you been tested for TB?',
                          value: _tbTest,
                          options: ['Yes', 'No', 'Don\'t Know'],
                          onChanged: (value) =>
                              setState(() => _tbTest = value!),
                        ),
                        _buildButtonGroup(
                          title: 'Have you been tested for malaria?',
                          value: _malariaTest,
                          options: ['Yes', 'No', 'Don\'t know'],
                          onChanged: (value) =>
                              setState(() => _malariaTest = value!),
                        ),
                        _buildButtonGroup(
                          title: 'Have you been tested for worms?',
                          value: _wormTest,
                          options: ['Yes', 'No', 'Don\'t remember'],
                          onChanged: (value) =>
                              setState(() => _wormTest = value!),
                        ),
                        _buildButtonGroup(
                          title: 'How many tetanus vaccinations have you had?',
                          value: _tetanusVaccinations.toString(),
                          options: ['0', '1', '2', '3', '4'],
                          onChanged: (value) => setState(
                              () => _tetanusVaccinations = int.parse(value!)),
                        ),
                        _buildYesNoButton(
                          title:
                              'Any other issues? (disability or chronic condition)',
                          value: _hasOtherIssues,
                          onChanged: (value) =>
                              setState(() => _hasOtherIssues = value),
                        ),
                        if (_hasOtherIssues) ...[
                          _buildTextFormField(
                            controller: _disabilityController,
                            label: 'Please specify',
                            hint: 'Diabetes, Hypertension, Heart disease, etc.',
                          ),
                        ],
                      ]
                    : [
                        _buildSummaryItem(
                          label: 'HIV Test Status',
                          value:
                              _getDisplayValue(_hivTestSelf, 'Not specified'),
                        ),
                        if (_onART)
                          _buildSummaryItem(
                            label: 'ART Treatment',
                            value:
                                'On treatment since ${_artStartController.text}',
                            statusColor: Colors.blue,
                          ),
                        _buildSummaryItem(
                          label: 'Syphilis Test',
                          value:
                              _getDisplayValue(_syphilisTest, 'Not specified'),
                        ),
                        _buildSummaryItem(
                          label: 'TB Test',
                          value: _getDisplayValue(_tbTest, 'Not specified'),
                        ),
                        _buildSummaryItem(
                          label: 'Malaria Test',
                          value:
                              _getDisplayValue(_malariaTest, 'Not specified'),
                        ),
                        _buildSummaryItem(
                          label: 'Tetanus Vaccinations',
                          value: _tetanusVaccinations > 0
                              ? '$_tetanusVaccinations doses'
                              : 'None recorded',
                        ),
                        if (_hasOtherIssues)
                          _buildSummaryItem(
                            label: 'Other Health Issues',
                            value: _disabilityController.text.isNotEmpty
                                ? _disabilityController.text
                                : 'Yes (details not specified)',
                            statusColor: Colors.orange,
                          ),
                      ],
              ),

              _buildExpandableSection(
                title: 'Pregnancy Information',
                sectionKey: 'pregnancy',
                filledCount: [
                  _lastMenstrualPeriodController.text,
                  _miscarriagesController.text,
                  _isFirstPregnancy ? 'first' : _liveBirthsController.text,
                ].where((x) => x.isNotEmpty).length,
                totalCount: 3,
                children: _isEditMode
                    ? [
                        _buildTextFormField(
                          controller: _lastMenstrualPeriodController,
                          label: 'First day of last menstrual period',
                          hint: 'DD/MM/YYYY',
                          onChanged: (_) => _calculateExpectedDeliveryDate(),
                        ),
                        _buildYesNoButton(
                          title: 'Is this your first pregnancy?',
                          value: _isFirstPregnancy,
                          onChanged: (value) =>
                              setState(() => _isFirstPregnancy = value),
                        ),
                        _buildTextFormField(
                          controller: _miscarriagesController,
                          label: 'How many miscarriages did you have before?',
                          keyboardType: TextInputType.number,
                          hint: 'Enter 0 if none',
                        ),
                        if (!_isFirstPregnancy) ...[
                          _buildTextFormField(
                            controller: _liveBirthsController,
                            label: 'Number of previous live births?',
                            keyboardType: TextInputType.number,
                            hint: 'Enter 0 if none',
                          ),
                          _buildTextFormField(
                            controller: _previousPregnanciesController,
                            label: 'Number of previous pregnancies?',
                            keyboardType: TextInputType.number,
                            hint: 'Enter 0 if none',
                          ),
                          _buildButtonGroup(
                            title:
                                'When was your last pregnancy before this one?',
                            value: _lastPregnancyTiming,
                            options: [
                              '>9 years',
                              'Between 9 and 5 years',
                              '<5 years'
                            ],
                            onChanged: (value) =>
                                setState(() => _lastPregnancyTiming = value!),
                          ),
                          _buildYesNoButton(
                            title: 'Already had a cesarean section?',
                            value: _hadCesarean,
                            onChanged: (value) =>
                                setState(() => _hadCesarean = value),
                          ),
                          if (_hadCesarean) ...[
                            _buildTextFormField(
                              controller: _cesareanCountController,
                              label: 'How many?',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ],
                      ]
                    : [
                        _buildSummaryItem(
                          label: 'Last Menstrual Period',
                          value: _getDisplayValue(
                              _lastMenstrualPeriodController.text,
                              'Not specified'),
                        ),
                        if (_expectedDeliveryDate != null)
                          _buildSummaryItem(
                            label: 'Expected Delivery Date',
                            value:
                                '${_expectedDeliveryDate!.day}/${_expectedDeliveryDate!.month}/${_expectedDeliveryDate!.year}',
                            statusColor: Colors.pink,
                          ),
                        _buildSummaryItem(
                          label: 'First Pregnancy',
                          value: _isFirstPregnancy ? 'Yes' : 'No',
                        ),
                        _buildSummaryItem(
                          label: 'Previous Miscarriages',
                          value: _miscarriagesController.text.isNotEmpty
                              ? _miscarriagesController.text
                              : 'Not specified',
                        ),
                        if (!_isFirstPregnancy) ...[
                          _buildSummaryItem(
                            label: 'Previous Live Births',
                            value: _getDisplayValue(
                                _liveBirthsController.text, 'Not specified'),
                          ),
                          _buildSummaryItem(
                            label: 'Previous Pregnancies',
                            value: _getDisplayValue(
                                _previousPregnanciesController.text,
                                'Not specified'),
                          ),
                          if (_lastPregnancyTiming != null)
                            _buildSummaryItem(
                              label: 'Last Pregnancy Timing',
                              value: _lastPregnancyTiming!,
                            ),
                          if (_hadCesarean)
                            _buildSummaryItem(
                              label: 'Previous Cesarean',
                              value: _cesareanCountController.text.isNotEmpty
                                  ? '${_cesareanCountController.text} times'
                                  : 'Yes',
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
                        Text(
                          'How to use this screen:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• Tap the edit icon to modify any information'),
                    Text('• Tap on sections to expand and see details'),
                    Text('• Red items need your attention'),
                    Text('• Orange items are partially complete'),
                    Text('• Green items are complete'),
                    Text('• Your health provider can see all information'),
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
              label: Text('Save Changes'),
            )
          : FloatingActionButton(
              onPressed: () => setState(() => _isEditMode = true),
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              child: Icon(Icons.edit),
              tooltip: 'Edit Information',
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
