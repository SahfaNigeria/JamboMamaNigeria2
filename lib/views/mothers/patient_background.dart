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
  // String _smokingFrequency = '';
  String? _smokingFrequency;
  bool _drinksAlcohol = false;
  // String _alcoholType = '';
  String? _alcoholType;
  // String _alcoholFrequency = '';
  String? _alcoholFrequency;
  bool _usesHerbalMedicine = false;
  // String _herbalFrequency = '';
  String? _herbalFrequency;
  bool _usesModernMedicine = false;
  // String _modernMedicineType = '';
  String? _modernMedicineType;
  // String _hivTestSelf = '';
  String? _hivTestSelf;
  // String _hivTestPartner = '';
  String? _hivTestPartner;
  bool _onART = false;
  // String _partnerARTStatus = '';
  String? _partnerARTStatus;
  // String _syphilisTest = '';
  String? _syphilisTest;

  // String _tbTest = '';
  String? _tbTest;
  // String _tbVaccination = '';
  String? _tbVaccination;
  bool _onTBTreatment = false;
  bool _currentlyOnTBTreatment = false;
  int _tetanusVaccinations = 0;
  // String _tetanusRecent = '';
  String? _tetanusRecent;
  // String _malariaTest = '';
  String? _malariaTest;
  bool _onAntimalarials = false;
  // String _antimalarialRecent = '';
  String? _antimalarialRecent;
  // String _wormTest = '';
  String? _wormTest;
  // String _wormMedicineRecent = '';
  String? _wormMedicineRecent;
  bool _hasOtherIssues = false;
  bool _isFirstPregnancy = true;
  // String _lastPregnancyTiming = '';
  String? _lastPregnancyTiming;
  bool _hadCesarean = false;
  // String _hadForcepsVacuum = '';
  String? _hadForcepsVacuum;
  // String _hadHeavyBleeding = '';
  String? _hadHeavyBleeding;
  // String _hadTears = '';
  String? _hadTears;
  // String _tearsNeedStitching = '';
  String? _tearsNeedStitching;
  // String _tearsHealedNaturally = '';
  String? _tearsHealedNaturally;
  // String _tearsStillBothering = '';
  String? _tearsStillBothering;

  double? _bmi;
  String _bmiMessage = '';
  String _bpMessage = '';
  String _haemoglobinMessage = '';
  String _albuminMessage = '';
  String _glucoseMessage = '';
  DateTime? _expectedDeliveryDate;
  List<String> _alerts = [];

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
        // Populate controllers and state variables with existing data
        // Implementation would populate all fields based on saved data
      }
    } catch (e) {
      print('Error loading existing data: $e');
    }
  }

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
      // Calculate pregnancy weeks to determine appropriate range
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

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      _checkHighRiskFactors();

      // Step 1: Lookup connected provider
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
        print('✅ Connected provider found: $providerId');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Connection required: $e')),
        );
        return;
      }

      // Step 2: Build data map
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
        // Save to patient's document
        await _firestore
            .collection('patients')
            .doc(widget.patientId)
            .collection('background')
            .doc('patient_background')
            .set(data, SetOptions(merge: true));

        // Save to provider's view
        await _firestore
            .collection('health_provider_data')
            .doc(providerId)
            .collection('patient_backgrounds')
            .doc(widget.patientId)
            .set(data, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient background saved successfully')),
        );

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

  // Future<void> _saveData() async {
  //   if (_formKey.currentState!.validate()) {
  //     _checkHighRiskFactors();

  //     Map<String, dynamic> data = {
  //       'schooling': int.tryParse(_schoolingController.text),
  //       'age': int.tryParse(_ageController.text),
  //       'height': double.tryParse(_heightController.text),
  //       'weight': double.tryParse(_weightController.text),
  //       'bmi': _bmi,
  //       'bmi_message': _bmiMessage,
  //       'systolic_bp': int.tryParse(_systolicController.text),
  //       'diastolic_bp': int.tryParse(_diastolicController.text),
  //       'bp_message': _bpMessage,
  //       'haemoglobin': double.tryParse(_haemoglobinController.text),
  //       'haemoglobin_message': _haemoglobinMessage,
  //       'albumin': double.tryParse(_albuminController.text),
  //       'albumin_message': _albuminMessage,
  //       'glucose': double.tryParse(_glucoseController.text),
  //       'glucose_message': _glucoseMessage,
  //       'urinalysis': _urinalysisResult,
  //       'smokes_tobacco': _smokesTobacco,
  //       'smoking_details': _smokingDetailsController.text,
  //       'smoking_frequency': _smokingFrequency,
  //       'drinks_alcohol': _drinksAlcohol,
  //       'alcohol_type': _alcoholType,
  //       'alcohol_frequency': _alcoholFrequency,
  //       'uses_herbal_medicine': _usesHerbalMedicine,
  //       'herbal_medicine_details': _herbalMedicineController.text,
  //       'herbal_frequency': _herbalFrequency,
  //       'uses_modern_medicine': _usesModernMedicine,
  //       'modern_medicine_type': _modernMedicineType,
  //       'hiv_test_self': _hivTestSelf,
  //       'hiv_test_partner': _hivTestPartner,
  //       'on_art': _onART,
  //       'art_start_date': _artStartController.text,
  //       'partner_art_status': _partnerARTStatus,
  //       'syphilis_test': _syphilisTest,
  //       'syphilis_treatment': _syphilisTreatmentController.text,
  //       'tb_test': _tbTest,
  //       'tb_vaccination': _tbVaccination,
  //       'tb_vaccination_year': _tbVaccinationYearController.text,
  //       'on_tb_treatment': _onTBTreatment,
  //       'tb_treatment_start': _tbTreatmentStartController.text,
  //       'tb_treatment_stop': _tbTreatmentStopController.text,
  //       'currently_on_tb_treatment': _currentlyOnTBTreatment,
  //       'tetanus_vaccinations': _tetanusVaccinations,
  //       'tetanus_recent': _tetanusRecent,
  //       'malaria_test': _malariaTest,
  //       'malaria_test_date': _malariaTestDateController.text,
  //       'on_antimalarials': _onAntimalarials,
  //       'antimalarial_treatment': _antimalarialTreatmentController.text,
  //       'antimalarial_recent': _antimalarialRecent,
  //       'worm_test': _wormTest,
  //       'worm_medicine_recent': _wormMedicineRecent,
  //       'has_other_issues': _hasOtherIssues,
  //       'disability_details': _disabilityController.text,
  //       'last_menstrual_period': _lastMenstrualPeriodController.text,
  //       'expected_delivery_date': _expectedDeliveryDate?.toIso8601String(),
  //       'is_first_pregnancy': _isFirstPregnancy,
  //       'miscarriages': int.tryParse(_miscarriagesController.text),
  //       'live_births': int.tryParse(_liveBirthsController.text),
  //       'previous_pregnancies':
  //           int.tryParse(_previousPregnanciesController.text),
  //       'last_pregnancy_timing': _lastPregnancyTiming,
  //       'stillborn': int.tryParse(_stillbornController.text),
  //       'had_cesarean': _hadCesarean,
  //       'cesarean_count': int.tryParse(_cesareanCountController.text),
  //       'had_forceps_vacuum': _hadForcepsVacuum,
  //       'had_heavy_bleeding': _hadHeavyBleeding,
  //       'had_tears': _hadTears,
  //       'tears_need_stitching': _tearsNeedStitching,
  //       'tears_healed_naturally': _tearsHealedNaturally,
  //       'tears_still_bothering': _tearsStillBothering,
  //       'delivery_remarks': _deliveryRemarksController.text,
  //       'alerts': _alerts,
  //       'created_at': FieldValue.serverTimestamp(),
  //       'updated_at': FieldValue.serverTimestamp(),
  //     };

  //     try {
  //       await _firestore
  //           .collection('patients')
  //           .doc(widget.patientId)
  //           .collection('background')
  //           .doc('patient_background')
  //           .set(data, SetOptions(merge: true));

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Patient background saved successfully')),
  //       );

  //       if (_alerts.isNotEmpty) {
  //         _showAlertsDialog();
  //       }
  //     } catch (e) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error saving data: $e')),
  //       );
  //     }
  //   }
  // }

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

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
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
        ),
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
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
        onChanged: onChanged,
      ),
    );
  }

  // Widget _buildRadioGroup({
  //   required String title,
  //   required String? value,
  //   required List<String> options,
  //   required void Function(String?) onChanged,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(title,
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
  //       ...options
  //           .map((option) => RadioListTile<String>(
  //                 title: Text(option),
  //                 value: option,
  //                 groupValue: value,
  //                 onChanged: onChanged,
  //               ))
  //           .toList(),
  //     ],
  //   );
  // }

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
                  onTap: () => onChanged(option),
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
                onTap: () => onChanged(true),
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
                onTap: () => onChanged(false),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Background'),
        backgroundColor: Colors.blue[700],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // General Questions Section
              _buildSection('General Questions', [
                _buildTextFormField(
                  controller: _schoolingController,
                  label: 'Schooling (years)',
                  keyboardType: TextInputType.number,
                ),
                _buildTextFormField(
                  controller: _ageController,
                  label: 'Age in years',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      int? age = int.tryParse(value);
                      if (age != null && (age < 20 || age > 39)) {
                        return 'Age outside typical range (20-39)';
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
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            double? height = double.tryParse(value);
                            if (height != null && height < 150) {
                              return 'Height below 150cm requires attention';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _weightController,
                        label: 'Weight (kg)',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateBMI(),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            double? weight = double.tryParse(value);
                            if (weight != null && weight < 45) {
                              return 'Weight below 45kg requires attention';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                if (_bmi != null) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _bmiMessage == 'Thumb up'
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _bmiMessage == 'Thumb up'
                              ? Icons.thumb_up
                              : Icons.warning,
                          color: _bmiMessage == 'Thumb up'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text('BMI: ${_bmi!.toStringAsFixed(1)} - $_bmiMessage'),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
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
                if (_bpMessage.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _bpMessage == 'Thumb up'
                          ? Colors.green[100]
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _bpMessage == 'Thumb up'
                              ? Icons.thumb_up
                              : Icons.warning,
                          color: _bpMessage == 'Thumb up'
                              ? Colors.green
                              : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Expanded(child: Text(_bpMessage)),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                _buildTextFormField(
                  controller: _haemoglobinController,
                  label: 'Haemoglobin (g/dl)',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _checkHaemoglobin(),
                ),
                if (_haemoglobinMessage.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _haemoglobinMessage == 'Thumb up'
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _haemoglobinMessage == 'Thumb up'
                              ? Icons.thumb_up
                              : Icons.warning,
                          color: _haemoglobinMessage == 'Thumb up'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Expanded(child: Text(_haemoglobinMessage)),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                _buildTextFormField(
                  controller: _albuminController,
                  label: 'Albumin in Urine (mg/L)',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _checkAlbumin(),
                ),
                if (_albuminMessage.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _albuminMessage.contains('Normal')
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _albuminMessage.contains('Normal')
                              ? Icons.thumb_up
                              : Icons.warning,
                          color: _albuminMessage.contains('Normal')
                              ? Colors.green
                              : Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Expanded(child: Text(_albuminMessage)),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                _buildTextFormField(
                  controller: _glucoseController,
                  label: 'Glucose in Urine (mmol/L)',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _checkGlucose(),
                ),
                if (_glucoseMessage.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _glucoseMessage == 'Normal'
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _glucoseMessage == 'Normal'
                              ? Icons.thumb_up
                              : Icons.warning,
                          color: _glucoseMessage == 'Normal'
                              ? Colors.green
                              : Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Expanded(child: Text(_glucoseMessage)),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                _buildDropdownFormField(
                  label: 'Urinalysis',
                  value: _urinalysisResult,
                  items: ['Normal', 'So-so', 'Danger'],
                  onChanged: (value) =>
                      setState(() => _urinalysisResult = value),
                ),
              ]),

              // Lifestyle Questions Section
              _buildSection('Lifestyle Questions', [
                _buildYesNoButton(
                  title: 'Do you smoke or chew tobacco?',
                  value: _smokesTobacco,
                  onChanged: (value) => setState(() => _smokesTobacco = value),
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
                  onChanged: (value) => setState(() => _drinksAlcohol = value),
                ),
                if (_drinksAlcohol) ...[
                  _buildButtonGroup(
                    title: 'Type of alcohol',
                    value: _alcoholType,
                    options: ['Beer', 'Liquor', 'Both'],
                    onChanged: (value) => setState(() => _alcoholType = value!),
                  ),
                  _buildButtonGroup(
                    title: 'How often?',
                    value: _alcoholFrequency,
                    options: ['Daily', 'Weekly', 'Less often'],
                    onChanged: (value) =>
                        setState(() => _alcoholFrequency = value!),
                  ),
                ],
              ]),

              // Medical History Section

              _buildSection('Medical History', [
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
                _buildYesNoButton(
                  title: 'Do you regularly use modern medicine?',
                  value: _usesModernMedicine,
                  onChanged: (value) =>
                      setState(() => _usesModernMedicine = value),
                ),
                if (_usesModernMedicine) ...[
                  _buildButtonGroup(
                    title: 'Type of medicine',
                    value: _modernMedicineType,
                    options: [
                      'Without prescription (like paracetamol)',
                      'With prescription (like antibiotics)'
                    ],
                    onChanged: (value) =>
                        setState(() => _modernMedicineType = value!),
                  ),
                ],
                _buildButtonGroup(
                  title: 'Have you been tested for HIV/AIDS?',
                  value: _hivTestSelf,
                  options: ['Yes', 'No', 'Don\'t Know'],
                  onChanged: (value) => setState(() => _hivTestSelf = value!),
                ),
                _buildButtonGroup(
                  title: 'Has your partner been tested for HIV/AIDS?',
                  value: _hivTestPartner,
                  options: ['Yes', 'No', 'Don\'t Know'],
                  onChanged: (value) =>
                      setState(() => _hivTestPartner = value!),
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
                  _buildButtonGroup(
                    title: 'Is your partner also treated?',
                    value: _partnerARTStatus,
                    options: ['Yes', 'No', 'Don\'t know'],
                    onChanged: (value) =>
                        setState(() => _partnerARTStatus = value!),
                  ),
                ],
                _buildButtonGroup(
                  title: 'Have you and your spouse been tested for Syphilis?',
                  value: _syphilisTest,
                  options: ['Yes', 'No', 'Don\'t know'],
                  onChanged: (value) => setState(() => _syphilisTest = value!),
                ),
                if (_syphilisTest == 'Yes') ...[
                  _buildTextFormField(
                    controller: _syphilisTreatmentController,
                    label: 'Name treatment',
                  ),
                ],
                _buildButtonGroup(
                  title: 'Have you been tested for TB?',
                  value: _tbTest,
                  options: ['Yes', 'No', 'Don\'t Know'],
                  onChanged: (value) => setState(() => _tbTest = value!),
                ),
                _buildButtonGroup(
                  title: 'Have you been vaccinated against TB?',
                  value: _tbVaccination,
                  options: ['Yes', 'No', 'Don\'t know'],
                  onChanged: (value) => setState(() => _tbVaccination = value!),
                ),
                if (_tbVaccination == 'Yes') ...[
                  _buildTextFormField(
                    controller: _tbVaccinationYearController,
                    label: 'When? (Year)',
                    keyboardType: TextInputType.number,
                  ),
                ],
                _buildYesNoButton(
                  title: 'Have you been on TB treatment?',
                  value: _onTBTreatment,
                  onChanged: (value) => setState(() => _onTBTreatment = value),
                ),
                if (_onTBTreatment) ...[
                  _buildTextFormField(
                    controller: _tbTreatmentStartController,
                    label: 'When did you start? (M/Y)',
                    hint: 'MM/YYYY',
                  ),
                  _buildTextFormField(
                    controller: _tbTreatmentStopController,
                    label: 'When did you stop? (M/Y)',
                    hint: 'MM/YYYY',
                  ),
                ],
                _buildYesNoButton(
                  title: 'Are you on TB treatment now?',
                  value: _currentlyOnTBTreatment,
                  onChanged: (value) =>
                      setState(() => _currentlyOnTBTreatment = value),
                ),
                _buildButtonGroup(
                  title: 'How many tetanus vaccinations have you had?',
                  value: _tetanusVaccinations.toString(),
                  options: ['0', '1', '2', '3', '4'],
                  onChanged: (value) =>
                      setState(() => _tetanusVaccinations = int.parse(value!)),
                ),
                _buildButtonGroup(
                  title: 'When was the most recent tetanus vaccination?',
                  value: _tetanusRecent,
                  options: [
                    'Less than 1 year ago',
                    'More than a year ago',
                    'Don\'t remember'
                  ],
                  onChanged: (value) => setState(() => _tetanusRecent = value!),
                ),
                _buildButtonGroup(
                  title: 'Have you been tested for malaria?',
                  value: _malariaTest,
                  options: ['Yes', 'No', 'Don\'t know'],
                  onChanged: (value) => setState(() => _malariaTest = value!),
                ),
                if (_malariaTest == 'Yes') ...[
                  _buildTextFormField(
                    controller: _malariaTestDateController,
                    label: 'When? (Month/Year)',
                    hint: 'MM/YYYY',
                  ),
                ],
                _buildYesNoButton(
                  title: 'Are you using antimalarial treatment now?',
                  value: _onAntimalarials,
                  onChanged: (value) =>
                      setState(() => _onAntimalarials = value),
                ),
                if (_onAntimalarials) ...[
                  _buildTextFormField(
                    controller: _antimalarialTreatmentController,
                    label: 'Name of treatment',
                  ),
                ],
                _buildButtonGroup(
                  title: 'When did you use antimalarials most recently?',
                  value: _antimalarialRecent,
                  options: [
                    'Less than 3 months ago',
                    '3-6 months ago',
                    'Over 6 months ago'
                  ],
                  onChanged: (value) =>
                      setState(() => _antimalarialRecent = value!),
                ),
                _buildButtonGroup(
                  title: 'Have you been tested for worms?',
                  value: _wormTest,
                  options: ['Yes', 'No', 'Don\'t remember'],
                  onChanged: (value) => setState(() => _wormTest = value!),
                ),
                _buildButtonGroup(
                  title: 'When did you take worm medicine for the last time?',
                  value: _wormMedicineRecent,
                  options: [
                    'Never took it',
                    'Less than 6 months ago',
                    'Over 6 months ago'
                  ],
                  onChanged: (value) =>
                      setState(() => _wormMedicineRecent = value!),
                ),
                _buildYesNoButton(
                  title: 'Any other issues? (disability or chronic condition)',
                  value: _hasOtherIssues,
                  onChanged: (value) => setState(() => _hasOtherIssues = value),
                ),
                if (_hasOtherIssues) ...[
                  _buildTextFormField(
                    controller: _disabilityController,
                    label: 'Please specify',
                    hint: 'Diabetes, Hypertension, Heart disease, etc.',
                  ),
                ],
              ]),

              // Pregnancy Related Questions Section

              _buildSection('Pregnancy Related Questions', [
                _buildTextFormField(
                  controller: _lastMenstrualPeriodController,
                  label: 'First day of last menstrual period',
                  hint: 'DD/MM/YYYY',
                  onChanged: (_) => _calculateExpectedDeliveryDate(),
                ),
                if (_expectedDeliveryDate != null) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.pink[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.baby_changing_station, color: Colors.pink),
                        SizedBox(width: 8),
                        Text(
                          'Your baby is expected on: ${_expectedDeliveryDate!.day}/${_expectedDeliveryDate!.month}/${_expectedDeliveryDate!.year}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
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
                    title: 'When was your last pregnancy before this one?',
                    value: _lastPregnancyTiming,
                    options: ['>9 years', 'Between 9 and 5 years', '<5 years'],
                    onChanged: (value) =>
                        setState(() => _lastPregnancyTiming = value!),
                  ),
                  _buildTextFormField(
                    controller: _stillbornController,
                    label: 'Any stillborn or baby died at or soon after birth?',
                    keyboardType: TextInputType.number,
                    hint: 'Enter 0 if none',
                  ),
                  _buildYesNoButton(
                    title: 'Already had a cesarean section?',
                    value: _hadCesarean,
                    onChanged: (value) => setState(() => _hadCesarean = value),
                  ),
                  if (_hadCesarean) ...[
                    _buildTextFormField(
                      controller: _cesareanCountController,
                      label: 'How many?',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  _buildButtonGroup(
                    title: 'Ever had birth with forceps or vacuum extractor?',
                    value: _hadForcepsVacuum,
                    options: ['Yes', 'No', 'Don\'t know'],
                    onChanged: (value) =>
                        setState(() => _hadForcepsVacuum = value!),
                  ),
                  _buildButtonGroup(
                    title: 'Ever had heavy bleeding AT or AFTER delivery?',
                    value: _hadHeavyBleeding,
                    options: ['Yes', 'No', 'Don\'t know'],
                    onChanged: (value) =>
                        setState(() => _hadHeavyBleeding = value!),
                  ),
                  _buildButtonGroup(
                    title: 'Did you have any tears?',
                    value: _hadTears,
                    options: ['Yes', 'No', 'Don\'t know'],
                    onChanged: (value) => setState(() => _hadTears = value!),
                  ),
                  if (_hadTears == 'Yes') ...[
                    _buildButtonGroup(
                      title: 'Did they need stitching?',
                      value: _tearsNeedStitching,
                      options: ['Yes', 'No', 'Don\'t know'],
                      onChanged: (value) =>
                          setState(() => _tearsNeedStitching = value!),
                    ),
                    _buildButtonGroup(
                      title: 'Did they heal by themselves?',
                      value: _tearsHealedNaturally,
                      options: ['Yes', 'No', 'Don\'t know'],
                      onChanged: (value) =>
                          setState(() => _tearsHealedNaturally = value!),
                    ),
                    _buildButtonGroup(
                      title: 'Are they still bothering you?',
                      value: _tearsStillBothering,
                      options: ['Yes', 'No', 'Don\'t know'],
                      onChanged: (value) =>
                          setState(() => _tearsStillBothering = value!),
                    ),
                  ],
                  _buildTextFormField(
                    controller: _deliveryRemarksController,
                    label: 'Any other remarks about previous deliveries?',
                    hint: 'If you can\'t write them, tell your HP at visit',
                  ),
                ],
              ]),

              // Alerts Section
              if (_alerts.isNotEmpty) ...[
                _buildSection('Health Provider Alerts', [
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
                            Icon(Icons.warning, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Alerts for Health Provider:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ..._alerts
                            .map((alert) => Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Text('• $alert'),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ]),
              ],

              // Save Button

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
                    Text(
                      'Important Information:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                        '• Incomplete data will not prevent saving your information'),
                    Text(
                        '• You and your Health Provider can see gaps to complete later'),
                    Text(
                        '• This information helps monitor your pregnancy evolution'),
                    Text(
                        '• Contact your Health Provider if you have questions'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              'Save Patient Background',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
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
