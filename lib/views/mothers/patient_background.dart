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
      // Calculate pregnancy weeks to determine appropriate range
      setState(() {
        if (haemoglobin < 9.5) {
          _haemoglobinMessage = autoI8lnGen.translate("HEALTH_ISSUE_5");
        } else if (haemoglobin > 15) {
          _haemoglobinMessage = autoI8lnGen.translate("HEALTH_ISSUE_6");
        } else {
          _haemoglobinMessage = autoI8lnGen.translate("THUMB_UP");
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

    if (_lastPregnancyTiming == autoI8lnGen.translate("LESS_9")) {
      _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_17"));
    }

    if (_hadCesarean) {
      _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_18"));
    }

    if (_hadHeavyBleeding == autoI8lnGen.translate("YES_MESSAGE")) {
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
          SnackBar(content: AutoText('CONNECTION_REQUIRED $e')),
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
          SnackBar(content: AutoText('P_B_S_S')),
        );

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

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoText(
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
          labelText: autoI8lnGen.translate(label),
          hintText: autoI8lnGen.translate(hint??""),
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
            child: AutoText(item),
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
    final lower = option.toLowerCase();
    final yesTranslation = autoI8lnGen.translate("YES_MESSAGE").toLowerCase();

    if (lower == yesTranslation) {
      return Icons.check_circle;
    } else if (lower == autoI8lnGen.translate("NO_2").toLowerCase()) {
      return Icons.cancel;
    } else if (lower == autoI8lnGen.translate("DONT_KNOW_2").toLowerCase() || lower == autoI8lnGen.translate("DONT_REMMEBR").toLowerCase()) {
      return Icons.help;
    } else if (lower == autoI8lnGen.translate("DAILY").toLowerCase()) {
      return Icons.today;
    } else if (lower == autoI8lnGen.translate("WEEKLY").toLowerCase()) {
      return Icons.calendar_view_week;
    } else if (lower == autoI8lnGen.translate("LESS_OFTEN").toLowerCase()) {
      return Icons.calendar_month;
    } else if (lower == autoI8lnGen.translate("BEER").toLowerCase()) {
      return Icons.local_bar;
    } else if (lower == autoI8lnGen.translate("LIQUOR").toLowerCase()) {
      return Icons.wine_bar;
    } else if (lower == autoI8lnGen.translate("BOTH").toLowerCase()) {
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
                      AutoText(
                        'NO_2',
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
        title: AutoText('P_T_B'),
        backgroundColor: Colors.blue[700],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // General Questions Section
              _buildSection('G_Q_1', [
                _buildTextFormField(
                  controller: _schoolingController,
                  label: 'G_Q_2',
                  keyboardType: TextInputType.number,
                ),
                _buildTextFormField(
                  controller: _ageController,
                  label: 'G_Q_3',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      int? age = int.tryParse(value);
                      if (age != null && (age < 20 || age > 39)) {
                        return autoI8lnGen.translate("G_Q_4");
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
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            double? height = double.tryParse(value);
                            if (height != null && height < 150) {
                              return autoI8lnGen.translate("G_Q_6");
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
                        label: 'WEIGHT_KG',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateBMI(),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            double? weight = double.tryParse(value);
                            if (weight != null && weight < 45) {
                              return autoI8lnGen.translate("G_Q_7");
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
                      color: _bmiMessage == autoI8lnGen.translate("THUMB_UP")
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _bmiMessage == autoI8lnGen.translate("THUMB_UP")
                              ? Icons.thumb_up
                              : Icons.warning,
                          color: _bmiMessage == autoI8lnGen.translate("THUMB_UP")
                              ? Colors.green
                              : Colors.orange,
                        ),
                        SizedBox(width: 8),
                        AutoText('BMI ${_bmi!.toStringAsFixed(1)} - $_bmiMessage'),
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
                        label: autoI8lnGen.translate("G_Q_8"),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _checkBloodPressure(),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _diastolicController,
                        label: autoI8lnGen.translate("G_Q_9"),
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
                      color: _bpMessage == autoI8lnGen.translate("THUMB_UP")
                          ? Colors.green[100]
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _bpMessage == autoI8lnGen.translate("THUMB_UP")
                              ? Icons.thumb_up
                              : Icons.warning,
                          color: _bpMessage == autoI8lnGen.translate("THUMB_UP")
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
                  label: autoI8lnGen.translate("HEAMOGOBLIN"),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _checkHaemoglobin(),
                ),
                if (_haemoglobinMessage.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _haemoglobinMessage == autoI8lnGen.translate("THUMB_UP")
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _haemoglobinMessage == autoI8lnGen.translate("THUMB_UP")
                              ? Icons.thumb_up
                              : Icons.warning,
                          color: _haemoglobinMessage == autoI8lnGen.translate("THUMB_UP")
                              ? Colors.green
                              : Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Expanded(child: AutoText(_haemoglobinMessage)),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                _buildTextFormField(
                  controller: _albuminController,
                  label: autoI8lnGen.translate("ALBUMIN_URINE"),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _checkAlbumin(),
                ),
                if (_albuminMessage.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _albuminMessage.contains(autoI8lnGen.translate("NORMAL"))
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _albuminMessage.contains(autoI8lnGen.translate("NORMAL"))
                              ? Icons.thumb_up
                              : Icons.warning,
                          color: _albuminMessage.contains(autoI8lnGen.translate("NORMAL"))
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
                  label: autoI8lnGen.translate("GLUCOSE_URINE"),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _checkGlucose(),
                ),
                if (_glucoseMessage.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _glucoseMessage == autoI8lnGen.translate("NORMAL")
                          ? Colors.green[100]
                          : Colors.orange[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _glucoseMessage == autoI8lnGen.translate("NORMAL")
                              ? Icons.thumb_up
                              : Icons.warning,
                          color: _glucoseMessage == autoI8lnGen.translate("NORMAL")
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
                  label: autoI8lnGen.translate("URINEANALYSIS"),
                  value: _urinalysisResult,
                  items: [autoI8lnGen.translate("NORMAL"),autoI8lnGen.translate("SO_SO"),autoI8lnGen.translate("DANGER"),],
                  onChanged: (value) =>
                      setState(() => _urinalysisResult = value),
                ),
              ]),

              // Lifestyle Questions Section
              _buildSection('G_Q_10', [
                _buildYesNoButton(
                  title: 'G_Q_11',
                  value: _smokesTobacco,
                  onChanged: (value) => setState(() => _smokesTobacco = value),
                ),
                if (_smokesTobacco) ...[
                  _buildTextFormField(
                    controller: _smokingDetailsController,
                    label: 'G_Q_12',
                  ),
                  _buildButtonGroup(
                    title: 'G_Q_13',
                    value: _smokingFrequency,
                    options: [autoI8lnGen.translate("DAILY_2"), autoI8lnGen.translate("WEEKLY_2"), autoI8lnGen.translate("L_O"), ],
                    onChanged: (value) =>
                        setState(() => _smokingFrequency = value!),
                  ),
                ],
                _buildYesNoButton(
                  title: 'D_Y_A',
                  value: _drinksAlcohol,
                  onChanged: (value) => setState(() => _drinksAlcohol = value),
                ),
                if (_drinksAlcohol) ...[
                  _buildButtonGroup(
                    title: 'T_O_A',
                    value: _alcoholType,
                    options: [autoI8lnGen.translate("BEER_2"), autoI8lnGen.translate("LIQUOR_2"), autoI8lnGen.translate("BOTH_2"), ],
                    onChanged: (value) => setState(() => _alcoholType = value!),
                  ),
                  _buildButtonGroup(
                    title: 'HOWT',
                    value: _alcoholFrequency,
                    options: [autoI8lnGen.translate("DAILY_2"), autoI8lnGen.translate("WEEKLY_2"), autoI8lnGen.translate("L_O"), ],
                    onChanged: (value) =>
                        setState(() => _alcoholFrequency = value!),
                  ),
                ],
              ]),

              // Medical History Section

              _buildSection('M_H', [
                _buildYesNoButton(
                  title: 'D_Y_HM',
                  value: _usesHerbalMedicine,
                  onChanged: (value) =>
                      setState(() => _usesHerbalMedicine = value),
                ),
                if (_usesHerbalMedicine) ...[
                  _buildTextFormField(
                    controller: _herbalMedicineController,
                    label: autoI8lnGen.translate("WHB"),
                  ),
                  _buildButtonGroup(
                    title: 'G_Q_13',
                    value: _herbalFrequency,
                    options: [autoI8lnGen.translate("DAILY_2"), autoI8lnGen.translate("WEEKLY_2"), autoI8lnGen.translate("L_O"), ],
                    onChanged: (value) =>
                        setState(() => _herbalFrequency = value!),
                  ),
                ],
                _buildYesNoButton(
                  title: 'D_R_M_M',
                  value: _usesModernMedicine,
                  onChanged: (value) =>
                      setState(() => _usesModernMedicine = value),
                ),
                if (_usesModernMedicine) ...[
                  _buildButtonGroup(
                    title: 'T_Y_P_M',
                    value: _modernMedicineType,
                    options: [autoI8lnGen.translate("W_T_O_P"), autoI8lnGen.translate("W_O_P"), ],
                    onChanged: (value) =>
                        setState(() => _modernMedicineType = value!),
                  ),
                ],
                _buildButtonGroup(
                  title: 'H_TV',
                  value: _hivTestSelf,
                  options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                  onChanged: (value) => setState(() => _hivTestSelf = value!),
                ),
                _buildButtonGroup(
                  title: 'HAS_TESTED_HIV',
                  value: _hivTestPartner,
                  options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                  onChanged: (value) =>
                      setState(() => _hivTestPartner = value!),
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
                  _buildButtonGroup(
                    title: 'P_ALSO_TREATED',
                    value: _partnerARTStatus,
                    options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                    onChanged: (value) =>
                        setState(() => _partnerARTStatus = value!),
                  ),
                ],
                _buildButtonGroup(
                  title: 'G_Q_14',
                  value: _syphilisTest,
                  options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                  onChanged: (value) => setState(() => _syphilisTest = value!),
                ),
                if (_syphilisTest == autoI8lnGen.translate("YES_MESSAGE")) ...[
                  _buildTextFormField(
                    controller: _syphilisTreatmentController,
                    label:autoI8lnGen.translate("G_Q_15"),
                  ),
                ],
                _buildButtonGroup(
                  title: 'G_Q_16',
                  value: _tbTest,
                  options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                  onChanged: (value) => setState(() => _tbTest = value!),
                ),
                _buildButtonGroup(
                  title: 'G_Q_17',
                  value: _tbVaccination,
                  options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                  onChanged: (value) => setState(() => _tbVaccination = value!),
                ),
                if (_tbVaccination == autoI8lnGen.translate("YES_MESSAGE")) ...[
                  _buildTextFormField(
                    controller: _tbVaccinationYearController,
                    label: 'G_Q_18',
                    keyboardType: TextInputType.number,
                  ),
                ],
                _buildYesNoButton(
                  title: 'G_Q_19',
                  value: _onTBTreatment,
                  onChanged: (value) => setState(() => _onTBTreatment = value),
                ),
                if (_onTBTreatment) ...[
                  _buildTextFormField(
                    controller: _tbTreatmentStartController,
                    label: 'G_Q_20',
                    hint: 'MM/YYYY',
                  ),
                  _buildTextFormField(
                    controller: _tbTreatmentStopController,
                    label: 'G_Q_21',
                    hint: 'MM/YYYY',
                  ),
                ],
                _buildYesNoButton(
                  title: 'G_Q_22',
                  value: _currentlyOnTBTreatment,
                  onChanged: (value) =>
                      setState(() => _currentlyOnTBTreatment = value),
                ),
                _buildButtonGroup(
                  title: 'G_Q_23',
                  value: _tetanusVaccinations.toString(),
                  options: ['0', '1', '2', '3', '4'],
                  onChanged: (value) =>
                      setState(() => _tetanusVaccinations = int.parse(value!)),
                ),
                _buildButtonGroup(
                  title: 'G_Q_24',
                  value: _tetanusRecent,
                  options: [autoI8lnGen.translate("L_1_YR"), autoI8lnGen.translate("L_A_YEAR"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                  onChanged: (value) => setState(() => _tetanusRecent = value!),
                ),
                _buildButtonGroup(
                  title: 'TESTED_MALARIA',
                  value: _malariaTest,
                  options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                  onChanged: (value) => setState(() => _malariaTest = value!),
                ),
                if (_malariaTest == autoI8lnGen.translate("YES_MESSAGE")) ...[
                  _buildTextFormField(
                    controller: _malariaTestDateController,
                    label: 'G_Q_25',
                    hint: 'MM/YYYY',
                  ),
                ],
                _buildYesNoButton(
                  title: 'G_Q_26',
                  value: _onAntimalarials,
                  onChanged: (value) =>
                      setState(() => _onAntimalarials = value),
                ),
                if (_onAntimalarials) ...[
                  _buildTextFormField(
                    controller: _antimalarialTreatmentController,
                    label: autoI8lnGen.translate("G_Q_27"),
                  ),
                ],
                _buildButtonGroup(
                  title: autoI8lnGen.translate("G_Q_28"),
                  value: _antimalarialRecent,
                  options: [autoI8lnGen.translate("G_Q_29"), autoI8lnGen.translate("G_Q_30"), autoI8lnGen.translate("G_Q_31"), ],
                  onChanged: (value) =>
                      setState(() => _antimalarialRecent = value!),
                ),
                _buildButtonGroup(
                  title: 'G_Q_32',
                  value: _wormTest,
                  options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                  onChanged: (value) => setState(() => _wormTest = value!),
                ),
                _buildButtonGroup(
                  title: 'G_Q_33',
                  value: _wormMedicineRecent,
                  options: [autoI8lnGen.translate("G_Q_34"), autoI8lnGen.translate("G_Q_35"), autoI8lnGen.translate("G_Q_36"), ],
                  onChanged: (value) =>
                      setState(() => _wormMedicineRecent = value!),
                ),
                _buildYesNoButton(
                  title: 'G_Q_37',
                  value: _hasOtherIssues,
                  onChanged: (value) => setState(() => _hasOtherIssues = value),
                ),
                if (_hasOtherIssues) ...[
                  _buildTextFormField(
                    controller: _disabilityController,
                    label: autoI8lnGen.translate('G_Q_38'),
                    hint: autoI8lnGen.translate('G_Q_39'),
                  ),
                ],
              ]),

              // Pregnancy Related Questions Section

              _buildSection("G_Q_40", [
                _buildTextFormField(
                  controller: _lastMenstrualPeriodController,
                  label: autoI8lnGen.translate("G_Q_41"),
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
                        AutoText(
                          'Y_B_E ${_expectedDeliveryDate!.day}/${_expectedDeliveryDate!.month}/${_expectedDeliveryDate!.year}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                ],
                _buildYesNoButton(
                  title: 'G_Q_42',
                  value: _isFirstPregnancy,
                  onChanged: (value) =>
                      setState(() => _isFirstPregnancy = value),
                ),
                _buildTextFormField(
                  controller: _miscarriagesController,
                  label: autoI8lnGen.translate("G_Q_43"),
                  keyboardType: TextInputType.number,
                  hint: autoI8lnGen.translate("G_Q_44"),
                ),
                if (!_isFirstPregnancy) ...[
                  _buildTextFormField(
                    controller: _liveBirthsController,
                    label: autoI8lnGen.translate("G_Q_45"),
                    keyboardType: TextInputType.number,
                    hint: autoI8lnGen.translate("G_Q_44"),
                  ),
                  _buildTextFormField(
                    controller: _previousPregnanciesController,
                    label: autoI8lnGen.translate("G_Q_46"),
                    keyboardType: TextInputType.number,
                    hint: autoI8lnGen.translate("G_Q_44"),
                  ),
                  _buildButtonGroup(
                    title: autoI8lnGen.translate("G_Q_47"),
                    value: _lastPregnancyTiming,
                    options: [autoI8lnGen.translate("G_Q_48"), autoI8lnGen.translate("G_Q_49"), autoI8lnGen.translate("G_Q_50")],
                    onChanged: (value) =>
                        setState(() => _lastPregnancyTiming = value!),
                  ),
                  _buildTextFormField(
                    controller: _stillbornController,
                    label: autoI8lnGen.translate("G_Q_51"),
                    keyboardType: TextInputType.number,
                    hint: autoI8lnGen.translate("G_Q_44"),
                  ),
                  _buildYesNoButton(
                    title: "G_Q_52",
                    value: _hadCesarean,
                    onChanged: (value) => setState(() => _hadCesarean = value),
                  ),
                  if (_hadCesarean) ...[
                    _buildTextFormField(
                      controller: _cesareanCountController,
                      label: autoI8lnGen.translate("G_Q_53"),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                  _buildButtonGroup(
                    title: 'G_Q_54',
                    value: _hadForcepsVacuum,
                    options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                    onChanged: (value) =>
                        setState(() => _hadForcepsVacuum = value!),
                  ),
                  _buildButtonGroup(
                    title: 'G_Q_55',
                    value: _hadHeavyBleeding,
                    options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                    onChanged: (value) =>
                        setState(() => _hadHeavyBleeding = value!),
                  ),
                  _buildButtonGroup(
                    title: 'G_Q_56',
                    value: _hadTears,
                    options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                    onChanged: (value) => setState(() => _hadTears = value!),
                  ),
                  if (_hadTears == autoI8lnGen.translate("YES_MESSAGE")) ...[
                    _buildButtonGroup(
                      title: 'G_Q_57',
                      value: _tearsNeedStitching,
                      options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                      onChanged: (value) =>
                          setState(() => _tearsNeedStitching = value!),
                    ),
                    _buildButtonGroup(
                      title: 'G_Q_58',
                      value: _tearsHealedNaturally,
                      options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                      onChanged: (value) =>
                          setState(() => _tearsHealedNaturally = value!),
                    ),
                    _buildButtonGroup(
                      title: 'G_Q_59',
                      value: _tearsStillBothering,
                      options: [autoI8lnGen.translate("YES_MESSAGE"), autoI8lnGen.translate("NO_2"), autoI8lnGen.translate("D_ONT_KNOW"), ],
                      onChanged: (value) =>
                          setState(() => _tearsStillBothering = value!),
                    ),
                  ],
                  _buildTextFormField(
                    controller: _deliveryRemarksController,
                    label: autoI8lnGen.translate("G_Q_60"),
                    hint: autoI8lnGen.translate("G_Q_61"),
                  ),
                ],
              ]),

              // Alerts Section
              if (_alerts.isNotEmpty) ...[
                _buildSection('G_Q_62', [
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
                            AutoText(
                              'G_Q_63',
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
                                  child: AutoText('• $alert'),
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
                    AutoText(
                      'G_Q_64',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    AutoText(
                        'G_Q_65'),
                    AutoText(
                        'G_Q_66'),
                    AutoText(
                        'G_Q_67'),
                    AutoText(
                        'G_Q_68'),
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
            child: AutoText(
              'SUBMIT',
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
