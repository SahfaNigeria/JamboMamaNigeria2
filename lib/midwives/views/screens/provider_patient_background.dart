import 'package:auto_i8ln/auto_i8ln.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ProviderPatientBackgroundScreen extends StatefulWidget {
  final String patientId;
  final String providerId;
  final String? patientName;

  const ProviderPatientBackgroundScreen({
    Key? key,
    required this.patientId,
    required this.providerId,
    this.patientName,
  }) : super(key: key);

  @override
  State<ProviderPatientBackgroundScreen> createState() =>
      _ProviderPatientBackgroundScreenState();
}

class _ProviderPatientBackgroundScreenState
    extends State<ProviderPatientBackgroundScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _patientData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPatientBackground();
  }

  Future<void> _loadPatientBackground() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Read from the patient's own record — same data, no provider scoping needed
      final doc = await _firestore
          .collection('patients')
          .doc(widget.patientId)
          .collection('background')
          .doc('patient_background')
          .get();

      if (doc.exists) {
        setState(() {
          _patientData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = autoI8lnGen.translate("N_O_D_F");
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '${autoI8lnGen.translate('E_L_P_D')}: $e';
        _isLoading = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Minor check: age ≤ 16
  // ─────────────────────────────────────────────────────────────────────────

  bool get _isMinor {
    final age = _patientData?['age'];
    if (age == null) return false;
    final ageInt = age is int ? age : int.tryParse(age.toString());
    return ageInt != null && ageInt <= 16;
  }

  /// Returns the patient name with asterisk wrapping if she is a minor,
  /// e.g.  "** Amara Osei **"
  String get _displayName {
    final name = widget.patientName ?? '';
    if (_isMinor) return '** $name **';
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(autoI8lnGen.translate('PATIENT_BACKGROUND')),
            Row(
              children: [
                Text(
                  _displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _isMinor ? FontWeight.bold : FontWeight.normal,
                    color: _isMinor ? Colors.yellow[200] : Colors.white70,
                  ),
                ),
                if (_isMinor) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red[700],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'MINOR',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatientBackground,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _patientData != null
                  ? _buildPatientDataView()
                  : _buildNoDataView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPatientBackground,
            child: const AutoText('RETRY'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const AutoText('N_B_D_A_2', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          AutoText('P_H_B_F', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildPatientDataView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Minor banner (shown prominently at top of data view)
          if (_isMinor) _buildMinorBanner(),

          // Alerts Section (if any)
          if (_patientData!['alerts'] != null &&
              (_patientData!['alerts'] as List).isNotEmpty)
            _buildAlertsSection(),

          // Demographics Section
          _buildSection('DEMOGRAPHICS', _buildDemographicsCards()),

          // Vital Signs Section
          _buildSection('V_S_N', _buildVitalSignsCards()),

          // Lab Results Section
          _buildSection('L_RE', _buildLabResultsCards()),

          // Lifestyle Section
          _buildSection('LIFESTYLE', _buildLifestyleCards()),

          // Medical History Section
          _buildSection('M_H', _buildMedicalHistoryCards()),

          // Pregnancy History Section
          if (_hasPregnancyData())
            _buildSection('P_H', _buildPregnancyHistoryCards()),

          // Last Updated
          _buildLastUpdatedSection(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Minor banner — shown at the very top of the data view
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMinorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.child_care, color: Colors.red[700], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_displayName} is a minor (age ${_patientData!['age']}). '
              'Ensure appropriate safeguarding protocols are followed.',
              style: TextStyle(
                color: Colors.red[800],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    final alerts = _patientData!['alerts'] as List;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  AutoText(
                    'ALERTS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...alerts.map((alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AutoText(
                            alert.toString(),
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: AutoText(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
        content,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDemographicsCards() {
    return Column(
      children: [
        _buildInfoCard('B_I', [
          _buildInfoRow('AGE', _patientData!['age']?.toString(), 'years'),
          _buildInfoRow(
              'SCHOOLING', _patientData!['schooling']?.toString(), 'years'),
          _buildInfoRow('EDU_LEVEL', _patientData!['education_level'], ''),
          _buildInfoRow('H', _patientData!['height']?.toString(), 'cm'),
          _buildInfoRow('W', _patientData!['weight']?.toString(), 'kg'),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('BMI_2', [
          _buildInfoRow('BMI_2', _patientData!['bmi']?.toStringAsFixed(1), ''),
          _buildInfoRow('STATUS', _patientData!['bmi_message'], ''),
        ]),
        const SizedBox(height: 16),
        // ── Genotype & Blood Group ─────────────────────────────────────
        _buildInfoCard('BLOOD_GENOTYPE', [
          _buildInfoRow('BLOOD_GROUP', _patientData!['blood_group'], ''),
          _buildInfoRow('GENOTYPE', _patientData!['genotype'], ''),
          _buildGenotypeRiskRow(_patientData!['genotype']),
          _buildInfoRow('ANC_REG',
              _getBooleanText(_patientData!['registered_for_anc']), ''),
        ]),
      ],
    );
  }

  /// Displays a coloured risk badge for the genotype value.
  Widget _buildGenotypeRiskRow(dynamic genotype) {
    if (genotype == null) return const SizedBox.shrink();
    final g = genotype.toString();
    final isHighRisk = g == 'SS' || g == 'SC';
    final isMediumRisk = g == 'AS' || g == 'AC';
    final color = isHighRisk
        ? Colors.red[700]!
        : isMediumRisk
            ? Colors.orange[700]!
            : Colors.green[700]!;
    final label = isHighRisk
        ? 'High risk — refer to specialist'
        : isMediumRisk
            ? 'Carrier — partner testing advised'
            : 'Low risk';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: AutoText(
              'GENOTYPE_RISK',
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignsCards() {
    return Column(
      children: [
        _buildInfoCard('BLOOD_PRESSURE', [
          _buildInfoRow(
              'SYSTOLIC', _patientData!['systolic_bp']?.toString(), 'mmHg'),
          _buildInfoRow(
              'DIASTOLIC', _patientData!['diastolic_bp']?.toString(), 'mmHg'),
          _buildInfoRow('STATUS', _patientData!['bp_message'], ''),
        ]),
      ],
    );
  }

  Widget _buildLabResultsCards() {
    return Column(
      children: [
        _buildInfoCard('B_T_E', [
          _buildInfoRow('PCV_SHORT', _patientData!['pcv']?.toString(), '%'),
          _buildInfoRow('STATUS', _patientData!['pcv_message'], ''),
          _buildInfoRow('HEAMOGOBLIN_T',
              _patientData!['haemoglobin']?.toString(), 'g/dL'),
          _buildInfoRow('STATUS', _patientData!['haemoglobin_message'], ''),
          _buildInfoRow(
              'ALBUMIN', _patientData!['albumin']?.toString(), 'g/dL'),
          _buildInfoRow('STATUS', _patientData!['albumin_message'], ''),
          _buildInfoRow(
              'GLUCOSE', _patientData!['glucose']?.toString(), 'mg/dL'),
          _buildInfoRow('STATUS', _patientData!['glucose_message'], ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('URINEANALYSIS', [
          _buildInfoRow('RESULTS', _patientData!['urinalysis'], ''),
        ]),
      ],
    );
  }

  Widget _buildLifestyleCards() {
    return Column(
      children: [
        _buildInfoCard('T_USE', [
          _buildInfoRow(
              'S_T', _getBooleanText(_patientData!['smokes_tobacco']), ''),
          if (_isTrue(_patientData!['smokes_tobacco'])) ...[
            _buildInfoRow('DETAILS', _patientData!['smoking_details'], ''),
            _buildInfoRow('FREQ', _patientData!['smoking_frequency'], ''),
          ],
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('AL_USE', [
          _buildInfoRow(
              'D_A', _getBooleanText(_patientData!['drinks_alcohol']), ''),
          if (_isTrue(_patientData!['drinks_alcohol'])) ...[
            _buildInfoRow('TYPE_2', _patientData!['alcohol_type'], ''),
            _buildInfoRow('FREQ', _patientData!['alcohol_frequency'], ''),
          ],
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('M_D', [
          _buildInfoRow('UHM',
              _getBooleanText(_patientData!['uses_herbal_medicine']), ''),
          if (_isTrue(_patientData!['uses_herbal_medicine'])) ...[
            _buildInfoRow(
                'DETAILS', _patientData!['herbal_medicine_details'], ''),
            _buildInfoRow('FREQ', _patientData!['herbal_frequency'], ''),
          ],
          _buildInfoRow('UMM',
              _getBooleanText(_patientData!['uses_modern_medicine']), ''),
          if (_isTrue(_patientData!['uses_modern_medicine']))
            _buildInfoRow('TYPE_2', _patientData!['modern_medicine_type'], ''),
        ]),
      ],
    );
  }

  Widget _buildMedicalHistoryCards() {
    return Column(
      children: [
        _buildInfoCard('HIV_S', [
          _buildInfoRow('S_TE', _patientData!['hiv_test_self'], ''),
          _buildInfoRow('P_TE', _patientData!['hiv_test_partner'], ''),
          _buildInfoRow('O_A', _getBooleanText(_patientData!['on_art']), ''),
          if (_isTrue(_patientData!['on_art']))
            _buildInfoRow('A_S_D', _patientData!['art_start_date'], ''),
          _buildInfoRow('P_A_S', _patientData!['partner_art_status'], ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('O_T_E', [
          _buildInfoRow('S_T_E', _patientData!['syphilis_test'], ''),
          _buildInfoRow('S_TRE', _patientData!['syphilis_treatment'], ''),

          // ── TB (expanded) ────────────────────────────────────────────
          _buildInfoRow('TB_TEST', _patientData!['tb_test'], ''),
          _buildInfoRow(
              'TB_VA', _getBooleanText(_patientData!['tb_vaccination']), ''),
          _buildInfoRow(
              'TB_VAC_YEAR', _patientData!['tb_vaccination_year'], ''),
          _buildInfoRow('ON_TB_TREATMENT',
              _getBooleanText(_patientData!['on_tb_treatment']), ''),
          if (_isTrue(_patientData!['on_tb_treatment'])) ...[
            _buildInfoRow(
                'TB_TX_START', _patientData!['tb_treatment_start'], ''),
            _buildInfoRow('TB_TX_STOP', _patientData!['tb_treatment_stop'], ''),
          ],
          _buildInfoRow('CURRENTLY_ON_TB',
              _getBooleanText(_patientData!['currently_on_tb_treatment']), ''),

          // ── Malaria (expanded) ───────────────────────────────────────
          _buildInfoRow('M_T_E', _patientData!['malaria_test'], ''),
          _buildInfoRow('M_TEST_DATE', _patientData!['malaria_test_date'], ''),
          _buildInfoRow('ON_ANTIMALARIALS',
              _getBooleanText(_patientData!['on_antimalarials']), ''),
          if (_isTrue(_patientData!['on_antimalarials']))
            _buildInfoRow(
                'ANTIMALARIAL_TX', _patientData!['antimalarial_treatment'], ''),
          _buildInfoRow(
              'ANTIMALARIAL_RECENT', _patientData!['antimalarial_recent'], ''),

          // ── Worms ────────────────────────────────────────────────────
          _buildInfoRow('W_T_E', _patientData!['worm_test'], ''),
          _buildInfoRow(
              'WORM_MED_RECENT', _patientData!['worm_medicine_recent'], ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('VACC', [
          _buildInfoRow(
              'T_V_A', _patientData!['tetanus_vaccinations']?.toString(), ''),
          _buildInfoRow(
              'R_T_E', _getBooleanText(_patientData!['tetanus_recent']), ''),
        ]),
        const SizedBox(height: 16),
        // ── Other issues ──────────────────────────────────────────────
        if (_isTrue(_patientData!['has_other_issues']))
          _buildInfoCard('OHIS', [
            _buildInfoRow('H_O_I',
                _getBooleanText(_patientData!['has_other_issues']), ''),
            _buildInfoRow('DETAILS', _patientData!['disability_details'], ''),
          ]),
      ],
    );
  }

  Widget _buildPregnancyHistoryCards() {
    return Column(
      children: [
        _buildInfoCard('C_PE', [
          _buildInfoRow('L_M_P', _patientData!['last_menstrual_period'], ''),
          _buildInfoRow('E_D_E',
              _formatDate(_patientData!['expected_delivery_date']), ''),
          _buildInfoRow('F_P_E',
              _getBooleanText(_patientData!['is_first_pregnancy']), ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('P_H_I', [
          _buildInfoRow('Previous Pregnancies',
              _patientData!['previous_pregnancies']?.toString(), ''),
          _buildInfoRow('L_BI', _patientData!['live_births']?.toString(), ''),
          _buildInfoRow(
              'MISCARRIAGES', _patientData!['miscarriages']?.toString(), ''),
          _buildInfoRow('S_B', _patientData!['stillborn']?.toString(), ''),
          _buildInfoRow(
              'H_CE', _getBooleanText(_patientData!['had_cesarean']), ''),
          if (_isTrue(_patientData!['had_cesarean']))
            _buildInfoRow(
                'CEC', _patientData!['cesarean_count']?.toString(), ''),
          _buildInfoRow('L_P_T', _patientData!['last_pregnancy_timing'], ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('D_HI', [
          _buildInfoRow('H_F_V',
              _getBooleanText(_patientData!['had_forceps_vacuum']), ''),
          _buildInfoRow('H_H_B',
              _getBooleanText(_patientData!['had_heavy_bleeding']), ''),
          _buildInfoRow(
              'H_T_E', _getBooleanText(_patientData!['had_tears']), ''),
          // ── Tear sub-questions (previously missing) ──────────────────
          if (_patientData!['had_tears'] != null &&
              _patientData!['had_tears'].toString().toLowerCase() ==
                  autoI8lnGen.translate('YES_MESSAGE').toLowerCase()) ...[
            _buildInfoRow(
                'TEARS_STITCHING', _patientData!['tears_need_stitching'], ''),
            _buildInfoRow(
                'TEARS_HEALED', _patientData!['tears_healed_naturally'], ''),
            _buildInfoRow(
                'TEARS_BOTHERING', _patientData!['tears_still_bothering'], ''),
          ],
          _buildInfoRow('D_RE', _patientData!['delivery_remarks'], ''),
        ]),
      ],
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoText(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, String unit) {
    if (value == null || value.isEmpty || value == 'null') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: AutoText(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$value${unit.isNotEmpty ? ' $unit' : ''}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdatedSection() {
    final updatedAt = _patientData!['updated_at'];
    String lastUpdatedText = autoI8lnGen.translate("ERROR_8");

    if (updatedAt != null) {
      if (updatedAt is Timestamp) {
        lastUpdatedText =
            DateFormat('MMM dd, yyyy - hh:mm a').format(updatedAt.toDate());
      }
    }

    return Card(
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.update, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              '${autoI8lnGen.translate('L_U_D')}: $lastUpdatedText',
              style: TextStyle(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasPregnancyData() {
    return _patientData!['last_menstrual_period'] != null ||
        _patientData!['expected_delivery_date'] != null ||
        _patientData!['is_first_pregnancy'] != null ||
        _patientData!['previous_pregnancies'] != null;
  }

  String _getBooleanText(dynamic value) {
    if (value == null) return autoI8lnGen.translate("NOT_SPECIFIED");

    if (value is bool) {
      return value
          ? autoI8lnGen.translate("YES_MESSAGE")
          : autoI8lnGen.translate("NO_2");
    }

    if (value is String) {
      final lowerValue = value.toLowerCase().trim();
      if (lowerValue == autoI8lnGen.translate("TRUE") ||
          lowerValue == autoI8lnGen.translate("YES_MESSAGE") ||
          lowerValue == '1') {
        return autoI8lnGen.translate("YES_MESSAGE");
      } else if (lowerValue == autoI8lnGen.translate("FALSE") ||
          lowerValue == autoI8lnGen.translate("NO_2").toLowerCase() ||
          lowerValue == '0') {
        return autoI8lnGen.translate("NO_2");
      }
      return value;
    }

    return autoI8lnGen.translate("NOT_SPECIFIED");
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty)
      return autoI8lnGen.translate("NOT_SPECIFIED");
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  bool _isTrue(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      final lowerValue = value.toLowerCase().trim();
      return lowerValue == autoI8lnGen.translate("TRUE") ||
          lowerValue == autoI8lnGen.translate("YES_MESSAGE") ||
          lowerValue == '1';
    }
    return false;
  }
}
