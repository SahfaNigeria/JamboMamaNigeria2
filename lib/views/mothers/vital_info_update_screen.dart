import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VitalInfoUpdateScreen extends StatefulWidget {
  final String userId;
  final int currentWeek;
  final double? initialWeight;
  final double? initialBmi;

  const VitalInfoUpdateScreen({
    Key? key,
    required this.userId,
    required this.currentWeek,
    this.initialWeight,
    this.initialBmi,
  }) : super(key: key);

  @override
  _VitalInfoUpdateScreenState createState() => _VitalInfoUpdateScreenState();
}

class _VitalInfoUpdateScreenState extends State<VitalInfoUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _haemoglobinController = TextEditingController();
  final TextEditingController _systolicController = TextEditingController();
  final TextEditingController _diastolicController = TextEditingController();
  final TextEditingController _albuminController = TextEditingController();
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _pulseController = TextEditingController();
  final TextEditingController _fundaHeightController = TextEditingController();
  final TextEditingController _babyHeartbeatController =
      TextEditingController();

  String _urineAnalysis = 'Normal';
  bool _isLoading = false;

  String _weightGuidance = '';
  String _hbGuidance = '';
  String _bpGuidance = '';
  String _albuminGuidance = '';
  String _glucoseGuidance = '';
  String _pulseGuidance = '';

  // Function to save vital info to Firestore

  Future<void> _submitVitalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Step 1: Fallback — find connected provider
      String? providerId;
      final query = await _firestore
          .collection('allowed_to_chat')
          .where('requesterId', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        providerId = query.docs.first['recipientId'];
        print('✅ Connected provider found: $providerId');
      } else {
        print('⚠️ No connected provider found for user: ${widget.userId}');
      }

      // Step 2: Prepare data
      final vitalInfoData = {
        'userId': widget.userId,
        'providerId': providerId ?? '',
        'currentWeek': widget.currentWeek,
        'weight': _weightController.text.isNotEmpty
            ? double.tryParse(_weightController.text)
            : null,
        'haemoglobin': _haemoglobinController.text.isNotEmpty
            ? double.tryParse(_haemoglobinController.text)
            : null,
        'systolicPressure': _systolicController.text.isNotEmpty
            ? int.tryParse(_systolicController.text)
            : null,
        'diastolicPressure': _diastolicController.text.isNotEmpty
            ? int.tryParse(_diastolicController.text)
            : null,
        'albumin': _albuminController.text.isNotEmpty
            ? double.tryParse(_albuminController.text)
            : null,
        'glucose': _glucoseController.text.isNotEmpty
            ? double.tryParse(_glucoseController.text)
            : null,
        'urineAnalysis': _urineAnalysis,
        'pulseRate': _pulseController.text.isNotEmpty
            ? int.tryParse(_pulseController.text)
            : null,
        'fundalHeight': _fundaHeightController.text.isNotEmpty
            ? double.tryParse(_fundaHeightController.text)
            : null,
        'babyHeartbeat': _babyHeartbeatController.text.isNotEmpty
            ? int.tryParse(_babyHeartbeatController.text)
            : null,
        'timestamp': FieldValue.serverTimestamp(),
        'dateRecorded': DateTime.now().toIso8601String(),
      };

      // Step 3: Save to main vital_info collection
      await _firestore.collection('vital_info').add(vitalInfoData);

      // Step 4: Save a copy to the connected provider (if any)
      if (providerId != null && providerId.isNotEmpty) {
        final providerRef = _firestore
            .collection('health_provider_data')
            .doc(providerId)
            .collection('vital_info_from_patients')
            .doc(widget.userId)
            .collection('records');

        await providerRef.add(vitalInfoData);
        print('✅ Vital info also saved to provider’s view.');
      }

      // Step 5: Update latest info for patient
      await _firestore.collection('users').doc(widget.userId).update({
        'latestVitalInfo': vitalInfoData,
        'lastVitalInfoUpdate': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vital information saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving vital info: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getWeightGuidance(double? currentWeight) {
    if (currentWeight == null || widget.initialWeight == null) return '';
    double weightGain = currentWeight - widget.initialWeight!;
    double? bmi = widget.initialBmi;
    String guidance = '';
    if (widget.currentWeek <= 18 && weightGain > 3) {
      guidance = 'Rapid weight gain before 28 weeks: call your RHP';
    } else if (widget.currentWeek >= 19 &&
        widget.currentWeek <= 28 &&
        (weightGain < 2 || weightGain > 4)) {
      guidance = 'Weight gain should be 2-4 kg for weeks 19-28';
    } else if (widget.currentWeek >= 29 && (weightGain < 3 || weightGain > 5)) {
      guidance = 'Weight gain should be 3-5 kg for weeks 29-40';
    }
    if (bmi != null) {
      if (bmi < 18.5) {
        guidance += '\nBMI < 18.5: More weight gain allowed';
      } else if (bmi <= 24.9) {
        guidance += '\nBMI 18.5-24.9: Total weight gain 11.5-16 kg is fine';
      } else if (bmi < 30) {
        guidance += '\nBMI ≥25: Less weight gain is safer';
      } else {
        guidance += '\nBMI ≥30: Weight gain must be kept as low as possible';
      }
    }
    return guidance;
  }

  String _getHaemoglobinGuidance(double? hb) {
    if (hb == null) return '';
    if (hb < 10.5) return 'You are anaemic. Ask HP for iron pills now.';
    if (hb <= 12) return 'Low iron: Ask your HP for iron pills at next visit';
    if (hb > 14) return 'Contact your HP to bring it down';
    return 'Normal iron levels';
  }

  String _getBloodPressureGuidance(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) return '';
    if (systolic >= 90 &&
        systolic <= 120 &&
        diastolic >= 60 &&
        diastolic <= 80) {
      return '👍 Normal blood pressure';
    } else if (systolic <= 129 && diastolic <= 89) {
      return 'ELEVATED: Take rest, reduce salt, tell your health provider';
    } else if (systolic <= 139 && diastolic < 90) {
      return 'Hypertension stage 1: Caution, visit your healthcare provider';
    } else if (systolic > 140 && diastolic > 90) {
      return 'Hypertension stage 2: Call Emergency Service';
    } else if (systolic > 160 && diastolic > 100) {
      return 'Hypertension Crisis: Call Emergency Service Immediately';
    }
    return '';
  }

  String _getAlbuminGuidance(double? albumin) {
    if (albumin == null) return '';
    if (albumin <= 150) return '👍 Normal';
    return 'Needs treatment - HP will be alerted';
  }

  String _getGlucoseGuidance(double? glucose) {
    if (glucose == null) return '';
    if (glucose < 7.8) return '👍 Normal';
    if (glucose < 11.0) return '2nd test needed';
    return 'Gestational diabetes - HP will be alerted';
  }

  String _getPulseGuidance(int? pulse) {
    if (pulse == null) return '';
    if (pulse <= 90) return '👍 Normal pulse';
    if (pulse <= 100) return 'Take rest + contact your HP';
    return 'Danger! Your HP will be alerted';
  }

  Widget _buildGuidance(String message) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.red[800], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red[800], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // Improved header section widget
  Widget _buildHeaderSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red[50]!,
              Colors.red[100]!,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[200]!, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We need updates for:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip('🩺 Blood pressure'),
                      _buildInfoChip('💓 Pulse'),
                      _buildInfoChip('⚖️ Weight'),
                      _buildInfoChip('💧 Urine'),
                      _buildInfoChip('🩸 Haemoglobin'),
                      _buildInfoChip('🤰 Belly height'),
                      _buildInfoChip('👶 Baby heartbeat'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[800], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Need help? Contact your referent health provider or ANC clinic',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Colors.red[800],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _weightController.addListener(() {
      final val = double.tryParse(_weightController.text);
      setState(() => _weightGuidance = _getWeightGuidance(val));
    });
    _haemoglobinController.addListener(() {
      final val = double.tryParse(_haemoglobinController.text);
      setState(() => _hbGuidance = _getHaemoglobinGuidance(val));
    });
    _systolicController.addListener(() {
      final s = int.tryParse(_systolicController.text);
      final d = int.tryParse(_diastolicController.text);
      setState(() => _bpGuidance = _getBloodPressureGuidance(s, d));
    });
    _diastolicController.addListener(() {
      final s = int.tryParse(_systolicController.text);
      final d = int.tryParse(_diastolicController.text);
      setState(() => _bpGuidance = _getBloodPressureGuidance(s, d));
    });
    _albuminController.addListener(() {
      final val = double.tryParse(_albuminController.text);
      setState(() => _albuminGuidance = _getAlbuminGuidance(val));
    });
    _glucoseController.addListener(() {
      final val = double.tryParse(_glucoseController.text);
      setState(() => _glucoseGuidance = _getGlucoseGuidance(val));
    });
    _pulseController.addListener(() {
      final val = int.tryParse(_pulseController.text);
      setState(() => _pulseGuidance = _getPulseGuidance(val));
    });
  }

  Widget _buildCard({
    required String title,
    IconData? icon,
    required Widget child,
    String? guidance,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, color: Colors.red[800], size: 20),
                if (icon != null) const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
            (guidance != null && guidance.isNotEmpty)
                ? _buildGuidance(guidance)
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vital Info Update'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(), // Updated header section

              _buildCard(
                title: 'Weight (kg)',
                icon: Icons.monitor_weight,
                child: TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(hintText: 'Enter current weight'),
                ),
                guidance: _weightGuidance,
              ),
              _buildCard(
                title: 'Haemoglobin (g/dl)',
                icon: Icons.opacity,
                child: TextFormField(
                  controller: _haemoglobinController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(hintText: 'Enter haemoglobin'),
                ),
                guidance: _hbGuidance,
              ),
              _buildCard(
                title: 'Blood Pressure (mmHg)',
                icon: Icons.bloodtype,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _systolicController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Systolic'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _diastolicController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Diastolic'),
                      ),
                    ),
                  ],
                ),
                guidance: _bpGuidance,
              ),
              _buildCard(
                title: 'Albumin in Urine (mg/L)',
                icon: Icons.science,
                child: TextFormField(
                  controller: _albuminController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Enter albumin'),
                ),
                guidance: _albuminGuidance,
              ),
              _buildCard(
                title: 'Glucose in Urine (mmol/L)',
                icon: Icons.bubble_chart,
                child: TextFormField(
                  controller: _glucoseController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Enter glucose'),
                ),
                guidance: _glucoseGuidance,
              ),
              _buildCard(
                title: 'Urine Analysis',
                icon: Icons.analytics,
                child: DropdownButtonFormField<String>(
                  value: _urineAnalysis,
                  items: ['Normal', 'So-so', 'Danger'].map((val) {
                    return DropdownMenuItem(value: val, child: Text(val));
                  }).toList(),
                  onChanged: (val) => setState(() => _urineAnalysis = val!),
                ),
              ),
              _buildCard(
                title: 'Pulse Rate (/min)',
                icon: Icons.favorite,
                child: TextFormField(
                  controller: _pulseController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(hintText: 'Enter pulse rate'),
                ),
                guidance: _pulseGuidance,
              ),
              if (widget.currentWeek >= 20)
                _buildCard(
                  title: 'Fundal Height (cm)',
                  icon: Icons.height,
                  child: TextFormField(
                    controller: _fundaHeightController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(hintText: 'Enter fundal height'),
                  ),
                ),
              if (widget.currentWeek >= 20)
                _buildCard(
                  title: 'Baby Heartbeat (/min)',
                  icon: Icons.monitor_heart,
                  child: TextFormField(
                    controller: _babyHeartbeatController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(hintText: 'Enter heartbeat'),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitVitalInfo,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[800],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('SUBMIT VITAL INFO',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _haemoglobinController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _albuminController.dispose();
    _glucoseController.dispose();
    _pulseController.dispose();
    _fundaHeightController.dispose();
    _babyHeartbeatController.dispose();
    super.dispose();
  }
}
