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
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _pcvController = TextEditingController();
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
  String? _educationLevel;
  static const List<String> _educationLevelOptions = [
    'No formal education',
    'Primary',
    'Secondary',
    'Tertiary',
    'Postgraduate',
  ];

  String? _bloodGroup;
  static const List<String> _bloodGroupOptions = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  String? _genotype;
  static const List<String> _genotypeOptions = [
    'AA',
    'AS',
    'SS',
    'SC',
    'AC',
  ];

  bool? _registeredForANC;

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
  String _pcvMessage = '';
  String _albuminMessage = '';
  String _glucoseMessage = '';
  DateTime? _expectedDeliveryDate;
  List<String> _alerts = [];

  // UI State
  bool _isEditMode = false;
  Set<String> _expandedSections = {};

  // ─────────────────────────────────────────────────────────────────────────
  // GATE: show professional-presence dialog on first entry
  // ─────────────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadExistingData();
    // Show the gate dialog after the first frame so context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showProfessionalGateDialog();
    });
  }

  /// Full-screen bottom-sheet style dialog that warns the user this form
  /// has sections requiring a health professional. It cannot be dismissed
  /// by tapping outside — the user must make a deliberate choice.
  void _showProfessionalGateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // force a deliberate choice
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + Title row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.medical_services_outlined,
                          color: Colors.blue[700], size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AutoText(
                        'PROF_GATE_TITLE',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Body explanation
                AutoText(
                  'PROF_GATE_BODY',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 16),

                // Section labels: what you can vs. cannot fill alone
                _buildGateSectionRow(
                  icon: Icons.person_outline,
                  color: Colors.green[700]!,
                  labelKey: 'GATE_SELF_LABEL',
                  // "You can fill these yourself:"
                  examplesKey: 'GATE_SELF_EXAMPLES',
                  // "Age, height, weight, education, pregnancy history,
                  //  lifestyle habits"
                ),
                const SizedBox(height: 8),
                _buildGateSectionRow(
                  icon: Icons.local_hospital_outlined,
                  color: Colors.red[700]!,
                  labelKey: 'GATE_PROF_LABEL',
                  // "These need a health professional:"
                  examplesKey: 'GATE_PROF_EXAMPLES',
                  // "Blood pressure, PCV (blood test), albumin, glucose,
                  //  urinalysis, HIV/syphilis/TB/malaria tests"
                ),

                const SizedBox(height: 16),

                // Tip about the ⓘ icons
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[300]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.tips_and_updates_outlined,
                          color: Colors.amber[800], size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AutoText(
                          'PROF_GATE_WARN',
                          style:
                              TextStyle(fontSize: 12, color: Colors.amber[900]),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // CTA buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.check_circle_outline),
                    label: AutoText('PROF_GATE_HAVE_PROF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop(); // close dialog
                      Navigator.of(context).pop(); // leave screen
                    },
                    icon: const Icon(Icons.arrow_back_outlined),
                    label: AutoText('PROF_GATE_COME_BACK'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[800],
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Small row used inside the gate dialog to list self-fill vs. pro-only
  /// sections.
  Widget _buildGateSectionRow({
    required IconData icon,
    required Color color,
    required String labelKey,
    required String examplesKey,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, height: 1.4),
              children: [
                TextSpan(
                  text: '${autoI8lnGen.translate(labelKey)} ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                TextSpan(
                  text: autoI8lnGen.translate(examplesKey),
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELP BOTTOM SHEET
  // Shown when the user taps a ⓘ icon next to a medical field.
  // ─────────────────────────────────────────────────────────────────────────

  void _showFieldHelp({
    required String titleKey,
    required String bodyKey,
    required String whoKey,
    required bool isProOnly,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              AutoText(
                titleKey,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Body
              AutoText(
                bodyKey,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey[800], height: 1.5),
              ),
              const SizedBox(height: 16),

              // "Who fills this in" badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isProOnly ? Colors.red[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isProOnly ? Colors.red[200]! : Colors.green[200]!,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isProOnly
                          ? Icons.local_hospital_outlined
                          : Icons.person_outline,
                      color: isProOnly ? Colors.red[700] : Colors.green[700],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AutoText(
                        whoKey,
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isProOnly ? Colors.red[800] : Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: AutoText('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper: field label row with optional ⓘ help icon
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFieldLabelWithHelp({
    required String labelKey,
    required String titleKey,
    required String bodyKey,
    required String whoKey,
    required bool isProOnly,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: AutoText(
              labelKey,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          GestureDetector(
            onTap: () => _showFieldHelp(
              titleKey: titleKey,
              bodyKey: bodyKey,
              whoKey: whoKey,
              isProOnly: isProOnly,
            ),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isProOnly ? Colors.red[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isProOnly
                        ? Icons.local_hospital_outlined
                        : Icons.info_outline,
                    size: 14,
                    color: isProOnly ? Colors.red[700] : Colors.blue[700],
                  ),
                  const SizedBox(width: 3),
                  Text(
                    isProOnly
                        ? autoI8lnGen.translate('PROF_ONLY_TAG')
                        // e.g. "Clinic only"
                        : autoI8lnGen.translate('LEARN_MORE'),
                    // e.g. "Learn more"
                    style: TextStyle(
                      fontSize: 11,
                      color: isProOnly ? Colors.red[700] : Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Pro-only banner shown once above the first medical-only field in a section
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildProOnlyBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_hospital_outlined, color: Colors.red[700], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: AutoText(
              'PRO_ONLY_BANNER',
              // e.g. "The fields below should be completed by or with
              //       the help of a health professional."
              style: TextStyle(fontSize: 13, color: Colors.red[800]),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Data loading
  // ─────────────────────────────────────────────────────────────────────────

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
          _educationLevel = data['education_level'];
          _bloodGroup = data['blood_group'];
          _genotype = data['genotype'];
          _registeredForANC = data['registered_for_anc'];
          _ageController.text = data['age']?.toString() ?? '';
          _heightController.text = data['height']?.toString() ?? '';
          _weightController.text = data['weight']?.toString() ?? '';
          _systolicController.text = data['systolic_bp']?.toString() ?? '';
          _diastolicController.text = data['diastolic_bp']?.toString() ?? '';
          _pcvController.text =
              data['pcv']?.toString() ?? data['haemoglobin']?.toString() ?? '';
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

          _calculateBMI();
          _checkBloodPressure();
          _checkPCV();
          _checkAlbumin();
          _checkGlucose();
          _calculateExpectedDeliveryDate();
        });
      }
    } catch (e) {
      print('Error loading existing data: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Calculations & checks (unchanged logic)
  // ─────────────────────────────────────────────────────────────────────────

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
        if (systolic >= 160 || diastolic >= 100) {
          _bpMessage = autoI8lnGen.translate("HEALTH_ISSUE_3");
          _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_4"));
        } else if (systolic >= 140 || diastolic >= 90) {
          _bpMessage = autoI8lnGen.translate("HEALTH_ISSUE_2");
        } else if (systolic >= 130 || diastolic > 80) {
          _bpMessage = autoI8lnGen.translate("HEALTH_ISSUE_1");
        } else if (systolic >= 120 && diastolic <= 80) {
          _bpMessage = autoI8lnGen.translate("E_C_D");
        } else if (systolic >= 90 && diastolic >= 60) {
          _bpMessage = autoI8lnGen.translate("THUMB_UP");
        }
      });
    }
  }

  void _checkPCV() {
    final pcv = double.tryParse(_pcvController.text);
    if (pcv != null) {
      setState(() {
        if (pcv < 30) {
          _pcvMessage = autoI8lnGen.translate("HEALTH_ISSUE_5");
        } else if (pcv >= 30 && pcv < 33) {
          _pcvMessage = autoI8lnGen.translate("HEALTH_ISSUE_5");
        } else if (pcv >= 33 && pcv <= 44) {
          _pcvMessage = autoI8lnGen.translate("HEALTH_ISSUE_7");
        } else {
          _pcvMessage = autoI8lnGen.translate("HEALTH_ISSUE_6");
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
          _glucoseMessage = autoI8lnGen.translate("HEALTH_ISSUE_12");
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
            _expectedDeliveryDate = lmp.add(const Duration(days: 280));
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
    if (_genotype == 'SS' || _genotype == 'SC') {
      _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_SICKLE_CELL"));
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
    int totalFields = 24;
    int filledFields = 0;
    if (_educationLevel != null) filledFields++;
    if (_bloodGroup != null) filledFields++;
    if (_genotype != null) filledFields++;
    if (_registeredForANC != null) filledFields++;
    if (_ageController.text.isNotEmpty) filledFields++;
    if (_heightController.text.isNotEmpty) filledFields++;
    if (_weightController.text.isNotEmpty) filledFields++;
    if (_systolicController.text.isNotEmpty) filledFields++;
    if (_diastolicController.text.isNotEmpty) filledFields++;
    if (_pcvController.text.isNotEmpty) filledFields++;
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
    if (_educationLevel == null)
      missing.add(autoI8lnGen.translate("EDU_LEVEL"));
    if (_bloodGroup == null) missing.add(autoI8lnGen.translate("BLOOD_GROUP"));
    if (_genotype == null) missing.add(autoI8lnGen.translate("GENOTYPE"));
    if (_registeredForANC == null)
      missing.add(autoI8lnGen.translate("ANC_REG"));
    if (_ageController.text.isEmpty) missing.add(autoI8lnGen.translate("AGE"));
    if (_heightController.text.isEmpty) missing.add(autoI8lnGen.translate("H"));
    if (_weightController.text.isEmpty) missing.add(autoI8lnGen.translate("W"));
    if (_systolicController.text.isEmpty)
      missing.add(autoI8lnGen.translate("BLOOD_PRESSURE"));
    if (_pcvController.text.isEmpty)
      missing.add(autoI8lnGen.translate("PCV_T"));
    if (_urinalysisResult == null)
      missing.add(autoI8lnGen.translate("URINEANALYSIS"));
    if (_hivTestSelf == null) missing.add(autoI8lnGen.translate("HI_T_S"));
    if (_syphilisTest == null) missing.add(autoI8lnGen.translate("S_T_E"));
    if (_tbTest == null) missing.add(autoI8lnGen.translate("TB_TEST"));
    if (_malariaTest == null) missing.add(autoI8lnGen.translate("M_T_E"));
    if (_lastMenstrualPeriodController.text.isEmpty)
      missing.add(autoI8lnGen.translate("L_M_P"));
    if (_tetanusVaccinations == 0) missing.add(autoI8lnGen.translate("T_V_A"));
    return missing;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Save
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      _checkHighRiskFactors();

      List<String> providerIds = [];
      try {
        final connectionQuery = await _firestore
            .collection('allowed_to_chat')
            .where('requesterId', isEqualTo: widget.patientId)
            .get();

        if (connectionQuery.docs.isEmpty) {
          throw Exception(
              'This patient is not connected to a health provider.');
        }

        providerIds = connectionQuery.docs
            .map((doc) => doc['recipientId'] as String)
            .toList();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: AutoText('CONNECTION_REQUIRED $e')),
        );
        return;
      }

      Map<String, dynamic> data = {
        'education_level': _educationLevel,
        'blood_group': _bloodGroup,
        'genotype': _genotype,
        'registered_for_anc': _registeredForANC,
        'age': int.tryParse(_ageController.text),
        'height': double.tryParse(_heightController.text),
        'weight': double.tryParse(_weightController.text),
        'bmi': _bmi,
        'bmi_message': _bmiMessage,
        'systolic_bp': int.tryParse(_systolicController.text),
        'diastolic_bp': int.tryParse(_diastolicController.text),
        'bp_message': _bpMessage,
        'pcv': double.tryParse(_pcvController.text),
        'pcv_message': _pcvMessage,
        'haemoglobin': null,
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
        'providerIds': providerIds,
        'patientId': widget.patientId,
      };

      try {
        await _firestore
            .collection('patients')
            .doc(widget.patientId)
            .collection('background')
            .doc('patient_background')
            .set(data, SetOptions(merge: true));

        for (final providerId in providerIds) {
          await _firestore
              .collection('health_provider_data')
              .doc(providerId)
              .collection('patient_backgrounds')
              .doc(widget.patientId)
              .set(data, SetOptions(merge: true));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Patient background saved successfully')),
        );

        setState(() => _isEditMode = false);

        if (_alerts.isNotEmpty) _showAlertsDialog();
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
              const SizedBox(height: 10),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Overview card
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildOverviewCard() {
    final completionPercentage = _getCompletionPercentage();
    final missingFields = _getMissingFields();

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AutoText(
                  'B_S_UM',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                const SizedBox(width: 12),
                AutoText(
                  '$completionPercentage% COMPLETE',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (missingFields.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: AutoText(
                            'STN (${missingFields.length} ITEMS):',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 8),
                        AutoText(
                          'STN (${missingFields.length}) ITEMS:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: missingFields
                          .map((field) => Chip(
                                label: Text(field,
                                    style: const TextStyle(fontSize: 12)),
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: AutoText(
                            'H_AL (${_alerts.length}):',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._alerts
                        .map((alert) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('• $alert',
                                  style: const TextStyle(fontSize: 13)),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Section builder
  // ─────────────────────────────────────────────────────────────────────────

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
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: AutoText(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                const SizedBox(width: 8),
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
              padding: const EdgeInsets.all(16),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: ListTile(
        dense: true,
        title: AutoText(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: AutoText(
          value,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
        trailing: trailing,
      ),
    );
  }

  String _getDisplayValue(dynamic value, String defaultText) {
    if (value == null || value.toString().isEmpty) return defaultText;
    return value.toString();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Form field builders (unchanged from original except where noted)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? suffixText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: autoI8lnGen.translate(label),
          hintText: autoI8lnGen.translate(hint ?? ""),
          border: const OutlineInputBorder(),
          enabled: _isEditMode,
          suffixText: suffixText,
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
    String? helperText,
  }) {
    String? safeValue = (value != null && items.contains(value)) ? value : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: autoI8lnGen.translate(label),
          border: const OutlineInputBorder(),
          helperText: helperText,
          helperMaxLines: 2,
        ),
        value: safeValue,
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

  Widget _buildChipSelector({
    required String title,
    required String? value,
    required List<String> options,
    required void Function(String?) onChanged,
    String? subtitle,
    Color? selectedColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoText(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = value == option;
              return ChoiceChip(
                label: Text(
                  option,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                selected: isSelected,
                onSelected: _isEditMode
                    ? (_) => onChanged(isSelected ? null : option)
                    : null,
                selectedColor: selectedColor ?? Colors.blue[700],
                backgroundColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected
                        ? (selectedColor ?? Colors.blue[700])!
                        : Colors.grey[300]!,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
        ],
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
        AutoText(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          children: options.map((option) {
            final isSelected = value == option;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: _isEditMode ? () => onChanged(option) : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                        const SizedBox(height: 8),
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
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _getIconForOption(String option) {
    String lowerOption = option.toLowerCase();
    String yesMessage = autoI8lnGen.translate("YES_MESSAGE").toLowerCase();
    if (lowerOption == yesMessage) return Icons.check_circle;
    if (lowerOption == autoI8lnGen.translate("NO_MESSAGE")) return Icons.cancel;
    if (lowerOption == autoI8lnGen.translate("DONT_KNOW_2") ||
        lowerOption == autoI8lnGen.translate("DONT_REMMEBR")) return Icons.help;
    if (lowerOption == autoI8lnGen.translate("DAILY")) return Icons.today;
    if (lowerOption == autoI8lnGen.translate("WEEKLY"))
      return Icons.calendar_view_week;
    if (lowerOption == autoI8lnGen.translate("LESS_OFTEN"))
      return Icons.calendar_month;
    if (lowerOption == autoI8lnGen.translate("BEER")) return Icons.local_bar;
    if (lowerOption == autoI8lnGen.translate("LIQUOR")) return Icons.wine_bar;
    if (lowerOption == autoI8lnGen.translate("BOTH")) return Icons.restaurant;
    return Icons.circle;
  }

  Widget _buildYesNoButton({
    required String title,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoText(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _isEditMode ? () => onChanged(true) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                      Icon(Icons.check_circle,
                          color: value ? Colors.white : Colors.grey[600],
                          size: 28),
                      const SizedBox(height: 8),
                      AutoText('YES_MESSAGE',
                          style: TextStyle(
                            color: value ? Colors.white : Colors.black87,
                            fontWeight:
                                value ? FontWeight.w600 : FontWeight.normal,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _isEditMode ? () => onChanged(false) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                      Icon(Icons.cancel,
                          color: !value ? Colors.white : Colors.grey[600],
                          size: 28),
                      const SizedBox(height: 8),
                      AutoText('NO_MESSAGE',
                          style: TextStyle(
                            color: !value ? Colors.white : Colors.black87,
                            fontWeight:
                                !value ? FontWeight.w600 : FontWeight.normal,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNullableYesNoButton({
    required String title,
    required bool? value,
    required void Function(bool) onChanged,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoText(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _isEditMode ? () => onChanged(true) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: value == true ? Colors.green[600] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: value == true
                          ? Colors.green[600]!
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle,
                          color:
                              value == true ? Colors.white : Colors.grey[600],
                          size: 28),
                      const SizedBox(height: 8),
                      AutoText('YES_MESSAGE',
                          style: TextStyle(
                            color:
                                value == true ? Colors.white : Colors.black87,
                            fontWeight: value == true
                                ? FontWeight.w600
                                : FontWeight.normal,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: _isEditMode ? () => onChanged(false) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: value == false ? Colors.red[600] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          value == false ? Colors.red[600]! : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cancel,
                          color:
                              value == false ? Colors.white : Colors.grey[600],
                          size: 28),
                      const SizedBox(height: 8),
                      AutoText('NO_MESSAGE',
                          style: TextStyle(
                            color:
                                value == false ? Colors.white : Colors.black87,
                            fontWeight: value == false
                                ? FontWeight.w600
                                : FontWeight.normal,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHealthIndicator(
      String title, String value, String message, IconData icon, Color color) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoText('$title $value',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (message.isNotEmpty)
                  AutoText(message,
                      style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenotypeBadge(String genotype) {
    final isHighRisk = genotype == 'SS' || genotype == 'SC';
    final isMediumRisk = genotype == 'AS' || genotype == 'AC';
    final color = isHighRisk
        ? Colors.red[700]!
        : isMediumRisk
            ? Colors.orange[700]!
            : Colors.green[700]!;
    final bgColor = isHighRisk
        ? Colors.red[50]!
        : isMediumRisk
            ? Colors.orange[50]!
            : Colors.green[50]!;
    final label = isHighRisk
        ? 'High risk — refer to specialist'
        : isMediumRisk
            ? 'Carrier — partner testing advised'
            : 'Low risk';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isHighRisk ? Icons.warning : Icons.info_outline,
              color: color, size: 14),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoText('P_T_B', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[700],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildOverviewCard(),

              // Health Indicators Summary
              if (_bmi != null ||
                  _bpMessage.isNotEmpty ||
                  _pcvMessage.isNotEmpty)
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoText('HID',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
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
                            'BLOOD_PRESSURE_2',
                            '${_systolicController.text}/${_diastolicController.text}',
                            _bpMessage,
                            Icons.favorite,
                            _bpMessage == autoI8lnGen.translate("THUMB_UP")
                                ? Colors.green
                                : Colors.red,
                          ),
                        if (_pcvMessage.isNotEmpty)
                          _buildHealthIndicator(
                            'PCV_2',
                            '${_pcvController.text}%',
                            _pcvMessage,
                            Icons.water_drop,
                            _pcvMessage ==
                                    autoI8lnGen.translate("HEALTH_ISSUE_7")
                                ? Colors.green
                                : Colors.orange,
                          ),
                        if (_expectedDeliveryDate != null)
                          _buildHealthIndicator(
                            'E_D_E_2',
                            '${_expectedDeliveryDate!.day}/${_expectedDeliveryDate!.month}/${_expectedDeliveryDate!.year}',
                            '',
                            Icons.baby_changing_station,
                            Colors.pink,
                          ),
                      ],
                    ),
                  ),
                ),

              // ══════════════════════════════════════════════════════════
              // SECTION 1: General / Personal Information
              // ══════════════════════════════════════════════════════════
              _buildExpandableSection(
                title: 'GIN',
                sectionKey: 'GENERAL_3',
                filledCount: [
                  _educationLevel,
                  _bloodGroup,
                  _genotype,
                  _registeredForANC?.toString(),
                  _ageController.text.isNotEmpty ? 'y' : null,
                  _heightController.text.isNotEmpty ? 'y' : null,
                  _weightController.text.isNotEmpty ? 'y' : null,
                  _systolicController.text.isNotEmpty ? 'y' : null,
                  _pcvController.text.isNotEmpty ? 'y' : null,
                  _urinalysisResult,
                ].where((x) => x != null && x.toString().isNotEmpty).length,
                totalCount: 10,
                children: _isEditMode
                    ? [
                        // ── Self-fill fields ───────────────────────────
                        _buildDropdownFormField(
                          label: 'EDU_LEVEL',
                          value: _educationLevel,
                          items: _educationLevelOptions,
                          onChanged: (value) =>
                              setState(() => _educationLevel = value),
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
                            const SizedBox(width: 16),
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

                        // ── Pro-only section banner ────────────────────
                        _buildProOnlyBanner(),

                        // Blood Pressure — pro only
                        _buildFieldLabelWithHelp(
                          labelKey: 'G_Q_8_LABEL',
                          // e.g. "Blood Pressure"
                          titleKey: 'HELP_BP_TITLE',
                          bodyKey: 'HELP_BP_BODY',
                          whoKey: 'HELP_BP_WHO',
                          isProOnly: true,
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
                            const SizedBox(width: 16),
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

                        // PCV — pro only
                        _buildFieldLabelWithHelp(
                          labelKey: 'PCV_2',
                          titleKey: 'HELP_PCV_TITLE',
                          bodyKey: 'HELP_PCV_BODY',
                          whoKey: 'HELP_PCV_WHO',
                          isProOnly: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _pcvController,
                                decoration: InputDecoration(
                                  labelText: autoI8lnGen.translate("PCV_LABEL"),
                                  hintText: autoI8lnGen.translate("PCV_HINT"),
                                  border: const OutlineInputBorder(),
                                  enabled: _isEditMode,
                                  suffixText: '%',
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _checkPCV(),
                                readOnly: !_isEditMode,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info_outline,
                                        size: 16, color: Colors.blue[700]),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: AutoText(
                                        'PCV_EXPLAINER',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue[800]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Albumin — pro only
                        _buildFieldLabelWithHelp(
                          labelKey: 'ALBUMIN_URINE',
                          titleKey: 'HELP_ALBUMIN_TITLE',
                          bodyKey: 'HELP_ALBUMIN_BODY',
                          whoKey: 'HELP_ALBUMIN_WHO',
                          isProOnly: true,
                        ),
                        _buildTextFormField(
                          controller: _albuminController,
                          label: 'ALBUMIN_URINE',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _checkAlbumin(),
                        ),

                        // Glucose — pro only
                        _buildFieldLabelWithHelp(
                          labelKey: 'GLUCOSE_URINE',
                          titleKey: 'HELP_GLUCOSE_TITLE',
                          bodyKey: 'HELP_GLUCOSE_BODY',
                          whoKey: 'HELP_GLUCOSE_WHO',
                          isProOnly: true,
                        ),
                        _buildTextFormField(
                          controller: _glucoseController,
                          label: 'GLUCOSE_URINE',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => _checkGlucose(),
                        ),

                        // Urinalysis — pro only
                        _buildFieldLabelWithHelp(
                          labelKey: 'URINEANALYSIS',
                          titleKey: 'HELP_URINALYSIS_TITLE',
                          bodyKey: 'HELP_URINALYSIS_BODY',
                          whoKey: 'HELP_URINALYSIS_WHO',
                          isProOnly: true,
                        ),
                        _buildDropdownFormField(
                          label: 'URINEANALYSIS',
                          value: _urinalysisResult,
                          items: [
                            autoI8lnGen.translate("NORMAL"),
                            autoI8lnGen.translate("SO_SO"),
                            autoI8lnGen.translate("DANGER"),
                          ],
                          onChanged: (value) =>
                              setState(() => _urinalysisResult = value),
                        ),

                        // Blood Group — ideally confirmed by pro
                        _buildFieldLabelWithHelp(
                          labelKey: 'BLOOD_GROUP_Q',
                          titleKey: 'HELP_BLOODGROUP_TITLE',
                          bodyKey: 'HELP_BLOODGROUP_BODY',
                          whoKey: 'HELP_BLOODGROUP_WHO',
                          isProOnly: false,
                        ),
                        _buildChipSelector(
                          title: autoI8lnGen.translate('BLOOD_GROUP_Q'),
                          subtitle:
                              autoI8lnGen.translate('BLOOD_GROUP_SUBTITLE'),
                          value: _bloodGroup,
                          options: _bloodGroupOptions,
                          onChanged: (value) =>
                              setState(() => _bloodGroup = value),
                          selectedColor: Colors.red[700],
                        ),

                        // Genotype — ideally confirmed by pro
                        _buildFieldLabelWithHelp(
                          labelKey: 'GENOTYPE_Q',
                          titleKey: 'HELP_GENOTYPE_TITLE',
                          bodyKey: 'HELP_GENOTYPE_BODY',
                          whoKey: 'HELP_GENOTYPE_WHO',
                          isProOnly: false,
                        ),
                        _buildChipSelector(
                          title: autoI8lnGen.translate('GENOTYPE_Q'),
                          subtitle: autoI8lnGen.translate('GENOTYPE_SUBTITLE'),
                          value: _genotype,
                          options: _genotypeOptions,
                          onChanged: (value) =>
                              setState(() => _genotype = value),
                          selectedColor: Colors.purple[700],
                        ),

                        // ANC Registration — self-fill
                        _buildNullableYesNoButton(
                          title: autoI8lnGen.translate('ANC_REG_Q'),
                          subtitle: autoI8lnGen.translate('ANC_REG_SUBTITLE'),
                          value: _registeredForANC,
                          onChanged: (value) =>
                              setState(() => _registeredForANC = value),
                        ),
                        if (_registeredForANC == false)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.campaign, color: Colors.orange[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: AutoText(
                                    'ANC_PROMPT',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.orange[900]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ]
                    : [
                        _buildSummaryItem(
                          label: autoI8lnGen.translate('EDU_LEVEL'),
                          value: _getDisplayValue(_educationLevel,
                              autoI8lnGen.translate("NOT_SPECIFIED")),
                        ),
                        _buildSummaryItem(
                          label: 'AGE',
                          value: _getDisplayValue(_ageController.text,
                              autoI8lnGen.translate("NOT_SPECIFIED")),
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
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        _buildSummaryItem(
                          label: 'BLOOD_PRESSURE',
                          value: _systolicController.text.isNotEmpty &&
                                  _diastolicController.text.isNotEmpty
                              ? '${_systolicController.text}/${_diastolicController.text}'
                              : autoI8lnGen.translate("NOT_SPECIFIED"),
                        ),
                        _buildSummaryItem(
                          label: autoI8lnGen.translate('PCV_SHORT'),
                          value: _pcvController.text.isNotEmpty
                              ? '${_pcvController.text}%'
                              : autoI8lnGen.translate("NOT_SPECIFIED"),
                        ),
                        _buildSummaryItem(
                          label: 'URINEANALYSIS',
                          value: _getDisplayValue(_urinalysisResult,
                              autoI8lnGen.translate("NOT_SPECIFIED")),
                        ),
                        // Blood Group summary
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[50],
                          ),
                          child: ListTile(
                            dense: true,
                            title: AutoText(
                              autoI8lnGen.translate('BLOOD_GROUP'),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            subtitle: AutoText(
                              _getDisplayValue(_bloodGroup,
                                  autoI8lnGen.translate("NOT_SPECIFIED")),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black87),
                            ),
                            trailing: _bloodGroup != null
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: Colors.red[200]!),
                                    ),
                                    child: Text(
                                      _bloodGroup!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red[800]),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        // Genotype summary
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[50],
                          ),
                          child: ListTile(
                            dense: true,
                            title: AutoText(
                              autoI8lnGen.translate('GENOTYPE'),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoText(
                                  _getDisplayValue(_genotype,
                                      autoI8lnGen.translate("NOT_SPECIFIED")),
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                                if (_genotype != null) ...[
                                  const SizedBox(height: 4),
                                  _buildGenotypeBadge(_genotype!),
                                ],
                              ],
                            ),
                          ),
                        ),
                        _buildSummaryItem(
                          label: autoI8lnGen.translate('ANC_REG'),
                          value: _registeredForANC == null
                              ? autoI8lnGen.translate("NOT_SPECIFIED")
                              : _registeredForANC!
                                  ? autoI8lnGen.translate('YES_MESSAGE')
                                  : autoI8lnGen.translate('NO_MESSAGE'),
                        ),
                      ],
              ),

              // ══════════════════════════════════════════════════════════
              // SECTION 2: Lifestyle
              // ══════════════════════════════════════════════════════════
              _buildExpandableSection(
                title: 'LIFESTYLE',
                sectionKey: 'LIFESTYLE'.toLowerCase(),
                filledCount: [
                  _smokesTobacco ? autoI8lnGen.translate("YES_MESSAGE") : '',
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
                            options: [
                              autoI8lnGen.translate("DAILY_2"),
                              autoI8lnGen.translate("WEEKLY_2"),
                              autoI8lnGen.translate("L_O"),
                            ],
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
                            options: [
                              autoI8lnGen.translate("DAILY_2"),
                              autoI8lnGen.translate("WEEKLY_2"),
                              autoI8lnGen.translate("L_O"),
                            ],
                            onChanged: (value) =>
                                setState(() => _alcoholFrequency = value!),
                          ),
                        ],
                      ]
                    : [
                        _buildSummaryItem(
                          label: 'T_USE',
                          value: _smokesTobacco
                              ? autoI8lnGen.translate(
                                  'YES_MESSAGE${_smokingFrequency != null ? " - $_smokingFrequency" : ""}')
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

              // ══════════════════════════════════════════════════════════
              // SECTION 3: Medical History
              // ══════════════════════════════════════════════════════════
              _buildExpandableSection(
                title: 'M_H',
                sectionKey: 'MDCL',
                filledCount: [
                  _hivTestSelf,
                  _syphilisTest,
                  _tbTest,
                  _malariaTest,
                  _wormTest,
                  _tetanusVaccinations > 0
                      ? autoI8lnGen.translate("YES_MESSAGE")
                      : null,
                ].where((x) => x != null && x.toString().isNotEmpty).length,
                totalCount: 6,
                children: _isEditMode
                    ? [
                        // Herbal medicine — self-fill
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
                            options: [
                              autoI8lnGen.translate("DAILY_2"),
                              autoI8lnGen.translate("WEEKLY_2"),
                              autoI8lnGen.translate("L_O"),
                            ],
                            onChanged: (value) =>
                                setState(() => _herbalFrequency = value!),
                          ),
                        ],

                        // ── Pro-only section banner ──────────────────
                        _buildProOnlyBanner(),

                        // HIV — with help
                        _buildFieldLabelWithHelp(
                          labelKey: 'HI_T_S',
                          titleKey: 'HELP_HIV_TITLE',
                          bodyKey: 'HELP_HIV_BODY',
                          whoKey: 'HELP_HIV_WHO',
                          isProOnly: false,
                        ),
                        _buildButtonGroup(
                          title: 'H_TV',
                          value: _hivTestSelf,
                          options: [
                            autoI8lnGen.translate("YES_MESSAGE"),
                            autoI8lnGen.translate("NO_MESSAGE"),
                            autoI8lnGen.translate("D_ONT_KNOW"),
                          ],
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

                        // Syphilis — with help
                        _buildFieldLabelWithHelp(
                          labelKey: 'S_T_E',
                          titleKey: 'HELP_SYPHILIS_TITLE',
                          bodyKey: 'HELP_SYPHILIS_BODY',
                          whoKey: 'HELP_SYPHILIS_WHO',
                          isProOnly: false,
                        ),
                        _buildButtonGroup(
                          title: 'G_Q_14',
                          value: _syphilisTest,
                          options: [
                            autoI8lnGen.translate("YES_MESSAGE"),
                            autoI8lnGen.translate("NO_MESSAGE"),
                            autoI8lnGen.translate("D_ONT_KNOW"),
                          ],
                          onChanged: (value) =>
                              setState(() => _syphilisTest = value!),
                        ),

                        // TB — with help
                        _buildFieldLabelWithHelp(
                          labelKey: 'TB_TEST',
                          titleKey: 'HELP_TB_TITLE',
                          bodyKey: 'HELP_TB_BODY',
                          whoKey: 'HELP_TB_WHO',
                          isProOnly: false,
                        ),
                        _buildButtonGroup(
                          title: 'G_Q_16',
                          value: _tbTest,
                          options: [
                            autoI8lnGen.translate("YES_MESSAGE"),
                            autoI8lnGen.translate("NO_MESSAGE"),
                            autoI8lnGen.translate("D_ONT_KNOW"),
                          ],
                          onChanged: (value) =>
                              setState(() => _tbTest = value!),
                        ),

                        // Malaria — with help
                        _buildFieldLabelWithHelp(
                          labelKey: 'M_T_E',
                          titleKey: 'HELP_MALARIA_TITLE',
                          bodyKey: 'HELP_MALARIA_BODY',
                          whoKey: 'HELP_MALARIA_WHO',
                          isProOnly: false,
                        ),
                        _buildButtonGroup(
                          title: 'TESTED_MALARIA',
                          value: _malariaTest,
                          options: [
                            autoI8lnGen.translate("YES_MESSAGE"),
                            autoI8lnGen.translate("NO_MESSAGE"),
                            autoI8lnGen.translate("D_ONT_KNOW"),
                          ],
                          onChanged: (value) =>
                              setState(() => _malariaTest = value!),
                        ),

                        _buildButtonGroup(
                          title: 'G_Q_32',
                          value: _wormTest,
                          options: [
                            autoI8lnGen.translate("YES_MESSAGE"),
                            autoI8lnGen.translate("NO_MESSAGE"),
                            autoI8lnGen.translate("D_ONT_KNOW"),
                          ],
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
                          title: 'G_Q_37',
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
                          value: _getDisplayValue(_hivTestSelf, ''),
                        ),
                        if (_onART)
                          _buildSummaryItem(
                            label: 'ARRT',
                            value: 'O_T_S ${_artStartController.text}',
                            statusColor: Colors.blue,
                          ),
                        _buildSummaryItem(
                          label: 'S_T_E',
                          value: _getDisplayValue(_syphilisTest,
                              autoI8lnGen.translate("NOT_SPECIFIED")),
                        ),
                        _buildSummaryItem(
                          label: 'TB_TEST',
                          value: _getDisplayValue(
                              _tbTest, autoI8lnGen.translate("NOT_SPECIFIED")),
                        ),
                        _buildSummaryItem(
                          label: 'M_T_E',
                          value: _getDisplayValue(_malariaTest,
                              autoI8lnGen.translate("NOT_SPECIFIED")),
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

              // ══════════════════════════════════════════════════════════
              // SECTION 4: Pregnancy Information
              // ══════════════════════════════════════════════════════════
              _buildExpandableSection(
                title: 'P_I',
                sectionKey: 'P_2',
                filledCount: [
                  _lastMenstrualPeriodController.text,
                  _isFirstPregnancy
                      ? autoI8lnGen.translate("F_WRD")
                      : _liveBirthsController.text,
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
                        if (!_isFirstPregnancy) ...[
                          _buildTextFormField(
                            controller: _miscarriagesController,
                            label: 'G_Q_43',
                            keyboardType: TextInputType.number,
                            hint: 'G_Q_44',
                          ),
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
                            title: 'G_Q_47',
                            value: _lastPregnancyTiming,
                            options: [
                              autoI8lnGen.translate("G_Q_48"),
                              autoI8lnGen.translate("G_Q_49"),
                              autoI8lnGen.translate("G_Q_50"),
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
                          value:
                              _isFirstPregnancy ? 'YES_MESSAGE' : 'NO_MESSAGE',
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
                            value: _getDisplayValue(_liveBirthsController.text,
                                autoI8lnGen.translate("NOT_SPECIFIED")),
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

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
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
                        const SizedBox(width: 8),
                        Expanded(
                          child: AutoText(
                            'H_T_U_S',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AutoText('TEIM'),
                    AutoText('TOST'),
                    AutoText('RINA'),
                    AutoText('OIPC'),
                    AutoText('GIAC'),
                    AutoText('Y_H_P_I'),
                  ],
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: _isEditMode
          ? FloatingActionButton.extended(
              onPressed: _saveData,
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
              icon: const Icon(Icons.save),
              label: AutoText('SAVE_CHANGES'),
            )
          : FloatingActionButton(
              onPressed: () => setState(() => _isEditMode = true),
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              child: const Icon(Icons.edit),
              tooltip: autoI8lnGen.translate("E_I_F"),
            ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _pcvController.dispose();
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

// import 'package:auto_i8ln/auto_i8ln.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class PatientBackgroundScreen extends StatefulWidget {
//   final String patientId;

//   const PatientBackgroundScreen({Key? key, required this.patientId})
//       : super(key: key);

//   @override
//   _PatientBackgroundScreenState createState() =>
//       _PatientBackgroundScreenState();
// }

// class _PatientBackgroundScreenState extends State<PatientBackgroundScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // Controllers for text fields
//   final TextEditingController _ageController = TextEditingController();
//   final TextEditingController _heightController = TextEditingController();
//   final TextEditingController _weightController = TextEditingController();
//   final TextEditingController _systolicController = TextEditingController();
//   final TextEditingController _diastolicController = TextEditingController();
//   final TextEditingController _pcvController = TextEditingController();
//   final TextEditingController _albuminController = TextEditingController();
//   final TextEditingController _glucoseController = TextEditingController();
//   final TextEditingController _smokingDetailsController =
//       TextEditingController();
//   final TextEditingController _herbalMedicineController =
//       TextEditingController();
//   final TextEditingController _modernMedicineController =
//       TextEditingController();
//   final TextEditingController _artStartController = TextEditingController();
//   final TextEditingController _syphilisTreatmentController =
//       TextEditingController();
//   final TextEditingController _tbVaccinationYearController =
//       TextEditingController();
//   final TextEditingController _tbTreatmentStartController =
//       TextEditingController();
//   final TextEditingController _tbTreatmentStopController =
//       TextEditingController();
//   final TextEditingController _malariaTestDateController =
//       TextEditingController();
//   final TextEditingController _antimalarialTreatmentController =
//       TextEditingController();
//   final TextEditingController _disabilityController = TextEditingController();
//   final TextEditingController _lastMenstrualPeriodController =
//       TextEditingController();
//   final TextEditingController _miscarriagesController = TextEditingController();
//   final TextEditingController _liveBirthsController = TextEditingController();
//   final TextEditingController _previousPregnanciesController =
//       TextEditingController();
//   final TextEditingController _stillbornController = TextEditingController();
//   final TextEditingController _cesareanCountController =
//       TextEditingController();
//   final TextEditingController _deliveryRemarksController =
//       TextEditingController();

//   // State variables
//   String? _educationLevel;
//   static const List<String> _educationLevelOptions = [
//     'No formal education',
//     'Primary',
//     'Secondary',
//     'Tertiary',
//     'Postgraduate',
//   ];

//   String? _bloodGroup;
//   static const List<String> _bloodGroupOptions = [
//     'A+',
//     'A-',
//     'B+',
//     'B-',
//     'AB+',
//     'AB-',
//     'O+',
//     'O-',
//   ];

//   String? _genotype;
//   static const List<String> _genotypeOptions = [
//     'AA',
//     'AS',
//     'SS',
//     'SC',
//     'AC',
//   ];

//   bool? _registeredForANC;

//   String? _urinalysisResult;
//   bool _smokesTobacco = false;
//   String? _smokingFrequency;
//   bool _drinksAlcohol = false;
//   String? _alcoholType;
//   String? _alcoholFrequency;
//   bool _usesHerbalMedicine = false;
//   String? _herbalFrequency;
//   bool _usesModernMedicine = false;
//   String? _modernMedicineType;
//   String? _hivTestSelf;
//   String? _hivTestPartner;
//   bool _onART = false;
//   String? _partnerARTStatus;
//   String? _syphilisTest;
//   String? _tbTest;
//   String? _tbVaccination;
//   bool _onTBTreatment = false;
//   bool _currentlyOnTBTreatment = false;
//   int _tetanusVaccinations = 0;
//   String? _tetanusRecent;
//   String? _malariaTest;
//   bool _onAntimalarials = false;
//   String? _antimalarialRecent;
//   String? _wormTest;
//   String? _wormMedicineRecent;
//   bool _hasOtherIssues = false;
//   bool _isFirstPregnancy = true;
//   String? _lastPregnancyTiming;
//   bool _hadCesarean = false;
//   String? _hadForcepsVacuum;
//   String? _hadHeavyBleeding;
//   String? _hadTears;
//   String? _tearsNeedStitching;
//   String? _tearsHealedNaturally;
//   String? _tearsStillBothering;

//   double? _bmi;
//   String _bmiMessage = '';
//   String _bpMessage = '';
//   String _pcvMessage = '';
//   String _albuminMessage = '';
//   String _glucoseMessage = '';
//   DateTime? _expectedDeliveryDate;
//   List<String> _alerts = [];

//   // UI State
//   bool _isEditMode = false;
//   Set<String> _expandedSections = {};

//   // ─────────────────────────────────────────────────────────────────────────
//   // GATE: show professional-presence dialog on first entry
//   // ─────────────────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     _loadExistingData();
//     // Show the gate dialog after the first frame so context is available.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _showProfessionalGateDialog();
//     });
//   }

//   /// Full-screen bottom-sheet style dialog that warns the user this form
//   /// has sections requiring a health professional. It cannot be dismissed
//   /// by tapping outside — the user must make a deliberate choice.
//   void _showProfessionalGateDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // force a deliberate choice
//       builder: (BuildContext ctx) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           insetPadding:
//               const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Icon + Title row
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(10),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(Icons.medical_services_outlined,
//                           color: Colors.blue[700], size: 28),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: AutoText(
//                         'PROF_GATE_TITLE',
//                         style: TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue[900],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 16),

//                 // Body explanation
//                 AutoText(
//                   'PROF_GATE_BODY',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey[800],
//                     height: 1.5,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Section labels: what you can vs. cannot fill alone
//                 _buildGateSectionRow(
//                   icon: Icons.person_outline,
//                   color: Colors.green[700]!,
//                   labelKey: 'GATE_SELF_LABEL',
//                   // "You can fill these yourself:"
//                   examplesKey: 'GATE_SELF_EXAMPLES',
//                   // "Age, height, weight, education, pregnancy history,
//                   //  lifestyle habits"
//                 ),
//                 const SizedBox(height: 8),
//                 _buildGateSectionRow(
//                   icon: Icons.local_hospital_outlined,
//                   color: Colors.red[700]!,
//                   labelKey: 'GATE_PROF_LABEL',
//                   // "These need a health professional:"
//                   examplesKey: 'GATE_PROF_EXAMPLES',
//                   // "Blood pressure, PCV (blood test), albumin, glucose,
//                   //  urinalysis, HIV/syphilis/TB/malaria tests"
//                 ),

//                 const SizedBox(height: 16),

//                 // Tip about the ⓘ icons
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.amber[50],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.amber[300]!),
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(Icons.tips_and_updates_outlined,
//                           color: Colors.amber[800], size: 18),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: AutoText(
//                           'PROF_GATE_WARN',
//                           style:
//                               TextStyle(fontSize: 12, color: Colors.amber[900]),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 24),

//                 // CTA buttons
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: () => Navigator.of(ctx).pop(),
//                     icon: const Icon(Icons.check_circle_outline),
//                     label: AutoText('PROF_GATE_HAVE_PROF'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green[700],
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     onPressed: () {
//                       Navigator.of(ctx).pop(); // close dialog
//                       Navigator.of(context).pop(); // leave screen
//                     },
//                     icon: const Icon(Icons.arrow_back_outlined),
//                     label: AutoText('PROF_GATE_COME_BACK'),
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.grey[800],
//                       side: BorderSide(color: Colors.grey[400]!),
//                       padding: const EdgeInsets.symmetric(vertical: 14),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   /// Small row used inside the gate dialog to list self-fill vs. pro-only
//   /// sections.
//   Widget _buildGateSectionRow({
//     required IconData icon,
//     required Color color,
//     required String labelKey,
//     required String examplesKey,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, color: color, size: 18),
//         const SizedBox(width: 8),
//         Expanded(
//           child: RichText(
//             text: TextSpan(
//               style: const TextStyle(fontSize: 13, height: 1.4),
//               children: [
//                 TextSpan(
//                   text: '${autoI8lnGen.translate(labelKey)} ',
//                   style: TextStyle(fontWeight: FontWeight.bold, color: color),
//                 ),
//                 TextSpan(
//                   text: autoI8lnGen.translate(examplesKey),
//                   style: TextStyle(color: Colors.grey[700]),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // HELP BOTTOM SHEET
//   // Shown when the user taps a ⓘ icon next to a medical field.
//   // ─────────────────────────────────────────────────────────────────────────

//   void _showFieldHelp({
//     required String titleKey,
//     required String bodyKey,
//     required String whoKey,
//     required bool isProOnly,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (ctx) {
//         return Padding(
//           padding: EdgeInsets.only(
//             left: 20,
//             right: 20,
//             top: 20,
//             bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Handle bar
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // Title
//               AutoText(
//                 titleKey,
//                 style:
//                     const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),

//               // Body
//               AutoText(
//                 bodyKey,
//                 style: TextStyle(
//                     fontSize: 14, color: Colors.grey[800], height: 1.5),
//               ),
//               const SizedBox(height: 16),

//               // "Who fills this in" badge
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: isProOnly ? Colors.red[50] : Colors.green[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: isProOnly ? Colors.red[200]! : Colors.green[200]!,
//                   ),
//                 ),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Icon(
//                       isProOnly
//                           ? Icons.local_hospital_outlined
//                           : Icons.person_outline,
//                       color: isProOnly ? Colors.red[700] : Colors.green[700],
//                       size: 16,
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: AutoText(
//                         whoKey,
//                         style: TextStyle(
//                           fontSize: 13,
//                           color:
//                               isProOnly ? Colors.red[800] : Colors.green[800],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               SizedBox(
//                 width: double.infinity,
//                 child: TextButton(
//                   onPressed: () => Navigator.pop(ctx),
//                   child: AutoText('OK'),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Helper: field label row with optional ⓘ help icon
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildFieldLabelWithHelp({
//     required String labelKey,
//     required String titleKey,
//     required String bodyKey,
//     required String whoKey,
//     required bool isProOnly,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         children: [
//           Expanded(
//             child: AutoText(
//               labelKey,
//               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//             ),
//           ),
//           GestureDetector(
//             onTap: () => _showFieldHelp(
//               titleKey: titleKey,
//               bodyKey: bodyKey,
//               whoKey: whoKey,
//               isProOnly: isProOnly,
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: isProOnly ? Colors.red[50] : Colors.blue[50],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     isProOnly
//                         ? Icons.local_hospital_outlined
//                         : Icons.info_outline,
//                     size: 14,
//                     color: isProOnly ? Colors.red[700] : Colors.blue[700],
//                   ),
//                   const SizedBox(width: 3),
//                   Text(
//                     isProOnly
//                         ? autoI8lnGen.translate('PROF_ONLY_TAG')
//                         // e.g. "Clinic only"
//                         : autoI8lnGen.translate('LEARN_MORE'),
//                     // e.g. "Learn more"
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: isProOnly ? Colors.red[700] : Colors.blue[700],
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Pro-only banner shown once above the first medical-only field in a section
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildProOnlyBanner() {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.red[50],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.red[200]!),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(Icons.local_hospital_outlined, color: Colors.red[700], size: 18),
//           const SizedBox(width: 8),
//           Expanded(
//             child: AutoText(
//               'PRO_ONLY_BANNER',
//               // e.g. "The fields below should be completed by or with
//               //       the help of a health professional."
//               style: TextStyle(fontSize: 13, color: Colors.red[800]),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Data loading
//   // ─────────────────────────────────────────────────────────────────────────

//   void _loadExistingData() async {
//     try {
//       DocumentSnapshot doc = await _firestore
//           .collection('patients')
//           .doc(widget.patientId)
//           .collection('background')
//           .doc('patient_background')
//           .get();

//       if (doc.exists) {
//         Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//         setState(() {
//           _educationLevel = data['education_level'];
//           _bloodGroup = data['blood_group'];
//           _genotype = data['genotype'];
//           _registeredForANC = data['registered_for_anc'];
//           _ageController.text = data['age']?.toString() ?? '';
//           _heightController.text = data['height']?.toString() ?? '';
//           _weightController.text = data['weight']?.toString() ?? '';
//           _systolicController.text = data['systolic_bp']?.toString() ?? '';
//           _diastolicController.text = data['diastolic_bp']?.toString() ?? '';
//           _pcvController.text =
//               data['pcv']?.toString() ?? data['haemoglobin']?.toString() ?? '';
//           _albuminController.text = data['albumin']?.toString() ?? '';
//           _glucoseController.text = data['glucose']?.toString() ?? '';
//           _urinalysisResult = data['urinalysis'];
//           _smokesTobacco = data['smokes_tobacco'] ?? false;
//           _smokingFrequency = data['smoking_frequency'];
//           _drinksAlcohol = data['drinks_alcohol'] ?? false;
//           _alcoholType = data['alcohol_type'];
//           _alcoholFrequency = data['alcohol_frequency'];
//           _usesHerbalMedicine = data['uses_herbal_medicine'] ?? false;
//           _herbalFrequency = data['herbal_frequency'];
//           _usesModernMedicine = data['uses_modern_medicine'] ?? false;
//           _modernMedicineType = data['modern_medicine_type'];
//           _hivTestSelf = data['hiv_test_self'];
//           _hivTestPartner = data['hiv_test_partner'];
//           _onART = data['on_art'] ?? false;
//           _partnerARTStatus = data['partner_art_status'];
//           _syphilisTest = data['syphilis_test'];
//           _tbTest = data['tb_test'];
//           _tbVaccination = data['tb_vaccination'];
//           _onTBTreatment = data['on_tb_treatment'] ?? false;
//           _currentlyOnTBTreatment = data['currently_on_tb_treatment'] ?? false;
//           _tetanusVaccinations = data['tetanus_vaccinations'] ?? 0;
//           _tetanusRecent = data['tetanus_recent'];
//           _malariaTest = data['malaria_test'];
//           _onAntimalarials = data['on_antimalarials'] ?? false;
//           _antimalarialRecent = data['antimalarial_recent'];
//           _wormTest = data['worm_test'];
//           _wormMedicineRecent = data['worm_medicine_recent'];
//           _hasOtherIssues = data['has_other_issues'] ?? false;
//           _isFirstPregnancy = data['is_first_pregnancy'] ?? true;
//           _lastPregnancyTiming = data['last_pregnancy_timing'];
//           _hadCesarean = data['had_cesarean'] ?? false;
//           _hadForcepsVacuum = data['had_forceps_vacuum'];
//           _hadHeavyBleeding = data['had_heavy_bleeding'];
//           _hadTears = data['had_tears'];
//           _tearsNeedStitching = data['tears_need_stitching'];
//           _tearsHealedNaturally = data['tears_healed_naturally'];
//           _tearsStillBothering = data['tears_still_bothering'];

//           _calculateBMI();
//           _checkBloodPressure();
//           _checkPCV();
//           _checkAlbumin();
//           _checkGlucose();
//           _calculateExpectedDeliveryDate();
//         });
//       }
//     } catch (e) {
//       print('Error loading existing data: $e');
//     }
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Calculations & checks (unchanged logic)
//   // ─────────────────────────────────────────────────────────────────────────

//   void _calculateBMI() {
//     final height = double.tryParse(_heightController.text);
//     final weight = double.tryParse(_weightController.text);
//     if (height != null && weight != null && height > 0) {
//       final heightInMeters = height / 100;
//       _bmi = weight / (heightInMeters * heightInMeters);
//       setState(() {
//         if (_bmi! < 18.5) {
//           _bmiMessage = autoI8lnGen.translate("TOO_LOW");
//         } else if (_bmi! >= 18.5 && _bmi! <= 24.9) {
//           _bmiMessage = autoI8lnGen.translate("THUMB_UP");
//         } else if (_bmi! >= 25 && _bmi! <= 29) {
//           _bmiMessage = autoI8lnGen.translate("TOO_HIGH");
//         } else {
//           _bmiMessage = autoI8lnGen.translate("OBESE_DANGER");
//           _addAlert(autoI8lnGen.translate("THIS_LEVEL_OBESE"));
//         }
//       });
//     }
//   }

//   void _checkBloodPressure() {
//     final systolic = int.tryParse(_systolicController.text);
//     final diastolic = int.tryParse(_diastolicController.text);
//     if (systolic != null && diastolic != null) {
//       setState(() {
//         if (systolic >= 160 || diastolic >= 100) {
//           _bpMessage = autoI8lnGen.translate("HEALTH_ISSUE_3");
//           _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_4"));
//         } else if (systolic >= 140 || diastolic >= 90) {
//           _bpMessage = autoI8lnGen.translate("HEALTH_ISSUE_2");
//         } else if (systolic >= 130 || diastolic > 80) {
//           _bpMessage = autoI8lnGen.translate("HEALTH_ISSUE_1");
//         } else if (systolic >= 120 && diastolic <= 80) {
//           _bpMessage = autoI8lnGen.translate("E_C_D");
//         } else if (systolic >= 90 && diastolic >= 60) {
//           _bpMessage = autoI8lnGen.translate("THUMB_UP");
//         }
//       });
//     }
//   }

//   void _checkPCV() {
//     final pcv = double.tryParse(_pcvController.text);
//     if (pcv != null) {
//       setState(() {
//         if (pcv < 30) {
//           _pcvMessage = autoI8lnGen.translate("HEALTH_ISSUE_5");
//         } else if (pcv >= 30 && pcv < 33) {
//           _pcvMessage = autoI8lnGen.translate("HEALTH_ISSUE_5");
//         } else if (pcv >= 33 && pcv <= 44) {
//           _pcvMessage = autoI8lnGen.translate("HEALTH_ISSUE_7");
//         } else {
//           _pcvMessage = autoI8lnGen.translate("HEALTH_ISSUE_6");
//         }
//       });
//     }
//   }

//   void _checkAlbumin() {
//     final albumin = double.tryParse(_albuminController.text);
//     if (albumin != null) {
//       setState(() {
//         if (albumin <= 150) {
//           _albuminMessage = autoI8lnGen.translate("HEALTH_ISSUE_7");
//         } else if (albumin > 150 && albumin <= 300) {
//           _albuminMessage = autoI8lnGen.translate("HEALTH_ISSUE_8");
//         } else {
//           _albuminMessage = autoI8lnGen.translate("HEALTH_ISSUE_9");
//           _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_10"));
//         }
//       });
//     }
//   }

//   void _checkGlucose() {
//     final glucose = double.tryParse(_glucoseController.text);
//     if (glucose != null) {
//       setState(() {
//         if (glucose < 7.8) {
//           _glucoseMessage = autoI8lnGen.translate("NORMAL");
//         } else if (glucose >= 7.8 && glucose < 11.0) {
//           _glucoseMessage = autoI8lnGen.translate("HEALTH_ISSUE_11");
//         } else {
//           _glucoseMessage = autoI8lnGen.translate("HEALTH_ISSUE_12");
//           _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_13"));
//         }
//       });
//     }
//   }

//   void _calculateExpectedDeliveryDate() {
//     if (_lastMenstrualPeriodController.text.isNotEmpty) {
//       try {
//         List<String> dateParts = _lastMenstrualPeriodController.text.split('/');
//         if (dateParts.length == 3) {
//           int day = int.parse(dateParts[0]);
//           int month = int.parse(dateParts[1]);
//           int year = int.parse(dateParts[2]);
//           DateTime lmp = DateTime(year, month, day);
//           setState(() {
//             _expectedDeliveryDate = lmp.add(const Duration(days: 280));
//           });
//         }
//       } catch (e) {
//         print('Error calculating EDD: $e');
//       }
//     }
//   }

//   void _addAlert(String alert) {
//     if (!_alerts.contains(alert)) {
//       _alerts.add(alert);
//     }
//   }

//   void _checkHighRiskFactors() {
//     _alerts.clear();
//     final age = int.tryParse(_ageController.text);
//     if (age != null) {
//       if (age < 20 || age > 39) {
//         _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_14"));
//       }
//       if (_isFirstPregnancy && (age < 20 || age > 35)) {
//         _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_15"));
//       }
//     }
//     if (_genotype == 'SS' || _genotype == 'SC') {
//       _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_SICKLE_CELL"));
//     }
//     final miscarriages = int.tryParse(_miscarriagesController.text);
//     if (miscarriages != null && miscarriages > 0) {
//       _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_16"));
//     }
//     if (_lastPregnancyTiming == '>9 years') {
//       _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_17"));
//     }
//     if (_hadCesarean) {
//       _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_18"));
//     }
//     if (_hadHeavyBleeding == 'Yes') {
//       _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_19"));
//     }
//     if (_onART) {
//       _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_20"));
//     }
//     if (_currentlyOnTBTreatment) {
//       _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_21"));
//     }
//     if (_hasOtherIssues) {
//       _addAlert(autoI8lnGen.translate("HEALTH_ISSUE_22"));
//     }
//   }

//   int _getCompletionPercentage() {
//     int totalFields = 24;
//     int filledFields = 0;
//     if (_educationLevel != null) filledFields++;
//     if (_bloodGroup != null) filledFields++;
//     if (_genotype != null) filledFields++;
//     if (_registeredForANC != null) filledFields++;
//     if (_ageController.text.isNotEmpty) filledFields++;
//     if (_heightController.text.isNotEmpty) filledFields++;
//     if (_weightController.text.isNotEmpty) filledFields++;
//     if (_systolicController.text.isNotEmpty) filledFields++;
//     if (_diastolicController.text.isNotEmpty) filledFields++;
//     if (_pcvController.text.isNotEmpty) filledFields++;
//     if (_albuminController.text.isNotEmpty) filledFields++;
//     if (_glucoseController.text.isNotEmpty) filledFields++;
//     if (_urinalysisResult != null) filledFields++;
//     if (_hivTestSelf != null) filledFields++;
//     if (_syphilisTest != null) filledFields++;
//     if (_tbTest != null) filledFields++;
//     if (_malariaTest != null) filledFields++;
//     if (_wormTest != null) filledFields++;
//     if (_lastMenstrualPeriodController.text.isNotEmpty) filledFields++;
//     if (_miscarriagesController.text.isNotEmpty) filledFields++;
//     if (!_isFirstPregnancy && _liveBirthsController.text.isNotEmpty)
//       filledFields++;
//     if (!_isFirstPregnancy && _previousPregnanciesController.text.isNotEmpty)
//       filledFields++;
//     if (!_isFirstPregnancy && _lastPregnancyTiming != null) filledFields++;
//     if (_tetanusVaccinations > 0) filledFields++;
//     return ((filledFields / totalFields) * 100).round();
//   }

//   List<String> _getMissingFields() {
//     List<String> missing = [];
//     if (_educationLevel == null)
//       missing.add(autoI8lnGen.translate("EDU_LEVEL"));
//     if (_bloodGroup == null) missing.add(autoI8lnGen.translate("BLOOD_GROUP"));
//     if (_genotype == null) missing.add(autoI8lnGen.translate("GENOTYPE"));
//     if (_registeredForANC == null)
//       missing.add(autoI8lnGen.translate("ANC_REG"));
//     if (_ageController.text.isEmpty) missing.add(autoI8lnGen.translate("AGE"));
//     if (_heightController.text.isEmpty) missing.add(autoI8lnGen.translate("H"));
//     if (_weightController.text.isEmpty) missing.add(autoI8lnGen.translate("W"));
//     if (_systolicController.text.isEmpty)
//       missing.add(autoI8lnGen.translate("BLOOD_PRESSURE"));
//     if (_pcvController.text.isEmpty)
//       missing.add(autoI8lnGen.translate("PCV_T"));
//     if (_urinalysisResult == null)
//       missing.add(autoI8lnGen.translate("URINEANALYSIS"));
//     if (_hivTestSelf == null) missing.add(autoI8lnGen.translate("HI_T_S"));
//     if (_syphilisTest == null) missing.add(autoI8lnGen.translate("S_T_E"));
//     if (_tbTest == null) missing.add(autoI8lnGen.translate("TB_TEST"));
//     if (_malariaTest == null) missing.add(autoI8lnGen.translate("M_T_E"));
//     if (_lastMenstrualPeriodController.text.isEmpty)
//       missing.add(autoI8lnGen.translate("L_M_P"));
//     if (_tetanusVaccinations == 0) missing.add(autoI8lnGen.translate("T_V_A"));
//     return missing;
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Save
//   // ─────────────────────────────────────────────────────────────────────────

//   Future<void> _saveData() async {
//     if (_formKey.currentState!.validate()) {
//       _checkHighRiskFactors();

//       List<String> providerIds = [];
//       try {
//         final connectionQuery = await _firestore
//             .collection('allowed_to_chat')
//             .where('requesterId', isEqualTo: widget.patientId)
//             .get();

//         if (connectionQuery.docs.isEmpty) {
//           throw Exception(
//               'This patient is not connected to a health provider.');
//         }

//         providerIds = connectionQuery.docs
//             .map((doc) => doc['recipientId'] as String)
//             .toList();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: AutoText('CONNECTION_REQUIRED $e')),
//         );
//         return;
//       }

//       Map<String, dynamic> data = {
//         'education_level': _educationLevel,
//         'blood_group': _bloodGroup,
//         'genotype': _genotype,
//         'registered_for_anc': _registeredForANC,
//         'age': int.tryParse(_ageController.text),
//         'height': double.tryParse(_heightController.text),
//         'weight': double.tryParse(_weightController.text),
//         'bmi': _bmi,
//         'bmi_message': _bmiMessage,
//         'systolic_bp': int.tryParse(_systolicController.text),
//         'diastolic_bp': int.tryParse(_diastolicController.text),
//         'bp_message': _bpMessage,
//         'pcv': double.tryParse(_pcvController.text),
//         'pcv_message': _pcvMessage,
//         'haemoglobin': null,
//         'albumin': double.tryParse(_albuminController.text),
//         'albumin_message': _albuminMessage,
//         'glucose': double.tryParse(_glucoseController.text),
//         'glucose_message': _glucoseMessage,
//         'urinalysis': _urinalysisResult,
//         'smokes_tobacco': _smokesTobacco,
//         'smoking_details': _smokingDetailsController.text,
//         'smoking_frequency': _smokingFrequency,
//         'drinks_alcohol': _drinksAlcohol,
//         'alcohol_type': _alcoholType,
//         'alcohol_frequency': _alcoholFrequency,
//         'uses_herbal_medicine': _usesHerbalMedicine,
//         'herbal_medicine_details': _herbalMedicineController.text,
//         'herbal_frequency': _herbalFrequency,
//         'uses_modern_medicine': _usesModernMedicine,
//         'modern_medicine_type': _modernMedicineType,
//         'hiv_test_self': _hivTestSelf,
//         'hiv_test_partner': _hivTestPartner,
//         'on_art': _onART,
//         'art_start_date': _artStartController.text,
//         'partner_art_status': _partnerARTStatus,
//         'syphilis_test': _syphilisTest,
//         'syphilis_treatment': _syphilisTreatmentController.text,
//         'tb_test': _tbTest,
//         'tb_vaccination': _tbVaccination,
//         'tb_vaccination_year': _tbVaccinationYearController.text,
//         'on_tb_treatment': _onTBTreatment,
//         'tb_treatment_start': _tbTreatmentStartController.text,
//         'tb_treatment_stop': _tbTreatmentStopController.text,
//         'currently_on_tb_treatment': _currentlyOnTBTreatment,
//         'tetanus_vaccinations': _tetanusVaccinations,
//         'tetanus_recent': _tetanusRecent,
//         'malaria_test': _malariaTest,
//         'malaria_test_date': _malariaTestDateController.text,
//         'on_antimalarials': _onAntimalarials,
//         'antimalarial_treatment': _antimalarialTreatmentController.text,
//         'antimalarial_recent': _antimalarialRecent,
//         'worm_test': _wormTest,
//         'worm_medicine_recent': _wormMedicineRecent,
//         'has_other_issues': _hasOtherIssues,
//         'disability_details': _disabilityController.text,
//         'last_menstrual_period': _lastMenstrualPeriodController.text,
//         'expected_delivery_date': _expectedDeliveryDate?.toIso8601String(),
//         'is_first_pregnancy': _isFirstPregnancy,
//         'miscarriages': int.tryParse(_miscarriagesController.text),
//         'live_births': int.tryParse(_liveBirthsController.text),
//         'previous_pregnancies':
//             int.tryParse(_previousPregnanciesController.text),
//         'last_pregnancy_timing': _lastPregnancyTiming,
//         'stillborn': int.tryParse(_stillbornController.text),
//         'had_cesarean': _hadCesarean,
//         'cesarean_count': int.tryParse(_cesareanCountController.text),
//         'had_forceps_vacuum': _hadForcepsVacuum,
//         'had_heavy_bleeding': _hadHeavyBleeding,
//         'had_tears': _hadTears,
//         'tears_need_stitching': _tearsNeedStitching,
//         'tears_healed_naturally': _tearsHealedNaturally,
//         'tears_still_bothering': _tearsStillBothering,
//         'delivery_remarks': _deliveryRemarksController.text,
//         'alerts': _alerts,
//         'created_at': FieldValue.serverTimestamp(),
//         'updated_at': FieldValue.serverTimestamp(),
//         'providerIds': providerIds,
//         'patientId': widget.patientId,
//       };

//       try {
//         await _firestore
//             .collection('patients')
//             .doc(widget.patientId)
//             .collection('background')
//             .doc('patient_background')
//             .set(data, SetOptions(merge: true));

//         for (final providerId in providerIds) {
//           await _firestore
//               .collection('health_provider_data')
//               .doc(providerId)
//               .collection('patient_backgrounds')
//               .doc(widget.patientId)
//               .set(data, SetOptions(merge: true));
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Patient background saved successfully')),
//         );

//         setState(() => _isEditMode = false);

//         if (_alerts.isNotEmpty) _showAlertsDialog();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: AutoText('ERROR_S_D $e')),
//         );
//       }
//     }
//   }

//   void _showAlertsDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: AutoText('H_P_A'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               AutoText('T_F_AG'),
//               const SizedBox(height: 10),
//               ..._alerts.map((alert) => Text('• $alert')).toList(),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: AutoText('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Overview card
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildOverviewCard() {
//     final completionPercentage = _getCompletionPercentage();
//     final missingFields = _getMissingFields();

//     return Card(
//       margin: const EdgeInsets.all(16),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 AutoText(
//                   'B_S_UM',
//                   style: const TextStyle(
//                       fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: LinearProgressIndicator(
//                     value: completionPercentage / 100,
//                     backgroundColor: Colors.grey[300],
//                     valueColor:
//                         AlwaysStoppedAnimation<Color>(completionPercentage >= 80
//                             ? Colors.green
//                             : completionPercentage >= 50
//                                 ? Colors.orange
//                                 : Colors.red),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 AutoText(
//                   '$completionPercentage% COMPLETE',
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             if (missingFields.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.orange[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.orange[200]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.info_outline, color: Colors.orange[600]),
//                         const SizedBox(width: 8),
//                         AutoText(
//                           'STN (${missingFields.length} ITEMS):',
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 4,
//                       children: missingFields
//                           .map((field) => Chip(
//                                 label: Text(field,
//                                     style: const TextStyle(fontSize: 12)),
//                                 backgroundColor: Colors.orange[100],
//                                 materialTapTargetSize:
//                                     MaterialTapTargetSize.shrinkWrap,
//                               ))
//                           .toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//             if (_alerts.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.red[200]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.warning, color: Colors.red[600]),
//                         const SizedBox(width: 8),
//                         AutoText(
//                           'H_AL (${_alerts.length}):',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red[700]),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     ..._alerts
//                         .map((alert) => Padding(
//                               padding: const EdgeInsets.only(bottom: 4),
//                               child: Text('• $alert',
//                                   style: const TextStyle(fontSize: 13)),
//                             ))
//                         .toList(),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Section builder
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildExpandableSection({
//     required String title,
//     required String sectionKey,
//     required List<Widget> children,
//     required int filledCount,
//     required int totalCount,
//   }) {
//     final isExpanded = _expandedSections.contains(sectionKey);
//     final isEmpty = filledCount == 0;
//     final isComplete = filledCount == totalCount;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//       child: Column(
//         children: [
//           ListTile(
//             title: Row(
//               children: [
//                 Expanded(
//                   child: AutoText(
//                     title,
//                     style: const TextStyle(
//                         fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: isComplete
//                         ? Colors.green[100]
//                         : isEmpty
//                             ? Colors.red[100]
//                             : Colors.orange[100],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: AutoText(
//                     '$filledCount/$totalCount',
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.bold,
//                       color: isComplete
//                           ? Colors.green[700]
//                           : isEmpty
//                               ? Colors.red[700]
//                               : Colors.orange[700],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Icon(
//                   isComplete
//                       ? Icons.check_circle
//                       : isEmpty
//                           ? Icons.error
//                           : Icons.warning,
//                   color: isComplete
//                       ? Colors.green[700]
//                       : isEmpty
//                           ? Colors.red[700]
//                           : Colors.orange[700],
//                 ),
//               ],
//             ),
//             trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
//             onTap: () {
//               setState(() {
//                 if (isExpanded) {
//                   _expandedSections.remove(sectionKey);
//                 } else {
//                   _expandedSections.add(sectionKey);
//                 }
//               });
//             },
//           ),
//           if (isExpanded) ...[
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(children: children),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryItem({
//     required String label,
//     required String value,
//     Widget? trailing,
//     Color? statusColor,
//     VoidCallback? onTap,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(8),
//         color: Colors.grey[50],
//       ),
//       child: ListTile(
//         dense: true,
//         title: AutoText(
//           label,
//           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//         ),
//         subtitle: AutoText(
//           value,
//           style: const TextStyle(fontSize: 13, color: Colors.black87),
//         ),
//         trailing: trailing,
//       ),
//     );
//   }

//   String _getDisplayValue(dynamic value, String defaultText) {
//     if (value == null || value.toString().isEmpty) return defaultText;
//     return value.toString();
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // Form field builders (unchanged from original except where noted)
//   // ─────────────────────────────────────────────────────────────────────────

//   Widget _buildTextFormField({
//     required TextEditingController controller,
//     required String label,
//     String? hint,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//     void Function(String)? onChanged,
//     String? suffixText,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: autoI8lnGen.translate(label),
//           hintText: autoI8lnGen.translate(hint ?? ""),
//           border: const OutlineInputBorder(),
//           enabled: _isEditMode,
//           suffixText: suffixText,
//         ),
//         keyboardType: keyboardType,
//         validator: validator,
//         onChanged: onChanged,
//         readOnly: !_isEditMode,
//       ),
//     );
//   }

//   Widget _buildDropdownFormField({
//     required String label,
//     required String? value,
//     required List<String> items,
//     required void Function(String?) onChanged,
//     String? helperText,
//   }) {
//     String? safeValue = (value != null && items.contains(value)) ? value : null;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: DropdownButtonFormField<String>(
//         decoration: InputDecoration(
//           labelText: autoI8lnGen.translate(label),
//           border: const OutlineInputBorder(),
//           helperText: helperText,
//           helperMaxLines: 2,
//         ),
//         value: safeValue,
//         items: items.map((String item) {
//           return DropdownMenuItem<String>(
//             value: item,
//             child: Text(item),
//           );
//         }).toList(),
//         onChanged: _isEditMode ? onChanged : null,
//       ),
//     );
//   }

//   Widget _buildChipSelector({
//     required String title,
//     required String? value,
//     required List<String> options,
//     required void Function(String?) onChanged,
//     String? subtitle,
//     Color? selectedColor,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AutoText(title,
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//           if (subtitle != null) ...[
//             const SizedBox(height: 4),
//             Text(subtitle,
//                 style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//           ],
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: options.map((option) {
//               final isSelected = value == option;
//               return ChoiceChip(
//                 label: Text(
//                   option,
//                   style: TextStyle(
//                     fontWeight:
//                         isSelected ? FontWeight.bold : FontWeight.normal,
//                     color: isSelected ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 selected: isSelected,
//                 onSelected: _isEditMode
//                     ? (_) => onChanged(isSelected ? null : option)
//                     : null,
//                 selectedColor: selectedColor ?? Colors.blue[700],
//                 backgroundColor: Colors.grey[100],
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   side: BorderSide(
//                     color: isSelected
//                         ? (selectedColor ?? Colors.blue[700])!
//                         : Colors.grey[300]!,
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//           const SizedBox(height: 8),
//         ],
//       ),
//     );
//   }

//   Widget _buildButtonGroup({
//     required String title,
//     required String? value,
//     required List<String> options,
//     required void Function(String?) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AutoText(title,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 12),
//         Row(
//           children: options.map((option) {
//             final isSelected = value == option;
//             return Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 4),
//                 child: GestureDetector(
//                   onTap: _isEditMode ? () => onChanged(option) : null,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     decoration: BoxDecoration(
//                       color: isSelected ? Colors.blue[600] : Colors.grey[100],
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color:
//                             isSelected ? Colors.blue[600]! : Colors.grey[300]!,
//                         width: 2,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         Icon(
//                           _getIconForOption(option),
//                           color: isSelected ? Colors.white : Colors.grey[600],
//                           size: 28,
//                         ),
//                         const SizedBox(height: 8),
//                         AutoText(
//                           option,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: isSelected ? Colors.white : Colors.black87,
//                             fontWeight: isSelected
//                                 ? FontWeight.w600
//                                 : FontWeight.normal,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   IconData _getIconForOption(String option) {
//     String lowerOption = option.toLowerCase();
//     String yesMessage = autoI8lnGen.translate("YES_MESSAGE").toLowerCase();
//     if (lowerOption == yesMessage) return Icons.check_circle;
//     if (lowerOption == autoI8lnGen.translate("NO_MESSAGE")) return Icons.cancel;
//     if (lowerOption == autoI8lnGen.translate("DONT_KNOW_2") ||
//         lowerOption == autoI8lnGen.translate("DONT_REMMEBR")) return Icons.help;
//     if (lowerOption == autoI8lnGen.translate("DAILY")) return Icons.today;
//     if (lowerOption == autoI8lnGen.translate("WEEKLY"))
//       return Icons.calendar_view_week;
//     if (lowerOption == autoI8lnGen.translate("LESS_OFTEN"))
//       return Icons.calendar_month;
//     if (lowerOption == autoI8lnGen.translate("BEER")) return Icons.local_bar;
//     if (lowerOption == autoI8lnGen.translate("LIQUOR")) return Icons.wine_bar;
//     if (lowerOption == autoI8lnGen.translate("BOTH")) return Icons.restaurant;
//     return Icons.circle;
//   }

//   Widget _buildYesNoButton({
//     required String title,
//     required bool value,
//     required void Function(bool) onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AutoText(title,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: GestureDetector(
//                 onTap: _isEditMode ? () => onChanged(true) : null,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   decoration: BoxDecoration(
//                     color: value ? Colors.green[600] : Colors.grey[100],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: value ? Colors.green[600]! : Colors.grey[300]!,
//                       width: 2,
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Icon(Icons.check_circle,
//                           color: value ? Colors.white : Colors.grey[600],
//                           size: 28),
//                       const SizedBox(height: 8),
//                       AutoText('YES_MESSAGE',
//                           style: TextStyle(
//                             color: value ? Colors.white : Colors.black87,
//                             fontWeight:
//                                 value ? FontWeight.w600 : FontWeight.normal,
//                           )),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: GestureDetector(
//                 onTap: _isEditMode ? () => onChanged(false) : null,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   decoration: BoxDecoration(
//                     color: !value ? Colors.red[600] : Colors.grey[100],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: !value ? Colors.red[600]! : Colors.grey[300]!,
//                       width: 2,
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Icon(Icons.cancel,
//                           color: !value ? Colors.white : Colors.grey[600],
//                           size: 28),
//                       const SizedBox(height: 8),
//                       AutoText('NO_MESSAGE',
//                           style: TextStyle(
//                             color: !value ? Colors.white : Colors.black87,
//                             fontWeight:
//                                 !value ? FontWeight.w600 : FontWeight.normal,
//                           )),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildNullableYesNoButton({
//     required String title,
//     required bool? value,
//     required void Function(bool) onChanged,
//     String? subtitle,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         AutoText(title,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
//         if (subtitle != null) ...[
//           const SizedBox(height: 4),
//           Text(subtitle,
//               style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//         ],
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: GestureDetector(
//                 onTap: _isEditMode ? () => onChanged(true) : null,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   decoration: BoxDecoration(
//                     color: value == true ? Colors.green[600] : Colors.grey[100],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: value == true
//                           ? Colors.green[600]!
//                           : Colors.grey[300]!,
//                       width: 2,
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Icon(Icons.check_circle,
//                           color:
//                               value == true ? Colors.white : Colors.grey[600],
//                           size: 28),
//                       const SizedBox(height: 8),
//                       AutoText('YES_MESSAGE',
//                           style: TextStyle(
//                             color:
//                                 value == true ? Colors.white : Colors.black87,
//                             fontWeight: value == true
//                                 ? FontWeight.w600
//                                 : FontWeight.normal,
//                           )),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: GestureDetector(
//                 onTap: _isEditMode ? () => onChanged(false) : null,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   decoration: BoxDecoration(
//                     color: value == false ? Colors.red[600] : Colors.grey[100],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color:
//                           value == false ? Colors.red[600]! : Colors.grey[300]!,
//                       width: 2,
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Icon(Icons.cancel,
//                           color:
//                               value == false ? Colors.white : Colors.grey[600],
//                           size: 28),
//                       const SizedBox(height: 8),
//                       AutoText('NO_MESSAGE',
//                           style: TextStyle(
//                             color:
//                                 value == false ? Colors.white : Colors.black87,
//                             fontWeight: value == false
//                                 ? FontWeight.w600
//                                 : FontWeight.normal,
//                           )),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }

//   Widget _buildHealthIndicator(
//       String title, String value, String message, IconData icon, Color color) {
//     if (value.isEmpty) return const SizedBox.shrink();
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 AutoText('$title $value',
//                     style: const TextStyle(fontWeight: FontWeight.bold)),
//                 if (message.isNotEmpty)
//                   AutoText(message,
//                       style: TextStyle(fontSize: 12, color: color)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGenotypeBadge(String genotype) {
//     final isHighRisk = genotype == 'SS' || genotype == 'SC';
//     final isMediumRisk = genotype == 'AS' || genotype == 'AC';
//     final color = isHighRisk
//         ? Colors.red[700]!
//         : isMediumRisk
//             ? Colors.orange[700]!
//             : Colors.green[700]!;
//     final bgColor = isHighRisk
//         ? Colors.red[50]!
//         : isMediumRisk
//             ? Colors.orange[50]!
//             : Colors.green[50]!;
//     final label = isHighRisk
//         ? 'High risk — refer to specialist'
//         : isMediumRisk
//             ? 'Carrier — partner testing advised'
//             : 'Low risk';
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.4)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(isHighRisk ? Icons.warning : Icons.info_outline,
//               color: color, size: 14),
//           const SizedBox(width: 4),
//           Text(label, style: TextStyle(fontSize: 11, color: color)),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: AutoText('P_T_B'),
//         backgroundColor: Colors.blue[700],
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               _buildOverviewCard(),

//               // Health Indicators Summary
//               if (_bmi != null ||
//                   _bpMessage.isNotEmpty ||
//                   _pcvMessage.isNotEmpty)
//                 Card(
//                   margin:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         AutoText('HID',
//                             style: const TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 12),
//                         if (_bmi != null)
//                           _buildHealthIndicator(
//                             'BMI_2',
//                             _bmi!.toStringAsFixed(1),
//                             _bmiMessage,
//                             Icons.monitor_weight,
//                             _bmiMessage == autoI8lnGen.translate("THUMB_UP")
//                                 ? Colors.green
//                                 : Colors.orange,
//                           ),
//                         if (_bpMessage.isNotEmpty)
//                           _buildHealthIndicator(
//                             'BLOOD_PRESSURE_2',
//                             '${_systolicController.text}/${_diastolicController.text}',
//                             _bpMessage,
//                             Icons.favorite,
//                             _bpMessage == autoI8lnGen.translate("THUMB_UP")
//                                 ? Colors.green
//                                 : Colors.red,
//                           ),
//                         if (_pcvMessage.isNotEmpty)
//                           _buildHealthIndicator(
//                             'PCV_2',
//                             '${_pcvController.text}%',
//                             _pcvMessage,
//                             Icons.water_drop,
//                             _pcvMessage ==
//                                     autoI8lnGen.translate("HEALTH_ISSUE_7")
//                                 ? Colors.green
//                                 : Colors.orange,
//                           ),
//                         if (_expectedDeliveryDate != null)
//                           _buildHealthIndicator(
//                             'E_D_E_2',
//                             '${_expectedDeliveryDate!.day}/${_expectedDeliveryDate!.month}/${_expectedDeliveryDate!.year}',
//                             '',
//                             Icons.baby_changing_station,
//                             Colors.pink,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),

//               // ══════════════════════════════════════════════════════════
//               // SECTION 1: General / Personal Information
//               // ══════════════════════════════════════════════════════════
//               _buildExpandableSection(
//                 title: 'GIN',
//                 sectionKey: 'GENERAL_3',
//                 filledCount: [
//                   _educationLevel,
//                   _bloodGroup,
//                   _genotype,
//                   _registeredForANC?.toString(),
//                   _ageController.text.isNotEmpty ? 'y' : null,
//                   _heightController.text.isNotEmpty ? 'y' : null,
//                   _weightController.text.isNotEmpty ? 'y' : null,
//                   _systolicController.text.isNotEmpty ? 'y' : null,
//                   _pcvController.text.isNotEmpty ? 'y' : null,
//                   _urinalysisResult,
//                 ].where((x) => x != null && x.toString().isNotEmpty).length,
//                 totalCount: 10,
//                 children: _isEditMode
//                     ? [
//                         // ── Self-fill fields ───────────────────────────
//                         _buildDropdownFormField(
//                           label: 'EDU_LEVEL',
//                           value: _educationLevel,
//                           items: _educationLevelOptions,
//                           onChanged: (value) =>
//                               setState(() => _educationLevel = value),
//                         ),
//                         _buildTextFormField(
//                           controller: _ageController,
//                           label: 'G_Q_3',
//                           keyboardType: TextInputType.number,
//                           onChanged: (_) => _calculateBMI(),
//                           validator: (value) {
//                             if (value != null && value.isNotEmpty) {
//                               int? age = int.tryParse(value);
//                               if (age != null && (age < 11 || age > 60)) {
//                                 return autoI8lnGen.translate("A_11_60");
//                               }
//                             }
//                             return null;
//                           },
//                         ),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildTextFormField(
//                                 controller: _heightController,
//                                 label: 'G_Q_5',
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (_) => _calculateBMI(),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: _buildTextFormField(
//                                 controller: _weightController,
//                                 label: 'WEIGHT_KG',
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (_) => _calculateBMI(),
//                               ),
//                             ),
//                           ],
//                         ),

//                         // ── Pro-only section banner ────────────────────
//                         _buildProOnlyBanner(),

//                         // Blood Pressure — pro only
//                         _buildFieldLabelWithHelp(
//                           labelKey: 'G_Q_8_LABEL',
//                           // e.g. "Blood Pressure"
//                           titleKey: 'HELP_BP_TITLE',
//                           bodyKey: 'HELP_BP_BODY',
//                           whoKey: 'HELP_BP_WHO',
//                           isProOnly: true,
//                         ),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _buildTextFormField(
//                                 controller: _systolicController,
//                                 label: 'G_Q_8',
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (_) => _checkBloodPressure(),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: _buildTextFormField(
//                                 controller: _diastolicController,
//                                 label: 'G_Q_9',
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (_) => _checkBloodPressure(),
//                               ),
//                             ),
//                           ],
//                         ),

//                         // PCV — pro only
//                         _buildFieldLabelWithHelp(
//                           labelKey: 'PCV_T',
//                           titleKey: 'HELP_PCV_TITLE',
//                           bodyKey: 'HELP_PCV_BODY',
//                           whoKey: 'HELP_PCV_WHO',
//                           isProOnly: true,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               TextFormField(
//                                 controller: _pcvController,
//                                 decoration: InputDecoration(
//                                   labelText: autoI8lnGen.translate("PCV_LABEL"),
//                                   hintText: autoI8lnGen.translate("PCV_HINT"),
//                                   border: const OutlineInputBorder(),
//                                   enabled: _isEditMode,
//                                   suffixText: '%',
//                                 ),
//                                 keyboardType: TextInputType.number,
//                                 onChanged: (_) => _checkPCV(),
//                                 readOnly: !_isEditMode,
//                               ),
//                               const SizedBox(height: 6),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 12, vertical: 8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue[50],
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(color: Colors.blue[200]!),
//                                 ),
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Icon(Icons.info_outline,
//                                         size: 16, color: Colors.blue[700]),
//                                     const SizedBox(width: 6),
//                                     Expanded(
//                                       child: AutoText(
//                                         'PCV_EXPLAINER',
//                                         style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.blue[800]),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),

//                         // Albumin — pro only
//                         _buildFieldLabelWithHelp(
//                           labelKey: 'ALBUMIN_URINE',
//                           titleKey: 'HELP_ALBUMIN_TITLE',
//                           bodyKey: 'HELP_ALBUMIN_BODY',
//                           whoKey: 'HELP_ALBUMIN_WHO',
//                           isProOnly: true,
//                         ),
//                         _buildTextFormField(
//                           controller: _albuminController,
//                           label: 'ALBUMIN_URINE',
//                           keyboardType: TextInputType.number,
//                           onChanged: (_) => _checkAlbumin(),
//                         ),

//                         // Glucose — pro only
//                         _buildFieldLabelWithHelp(
//                           labelKey: 'GLUCOSE_URINE',
//                           titleKey: 'HELP_GLUCOSE_TITLE',
//                           bodyKey: 'HELP_GLUCOSE_BODY',
//                           whoKey: 'HELP_GLUCOSE_WHO',
//                           isProOnly: true,
//                         ),
//                         _buildTextFormField(
//                           controller: _glucoseController,
//                           label: 'GLUCOSE_URINE',
//                           keyboardType: TextInputType.number,
//                           onChanged: (_) => _checkGlucose(),
//                         ),

//                         // Urinalysis — pro only
//                         _buildFieldLabelWithHelp(
//                           labelKey: 'URINEANALYSIS',
//                           titleKey: 'HELP_URINALYSIS_TITLE',
//                           bodyKey: 'HELP_URINALYSIS_BODY',
//                           whoKey: 'HELP_URINALYSIS_WHO',
//                           isProOnly: true,
//                         ),
//                         _buildDropdownFormField(
//                           label: 'URINEANALYSIS',
//                           value: _urinalysisResult,
//                           items: [
//                             autoI8lnGen.translate("NORMAL"),
//                             autoI8lnGen.translate("SO_SO"),
//                             autoI8lnGen.translate("DANGER"),
//                           ],
//                           onChanged: (value) =>
//                               setState(() => _urinalysisResult = value),
//                         ),

//                         // Blood Group — ideally confirmed by pro
//                         _buildFieldLabelWithHelp(
//                           labelKey: 'BLOOD_GROUP_Q',
//                           titleKey: 'HELP_BLOODGROUP_TITLE',
//                           bodyKey: 'HELP_BLOODGROUP_BODY',
//                           whoKey: 'HELP_BLOODGROUP_WHO',
//                           isProOnly: false,
//                         ),
//                         _buildChipSelector(
//                           title: autoI8lnGen.translate('BLOOD_GROUP_Q'),
//                           subtitle:
//                               autoI8lnGen.translate('BLOOD_GROUP_SUBTITLE'),
//                           value: _bloodGroup,
//                           options: _bloodGroupOptions,
//                           onChanged: (value) =>
//                               setState(() => _bloodGroup = value),
//                           selectedColor: Colors.red[700],
//                         ),

//                         // Genotype — ideally confirmed by pro
//                         _buildFieldLabelWithHelp(
//                           labelKey: 'GENOTYPE_Q',
//                           titleKey: 'HELP_GENOTYPE_TITLE',
//                           bodyKey: 'HELP_GENOTYPE_BODY',
//                           whoKey: 'HELP_GENOTYPE_WHO',
//                           isProOnly: false,
//                         ),
//                         _buildChipSelector(
//                           title: autoI8lnGen.translate('GENOTYPE_Q'),
//                           subtitle: autoI8lnGen.translate('GENOTYPE_SUBTITLE'),
//                           value: _genotype,
//                           options: _genotypeOptions,
//                           onChanged: (value) =>
//                               setState(() => _genotype = value),
//                           selectedColor: Colors.purple[700],
//                         ),

//                         // ANC Registration — self-fill
//                         _buildNullableYesNoButton(
//                           title: autoI8lnGen.translate('ANC_REG_Q'),
//                           subtitle: autoI8lnGen.translate('ANC_REG_SUBTITLE'),
//                           value: _registeredForANC,
//                           onChanged: (value) =>
//                               setState(() => _registeredForANC = value),
//                         ),
//                         if (_registeredForANC == false)
//                           Container(
//                             padding: const EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.orange[50],
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.orange[200]!),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.campaign, color: Colors.orange[700]),
//                                 const SizedBox(width: 8),
//                                 Expanded(
//                                   child: AutoText(
//                                     'ANC_PROMPT',
//                                     style: TextStyle(
//                                         fontSize: 13,
//                                         color: Colors.orange[900]),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ]
//                     : [
//                         _buildSummaryItem(
//                           label: autoI8lnGen.translate('EDU_LEVEL'),
//                           value: _getDisplayValue(_educationLevel,
//                               autoI8lnGen.translate("NOT_SPECIFIED")),
//                         ),
//                         _buildSummaryItem(
//                           label: 'AGE',
//                           value: _getDisplayValue(_ageController.text,
//                               autoI8lnGen.translate("NOT_SPECIFIED")),
//                         ),
//                         _buildSummaryItem(
//                           label: 'H & W',
//                           value: _heightController.text.isNotEmpty &&
//                                   _weightController.text.isNotEmpty
//                               ? '${_heightController.text} cm, ${_weightController.text} kg'
//                               : autoI8lnGen.translate("NOT_SPECIFIED"),
//                           trailing: _bmi != null
//                               ? AutoText(
//                                   'BMI ${_bmi!.toStringAsFixed(1)}',
//                                   style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.bold),
//                                 )
//                               : null,
//                         ),
//                         _buildSummaryItem(
//                           label: 'BLOOD_PRESSURE',
//                           value: _systolicController.text.isNotEmpty &&
//                                   _diastolicController.text.isNotEmpty
//                               ? '${_systolicController.text}/${_diastolicController.text}'
//                               : autoI8lnGen.translate("NOT_SPECIFIED"),
//                         ),
//                         _buildSummaryItem(
//                           label: autoI8lnGen.translate('PCV_SHORT'),
//                           value: _pcvController.text.isNotEmpty
//                               ? '${_pcvController.text}%'
//                               : autoI8lnGen.translate("NOT_SPECIFIED"),
//                         ),
//                         _buildSummaryItem(
//                           label: 'URINEANALYSIS',
//                           value: _getDisplayValue(_urinalysisResult,
//                               autoI8lnGen.translate("NOT_SPECIFIED")),
//                         ),
//                         // Blood Group summary
//                         Container(
//                           margin: const EdgeInsets.symmetric(vertical: 4),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey[300]!),
//                             borderRadius: BorderRadius.circular(8),
//                             color: Colors.grey[50],
//                           ),
//                           child: ListTile(
//                             dense: true,
//                             title: AutoText(
//                               autoI8lnGen.translate('BLOOD_GROUP'),
//                               style: const TextStyle(
//                                   fontSize: 14, fontWeight: FontWeight.w500),
//                             ),
//                             subtitle: AutoText(
//                               _getDisplayValue(_bloodGroup,
//                                   autoI8lnGen.translate("NOT_SPECIFIED")),
//                               style: const TextStyle(
//                                   fontSize: 13, color: Colors.black87),
//                             ),
//                             trailing: _bloodGroup != null
//                                 ? Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 10, vertical: 4),
//                                     decoration: BoxDecoration(
//                                       color: Colors.red[50],
//                                       borderRadius: BorderRadius.circular(12),
//                                       border:
//                                           Border.all(color: Colors.red[200]!),
//                                     ),
//                                     child: Text(
//                                       _bloodGroup!,
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.red[800]),
//                                     ),
//                                   )
//                                 : null,
//                           ),
//                         ),
//                         // Genotype summary
//                         Container(
//                           margin: const EdgeInsets.symmetric(vertical: 4),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey[300]!),
//                             borderRadius: BorderRadius.circular(8),
//                             color: Colors.grey[50],
//                           ),
//                           child: ListTile(
//                             dense: true,
//                             title: AutoText(
//                               autoI8lnGen.translate('GENOTYPE'),
//                               style: const TextStyle(
//                                   fontSize: 14, fontWeight: FontWeight.w500),
//                             ),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 AutoText(
//                                   _getDisplayValue(_genotype,
//                                       autoI8lnGen.translate("NOT_SPECIFIED")),
//                                   style: const TextStyle(
//                                       fontSize: 13, color: Colors.black87),
//                                 ),
//                                 if (_genotype != null) ...[
//                                   const SizedBox(height: 4),
//                                   _buildGenotypeBadge(_genotype!),
//                                 ],
//                               ],
//                             ),
//                           ),
//                         ),
//                         _buildSummaryItem(
//                           label: autoI8lnGen.translate('ANC_REG'),
//                           value: _registeredForANC == null
//                               ? autoI8lnGen.translate("NOT_SPECIFIED")
//                               : _registeredForANC!
//                                   ? autoI8lnGen.translate('YES_MESSAGE')
//                                   : autoI8lnGen.translate('NO_MESSAGE'),
//                         ),
//                       ],
//               ),

//               // ══════════════════════════════════════════════════════════
//               // SECTION 2: Lifestyle
//               // ══════════════════════════════════════════════════════════
//               _buildExpandableSection(
//                 title: 'LIFESTYLE',
//                 sectionKey: 'LIFESTYLE'.toLowerCase(),
//                 filledCount: [
//                   _smokesTobacco ? autoI8lnGen.translate("YES_MESSAGE") : '',
//                   _drinksAlcohol ? autoI8lnGen.translate("YES_MESSAGE") : '',
//                 ].where((x) => x.isNotEmpty).length,
//                 totalCount: 2,
//                 children: _isEditMode
//                     ? [
//                         _buildYesNoButton(
//                           title: 'G_Q_11',
//                           value: _smokesTobacco,
//                           onChanged: (value) =>
//                               setState(() => _smokesTobacco = value),
//                         ),
//                         if (_smokesTobacco) ...[
//                           _buildTextFormField(
//                             controller: _smokingDetailsController,
//                             label: 'G_Q_12',
//                           ),
//                           _buildButtonGroup(
//                             title: 'G_Q_13',
//                             value: _smokingFrequency,
//                             options: [
//                               autoI8lnGen.translate("DAILY_2"),
//                               autoI8lnGen.translate("WEEKLY_2"),
//                               autoI8lnGen.translate("L_O"),
//                             ],
//                             onChanged: (value) =>
//                                 setState(() => _smokingFrequency = value!),
//                           ),
//                         ],
//                         _buildYesNoButton(
//                           title: 'D_Y_A',
//                           value: _drinksAlcohol,
//                           onChanged: (value) =>
//                               setState(() => _drinksAlcohol = value),
//                         ),
//                         if (_drinksAlcohol) ...[
//                           _buildButtonGroup(
//                             title: 'Type of alcohol',
//                             value: _alcoholType,
//                             options: ['Beer', 'Liquor', 'Both'],
//                             onChanged: (value) =>
//                                 setState(() => _alcoholType = value!),
//                           ),
//                           _buildButtonGroup(
//                             title: 'How often?',
//                             value: _alcoholFrequency,
//                             options: [
//                               autoI8lnGen.translate("DAILY_2"),
//                               autoI8lnGen.translate("WEEKLY_2"),
//                               autoI8lnGen.translate("L_O"),
//                             ],
//                             onChanged: (value) =>
//                                 setState(() => _alcoholFrequency = value!),
//                           ),
//                         ],
//                       ]
//                     : [
//                         _buildSummaryItem(
//                           label: 'T_USE',
//                           value: _smokesTobacco
//                               ? autoI8lnGen.translate(
//                                   'YES_MESSAGE${_smokingFrequency != null ? " - $_smokingFrequency" : ""}')
//                               : 'NO_MESSAGE',
//                         ),
//                         _buildSummaryItem(
//                           label: 'AL_USE',
//                           value: _drinksAlcohol
//                               ? 'YES_MESSAGE${_alcoholType != null ? " - $_alcoholType" : ""}${_alcoholFrequency != null ? " ($_alcoholFrequency)" : ""}'
//                               : 'NO_MESSAGE',
//                         ),
//                       ],
//               ),

//               // ══════════════════════════════════════════════════════════
//               // SECTION 3: Medical History
//               // ══════════════════════════════════════════════════════════
//               _buildExpandableSection(
//                 title: 'M_H',
//                 sectionKey: 'MDCL',
//                 filledCount: [
//                   _hivTestSelf,
//                   _syphilisTest,
//                   _tbTest,
//                   _malariaTest,
//                   _wormTest,
//                   _tetanusVaccinations > 0
//                       ? autoI8lnGen.translate("YES_MESSAGE")
//                       : null,
//                 ].where((x) => x != null && x.toString().isNotEmpty).length,
//                 totalCount: 6,
//                 children: _isEditMode
//                     ? [
//                         // Herbal medicine — self-fill
//                         _buildYesNoButton(
//                           title: 'D_Y_HM',
//                           value: _usesHerbalMedicine,
//                           onChanged: (value) =>
//                               setState(() => _usesHerbalMedicine = value),
//                         ),
//                         if (_usesHerbalMedicine) ...[
//                           _buildTextFormField(
//                             controller: _herbalMedicineController,
//                             label: 'WHB',
//                           ),
//                           _buildButtonGroup(
//                             title: 'G_Q_13',
//                             value: _herbalFrequency,
//                             options: [
//                               autoI8lnGen.translate("DAILY_2"),
//                               autoI8lnGen.translate("WEEKLY_2"),
//                               autoI8lnGen.translate("L_O"),
//                             ],
//                             onChanged: (value) =>
//                                 setState(() => _herbalFrequency = value!),
//                           ),
//                         ],

//                         // ── Pro-only section banner ──────────────────
//                         _buildProOnlyBanner(),

//                         // HIV — with help
//                         _buildFieldLabelWithHelp(
//                           labelKey: 'HI_T_S',
//                           titleKey: 'HELP_HIV_TITLE',
//                           bodyKey: 'HELP_HIV_BODY',
//                           whoKey: 'HELP_HIV_WHO',
//                           isProOnly: false,
//                         ),
//                         _buildButtonGroup(
//                           title: 'H_TV',
//                           value: _hivTestSelf,
//                           options: [
//                             autoI8lnGen.translate("YES_MESSAGE"),
//                             autoI8lnGen.translate("NO_MESSAGE"),
//                             autoI8lnGen.translate("D_ONT_KNOW"),
//                           ],
//                           onChanged: (value) =>
//                               setState(() => _hivTestSelf = value!),
//                         ),
//                         _buildYesNoButton(
//                           title: 'ARE_YOU_THERAPY',
//                           value: _onART,
//                           onChanged: (value) => setState(() => _onART = value),
//                         ),
//                         if (_onART) ...[
//                           _buildTextFormField(
//                             controller: _artStartController,
//                             label: 'SINCE_WHEN',
//                             hint: 'MM/YYYY',
//                           ),
//                         ],

//                         // Syphilis — with help
//                         _buildFieldLabelWithHelp(
//                           labelKey: 'S_T_E',
//                           titleKey: 'HELP_SYPHILIS_TITLE',
//                           bodyKey: 'HELP_SYPHILIS_BODY',
//                           whoKey: 'HELP_SYPHILIS_WHO',
//                           isProOnly: false,
//                         ),
//                         _buildButtonGroup(
//                           title: 'G_Q_14',
//                           value: _syphilisTest,
//                           options: [
//                             autoI8lnGen.translate("YES_MESSAGE"),
//                             autoI8lnGen.translate("NO_MESSAGE"),
//                             autoI8lnGen.translate("D_ONT_KNOW"),
//                           ],
//                           onChanged: (value) =>
//                               setState(() => _syphilisTest = value!),
//                         ),

//                         // TB — with help
//                         _buildFieldLabelWithHelp(
//                           labelKey: 'TB_TEST',
//                           titleKey: 'HELP_TB_TITLE',
//                           bodyKey: 'HELP_TB_BODY',
//                           whoKey: 'HELP_TB_WHO',
//                           isProOnly: false,
//                         ),
//                         _buildButtonGroup(
//                           title: 'G_Q_16',
//                           value: _tbTest,
//                           options: [
//                             autoI8lnGen.translate("YES_MESSAGE"),
//                             autoI8lnGen.translate("NO_MESSAGE"),
//                             autoI8lnGen.translate("D_ONT_KNOW"),
//                           ],
//                           onChanged: (value) =>
//                               setState(() => _tbTest = value!),
//                         ),

//                         // Malaria — with help
//                         _buildFieldLabelWithHelp(
//                           labelKey: 'M_T_E',
//                           titleKey: 'HELP_MALARIA_TITLE',
//                           bodyKey: 'HELP_MALARIA_BODY',
//                           whoKey: 'HELP_MALARIA_WHO',
//                           isProOnly: false,
//                         ),
//                         _buildButtonGroup(
//                           title: 'TESTED_MALARIA',
//                           value: _malariaTest,
//                           options: [
//                             autoI8lnGen.translate("YES_MESSAGE"),
//                             autoI8lnGen.translate("NO_MESSAGE"),
//                             autoI8lnGen.translate("D_ONT_KNOW"),
//                           ],
//                           onChanged: (value) =>
//                               setState(() => _malariaTest = value!),
//                         ),

//                         _buildButtonGroup(
//                           title: 'G_Q_32',
//                           value: _wormTest,
//                           options: [
//                             autoI8lnGen.translate("YES_MESSAGE"),
//                             autoI8lnGen.translate("NO_MESSAGE"),
//                             autoI8lnGen.translate("D_ONT_KNOW"),
//                           ],
//                           onChanged: (value) =>
//                               setState(() => _wormTest = value!),
//                         ),
//                         _buildButtonGroup(
//                           title: 'G_Q_23',
//                           value: _tetanusVaccinations.toString(),
//                           options: ['0', '1', '2', '3', '4'],
//                           onChanged: (value) => setState(
//                               () => _tetanusVaccinations = int.parse(value!)),
//                         ),
//                         _buildYesNoButton(
//                           title: 'G_Q_37',
//                           value: _hasOtherIssues,
//                           onChanged: (value) =>
//                               setState(() => _hasOtherIssues = value),
//                         ),
//                         if (_hasOtherIssues) ...[
//                           _buildTextFormField(
//                             controller: _disabilityController,
//                             label: 'G_Q_38',
//                             hint: 'G_Q_39',
//                           ),
//                         ],
//                       ]
//                     : [
//                         _buildSummaryItem(
//                           label: 'HIV Test Status',
//                           value: _getDisplayValue(_hivTestSelf, ''),
//                         ),
//                         if (_onART)
//                           _buildSummaryItem(
//                             label: 'ARRT',
//                             value: 'O_T_S ${_artStartController.text}',
//                             statusColor: Colors.blue,
//                           ),
//                         _buildSummaryItem(
//                           label: 'S_T_E',
//                           value: _getDisplayValue(_syphilisTest,
//                               autoI8lnGen.translate("NOT_SPECIFIED")),
//                         ),
//                         _buildSummaryItem(
//                           label: 'TB_TEST',
//                           value: _getDisplayValue(
//                               _tbTest, autoI8lnGen.translate("NOT_SPECIFIED")),
//                         ),
//                         _buildSummaryItem(
//                           label: 'M_T_E',
//                           value: _getDisplayValue(_malariaTest,
//                               autoI8lnGen.translate("NOT_SPECIFIED")),
//                         ),
//                         _buildSummaryItem(
//                           label: 'T_V_A',
//                           value: _tetanusVaccinations > 0
//                               ? '$_tetanusVaccinations DOSES'
//                               : 'NONE_REC',
//                         ),
//                         if (_hasOtherIssues)
//                           _buildSummaryItem(
//                             label: 'OHIS',
//                             value: _disabilityController.text.isNotEmpty
//                                 ? _disabilityController.text
//                                 : 'YES_D_N_S',
//                             statusColor: Colors.orange,
//                           ),
//                       ],
//               ),

//               // ══════════════════════════════════════════════════════════
//               // SECTION 4: Pregnancy Information
//               // ══════════════════════════════════════════════════════════
//               _buildExpandableSection(
//                 title: 'P_I',
//                 sectionKey: 'P_2',
//                 filledCount: [
//                   _lastMenstrualPeriodController.text,
//                   _isFirstPregnancy
//                       ? autoI8lnGen.translate("F_WRD")
//                       : _liveBirthsController.text,
//                 ].where((x) => x.isNotEmpty).length,
//                 totalCount: 3,
//                 children: _isEditMode
//                     ? [
//                         _buildTextFormField(
//                           controller: _lastMenstrualPeriodController,
//                           label: 'G_Q_41',
//                           hint: 'DD/MM/YYYY',
//                           onChanged: (_) => _calculateExpectedDeliveryDate(),
//                         ),
//                         _buildYesNoButton(
//                           title: 'G_Q_42',
//                           value: _isFirstPregnancy,
//                           onChanged: (value) =>
//                               setState(() => _isFirstPregnancy = value),
//                         ),
//                         if (!_isFirstPregnancy) ...[
//                           _buildTextFormField(
//                             controller: _miscarriagesController,
//                             label: 'G_Q_43',
//                             keyboardType: TextInputType.number,
//                             hint: 'G_Q_44',
//                           ),
//                           _buildTextFormField(
//                             controller: _liveBirthsController,
//                             label: 'G_Q_45',
//                             keyboardType: TextInputType.number,
//                             hint: 'G_Q_44',
//                           ),
//                           _buildTextFormField(
//                             controller: _previousPregnanciesController,
//                             label: 'G_Q_46',
//                             keyboardType: TextInputType.number,
//                             hint: 'G_Q_44',
//                           ),
//                           _buildButtonGroup(
//                             title: 'G_Q_47',
//                             value: _lastPregnancyTiming,
//                             options: [
//                               autoI8lnGen.translate("G_Q_48"),
//                               autoI8lnGen.translate("G_Q_49"),
//                               autoI8lnGen.translate("G_Q_50"),
//                             ],
//                             onChanged: (value) =>
//                                 setState(() => _lastPregnancyTiming = value!),
//                           ),
//                           _buildYesNoButton(
//                             title: 'G_Q_52',
//                             value: _hadCesarean,
//                             onChanged: (value) =>
//                                 setState(() => _hadCesarean = value),
//                           ),
//                           if (_hadCesarean) ...[
//                             _buildTextFormField(
//                               controller: _cesareanCountController,
//                               label: 'G_Q_53',
//                               keyboardType: TextInputType.number,
//                             ),
//                           ],
//                         ],
//                       ]
//                     : [
//                         _buildSummaryItem(
//                           label: 'L_M_P',
//                           value: _getDisplayValue(
//                               _lastMenstrualPeriodController.text,
//                               autoI8lnGen.translate("NOT_SPECIFIED")),
//                         ),
//                         if (_expectedDeliveryDate != null)
//                           _buildSummaryItem(
//                             label: 'E_D_D',
//                             value:
//                                 '${_expectedDeliveryDate!.day}/${_expectedDeliveryDate!.month}/${_expectedDeliveryDate!.year}',
//                             statusColor: Colors.pink,
//                           ),
//                         _buildSummaryItem(
//                           label: 'F_P_E',
//                           value:
//                               _isFirstPregnancy ? 'YES_MESSAGE' : 'NO_MESSAGE',
//                         ),
//                         _buildSummaryItem(
//                           label: 'Previous Miscarriages',
//                           value: _miscarriagesController.text.isNotEmpty
//                               ? _miscarriagesController.text
//                               : autoI8lnGen.translate("NOT_SPECIFIED"),
//                         ),
//                         if (!_isFirstPregnancy) ...[
//                           _buildSummaryItem(
//                             label: 'P_LV_B',
//                             value: _getDisplayValue(_liveBirthsController.text,
//                                 autoI8lnGen.translate("NOT_SPECIFIED")),
//                           ),
//                           _buildSummaryItem(
//                             label: 'P_P',
//                             value: _getDisplayValue(
//                                 _previousPregnanciesController.text,
//                                 autoI8lnGen.translate("NOT_SPECIFIED")),
//                           ),
//                           if (_lastPregnancyTiming != null)
//                             _buildSummaryItem(
//                               label: 'L_P_T',
//                               value: _lastPregnancyTiming!,
//                             ),
//                           if (_hadCesarean)
//                             _buildSummaryItem(
//                               label: 'P_C_E',
//                               value: _cesareanCountController.text.isNotEmpty
//                                   ? '${_cesareanCountController.text} TIMES'
//                                   : 'YES_MESSAGE',
//                               statusColor: Colors.orange,
//                             ),
//                         ],
//                       ],
//               ),

//               // Footer
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 margin: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.blue[200]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(Icons.info_outline, color: Colors.blue[700]),
//                         const SizedBox(width: 8),
//                         AutoText(
//                           'H_T_U_S',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[700],
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     AutoText('TEIM'),
//                     AutoText('TOST'),
//                     AutoText('RINA'),
//                     AutoText('OIPC'),
//                     AutoText('GIAC'),
//                     AutoText('Y_H_P_I'),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 80),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: _isEditMode
//           ? FloatingActionButton.extended(
//               onPressed: _saveData,
//               backgroundColor: Colors.red[800],
//               foregroundColor: Colors.white,
//               icon: const Icon(Icons.save),
//               label: AutoText('SAVE_CHANGES'),
//             )
//           : FloatingActionButton(
//               onPressed: () => setState(() => _isEditMode = true),
//               backgroundColor: Colors.blue[700],
//               foregroundColor: Colors.white,
//               child: const Icon(Icons.edit),
//               tooltip: autoI8lnGen.translate("E_I_F"),
//             ),
//     );
//   }

//   @override
//   void dispose() {
//     _ageController.dispose();
//     _heightController.dispose();
//     _weightController.dispose();
//     _systolicController.dispose();
//     _diastolicController.dispose();
//     _pcvController.dispose();
//     _albuminController.dispose();
//     _glucoseController.dispose();
//     _smokingDetailsController.dispose();
//     _herbalMedicineController.dispose();
//     _modernMedicineController.dispose();
//     _artStartController.dispose();
//     _syphilisTreatmentController.dispose();
//     _tbVaccinationYearController.dispose();
//     _tbTreatmentStartController.dispose();
//     _tbTreatmentStopController.dispose();
//     _malariaTestDateController.dispose();
//     _antimalarialTreatmentController.dispose();
//     _disabilityController.dispose();
//     _lastMenstrualPeriodController.dispose();
//     _miscarriagesController.dispose();
//     _liveBirthsController.dispose();
//     _previousPregnanciesController.dispose();
//     _stillbornController.dispose();
//     _cesareanCountController.dispose();
//     _deliveryRemarksController.dispose();
//     super.dispose();
//   }
// }
