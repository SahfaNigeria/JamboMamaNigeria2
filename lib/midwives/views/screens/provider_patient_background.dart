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
          _errorMessage = 'No background data found for this patient';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading patient data: $e';
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
            child: const Text('Retry'),
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
          const Text(
            'No background data available',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Patient has not completed their background form yet',
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
          _buildSection('Demographics', _buildDemographicsCards()),

          // Vital Signs Section
          _buildSection('Vital Signs', _buildVitalSignsCards()),

          // Lab Results Section
          _buildSection('Lab Results', _buildLabResultsCards()),

          // Lifestyle Section
          _buildSection('Lifestyle', _buildLifestyleCards()),

          // Medical History Section
          _buildSection('Medical History', _buildMedicalHistoryCards()),

          // Pregnancy History Section
          if (_hasPregnancyData())
            _buildSection('Pregnancy History', _buildPregnancyHistoryCards()),

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
                  Text(
                    'Alerts',
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
                          child: Text(
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
          child: Text(
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
        _buildInfoCard('Basic Information', [
          _buildInfoRow('Age', _patientData!['age']?.toString(), 'years'),
          _buildInfoRow(
              'Schooling', _patientData!['schooling']?.toString(), 'years'),
          _buildInfoRow('Height', _patientData!['height']?.toString(), 'cm'),
          _buildInfoRow('Weight', _patientData!['weight']?.toString(), 'kg'),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('BMI', [
          _buildInfoRow('BMI', _patientData!['bmi']?.toStringAsFixed(1), ''),
          _buildInfoRow('Status', _patientData!['bmi_message'], ''),
        ]),
      ],
    );
  }

  Widget _buildVitalSignsCards() {
    return Column(
      children: [
        _buildInfoCard('Blood Pressure', [
          _buildInfoRow(
              'Systolic', _patientData!['systolic_bp']?.toString(), 'mmHg'),
          _buildInfoRow(
              'Diastolic', _patientData!['diastolic_bp']?.toString(), 'mmHg'),
          _buildInfoRow('Status', _patientData!['bp_message'], ''),
        ]),
      ],
    );
  }

  Widget _buildLabResultsCards() {
    return Column(
      children: [
        _buildInfoCard('Blood Tests', [
          _buildInfoRow(
              'Haemoglobin', _patientData!['haemoglobin']?.toString(), 'g/dL'),
          _buildInfoRow('Status', _patientData!['haemoglobin_message'], ''),
          _buildInfoRow(
              'Albumin', _patientData!['albumin']?.toString(), 'g/dL'),
          _buildInfoRow('Status', _patientData!['albumin_message'], ''),
          _buildInfoRow(
              'Glucose', _patientData!['glucose']?.toString(), 'mg/dL'),
          _buildInfoRow('Status', _patientData!['glucose_message'], ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Urinalysis', [
          _buildInfoRow('Result', _patientData!['urinalysis'], ''),
        ]),
      ],
    );
  }

  Widget _buildLifestyleCards() {
    return Column(
      children: [
        _buildInfoCard('Tobacco Use', [
          _buildInfoRow('Smokes Tobacco',
              _getBooleanText(_patientData!['smokes_tobacco']), ''),
          if (_isTrue(_patientData!['smokes_tobacco'])) ...[
            _buildInfoRow('Details', _patientData!['smoking_details'], ''),
            _buildInfoRow('Frequency', _patientData!['smoking_frequency'], ''),
          ],
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Alcohol Use', [
          _buildInfoRow('Drinks Alcohol',
              _getBooleanText(_patientData!['drinks_alcohol']), ''),
          if (_isTrue(_patientData!['drinks_alcohol'])) ...[
            _buildInfoRow('Type', _patientData!['alcohol_type'], ''),
            _buildInfoRow('Frequency', _patientData!['alcohol_frequency'], ''),
          ],
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Medications', [
          _buildInfoRow('Uses Herbal Medicine',
              _getBooleanText(_patientData!['uses_herbal_medicine']), ''),
          if (_isTrue(_patientData!['uses_herbal_medicine'])) ...[
            _buildInfoRow(
                'Details', _patientData!['herbal_medicine_details'], ''),
            _buildInfoRow('Frequency', _patientData!['herbal_frequency'], ''),
          ],
          _buildInfoRow('Uses Modern Medicine',
              _getBooleanText(_patientData!['uses_modern_medicine']), ''),
          if (_isTrue(_patientData!['uses_modern_medicine']))
            _buildInfoRow('Type', _patientData!['modern_medicine_type'], ''),
        ]),
      ],
    );
  }

  Widget _buildMedicalHistoryCards() {
    return Column(
      children: [
        _buildInfoCard('HIV Status', [
          _buildInfoRow('Self Test', _patientData!['hiv_test_self'], ''),
          _buildInfoRow('Partner Test', _patientData!['hiv_test_partner'], ''),
          _buildInfoRow('On ART', _getBooleanText(_patientData!['on_art']), ''),
          if (_isTrue(_patientData!['on_art']))
            _buildInfoRow(
                'ART Start Date', _patientData!['art_start_date'], ''),
          _buildInfoRow(
              'Partner ART Status', _patientData!['partner_art_status'], ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Other Tests', [
          _buildInfoRow('Syphilis Test', _patientData!['syphilis_test'], ''),
          _buildInfoRow(
              'Syphilis Treatment', _patientData!['syphilis_treatment'], ''),
          _buildInfoRow('TB Test', _patientData!['tb_test'], ''),
          _buildInfoRow('TB Vaccination',
              _getBooleanText(_patientData!['tb_vaccination']), ''),
          _buildInfoRow('Malaria Test', _patientData!['malaria_test'], ''),
          _buildInfoRow('Worm Test', _patientData!['worm_test'], ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Vaccinations', [
          _buildInfoRow('Tetanus Vaccinations',
              _patientData!['tetanus_vaccinations']?.toString(), ''),
          _buildInfoRow('Recent Tetanus',
              _getBooleanText(_patientData!['tetanus_recent']), ''),
        ]),
      ],
    );
  }

  Widget _buildPregnancyHistoryCards() {
    return Column(
      children: [
        _buildInfoCard('Current Pregnancy', [
          _buildInfoRow('Last Menstrual Period',
              _patientData!['last_menstrual_period'], ''),
          _buildInfoRow('Expected Delivery',
              _formatDate(_patientData!['expected_delivery_date']), ''),
          _buildInfoRow('First Pregnancy',
              _getBooleanText(_patientData!['is_first_pregnancy']), ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Pregnancy History', [
          _buildInfoRow('Previous Pregnancies',
              _patientData!['previous_pregnancies']?.toString(), ''),
          _buildInfoRow(
              'Live Births', _patientData!['live_births']?.toString(), ''),
          _buildInfoRow(
              'Miscarriages', _patientData!['miscarriages']?.toString(), ''),
          _buildInfoRow(
              'Stillborn', _patientData!['stillborn']?.toString(), ''),
          _buildInfoRow('Had Cesarean',
              _getBooleanText(_patientData!['had_cesarean']), ''),
          if (_isTrue(_patientData!['had_cesarean']))
            _buildInfoRow('Cesarean Count',
                _patientData!['cesarean_count']?.toString(), ''),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('Delivery History', [
          _buildInfoRow('Had Forceps/Vacuum',
              _getBooleanText(_patientData!['had_forceps_vacuum']), ''),
          _buildInfoRow('Had Heavy Bleeding',
              _getBooleanText(_patientData!['had_heavy_bleeding']), ''),
          _buildInfoRow(
              'Had Tears', _getBooleanText(_patientData!['had_tears']), ''),
          _buildInfoRow(
              'Delivery Remarks', _patientData!['delivery_remarks'], ''),
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
            Text(
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
            child: Text(
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
    String lastUpdatedText = 'Unknown';

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
              'Last Updated: $lastUpdatedText',
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
    if (value == null) return 'Not specified';

    // Handle boolean values
    if (value is bool) {
      return value ? 'Yes' : 'No';
    }

    // Handle string values that might represent booleans
    if (value is String) {
      final lowerValue = value.toLowerCase().trim();
      if (lowerValue == 'true' || lowerValue == 'yes' || lowerValue == '1') {
        return 'Yes';
      } else if (lowerValue == 'false' ||
          lowerValue == 'no' ||
          lowerValue == '0') {
        return 'No';
      }
      // If it's a descriptive string, return as-is
      return value;
    }

    return 'Not specified';
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Not specified';
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
      return lowerValue == 'true' || lowerValue == 'yes' || lowerValue == '1';
    }

    return false;
  }
}
