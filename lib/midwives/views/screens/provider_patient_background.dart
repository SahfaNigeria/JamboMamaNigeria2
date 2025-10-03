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

      final doc = await _firestore
          .collection('health_provider_data')
          .doc(widget.providerId)
          .collection('patient_backgrounds')
          .doc(widget.patientId)
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
        _errorMessage = autoI8lnGen.translate("'E_L_P_D $e'");
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
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
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
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
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const AutoText(
            'N_B_D_A_2',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          AutoText(
            'P_H_B_F',
            style: TextStyle(color: Colors.grey[600]),
          ),
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
          _buildInfoRow('H', _patientData!['height']?.toString(), 'cm'),
          _buildInfoRow('W', _patientData!['weight']?.toString(), 'kg'),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('BMI_2', [
          _buildInfoRow('BMI_2', _patientData!['bmi']?.toStringAsFixed(1), ''),
          _buildInfoRow('STATUS', _patientData!['bmi_message'], ''),
        ]),
      ],
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
          _buildInfoRow(
              'HEAMOGOBLIN_T', _patientData!['haemoglobin']?.toString(), 'g/dL'),
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
          _buildInfoRow('S_T',
              _getBooleanText(_patientData!['smokes_tobacco']), ''),
          if (_isTrue(_patientData!['smokes_tobacco'])) ...[
            _buildInfoRow('DETAILS', _patientData!['smoking_details'], ''),
            _buildInfoRow('FREQ', _patientData!['smoking_frequency'], ''),
          ],
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('AL_USE', [
          _buildInfoRow('D_A',
              _getBooleanText(_patientData!['drinks_alcohol']), ''),
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
          _buildInfoRow(
              'S_TE', _patientData!['hiv_test_self'], ''),
          _buildInfoRow('P_TE', _patientData!['hiv_test_partner'], ''),
          _buildInfoRow('O_A', _getBooleanText(_patientData!['on_art']), ''),
          if (_isTrue(_patientData!['on_art']))
            _buildInfoRow(
                'A_S_D', _patientData!['art_start_date'], ''),
          _buildInfoRow(
              'P_A_S', _patientData!['partner_art_status'], ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('O_T_E', [
          _buildInfoRow('S_T_E', _patientData!['syphilis_test'], ''),
          _buildInfoRow(
              'S_TRE', _patientData!['syphilis_treatment'], ''),
          _buildInfoRow('TB_TEST', _patientData!['tb_test'], ''),
          _buildInfoRow('TB_VA',
              _getBooleanText(_patientData!['tb_vaccination']), ''),
          _buildInfoRow('M_T_E', _patientData!['malaria_test'], ''),
          _buildInfoRow('W_T_E', _patientData!['worm_test'], ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('VACC', [
          _buildInfoRow('T_V_A',
              _patientData!['tetanus_vaccinations']?.toString(), ''),
          _buildInfoRow('R_T_E',
              _getBooleanText(_patientData!['tetanus_recent']), ''),
        ]),
      ],
    );
  }

  Widget _buildPregnancyHistoryCards() {
    return Column(
      children: [
        _buildInfoCard('C_PE', [
          _buildInfoRow('L_M_P',
              _patientData!['last_menstrual_period'], ''),
          _buildInfoRow('E_D_E',
              _formatDate(_patientData!['expected_delivery_date']), ''),
          _buildInfoRow('F_P_E',
              _getBooleanText(_patientData!['is_first_pregnancy']), ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('P_H_I', [
          _buildInfoRow('Previous Pregnancies',
              _patientData!['previous_pregnancies']?.toString(), ''),
          _buildInfoRow(
              'L_BI', _patientData!['live_births']?.toString(), ''),
          _buildInfoRow(
              'MISCARRIAGES', _patientData!['miscarriages']?.toString(), ''),
          _buildInfoRow(
              'S_B', _patientData!['stillborn']?.toString(), ''),
          _buildInfoRow('H_CE',
              _getBooleanText(_patientData!['had_cesarean']), ''),
          if (_isTrue(_patientData!['had_cesarean']))
            _buildInfoRow('CEC',
                _patientData!['cesarean_count']?.toString(), ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('D_HI', [
          _buildInfoRow('H_F_V',
              _getBooleanText(_patientData!['had_forceps_vacuum']), ''),
          _buildInfoRow('H_H_B',
              _getBooleanText(_patientData!['had_heavy_bleeding']), ''),
          _buildInfoRow(
              'H_T_E', _getBooleanText(_patientData!['had_tears']), ''),
          _buildInfoRow(
              'D_RE', _patientData!['delivery_remarks'], ''),
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
            child: AutoText(
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
            AutoText(
              'L_U_D $lastUpdatedText',
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

    // Handle boolean values
    if (value is bool) {
      return value ? autoI8lnGen.translate("YES_MESSAGE") : autoI8lnGen.translate("NO_2");
    }

    // Handle string values that might represent booleans
    if (value is String) {
      final lowerValue = value.toLowerCase().trim();
      if (lowerValue == autoI8lnGen.translate("TRUE") || lowerValue == autoI8lnGen.translate("YES_MESSAGE") || lowerValue == '1') {
        return autoI8lnGen.translate("YES_MESSAGE");
      } else if (lowerValue == autoI8lnGen.translate("FALSE") ||
          lowerValue == autoI8lnGen.translate("NO_2").toLowerCase() ||
          lowerValue == '0') {
        return autoI8lnGen.translate("NO_2");
      }
      // If it's a descriptive string, return as-is
      return value;
    }

    return autoI8lnGen.translate("NOT_SPECIFIED");
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return autoI8lnGen.translate("NOT_SPECIFIED");
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // Helper method to check if a value represents "true"
  bool _isTrue(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    if (value is String) {
      final lowerValue = value.toLowerCase().trim();
      return lowerValue == autoI8lnGen.translate("TRUE") || lowerValue == autoI8lnGen.translate("YES_MESSAGE") || lowerValue == '1';
    }

    return false;
  }
}
